--------------------------------------------------------
--  DDL for Package Body PA_TXN_ACCUMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TXN_ACCUMS" AS
/* $Header: PATXNACB.pls 120.7.12010000.5 2010/03/05 08:26:35 jjgeorge ship $ */

   -- Initialize function


   FUNCTION initialize RETURN NUMBER IS
      x_err_code NUMBER:=0;
   BEGIN

     RETURN 0;
   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RETURN x_err_code;
   END initialize;

   FUNCTION cmt_line_id RETURN NUMBER IS
      cmt_line_id NUMBER;
   BEGIN
      SELECT
	pa_commitment_txns_s.NEXTVAL
      INTO cmt_line_id
      FROM
	SYS.DUAL;
      RETURN cmt_line_id;
    END cmt_line_id;

   -- Get accumulation configuration



PROCEDURE get_accum_configurations
                        ( x_project_id              IN NUMBER,
                          x_err_stage            IN OUT NOCOPY VARCHAR2,
                          x_err_code             IN OUT NOCOPY NUMBER)
   IS
     x_err_stack  VARCHAR2(255);
     P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/

   BEGIN
     x_err_code  :=0;
     x_err_stage := 'Getting the accumulation configuration';
     x_err_stack := '->get_accum_configurations';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('get_accum_configurations: ' || x_err_stage);
     END IF;

     -- Pass on the project_id to determine the configuration

     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'RAW_COST',
		     raw_cost_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);

     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'BURDENED_COST',
		     burdened_cost_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);
     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'QUANTITY',
		     quantity_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);
     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'LABOR_HOURS',
		     labor_hours_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);

     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'BILLABLE_RAW_COST',
		     billable_raw_cost_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);

     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'BILLABLE_BURDENED_COST',
		     billable_burdened_cost_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);

     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'BILLABLE_QUANTITY',
		     billable_quantity_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);
     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'BILLABLE_LABOR_HOURS',
		     billable_labor_hours_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);
     pa_accum_utils.get_config_option
		    (x_project_id,
		     'ACTUALS',
		     'REVENUE',
		     revenue_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);
     pa_accum_utils.get_config_option
		    (x_project_id,
		     'COMMITMENTS',
		     'CMT_RAW_COST',
		     cmt_raw_cost_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);
     pa_accum_utils.get_config_option
		    (x_project_id,
		     'COMMITMENTS',
		     'CMT_BURDENED_COST',
		     cmt_burdened_cost_flag,
		     x_err_code,
		     x_err_stage,
		     x_err_stack);

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('get_accum_configurations: ' || 'The following columns are configured for accumulation for this project:');
        pa_debug.debug('get_accum_configurations: ' || 'Raw_cost='||RAW_COST_FLAG||' Burdened_cost='||BURDENED_COST_FLAG||
		    ' Quantity='||QUANTITY_FLAG||' Labor_hours='||LABOR_HOURS_FLAG);
        pa_debug.debug('get_accum_configurations: ' || 'Billable_raw_cost='||BILLABLE_RAW_COST_FLAG||
		    ' Billable_burdened_cost='||BILLABLE_BURDENED_COST_FLAG||
		    ' Billable_quantity='||BILLABLE_QUANTITY_FLAG||
		    ' Billable_labor_hours='|| BILLABLE_LABOR_HOURS_FLAG);
        pa_debug.debug('get_accum_configurations: ' || 'Revenue='||REVENUE_FLAG||' Cmt_raw_cost'||CMT_RAW_COST_FLAG||
		    ' Cmt_burdened_cost='|| CMT_BURDENED_COST_FLAG);
     END IF;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END get_accum_configurations;


--
--   20-MAY-2003      jwhite         For r11i.PA.L Burdening Enhancements, modified the
--                                   UPDATE pa_cost_distribution_lines_all statement:
--
--                                   Code like the following:
--                                         AND cdl.line_type = 'R'
--                                   was replaced with the following:
--                                         AND ( cdl.line_type = 'R' OR cdl.line_type = 'I')

   PROCEDURE update_resource_flag
                      (x_start_project_id     IN  NUMBER,
                       x_end_project_id       IN  NUMBER,
                       x_start_pa_date        IN  DATE,
                       x_end_pa_date          IN  DATE,
                       x_err_stage            IN OUT NOCOPY VARCHAR2,
                       x_err_code             IN OUT NOCOPY NUMBER)
   IS
   tot_recs_processed   NUMBER;
   P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/
   /*Code Changes for Bug No.2984871 start */
   l_rowcount number :=0;
   /*Code Changes for Bug No.2984871 end */

   BEGIN
    x_err_code :=0;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage := 'Updating resource_accumulated_flag';
           pa_debug.debug('update_resource_flag: ' || x_err_stage);
    END IF;
    tot_recs_processed := 0;

    LOOP

       UPDATE pa_cost_distribution_lines_all SET
                          resource_accumulated_flag = 'N'
                  WHERE   project_id = x_start_project_id AND
                          (line_type = 'R' OR line_type = 'I') AND
                          resource_accumulated_flag <> 'N' AND
                          TRUNC(pa_date) BETWEEN x_start_pa_date AND x_end_pa_date AND
                          ROWNUM <= pa_proj_accum_main.x_commit_size;
	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */
       COMMIT;
       /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
       tot_recs_processed := tot_recs_processed + l_rowcount;

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          pa_debug.debug('update_resource_flag: ' || 'Number of Records Commited cumulatively = '|| TO_CHAR(tot_recs_processed));
       END IF;
       /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
       IF (l_rowcount < pa_proj_accum_main.x_commit_size) THEN
          EXIT;
       END IF;
    END LOOP;

    LOOP
       UPDATE pa_draft_revenues SET
                          resource_accumulated_flag = 'S'
                  WHERE   project_id = x_start_project_id AND
                          released_date IS NOT NULL AND
                          resource_accumulated_flag <> 'S' AND
                          TRUNC(pa_date) BETWEEN x_start_pa_date AND x_end_pa_date AND
                          ROWNUM <= pa_proj_accum_main.x_commit_size;
	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */
       COMMIT;
       /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
       tot_recs_processed := tot_recs_processed + l_rowcount;

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          pa_debug.debug('update_resource_flag: ' || 'Number of Records Commited cumulatively = '|| TO_CHAR(tot_recs_processed));
       END IF;
       /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
       IF (l_rowcount < pa_proj_accum_main.x_commit_size) THEN
            EXIT;
       END IF;
    END LOOP;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;

   END update_resource_flag;

   -- Procedure for refreshing transaction accum

   PROCEDURE refresh_txn_accum
			( x_start_project_id        IN  NUMBER,
	    x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_transaction_type        IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)
     IS
	P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/


   BEGIN
    x_err_code :=0;

    -- Call the appropriate procedure depending on the value of
    -- x_transaction_type. If it is = 'C' then only actual
    -- cost accumulation need to be refreshed. If it is 'R' then
    -- Revenue accumulation figures need to be refreshed. If
    -- it is 'C' then commitment accumulation figures need to be refreshed.
    -- If it is not specified then all the accumulation figures need
    -- to be refreshed
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage := 'Refreshing transaction accum';
     pa_debug.debug('refresh_txn_accum: ' || x_err_stage);
    END IF;

    IF ( x_transaction_type = 'C' ) THEN
      -- Refresh actual cost accumulation Figures
      refresh_act_txn_accum
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_system_linkage_function,
			  x_err_stage,
			  x_err_code);
      delete_act_txn_accum_details
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_system_linkage_function,
			  x_err_stage,
			  x_err_code);

    ELSIF ( x_transaction_type = 'R' ) THEN
      -- Refresh revenue accumulation Figures
      refresh_rev_txn_accum
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_err_stage,
			  x_err_code);
      delete_rev_txn_accum_details
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_err_stage,
			  x_err_code);
    ELSIF ( x_transaction_type = 'M' ) THEN
      -- Refresh commitment accumulation Figures
      refresh_cmt_txn_accum
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_system_linkage_function,
			  x_err_stage,
			  x_err_code);
      delete_cmt_txn_accum_details
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_system_linkage_function,
			  x_err_stage,
			  x_err_code);
      delete_cmt_txns
		( x_start_project_id,
	   x_end_project_id,
		  x_start_pa_date,
		  x_end_pa_date,
		  x_system_linkage_function,
		  x_err_stage,
		  x_err_code);
    ELSIF ( x_transaction_type IS NULL ) THEN
      -- Refresh actual cost, revenue and commitment accumulation Figures
      -- and there drilldown keys
      refresh_act_txn_accum
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_system_linkage_function,
			  x_err_stage,
			  x_err_code);
      delete_act_txn_accum_details
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_system_linkage_function,
			  x_err_stage,
			  x_err_code);
      refresh_rev_txn_accum
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_err_stage,
			  x_err_code);
      delete_rev_txn_accum_details
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_err_stage,
			  x_err_code);
      refresh_cmt_txn_accum
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_system_linkage_function,
			  x_err_stage,
			  x_err_code);
      delete_cmt_txn_accum_details
			( x_start_project_id,
		   x_end_project_id,
			  x_start_pa_date,
			  x_end_pa_date,
			  x_system_linkage_function,
			  x_err_stage,
			  x_err_code);
      delete_cmt_txns
		( x_start_project_id,
    x_end_project_id,
		  x_start_pa_date,
		  x_end_pa_date,
		  x_system_linkage_function,
		  x_err_stage,
		  x_err_code);
    END IF;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END refresh_txn_accum;

   -- Procedure for refreshing transaction accum for actual costs
   -- This procedure will refresh the transaction accum table for
   -- actual cost. The following from pa_txn_accum table is
   -- refreshed
   --     tot_raw_cost
   --     tot_burdened_cost
   --     tot_quantity
   --     tot_labor_hours
   --     tot_billable_raw_cost
   --     tot_billable_burdened_cost
   --     tot_billable_quantity
   --     tot_billable_labor_hours
   --     i_tot_raw_cost
   --     i_tot_burdened_cost
   --     i_tot_quantity
   --     i_tot_labor_hours
   --     i_tot_billable_raw_cost
   --     i_tot_billable_burdened_cost
   --     i_tot_billable_quantity
   --     i_tot_billable_labor_hours
   --     unit_of_measure

   PROCEDURE refresh_act_txn_accum
			( x_start_project_id        IN  NUMBER,
  	  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)
   IS
   P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/


   BEGIN
    x_err_code :=0;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage := 'Refreshing Actual transaction accum';
           pa_debug.debug('refresh_act_txn_accum: ' || x_err_stage);
    END IF;

    UPDATE
        pa_txn_accum pta
    SET
        pta.tot_raw_cost                 = NULL,
        pta.tot_burdened_cost            = NULL,
        pta.tot_quantity                 = NULL,
        pta.tot_labor_hours              = NULL,
        pta.tot_billable_raw_cost        = NULL,
        pta.tot_billable_burdened_cost   = NULL,
        pta.tot_billable_quantity        = NULL,
        pta.tot_billable_labor_hours     = NULL,
        pta.i_tot_raw_cost               = NULL,
        pta.i_tot_burdened_cost          = NULL,
        pta.i_tot_quantity               = NULL,
        pta.i_tot_labor_hours            = NULL,
        pta.i_tot_billable_raw_cost      = NULL,
        pta.i_tot_billable_burdened_cost = NULL,
        pta.i_tot_billable_quantity      = NULL,
        pta.i_tot_billable_labor_hours   = NULL,
	pta.unit_of_measure              = NULL,
	pta.actual_cost_rollup_flag      = 'N',
        pta.last_updated_by              = x_last_updated_by,
        pta.last_update_date             = SYSDATE,
        pta.request_id                   = x_request_id,
        pta.program_application_id       = x_program_application_id,
        pta.program_id                   = x_program_id,
        pta.program_update_date          = SYSDATE
    WHERE
        pta.project_id = x_start_project_id -- BETWEEN x_start_project_id AND x_end_project_id - Commented for bug 3736097
    AND pta.system_linkage_function =
			       NVL(x_system_linkage_function,pta.system_linkage_function)
    AND EXISTS
	( SELECT 'Yes'
	  FROM   pa_txn_accum_details ptad
	  WHERE  pta.txn_accum_id = ptad.txn_accum_id
	  AND    ptad.line_type = 'C'
	)
    AND EXISTS
        ( SELECT 'Yes'
          FROM   pa_periods
          WHERE  period_name = pta.pa_period
          AND    start_date >= x_start_pa_date
          AND    end_date   <= x_end_pa_date
        );

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('refresh_act_txn_accum: ' || 'Records Updated = '||TO_CHAR(SQL%ROWCOUNT));
    END IF;

   COMMIT;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END refresh_act_txn_accum;

   -- Procedure for refreshing transaction accum for Revenue
   -- This procedure will refresh the transaction accum table for
   -- revenue. The following from pa_txn_accum table is
   -- refreshed
   --   tot_revenue
   --   i_tot_revenue

   PROCEDURE refresh_rev_txn_accum
			( x_start_project_id        IN  NUMBER,
  	  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)

   IS
   P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/
      BEGIN
    x_err_code :=0;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage := 'Refreshing Revenue transaction accum';
       pa_debug.debug('refresh_rev_txn_accum: ' || x_err_stage);
    END IF;

    UPDATE
        pa_txn_accum pta
    SET
        pta.tot_revenue                  = NULL,
        pta.i_tot_revenue                = NULL,
	pta.revenue_rollup_flag          = 'N',
        pta.last_updated_by              = x_last_updated_by,
        pta.last_update_date             = SYSDATE,
        pta.request_id                   = x_request_id,
        pta.program_application_id       = x_program_application_id,
        pta.program_id                   = x_program_id,
        pta.program_update_date          = SYSDATE
    WHERE
        pta.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id -- Commented for bug 3736097
    AND EXISTS
	( SELECT 'Yes'
	  FROM   pa_txn_accum_details ptad
	  WHERE  pta.txn_accum_id = ptad.txn_accum_id
	  AND    ptad.line_type IN ('R','E')
	)
    AND EXISTS
        ( SELECT 'Yes'
          FROM   pa_periods
          WHERE  period_name = pta.pa_period
          AND    start_date >= x_start_pa_date
          AND    end_date   <= x_end_pa_date
	);

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('refresh_rev_txn_accum: ' || 'Records Updated = '||TO_CHAR(SQL%ROWCOUNT));
    END IF;

   COMMIT;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END refresh_rev_txn_accum;

   -- Procedure for refreshing transaction accum for commitment costs
   -- This procedure will refresh the transaction accum table for
   -- commitment cost. The following from pa_txn_accum table is
   -- refreshed

   PROCEDURE refresh_cmt_txn_accum
			( x_start_project_id        IN  NUMBER,
  	  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)
    IS
   P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/
      BEGIN
    x_err_code :=0;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage := 'Refreshing commitments transaction accum';
      pa_debug.debug('refresh_cmt_txn_accum: ' || x_err_stage);
    END IF;

    UPDATE
        pa_txn_accum pta
    SET
        pta.tot_cmt_raw_cost             = NULL,
        pta.tot_cmt_burdened_cost        = NULL,
	pta.cmt_rollup_flag              = 'N',
        pta.last_updated_by              = x_last_updated_by,
        pta.last_update_date             = SYSDATE,
        pta.request_id                   = x_request_id,
        pta.program_application_id       = x_program_application_id,
        pta.program_id                   = x_program_id,
        pta.program_update_date          = SYSDATE
    WHERE
        pta.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id  Commented for bug 3736097
    -- System_linkage_function can be Null for commitments
    AND NVL(pta.system_linkage_function,'X') =
	       NVL(NVL(x_system_linkage_function,pta.system_linkage_function),'X')
    AND EXISTS
	( SELECT 'Yes'
	  FROM   pa_txn_accum_details ptad
	  WHERE  pta.txn_accum_id = ptad.txn_accum_id
	  AND    ptad.line_type = 'M'
	)
    AND EXISTS
        ( SELECT 'Yes'
          FROM   pa_periods
          WHERE  period_name = pta.pa_period
          AND    start_date >= x_start_pa_date
          AND    end_date   <= x_end_pa_date
        );

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('refresh_cmt_txn_accum: ' || 'Records Updated = '||TO_CHAR(SQL%ROWCOUNT));
    END IF;

   COMMIT;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END refresh_cmt_txn_accum;

   -- This procedure will update txn accumulation for re-accumulation

   PROCEDURE update_act_txn_accum
			( x_start_project_id        IN  NUMBER,
			  x_end_project_id          IN  NUMBER,
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)
IS
  P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/
     BEGIN
    x_err_code :=0;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage := 'Refreshing transaction accumulation for Reaccumulation';
       pa_debug.debug('update_act_txn_accum: ' || x_err_stage);
    END IF;

    UPDATE
        pa_txn_accum pta
    SET
        pta.i_tot_raw_cost = DECODE(raw_cost_flag,'Y',
                             (NVL(i_tot_raw_cost, 0) + NVL(tot_raw_cost,0)), NULL),
	pta.i_tot_burdened_cost = DECODE(burdened_cost_flag,'Y',
                                  (NVL(i_tot_burdened_cost, 0) + NVL(tot_burdened_cost,0)),
				  NULL),
	pta.i_tot_quantity = DECODE(quantity_flag,'Y',
                             (NVL(i_tot_quantity, 0) + NVL(tot_quantity,0)), NULL),
	pta.i_tot_labor_hours = DECODE(labor_hours_flag,'Y',
                                (NVL(i_tot_labor_hours,0) +
	                         DECODE(pta.system_linkage_function,
				 'OT', NVL(tot_quantity,0),
				 'ST', NVL(tot_quantity,0), 0)),NULL),
	pta.i_tot_billable_raw_cost = DECODE(billable_raw_cost_flag,'Y',
                                      (NVL(i_tot_billable_raw_cost, 0) +
			               NVL(tot_billable_raw_cost,0)),NULL),
	pta.i_tot_billable_burdened_cost = DECODE(billable_burdened_cost_flag,'Y',
                                           (NVL(i_tot_billable_burdened_cost, 0) +
		                            NVL(tot_billable_burdened_cost,0)),NULL),
	pta.i_tot_billable_quantity = DECODE(billable_quantity_flag,'Y',
                                      (NVL(i_tot_billable_quantity, 0) +
			               NVL(tot_billable_quantity,0)),NULL),
	pta.i_tot_billable_labor_hours = DECODE(billable_labor_hours_flag,'Y',
                                         (NVL(i_tot_billable_labor_hours,0) +
	                                   DECODE(pta.system_linkage_function,
					  'OT', NVL(tot_billable_quantity,0),
					  'ST', NVL(tot_billable_quantity,0), 0)),NULL),
        pta.i_tot_revenue = DECODE(revenue_flag,'Y',
                            (NVL(i_tot_revenue, 0) + NVL(tot_revenue,0)),NULL),
        pta.tot_raw_cost = NULL,
	pta.tot_burdened_cost = NULL,
	pta.tot_quantity = NULL,
	pta.tot_labor_hours = NULL,
	pta.tot_billable_raw_cost = NULL,
	pta.tot_billable_burdened_cost = NULL,
	pta.tot_billable_quantity = NULL,
	pta.tot_billable_labor_hours = NULL,
        pta.tot_revenue = NULL,
        pta.actual_cost_rollup_flag      = 'Y',
        pta.revenue_rollup_flag          = 'Y',
        pta.last_update_date             = SYSDATE,
	pta.last_updated_by              = x_last_updated_by,
	pta.request_Id                   = x_request_id,
	pta.program_application_id       = x_program_application_id,
	pta.program_id                   = x_program_id,
	pta.program_update_Date          = SYSDATE
    WHERE
        pta.project_id BETWEEN x_start_project_id AND x_end_project_id
    AND pta.request_id <> x_request_id
    AND EXISTS
        ( SELECT 'Yes'
          FROM   pa_txn_accum_details ptad
          WHERE  pta.txn_accum_id = ptad.txn_accum_id
          AND    ptad.line_type IN ('C','R','E')
        );

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('update_act_txn_accum: ' || 'Records Updated = '||TO_CHAR(SQL%ROWCOUNT));
    END IF;

   COMMIT;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END update_act_txn_accum;

   -- Procedure for refreshing transaction accumes details for actual costs
   -- This procedure deletes the rows from drill down table when
   -- transaction accumes are refreshed

   PROCEDURE delete_act_txn_accum_details
			( x_start_project_id        IN  NUMBER,
  	  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)
   IS
  P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/
      tot_recs_processed   NUMBER;
   /*Code Changes for Bug No.2984871 start */
   l_rowcount number :=0;
   /*Code Changes for Bug No.2984871 end */

   BEGIN
     x_err_code :=0;
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     x_err_stage := 'Deleteing Actual transaction accum details';
     tot_recs_processed := 0;
        pa_debug.debug('delete_act_txn_accum_details: ' || x_err_stage);
     END IF;

     LOOP
     DELETE pa_txn_accum_details ptad
     WHERE txn_accum_id IN
	 (SELECT txn_accum_id FROM pa_txn_accum pta
	  WHERE
          pta.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id  -- Commented for bug 3736097
          AND pta.system_linkage_function =
			       NVL(x_system_linkage_function,pta.system_linkage_function)
          AND EXISTS
              ( SELECT 'Yes'
                FROM   pa_periods
                WHERE  period_name = pta.pa_period
                AND    start_date >= x_start_pa_date
                AND    end_date   <= x_end_pa_date
              )
	 )
     AND ptad.line_type = 'C'
     AND ROWNUM <= pa_proj_accum_main.x_commit_size;
	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */
     COMMIT;
     /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
     tot_recs_processed := tot_recs_processed + l_rowcount;
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('delete_act_txn_accum_details: ' || 'Number of Records Commited cumulatively = '|| TO_CHAR(tot_recs_processed));
     END IF;
     /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
     IF l_rowcount < pa_proj_accum_main.x_commit_size THEN
        EXIT;
     END IF;
   END LOOP;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('delete_act_txn_accum_details: ' || 'Records Deleted = '||TO_CHAR(tot_recs_processed));
     END IF;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END delete_act_txn_accum_details;


   -- Procedure for refreshing transaction accumes details for revenue
   -- This procedure deletes the rows from drill down table when
   -- transaction accumes are refreshed

   PROCEDURE delete_rev_txn_accum_details
			( x_start_project_id        IN  NUMBER,
  	  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)
    IS
