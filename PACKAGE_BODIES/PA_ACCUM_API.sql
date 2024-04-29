--------------------------------------------------------
--  DDL for Package Body PA_ACCUM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACCUM_API" AS
/* $Header: PAAAPIB.pls 120.2 2005/08/19 16:13:17 mwasowic ship $ */

  PROCEDURE get_period_date_range
		 (x_period_type               IN         VARCHAR2 DEFAULT 'P',
		  x_from_period_name          IN         VARCHAR2 DEFAULT NULL,
		  x_to_period_name            IN         VARCHAR2 DEFAULT NULL,
                  x_start_date             IN OUT        NOCOPY DATE, --File.Sql.39 bug 4440895
                  x_end_date               IN OUT        NOCOPY DATE, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER) --File.Sql.39 bug 4440895
  IS
  BEGIN
     x_err_code               := 0;
     x_err_stage              := 'Getting the period date range';

     x_start_date             := NULL;
     x_end_date               := NULL;

     -- Get the period start date and end date

     IF ( x_period_type = 'G' ) THEN
       -- Get the dates from GL_PERIOD_STATUSES table
/*
       SELECT MIN(sp.start_date)
       INTO   x_start_date
       FROM   gl_period_statuses sp, pa_implementations imp
       WHERE
           sp.period_name = NVL(x_from_period_name,sp.period_name)
       AND sp.set_of_books_id = imp.set_of_books_id
       AND sp.application_id = 101
       AND sp.adjustment_period_flag = 'N';

       SELECT MAX(ep.end_date)
       INTO   x_end_date
       FROM   gl_period_statuses ep, pa_implementations imp
       WHERE
           ep.period_name = NVL(x_to_period_name,ep.period_name)
       AND ep.set_of_books_id = imp.set_of_books_id
       AND ep.application_id = 101
       AND ep.adjustment_period_flag = 'N';
*/

       SELECT MIN(sp.start_date)
       INTO   x_start_date
       FROM   gl_period_statuses sp, pa_implementations imp
       WHERE
           sp.period_name =x_from_period_name
       AND sp.set_of_books_id = imp.set_of_books_id
       AND sp.application_id = pa_period_process_pkg.application_id
       AND sp.adjustment_period_flag = 'N';

       if x_start_date is null then

          SELECT MIN(sp.start_date)
          INTO   x_start_date
          FROM   gl_period_statuses sp, pa_implementations imp
          WHERE  sp.set_of_books_id = imp.set_of_books_id
          AND sp.application_id = pa_period_process_pkg.application_id
          AND sp.adjustment_period_flag = 'N';

       end if;


       SELECT MAX(ep.end_date)
       INTO   x_end_date
       FROM   gl_period_statuses ep, pa_implementations imp
       WHERE
           ep.period_name = x_to_period_name
       AND ep.set_of_books_id = imp.set_of_books_id
       AND ep.application_id = pa_period_process_pkg.application_id
       AND ep.adjustment_period_flag = 'N';

       if x_end_date is null then

          SELECT MAX(ep.end_date)
          INTO   x_end_date
          FROM   gl_period_statuses ep, pa_implementations imp
          WHERE  ep.set_of_books_id = imp.set_of_books_id
          AND ep.application_id = pa_period_process_pkg.application_id
          AND ep.adjustment_period_flag = 'N';

       end if;

     ELSE

       -- Get the dates from PA_PERIODS table

       SELECT MIN(sp.start_date)
       INTO   x_start_date
       FROM   pa_periods sp
       WHERE  sp.period_name = x_from_period_name;

       IF ( x_start_date IS NULL ) THEN
            SELECT MIN(sp.start_date)
            INTO   x_start_date
            FROM   pa_periods sp;
       END IF;

       SELECT MAX(ep.end_date)
       INTO   x_end_date
       FROM   pa_periods ep
       WHERE ep.period_name = x_to_period_name;

       IF (x_end_date IS NULL ) THEN
            SELECT MAX(ep.end_date)
            INTO   x_end_date
            FROM   pa_periods ep;
       END IF;

/*
       SELECT MIN(sp.start_date)
       INTO   x_start_date
       FROM   pa_periods sp
       WHERE
          sp.period_name = NVL(x_from_period_name,sp.period_name);

       SELECT MAX(ep.end_date)
       INTO   x_end_date
       FROM   pa_periods ep
       WHERE
              ep.period_name = NVL(x_to_period_name,ep.period_name);
*/

     END IF;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
  END get_period_date_range;

  -- Actuals accumulation API

  PROCEDURE get_proj_txn_accum
		 (x_project_id                IN         NUMBER,
		  x_task_id                   IN         NUMBER   DEFAULT NULL,
		  x_period_type               IN         VARCHAR2 DEFAULT 'P',
		  x_from_period_name          IN         VARCHAR2 DEFAULT NULL,
		  x_prd_start_date	      IN	 DATE     DEFAULT NULL,
		  x_prd_end_date	      IN	 DATE     DEFAULT NULL,
		  x_revenue                IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_raw_cost               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_burdened_cost          IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_quantity               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_labor_hours            IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_raw_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_burdened_cost IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_quantity      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_labor_hours   IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_raw_cost           IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_burdened_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  x_unit_of_measure        IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER) --File.Sql.39 bug 4440895
  IS
/* Done changes for bug 1631100.
   1. Replaced pa_periods with pa_periods_all with join with pa_implementations.
   2. Removed nvl for start and end date so that index can be used
*/

--    Modified for bug 4390421
--    CURSOR seltxnaccums_p(x_prd_start_date IN DATE, x_prd_end_date IN DATE) IS
      CURSOR seltxnaccums_p IS
      SELECT
          tot_revenue,
          tot_raw_cost,
          tot_burdened_cost,
          tot_quantity,
          tot_labor_hours,
          tot_billable_raw_cost,
          tot_billable_burdened_cost,
          tot_billable_quantity,
          tot_billable_labor_hours,
          tot_cmt_raw_cost,
          tot_cmt_burdened_cost,
          unit_of_measure
      FROM
	  pa_txn_accum pta /*,  commented for bug 4390421
          pa_periods_all pp,
          pa_implementations imp   */
      WHERE
          x_period_type = 'P'
      AND pta.project_id = x_project_id
      AND (
	   (x_task_id IS NULL)   --- project level numbers
	   OR
	   (pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = x_task_id
	          )
	    )
          )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.pa_period = x_from_period_name ;
/*   Commented for bug 4390421
      AND nvl(imp.org_id,-1) = nvl(pp.org_id,-1)
      AND pp.period_name = pta.pa_period
      AND pp.start_date BETWEEN
          x_prd_start_date AND                     -- Bug 1631100 Removed nvl
	  x_prd_end_date;
*/
/* Made changes for bug 1631100. For performance improvement added pa_periods table so that
   index on project_id , pa_period gets effectively used.
   For consistency purpose removed nvl for start date/end date. Refer bugdb for more details
*/

--    Modified for bug 4390421
--    CURSOR seltxnaccums_g(x_prd_start_date IN DATE, x_prd_end_date IN DATE) IS
      CURSOR seltxnaccums_g IS
      SELECT
          tot_revenue,
          tot_raw_cost,
          tot_burdened_cost,
          tot_quantity,
          tot_labor_hours,
          tot_billable_raw_cost,
          tot_billable_burdened_cost,
          tot_billable_quantity,
          tot_billable_labor_hours,
          tot_cmt_raw_cost,
          tot_cmt_burdened_cost,
          unit_of_measure
      FROM
/*   commented for bug 4390421
          pa_implementations imp,
          gl_period_statuses glp,
          pa_periods_all pp,  Commented for bug 2922974       Added for bug 1631100 performance tuning */
	  pa_txn_accum pta
      WHERE
          x_period_type = 'G'
      AND pta.project_id = x_project_id
      AND (
	   (x_task_id IS NULL)   --- project level numbers
	   OR
	   (pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = x_task_id
	          )
	    )
          )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.gl_period =  x_from_period_name ;      -- Added for bug 4390421
/*    AND pp.gl_period_name = glp.period_name       Commented for bug 2922974       Added for bug 1631100 performance tuning
      AND pp.period_name = pta.pa_period            Commented for bug 2922974       Added for bug 1631100 performance tuning
      AND nvl(pp.org_id, -1) = nvl(imp.org_id, -1)  Commented for bug 2922974       Added for bug 1631100 performance tuning
     --  Commented for bug 4390421
						AND glp.period_name = pta.gl_period
      AND glp.set_of_books_id = imp.set_of_books_id
      AND glp.application_id = pa_period_process_pkg.application_id
      AND glp.adjustment_period_flag = 'N'
      AND glp.start_date BETWEEN
          x_prd_start_date AND                      Bug 1631100 removed nvl
	  x_prd_end_date;
*/
  txnaccumrec_p     seltxnaccums_p%ROWTYPE;
  txnaccumrec_g     seltxnaccums_g%ROWTYPE;
  is_uom_unique     BOOLEAN;

  -- Added for bug 4390421
  P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');

  BEGIN
     x_err_code               := 0;
     x_err_stage              := 'Getting the Project Txn Accumlation';

  -- Added for bug 4390421
    If p_debug_mode = 'Y' and pa_budget_core1.g_calling_mode = 'CONCURRENT REQUEST' then
     fnd_file.put_line(1,x_err_stage);
    End if;
     -- all of the accumlation numbers are initialized in the calling
     -- procedure
     is_uom_unique := TRUE;


    IF x_period_type = 'G' THEN