P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/
      tot_recs_processed   NUMBER;
   /*Code Changes for Bug No.2984871 start */
   l_rowcount number :=0;
   /*Code Changes for Bug No.2984871 end */

   BEGIN
     x_err_code :=0;
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     x_err_stage := 'Deleteing Revenue transaction accum details';
     tot_recs_processed := 0;
        pa_debug.debug('delete_rev_txn_accum_details: ' || x_err_stage);
     END IF;

     LOOP
     DELETE pa_txn_accum_details ptad
     WHERE txn_accum_id IN
	 (SELECT txn_accum_id FROM pa_txn_accum pta
	  WHERE
          pta.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id  Commented for bug 3736097
          AND EXISTS
              ( SELECT 'Yes'
                FROM   pa_periods
                WHERE  period_name = pta.pa_period
                AND    start_date >= x_start_pa_date
                AND    end_date   <= x_end_pa_date
              )
	 )
     AND ptad.line_type IN ('R','E')
     AND ROWNUM <= pa_proj_accum_main.x_commit_size;
	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */

     COMMIT;
     /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
     tot_recs_processed := tot_recs_processed + l_rowcount;
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('delete_rev_txn_accum_details: ' || 'Number of Records Commited cumulatively = '|| TO_CHAR(tot_recs_processed));
     END IF;
     /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
     IF (l_rowcount < pa_proj_accum_main.x_commit_size) THEN
         EXIT;
     END IF;
     END LOOP;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('delete_rev_txn_accum_details: ' || 'Records Deleted = '||TO_CHAR(tot_recs_processed));
     END IF;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END delete_rev_txn_accum_details;

   -- Procedure for refreshing transaction accumes details for commitments
   -- This procedure deletes the rows from drill down table when
   -- transaction accumes are refreshed

   PROCEDURE delete_cmt_txn_accum_details
			( x_start_project_id        IN  NUMBER,
  	  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)
   IS
P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/
   /*Code Changes for Bug No.2984871 start */
   l_rowcount number :=0;
   /*Code Changes for Bug No.2984871 end */


   tot_recs_processed   NUMBER;
   BEGIN
     x_err_code :=0;
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     x_err_stage := 'Deleteing commitments transaction accum details';
     tot_recs_processed := 0;
        pa_debug.debug('delete_cmt_txn_accum_details: ' || x_err_stage);
     END IF;

     LOOP
     DELETE pa_txn_accum_details ptad
     WHERE txn_accum_id IN
	 (SELECT txn_accum_id FROM pa_txn_accum pta
	  WHERE
          pta.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id  Commented out for bug 3736097
          AND NVL(pta.system_linkage_function,'X') =
			       NVL(NVL(x_system_linkage_function,pta.system_linkage_function),'X')
          AND EXISTS
              ( SELECT 'Yes'
                FROM   pa_periods
                WHERE  period_name = pta.pa_period
                AND    start_date >= x_start_pa_date
                AND    end_date   <= x_end_pa_date
              )
	 )
     AND ptad.line_type = 'M'
     AND ROWNUM <= pa_proj_accum_main.x_commit_size;
	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */
     COMMIT;
     /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
     tot_recs_processed := tot_recs_processed + l_rowcount;
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('delete_cmt_txn_accum_details: ' || 'Number of Records Commited cumulatively = '|| TO_CHAR(tot_recs_processed));
     END IF;
     /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
     IF l_rowcount < pa_proj_accum_main.x_commit_size THEN
          EXIT;
     END IF;
     END LOOP;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('delete_cmt_txn_accum_details: ' || 'Records Deleted = '||TO_CHAR(tot_recs_processed));
     END IF;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END delete_cmt_txn_accum_details;

  -- Procedure for creating transaction accum Details

  PROCEDURE create_txn_accum_details
			 (x_txn_accum_id          IN  NUMBER,
			  x_line_type             IN  VARCHAR2,
			  x_expenditure_item_id   IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_line_num              IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_event_num             IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_cmt_line_id           IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_project_id            IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_task_id               IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage          IN OUT NOCOPY VARCHAR2,
			  x_err_code           IN OUT NOCOPY NUMBER)
  IS
  BEGIN
     x_err_code :=0;
     x_err_stage := 'Creating transaction accum details';

     INSERT INTO pa_txn_accum_details
	  (txn_accum_id,
	   line_type,
	   expenditure_item_id,
	   line_num,
	   event_num,
	   cmt_line_id,
	   project_id,
	   task_id,
           creation_date,
           created_by,
	   last_updated_by,
	   last_update_date,
	   last_update_login,
           request_id,
           program_application_id,
           program_id)
     VALUES
	  (x_txn_accum_id,
	   x_line_type,
	   x_expenditure_item_id,
	   x_line_num,
	   x_event_num,
	   x_cmt_line_id,
	   x_project_id,
	   x_task_id,
           SYSDATE,
           x_created_by,
	   x_last_updated_by,
	   SYSDATE,
	   x_last_update_login,
           x_request_id,
           x_program_application_id,
           x_program_id);

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;

  END create_txn_accum_details;

  -- This procedure checks if a combinations of given column
  -- Exit in the PA_TXN_ACCUM table
  -- x_line_type represent the type fo line
  -- i.e. 'C' for CDL, 'R' for revenue and 'M' for commitments
  -- If combination does not exist it will create the row
  -- and returns the primary key TXN_ACCUM_ID and Status

  PROCEDURE create_txn_accum
		       ( x_project_id                IN  NUMBER,
		         x_task_Id                   IN  NUMBER,
		         x_pa_period                 IN  VARCHAR2,
		         x_gl_period                 IN  VARCHAR2,
		         x_week_ending_date          IN  DATE,
		         x_month_ending_date         IN  DATE,
		         x_person_id                 IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_job_id                    IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_vendor_id                 IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_expenditure_type          IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_organization_id           IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_non_labor_resource        IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			        x_non_labor_resource_org_id IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_expenditure_category      IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_revenue_category          IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_event_type                IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
		         x_event_type_classification IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
       			 x_system_linkage_function   IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			        x_line_type                 IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			        x_cost_ind_compiled_set_id  IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			        x_rev_ind_compiled_set_id   IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			        x_inv_ind_compiled_set_id   IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			        x_cmt_ind_compiled_set_id   IN  NUMBER, -- Default value removed to avoid GSCC warning File.Pkg.22
			        x_txn_accum_id           IN OUT NOCOPY NUMBER,
			        x_err_stage              IN OUT NOCOPY VARCHAR2,
			        x_err_code               IN OUT NOCOPY NUMBER)
  IS
  is_row_found     NUMBER;
  BEGIN

       is_row_found := 1;            /* Assume a row exist in pa_txn_accum */
       x_err_code   := 0;
       x_err_stage  := 'Creating transaction accums';

       <<get_txn_accum_id>>
       BEGIN

         -- Seperating Expenditure Items/Events Processing
         IF ( x_expenditure_type IS NOT NULL ) THEN

            -- Seperating processing where person_id is null/not null
            -- to take advantage of index on person_id
            IF ( x_person_id IS NOT NULL ) THEN
               -- person_id is not null
               SELECT /*+ index(pta PA_TXN_ACCUM_N2)*/ txn_accum_id   -- Added hint for bug 4504019
               INTO   x_txn_accum_id
               FROM   pa_txn_accum pta
               WHERE  x_project_id = pta.project_id
	       AND    x_task_Id    = pta.task_id
	       AND    x_pa_period  = pta.pa_period
	       AND    x_gl_period  = pta.gl_period
	       AND    x_week_ending_date  = pta.week_ending_date
	       AND    x_month_ending_date = pta.month_ending_date
	       AND    x_expenditure_type  = pta.expenditure_type
	       AND    x_organization_id   = pta.organization_id
	       AND    x_person_id = pta.person_id
	       AND    NVL(x_job_id,-1)    = NVL(pta.job_id,-1)
	       AND    NVL(x_vendor_id,-1) = NVL(pta.vendor_id,-1)
	       AND    NVL(x_non_labor_resource,'X') = NVL(pta.non_labor_resource,'X')
	       AND    NVL(x_non_labor_resource_org_id,-1)
					       = NVL(pta.non_labor_resource_org_id,-1)
	       AND    NVL(x_expenditure_category,'X')= NVL(pta.expenditure_category,'X')
	       AND    NVL(x_revenue_category,'X')    = NVL(pta.revenue_category,'X')
	       AND    NVL(x_system_linkage_function,'X')
					       = NVL(pta.system_linkage_function,'X')
  	       AND    DECODE(x_line_type,'C',(NVL(x_cost_ind_compiled_set_id,-1)),-1)
  					       = NVL(pta.cost_ind_compiled_set_id,-1)
  	       AND    DECODE(x_line_type,'R',(NVL(x_rev_ind_compiled_set_id,-1)),-1)
  					       = NVL(pta.rev_ind_compiled_set_id,-1)
  	       AND    DECODE(x_line_type,'R',(NVL(x_inv_ind_compiled_set_id,-1)),-1)
  					       = NVL(pta.inv_ind_compiled_set_id,-1)
  	       AND    DECODE(x_line_type,'M',(NVL(x_cmt_ind_compiled_set_id,-1)),-1)
  					       = NVL(pta.cmt_ind_compiled_set_id,-1);
            ELSE
               -- When person_id is not available
               SELECT txn_accum_id
               INTO   x_txn_accum_id
               FROM   pa_txn_accum pta
               WHERE  x_project_id = pta.project_id
	       AND    x_task_Id    = pta.task_id
	       AND    x_pa_period  = pta.pa_period
	       AND    x_gl_period  = pta.gl_period
	       AND    x_week_ending_date  = pta.week_ending_date
	       AND    x_month_ending_date = pta.month_ending_date
	       AND    x_expenditure_type  = pta.expenditure_type
	       AND    x_organization_id   = pta.organization_id
	       AND    pta.person_id IS NULL
	       AND    NVL(x_job_id,-1)    = NVL(pta.job_id,-1)
	       AND    NVL(x_vendor_id,-1) = NVL(pta.vendor_id,-1)
	       AND    NVL(x_non_labor_resource,'X') = NVL(pta.non_labor_resource,'X')
	       AND    NVL(x_non_labor_resource_org_id,-1)
					       = NVL(pta.non_labor_resource_org_id,-1)
	       AND    NVL(x_expenditure_category,'X')= NVL(pta.expenditure_category,'X')
	       AND    NVL(x_revenue_category,'X')    = NVL(pta.revenue_category,'X')
	       AND    NVL(x_system_linkage_function,'X')
					       = NVL(pta.system_linkage_function,'X')
  	       AND    DECODE(x_line_type,'C',(NVL(x_cost_ind_compiled_set_id,-1)),-1)
  					       = NVL(pta.cost_ind_compiled_set_id,-1)
  	       AND    DECODE(x_line_type,'R',(NVL(x_rev_ind_compiled_set_id,-1)),-1)
  					       = NVL(pta.rev_ind_compiled_set_id,-1)
  	       AND    DECODE(x_line_type,'R',(NVL(x_inv_ind_compiled_set_id,-1)),-1)
  					       = NVL(pta.inv_ind_compiled_set_id,-1)
  	       AND    DECODE(x_line_type,'M',(NVL(x_cmt_ind_compiled_set_id,-1)),-1)
  					       = NVL(pta.cmt_ind_compiled_set_id,-1);
            END IF; -- IF ( x_person_id IS NOT NULL )
         ELSE
            /* Process Event Here */
            SELECT txn_accum_id
            INTO   x_txn_accum_id
            FROM   pa_txn_accum pta
            WHERE  x_project_id = pta.project_id
	    AND    x_task_Id    = pta.task_id
	    AND    x_pa_period  = pta.pa_period
	    AND    x_gl_period  = pta.gl_period
	    AND    x_week_ending_date  = pta.week_ending_date
	    AND    x_month_ending_date = pta.month_ending_date
	    AND    x_event_type = pta.event_type
	    AND    x_event_type_classification = pta.event_type_classification
	    AND    x_organization_id   = pta.organization_id
	    AND    x_revenue_category  = pta.revenue_category;
         END IF; -- IF ( x_expenditure_type IS NOT NULL )

       EXCEPTION
	 WHEN  NO_DATA_FOUND THEN
	   is_row_found := 0;
         WHEN  OTHERS  THEN
	   x_err_code := SQLCODE;
           RAISE;
       END get_txn_accum_id;

       IF ( is_row_found = 0 ) THEN
       --- Could not find a row, for the given transaction attributes
       BEGIN

         SELECT pa_txn_accum_s.NEXTVAL
	 INTO   x_txn_accum_Id
	 FROM   SYS.DUAL;

         -- Insert a row in PA_TXN_ACCUM now

         INSERT INTO PA_TXN_ACCUM (
	      txn_accum_id,
              project_id,
	      task_Id,
	      pa_period,
	      gl_period,
	      week_ending_date,
	      month_ending_date,
	      person_id,
	      job_id,
	      vendor_id,
	      expenditure_type,
	      organization_id,
	      non_labor_resource,
	      non_labor_resource_org_id,
	      expenditure_category,
	      revenue_category,
	      event_type,
	      event_type_classification,
	      system_linkage_function,
	      cost_ind_compiled_set_id,
	      rev_ind_compiled_set_id,
	      inv_ind_compiled_set_id,
	      cmt_ind_compiled_set_id,
	      actual_cost_rollup_flag,
	      revenue_rollup_flag,
	      cmt_rollup_flag,
              creation_date,
              created_by,
	      last_updated_by,
	      last_update_date,
	      last_update_login,
              request_id,
              program_application_id,
              program_id
	 )
	 VALUES (
	      x_txn_accum_id,
              x_project_id,
	      x_task_Id,
	      x_pa_period,
	      x_gl_period,
	      x_week_ending_date,
	      x_month_ending_date,
	      x_person_id,
	      x_job_id,
	      x_vendor_id,
	      x_expenditure_type,
	      x_organization_id,
	      x_non_labor_resource,
	      x_non_labor_resource_org_id,
	      x_expenditure_category,
	      x_revenue_category,
	      x_event_type,
	      x_event_type_classification,
	      x_system_linkage_function,
	      x_cost_ind_compiled_set_id,
	      x_rev_ind_compiled_set_id,
	      x_inv_ind_compiled_set_id,
	      x_cmt_ind_compiled_set_id,
	      'N',
	      'N',
	      'N',
              SYSDATE,
              x_created_by,
	      x_last_updated_by,
	      SYSDATE,
	      x_last_update_login,
              x_request_id,
              x_program_application_id,
              x_program_id
	 );

       EXCEPTION
         WHEN  OTHERS  THEN
	   x_err_code := SQLCODE;
           RAISE;
       END;
       END IF;
    EXCEPTION
      WHEN  OTHERS  THEN
         x_err_code := SQLCODE;
         RAISE;
  END create_txn_accum;

   -- This procedure deletes the pa_commitment_txns which were refreshed

   PROCEDURE delete_cmt_txns
			( x_start_project_id        IN  NUMBER,
  	  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER)