--   commented for bug 4390421
--     FOR txnaccumrec_g IN seltxnaccums_g (x_prd_start_date, x_prd_end_date) LOOP
     FOR txnaccumrec_g IN seltxnaccums_g LOOP
       x_revenue := x_revenue +
                    NVL(txnaccumrec_g.TOT_REVENUE,0) ;
       x_raw_cost := x_raw_cost +
		     NVL(txnaccumrec_g.TOT_RAW_COST,0);
       x_burdened_cost := x_burdened_cost +
			  NVL(txnaccumrec_g.TOT_BURDENED_COST,0);
       x_quantity := x_quantity +
			NVL(txnaccumrec_g.TOT_QUANTITY,0);
       x_labor_hours := x_labor_hours +
			NVL(txnaccumrec_g.TOT_LABOR_HOURS,0);
       x_billable_raw_cost := x_billable_raw_cost +
			      NVL(txnaccumrec_g.TOT_BILLABLE_RAW_COST,0);
       x_billable_burdened_cost := x_billable_burdened_cost +
				   NVL(txnaccumrec_g.TOT_BILLABLE_BURDENED_COST,0);
       x_billable_quantity := x_billable_quantity +
			NVL(txnaccumrec_g.TOT_BILLABLE_QUANTITY,0);
       x_billable_labor_hours := x_billable_labor_hours +
				 NVL(txnaccumrec_g.TOT_BILLABLE_LABOR_HOURS,0);
       x_cmt_raw_cost := x_cmt_raw_cost + NVL(txnaccumrec_g.TOT_CMT_RAW_COST,0) ;
       x_cmt_burdened_cost := x_cmt_burdened_cost +
			      NVL(txnaccumrec_g.TOT_CMT_BURDENED_COST,0);

       -- Process UOM
       -- We will return UOM only if all the txn has the same UOM

       IF ( is_uom_unique AND txnaccumrec_g.unit_of_measure IS NOT NULL) THEN
          IF ( x_unit_of_measure IS NULL ) THEN
             x_unit_of_measure := txnaccumrec_g.unit_of_measure;
          ELSIF ( x_unit_of_measure <> txnaccumrec_g.unit_of_measure) THEN
            is_uom_unique := FALSE;
            x_unit_of_measure := NULL;
          END IF;
       END IF;

     END LOOP;

    END IF; /* End of x_period_type = 'G' */

    IF x_period_type = 'P' THEN

--   commented for bug 4390421
--     FOR txnaccumrec_p IN seltxnaccums_p (x_prd_start_date, x_prd_end_date) LOOP
     FOR txnaccumrec_p IN seltxnaccums_p LOOP
       x_revenue := x_revenue +
                    NVL(txnaccumrec_p.TOT_REVENUE,0) ;
       x_raw_cost := x_raw_cost +
		     NVL(txnaccumrec_p.TOT_RAW_COST,0);
       x_burdened_cost := x_burdened_cost +
			  NVL(txnaccumrec_p.TOT_BURDENED_COST,0);
       x_quantity := x_quantity +
			NVL(txnaccumrec_p.TOT_QUANTITY,0);
       x_labor_hours := x_labor_hours +
			NVL(txnaccumrec_p.TOT_LABOR_HOURS,0);
       x_billable_raw_cost := x_billable_raw_cost +
			      NVL(txnaccumrec_p.TOT_BILLABLE_RAW_COST,0);
       x_billable_burdened_cost := x_billable_burdened_cost +
				   NVL(txnaccumrec_p.TOT_BILLABLE_BURDENED_COST,0);
       x_billable_quantity := x_billable_quantity +
			NVL(txnaccumrec_p.TOT_BILLABLE_QUANTITY,0);
       x_billable_labor_hours := x_billable_labor_hours +
				 NVL(txnaccumrec_p.TOT_BILLABLE_LABOR_HOURS,0);
       x_cmt_raw_cost := x_cmt_raw_cost + NVL(txnaccumrec_p.TOT_CMT_RAW_COST,0) ;
       x_cmt_burdened_cost := x_cmt_burdened_cost +
			      NVL(txnaccumrec_p.TOT_CMT_BURDENED_COST,0);

       -- Process UOM
       -- We will return UOM only if all the txn has the same UOM

       IF ( is_uom_unique AND txnaccumrec_p.unit_of_measure IS NOT NULL) THEN
          IF ( x_unit_of_measure IS NULL ) THEN
             x_unit_of_measure := txnaccumrec_p.unit_of_measure;
          ELSIF ( x_unit_of_measure <> txnaccumrec_p.unit_of_measure) THEN
            is_uom_unique := FALSE;
            x_unit_of_measure := NULL;
          END IF;
       END IF;

     END LOOP;

    END IF; /* End of x_period_type = 'P' */

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
  END get_proj_txn_accum;

  PROCEDURE get_proj_res_accum
		 (x_project_id                IN         NUMBER,
		  x_task_id                   IN         NUMBER   DEFAULT NULL,
		  x_resource_list_member_id   IN         NUMBER   DEFAULT NULL,
		  x_period_type               IN         VARCHAR2 DEFAULT 'P',
		  x_from_period_name          IN         VARCHAR2 DEFAULT NULL,
		  x_prd_start_date	      IN	 DATE     DEFAULT NULL,
		  x_prd_end_date	      IN	 DATE     DEFAULT NULL,
		  x_revenue                IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_raw_cost               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_burdened_cost          IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_quantity               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_labor_hours            IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_raw_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_burdened_cost IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_quantity      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_labor_hours   IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_raw_cost           IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_burdened_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_unit_of_measure        IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER) --File.Sql.39 bug 4440895
  IS
/* Modified for performance. Bug 1631100
   Moved join for project_id and task_id to the pa_txn_accum table and joining to pa_resource
   accum_details thru txn_accum_id.
   replaced pa_periods with pa_periods_all. Removed nvl for start date and end date.
   Now index on project_id and pa_period will be very effectively used on pa_txn_accum
*/