IS
P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/

   tot_recs_processed    NUMBER;
   /*Code Changes for Bug No.2984871 start */
   l_rowcount number :=0;
   /*Code Changes for Bug No.2984871 end */

   BEGIN
    x_err_code :=0;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage := 'Deleting commitments transaction';
    tot_recs_processed := 0;
       pa_debug.debug('delete_cmt_txns: ' || x_err_stage);
    END IF;


    LOOP
    DELETE
        pa_commitment_txns pct
    WHERE
        pct.project_id = x_start_project_id -- BETWEEN x_start_project_id AND x_end_project_id -- Commented out for bug 3736097
    -- System_linkage_function can be Null for commitments
    AND NVL(pct.system_linkage_function,'X') =
	       NVL(NVL(x_system_linkage_function,pct.system_linkage_function),'X')
    AND EXISTS
        ( SELECT 'Yes'
          FROM   pa_periods
          WHERE  period_name = pct.pa_period
          AND    start_date >= x_start_pa_date
          AND    end_date   <= x_end_pa_date
        )
    AND ROWNUM <= pa_proj_accum_main.x_commit_size;
   	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */

    COMMIT;
    /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
    tot_recs_processed := tot_recs_processed + l_rowcount;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('delete_cmt_txns: ' || 'Number of Records Commited cumulatively = '|| TO_CHAR(tot_recs_processed));
    END IF;
    /*Bug 2984871:Replaced sql%rowcount with l_rowcount */
    IF l_rowcount < pa_proj_accum_main.x_commit_size THEN
       EXIT;
    END IF;
    END LOOP;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('delete_cmt_txns: ' || 'Records Deleted = '||TO_CHAR(tot_recs_processed));
    END IF;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END delete_cmt_txns;

  -- This procedure creates the commitment txns into pa_commitment_txns
  -- from the view pa_commitment_txns_v

--
-- Name:		Create_Cmt_Txns
--
-- History
--
--    04-MAR-99	 jwhite       Implemented lastest MC related design:
--				1) create_cmt_txns
--				   a. removed the rounding_limit column.
--				   b. specified NULL for cmt_rejection_code.
--				   c. specified 'N' for new generation_error_flag.
--				   d. removed denom and acct amount_delivered columns
--
--
--    30-MAY-03  jwhite        As per design for Initial Grants Managment Integration
--                             for summarization commitment processing, modified
--                             the create_cmt_txns to conditionally insert
--                             commitment rows from a GMS object.
--


  PROCEDURE create_cmt_txns
			( x_start_project_id        IN  NUMBER,
  	  x_end_project_id          IN  NUMBER,
			  x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
			  x_err_code             IN OUT NOCOPY NUMBER,
                          x_use_tmp_table           IN  VARCHAR2 DEFAULT 'N' /*Added for bug 5635857*/)
   IS

P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/

  l_cur_pa_period varchar2(20); /* Added for commitment change request */
  l_cur_gl_period varchar2(15); /* Added for commitment change request */

  BEGIN

     x_err_code :=0;

    -- Grants Management Integrated Commitment Processing  ---------------------
    -- added 30-MAY-2003, jwhite


   /*Commented for bug 4094814 IF ( PA_PROJ_ACCUM_MAIN.G_GMS_Enabled = 'Y' ) and added below if*/

   IF ( pa_gms_api.is_sponsored_project(x_start_project_id) )
     THEN

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       x_err_stage := 'Creating commitment txns from Grants Management Source';
       pa_debug.debug('create_cmt_txns: ' || x_err_stage);
     END IF;

       -- Insert Commitments from GMS Source
       GMS_PA_API3.create_cmt_txns
  		           (p_start_project_id          => x_start_project_id
                            , p_end_project_id          => x_end_project_id
                            , p_system_linkage_function => x_system_linkage_function
                            )  ;

     commit;

   ELSE

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       x_err_stage := 'Creating commitment txns from PA_COMMITMENT_TXNS_V Source';
       pa_debug.debug('create_cmt_txns: ' || x_err_stage);
     END IF;

     -- Insert Commitments from the Oracle Projects User-Defined PA_COMMITMENT_TXNS_V
     -- View.

      if (x_start_project_id is not null) then -- refresh cmts for single prj

     /* Added for commitment change request */

        -- l_cur_pa_period := pa_accum_utils.Get_current_pa_period;
        -- l_cur_gl_period := pa_accum_utils.Get_current_gl_period;

        -- bug 3746527
        select
          per.PERIOD_NAME,
          per.GL_PERIOD_NAME
        into
          l_cur_pa_period,
          l_cur_gl_period
        from
          PA_PROJECTS_ALL prj,
          PA_PERIODS_ALL per
        where
          prj.PROJECT_ID = x_start_project_id and
          nvl(per.ORG_ID, -1) = nvl(prj.ORG_ID, -1) and
          per.CURRENT_PA_PERIOD_FLAG = 'Y';

     /* End of commitment change request*/
         IF x_use_tmp_table='N' THEN /*Added for bug 5635857*/

     INSERT INTO pa_commitment_txns
       ( CMT_LINE_ID,
         PROJECT_ID,
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
              TOT_CMT_RAW_COST,
              TOT_CMT_BURDENED_COST,
         TOT_CMT_QUANTITY,
         QUANTITY_ORDERED,
         AMOUNT_ORDERED,
         ORIGINAL_QUANTITY_ORDERED,
         ORIGINAL_AMOUNT_ORDERED,
         QUANTITY_CANCELLED,
         AMOUNT_CANCELLED,
         QUANTITY_DELIVERED,
              AMOUNT_DELIVERED,
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
         BURDEN_SUM_SOURCE_RUN_ID,
         BURDEN_SUM_DEST_RUN_ID,
         BURDEN_SUM_REJECTION_CODE,
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
              project_currency_code,
              project_rate_date,
              project_rate_type,
              project_exchange_rate,
              generation_error_flag,
	      cmt_rejection_code,
	/* added in FP.M */
	      INVENTORY_ITEM_ID,
              UOM_CODE,
              BOM_LABOR_RESOURCE_ID,
              BOM_EQUIPMENT_RESOURCE_ID,
              RESOURCE_CLASS
     )
     SELECT
         pa_txn_accums.cmt_line_id,
         pctv.project_id,
         pctv.task_id,
         pctv.transaction_source,
         decode(pctv.line_type,'P','P','R','R','I','I','O'),/*Bug 4050269*/
         pctv.cmt_number,
         pctv.cmt_distribution_id,
         pctv.cmt_header_id,
         pctv.description,
         pctv.expenditure_item_date,
/* For commitment change request
         pctv.pa_period,
         pctv.gl_period, and added below variables*/
         l_cur_pa_period, /* Added for commitment change request*/
         l_cur_gl_period, /* Added for commitment change request*/
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
            TO_NUMBER(NULL),
            TO_NUMBER(NULL),
         pctv.tot_cmt_quantity,
         pctv.quantity_ordered,
         pctv.amount_ordered,
         pctv.original_quantity_ordered,
         pctv.original_amount_ordered,
         pctv.quantity_cancelled,
         pctv.amount_cancelled,
         pctv.quantity_delivered,
           TO_NUMBER(NULL),
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
         -9999,
         NULL,
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
 	      NULL,
 	      TO_DATE(NULL),
	      NULL,
	      TO_NUMBER(NULL),
              'N',
	      NULL,
	/* added in FP.M */
              pctv.INVENTORY_ITEM_ID,
	      pctv.UOM_CODE,
              pctv.wip_resource_id,
              pctv.wip_resource_id,
              pctv.resource_class
      FROM
	 pa_commitment_txns_v pctv
      WHERE
	 pctv.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id commented for bug 3736097
      AND NVL(pctv.system_linkage_function,'X') =
	       NVL(NVL(x_system_linkage_function,pctv.system_linkage_function),'X');

     ELSIF x_use_tmp_table='Y' THEN  /*Start of addition for bug 5635857*/
     INSERT INTO pa_commitment_txns
       ( CMT_LINE_ID,
         PROJECT_ID,
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
              TOT_CMT_RAW_COST,
              TOT_CMT_BURDENED_COST,
         TOT_CMT_QUANTITY,
         QUANTITY_ORDERED,
         AMOUNT_ORDERED,
         ORIGINAL_QUANTITY_ORDERED,
         ORIGINAL_AMOUNT_ORDERED,
         QUANTITY_CANCELLED,
         AMOUNT_CANCELLED,
         QUANTITY_DELIVERED,
              AMOUNT_DELIVERED,
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
         BURDEN_SUM_SOURCE_RUN_ID,
         BURDEN_SUM_DEST_RUN_ID,
         BURDEN_SUM_REJECTION_CODE,
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
              project_currency_code,
              project_rate_date,
              project_rate_type,
              project_exchange_rate,
              generation_error_flag,
	      cmt_rejection_code,
	/* added in FP.M */
	      INVENTORY_ITEM_ID,
              UOM_CODE,
              BOM_LABOR_RESOURCE_ID,
              BOM_EQUIPMENT_RESOURCE_ID,
              RESOURCE_CLASS
     )
     SELECT
         pa_txn_accums.cmt_line_id,
         pctv.project_id,
         pctv.task_id,
         pctv.transaction_source,
         pctv.line_type,/*Bug 4050269*/
         pctv.cmt_number,
         pctv.cmt_distribution_id,
         pctv.cmt_header_id,
         pctv.description,
         pctv.expenditure_item_date,
/* For commitment change request
         pctv.pa_period,
         pctv.gl_period, and added below variables*/
         l_cur_pa_period, /* Added for commitment change request*/
         l_cur_gl_period, /* Added for commitment change request*/
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
            TO_NUMBER(NULL),
            TO_NUMBER(NULL),
         pctv.tot_cmt_quantity,
         pctv.quantity_ordered,
         pctv.amount_ordered,
         pctv.original_quantity_ordered,
         pctv.original_amount_ordered,
         pctv.quantity_cancelled,
         pctv.amount_cancelled,
         pctv.quantity_delivered,
           TO_NUMBER(NULL),
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
         -9999,
         NULL,
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
 	      NULL,
 	      TO_DATE(NULL),
	      NULL,
	      TO_NUMBER(NULL),
              'N',
	      NULL,
	/* added in FP.M */
              pctv.INVENTORY_ITEM_ID,
	      pctv.UOM_CODE,
              pctv.wip_resource_id,
              pctv.wip_resource_id,
              pctv.resource_class
      FROM
         pa_commitment_txns_tmp pctv
          WHERE
         pctv.project_id = x_start_project_id ;