--    Commented for bug 4390421
--      CURSOR selresaccums_p(x_prd_start_date IN DATE, x_prd_end_date IN DATE) IS
      CURSOR selresaccums_p IS
      SELECT
          PTA.TOT_REVENUE,
          PTA.TOT_RAW_COST,
          PTA.TOT_BURDENED_COST,
          PTA.TOT_QUANTITY,
          PTA.TOT_LABOR_HOURS,
          PTA.TOT_BILLABLE_RAW_COST,
          PTA.TOT_BILLABLE_BURDENED_COST,
          PTA.TOT_BILLABLE_QUANTITY,
          PTA.TOT_BILLABLE_LABOR_HOURS,
          PTA.TOT_CMT_RAW_COST,
          PTA.TOT_CMT_BURDENED_COST,
          PTA.UNIT_OF_MEASURE
      FROM
	  PA_TXN_ACCUM PTA  /*, Commented for bug 4390421
          pa_periods_all pp,
          pa_implementations imp */
      WHERE PTA.PROJECT_ID = X_PROJECT_ID
      AND (
              (x_task_id IS NULL)   --- project level numbers
              OR
              (PTA.TASK_ID IN
                    (SELECT
                          task_id
                     FROM
                          pa_tasks
                     CONNECT BY PRIOR task_id = parent_task_id
                     START WITH task_id = x_task_id
                     )
               )
           )
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
            -- Modified for bug 4390421
		(  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = X_RESOURCE_LIST_MEMBER_ID
		          or
			  PRLM.PARENT_MEMBER_ID = X_RESOURCE_LIST_MEMBER_ID  )
           /*  Commented for bug 4390421
		(
		  SELECT          -- 2nd level resource list members
			PRLM.RESOURCE_LIST_MEMBER_ID
		  FROM
			PA_RESOURCE_LIST_MEMBERS PRLM
		  WHERE
			PRLM.PARENT_MEMBER_ID = X_RESOURCE_LIST_MEMBER_ID
		  UNION
		  SELECT          -- Group level Resource list member
			X_RESOURCE_LIST_MEMBER_ID
		  FROM
			SYS.DUAL  */
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND x_period_type = 'P'
      AND pta.pa_period = x_from_period_name; -- Added for bug 4390421
/*   Commented for bug 4390421
      AND nvl(imp.org_id,-1) = nvl(pp.org_id,-1)
      AND pp.period_name = pta.pa_period
      AND pp.start_date BETWEEN
          x_prd_start_date AND
	  x_prd_end_date;
*/

/* Modified for performance. Bug 1631100
   Moved join for project_id and task_id to the pa_txn_accum table and joining to pa_resource
   accum_details thru txn_accum_id.
   Added pa_periods_all table to the from clause so that index on project_id, pa_period can
   be used.
   removed nvl from start date/end date for consistencey purpose.
*/

--    Commented for bug 4390421
--    CURSOR selresaccums_g(x_prd_start_date IN DATE, x_prd_end_date IN DATE) IS
      CURSOR selresaccums_g IS
      SELECT
          PTA.TOT_REVENUE,
          PTA.TOT_RAW_COST,
          PTA.TOT_BURDENED_COST,
          PTA.TOT_QUANTITY,
          PTA.TOT_LABOR_HOURS,
          PTA.TOT_BILLABLE_RAW_COST,
          PTA.TOT_BILLABLE_BURDENED_COST,
          PTA.TOT_BILLABLE_QUANTITY,
          PTA.TOT_BILLABLE_LABOR_HOURS,
          PTA.TOT_CMT_RAW_COST,
          PTA.TOT_CMT_BURDENED_COST,
          PTA.UNIT_OF_MEASURE
      FROM
/*      Commented for bug 4390421
          pa_implementations imp,
          gl_period_statuses glp, */
	  PA_TXN_ACCUM PTA
/*        PA_PERIODS_ALL PP       commented for bug 2922974  */
      WHERE PTA.PROJECT_ID = X_PROJECT_ID
            AND (
                 (x_task_id IS NULL)   --- project level numbers
                 OR
                 (PTA.TASK_ID IN
                       (SELECT
                             task_id
                        FROM
                             pa_tasks
                        CONNECT BY PRIOR task_id = parent_task_id
                        START WITH task_id = x_task_id
                        )
                  )
                )
        AND EXISTS (SELECT 'Yes'
                    FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
                    WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
	            AND PRAD.RESOURCE_LIST_MEMBER_ID IN
                -- Modified for bug 4390421
		(  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = X_RESOURCE_LIST_MEMBER_ID
		          or
			  PRLM.PARENT_MEMBER_ID = X_RESOURCE_LIST_MEMBER_ID  )
        /*
                (
                  SELECT          -- 2nd level resource list members
                        PRLM.RESOURCE_LIST_MEMBER_ID
                  FROM
                        PA_RESOURCE_LIST_MEMBERS PRLM
                  WHERE
                        PRLM.PARENT_MEMBER_ID = X_RESOURCE_LIST_MEMBER_ID
                  UNION
                  SELECT          -- Group level Resource list member
                        X_RESOURCE_LIST_MEMBER_ID
                  FROM
                        SYS.DUAL        */
                )
	      )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
/*    AND pp.gl_period_name = glp.period_name      commented for bug 2922974   Added for bug 1631100 performance tuning
      AND pp.period_name = pta.pa_period           commented for bug 2922974   Added for bug 1631100 performance tuning
      AND nvl(pp.org_id, -1) = nvl(imp.org_id, -1) commented for bug 2922974   Added for bug 1631100 performance tuning */
      AND x_period_type = 'G'
      AND pta.gl_period = x_from_period_name;