end if;  /* End of Addition for bug 5635857*/

        commit;

      else -- refresh commitments for all projects

        declare

          l_helper_batch_id number;

          l_x               number;
          l_project_id_1    number := null;
          l_project_id_2    number := null;
          l_project_id_3    number := null;
          l_project_id_4    number := null;
          l_project_id_5    number := null;
          l_project_id_6    number := null;
          l_project_id_7    number := null;
          l_project_id_8    number := null;
          l_project_id_9    number := null;
          l_project_id_10   number := null;
          l_project_id_11   number := null;
          l_project_id_12   number := null;
          l_project_id_13   number := null;
          l_project_id_14   number := null;
          l_project_id_15   number := null;
          l_project_id_16   number := null;
          l_project_id_17   number := null;
          l_project_id_18   number := null;
          l_project_id_19   number := null;
          l_project_id_20   number := null;

          l_pa_period_1     varchar2(15) := null;
          l_pa_period_2     varchar2(15) := null;
          l_pa_period_3     varchar2(15) := null;
          l_pa_period_4     varchar2(15) := null;
          l_pa_period_5     varchar2(15) := null;
          l_pa_period_6     varchar2(15) := null;
          l_pa_period_7     varchar2(15) := null;
          l_pa_period_8     varchar2(15) := null;
          l_pa_period_9     varchar2(15) := null;
          l_pa_period_10    varchar2(15) := null;
          l_pa_period_11    varchar2(15) := null;
          l_pa_period_12    varchar2(15) := null;
          l_pa_period_13    varchar2(15) := null;
          l_pa_period_14    varchar2(15) := null;
          l_pa_period_15    varchar2(15) := null;
          l_pa_period_16    varchar2(15) := null;
          l_pa_period_17    varchar2(15) := null;
          l_pa_period_18    varchar2(15) := null;
          l_pa_period_19    varchar2(15) := null;
          l_pa_period_20    varchar2(15) := null;

          l_gl_period_1     varchar2(15) := null;
          l_gl_period_2     varchar2(15) := null;
          l_gl_period_3     varchar2(15) := null;
          l_gl_period_4     varchar2(15) := null;
          l_gl_period_5     varchar2(15) := null;
          l_gl_period_6     varchar2(15) := null;
          l_gl_period_7     varchar2(15) := null;
          l_gl_period_8     varchar2(15) := null;
          l_gl_period_9     varchar2(15) := null;
          l_gl_period_10    varchar2(15) := null;
          l_gl_period_11    varchar2(15) := null;
          l_gl_period_12    varchar2(15) := null;
          l_gl_period_13    varchar2(15) := null;
          l_gl_period_14    varchar2(15) := null;
          l_gl_period_15    varchar2(15) := null;
          l_gl_period_16    varchar2(15) := null;
          l_gl_period_17    varchar2(15) := null;
          l_gl_period_18    varchar2(15) := null;
          l_gl_period_19    varchar2(15) := null;
          l_gl_period_20    varchar2(15) := null;

        begin

          l_helper_batch_id := x_end_project_id; -- overload of to_proj param

          l_x := 1;

          for c in (select PROJECT_ID,
                           PA_PERIOD_NAME,
                           GL_PERIOD_NAME
                    from   PJI_FM_EXTR_DREVN -- overload of drev table for cmt
                    where  BATCH_ID = l_helper_batch_id) loop

            if (l_x = 1) then
              l_project_id_1 := c.PROJECT_ID;
              l_pa_period_1  := c.PA_PERIOD_NAME;
              l_gl_period_1  := c.GL_PERIOD_NAME;
            elsif (l_x = 2) then
              l_project_id_2 := c.PROJECT_ID;
              l_pa_period_2  := c.PA_PERIOD_NAME;
              l_gl_period_2  := c.GL_PERIOD_NAME;
            elsif (l_x = 3) then
              l_project_id_3 := c.PROJECT_ID;
              l_pa_period_3  := c.PA_PERIOD_NAME;
              l_gl_period_3  := c.GL_PERIOD_NAME;
            elsif (l_x = 4) then
              l_project_id_4 := c.PROJECT_ID;
              l_pa_period_4  := c.PA_PERIOD_NAME;
              l_gl_period_4  := c.GL_PERIOD_NAME;
            elsif (l_x = 5) then
              l_project_id_5 := c.PROJECT_ID;
              l_pa_period_5  := c.PA_PERIOD_NAME;
              l_gl_period_5  := c.GL_PERIOD_NAME;
            elsif (l_x = 6) then
              l_project_id_6 := c.PROJECT_ID;
              l_pa_period_6  := c.PA_PERIOD_NAME;
              l_gl_period_6  := c.GL_PERIOD_NAME;
            elsif (l_x = 7) then
              l_project_id_7 := c.PROJECT_ID;
              l_pa_period_7  := c.PA_PERIOD_NAME;
              l_gl_period_7  := c.GL_PERIOD_NAME;
            elsif (l_x = 8) then
              l_project_id_8 := c.PROJECT_ID;
              l_pa_period_8  := c.PA_PERIOD_NAME;
              l_gl_period_8  := c.GL_PERIOD_NAME;
            elsif (l_x = 9) then
              l_project_id_9 := c.PROJECT_ID;
              l_pa_period_9  := c.PA_PERIOD_NAME;
              l_gl_period_9  := c.GL_PERIOD_NAME;
            elsif (l_x = 10) then
              l_project_id_10 := c.PROJECT_ID;
              l_pa_period_10  := c.PA_PERIOD_NAME;
              l_gl_period_10  := c.GL_PERIOD_NAME;
            elsif (l_x = 11) then
              l_project_id_11 := c.PROJECT_ID;
              l_pa_period_11  := c.PA_PERIOD_NAME;
              l_gl_period_11  := c.GL_PERIOD_NAME;
            elsif (l_x = 12) then
              l_project_id_12 := c.PROJECT_ID;
              l_pa_period_12  := c.PA_PERIOD_NAME;
              l_gl_period_12  := c.GL_PERIOD_NAME;
            elsif (l_x = 13) then
              l_project_id_13 := c.PROJECT_ID;
              l_pa_period_13  := c.PA_PERIOD_NAME;
              l_gl_period_13  := c.GL_PERIOD_NAME;
            elsif (l_x = 14) then
              l_project_id_14 := c.PROJECT_ID;
              l_pa_period_14  := c.PA_PERIOD_NAME;
              l_gl_period_14  := c.GL_PERIOD_NAME;
            elsif (l_x = 15) then
              l_project_id_15 := c.PROJECT_ID;
              l_pa_period_15  := c.PA_PERIOD_NAME;
              l_gl_period_15  := c.GL_PERIOD_NAME;
            elsif (l_x = 16) then
              l_project_id_16 := c.PROJECT_ID;
              l_pa_period_16  := c.PA_PERIOD_NAME;
              l_gl_period_16  := c.GL_PERIOD_NAME;
            elsif (l_x = 17) then
              l_project_id_17 := c.PROJECT_ID;
              l_pa_period_17  := c.PA_PERIOD_NAME;
              l_gl_period_17  := c.GL_PERIOD_NAME;
            elsif (l_x = 18) then
              l_project_id_18 := c.PROJECT_ID;
              l_pa_period_18  := c.PA_PERIOD_NAME;
              l_gl_period_18  := c.GL_PERIOD_NAME;
            elsif (l_x = 19) then
              l_project_id_19 := c.PROJECT_ID;
              l_pa_period_19  := c.PA_PERIOD_NAME;
              l_gl_period_19  := c.GL_PERIOD_NAME;
            elsif (l_x = 20) then
              l_project_id_20 := c.PROJECT_ID;
              l_pa_period_20  := c.PA_PERIOD_NAME;
              l_gl_period_20  := c.GL_PERIOD_NAME;
            else
              dbms_standard.raise_application_error(-20010, 'batch too large');
            end if;

            l_x := l_x + 1;

          end loop;

     IF x_use_tmp_table='N' THEN /*Added for bug 5635857*/

          insert into PA_COMMITMENT_TXNS
          (
            CMT_LINE_ID,
            PROJECT_ID,
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
            TOT_CMT_RAW_COST,
            TOT_CMT_BURDENED_COST,
            TOT_CMT_QUANTITY,
            QUANTITY_ORDERED,
            AMOUNT_ORDERED,
            ORIGINAL_QUANTITY_ORDERED,
            ORIGINAL_AMOUNT_ORDERED,
            QUANTITY_CANCELLED,
            AMOUNT_CANCELLED,
            QUANTITY_DELIVERED,
            AMOUNT_DELIVERED,
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
            BURDEN_SUM_SOURCE_RUN_ID,
            BURDEN_SUM_DEST_RUN_ID,
            BURDEN_SUM_REJECTION_CODE,
            ACCT_RAW_COST,
            ACCT_BURDENED_COST,
            DENOM_CURRENCY_CODE,
            DENOM_RAW_COST,
            DENOM_BURDENED_COST,
            ACCT_CURRENCY_CODE,
            ACCT_RATE_DATE,
            ACCT_RATE_TYPE,
            ACCT_EXCHANGE_RATE,
            RECEIPT_CURRENCY_CODE,
            RECEIPT_CURRENCY_AMOUNT,
            RECEIPT_EXCHANGE_RATE,
            PROJECT_CURRENCY_CODE,
            PROJECT_RATE_DATE,
            PROJECT_RATE_TYPE,
            PROJECT_EXCHANGE_RATE,
            GENERATION_ERROR_FLAG,
            CMT_REJECTION_CODE,
            INVENTORY_ITEM_ID,
            UOM_CODE,
            BOM_LABOR_RESOURCE_ID,
            BOM_EQUIPMENT_RESOURCE_ID,
            RESOURCE_CLASS
          )
          select /*+ push_pred(pctv) */
            PA_COMMITMENT_TXNS_S.NEXTVAL             CMT_LINE_ID,
            pctv.PROJECT_ID,
            pctv.TASK_ID,
            pctv.TRANSACTION_SOURCE,
            decode(pctv.LINE_TYPE,
                   'P', 'P',
                   'R', 'R',
                   'I', 'I',
                        'O')                         LINE_TYPE,
            pctv.CMT_NUMBER,
            pctv.CMT_DISTRIBUTION_ID,
            pctv.CMT_HEADER_ID,
            pctv.DESCRIPTION,
            pctv.EXPENDITURE_ITEM_DATE,
            decode(pctv.PROJECT_ID,
                   l_project_id_1,  l_pa_period_1,
                   l_project_id_2,  l_pa_period_2,
                   l_project_id_3,  l_pa_period_3,
                   l_project_id_4,  l_pa_period_4,
                   l_project_id_5,  l_pa_period_5,
                   l_project_id_6,  l_pa_period_6,
                   l_project_id_7,  l_pa_period_7,
                   l_project_id_8,  l_pa_period_8,
                   l_project_id_9,  l_pa_period_9,
                   l_project_id_10, l_pa_period_10,
                   l_project_id_11, l_pa_period_11,
                   l_project_id_12, l_pa_period_12,
                   l_project_id_13, l_pa_period_13,
                   l_project_id_14, l_pa_period_14,
                   l_project_id_15, l_pa_period_15,
                   l_project_id_16, l_pa_period_16,
                   l_project_id_17, l_pa_period_17,
                   l_project_id_18, l_pa_period_18,
                   l_project_id_19, l_pa_period_19,
                   l_project_id_20, l_pa_period_20)  PA_PERIOD,
            decode(pctv.PROJECT_ID,
                   l_project_id_1,  l_gl_period_1,
                   l_project_id_2,  l_gl_period_2,
                   l_project_id_3,  l_gl_period_3,
                   l_project_id_4,  l_gl_period_4,
                   l_project_id_5,  l_gl_period_5,
                   l_project_id_6,  l_gl_period_6,
                   l_project_id_7,  l_gl_period_7,
                   l_project_id_8,  l_gl_period_8,
                   l_project_id_9,  l_gl_period_9,
                   l_project_id_10, l_gl_period_10,
                   l_project_id_11, l_gl_period_11,
                   l_project_id_12, l_gl_period_12,
                   l_project_id_13, l_gl_period_13,
                   l_project_id_14, l_gl_period_14,
                   l_project_id_15, l_gl_period_15,
                   l_project_id_16, l_gl_period_16,
                   l_project_id_17, l_gl_period_17,
                   l_project_id_18, l_gl_period_18,
                   l_project_id_19, l_gl_period_19,
                   l_project_id_20, l_gl_period_20)  GL_PERIOD,
            pctv.CMT_LINE_NUMBER,
            pctv.CMT_CREATION_DATE,
            pctv.CMT_APPROVED_DATE,
            pctv.CMT_REQUESTOR_NAME,
            pctv.CMT_BUYER_NAME,
            pctv.CMT_APPROVED_FLAG,
            pctv.CMT_PROMISED_DATE,
            pctv.CMT_NEED_BY_DATE,
            pctv.ORGANIZATION_ID,
            pctv.VENDOR_ID,
            pctv.VENDOR_NAME,
            pctv.EXPENDITURE_TYPE,
            pctv.EXPENDITURE_CATEGORY,
            pctv.REVENUE_CATEGORY,
            pctv.SYSTEM_LINKAGE_FUNCTION,
            pctv.UNIT_OF_MEASURE,
            pctv.UNIT_PRICE,
            pctv.CMT_IND_COMPILED_SET_ID,
            to_number(null)                          TOT_CMT_RAW_COST,
            to_number(null)                          TOT_CMT_BURDENED_COST,
            pctv.TOT_CMT_QUANTITY,
            pctv.QUANTITY_ORDERED,
            pctv.AMOUNT_ORDERED,
            pctv.ORIGINAL_QUANTITY_ORDERED,
            pctv.ORIGINAL_AMOUNT_ORDERED,
            pctv.QUANTITY_CANCELLED,
            pctv.AMOUNT_CANCELLED,
            pctv.QUANTITY_DELIVERED,
            to_number(null)                          AMOUNT_DELIVERED,
            pctv.QUANTITY_INVOICED,
            pctv.AMOUNT_INVOICED,
            pctv.QUANTITY_OUTSTANDING_DELIVERY,
            pctv.AMOUNT_OUTSTANDING_DELIVERY,
            pctv.QUANTITY_OUTSTANDING_INVOICE,
            pctv.AMOUNT_OUTSTANDING_INVOICE,
            pctv.QUANTITY_OVERBILLED,
            pctv.AMOUNT_OVERBILLED,
            pctv.ORIGINAL_TXN_REFERENCE1,
            pctv.ORIGINAL_TXN_REFERENCE2,
            pctv.ORIGINAL_TXN_REFERENCE3,
            sysdate                                  LAST_UPDATE_DATE,
            x_last_updated_by                        LAST_UPDATED_BY,
            sysdate                                  CREATION_DATE,
            x_created_by                             CREATED_BY,
            x_last_update_login                      LAST_UPDATE_LOGIN,
            x_request_id                             REQUEST_ID,
            x_program_application_id                 PROGRAM_APPLICATION_ID,
            x_program_id                             PROGRAM_ID,
            null                                     PROGRAM_UPDATE_DATE,
            -9999                                    BURDEN_SUM_SOURCE_RUN_ID,
            null                                     BURDEN_SUM_DEST_RUN_ID,
            null                                     BURDEN_SUM_REJECTION_CODE,
            pctv.ACCT_RAW_COST,
            pctv.ACCT_BURDENED_COST,
            pctv.DENOM_CURRENCY_CODE,
            pctv.DENOM_RAW_COST,
            pctv.DENOM_BURDENED_COST,
            pctv.ACCT_CURRENCY_CODE,
            pctv.ACCT_RATE_DATE,
            pctv.ACCT_RATE_TYPE,
            pctv.ACCT_EXCHANGE_RATE,
            pctv.RECEIPT_CURRENCY_CODE,
            pctv.RECEIPT_CURRENCY_AMOUNT,
            pctv.RECEIPT_EXCHANGE_RATE,
            null                                     PROJECT_CURRENCY_CODE,
            to_date(null)                            PROJECT_RATE_DATE,
            null                                     PROJECT_RATE_TYPE,
            to_number(null)                          PROJECT_EXCHANGE_RATE,
            'N'                                      GENERATION_ERROR_FLAG,
            null                                     CMT_REJECTION_CODE,
            pctv.INVENTORY_ITEM_ID,
            pctv.UOM_CODE,
            pctv.WIP_RESOURCE_ID                     BOM_LABOR_RESOURCE_ID,
            pctv.WIP_RESOURCE_ID                     BOM_EQUIPMENT_RESOURCE_ID,
            pctv.RESOURCE_CLASS
          from
            PA_COMMITMENT_TXNS_V pctv
          where
            pctv.PROJECT_ID = l_project_id_1;

            /* single project batch

            pctv.PROJECT_ID in (l_project_id_1,
                                l_project_id_2,
                                l_project_id_3,
                                l_project_id_4,
                                l_project_id_5,
                                l_project_id_6,
                                l_project_id_7,
                                l_project_id_8,
                                l_project_id_9,
                                l_project_id_10,
                                l_project_id_11,
                                l_project_id_12,
                                l_project_id_13,
                                l_project_id_14,
                                l_project_id_15,
                                l_project_id_16,
                                l_project_id_17,
                                l_project_id_18,
                                l_project_id_19,
                                l_project_id_20);
            */

/* Start of Addition for bug 5635857*/
    ELSIF x_use_tmp_table='Y' THEN
          insert into PA_COMMITMENT_TXNS
          (
            CMT_LINE_ID,
            PROJECT_ID,
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
            TOT_CMT_RAW_COST,
            TOT_CMT_BURDENED_COST,
            TOT_CMT_QUANTITY,
            QUANTITY_ORDERED,
            AMOUNT_ORDERED,
            ORIGINAL_QUANTITY_ORDERED,
            ORIGINAL_AMOUNT_ORDERED,
            QUANTITY_CANCELLED,
            AMOUNT_CANCELLED,
            QUANTITY_DELIVERED,
            AMOUNT_DELIVERED,
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
            BURDEN_SUM_SOURCE_RUN_ID,
            BURDEN_SUM_DEST_RUN_ID,
            BURDEN_SUM_REJECTION_CODE,
            ACCT_RAW_COST,
            ACCT_BURDENED_COST,
            DENOM_CURRENCY_CODE,
            DENOM_RAW_COST,
            DENOM_BURDENED_COST,
            ACCT_CURRENCY_CODE,
            ACCT_RATE_DATE,
            ACCT_RATE_TYPE,
            ACCT_EXCHANGE_RATE,
            RECEIPT_CURRENCY_CODE,
            RECEIPT_CURRENCY_AMOUNT,
            RECEIPT_EXCHANGE_RATE,
            PROJECT_CURRENCY_CODE,
            PROJECT_RATE_DATE,
            PROJECT_RATE_TYPE,
            PROJECT_EXCHANGE_RATE,
            GENERATION_ERROR_FLAG,
            CMT_REJECTION_CODE,
            INVENTORY_ITEM_ID,
            UOM_CODE,
            BOM_LABOR_RESOURCE_ID,
            BOM_EQUIPMENT_RESOURCE_ID,
            RESOURCE_CLASS
          )
          select
            PA_COMMITMENT_TXNS_S.NEXTVAL             CMT_LINE_ID,
            pctv.PROJECT_ID,
            pctv.TASK_ID,
            pctv.TRANSACTION_SOURCE,
            pctv.LINE_TYPE,
            pctv.CMT_NUMBER,
            pctv.CMT_DISTRIBUTION_ID,
            pctv.CMT_HEADER_ID,
            pctv.DESCRIPTION,
            pctv.EXPENDITURE_ITEM_DATE,
            decode(pctv.PROJECT_ID,
                   l_project_id_1,  l_pa_period_1,
                   l_project_id_2,  l_pa_period_2,
                   l_project_id_3,  l_pa_period_3,
                   l_project_id_4,  l_pa_period_4,
                   l_project_id_5,  l_pa_period_5,
                   l_project_id_6,  l_pa_period_6,
                   l_project_id_7,  l_pa_period_7,
                   l_project_id_8,  l_pa_period_8,
                   l_project_id_9,  l_pa_period_9,
                   l_project_id_10, l_pa_period_10,
                   l_project_id_11, l_pa_period_11,
                   l_project_id_12, l_pa_period_12,
                   l_project_id_13, l_pa_period_13,
                   l_project_id_14, l_pa_period_14,
                   l_project_id_15, l_pa_period_15,
                   l_project_id_16, l_pa_period_16,
                   l_project_id_17, l_pa_period_17,
                   l_project_id_18, l_pa_period_18,
                   l_project_id_19, l_pa_period_19,
                   l_project_id_20, l_pa_period_20)  PA_PERIOD,
            decode(pctv.PROJECT_ID,
                   l_project_id_1,  l_gl_period_1,
                   l_project_id_2,  l_gl_period_2,
                   l_project_id_3,  l_gl_period_3,
                   l_project_id_4,  l_gl_period_4,
                   l_project_id_5,  l_gl_period_5,
                   l_project_id_6,  l_gl_period_6,
                   l_project_id_7,  l_gl_period_7,
                   l_project_id_8,  l_gl_period_8,
                   l_project_id_9,  l_gl_period_9,
                   l_project_id_10, l_gl_period_10,
                   l_project_id_11, l_gl_period_11,
                   l_project_id_12, l_gl_period_12,
                   l_project_id_13, l_gl_period_13,
                   l_project_id_14, l_gl_period_14,
                   l_project_id_15, l_gl_period_15,
                   l_project_id_16, l_gl_period_16,
                   l_project_id_17, l_gl_period_17,
                   l_project_id_18, l_gl_period_18,
                   l_project_id_19, l_gl_period_19,
                   l_project_id_20, l_gl_period_20)  GL_PERIOD,
            pctv.CMT_LINE_NUMBER,
            pctv.CMT_CREATION_DATE,
            pctv.CMT_APPROVED_DATE,
            pctv.CMT_REQUESTOR_NAME,
            pctv.CMT_BUYER_NAME,
            pctv.CMT_APPROVED_FLAG,
            pctv.CMT_PROMISED_DATE,
            pctv.CMT_NEED_BY_DATE,
            pctv.ORGANIZATION_ID,
            pctv.VENDOR_ID,
            pctv.VENDOR_NAME,
            pctv.EXPENDITURE_TYPE,
            pctv.EXPENDITURE_CATEGORY,
            pctv.REVENUE_CATEGORY,
            pctv.SYSTEM_LINKAGE_FUNCTION,
            pctv.UNIT_OF_MEASURE,
            pctv.UNIT_PRICE,
            pctv.CMT_IND_COMPILED_SET_ID,
            to_number(null)                          TOT_CMT_RAW_COST,
            to_number(null)                          TOT_CMT_BURDENED_COST,
            pctv.TOT_CMT_QUANTITY,
            pctv.QUANTITY_ORDERED,
            pctv.AMOUNT_ORDERED,
            pctv.ORIGINAL_QUANTITY_ORDERED,
            pctv.ORIGINAL_AMOUNT_ORDERED,
            pctv.QUANTITY_CANCELLED,
            pctv.AMOUNT_CANCELLED,
            pctv.QUANTITY_DELIVERED,
            to_number(null)                          AMOUNT_DELIVERED,
            pctv.QUANTITY_INVOICED,
            pctv.AMOUNT_INVOICED,
            pctv.QUANTITY_OUTSTANDING_DELIVERY,
            pctv.AMOUNT_OUTSTANDING_DELIVERY,
            pctv.QUANTITY_OUTSTANDING_INVOICE,
            pctv.AMOUNT_OUTSTANDING_INVOICE,
            pctv.QUANTITY_OVERBILLED,
            pctv.AMOUNT_OVERBILLED,
            pctv.ORIGINAL_TXN_REFERENCE1,
            pctv.ORIGINAL_TXN_REFERENCE2,
            pctv.ORIGINAL_TXN_REFERENCE3,
            sysdate                                  LAST_UPDATE_DATE,
            x_last_updated_by                        LAST_UPDATED_BY,
            sysdate                                  CREATION_DATE,
            x_created_by                             CREATED_BY,
            x_last_update_login                      LAST_UPDATE_LOGIN,
            x_request_id                             REQUEST_ID,
            x_program_application_id                 PROGRAM_APPLICATION_ID,
            x_program_id                             PROGRAM_ID,
            null                                     PROGRAM_UPDATE_DATE,
            -9999                                    BURDEN_SUM_SOURCE_RUN_ID,
            null                                     BURDEN_SUM_DEST_RUN_ID,
            null                                     BURDEN_SUM_REJECTION_CODE,
            pctv.ACCT_RAW_COST,
            pctv.ACCT_BURDENED_COST,
            pctv.DENOM_CURRENCY_CODE,
            pctv.DENOM_RAW_COST,
            pctv.DENOM_BURDENED_COST,
            pctv.ACCT_CURRENCY_CODE,
            pctv.ACCT_RATE_DATE,
            pctv.ACCT_RATE_TYPE,
            pctv.ACCT_EXCHANGE_RATE,
            pctv.RECEIPT_CURRENCY_CODE,
            pctv.RECEIPT_CURRENCY_AMOUNT,
            pctv.RECEIPT_EXCHANGE_RATE,
            null                                     PROJECT_CURRENCY_CODE,
            to_date(null)                            PROJECT_RATE_DATE,
            null                                     PROJECT_RATE_TYPE,
            to_number(null)                          PROJECT_EXCHANGE_RATE,
            'N'                                      GENERATION_ERROR_FLAG,
            null                                     CMT_REJECTION_CODE,
            pctv.INVENTORY_ITEM_ID,
            pctv.UOM_CODE,
            pctv.WIP_RESOURCE_ID                     BOM_LABOR_RESOURCE_ID,
            pctv.WIP_RESOURCE_ID                     BOM_EQUIPMENT_RESOURCE_ID,
            pctv.RESOURCE_CLASS
          from
         pa_commitment_txns_tmp pctv
          WHERE
            pctv.PROJECT_ID = l_project_id_1;
    end if;