/*    Commented for bug 4390421
      AND glp.set_of_books_id = imp.set_of_books_id
      AND glp.application_id = pa_period_process_pkg.application_id
      AND glp.adjustment_period_flag = 'N'
      AND glp.start_date BETWEEN
          x_prd_start_date AND
	  x_prd_end_date; */

  resaccumrec_p     selresaccums_p%ROWTYPE;
  resaccumrec_g     selresaccums_g%ROWTYPE;
  is_uom_unique     BOOLEAN;

  -- Added for bug 4390421
  P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');

  BEGIN
     x_err_code               := 0;
     x_err_stage              := 'Getting the Project Res Accumlation';

  -- Added for bug 4390421
    If p_debug_mode = 'Y' and pa_budget_core1.g_calling_mode = 'CONCURRENT REQUEST' then
     fnd_file.put_line(1,x_err_stage);
    End if;

     -- all of the accumlation numbers are initialized in the calling
     -- procedure
     is_uom_unique := TRUE;

   IF x_period_type = 'G' THEN

--    Commented for bug 4390421
--     FOR resaccumrec_g IN selresaccums_g (x_prd_start_date, x_prd_end_date) LOOP
     FOR resaccumrec_g IN selresaccums_g LOOP

       x_revenue := x_revenue +
		    NVL(resaccumrec_g.TOT_REVENUE,0);
       x_raw_cost := x_raw_cost +
		     NVL(resaccumrec_g.TOT_RAW_COST,0);
       x_burdened_cost := x_burdened_cost +
			  NVL(resaccumrec_g.TOT_BURDENED_COST,0);
       x_quantity := x_quantity +
			NVL(resaccumrec_g.TOT_QUANTITY,0);
       x_labor_hours := x_labor_hours +
			NVL(resaccumrec_g.TOT_LABOR_HOURS,0);
       x_billable_raw_cost := x_billable_raw_cost +
			      NVL(resaccumrec_g.TOT_BILLABLE_RAW_COST,0);
       x_billable_burdened_cost := x_billable_burdened_cost +
				   NVL(resaccumrec_g.TOT_BILLABLE_BURDENED_COST,0);
       x_billable_quantity := x_billable_quantity +
			NVL(resaccumrec_g.TOT_BILLABLE_QUANTITY,0);
       x_billable_labor_hours := x_billable_labor_hours +
				 NVL(resaccumrec_g.TOT_BILLABLE_LABOR_HOURS,0);
       x_cmt_raw_cost := x_cmt_raw_cost + NVL(resaccumrec_g.TOT_CMT_RAW_COST,0) ;
       x_cmt_burdened_cost := x_cmt_burdened_cost +
			      NVL(resaccumrec_g.TOT_CMT_BURDENED_COST,0);
       -- Process UOM
       -- We will return UOM only if all the txn has the same UOM

       IF ( is_uom_unique AND resaccumrec_g.unit_of_measure IS NOT NULL) THEN
          IF ( x_unit_of_measure IS NULL ) THEN
             x_unit_of_measure := resaccumrec_g.unit_of_measure;
          ELSIF ( x_unit_of_measure <> resaccumrec_g.unit_of_measure) THEN
            is_uom_unique := FALSE;
            x_unit_of_measure := NULL;
          END IF;
       END IF;

   END LOOP;

   END IF; /* End of x_period_type = 'G' */


   IF x_period_type = 'P' THEN

--    Commented for bug 4390421
--     FOR resaccumrec_p IN selresaccums_p (x_prd_start_date, x_prd_end_date) LOOP
     FOR resaccumrec_p IN selresaccums_p LOOP
       x_revenue := x_revenue +
		    NVL(resaccumrec_p.TOT_REVENUE,0);
       x_raw_cost := x_raw_cost +
		     NVL(resaccumrec_p.TOT_RAW_COST,0);
       x_burdened_cost := x_burdened_cost +
			  NVL(resaccumrec_p.TOT_BURDENED_COST,0);
       x_quantity := x_quantity +
			NVL(resaccumrec_p.TOT_QUANTITY,0);
       x_labor_hours := x_labor_hours +
			NVL(resaccumrec_p.TOT_LABOR_HOURS,0);
       x_billable_raw_cost := x_billable_raw_cost +
			      NVL(resaccumrec_p.TOT_BILLABLE_RAW_COST,0);
       x_billable_burdened_cost := x_billable_burdened_cost +
				   NVL(resaccumrec_p.TOT_BILLABLE_BURDENED_COST,0);
       x_billable_quantity := x_billable_quantity +
			NVL(resaccumrec_p.TOT_BILLABLE_QUANTITY,0);
       x_billable_labor_hours := x_billable_labor_hours +
				 NVL(resaccumrec_p.TOT_BILLABLE_LABOR_HOURS,0);
       x_cmt_raw_cost := x_cmt_raw_cost + NVL(resaccumrec_p.TOT_CMT_RAW_COST,0) ;
       x_cmt_burdened_cost := x_cmt_burdened_cost +
			      NVL(resaccumrec_p.TOT_CMT_BURDENED_COST,0);
       -- Process UOM
       -- We will return UOM only if all the txn has the same UOM

       IF ( is_uom_unique AND resaccumrec_p.unit_of_measure IS NOT NULL) THEN
          IF ( x_unit_of_measure IS NULL ) THEN
             x_unit_of_measure := resaccumrec_p.unit_of_measure;
          ELSIF ( x_unit_of_measure <> resaccumrec_p.unit_of_measure) THEN
            is_uom_unique := FALSE;
            x_unit_of_measure := NULL;
          END IF;
       END IF;

     END LOOP;

   END IF; /* End of x_period_type = 'P' */

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
  END get_proj_res_accum;


  PROCEDURE get_proj_accum_actuals
		 (x_project_id                IN         NUMBER,
		  x_task_id                   IN         NUMBER   DEFAULT NULL,
		  x_resource_list_member_id   IN         NUMBER   DEFAULT NULL,
		  x_period_type               IN         VARCHAR2 DEFAULT 'P',
		  x_from_period_name          IN         VARCHAR2 DEFAULT NULL,
		  x_prd_start_date	      IN	 DATE     DEFAULT NULL,
		  x_prd_end_date	      IN	 DATE     DEFAULT NULL,
		  x_revenue                IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_raw_cost               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_burdened_cost          IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_quantity               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_labor_hours            IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_raw_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_burdened_cost IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_quantity      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_labor_hours   IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_raw_cost           IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_burdened_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_unit_of_measure        IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER) --File.Sql.39 bug 4440895
  IS
    -- Added for bug 4390421
  P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');

  BEGIN
     x_err_code               := 0;
     x_err_stage              := 'Getting the Project Accumlation';

  -- Added for bug 4390421
    If p_debug_mode = 'Y' and pa_budget_core1.g_calling_mode = 'CONCURRENT REQUEST' then
     fnd_file.put_line(1,x_err_stage);
    End if;

     x_revenue                := 0;
     x_raw_cost               := 0;
     x_burdened_cost          := 0;
     x_quantity               := 0;
     x_labor_hours            := 0;
     x_billable_raw_cost      := 0;
     x_billable_burdened_cost := 0;
     x_billable_quantity      := 0;
     x_billable_labor_hours   := 0;
     x_cmt_raw_cost           := 0;
     x_cmt_burdened_cost      := 0;
     x_unit_of_measure        := NULL;

     IF ( x_resource_list_member_id IS NULL ) THEN
       -- Call the txn accum
       get_proj_txn_accum
		 (x_project_id,
		  x_task_id,
		  x_period_type,
		  x_from_period_name,
		  x_prd_start_date,
		  x_prd_end_date,
		  x_revenue,
		  x_raw_cost,
		  x_burdened_cost,
		  x_quantity,
		  x_labor_hours,
		  x_billable_raw_cost,
		  x_billable_burdened_cost,
		  x_billable_quantity,
		  x_billable_labor_hours,
		  x_cmt_raw_cost,
		  x_cmt_burdened_cost,
                  x_unit_of_measure,
                  x_err_stage,
                  x_err_code);
     ELSE
       -- Call the resource accum
       get_proj_res_accum
		 (x_project_id,
		  x_task_id,
		  x_resource_list_member_id,
		  x_period_type,
		  x_from_period_name,
		  x_prd_start_date,
		  x_prd_end_date,
		  x_revenue,
		  x_raw_cost,
		  x_burdened_cost,
		  x_quantity,
		  x_labor_hours,
		  x_billable_raw_cost,
		  x_billable_burdened_cost,
		  x_billable_quantity,
		  x_billable_labor_hours,
		  x_cmt_raw_cost,
		  x_cmt_burdened_cost,
		  x_unit_of_measure,
                  x_err_stage,
                  x_err_code);
     END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
  END get_proj_accum_actuals;