/* End of Addition for bug 5635857*/

        end;

      end if;

   END IF; -- ( PA_PROJ_ACCUM_MAIN.G_GMS_Enabled = 'Y'

   -- End: Grants Management Integrated Commitment Processing  ---------------------


   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug('create_cmt_txns: ' || 'Records Inserted = '||TO_CHAR(SQL%ROWCOUNT));
   END IF;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;

  END create_cmt_txns;

  -- This procedure accumulates the actual cost txn in the given
  -- txn_accum_id. The quantity figures are accumulated in
  -- either tot_quantity or tot_labor_hours column on
  -- pa_txn_accum depending if the UNIT_OF_MEASURE is 'HOURS'
  -- We are assuming that for a given expenditure type we
  -- can have only one and only one UNIT_OF_MEASURE
  -- Since expenditure types is one of the transaction attributes
  -- for a row in pa_txn_accum it will have only one and only one
  -- value for UNIT_OF_MEASURE

  PROCEDURE accum_act_txn
		       ( x_txn_accum_id               IN  NUMBER,
			 x_tot_raw_cost               IN  NUMBER,
			 x_tot_burdened_cost          IN  NUMBER,
			 x_tot_quantity               IN  NUMBER,
			 x_tot_billable_raw_cost      IN  NUMBER,
			 x_tot_billable_burdened_cost IN  NUMBER,
			 x_tot_billable_quantity      IN  NUMBER,
			 x_unit_of_measure            IN  VARCHAR2,
			 x_err_stage               IN OUT NOCOPY VARCHAR2,
			 x_err_code                IN OUT NOCOPY NUMBER)
  IS
  BEGIN
       x_err_code :=0;

       -- for actual costs x_unit_of_measure will always be not null
       -- If the transactions are labor transactions than add them to
       -- to labor_hours and billable_labor_hours as well

       x_err_stage := 'Accumulating Actual Cost transaction';

       UPDATE pa_txn_accum pta
       SET    pta.i_tot_raw_cost               = DECODE(raw_cost_flag,'Y',
                                                   (NVL(i_tot_raw_cost, 0) + x_tot_raw_cost),
                                                   NULL),
	      pta.i_tot_burdened_cost          = DECODE(burdened_cost_flag,'Y',
                                                   (NVL(i_tot_burdened_cost, 0) +
						     x_tot_burdened_cost),NULL),
	      pta.i_tot_quantity               = DECODE(quantity_flag,'Y',
                                                   (NVL(i_tot_quantity, 0) +
						     x_tot_quantity),NULL),
	      pta.i_tot_labor_hours            = DECODE(labor_hours_flag,'Y',
                                                   (NVL(i_tot_labor_hours,0) +
	                                         DECODE(pta.system_linkage_function,
							  'OT',
							     x_tot_quantity,
							   'ST',
							     x_tot_quantity,
							   0)),NULL),
	      pta.i_tot_billable_raw_cost      = DECODE(billable_raw_cost_flag,'Y',
                                                   (NVL(i_tot_billable_raw_cost, 0) +
			                             x_tot_billable_raw_cost),NULL),
	      pta.i_tot_billable_burdened_cost = DECODE(billable_burdened_cost_flag,'Y',
                                                   (NVL(i_tot_billable_burdened_cost, 0) +
			                             x_tot_billable_burdened_cost),NULL),
	      pta.i_tot_billable_quantity      = DECODE(billable_quantity_flag,'Y',
                                                   (NVL(i_tot_billable_quantity, 0) +
			                             x_tot_billable_quantity),NULL),
	      pta.i_tot_billable_labor_hours   = DECODE(billable_labor_hours_flag,'Y',
                                                   (NVL(i_tot_billable_labor_hours,0) +
	                                         DECODE(pta.system_linkage_function,
							  'OT',
							     x_tot_billable_quantity,
							   'ST',
							     x_tot_billable_quantity,
							   0)),NULL),
	      pta.unit_of_measure              = x_unit_of_measure,
              pta.actual_cost_rollup_flag      = 'Y',
              pta.last_update_date             = SYSDATE,
	      pta.last_updated_by              = x_last_updated_by,
	      pta.request_Id                   = x_request_id,
	      pta.program_application_id       = x_program_application_id,
	      pta.program_id                   = x_program_id,
	      pta.program_update_Date          = SYSDATE
       WHERE
	      pta.txn_accum_id = x_txn_accum_id;

  EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
  END accum_act_txn;

  -- This procedure accumulates the revenue txn in the given
  -- txn_accum_id.

  PROCEDURE accum_rev_txn
		       ( x_txn_accum_id           IN  NUMBER,
			 x_tot_revenue            IN  NUMBER,
                         x_unit_of_measure	  IN  VARCHAR2,
			 x_err_stage           IN OUT NOCOPY VARCHAR2,
			 x_err_code            IN OUT NOCOPY NUMBER)
  IS
  BEGIN
       x_err_code :=0;
       x_err_stage := 'Accumulating Revenue transactions';

       -- accumulate revenue now
       UPDATE pa_txn_accum pta
       SET    pta.i_tot_revenue           = DECODE(revenue_flag,'Y',
                                              (NVL(i_tot_revenue, 0) +
					        x_tot_revenue),NULL),
              pta.unit_of_measure         = x_unit_of_measure,
              pta.revenue_rollup_flag     = 'Y',
              pta.last_update_date        = SYSDATE,
	      pta.last_updated_by         = x_last_updated_by,
	      pta.request_Id              = x_request_id,
	      pta.program_application_id  = x_program_application_id,
	      pta.program_id              = x_program_id,
	      pta.program_update_Date     = SYSDATE
       WHERE
	      pta.txn_accum_id = x_txn_accum_id;

  EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
  END accum_rev_txn;

  -- This procedure accumulates the commitment txn in the given
  -- txn_accum_id.
  -- Please note that the commitment quantity is always accumulated
  -- into CMT_QUANTITY column irrespective of the unit_of_measure
  -- is 'HOURS'

  PROCEDURE accum_cmt_txn
		       ( x_txn_accum_id           IN  NUMBER,
			 x_tot_cmt_raw_cost       IN  NUMBER,
			 x_tot_cmt_burdened_cost  IN  NUMBER,
			 x_err_stage           IN OUT NOCOPY VARCHAR2,
			 x_err_code            IN OUT NOCOPY NUMBER)
  IS
  BEGIN
       x_err_code :=0;
       x_err_stage := 'Accumulating Commitments transaction';
       -- accumulate commitment now

       /* Bug# 1239605 - Included NVL for x_tot_cmt_raw_cost and
          x_tot_burdened_cost in the following update */

       UPDATE pa_txn_accum pta
       SET    pta.tot_cmt_raw_cost      = DECODE(cmt_raw_cost_flag,'Y',
                                          (NVL(tot_cmt_raw_cost, 0) +
					  NVL(x_tot_cmt_raw_cost,0)),NULL),
	      pta.tot_cmt_burdened_cost = DECODE(cmt_burdened_cost_flag,'Y',
                                          (NVL(tot_cmt_burdened_cost, 0) +
                                          NVL(x_tot_cmt_burdened_cost,0)),NULL),
              pta.cmt_rollup_flag       = 'Y',
              pta.last_update_date      = SYSDATE,
	      pta.last_updated_by       = x_last_updated_by,
	      pta.request_Id            = x_request_id,
	      pta.program_application_id= x_program_application_id,
	      pta.program_id            = x_program_id,
	      pta.program_update_Date   = SYSDATE
       WHERE
	      pta.txn_accum_id = x_txn_accum_id;

  EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
  END accum_cmt_txn;

  -- Accumulate cost from CDLS

-- Name: Accum_Cdls
--
-- History
--   dd-mmm-1997     Vbanal          Created.
--
--   15-OCT-2001     Jwhite          Modified for the Enhanced Period Processing effort.
--                                   Removed joins to gl_date_period_map and related entities
--                                   and referenced new GL and PA period name columns on cdl.
--
--   13-OCT-2002     Sacgupta        Bug # 2580808.
--                                   Modified for the Enhanced Period Processing effort.
--                                   Fetching PA period name and GL period name from gl_date_period_map
--                                   and related entities for inserting into pa_txn_accum table when
--                                   GL and PA period name columns on cdl are null.
--
--   05-NOV-2002     Sacgupta        Bug # 2650900.
--                                   Removed the condition x_mode <> I. So now both Update process and
--                                   Refresh process will fetch PA period name and GL period name from
--                                   gl_date_period_map and related entities for inserting into
--                                   pa_txn_accum table when GL and PA period name columns on cdl are null.
--
--   20-MAY-2003      jwhite         For r11i.PA.L Burdening Enhancements, modified the following
--                                   cursors: selcdls1, selcdls2, selcdls3.
--
--                                   Code like the following:
--                                         AND cdl.line_type = 'R'
--                                   was replaced with the following:
--                                         AND ( cdl.line_type = 'R' OR cdl.line_type = 'I')
--
--
--   31-JUL-2003      jwhite         For patchset 'L' Reburdening Enhancement, added this
--                                   IN-parm to the accum_cdls procedure to help minimize found
--                                   performance issues:
--                                         x_cdl_line_type VARCHAR2
--
--                                   Code like the following:
--                                         AND ( cdl.line_type = 'R' OR cdl.line_type = 'I')
--                                   was replaced with the following:
--                                         AND cdl.line_type = x_cdl_line_type
--
--   07-Jul-2004     Sacgupta        Bug # 3736097.
--                                   Commented out all occurence of x_end_project_id.
--                                   This is done because all the processing is done for a
--                                   single project rather than for a range of projects.
--



  PROCEDURE accum_cdls
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
                          x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_mode                    IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
                          x_cdl_line_type           IN  VARCHAR2,
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
                          x_err_code             IN OUT NOCOPY NUMBER)
  IS
P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/


	-- The cursor selcdl selects all CDLs which
	-- satisfy the pa_period given as the parameters
	-- the argument x_mode represents the mode for accumulation i.e.
	-- 'I' for incremental and 'F' for FULL

/* Bug# 1770772 - Breaking the cursor into two and call/open it conditionally based on x_mode parameter
   to eliminate the decode on resource_accumulated_Flag and hence use index usage
*/
	CURSOR selcdls1 IS
        SELECT
	   cdl.ROWID cdlrowid,
           cdl.expenditure_item_id expenditure_item_id,
           cdl.line_num line_num,
           pe.incurred_by_person_id person_id,
	   ei.job_id job_id,
           NVL(ei.override_to_organization_id,
	       pe.incurred_by_organization_id) organization_id,
           decode(ei.system_linkage_function,'VI',cdl.system_reference1,NULL) vendor_id, -- Modified for bug#5878137
           et.expenditure_type expenditure_type,
           ei.non_labor_resource non_labor_resource,
           et.expenditure_category expenditure_category,
	   et.revenue_category_code revenue_category,
           ei.organization_id non_labor_resource_org_id,
	   ei.system_linkage_function system_linkage_function,
           cdl.project_id project_id,
	   cdl.task_id task_id,
	   cdl.RECVR_PA_PERIOD_NAME pa_period,
           cdl.RECVR_GL_PERIOD_NAME gl_period,
           pe.expenditure_ending_date week_ending_date,
	   LAST_DAY(ei.expenditure_item_date) month_ending_date,
	   NVL(cdl.amount,0) raw_cost,
	   NVL(cdl.quantity,0) quantity,
	   NVL(cdl.burdened_cost,0) burdened_cost,
	   DECODE(cdl.billable_flag,'Y',NVL(cdl.amount,0),0) billable_raw_cost,
	   DECODE(cdl.billable_flag,'Y',NVL(cdl.quantity,0),0) billable_quantity,
	   DECODE(cdl.billable_flag,'Y',NVL(cdl.burdened_cost,0),0) billable_burdened_cost,
	   decode(et.unit_of_measure,NULL, ei.unit_of_measure, et.unit_of_measure) unit_of_measure,
	   cdl.ind_compiled_set_id cost_ind_compiled_set_id
        FROM
	   pa_expenditures_all pe,
           pa_expenditure_types et,
	   pa_expenditure_items_all ei,
           pa_cost_distribution_lines_all cdl
        WHERE
     cdl.project_id = x_start_project_id      -- BETWEEN x_start_project_id AND x_end_project_id
        AND cdl.line_type = x_cdl_line_type
        AND cdl.resource_accumulated_flag = 'N'
        AND cdl.expenditure_item_id = ei.expenditure_item_id
        AND NVL(cdl.org_id,-99) = NVL(ei.org_id,-99)
        AND ei.expenditure_type = et.expenditure_type
        AND ei.task_id = cdl.task_id
        AND pe.expenditure_id = ei.expenditure_id
        AND NVL(pe.org_id,-99) = NVL(ei.org_id,-99)
        AND ei.system_linkage_function||'' =
	          NVL(x_system_linkage_function,ei.system_linkage_function)
        AND TRUNC(cdl.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date;

	CURSOR selcdls2 IS
        SELECT
	   cdl.ROWID cdlrowid,
           cdl.expenditure_item_id expenditure_item_id,
           cdl.line_num line_num,
           pe.incurred_by_person_id person_id,
	   ei.job_id job_id,
           NVL(ei.override_to_organization_id,
	       pe.incurred_by_organization_id) organization_id,
           decode(ei.system_linkage_function,'VI',cdl.system_reference1,NULL) vendor_id, -- Modified for bug#5878137
           et.expenditure_type expenditure_type,
           ei.non_labor_resource non_labor_resource,
           et.expenditure_category expenditure_category,
	   et.revenue_category_code revenue_category,
           ei.organization_id non_labor_resource_org_id,
	   ei.system_linkage_function system_linkage_function,
           cdl.project_id project_id,
	   cdl.task_id task_id,
	   cdl.RECVR_PA_PERIOD_NAME pa_period,
           cdl.RECVR_GL_PERIOD_NAME gl_period,
           pe.expenditure_ending_date week_ending_date,
	   LAST_DAY(ei.expenditure_item_date) month_ending_date,
	   NVL(cdl.amount,0) raw_cost,
	   NVL(cdl.quantity,0) quantity,
	   NVL(cdl.burdened_cost,0) burdened_cost,
	   DECODE(cdl.billable_flag,'Y',NVL(cdl.amount,0),0) billable_raw_cost,
	   DECODE(cdl.billable_flag,'Y',NVL(cdl.quantity,0),0) billable_quantity,
	   DECODE(cdl.billable_flag,'Y',NVL(cdl.burdened_cost,0),0) billable_burdened_cost,
	   decode(et.unit_of_measure ,NULL, ei.unit_of_measure, et.unit_of_measure) unit_of_measure,
	   cdl.ind_compiled_set_id cost_ind_compiled_set_id
        FROM
	   pa_expenditures_all pe,
           pa_expenditure_types et,
	   pa_expenditure_items_all ei,
           pa_cost_distribution_lines_all cdl
        WHERE
--	    cdl.project_id BETWEEN x_start_project_id AND x_end_project_id -- Modified for bug 3736097
	    cdl.project_id = x_start_project_id
        AND cdl.line_type = x_cdl_line_type
/* Commented for bug# 1770772 while splitting the cursor in two
        AND cdl.resource_accumulated_flag =
		    decode(x_mode,'I','N',
				  'F',cdl.resource_accumulated_flag,'N')
*/
        AND cdl.expenditure_item_id = ei.expenditure_item_id
        AND NVL(cdl.org_id,-99) = NVL(ei.org_id,-99)
        AND ei.expenditure_type = et.expenditure_type
        AND ei.task_id = cdl.task_id
        AND pe.expenditure_id = ei.expenditure_id
        AND NVL(pe.org_id,-99) = NVL(ei.org_id,-99)
        AND ei.system_linkage_function||'' =
	          NVL(x_system_linkage_function,ei.system_linkage_function)
        AND TRUNC(cdl.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date;

-- Cursor added for bug 2580808
	CURSOR selcdls3 (crowid  VARCHAR2)IS
        SELECT
           p.period_name pa_period1,
           g.period_name gl_period1
        FROM
	          gl_date_period_map p,
           gl_date_period_map g,
	          pa_expenditures_all pe,
           pa_expenditure_types et,
	          pa_expenditure_items_all ei,
           pa_cost_distribution_lines_all cdl,
           pa_implementations pi,
           gl_sets_of_books sob
        WHERE
    --       cdl.project_id BETWEEN x_start_project_id AND x_end_project_id  -- Modified for bug 3736097
           cdl.project_id = x_start_project_id
       	AND cdl.ROWID = CHARTOROWID(crowid)
        AND cdl.line_type = x_cdl_line_type
        AND cdl.expenditure_item_id = ei.expenditure_item_id
        AND NVL(cdl.org_id,-99) = NVL(ei.org_id,-99)
        AND ei.expenditure_type = et.expenditure_type
        AND ei.task_id = cdl.task_id
        AND pe.expenditure_id = ei.expenditure_id
        AND NVL(pe.org_id,-99) = NVL(ei.org_id,-99)
        AND sob.set_of_books_id = pi.set_of_books_id
        AND p.period_set_name = sob.period_set_name
        AND g.period_set_name = sob.period_set_name
        AND p.period_type = pi.pa_period_type
        AND g.period_type = sob.accounted_period_type
        /* Bug #3493462: Added trunc to recvr_pa_date */
        AND p.accounting_date = TRUNC(cdl.recvr_pa_date)
        AND g.accounting_date = NVL(TRUNC(cdl.recvr_gl_date), TRUNC(cdl.recvr_pa_date))
        AND ei.system_linkage_function||'' =
	          NVL(x_system_linkage_function,ei.system_linkage_function)
        AND TRUNC(cdl.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date;

  cdlrec	     selcdls1%ROWTYPE;
  cdlrec1            selcdls3%ROWTYPE; -- added for bug 2580808.
  x_txn_accum_id     NUMBER;
  row_processed      NUMBER;
  commit_rows        NUMBER;

  BEGIN

     x_txn_accum_id    :=0;
     x_err_code        :=0;
     row_processed     :=0;
     commit_rows       :=0;
     x_err_stage       := 'Accumulating CDLs';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('accum_cdls: ' || x_err_stage);
     END IF;

/* Included for bug# 1770772 */

     IF x_mode = 'I' THEN
        OPEN selcdls1;
     ELSE
        OPEN selcdls2;
     END IF;

     LOOP
     IF x_mode = 'I' THEN
        FETCH selcdls1 INTO cdlrec;
        EXIT WHEN selcdls1%NOTFOUND;
     ELSE
        FETCH selcdls2 INTO cdlrec;
        EXIT WHEN selcdls2%NOTFOUND;
     END IF;

/* Commented for bug# 1770772 */

/*   FOR cdlrec IN selcdls LOOP */

/* End of changes for bug# 1770772 */

	row_processed := row_processed + 1;
        commit_rows   := commit_rows + 1;

-- IF clause added for bug 2580808.
--	IF x_mode <> 'I' THEN    -- for bug 2650900
	  IF cdlrec.pa_period IS NULL OR cdlrec.gl_period IS NULL THEN
             OPEN selcdls3(ROWIDTOCHAR(cdlrec.cdlrowid));
             FETCH selcdls3 INTO cdlrec1;
             CLOSE selcdls3;
          END IF;
--	END IF;        -- for bug 2650900


	create_txn_accum(
	    cdlrec.project_id,
	    cdlrec.task_id,
	    NVL(cdlrec.pa_period, cdlrec1.pa_period1), -- Modified for bug 2580808.
	    NVL(cdlrec.gl_period, cdlrec1.gl_period1), -- Modified for bug 2580808.
	    cdlrec.week_ending_date,
	    cdlrec.month_ending_date,
	    cdlrec.person_id,
	    cdlrec.job_id,
	    cdlrec.vendor_id,
	    cdlrec.expenditure_type,
	    cdlrec.organization_id,
	    cdlrec.non_labor_resource,
	    cdlrec.non_labor_resource_org_id,
	    cdlrec.expenditure_category,
	    cdlrec.revenue_category,
	    NULL,                               -- event_type
	    NULL,                               -- event_type_classification
	    cdlrec.system_linkage_function,
	    'C',                                -- x_line_type = 'C' for CDL
	    cdlrec.cost_ind_compiled_set_id,
	    NULL,                               -- rev_ind_compiled_set_id
	    NULL,                               -- inv_ind_compiled_set_id
	    NULL,                               -- cmt_ind_compiled_set_id
	    x_txn_accum_id,
	    x_err_stage,
	    x_err_code);

        -- Create a row for drilldown in pa_txn_accume_details Now

        create_txn_accum_details(
            x_txn_accum_id,
	    'C',                                -- CDLS
	    cdlrec.expenditure_item_id,
            cdlrec.line_num,
	    NULL,                               -- event_num
	    NULL,                               -- cmt_line_id
	    cdlrec.project_id,
	    cdlrec.task_id,
	    x_err_stage,
	    x_err_code);

        -- Accume this row now for txn_accum_id = x_txn_accum_id
        -- also create rows for drilldown

	accum_act_txn(
	   x_txn_accum_id,
	   cdlrec.raw_cost,
	   cdlrec.burdened_cost,
	   cdlrec.quantity,
	   cdlrec.billable_raw_cost,
	   cdlrec.billable_burdened_cost,
	   cdlrec.billable_quantity,
	   cdlrec.unit_of_measure,
	   x_err_stage,
	   x_err_code);

        --- Update the CDL.Resource_accumulated_flag = 'Y' Now

	UPDATE
            pa_cost_distribution_lines_all
	SET
            resource_accumulated_flag = 'Y'
	WHERE
            ROWID = cdlrec.cdlrowid;

        IF (commit_rows >= pa_proj_accum_main.x_commit_size) THEN
            COMMIT;
            commit_rows := 0;
        END IF;

     END LOOP;

/* Included for bug# 1770772 */

     IF x_mode = 'I' THEN
        CLOSE selcdls1;
     ELSE
        CLOSE selcdls2;
     END IF;

/* End of changes for bug# 1770772 */

     IF (commit_rows < pa_proj_accum_main.x_commit_size) THEN
           COMMIT;
     END IF;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('accum_cdls: ' || 'Number of CDL Processed = ' || TO_CHAR(row_processed));
     END IF;

     EXCEPTION
	WHEN OTHERS THEN
	x_err_code := SQLCODE;
	RAISE;

  END accum_cdls;

  -- Accumulate revenue from RDLS

-- Name: Accum_Rdls
--
-- History
--   dd-mmm-1997     Vbanal          Created.
--
--   15-OCT-2001     Jwhite          Modified for the Enhanced Period Processing effort.
--                                   Removed joins to gl_date_period_map and related entities
--                                   and referenced new GL and PA period name columns on rdl.
--
--   13-OCT-2002     Sacgupta        Bug # 2580808.
--                                   Modified for the Enhanced Period Processing effort.
--                                   Fetching PA period name and GL period name from gl_date_period_map
--                                   and related entities for inserting into pa_txn_accum table when
--                                   GL and PA period name columns on rdl are null.
--
--   05-NOV-2002     Sacgupta        Bug # 2650900.
--                                   Removed the condition x_mode <> I. So now both Update process and
--                                   Refresh process will fetch PA period name and GL period name from
--                                   gl_date_period_map and related entities for inserting into
--                                   pa_txn_accum table when GL and PA period name columns on rdl are null.
--
--   07-Jul-2004     Sacgupta        Bug # 3736097.
--                                   Commented out all occurence of x_end_project_id.
--                                   This is done because all the processing is done for a
--                                   single project rather than for a range of projects.
  PROCEDURE accum_rdls
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
			  x_mode                    IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
                          x_err_code             IN OUT NOCOPY NUMBER)
  IS
P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/


	CURSOR selrdls IS
        SELECT
	   dr.ROWID drrowid,
           rdl.expenditure_item_id expenditure_item_id,
           rdl.line_num line_num,
           pe.incurred_by_person_id person_id,
	   ei.job_id job_id,
           NVL(ei.override_to_organization_id,
	       pe.incurred_by_organization_id) organization_id,
           et.expenditure_type expenditure_type,
           ei.non_labor_resource non_labor_resource,
           et.expenditure_category expenditure_category,
	   et.revenue_category_code revenue_category,
	   ei.organization_id non_labor_resource_org_id,
	   ei.system_linkage_function system_linkage_function,
           dr.project_id project_id,
	   ei.task_id task_id,
	   dr.PA_PERIOD_NAME pa_period,
           dr.GL_PERIOD_NAME gl_period,
           pe.expenditure_ending_date week_ending_date,
	   LAST_DAY(ei.expenditure_item_date) month_ending_date,
	   rdl.rev_ind_compiled_set_id rev_ind_compiled_set_id,
	   rdl.inv_ind_compiled_set_id inv_ind_compiled_set_id,
	   NVL(rdl.amount,0) amount,
           decode(et.unit_of_measure,NULL,et.unit_of_measure,ei.unit_of_measure)  unit_of_measure
        FROM
	   pa_expenditures_all pe,
           pa_expenditure_types et,
	   pa_expenditure_items_all ei,
           pa_cust_rev_dist_lines rdl,
	   pa_draft_revenues dr
        WHERE
	    dr.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id Commented for Bug # 3736097
        AND NVL(dr.resource_accumulated_flag,'S') =
		     DECODE(x_mode,'I','S',
				   'F',NVL(dr.resource_accumulated_flag,'S'),'S')
	AND dr.released_date IS NOT NULL
	AND rdl.function_code NOT IN ('LRL','LRB','URL','URB')
	AND dr.project_id = rdl.project_id
	AND dr.draft_revenue_num = rdl.draft_revenue_num
	AND rdl.expenditure_item_id = ei.expenditure_item_id
        AND ei.expenditure_type = et.expenditure_type
        AND TRUNC(dr.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date
        AND NVL(pe.org_id,-99) = NVL(ei.org_id,-99)
        AND pe.expenditure_id = ei.expenditure_id;

-- Cursor added for bug 2580808
	CURSOR selrdls1 (rrowid  VARCHAR2)IS
        SELECT
           p.period_name pa_period1,
           g.period_name gl_period1
        FROM
       	   gl_date_period_map p,
           gl_date_period_map g,
 	         pa_expenditures_all pe,
           pa_expenditure_types et,
           pa_expenditure_items_all ei,
           pa_cust_rev_dist_lines rdl,
           pa_draft_revenues dr,
           pa_implementations pi,
           gl_sets_of_books sob
        WHERE
      	    dr.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id Commented for Bug # 3736097
	       AND dr.ROWID = CHARTOROWID(rrowid)
        AND NVL(dr.resource_accumulated_flag,'S') =
           DECODE(x_mode,'I','S',
				         'F',NVL(dr.resource_accumulated_flag,'S'),'S')
	       AND dr.released_date IS NOT NULL
	AND rdl.function_code NOT IN ('LRL','LRB','URL','URB')
	AND dr.project_id = rdl.project_id
	AND dr.draft_revenue_num = rdl.draft_revenue_num
	AND rdl.expenditure_item_id = ei.expenditure_item_id
        AND ei.expenditure_type = et.expenditure_type
        AND sob.set_of_books_id = pi.set_of_books_id
        AND p.period_set_name = sob.period_set_name
        AND g.period_set_name = sob.period_set_name
        AND p.period_type = pi.pa_period_type
        AND g.period_type = sob.accounted_period_type
        AND p.accounting_date = dr.pa_date
        AND g.accounting_date = NVL(dr.gl_date, dr.pa_date)
        AND TRUNC(dr.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date
        AND NVL(pe.org_id,-99) = NVL(ei.org_id,-99)
        AND pe.expenditure_id = ei.expenditure_id;


  rdlrec	   selrdls%ROWTYPE;
  rdlrec1   selrdls1%ROWTYPE; -- added for bug 2580808.
  x_txn_accum_id   NUMBER;
  row_processed    NUMBER;

  BEGIN
    x_txn_accum_id    :=0;
    x_err_code        :=0;
    row_processed     :=0;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage       := 'Accumulating revenue';
       pa_debug.debug('accum_rdls: ' || x_err_stage);
    END IF;

    FOR rdlrec IN selrdls LOOP

	row_processed := row_processed + 1;

-- IF clause added for bug 2580808.
--	IF x_mode <> 'I' THEN    -- for bug 2650900
	  IF (rdlrec.pa_period IS NULL OR rdlrec.gl_period IS NULL) THEN
             OPEN selrdls1(ROWIDTOCHAR(rdlrec.drrowid));
             FETCH selrdls1 INTO rdlrec1;
             CLOSE selrdls1;
          END IF;
--  END IF;    -- for bug 2650900

	create_txn_accum(
	    rdlrec.project_id,
	    rdlrec.task_id,
-- Commented out for bug 2580808
--	    rdlrec.pa_period,
--	    rdlrec.gl_period,
	    NVL(rdlrec.pa_period,rdlrec1.pa_period1), -- added for bug 2580808
	    NVL(rdlrec.gl_period,rdlrec1.gl_period1), -- added for bug 2580808
	    rdlrec.week_ending_date,
	    rdlrec.month_ending_date,
	    rdlrec.person_id,
	    rdlrec.job_id,
	    NULL,                           -- vendor_id
	    rdlrec.expenditure_type,
	    rdlrec.organization_id,
            rdlrec.non_labor_resource,
            rdlrec.non_labor_resource_org_id,
            rdlrec.expenditure_category,
            rdlrec.revenue_category,
            NULL,                           -- event_type
            NULL,                           -- event_type_classification
	    rdlrec.system_linkage_function,
	    'R',                            -- x_line_type = 'R' for RDL
            NULL,                           -- cost_ind_compiled_set_id
            rdlrec.rev_ind_compiled_set_id,
            rdlrec.inv_ind_compiled_set_id,
            NULL,                           -- cmt_ind_compiled_set_id
            x_txn_accum_id,
            x_err_stage,
            x_err_code);

        -- Create a row for drilldown in pa_txn_accum_details Now

        create_txn_accum_details(
            x_txn_accum_id,
            'R',                                -- RDLS
            rdlrec.expenditure_item_id,
            rdlrec.line_num,
            NULL,                               -- Event Num
            NULL,                               -- CMT_LINE_ID
            rdlrec.project_id,
            rdlrec.task_id,
            x_err_stage,
            x_err_code);

        -- Accume this row in txn_accum_id = x_txn_accum_id
        -- also create rows for drilldown

	accum_rev_txn(
	   x_txn_accum_id,
           rdlrec.amount,
           rdlrec.unit_of_measure,
           x_err_stage,
           x_err_code);

        ---  Update the DR.Resource_accumulated_flag = 'Y' Now

	UPDATE
            pa_draft_revenues
	SET
            resource_accumulated_flag = 'S'
	WHERE
            ROWID = rdlrec.drrowid;

    END LOOP;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('accum_rdls: ' || 'Number of RDL Processed = ' || TO_CHAR(row_processed));
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
	x_err_code := SQLCODE;
	RAISE;

  END accum_rdls;

  -- Accumulate revenue from Events

-- Name: Accum_Erdls
--
-- History
--   dd-mmm-1997     Vbanal          Created.
--
--   15-OCT-2001     Jwhite          Modified for the Enhanced Period Processing effort.
--                                   Removed joins to gl_date_period_map and related entities
--                                   and referenced new GL and PA period name columns on erdls
--
--   13-OCT-2002     Sacgupta        Bug # 2580808.
--                                   Modified for the Enhanced Period Processing effort.
--                                   Fetching PA period name and GL period name from gl_date_period_map
--                                   and related entities for inserting into pa_txn_accum table when
--                                   GL and PA period name columns on erdls are null.
--
--   05-NOV-2002     Sacgupta        Bug # 2650900.
--                                   Removed the condition x_mode <> I. So now both Update process and
--                                   Refresh process will fetch PA period name and GL period name from
--                                   gl_date_period_map and related entities for inserting into
--                                   pa_txn_accum table when GL and PA period name columns on erdls are null.
--
--   07-JUL-2004     Sacgupta        Bug # 3736097.
--                                   Commented out all occurence of x_end_project_id.
--                                   This is done because all the processing is done for a
--                                   single project rather than for a range of projects.
--
  PROCEDURE accum_erdls
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
			  x_mode                    IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
                          x_err_code             IN OUT NOCOPY NUMBER)
  IS
P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/



	CURSOR selevents IS
        SELECT
	   dr.ROWID drrowid,
           erdl.event_num event_num,
           erdl.line_num line_num,
	   ev.organization_id organization_id,
           ev.event_type,
           evt.revenue_category_code revenue_category,
           erdl.project_id,
           NVL(erdl.task_id,0) task_id,
	   dr.PA_PERIOD_NAME pa_period,
           dr.GL_PERIOD_NAME gl_period,
	   evt.event_type_classification,
           pa_utils.GetWeekEnding(ev.completion_date) week_ending_date,
	   LAST_DAY(ev.completion_date) month_ending_date,
	   NVL(erdl.amount,0) amount
        FROM
           pa_events ev,
           pa_event_types evt,
           pa_cust_event_rev_dist_lines erdl,
           pa_draft_revenues dr
        WHERE
            dr.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id commented for Bug # 3736097
        AND NVL(dr.resource_accumulated_flag,'S') =
		     DECODE(x_mode,'I','S',
				   'F',NVL(dr.resource_accumulated_flag,'S'),'S')
	AND dr.released_date IS NOT NULL
	AND dr.project_id = erdl.project_id
	AND dr.draft_revenue_num = erdl.draft_revenue_num
	AND erdl.project_id = ev.project_id
	AND NVL(erdl.task_id,0) = NVL(ev.task_id,0)
	AND ev.event_num = erdl.event_num
	AND ev.event_type = evt.event_type
        AND TRUNC(dr.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date;

-- Cursor added for bug 2580808
	CURSOR selevents1 (rrowid  VARCHAR2)IS
        SELECT
           p.period_name pa_period1,
           g.period_name gl_period1
        FROM
       	   gl_date_period_map p,
           gl_date_period_map g,
           pa_events ev,
           pa_event_types evt,
           pa_cust_event_rev_dist_lines erdl,
           pa_draft_revenues dr,
           pa_implementations pi,
           gl_sets_of_books sob
        WHERE
            dr.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id commented for Bug # 3736097
	       AND dr.ROWID = CHARTOROWID(rrowid)
        AND NVL(dr.resource_accumulated_flag,'S') =
		     DECODE(x_mode,'I','S',
				   'F',NVL(dr.resource_accumulated_flag,'S'),'S')
       	AND dr.released_date IS NOT NULL
       	AND dr.project_id = erdl.project_id
       	AND dr.draft_revenue_num = erdl.draft_revenue_num
       	AND erdl.project_id = ev.project_id
       	AND NVL(erdl.task_id,0) = NVL(ev.task_id,0)
       	AND ev.event_num = erdl.event_num
       	AND ev.event_type = evt.event_type
        AND sob.set_of_books_id = pi.set_of_books_id
        AND p.period_set_name = sob.period_set_name
        AND g.period_set_name = sob.period_set_name
        AND p.period_type = pi.pa_period_type
        AND g.period_type = sob.accounted_period_type
        AND p.accounting_date = dr.pa_date
        AND g.accounting_date = NVL(dr.gl_date, dr.pa_date)
        AND TRUNC(dr.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date;


   eventrec	 selevents%ROWTYPE;
   eventrec1	 selevents1%ROWTYPE;  -- for bug 2580808
   x_txn_accum_id NUMBER;
   row_processed  NUMBER;


   BEGIN
    x_txn_accum_id      :=0;
    x_err_code          :=0;
    row_processed       :=0;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    x_err_stage         := 'Accumulating Event Revenue';
       pa_debug.debug('accum_erdls: ' || x_err_stage);
    END IF;

    FOR eventrec IN selevents LOOP

	row_processed := row_processed + 1;

-- IF clause added for bug 2580808.
--	IF x_mode <> 'I' THEN    -- for bug 2650900
	  IF (eventrec.pa_period IS NULL OR eventrec.gl_period IS NULL) THEN
             OPEN selevents1(ROWIDTOCHAR(eventrec.drrowid));
             FETCH selevents1 INTO eventrec1;
             CLOSE selevents1;
          END IF;
--  END IF;    -- for bug 2650900

	create_txn_accum(
	    eventrec.project_id,
            eventrec.task_id,
-- Commented out for bug 2580808
--            eventrec.pa_period,
--	    eventrec.gl_period,
	    NVL(eventrec.pa_period,eventrec1.pa_period1), -- for bug 2580808
	    NVL(eventrec.gl_period,eventrec1.gl_period1), -- for bug 2580808
            eventrec.week_ending_date,
            eventrec.month_ending_date,
	    NULL,                         -- person_id
	    NULL,                         -- job_id
	    NULL,                         -- vendor_id
            NULL,                         -- expenditure_type
            eventrec.organization_id,
            NULL,                         -- non_labor_resource
            NULL,                         -- non_labor_resource_org_id
            NULL,                         -- expenditure_category
	    eventrec.revenue_category,
	    eventrec.event_type,
	    eventrec.event_type_classification,
	    NULL,                         -- system_linkage_function
	    'R',                          -- x_line_type = 'R' for revenue
            NULL,                         -- cost_ind_compiled_set_id
            NULL,                         -- rev_ind_compiled_set_id
            NULL,                         -- inv_ind_compiled_set_id
            NULL,                         -- cmt_ind_compiled_set_id
            x_txn_accum_id,
            x_err_stage,
            x_err_code);

        -- Create a row for drilldown in pa_txn_accum_details Now

        create_txn_accum_details(
            x_txn_accum_id,
            'E',                        -- ERDLS
            NULL,                       -- expenditure_item_id
            eventrec.line_num,
            eventrec.event_num,
            NULL,                       -- cmt_line_id
            eventrec.project_id,
            eventrec.task_id,
            x_err_stage,
            x_err_code);

        -- Accume this row in txn_accum_id = x_txn_accum_id
        -- also create rows for drilldown

	accum_rev_txn(
	   x_txn_accum_id,
           eventrec.amount,
           NULL,		-- Unit_of_measure
           x_err_stage,
           x_err_code);

        --- Update the DR.Resource_accumulated_flag = 'Y' Now

	UPDATE
            pa_draft_revenues
	SET
            resource_accumulated_flag = 'S'
	WHERE
            ROWID = eventrec.drrowid;

    END LOOP;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('accum_erdls: ' || 'Number of Event RDL Processed = ' || TO_CHAR(row_processed));
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
	x_err_code := SQLCODE;
	RAISE;

  END accum_erdls;

  -- The procedure given below should be called to accumulate
  -- revenue

-- Name: Accum_Revenue
--
-- History
--   dd-mmm-1997     Vbanal          Created.
--
--   15-OCT-2001     Jwhite          Modified for the Enhanced Period Processing effort.
--                                   Removed joins to gl_date_period_map and related entities
--                                   and referenced new GL and PA period name columns.
--
--   13-OCT-2002     Sacgupta        Bug # 2580808.
--                                   Modified for the Enhanced Period Processing effort.
--                                   Fetching PA period name and GL period name from gl_date_period_map
--                                   and related entities for inserting into pa_txn_accum table when
--                                   GL and PA period name columns on rdl are null.
--
--   05-NOV-2002     Sacgupta        Bug # 2650900.
--                                   Removed the condition x_mode <> I. So now both Update process and
--                                   Refresh process will fetch PA period name and GL period name from
--                                   gl_date_period_map and related entities for inserting into
--                                   pa_txn_accum table when GL and PA period name columns on rdl are null.
--
--   07-JUL-2004     Sacgupta        Bug # 3736097.
--                                   Commented out all occurence of x_end_project_id.
--                                   This is done because all the processing is done for a
--                                   single project rather than for a range of projects.
--
  PROCEDURE accum_revenue
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
			  x_mode                    IN VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
			  x_err_stage            IN OUT NOCOPY VARCHAR2,
                          x_err_code             IN OUT NOCOPY NUMBER)
         IS
	P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/

	CURSOR selrdls IS
        SELECT
           'R'                                 line_type,
	   dr.ROWID                            drrowid,
           rdl.expenditure_item_id             expenditure_item_id,
           rdl.line_num                        line_num,
           pe.incurred_by_person_id            person_id,
	   ei.job_id                           job_id,
           NVL(ei.override_to_organization_id,
	       pe.incurred_by_organization_id) organization_id,
           et.expenditure_type                 expenditure_type,
           ei.non_labor_resource               non_labor_resource,
           et.expenditure_category             expenditure_category,
	   et.revenue_category_code            revenue_category,
	   ei.organization_id                  non_labor_resource_org_id,
	   ei.system_linkage_function          system_linkage_function,
           dr.project_id                       project_id,
	   ei.task_id                          task_id,
	   dr.PA_PERIOD_NAME pa_period,
           dr.GL_PERIOD_NAME gl_period,
           pe.expenditure_ending_date          week_ending_date,
	   LAST_DAY(ei.expenditure_item_date)  month_ending_date,
	   rdl.rev_ind_compiled_set_id         rev_ind_compiled_set_id,
	   rdl.inv_ind_compiled_set_id         inv_ind_compiled_set_id,
	   NVL(rdl.amount,0)                   amount,
           TO_NUMBER(NULL)                     event_num,
           NULL                                event_type,
           NULL                                event_type_classification,
           et.unit_of_measure                  unit_of_measure
        FROM
	   pa_expenditures_all pe,
           pa_expenditure_types et,
	   pa_expenditure_items_all ei,
           pa_cust_rev_dist_lines rdl,
	   pa_draft_revenues dr
        WHERE
	    dr.project_id = x_start_project_id ---- x_start_project_id and x_end_project_id
        AND NVL(dr.resource_accumulated_flag,'S') =
		     DECODE(x_mode,'I','S',
				   'F',NVL(dr.resource_accumulated_flag,'S'),'S')
	AND dr.released_date IS NOT NULL
	AND rdl.function_code NOT IN ('LRL','LRB','URL','URB')
	AND dr.project_id = rdl.project_id
	AND dr.draft_revenue_num = rdl.draft_revenue_num
	AND rdl.expenditure_item_id = ei.expenditure_item_id
        AND ei.expenditure_type = et.expenditure_type
        AND TRUNC(dr.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date
        AND NVL(pe.org_id,-99) = NVL(ei.org_id,-99)
        AND pe.expenditure_id = ei.expenditure_id
  UNION ALL
        SELECT
           'E'                               line_type,
	   dr.ROWID                          drrowid,
           TO_NUMBER(NULL)                   expenditure_item_id,
           erdl.line_num                     line_num,
           TO_NUMBER(NULL)                   person_id,
           TO_NUMBER(NULL)                   job_id,
	   ev.organization_id                organization_id,
           NULL                              expenditure_type,
           NULL                              non_labor_resource,
           NULL                              expenditure_category,
           evt.revenue_category_code         revenue_category,
           TO_NUMBER(NULL)                   non_labor_resource_org_id,
           NULL                              system_linkage_function,
           erdl.project_id                   project_id,
           NVL(erdl.task_id,0)               task_id,
	   dr.PA_PERIOD_NAME pa_period,
           dr.GL_PERIOD_NAME gl_period,
           pa_utils.GetWeekEnding(ev.completion_date) week_ending_date,
	   LAST_DAY(ev.completion_date)      month_ending_date,
           TO_NUMBER(NULL)                   rev_ind_compiled_set_id,
           TO_NUMBER(NULL)                   inv_ind_compiled_set_id,
	   NVL(erdl.amount,0)                amount,
           erdl.event_num                    event_num,
           ev.event_type                     event_type,
	   evt.event_type_classification     event_type_classification,
           NULL                              unit_of_measure
        FROM
           pa_events ev,
           pa_event_types evt,
           pa_cust_event_rev_dist_lines erdl,
           pa_draft_revenues dr
        WHERE
            dr.project_id = x_start_project_id ---- x_start_project_id and x_end_project_id
        AND NVL(dr.resource_accumulated_flag,'S') =
		     DECODE(x_mode,'I','S',
				   'F',NVL(dr.resource_accumulated_flag,'S'),'S')
	AND dr.released_date IS NOT NULL
	AND dr.project_id = erdl.project_id
	AND dr.draft_revenue_num = erdl.draft_revenue_num
	AND erdl.project_id = ev.project_id
	AND NVL(erdl.task_id,0) = NVL(ev.task_id,0)
	AND ev.event_num = erdl.event_num
	AND ev.event_type = evt.event_type
        AND TRUNC(dr.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date
    ORDER BY 2;

-- Cursor added for bug 2580808
	CURSOR selrdls1 (rrowid  VARCHAR2)IS
        SELECT
           p.period_name pa_period1,
           g.period_name gl_period1
        FROM
	   gl_date_period_map p,
           gl_date_period_map g,
           pa_draft_revenues dr,
           pa_implementations pi,
           gl_sets_of_books sob
        WHERE
            dr.project_id = x_start_project_id
	       AND dr.ROWID = CHARTOROWID(rrowid)
        AND NVL(dr.resource_accumulated_flag,'S') = DECODE(x_mode,'I','S','F',NVL(dr.resource_accumulated_flag,'S'),'S')
       	AND dr.released_date IS NOT NULL
        AND sob.set_of_books_id = pi.set_of_books_id
        AND p.period_set_name = sob.period_set_name
        AND g.period_set_name = sob.period_set_name
        AND p.period_type = pi.pa_period_type
        AND g.period_type = sob.accounted_period_type
        AND p.accounting_date = dr.pa_date
        AND g.accounting_date = NVL(dr.gl_date, dr.pa_date)
        AND TRUNC(dr.pa_date) BETWEEN x_start_pa_date AND x_end_pa_date;


  rdlrec	   selrdls%ROWTYPE;
  rdlrec1   selrdls1%ROWTYPE;  -- for bug 2580808
  x_txn_accum_id   NUMBER;
  row_processed    NUMBER;
  commit_rows      NUMBER;
  curr_rowid        ROWID;

  BEGIN
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	x_err_stage := 'Accumulating All Revenues';
           pa_debug.debug('accum_revenue: ' || x_err_stage);
        END IF;

    x_txn_accum_id    :=0;
    x_err_code        :=0;
    row_processed     :=0;
    commit_rows       :=0;


    FOR rdlrec IN selrdls LOOP
--        pa_debug.debug('Each row, drrowid='||rdlrec.drrowid);
--        pa_debug.debug('Each row, curr_rowid='||curr_rowid);

	row_processed := row_processed + 1;

        IF rdlrec.drrowid <> curr_rowid THEN
--           pa_debug.debug('drrowid='||rdlrec.drrowid);
--           pa_debug.debug('curr_rowid='||curr_rowid);

           --- Update the DR.Resource_accumulated_flag = 'Y' Now
	   UPDATE
              pa_draft_revenues
           SET
              resource_accumulated_flag = 'Y',
              last_updated_by           = x_last_updated_by,
              last_update_login         = x_last_update_login,
              request_id                = x_request_id,
              program_application_id    = x_program_application_id,
              program_id                = x_program_id
           WHERE
              ROWID = curr_rowid;

           IF commit_rows >= pa_proj_accum_main.x_commit_size THEN
              COMMIT;
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('accum_revenue: ' || 'Number of Records Commited = '|| TO_CHAR(commit_rows));
              END IF;
              commit_rows := 0;
           END IF;
        END IF;

        curr_rowid    := rdlrec.drrowid;
        commit_rows := commit_rows + 1;

-- IF clause added for bug 2580808.
--	IF x_mode <> 'I' THEN     -- for bug 2650900
	  IF (rdlrec.pa_period IS NULL OR rdlrec.gl_period IS NULL) THEN
             OPEN selrdls1(ROWIDTOCHAR(rdlrec.drrowid));
             FETCH selrdls1 INTO rdlrec1;
             CLOSE selrdls1;
          END IF;
--  END IF;    -- for bug 2650900

	create_txn_accum(
	    rdlrec.project_id,
	    rdlrec.task_id,
	    -- Commented out for 2580808
--	    rdlrec.pa_period,
--	    rdlrec.gl_period,
	    NVL(rdlrec.pa_period,rdlrec1.pa_period1), -- added for bug 2580808
	    NVL(rdlrec.gl_period,rdlrec1.gl_period1), --added for bug 2580808
	    rdlrec.week_ending_date,
	    rdlrec.month_ending_date,
	    rdlrec.person_id,
	    rdlrec.job_id,
	    NULL,                           -- vendor_id
	    rdlrec.expenditure_type,
	    rdlrec.organization_id,
            rdlrec.non_labor_resource,
            rdlrec.non_labor_resource_org_id,
            rdlrec.expenditure_category,
            rdlrec.revenue_category,
            rdlrec.event_type,              -- event_type
            rdlrec.event_type_classification,      -- event_type_classification
	    rdlrec.system_linkage_function,
	    rdlrec.line_type,                            -- x_line_type = 'R' for RDL
            NULL,                           -- cost_ind_compiled_set_id
            rdlrec.rev_ind_compiled_set_id,
            rdlrec.inv_ind_compiled_set_id,
            NULL,                           -- cmt_ind_compiled_set_id
            x_txn_accum_id,
            x_err_stage,
            x_err_code);

        -- Create a row for drilldown in pa_txn_accum_details Now

        create_txn_accum_details(
            x_txn_accum_id,
            rdlrec.line_type,                          -- RDLS
            rdlrec.expenditure_item_id,
            rdlrec.line_num,
            rdlrec.event_num,                   -- Event Num
            NULL,                               -- CMT_LINE_ID
            rdlrec.project_id,
            rdlrec.task_id,
            x_err_stage,
            x_err_code);

        -- Accume this row in txn_accum_id = x_txn_accum_id
        -- also create rows for drilldown

	accum_rev_txn(
	   x_txn_accum_id,
           rdlrec.amount,
           rdlrec.unit_of_measure,
           x_err_stage,
           x_err_code);

    END LOOP;

    --- Update the DR.Resource_accumulated_flag = 'Y' Now
    UPDATE
        pa_draft_revenues
    SET
        resource_accumulated_flag = 'Y',
        last_updated_by           = x_last_updated_by,
        last_update_login         = x_last_update_login,
        request_id                = x_request_id,
        program_application_id    = x_program_application_id,
        program_id                = x_program_id
    WHERE
        ROWID = curr_rowid;

    COMMIT;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('accum_revenue: ' || 'Number of Draft Revenues Processed = '||TO_CHAR(row_processed));
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
	x_err_code := SQLCODE;
	RAISE;

  END accum_revenue;

  -- Procedure to accumulate the commitments
  -- The pa_period and the gl_period parameter are not passed to
  -- this routine, since the commitments are always accumulated
  -- in the current pa_period and gl_period


-- Name:		Accum_Commitments
--
-- History
--
--
--	12-FEB-99	jwhite	For the accum_commitments procedure, added
--				MC related design elements.
--				Numerous changes were made to the procedure.
--
--	04-MAR-99	jwhite	Implemented latest design changes:
--				1) Removed all references to amount_delivered columns.
--			        2) Added generation_error_flag to Update
--                                 pa_project_accum_headers
--				3) Removed pa_debug design elements.
--
--    03-DEC-2001        jwhite Bug 2119738
--                              The parameter list for the following was changed:
--                              pa_multi_currency_txn.get_currency_amounts. This change
--                              was not communicated to the Reporting team.  System
--                              testing revealed this oversight.
--

  PROCEDURE accum_commitments
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_system_linkage_function IN  VARCHAR2, -- Default value removed to avoid GSCC warning File.Pkg.22
                          x_err_stage            IN OUT NOCOPY VARCHAR2,
                          x_err_code             IN OUT NOCOPY NUMBER)
 IS
P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');/*Added the default profile option variable initialization for bug 2674619*/
--
-- Cursors  ---------------------------------------------------
--
	-- The cursor selcmts selects all PA_COMMITMENT_TXNS which
	-- satisfy the given parameters

	CURSOR selcmts IS
        SELECT
	     pct.cmt_line_id,
             pct.project_id,
             pct.task_id,
             pa_utils.GetWeekEnding(pct.expenditure_item_date) week_ending_date,
	     LAST_DAY(pct.expenditure_item_date) month_ending_date,
             pct.pa_period,
             pct.gl_period,
             pct.organization_id,
             pct.vendor_id,
             pct.expenditure_type,
             pct.expenditure_category,
             pct.revenue_category,
             pct.system_linkage_function,
             pct.cmt_ind_compiled_set_id,
             pct.expenditure_item_date,
             pct.denom_currency_code,
             pct.denom_raw_cost,
             pct.denom_burdened_cost,
             pct.acct_currency_code,
             pct.acct_rate_date,
             pct.acct_rate_type,
             pct.acct_exchange_rate,
             pct.acct_raw_cost,
             pct.acct_burdened_cost,
             pct.receipt_currency_code,
             pct.receipt_currency_amount,
             pct.receipt_exchange_rate
        FROM
	     pa_commitment_txns pct
--  Bug#2634995 - removed the reference to pa_implentations as it is not used in  the SQL
--		 ,pa_implementations pi
        WHERE
	    pct.project_id = x_start_project_id  -- BETWEEN x_start_project_id AND x_end_project_id commented for bug 3736097
        AND pct.system_linkage_function||'' =
	          NVL(x_system_linkage_function,pct.system_linkage_function);

--  This cursor retrives the Project Currency Code for the project.
/* Bug# 2158736 - Included projfunc_currency_code in the cursor */

        CURSOR	l_project_curr_code_csr
		(l_project_id pa_projects.project_id%TYPE)
        IS
        SELECT 	project_currency_code,projfunc_currency_code
        FROM	pa_projects p
        WHERE	p.project_id = l_project_id;


--
-- Local Variables -------------------------------------------
--

-- Procedure Variables
  l_proj_curr_OK              VARCHAR2(1) := 'Y';
  l_project_curr_code	      pa_projects.project_currency_code%TYPE   := NULL;
  l_sum_exception_code        pa_project_accum_headers.sum_exception_code%TYPE := NULL;


--  Main LOOP Variables
  cmtrec	        selcmts%ROWTYPE;
  x_txn_accum_id        NUMBER;
  row_processed         NUMBER;
  l_cmtrec_curr_OK      VARCHAR2(1);
  l_cmt_rejection_code	pa_commitment_txns.cmt_rejection_code%TYPE;
  l_err_msg             VARCHAR2(2000);

-- Client Extension API Variables
  l_Project_Rate_Type	      pa_commitment_txns.project_rate_type%TYPE;
  l_Project_Rate_Date	      DATE;
  l_project_exch_rate	      NUMBER;
  l_Num_Rate	              NUMBER;
  l_Denom_Rate	              NUMBER;
  l_Converted_Amount	      NUMBER;
  l_Msg_Application           fnd_application.application_short_name%TYPE;
  l_Msg_Data                  pa_commitment_txns.cmt_rejection_code%TYPE;
  l_Msg_Count		      NUMBER;

-- Multicurrency API Variables
  l_amount_out		      NUMBER;
  l_tot_cmt_raw_cost          NUMBER;
  l_tot_cmt_burdened_cost     NUMBER;
  l_status		      VARCHAR2(200) := NULL;
  l_stage		      NUMBER  := NULL;

-- Bug 2119738: New Parameters
  l_SYSTEM_LINKAGE            pa_expenditure_items_all.SYSTEM_LINKAGE_FUNCTION%TYPE :=NULL;
  l_PROJECT_RAW_COST          NUMBER := NULL;
  l_PROJFUNC_CURR_CODE        pa_projects.project_currency_code%TYPE     := NULL;
  l_PROJFUNC_COST_RATE_TYPE   pa_commitment_txns.project_rate_type%TYPE  := NULL;
  l_PROJFUNC_COST_RATE_DATE   DATE  := NULL;
  l_PROJFUNC_COST_EXCH_RATE   NUMBER :=  NULL;

-- added for FP.M
  l_PROJECT_BURDENED_COST	NUMBER := NULL;

  BEGIN

     x_txn_accum_id    :=0;
     x_err_code        :=0;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     x_err_stage       := 'Accumulating Commitments';
     row_processed     :=0;
        pa_debug.debug('accum_commitments: ' || x_err_stage);
     END IF;


-- Get Project Currency Code for Project

/* Bug# 2158736 - Included project functional currency code in the fetch */

     OPEN l_project_curr_code_csr(x_start_project_id);
     FETCH l_project_curr_code_csr INTO l_project_curr_code,l_projfunc_curr_code;
     CLOSE l_project_curr_code_csr;

     FOR cmtrec IN selcmts LOOP

	row_processed := row_processed + 1;

-- Initialize Cmtrec Local Variables

        l_cmtrec_curr_OK        := 'Y';
        l_project_Rate_Type     := NULL;
        /* Bug 8416706  Start Resetting the values*/
--        l_project_Rate_Date     := cmtrec.expenditure_item_date;
        l_project_Rate_Date     := NULL; -- Issue 1
        l_PROJFUNC_COST_RATE_TYPE := NULL;  -- Issue 2
        l_PROJFUNC_COST_RATE_DATE := NULL;  -- Issue 2
        l_PROJFUNC_COST_EXCH_RATE :=  NULL;  -- Issue 2
        /* Bug 8416706  End */
        l_project_exch_rate     := NULL;
        l_Num_Rate	        := NULL;
        l_Denom_Rate	        := NULL;
        l_Converted_Amount      := NULL;
        l_Msg_Application       := NULL;
        l_Msg_Data              := NULL;
        l_Msg_Count             := NULL;
        l_amount_out            := NULL;
        l_tot_cmt_raw_cost      := NULL;
	l_tot_cmt_burdened_cost := NULL;
        l_status		:= NULL;
        l_stage                 := NULL;
        l_cmt_rejection_code    := NULL;
        l_err_msg               := NULL;


	create_txn_accum(
	    cmtrec.project_id,
	    cmtrec.task_id,
	    cmtrec.pa_period,
	    cmtrec.gl_period,
	    cmtrec.week_ending_date,
	    cmtrec.month_ending_date,
	    NULL,                         -- person_id
	    NULL,                         -- Job_id
	    cmtrec.vendor_id,
	    cmtrec.expenditure_type,
	    cmtrec.organization_id,
	    NULL,                         -- non_labor_resource
	    NULL,                         -- non_labor_resource_org_id
	    cmtrec.expenditure_category,
	    cmtrec.revenue_category,
	    NULL,                           -- event_type
	    NULL,                           -- event_type_classification
	    cmtrec.system_linkage_function,
	    'M',                            -- x_line_type = 'M' for commitments
	    NULL,                           -- cost_ind_compiled_set_id
	    NULL,                           -- rev_ind_compiled_set_id
	    NULL,                           -- inv_ind_compiled_set_id
	    cmtrec.cmt_ind_compiled_set_id,
	    x_txn_accum_id,
	    x_err_stage,
	    x_err_code);

        -- Create a row for drilldown in pa_txn_accume_details Now

        create_txn_accum_details(
            x_txn_accum_id,
	    'M',                                -- pa_commitments_txns
	    NULL,                               -- expenditure_item_id
            NULL,                               -- line_num
	    NULL,                               -- event_num
	    cmtrec.cmt_line_id,
	    cmtrec.project_id,
	    cmtrec.task_id,
	    x_err_stage,
	    x_err_code);


--
-- VALIDATION Currency Business Rules ------------
--
--     Go Here!
--
--     Set l_cmtrec_curr_OK to 'N' if any one of the rules are
--     violated.
--


--
-- PROJECT COLUMN DERIVATION  --------------------
--

     IF (l_cmtrec_curr_OK = 'Y')
      THEN


-- RAW COST Derivation

      IF (l_cmtrec_curr_OK = 'Y')
        THEN

         pa_multi_currency_txn.get_currency_amounts
		(p_project_curr_code            => l_project_curr_code
                 , p_ei_date                    => cmtrec.expenditure_item_date
                 , p_task_id 		        => cmtrec.task_id
                 , p_denom_raw_cost	        => cmtrec.denom_raw_cost
                 , p_denom_curr_code            => cmtrec.denom_currency_code
                 , p_acct_curr_code	        => cmtrec.acct_currency_code
                 , p_accounted_flag              => 'Y'                           /* Bug 1642321 manokuma */
               	 , p_acct_rate_date             => cmtrec.acct_rate_date
                 , p_acct_rate_type             => cmtrec.acct_rate_type
                 , p_acct_exch_rate             => cmtrec.acct_exchange_rate
                 , p_acct_raw_cost              => cmtrec.acct_raw_cost
                 , p_project_rate_type          => l_project_rate_type
                 , p_project_rate_date          => l_project_rate_date
                 , p_project_exch_rate          => l_project_exch_rate
                 , P_PROJFUNC_RAW_COST          => l_amount_out
                 , p_status                     => l_status
                 , p_stage                      => l_stage
                 , P_SYSTEM_LINKAGE             => l_SYSTEM_LINKAGE
                 , P_PROJECT_RAW_COST           => l_PROJECT_RAW_COST
                 , P_PROJFUNC_CURR_CODE         => l_PROJFUNC_CURR_CODE
                 , P_PROJFUNC_COST_RATE_TYPE    => l_PROJFUNC_COST_RATE_TYPE
                 , P_PROJFUNC_COST_RATE_DATE    => l_PROJFUNC_COST_RATE_DATE
                 , P_PROJFUNC_COST_EXCH_RATE    => l_PROJFUNC_COST_EXCH_RATE
		);

          l_tot_cmt_raw_cost := l_amount_out;

	  IF (l_status IS NOT NULL)             -- Error returned
            THEN

              l_cmt_rejection_code    := l_status;
	      l_cmtrec_curr_OK        := 'N';

          END IF; --(l_status IS NOT NULL)

      END IF; --RAW COST

-- BURDENED COST Derivation

      IF (l_cmtrec_curr_OK = 'Y')
        THEN

	 pa_multi_currency_txn.get_currency_amounts
		(p_project_curr_code            => l_project_curr_code
                 , p_ei_date                    => cmtrec.expenditure_item_date
                 , p_task_id 		        => cmtrec.task_id
                 , p_denom_raw_cost	        => cmtrec.denom_burdened_cost
                 , p_denom_curr_code            => cmtrec.denom_currency_code
                 , p_acct_curr_code	        => cmtrec.acct_currency_code
                 , p_accounted_flag             => 'Y'                          /* Bug 1642321 manokuma */
               	 , p_acct_rate_date             => cmtrec.acct_rate_date
                 , p_acct_rate_type             => cmtrec.acct_rate_type
                 , p_acct_exch_rate             => cmtrec.acct_exchange_rate
                 , p_acct_raw_cost              => cmtrec.acct_burdened_cost
                 , p_project_rate_type          => l_project_rate_type
                 , p_project_rate_date          => l_project_rate_date
                 , p_project_exch_rate          => l_project_exch_rate
                 , P_PROJFUNC_RAW_COST          => l_amount_out
                 , p_status                     => l_status
                 , p_stage                      => l_stage
                 , P_SYSTEM_LINKAGE             => l_SYSTEM_LINKAGE
                 , P_PROJECT_RAW_COST           => l_PROJECT_BURDENED_COST   /*l_PROJECT_RAW_COST  bug   9076987*/
                 , P_PROJFUNC_CURR_CODE         => l_PROJFUNC_CURR_CODE
                 , P_PROJFUNC_COST_RATE_TYPE    => l_PROJFUNC_COST_RATE_TYPE
                 , P_PROJFUNC_COST_RATE_DATE    => l_PROJFUNC_COST_RATE_DATE
                 , P_PROJFUNC_COST_EXCH_RATE    => l_PROJFUNC_COST_EXCH_RATE
		);

          l_tot_cmt_burdened_cost := l_amount_out;

	-- added for FP.M
	--  l_PROJECT_BURDENED_COST := l_PROJECT_RAW_COST;   Commented for bug   9076987

	  IF (l_status IS NOT NULL)             -- Error returned
            THEN

              l_cmt_rejection_code    := l_status;
	      l_cmtrec_curr_OK        := 'N';

          END IF; --(l_status IS NOT NULL)

      END IF; --BURDENED COST

    END IF; -- DERIVATION SUBsection

--
-- UPDATE COMMITMENT ROW -------------------------------
--

     IF (l_cmtrec_curr_OK = 'Y')
      THEN
           UPDATE pa_commitment_txns
           SET tot_cmt_raw_cost     = l_tot_cmt_raw_cost
           , tot_cmt_burdened_cost  = l_tot_cmt_burdened_cost
           , project_currency_code  = l_project_curr_code
           , project_rate_date      = l_project_rate_date
           , project_rate_type      = l_project_rate_type
           , project_exchange_rate  = l_project_exch_rate
	   , proj_raw_cost       = l_PROJECT_RAW_COST  /* added for FP.M proj_raw_cost stores raw cost in project currency */
	   , proj_burdened_cost  = l_PROJECT_BURDENED_COST  /* added for FP.M proj_burdened_cost stores burdened cost in project currency */
           WHERE cmt_line_id = cmtrec.cmt_line_id;

      ELSE

           UPDATE pa_commitment_txns
           SET generation_error_flag = 'Y'
           , cmt_rejection_code = l_cmt_rejection_code
           WHERE cmt_line_id = cmtrec.cmt_line_id;

           l_proj_curr_OK := 'N';

     END IF; -- UPDATE COMMITMENT ROW


-- Accume this row now for txn_accum_id = x_txn_accum_id
-- also create rows for drilldown

	accum_cmt_txn(
	   x_txn_accum_id,
	   l_tot_cmt_raw_cost,
	   l_tot_cmt_burdened_cost,
	   x_err_stage,
	   x_err_code);

     END LOOP; -- CMTREC Processing

   COMMIT;
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('accum_commitments: ' || 'Number of Commitments Processed = ' || TO_CHAR(row_processed));
     END IF;

--
-- UPDATE PROJECT LOCKROW to Record Exception, If Any  -----------
--

     IF (l_proj_curr_OK = 'Y')
      THEN
          l_sum_exception_code := NULL;
      ELSE
          l_sum_exception_code := 'PA_SUM_CMT_REJECTIONS';
     END IF;

     UPDATE pa_project_accum_headers
     SET sum_exception_code = l_sum_exception_code
     WHERE project_id              = x_start_project_id
     AND   task_id                 = 0
     AND   resource_list_id        = 0
     AND   resource_list_member_id = 0;



     EXCEPTION
       WHEN OTHERS THEN
	x_err_code := SQLCODE;
	RAISE;

  END accum_commitments;

END PA_TXN_ACCUMS;

/