PROCEDURE get_proj_accum_budgets
	 (x_project_id              	IN    NUMBER,
	  x_task_id       		IN    NUMBER   DEFAULT NULL,
	  x_resource_list_member_id   	IN    NUMBER   DEFAULT NULL,
	  x_period_type               	IN    VARCHAR2 DEFAULT 'P',
	  x_from_period_name          	IN    VARCHAR2 DEFAULT NULL,
	  x_to_period_name            	IN    VARCHAR2 DEFAULT NULL,
	  x_budget_type_code		IN    VARCHAR2 DEFAULT NULL,
	  x_base_raw_cost               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_base_burdened_cost          IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_base_revenue                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_base_quantity 		IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_base_labor_quantity         IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_unit_of_measure 		IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_orig_raw_cost               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_orig_burdened_cost          IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_orig_revenue                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_orig_quantity               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_orig_labor_quantity		IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_err_stage              	IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_err_code               	IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS

--- Transaction Cursor (Project- and Task-Level Amounts)
CURSOR seltxnbudget(x_start_date IN DATE, x_end_date IN DATE) IS
      SELECT
	bpv.base_raw_cost,
	bpv.base_burdened_cost,
	bpv.base_revenue,
	bpv.base_quantity,
	bpv.base_labor_quantity,
	bpv.unit_of_measure,
	bpv.orig_raw_cost,
	bpv.orig_burdened_cost,
	bpv.orig_revenue,
	bpv.orig_quantity,
	bpv.orig_labor_quantity
      FROM
	pa_budget_by_pa_period_v  bpv,
        pa_periods pp
      WHERE
		bpv.project_id = x_project_id
            AND (
	         (x_task_id IS NULL)   --- project level numbers
	         OR
	         (bpv.task_id IN
                       	(SELECT
                            	 t.task_id
                       	 FROM
                            	 pa_tasks t
                        	CONNECT BY PRIOR t.task_id = t.parent_task_id
                        	START WITH t.task_id = x_task_id
		 )
	           )
                       )
      AND x_period_type = 'P'
      AND pp.period_name = bpv.pa_period
      AND pp.start_date BETWEEN
          NVL(x_start_date,pp.start_date) AND NVL(x_end_date,pp.end_date)
     AND bpv.budget_type_code = NVL(x_budget_type_code,bpv.budget_type_code)
     UNION ALL
      SELECT
	bpv.base_raw_cost,
	bpv.base_burdened_cost,
	bpv.base_revenue,
	bpv.base_quantity,
	bpv.base_labor_quantity,
	bpv.unit_of_measure,
	bpv.orig_raw_cost,
	bpv.orig_burdened_cost,
	bpv.orig_revenue,
	bpv.orig_quantity,
	bpv.orig_labor_quantity
      FROM
	pa_budget_by_pa_period_v  bpv,
        gl_period_statuses glp,
        pa_implementations imp
      WHERE
		bpv.project_id = x_project_id
            AND (
	         (x_task_id IS NULL)   --- project level numbers
	         OR
	         (bpv.task_id IN
                       	(SELECT
                            	 t.task_id
                       	 FROM
                            	 pa_tasks t
                        	CONNECT BY PRIOR t.task_id = t.parent_task_id
                        	START WITH t.task_id = x_task_id
		 )
	           )
                       )
      AND x_period_type = 'G'
      AND glp.period_name = bpv.gl_period_name
      AND glp.set_of_books_id = imp.set_of_books_id
      AND glp.application_id = pa_period_process_pkg.application_id
      AND glp.adjustment_period_flag = 'N'
      AND glp.start_date BETWEEN
          NVL(x_start_date,glp.start_date) AND NVL(x_end_date,glp.end_date)
     AND bpv.budget_type_code = NVL(x_budget_type_code,bpv.budget_type_code) ;

txnbudgetrec	seltxnbudget%ROWTYPE;
is_txn_uom_unique     BOOLEAN;


--- Resource Cursor (Project-, Task- and Resource-Level Amounts)
CURSOR selresbudget(x_start_date IN DATE, x_end_date IN DATE) IS
      SELECT
	bpv.base_raw_cost,
	bpv.base_burdened_cost,
	bpv.base_revenue,
	bpv.base_quantity,
	bpv.base_labor_quantity,
	bpv.unit_of_measure,
	bpv.orig_raw_cost,
	bpv.orig_burdened_cost,
	bpv.orig_revenue,
	bpv.orig_quantity,
	bpv.orig_labor_quantity
      FROM
	pa_budget_by_pa_period_v  bpv,
        pa_periods pp
      WHERE
		bpv.project_id = x_project_id
            AND (
	         (x_task_id IS NULL)   --- project level numbers
	         OR
	         (bpv.task_id IN
                       	(SELECT
                            	 t.task_id
                       	 FROM
                            	 pa_tasks t
                        	CONNECT BY PRIOR t.task_id = t.parent_task_id
                        	START WITH t.task_id = x_task_id)
	           )
                       )
   	AND bpv.resource_list_member_id IN
		(
		  SELECT          -- 2nd level resource list members
			rlm.resource_list_member_id
		  FROM
			pa_resource_list_members rlm
		  WHERE
			rlm.parent_member_id = x_resource_list_member_id
		  UNION
		  SELECT          -- Group level Resource list member
			x_resource_list_member_id
		  FROM
			SYS.DUAL
		)
      AND x_period_type = 'P'
      AND pp.period_name = bpv.pa_period
      AND pp.start_date BETWEEN
          NVL(x_start_date,pp.start_date) AND NVL(x_end_date,pp.end_date)
      AND bpv.budget_type_code = NVL(x_budget_type_code,bpv.budget_type_code)
      UNION ALL
      SELECT
	bpv.base_raw_cost,
	bpv.base_burdened_cost,
	bpv.base_revenue,
	bpv.base_quantity,
	bpv.base_labor_quantity,
	bpv.unit_of_measure,
	bpv.orig_raw_cost,
	bpv.orig_burdened_cost,
	bpv.orig_revenue,
	bpv.orig_quantity,
	bpv.orig_labor_quantity
      FROM
	pa_budget_by_pa_period_v  bpv,
        gl_period_statuses glp,
        pa_implementations imp
      WHERE
		bpv.project_id = x_project_id
            AND (
	         (x_task_id IS NULL)   --- project level numbers
	         OR
	         (bpv.task_id IN
                       	(SELECT
                            	 t.task_id
                       	 FROM
                            	 pa_tasks t
                        	CONNECT BY PRIOR t.task_id = t.parent_task_id
                        	START WITH t.task_id = x_task_id)
	           )
                       )
   	AND bpv.resource_list_member_id IN
		(
		  SELECT          -- 2nd level resource list members
			rlm.resource_list_member_id
		  FROM
			pa_resource_list_members rlm
		  WHERE
			rlm.parent_member_id = x_resource_list_member_id
		  UNION
		  SELECT          -- Group level Resource list member
			x_resource_list_member_id
		  FROM
			SYS.DUAL
		)
      AND x_period_type = 'G'
      AND glp.period_name = bpv.gl_period_name
      AND glp.set_of_books_id = imp.set_of_books_id
      AND glp.application_id = pa_period_process_pkg.application_id
      AND glp.adjustment_period_flag = 'N'
      AND glp.start_date BETWEEN
          NVL(x_start_date,glp.start_date) AND NVL(x_end_date,glp.end_date)
      AND bpv.budget_type_code = NVL(x_budget_type_code,bpv.budget_type_code) ;

resbudgetrec	selresbudget%ROWTYPE;
is_res_uom_unique     BOOLEAN;
x_start_date      DATE;
x_end_date        DATE;


BEGIN
	x_err_code               		:= 0;
     	x_err_stage              		:= 'Getting the Project Accumulation Budgets';

	x_base_raw_cost                  	:= 0;
	x_base_burdened_cost             	:= 0;
	x_base_revenue                   	:= 0;
	x_base_quantity 			:= 0;
	x_base_labor_quantity            	:= 0;
	x_unit_of_measure 		:= NULL;
	x_orig_raw_cost                  	:= 0;
	x_orig_burdened_cost             	:= 0;
	x_orig_revenue                   	:= 0;
	x_orig_quantity                  	:= 0;
	x_orig_labor_quantity		:= 0;

        -- Get period start and end date

        get_period_date_range
	 (x_period_type,
	  x_from_period_name,
	  x_to_period_name,
          x_start_date,
          x_end_date,
          x_err_stage,
          x_err_code);

IF ( x_resource_list_member_id IS NULL ) THEN
--  Process Transaction Cursor
   x_err_stage        := 'Getting the Project Txn Accumulation Budgets';
   is_txn_uom_unique := TRUE;

   FOR txnbudgetrec  IN seltxnbudget(x_start_date, x_end_date)  LOOP

	x_base_raw_cost		:= x_base_raw_cost +
		NVL(txnbudgetrec.BASE_RAW_COST, 0);

	x_base_burdened_cost      	:= x_base_burdened_cost +
		NVL(txnbudgetrec.BASE_BURDENED_COST, 0);

	x_base_revenue                	:= x_base_revenue +
		NVL(txnbudgetrec.BASE_REVENUE, 0);

	x_base_quantity		:= x_base_quantity +
		NVL(txnbudgetrec.BASE_QUANTITY, 0);

	x_base_labor_quantity	:= x_base_labor_quantity +
		NVL(txnbudgetrec.BASE_LABOR_QUANTITY, 0);

	x_orig_raw_cost		:= x_orig_raw_cost +
		NVL(txnbudgetrec.ORIG_RAW_COST, 0);

	x_orig_burdened_cost      	:= x_orig_burdened_cost +
		NVL(txnbudgetrec.ORIG_BURDENED_COST, 0);

	x_orig_revenue                	:= x_orig_revenue +
		NVL(txnbudgetrec.ORIG_REVENUE, 0);

	x_orig_quantity		:= x_orig_quantity +
		NVL(txnbudgetrec.ORIG_QUANTITY, 0);

	x_orig_labor_quantity	:= x_orig_labor_quantity +
		NVL(txnbudgetrec.ORIG_LABOR_QUANTITY, 0);

-- Process UOM
-- We will return UOM only if all the txn has the same UOM

       IF ( is_txn_uom_unique AND txnbudgetrec.unit_of_measure IS NOT NULL) THEN
          IF ( x_unit_of_measure IS NULL ) THEN
             x_unit_of_measure := txnbudgetrec.unit_of_measure;
          ELSIF ( x_unit_of_measure <> txnbudgetrec.unit_of_measure) THEN
            is_txn_uom_unique := FALSE;
            x_unit_of_measure := NULL;
          END IF;
       END IF;


   END LOOP;

ELSE
--  Process Resource Cursor
   x_err_stage     := 'Getting the Project Res Accumulation Budgets';
   is_res_uom_unique := TRUE;

   FOR resbudgetrec  IN selresbudget(x_start_date, x_end_date) LOOP

	x_base_raw_cost		:= x_base_raw_cost +
		NVL(resbudgetrec.BASE_RAW_COST, 0);

	x_base_burdened_cost      	:= x_base_burdened_cost +
		NVL(resbudgetrec.BASE_BURDENED_COST, 0);

	x_base_revenue                	:= x_base_revenue +
		NVL(resbudgetrec.BASE_REVENUE, 0);

	x_base_quantity		:= x_base_quantity +
		NVL(resbudgetrec.BASE_QUANTITY, 0);

	x_base_labor_quantity	:= x_base_labor_quantity +
		NVL(resbudgetrec.BASE_LABOR_QUANTITY, 0);

	x_orig_raw_cost		:= x_orig_raw_cost +
		NVL(resbudgetrec.ORIG_RAW_COST, 0);

	x_orig_burdened_cost      	:= x_orig_burdened_cost +
		NVL(resbudgetrec.ORIG_BURDENED_COST, 0);

	x_orig_revenue                	:= x_orig_revenue +
		NVL(resbudgetrec.ORIG_REVENUE, 0);

	x_orig_quantity		:= x_orig_quantity +
		NVL(resbudgetrec.ORIG_QUANTITY, 0);

	x_orig_labor_quantity	:= x_orig_labor_quantity +
		NVL(resbudgetrec.ORIG_LABOR_QUANTITY, 0);

-- Process UOM
-- We will return UOM only if all the res has the same UOM

       IF ( is_res_uom_unique AND resbudgetrec.unit_of_measure IS NOT NULL) THEN
          IF ( x_unit_of_measure IS NULL ) THEN
             x_unit_of_measure := resbudgetrec.unit_of_measure;
          ELSIF ( x_unit_of_measure <> resbudgetrec.unit_of_measure) THEN
            is_res_uom_unique := FALSE;
            x_unit_of_measure := NULL;
          END IF;
       END IF;


   END LOOP;

END IF;


EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;

END get_proj_accum_budgets;


END PA_ACCUM_API;

/
