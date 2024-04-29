--------------------------------------------------------
--  DDL for Package Body PA_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING" AS
/* $Header: PAXIBILB.pls 120.7.12010000.12 2010/04/30 15:51:53 rmandali ship $ */

/* MCB related changes */

/* ATG changes :   Added the format mask YYYY/MM/DD for the to_date conversion function */

FUNCTION GetPADate RETURN DATE
IS
BEGIN
   RETURN ( TO_DATE(GlobVars.PaDate, 'YYYY/MM/DD') );
END;

FUNCTION GetInvoiceDate RETURN DATE
IS
BEGIN
  RETURN ( TO_DATE(GlobVars.InvoiceDate, 'YYYY/MM/DD') );
END;

FUNCTION GetBillingAssignmentId RETURN NUMBER
IS
BEGIN
  RETURN ( GlobVars.BillingAssignmentId );
END;
/* Till Here */

/* Start EPP Changes on 27-Dec-2001 */
FUNCTION GetGlDate RETURN DATE
IS
BEGIN
   RETURN ( TO_DATE(GlobVars.GlDate, 'YYYY/MM/DD') );
END;
FUNCTION GetGlPeriodname RETURN VARCHAR2
IS
BEGIN
   RETURN ( GlobVars.GlPeriodName );
END;
FUNCTION GetPaPeriodname RETURN VARCHAR2
IS
BEGIN
   RETURN ( GlobVars.PaPeriodName );
END;

/* End of  EPP Changes on 27-Dec-2001 */

/* Begin Retention Enhancements Changes on 28-mar-2002 */

 FUNCTION  GetBillThruDate RETURN VARCHAR2
 IS
 BEGIN
   RETURN ( GlobVars.BillThruDate);
 END;

/* End Retention Enhancements Changes on 28-mar-2002 */


FUNCTION GetReqId RETURN NUMBER
IS
BEGIN
  RETURN ( GlobVars.ReqId );
END;

FUNCTION GetProjId RETURN NUMBER
IS
BEGIN
  RETURN ( GlobVars.ProjectId );
END;

PROCEDURE  SetProjId (x_project_id      IN      NUMBER) /* Added procedure for bug 7606086 */
IS
BEGIN
  GlobVars.ProjectId := x_project_id;
END;

FUNCTION GetTaskId RETURN NUMBER
IS
BEGIN
  RETURN ( GlobVars.TaskId );
END;

FUNCTION GetCallPlace RETURN VARCHAR2
IS
BEGIN
  RETURN ( GlobVars.CallingPlace );
END;

FUNCTION GetCallProcess RETURN VARCHAR2
IS
BEGIN
  RETURN ( GlobVars.CallingProcess );
END;

FUNCTION GetMassGen RETURN VARCHAR2
IS
BEGIN
  RETURN ( GlobVars.MassGenFlag );
END;

FUNCTION GetBillingExtensionId RETURN NUMBER
IS
BEGIN
  RETURN ( GlobVars.BillingExtensionId );
END;

procedure SetMassGen (x_Massgenflag VARCHAR2) is
BEGIN
       GlobVars.MassGenFlag := x_Massgenflag ;
END;

/* Start of Changes for BUG 8666892 */

FUNCTION  GetInvoiceNZ  RETURN VARCHAR2
IS
l_org_id	NUMBER(15);
BEGIN
	SELECT	NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99)
	INTO	l_org_id
	FROM	DUAL;

	   IF (G_ORG_ID is NULL or
	       G_ORG_ID <> l_org_id) THEN
		SELECT	NVL(INVOICE_NZ_LINES,'N')
		INTO	G_INV_NZ_LINES
		FROM	PA_IMPLEMENTATIONS;

		g_org_id := l_org_id;
	   END IF;

   RETURN(G_INV_NZ_LINES);

END;
/* End of Changes for BUG 8666892 */

procedure bill_ext_driver
		( x_project_id        IN     NUMBER,
                  x_calling_process   IN     VARCHAR2,
                  x_calling_place     IN     VARCHAR2,
                  x_rev_or_bill_date  IN     VARCHAR2,
                  x_request_id        IN     NUMBER,
                  x_error_message     IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
  c              INTEGER;
  row_processed  INTEGER;
  proc_stmt      VARCHAR2(1000);
  l_project_type pa_projects_all.project_type%type;
  l_distribution_rule pa_projects_all.distribution_rule%type;
  cursor get_procedure is
    select be.procedure_name proc_name, bea.billing_assignment_id bea_id,
           bea.billing_extension_id be_id, bea.top_task_id task_id,
           decode(be.amount_reqd_flag, 'Y', nvl(bea.amount, 0), 0) amt,
           decode(be.percentage_reqd_flag, 'Y', nvl(bea.percentage, 0), 0)
           percent
    from   pa_billing_extensions be, pa_billing_assignments bea -- , Commented for bug 3643409
--           pa_projects p Commented for bug 3643409
    where  -- p.project_id = x_project_id Commented for bug 3643409
--    and    Commented for bug 3643409
           to_date(x_rev_or_bill_date,'YYYY/MM/DD') between be.start_date_active and nvl(be.end_date_active,to_date(x_rev_or_bill_date,'YYYY/MM/DD'))  --Added the condition for bug 8206153, added nvl for bug 8228460
    and	   bea.active_flag = 'Y'
    and    bea.billing_extension_id = be.billing_extension_id
    and    (be.calling_process  = x_calling_process
	    or be.calling_process = 'Both')
    and    (bea.project_id  = X_project_id
	    or    bea.project_type  = l_project_type
    	    or bea.distribution_rule  = l_distribution_rule)
	    -- Added above two lines for bug 3643409
--    	    or    bea.project_type  = p.project_type Commented for bug 3643409
--    	    or bea.distribution_rule  = p.distribution_rule) Commented for bug 3643409
    and
    (
       ( x_calling_place = 'PRE'    and nvl(be.pre_processing_flag,'N') = 'Y')
    or ( x_calling_place = 'POST'   and nvl(be.post_processing_flag,'N')= 'Y')
    or ( x_calling_place = 'DEL'    and nvl(be.call_before_del_flag,'N')= 'Y')
    or ( x_calling_place = 'CANCEL' and nvl(be.call_after_cancel_inv_flag,'N')= 'Y')
    or ( x_calling_place = 'WRITE-OFF'   and nvl(be.call_after_woff_inv_flag,'N')= 'Y')
    or ( x_calling_place = 'CONCESSION'   and nvl(be.call_after_concession_inv_flag,'N')= 'Y')  -- Added this line for Concession Invoice
    or
     (
       ( x_calling_place = 'ADJ' and nvl(be.call_after_adj_flag,'N')= 'Y')
       or ( x_calling_place = 'REG' and nvl(be.call_after_reg_flag,'N')= 'Y')
       or ( x_calling_place = 'POST-REG' and nvl(be.call_post_reg_flag,'N')= 'Y')
       and
          (   nvl(be.trx_independent_flag, 'N') = 'Y'
    	    or
	   (    x_calling_process in ('Invoice','Both')
    		AND   EXISTS
		     (select NULL from pa_draft_invoices pdi
        	     where pdi.project_id = x_project_id
	             and   pdi.request_id = x_request_id
--	 	     and   pdi.invoice_line_type <> 'NET ZERO ADJUSTMENT'
    		     and   ((   x_calling_place = 'ADJ'
 		           and pdi.draft_invoice_num_credited is not null)
		           OR
	   	           (   x_calling_place IN ('REG' , 'POST-REG')
		           and pdi.draft_invoice_num_credited IS NULL)))
           )
	    or
	   (    x_calling_process in ('Revenue','Both')
    		AND   EXISTS
		     (select NULL from pa_draft_revenues pdr
        	     where pdr.project_id = x_project_id
	             and   pdr.request_id = x_request_id
    		     and   ((   x_calling_place = 'ADJ'
 		           and pdr.draft_revenue_num_credited is not null)
		           OR
	   	           (   x_calling_place IN ('REG','POST-REG')
		           and pdr.draft_revenue_num_credited IS NULL)))
           )
         )
      )
    )
    order by be.processing_order, bea.billing_assignment_id;

fund_level 	VARCHAR2(10) := NULL;
NO_FUNDING	EXCEPTION;

CURSOR each_task (X2_task_id NUMBER) IS
	SELECT	distinct
		decode(fund_level,
			'PROJECT', decode(X2_task_id, NULL, NULL, X2_task_id),
			'TASK',	   t.top_task_id,
			 t.top_task_id) tpid
	FROM	pa_tasks t
	WHERE	t.project_id = X_project_id
	AND	t.task_id = nvl(X2_task_id, t.task_id)
        AND     t.ready_to_distribute_flag =
                  decode(x_calling_process, 'Revenue', 'Y', 'Both', 'Y',
                                t.ready_to_distribute_flag)
        AND     t.ready_to_bill_flag =
                  decode(x_calling_process, 'Invoice', 'Y', 'Both', 'Y',
                                t.ready_to_bill_flag);

task_rec	each_task%ROWTYPE;

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.bill_ext_driver  :');
END IF;
GlobVars.ProjectId 	:= x_project_id;
GlobVars.ReqId          := x_request_id;
GlobVars.CallingPlace   := x_calling_place;
GlobVars.CallingProcess := x_calling_process;
GlobVars.AccrueThruDate := x_rev_or_bill_date;
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver project id :'||to_char(GlobVars.ProjectId));
	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver  Request id :'||to_char(GlobVars.ReqId));
	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver  Calling place :'||GlobVars.CallingPlace);
	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver  calling process :'||GlobVars.CallingProcess);
	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver  accru thru date :'||GlobVars.AccrueThruDate);
END IF;

-- DBMS_OUTPUT.ENABLE(1000000);
  fund_level := pa_billing_values.funding_level(X_project_id);
  x_error_message := 'Error during opening the dbms_sql cursor.';
  c := dbms_sql.open_cursor;

  x_error_message := 'Error during fetching the get_procedure cursor.';

/* Added below select statement for bug 3643409 */
SELECT	project_type,distribution_rule
INTO	l_project_type,l_distribution_rule
FROM	pa_projects_all
WHERE	project_id = x_project_id;

  FOR get_rec IN get_procedure LOOP
    -- Loop for each assigned Billing Extension

    BEGIN

      x_error_message := 'Error while setting up proc_stmt.';
      FOR task_rec IN each_task(get_rec.task_id) LOOP

	-- Loop for each task level execution (in case of task funding)
	BEGIN

	GlobVars.BillingExtensionId 	:= get_rec.be_id;
	GlobVars.BillingAssignmentId 	:= get_rec.bea_id;
	GlobVars.TaskId			:= task_rec.tpid;


/* ATG changes :   Added the format mask YYYY/MM/DD for the to_date conversion function */


/* Commented for bug 3560805
	IF (task_rec.tpid IS NULL) THEN
            -- This will be the case for Project Level funding and Project
	    -- Level assignment.
           -- Do not have to change this stmt for MCB, because user is going to select from the
           --   view pa_billing_extn_params_v ( all the newly added columns in pa_billing_assignments table)

            proc_stmt := 'declare s varchar2(240):=null; begin ' ||
            get_rec.proc_name || '(' || to_char(x_project_id) ||
            ','''',''' || x_calling_process ||
            ''',''' || x_calling_place || ''',fnd_number.canonical_to_number('''
           || fnd_number.number_to_canonical(get_rec.amt) ||
            '''),fnd_number.canonical_to_number(''' ||
        fnd_number.number_to_canonical(get_rec.percent) || '''), to_date(''' ||
            x_rev_or_bill_date || ''', , ''' || 'YYYY/MM/DD' ||'''),' || to_char(get_rec.bea_id) || ',' ||
            to_char(get_rec.be_id) || ',' || to_char(x_request_id) ||
	    '); end;';
	ELSE
	    -- This will be the case for either Task Level assignment
	    -- (one iteration) or task level funding and project level
	    -- assignment (one iteration per top task)

            proc_stmt := 'declare s varchar2(240):=null; begin ' ||
            get_rec.proc_name || '(' || to_char(x_project_id) ||
            ',' || task_rec.tpid || ',''' || x_calling_process ||
            ''',''' || x_calling_place || ''',fnd_number.canonical_to_number('''
           || fnd_number.number_to_canonical(get_rec.amt) ||
            '''),fnd_number.canonical_to_number(''' ||
         fnd_number.number_to_canonical(get_rec.percent) || '''), to_date(''' ||
            x_rev_or_bill_date || ''', ''' || 'YYYY/MM/DD' ||'''),' || to_char(get_rec.bea_id) || ',' ||
            to_char(get_rec.be_id) || ',' || to_char(x_request_id) ||
            '); end;';
	END IF; */

	proc_stmt := 'declare s varchar2(240):=null; begin ' ||
            get_rec.proc_name || '(:project_id,:task_id,:calling_process,:calling_place,
	    :amt,:percent,:rev_or_bill_date,:bea_id,:be_id,:request_id); end;'; 	/* Added for 3560805*/

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver: before executing building the Pl/Sql block  :'||proc_stmt);
END IF;
        x_error_message := 'Error during parsing the dynamic PL/SQL.';
        dbms_sql.parse(c, proc_stmt, dbms_sql.native);

	/* Start of 3560805*/

        /* Release 12 : ATG changes :  Added the date format for the variable x_rev_or_bill_date */

	DBMS_SQL.BIND_VARIABLE(c, ':project_id', x_project_id);
	DBMS_SQL.BIND_VARIABLE(c, ':task_id', task_rec.tpid);
	DBMS_SQL.BIND_VARIABLE(c, ':calling_process',x_calling_process);
	DBMS_SQL.BIND_VARIABLE(c, ':calling_place',x_calling_place);
	DBMS_SQL.BIND_VARIABLE(c, ':amt',fnd_number.number_to_canonical(get_rec.amt));
	DBMS_SQL.BIND_VARIABLE(c, ':percent',fnd_number.number_to_canonical(get_rec.percent));
	DBMS_SQL.BIND_VARIABLE(c, ':rev_or_bill_date',TO_DATE(x_rev_or_bill_date,'YYYY/MM/DD'));
	DBMS_SQL.BIND_VARIABLE(c, ':bea_id',get_rec.bea_id);
	DBMS_SQL.BIND_VARIABLE(c, ':be_id',get_rec.be_id);
	DBMS_SQL.BIND_VARIABLE(c, ':request_id',x_request_id);

	/* End of 3560805*/

        x_error_message := 'Error during executing the dynamic PL/SQL.';
        row_processed := dbms_sql.execute(c);


      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver: After building the Pl/Sql block  :');
      END IF;
      EXCEPTION
        WHEN NO_FUNDING THEN
        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver: Inside the error :');
        END IF;
	   X_error_message := 'There is no funding';
--         DBMS_OUTPUT.PUT_LINE(SQLERRM);
        WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE(SQLERRM);
           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('pa_billing.bill_ext_driver: Inside the others error :');
           END IF;
           dbms_sql.close_cursor(c);
           RAISE;
      END;

      END LOOP;

      END;

  END LOOP;

  x_error_message := 'Error during closing the dbms_sql cursor.';
  dbms_sql.close_cursor(c);
  if x_error_message = 'Error during closing the dbms_sql cursor.' then
    x_error_message := 'OK';
  end if;

  IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('Exiting from pa_billing.bill_ext_driver  :');
  END IF;
  EXCEPTION
	WHEN OTHERS THEN
--              DBMS_OUTPUT.PUT_LINE(SQLERRM);
  IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('Inside main others error pa_billing.bill_ext_driver  :');
  END IF;
		RAISE;
end bill_ext_driver;



PROCEDURE ccrev(	X_project_id               IN     NUMBER,
	             	X_top_task_id              IN     NUMBER   DEFAULT NULL,
                     	X_calling_process          IN     VARCHAR2 DEFAULT NULL,
                     	X_calling_place            IN     VARCHAR2 DEFAULT NULL,
                     	X_amount                   IN     NUMBER DEFAULT NULL,
                     	X_percentage               IN     NUMBER DEFAULT NULL,
                     	X_rev_or_bill_date         IN     DATE   DEFAULT NULL,
                     	X_billing_assignment_id    IN     NUMBER DEFAULT NULL,
                     	X_billing_extension_id     IN     NUMBER DEFAULT NULL,
                     	X_request_id               IN     NUMBER DEFAULT NULL
                   ) IS


g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

budget_revenue REAL := 0;
budget_cost    REAL := 0;
invoice_amount REAL := 0;
revenue_amount REAL := 0;
event_revenue REAL := 0;
event_invoice REAL := 0;
cost_amount REAL := 0;
revenue	REAL := 0;
invoice REAL := 0;
Amount_Left REAL := 0;

event_description	VARCHAR2(240);
--
-- The cost and revenue budget type codes used by the pa_billing_pub.get_budget_amount procedure
--
l_cost_budget_type_code VARCHAR2(30);
l_rev_budget_type_code  VARCHAR2(30);
l_currency_code         VARCHAR2(15);

l_status		NUMBER;
l_error_message 	VARCHAR2(240);

ccrev_error		EXCEPTION;

 /* MCB related changes */
  l_multi_currency_billing_flag     pa_projects_all.MULTI_CURRENCY_BILLING_FLAG%TYPE;
  l_baseline_funding_flag           pa_projects_all.BASELINE_FUNDING_FLAG%TYPE;
  l_revproc_currency_code           pa_projects_all.revproc_currency_code%TYPE;
  l_invproc_currency_code           VARCHAR2(30);
  l_invproc_currency_type           pa_projects_all.invproc_currency_type%TYPE;
  l_project_currency_code           pa_projects_all.project_currency_code%TYPE;
  l_project_bil_rate_date_code      pa_projects_all.project_bil_rate_date_code%TYPE;
  l_project_bil_rate_type           pa_projects_all.project_bil_rate_type%TYPE;
  l_project_bil_rate_date           pa_projects_all.project_bil_rate_date%TYPE;
  l_project_bil_exchange_rate       pa_projects_all.project_bil_exchange_rate%TYPE;
  l_projfunc_currency_code          pa_projects_all.projfunc_currency_code%TYPE;
  l_projfunc_bil_rate_date_code     pa_projects_all.projfunc_bil_rate_date_code%TYPE;
  l_projfunc_bil_rate_type          pa_projects_all.projfunc_bil_rate_type%TYPE;
  l_projfunc_bil_rate_date          pa_projects_all.projfunc_bil_rate_date%TYPE;
  l_projfunc_bil_exchange_rate      pa_projects_all.projfunc_bil_exchange_rate%TYPE;
  l_funding_rate_date_code          pa_projects_all.funding_rate_date_code%TYPE;
  l_funding_rate_type               pa_projects_all.funding_rate_type%TYPE;
  l_funding_rate_date               pa_projects_all.funding_rate_date%TYPE;
  l_funding_exchange_rate           pa_projects_all.funding_exchange_rate%TYPE;
  l_return_status                   VARCHAR2(30);
  l_msg_count                       NUMBER;
  l_msg_data                        VARCHAR2(30);
  /* Till Here */

/* Added for Fin Plan impact */
l_cost_plan_type_id      NUMBER;
l_rev_plan_type_id       NUMBER;
/* till here */


BEGIN
--
-- Modified to pass the cost budget and revenue budget type codes
--
  l_status := 0;
  l_error_message := NULL;
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.ccrev  :');
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev Project Id :'||to_char(X_project_id));
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev Top Task Id :'||to_char(X_top_task_id));
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev Calling process :'||X_calling_process);
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev Calling place :'||X_calling_place);
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev Amount :'||to_char(X_amount));
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev Percentage :'||to_char(X_percentage));
        PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev rev_or_bill_date :'||to_char(X_rev_or_bill_date,'YYYY/MM/DD'));
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev billing_assignment_id :'||to_char(X_billing_assignment_id));
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev billing_extension_id :'||to_char(X_billing_extension_id));
	PA_MCB_INVOICE_PKG.log_message('pa_billing.ccrev request_id :'||to_char(X_request_id));
END IF;
/*****
 l_cost_budget_type_code := 'AC';
 l_rev_budget_type_code  := 'AR';
 P_cost_budget_type_code => l_cost_budget_type_code,
 P_rev_budget_type_code =>  l_rev_budget_type_code,
*****/
/* This is commented for MCB2 */
-- l_currency_code := pa_multi_currency_txn.get_proj_curr_code_sql(X_project_id);

 /* MCB related changes */
 PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  =>  X_project_id,
            x_multi_currency_billing_flag =>  l_multi_currency_billing_flag,
            x_baseline_funding_flag       =>  l_baseline_funding_flag,
            x_revproc_currency_code       =>  l_revproc_currency_code,
            x_invproc_currency_type       =>  l_invproc_currency_type,
            x_invproc_currency_code       =>  l_invproc_currency_code,
            x_project_currency_code       =>  l_project_currency_code,
            x_project_bil_rate_date_code  =>  l_project_bil_rate_date_code,
            x_project_bil_rate_type       =>  l_project_bil_rate_type,
            x_project_bil_rate_date       =>  l_project_bil_rate_date,
            x_project_bil_exchange_rate   =>  l_project_bil_exchange_rate,
            x_projfunc_currency_code      =>  l_projfunc_currency_code,
            x_projfunc_bil_rate_date_code =>  l_projfunc_bil_rate_date_code,
            x_projfunc_bil_rate_type      =>  l_projfunc_bil_rate_type,
            x_projfunc_bil_rate_date      =>  l_projfunc_bil_rate_date,
            x_projfunc_bil_exchange_rate  =>  l_projfunc_bil_exchange_rate,
            x_funding_rate_date_code      =>  l_funding_rate_date_code,
            x_funding_rate_type           =>  l_funding_rate_type,
            x_funding_rate_date           =>  l_funding_rate_date,
            x_funding_exchange_rate       =>  l_funding_exchange_rate,
            x_return_status               =>  l_return_status,
            x_msg_count                   =>  l_msg_count,
            x_msg_data                    =>  l_msg_data);

     l_currency_code := l_projfunc_currency_code;
     /* Till Here */


 IF g1_debug_mode  = 'Y' THEN
 	PA_MCB_INVOICE_PKG.log_message('Before select of pa billing params v pa_billing.ccrev :');
 END IF;
  /* Added for bug 2649456.Not handling exception intentionaly because if it is coming,
   it will be data issue */
   BEGIN
     SELECT default_cost_plan_type_id,default_rev_plan_type_id
     INTO l_cost_plan_type_id,l_rev_plan_type_id
     FROM pa_billing_extn_params_v;
   EXCEPTION
     WHEN OTHERS THEN
      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('Error from pa_billing_extn_params_v pa_billing.ccrev :'||SQLERRM);
      END IF;
      RAISE;
   END;
  /* till here */

 IF g1_debug_mode  = 'Y' THEN
 	PA_MCB_INVOICE_PKG.log_message('pa billing params v.cost_plan_type_id pa_billing.ccrev :'||l_cost_plan_type_id);
 	PA_MCB_INVOICE_PKG.log_message('pa billing params v.rev_plan_type_id pa_billing.ccrev :'||l_rev_plan_type_id);
 	PA_MCB_INVOICE_PKG.log_message('Before calling pa_billing_pub.get_budget_amount inside pa_billing.ccrev :');
 END IF;
  pa_billing_pub.get_budget_amount(
		X2_project_id           => X_project_id,
		X2_task_id              => X_top_task_id,
		X2_revenue_amount       => budget_revenue,
		X2_cost_amount          => budget_cost,
                X_cost_budget_type_code => l_cost_budget_type_code,
                X_rev_budget_type_code  => l_rev_budget_type_code,
                P_cost_plan_type_id     => l_cost_plan_type_id, /* Added for fin plan impact */
                P_rev_plan_type_id      => l_rev_plan_type_id,  /* Added for fin plan impact */
		X_error_message	        => l_error_message,
		X_status	        => l_status);

 IF g1_debug_mode  = 'Y' THEN
 	PA_MCB_INVOICE_PKG.log_message('After calling pa_billing_pub.get_budget_amount inside pa_billing.ccrev budget_revenue :'||to_char(budget_revenue));
 	PA_MCB_INVOICE_PKG.log_message('After calling pa_billing_pub.get_budget_amount inside pa_billing.ccrev budget_cost :'||to_char(budget_cost));
 	PA_MCB_INVOICE_PKG.log_message('After calling pa_billing_pub.get_budget_amount inside pa_billing.ccrev l_cost_budget_type_code :'||l_cost_budget_type_code);
 	PA_MCB_INVOICE_PKG.log_message('After calling pa_billing_pub.get_budget_amount inside pa_billing.ccrev budget_cost l_rev_budget_type_code :'||l_rev_budget_type_code);
 END IF;
-- If get budget amount return an error its fatal.

  IF l_status <> 0 THEN
	raise ccrev_error;
  END IF;

 IF g1_debug_mode  = 'Y' THEN
 	PA_MCB_INVOICE_PKG.log_message('Before calling pa_billing_amount.PotEventAmount inside pa_billing.ccrev :');
 END IF;
  pa_billing_amount.PotEventAmount(
		 X2_project_id => X_project_id,
 		 X2_task_id => X_top_task_id,
		 X2_accrue_through_date => X_rev_or_bill_date,
		 X2_revenue_amount => event_revenue,
		 X2_invoice_amount => event_invoice);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After calling pa_billing_amount.PotEventAmount inside pa_billing.ccrev event_revenue  :'||to_char(event_revenue));
	PA_MCB_INVOICE_PKG.log_message('Before calling pa_billing_amount.CostAmount inside pa_billing.ccrev event_invoice  :'||to_char(event_invoice));
END IF;
  pa_billing_amount.CostAmount(
		X2_project_id => X_project_id,
		X2_task_id => X_top_task_id,
		X2_accrue_through_date => X_rev_or_bill_date,
		X2_cost_amount => cost_amount);
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After pa_billing_amount.CostAmount inside pa_billing.ccrev cost_amount :'||to_char(cost_amount));
END IF;

  Amount_Left := pa_billing_amount.LowestAmountLeft(
					X_project_id,
					X_top_task_id,
					X_calling_process);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After pa_billing_amount.LowestAmountLeft inside pa_billing.ccrev Amount_Left :'||to_char(Amount_Left));
END IF;
--			DBMS_OUTPUT.PUT('Revenue =');
--			DBMS_OUTPUT.PUT_LINE(Revenue);
--			DBMS_OUTPUT.PUT('Amount_Left=');
--			DBMS_OUTPUT.PUT_LINE(Amount_Left);
--			DBMS_OUTPUT.PUT('budget_cost=');
--			DBMS_OUTPUT.PUT_LINE(budget_cost);
--			DBMS_OUTPUT.PUT('budget_revenue=');
--			DBMS_OUTPUT.PUT_LINE(budget_revenue);
--			DBMS_OUTPUT.PUT('cost_amount=');
--			DBMS_OUTPUT.PUT_LINE(cost_amount);
--			DBMS_OUTPUT.PUT('revenue_amount=');
--			DBMS_OUTPUT.PUT_LINE(revenue_amount);
--			DBMS_OUTPUT.PUT('event_revenue=');
--			DBMS_OUTPUT.PUT_LINE(event_revenue);


  IF (X_calling_process = 'Revenue') THEN
    pa_billing_amount.RevenueAmount(
		  X2_project_id => x_project_id,
 		  X2_task_id => X_top_task_id,
	   	  X2_revenue_amount => revenue_amount);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After call of pa_billing_amount.RevenueAmount inside  pa_billing.ccrev revenue_amount 1  :'||to_char(revenue_amount));
END IF;
    IF (budget_cost <> 0) THEN
    --  Take the lower of what you should insert based on cost-cost algorithm,
    --  of revenue = (cost/budget_cost) * (budget_revenue - event_revenue)
    --                - existing revenue.
    --  and what you can insert based on the lowest hard limit of the projects
    --  customers.

    	Revenue := Least( ( (nvl(cost_amount,0)/budget_cost)
			      * greatest( nvl(budget_revenue,0)
 				           - nvl(event_revenue,0), 0
			                )
 			      - (nvl(revenue_amount,0))
			   ) ,
			   Amount_Left
            		);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Inside pa_billing.ccrev calculating Revenue ( Least) Revenue 2  :'||to_char(Revenue));
END IF;

        /* Changed the length of the format mask for amount_left column from 15 to 22
           to fix the bug 2124494 for MCB2 */
        /* Changed the length of the format mask for all column from 15 to 22
           to fix the bug 2162900 for MCB2 */
	Event_Description := pa_billing_values.get_message('CCREV_DESCRIPTION')|| '(' ||
		     to_char(amount_left,fnd_currency.get_format_mask(l_currency_code,22))
                     || ' ,((' ||
		     to_char(cost_amount,fnd_currency.get_format_mask(l_currency_code,22))
                     || '/' ||
		     to_char(budget_cost,fnd_currency.get_format_mask(l_currency_code,22))
                     || ' * (' ||
		     to_char(budget_revenue,fnd_currency.get_format_mask(l_currency_code,22))
                     || ' - ' ||
		     to_char(nvl(event_revenue,0),fnd_currency.get_format_mask(l_currency_code,22))
                     || ')) - '||
		     to_char(nvl(revenue_amount,0),fnd_currency.get_format_mask(l_currency_code,22))
                     || ' ))';
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('rev part Inside Revenue part pa_billing.ccrev Event desc :'||Event_Description);
	PA_MCB_INVOICE_PKG.log_message('Rev part Before insert pa_billing.ccrev.insert_event 1  :'||to_char(Revenue));
END IF;
-- Modified to add new parameters for insert_event
    	pa_billing_pub.insert_event (
			X_rev_amt => Revenue,
			X_bill_amt => 0,
                       	X_event_description => event_description,
                        X_audit_amount1 => amount_left,
                        X_audit_amount2 => revenue_amount,
                        X_audit_amount3 => budget_revenue,
                        X_audit_amount4 => event_revenue,
			X_audit_amount5 => budget_cost,
		        X_audit_amount6 => cost_amount,
                        X_audit_cost_budget_type_code => l_cost_budget_type_code,
                        X_audit_rev_budget_type_code  => l_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => l_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => l_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message => l_error_message,
			X_status	=> l_status
			);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('rev part after insert pa_billing.ccrev.insert_event rev  :'||to_char(revenue_amount));
	PA_MCB_INVOICE_PKG.log_message('rev part after insert pa_billing.ccrev.insert_event budget rev  :'||to_char(budget_revenue));
	PA_MCB_INVOICE_PKG.log_message('rev part after insert pa_billing.ccrev.insert_event amt left  :'||to_char(amount_left));
	PA_MCB_INVOICE_PKG.log_message('rev part after insert pa_billing.ccrev.insert_event evt rev  :'||to_char(event_revenue));
	PA_MCB_INVOICE_PKG.log_message('rev part after insert pa_billing.ccrev.insert_event budget cost  :'||to_char(budget_cost));
	PA_MCB_INVOICE_PKG.log_message('rev part after insert pa_billing.ccrev.insert_event cst amt   :'||to_char(cost_amount));
END IF;
	IF l_status <> 0 THEN
	   raise ccrev_error;
        END IF;

   END IF;

  ELSE
    pa_billing_amount.InvoiceAmount(
		  X2_project_id => X_project_id,
 		  X2_task_id => X_top_task_id,
		  X2_invoice_amount => invoice_amount);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('After the call of pa_billing_amount.InvoiceAmount inside pa_billing.ccrev   :'||to_char(invoice_amount));
END IF;
    IF (budget_cost <> 0) THEN
	Invoice := Least( ( (nvl(cost_amount,0)/budget_cost)
			    * greatest( (nvl(budget_revenue,0)
					- nvl(event_invoice,0)), 0)
			  ) - nvl(invoice_amount,0),
			  nvl(Amount_Left,0)
			);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Inside pa_billing.ccrev calculating Invoice (Least)   :'||to_char(Invoice));
END IF;
        /* Changed the length of the format mask for amount_left column from 15 to 22
           to fix the bug 2124494 for MCB2 */
        /* Changed the length of the format mask for all column from 15 to 22
           to fix the bug 2162900 for MCB2 */
	Event_Description := pa_billing_values.get_message('CCREV_DESCRIPTION')|| '(' ||
		     to_char(amount_left,fnd_currency.get_format_mask(l_currency_code,22))
		     || ' ,((' ||
		     to_char(cost_amount,fnd_currency.get_format_mask(l_currency_code,22))
                     || '/' ||
		     to_char(budget_cost,fnd_currency.get_format_mask(l_currency_code,22))
                     || ' * (' ||
		     to_char(budget_revenue,fnd_currency.get_format_mask(l_currency_code,22))
                     || ' - ' ||
		     to_char(nvl(event_invoice,0),fnd_currency.get_format_mask(l_currency_code,22))
                     || ')) - '||
		     to_char(nvl(invoice_amount,0),fnd_currency.get_format_mask(l_currency_code,22))
                     || ' ))';

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('inv part Inside Revenue part pa_billing.ccrev Event desc :'||Event_Description);
	PA_MCB_INVOICE_PKG.log_message('inv part before insert pa_billing.ccrev.insert_event inv 2  :'||to_char(Invoice));
END IF;
    	pa_billing_pub.insert_event (
			X_rev_amt => 0,
			X_bill_amt => Invoice,
			X_event_description => Event_Description,
                        X_audit_amount1 => amount_left,
                        X_audit_amount2 => invoice_amount,
                        X_audit_amount3 => budget_revenue,
                        X_audit_amount4 => event_invoice,
			X_audit_amount5 => budget_cost,
		        X_audit_amount6 => cost_amount,
                        X_audit_cost_budget_type_code => l_cost_budget_type_code,
                        X_audit_rev_budget_type_code  => l_rev_budget_type_code,
                        X_audit_cost_plan_type_id     => l_cost_plan_type_id, /* Added for fin plan impact */
                        X_audit_rev_plan_type_id      => l_rev_plan_type_id,  /* Added for fin plan impact */
			X_error_message => l_error_message,
			X_status	=> l_status
			);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('inv part after insert pa_billing.ccrev.insert_event inv 2  :'||to_char(invoice_amount));
	PA_MCB_INVOICE_PKG.log_message('inv part after insert pa_billing.ccrev.insert_event bud rev 2  :'||to_char(budget_revenue));
	PA_MCB_INVOICE_PKG.log_message('inv part after insert pa_billing.ccrev.insert_event amt lft 2  :'||to_char(amount_left));
	PA_MCB_INVOICE_PKG.log_message('inv part after insert pa_billing.ccrev.insert_event evt inv 2  :'||to_char(event_invoice));
	PA_MCB_INVOICE_PKG.log_message('inv part after insert pa_billing.ccrev.insert_event bd cst 2  :'||to_char(budget_cost));
	PA_MCB_INVOICE_PKG.log_message('inv part after insert pa_billing.ccrev.insert_event cst amt 2   :'||to_char(cost_amount));
END IF;
	IF l_status <> 0 THEN
	   raise ccrev_error;
        END IF;

    END IF;
  END IF;

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing.ccrev :');
END IF;
EXCEPTION
  WHEN ccrev_error THEN
       NULL;
--  Modified so that this exception is reported but doesnot stop revenue
--  processing
--  RAISE_APPLICATION_ERROR(-20101,l_error_message);
  WHEN OTHERS THEN
--      DBMS_OUTPUT.PUT_LINE(SQLERRM);
	RAISE;

END ccrev;


PROCEDURE Delete_Automatic_Events ( 	X_Project_id	NUMBER,
					X_request_id	NUMBER DEFAULT NULL,
					X_rev_inv_num	NUMBER DEFAULT NULL,
					X_calling_process	VARCHAR2) IS


g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

-- Bug#1165176 Added condition line_num_reversed is null

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.Delete_Automatic_Events :');
END IF;
IF (X_calling_Process = 'Revenue') THEN
	DELETE 	from pa_events v
        WHERE 	v.project_id = X_project_id
        AND 	v.request_id+0 = X_request_id
        AND 	(v.project_id, nvl(v.task_id, -1), v.event_num) IN
	        (SELECT l.project_id, nvl(l.task_id, -1), l.event_num
             	 FROM 	pa_cust_event_rev_dist_lines l
	         WHERE 	l.project_id = X_project_id
                 AND    l.line_num_reversed is null
                 AND 	l.draft_revenue_num = X_rev_inv_num)
	AND 	EXISTS
                 (SELECT vt.event_type
                    FROM pa_event_types vt
                   WHERE vt.event_type_classification||'' = 'AUTOMATIC'
		     AND vt.event_type = v.event_type)
        AND 	v.calling_process = X_calling_process;
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Deleted Revenue pa_billing.Delete_Automatic_Events :');
END IF;
ELSE
-- DBMS_OUTPUT.PUT_LINE('Deleting Invoice Events');

	      DELETE FROM PA_EVENTS V
              WHERE V.Project_ID = X_project_id
              AND  (nvl(V.Task_ID, -1), V.Event_Num) IN
                   (select nvl(dii.Event_Task_ID, -1), dii.Event_Num
                    from pa_draft_invoice_items dii, pa_draft_invoices di
                    where di.Project_ID = X_project_id
                    and di.draft_invoice_num = X_rev_inv_num
                    and dii.Project_ID = di.Project_ID
                    and dii.draft_invoice_num = di.draft_invoice_num
                    and nvl(di.write_off_flag, 'N') = 'N'
		                and nvl(di.concession_flag,'N') = 'N') /* line added for bug 9068422 */
              AND   V.Bill_Amount <> 0
              AND   V.calling_process = X_calling_process;

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Deleted Invoice pa_billing.Delete_Automatic_Events :');
END IF;
-- This last part is to ensure that we delete only events that were created
-- by Invoice as per the adjustment model for Billing Extensions.

END IF;

-- commit;

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing.Delete_Automatic_Events :');
END IF;
END Delete_Automatic_Events;


PROCEDURE Call_Calc_Bill_Amount(
                                x_transaction_type       in varchar2 default 'ACTUAL',
				x_expenditure_item_id    in number,
                              	x_sys_linkage_function   in varchar2,
                                x_amount                   in out NOCOPY number, /* This amount is treated as amount in T --File.Sql.39 bug 4440895
ransaction currency */
                                x_bill_rate_flag           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                x_status                   in out NOCOPY number, --File.Sql.39 bug 4440895
                                x_bill_trans_currency_code out NOCOPY varchar2,/* The following four parameters are added for MCB2 */ --File.Sql.39 bug 4440895
                                x_bill_txn_bill_rate       out NOCOPY number, --File.Sql.39 bug 4440895
                                x_markup_percentage        out NOCOPY number, --File.Sql.39 bug 4440895
                                x_rate_source_id           out NOCOPY number   ) IS --File.Sql.39 bug 4440895

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
/* Change the call and aded new paras in this procs. for MCB2 */
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.Call_Calc_Bill_Amount   :');
END IF;
 pa_client_extn_billing.Calc_Bill_Amount(
                  x_transaction_type         => x_transaction_type,
		  x_expenditure_item_id      => x_expenditure_item_id,
                  x_sys_linkage_function     => x_sys_linkage_function,
                  x_amount                   => x_amount,
                  x_bill_rate_flag           => x_bill_rate_flag,
                  x_status                   => x_status,
                  x_bill_trans_currency_code => x_bill_trans_currency_code,
                  x_bill_txn_bill_rate       => x_bill_txn_bill_rate,
                  x_markup_percentage        => x_markup_percentage,
                  x_rate_source_id           => x_rate_source_id
                  );




/* Bug 1292444 Commented out this rounding as this is done when updating
   pa_expenditure_items  in pardfp.lpc. Rounding off tmount depending on the
   currency
x_amount := pa_currency.round_currency_amt(x_amount);*/

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing.Call_Calc_Bill_Amount   :');
END IF;
EXCEPTION WHEN OTHERS THEN
--      DBMS_OUTPUT.PUT(SQLERRM);
	RAISE;

END Call_Calc_Bill_Amount;

PROCEDURE DUMMY IS
BEGIN
NULL;
END;

/*-----------------------------------------------------------------------------
 |  Procedure Check_Spf_Amounts checks the amounts in summary_project_fundings|
 |  Table. If there are discrepancies it updates the amounts                  |
 |                                                                            |
 |  Parameters are:                                                           |
 |                                                                            |
 |     X_Option           :  I - Update Only Invoice Amounts                  |
 |                           R - Update Only Revenue Amounts                  |
 |                           B - Update Both Revenue/Invoice Amounts          |
 |                                                                            |
 |    X_proj_id           :  pa_projects.project_id                           |
 |    X_start_proj_num    :  Start project Number (pa_projects.segment1)      |
 |    X_end_proj_num      :  End   project Number (pa_projects.segment1)      |
 |                                                                            |
 |                                                                            |
 |  Called from :  PARGDR - Generate Draft Revenue                            |
 |                 PAIGEN - Generate Draft Invoice                            |
 |                                                                            |
 |  Morg Orientation:  Project Orientation.                                   |
 |                                                                            |
 |  History:                                                                  |
 |    21-Mar-97    N. Chouhan       Created                                   |
 |                                                                            |
 -----------------------------------------------------------------------------*/

PROCEDURE CHECK_SPF_AMOUNTS( X_option         in varchar2,
                             X_proj_id        in number,
                             X_start_proj_num in varchar2,
                             X_end_proj_num   in varchar2) IS

   l_project_id    number;


g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  /*--------------------------------------------------------------------------
   |     Cursor For Selecting AND Locking PA_PROJECTS TABLE                  |
   --------------------------------------------------------------------------*/

 /* CURSOR sel_proj is
         SELECT project_id
           FROM pa_projects
          WHERE (   (    nvl(X_proj_id,0) <> 0
                     AND project_id = X_proj_id )
                 OR (    nvl(X_proj_id,0) = 0
                     AND segment1 between X_start_proj_num
                         and X_end_proj_num))
         FOR UPDATE OF project_id; Commented for bug 3372249*/

 /* Fix for bug 3372249 Starts here */

 CURSOR sel_proj is
         SELECT project_id
           FROM pa_projects
          WHERE project_id = X_proj_id
         FOR UPDATE OF project_id;

CURSOR sel_proj_seg is
         SELECT project_id
           FROM pa_projects
          WHERE segment1 between X_start_proj_num
                         and X_end_proj_num
         FOR UPDATE OF project_id;

/* Fix for bug 3372249 Ends here */



  /*--------------------------------------------------------------------------
   |     Cursor For Selecting record having 0 accrued revenue                |
   --------------------------------------------------------------------------*/
   CURSOR spf_acc_0 is
         SELECT pf.agreement_id, pf.project_id, pf.task_id
           FROM pa_summary_project_fundings pf
          WHERE (pf.revproc_accrued_amount <> 0 /* MCB related changes */
                 /* The following added to fix bug 2249216 */
                 OR pf.PROJFUNC_ACCRUED_AMOUNT <> 0
                 OR pf.PROJECT_ACCRUED_AMOUNT <> 0
                 OR pf.TOTAL_ACCRUED_AMOUNT <> 0)
                 /* END fix bug 2249216 */
            AND pf.project_id = l_project_id
            AND NOT EXISTS
                  ( SELECT null
                      FROM pa_draft_revenue_items dri,
                           pa_draft_revenues dr
                     WHERE dri.project_id = dr.project_id
                       AND dri.draft_revenue_num = dr.draft_revenue_num
                       AND (   nvl(pf.task_id,0) = 0
                            OR dri.task_id = pf.task_id )
                       AND dr.project_id = pf.project_id
                       AND dr.agreement_id+0 = pf.agreement_id);

  /*--------------------------------------------------------------------------
   |     Cursor For Selecting record having bad accrued revenue data         |
   --------------------------------------------------------------------------*/
   CURSOR spf_acc_amt is
         SELECT pf.agreement_id, pf.project_id,
                decode(p.project_level_funding_flag,'Y',0,pf.task_id) task_fund, /*Decode added for bug 3647592 */
                sum(dri.amount) dri_amount, dri.revproc_currency_code,
                sum(dri.projfunc_revenue_amount) dri_projfunc_amount,dri.projfunc_currency_code,
                sum(dri.project_revenue_amount) dri_project_amount,dri.project_currency_code,
                sum(dri.funding_revenue_amount) dri_funding_amount,dri.funding_currency_code
           FROM pa_draft_revenue_items dri,
                pa_draft_revenues dr,
                pa_summary_project_fundings pf,
                pa_projects p                          /* Added pa_projects for bug 3647592 */
          WHERE dri.project_id = dr.project_id
            AND dri.draft_revenue_num = dr.draft_revenue_num
            AND (   (nvl(pf.task_id,0) = 0 AND nvl(p.project_level_funding_flag,'N')='Y')
                 OR dri.task_id = decode(p.project_level_funding_flag,'Y',0,pf.task_id) )   /* Added decode condition for bug 3647592 */
            AND dr.project_id+0 = pf.project_id
            AND dr.agreement_id = pf.agreement_id
            AND pf.project_id = l_project_id
            AND p.project_id = pf.project_id
    	    AND exists (select 1 from pa_agreements_all paa where paa.agreement_id = pf.agreement_id /*Changed to pa_agreements_all for bug 8307812 */
                             and dri.funding_currency_code =  paa.agreement_currency_code) /*  condition added  for  Bug  5956273*/

       GROUP BY pf.agreement_id, pf.project_id, decode(p.project_level_funding_flag,'Y',0,pf.task_id),dri.revproc_currency_code,
                dri.projfunc_currency_code,dri.project_currency_code,
                dri.funding_currency_code;   /* MCB related changes */

  /*--------------------------------------------------------------------------
   |     Cursor For Selecting record having 0 billed amount                  |
   --------------------------------------------------------------------------*/
   CURSOR spf_bill_0 is
         SELECT pf.agreement_id, pf.project_id, pf.task_id
           FROM pa_summary_project_fundings pf
          WHERE (pf.invproc_billed_amount <> 0 /* MCB related changes */
                 /* The following added to fix bug 2249216 */
                 OR pf.PROJFUNC_BILLED_AMOUNT <> 0
                 OR pf.PROJECT_BILLED_AMOUNT <> 0
                 OR pf.TOTAL_BILLED_AMOUNT <> 0)
                 /* END fix bug 2249216 */
            AND pf.project_id = l_project_id;
            /*AND NOT EXISTS
                  ( SELECT null
                      FROM pa_draft_invoice_items dii,
                           pa_draft_invoices di
                     WHERE dii.project_id = di.project_id
                       AND dii.draft_invoice_num = di.draft_invoice_num
                       AND (   nvl(pf.task_id,0) = 0
                            OR dii.task_id = pf.task_id )
                       AND di.project_id = pf.project_id
		       AND dii.invoice_line_type<>'RETENTION' /* added for bug 2822610
                       AND di.agreement_id+0 = pf.agreement_id);    commented for bug 8884098 */

  /*--------------------------------------------------------------------------
   | Cursor For Selecting record having bad bill amount data for Projects    |
   | Funded at Project Level                                                 |
   --------------------------------------------------------------------------*/
   CURSOR spf_pl_bill_amt is
         SELECT pf.agreement_id, pf.project_id,
                sum(dii.amount) dii_amount,dii.invproc_currency_code,
                sum(dii.projfunc_bill_amount) dii_projfunc_amount,dii.projfunc_currency_code,
                sum(dii.project_bill_amount) dii_project_amount,dii.project_currency_code,
                sum(dii.funding_bill_amount) dii_funding_amount,dii.funding_currency_code
           FROM pa_draft_invoice_items dii,
                pa_draft_invoices di,
                pa_summary_project_fundings pf
         WHERE dii.project_id = di.project_id
           AND dii.draft_invoice_num = di.draft_invoice_num
           AND dii.invoice_line_type <> 'RETENTION'
           AND di.project_id+0 = pf.project_id
           AND di.agreement_id = pf.agreement_id
           AND nvl(pf.task_id, 0) = 0
           AND pf.project_id = l_project_id
           AND pf.invproc_currency_code = dii.invproc_currency_code   /* Added for Bug 9402708 */
	   AND pf.total_baselined_amount > 0  /* 2094391 */
	   AND exists (select 1 from pa_agreements_all paa where paa.agreement_id = pf.agreement_id  /*Changed to pa_agreements_all for bug 8307812 */
                         and dii.funding_currency_code =  paa.agreement_currency_code) /*  condition added  for  Bug  5956273*/
      GROUP BY pf.agreement_id, pf.project_id
               ,dii.invproc_currency_code,dii.projfunc_currency_code,dii.project_currency_code
               , dii.funding_currency_code;  /* MCB related changes */

  /*--------------------------------------------------------------------------
   | Cursor For Selecting record having bad bill amount data for Projects    |
   | Funded at Task Level                                                    |
   --------------------------------------------------------------------------*/
   CURSOR spf_tl_bill_amt is
         /* This new currency procs. is being used which covers the MCB2 as well as old functionality */

         SELECT pf.agreement_id, pf.project_id, pf.task_id
                ,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(sum(dii.amount * (1 -
                    ( nvl(di.retention_percentage,0)/100 )) ), dii.invproc_currency_code) dii_amount,dii.invproc_currency_code,
                PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(sum(dii.projfunc_bill_amount * (1 -
                    ( nvl(di.retention_percentage,0)/100 )) ),dii.projfunc_currency_code) dii_projfunc_amount,dii.projfunc_currency_code,
                PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(sum(dii.project_bill_amount * (1 -
                    ( nvl(di.retention_percentage,0)/100 )) ),dii.project_currency_code) dii_project_amount,dii.project_currency_code,
                PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(sum(dii.funding_bill_amount * (1 -
                    ( nvl(di.retention_percentage,0)/100 )) ),dii.funding_currency_code) dii_funding_amount,dii.funding_currency_code
           FROM pa_draft_invoice_items dii,
                pa_draft_invoices di,
                pa_summary_project_fundings pf
         WHERE dii.project_id = di.project_id                            /* Bug#5081194 : Removed the +0 for perf issue */
           AND dii.draft_invoice_num+0 = di.draft_invoice_num
           AND pf.task_id = dii.task_id
           AND dii.invoice_line_type <> 'RETENTION'
           AND di.project_id = pf.project_id                    /* Bug#5081194 : Removed the +0 in di.project_id for perf issue */
           AND di.agreement_id = pf.agreement_id
           AND pf.project_id = l_project_id
           AND pf.project_id = dii.project_id                 /* Bug#5081194 : added this condition */
           AND pf.invproc_currency_code = dii.invproc_currency_code   /* Added for Bug 9402708 */
       AND pf.total_baselined_amount > 0  /* added for bug 3464050 */
       AND exists (select 1 from pa_agreements_all paa where paa.agreement_id = pf.agreement_id /*Changed to pa_agreements_all for bug 8307812 */
                         and dii.funding_currency_code =  paa.agreement_currency_code) /*  condition added  for  Bug  5956273*/
      GROUP BY pf.agreement_id, pf.project_id, pf.task_id
               ,dii.invproc_currency_code,dii.projfunc_currency_code,
               dii.project_currency_code,dii.funding_currency_code;         /* MCB related changes */

BEGIN
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.CHECK_SPF_AMOUNTS   :');
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.CHECK_SPF_AMOUNTS X_option  : '||X_option);
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.CHECK_SPF_AMOUNTS X_proj_id  : '||X_proj_id);
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.CHECK_SPF_AMOUNTS X_start_proj_num  : '||X_start_proj_num);
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.CHECK_SPF_AMOUNTS X_end_proj_num  : '||X_end_proj_num);
END IF;

--  OPEN sel_proj; Commented for bug 3372249

/* Start of fix for bug 3372249 */
IF(nvl(X_proj_id,0) <> 0) THEN
  OPEN sel_proj;
ELSE
  OPEN sel_proj_seg;
END IF;
/* End of fix for bug 3372249 */

  LOOP

--    FETCH sel_proj into l_project_id; Commented for bug 3372249

    /* Start of fix for bug 3372249 */
    IF(nvl(X_proj_id,0) <> 0) THEN
        FETCH sel_proj into l_project_id;
    ELSE
        FETCH sel_proj_seg into l_project_id;
    END IF;
    /* End of fix for bug 3372249 */

    IF g1_debug_mode  = 'Y' THEN
    	PA_MCB_INVOICE_PKG.log_message('Inside pa_billing.CHECK_SPF_AMOUNTS cursor sel_proj  : ');
    END IF;

--    EXIT WHEN sel_proj%NOTFOUND; Commented for bug 3372249
    /* Start of fix for bug 3372249 */
    IF(nvl(X_proj_id,0) <> 0) THEN
        EXIT WHEN sel_proj%NOTFOUND;
    ELSE
        EXIT WHEN sel_proj_seg%NOTFOUND;
    END IF;
    /* End of fix for bug 3372249 */


    IF (X_option in ('R','B')) THEN

      /*-----------------------------------------------------------------------
       |   Updating Total Accrued Revenue column which should be zero         |
       -----------------------------------------------------------------------*/
      FOR acc_0_rec in spf_acc_0 LOOP

    IF g1_debug_mode  = 'Y' THEN
    	PA_MCB_INVOICE_PKG.log_message('Inside pa_billing.CHECK_SPF_AMOUNTS cursor spf_acc_0  : ');
    END IF;
        UPDATE pa_summary_project_fundings pf
           SET pf.total_accrued_amount    = 0,
               pf.revproc_accrued_amount  = 0,   /* MCB related changes */
               pf.projfunc_accrued_amount = 0,
               pf.project_accrued_amount  = 0
         WHERE pf.agreement_id   = acc_0_rec.agreement_id
             AND pf.project_id     = acc_0_rec.project_id
             AND nvl(pf.task_id,0) = nvl(acc_0_rec.task_id,0);   /* MCB related changes */

      END LOOP;


      /*-----------------------------------------------------------------------
       |   Updating Total Accrued Revenue column                              |
       -----------------------------------------------------------------------*/

      FOR acc_amt_rec in spf_acc_amt LOOP
   /* This new currency procs. is being used which covers the MCB2 as well as old functionality */

    IF g1_debug_mode  = 'Y' THEN
    	PA_MCB_INVOICE_PKG.log_message('Inside pa_billing.CHECK_SPF_AMOUNTS cursor spf_acc_amt  : ');
    END IF;
      UPDATE pa_summary_project_fundings pf
           SET   pf.total_accrued_amount =
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                          (acc_amt_rec.dri_funding_amount,acc_amt_rec.funding_currency_code),
                 pf.revproc_accrued_amount =
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                          (acc_amt_rec.dri_amount,acc_amt_rec.revproc_currency_code),
                 pf.projfunc_accrued_amount =
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                          (acc_amt_rec.dri_projfunc_amount,acc_amt_rec.projfunc_currency_code),
                 pf.project_accrued_amount =
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                          (acc_amt_rec.dri_project_amount,acc_amt_rec.project_currency_code)
         WHERE pf.agreement_id   = acc_amt_rec.agreement_id
           AND pf.project_id     = acc_amt_rec.project_id
           AND nvl(pf.task_id,0) = nvl(acc_amt_rec.task_fund,0);      /* changed task_id to task_fund for bug 3647592 */ /* added semi-colon for bug 3717388*/
  /***     AND nvl(pf.total_baselined_amount,0) <>0; ***//* MCB related changes */
           /* AND nvl(pf.total_baselined_amount,0) >= 0; commented for bug 3717388 */ /* Changed condition bug 2842994 */

      END LOOP;

    END IF;


    IF (X_option in ('I','B')) THEN

      /*-----------------------------------------------------------------------
       |   Updating Zero Total Billed amount column.                          |
       -----------------------------------------------------------------------*/

      FOR bill_0_rec in spf_bill_0 LOOP

    IF g1_debug_mode  = 'Y' THEN
    	PA_MCB_INVOICE_PKG.log_message('Inside pa_billing.CHECK_SPF_AMOUNTS cursor spf_bill_0  : ');
    END IF;
        UPDATE pa_summary_project_fundings pf
           SET pf.total_billed_amount    = 0,
               pf.invproc_billed_amount  = 0,  /* MCB related changes */
               pf.projfunc_billed_amount = 0,
               pf.project_billed_amount  = 0
         WHERE pf.agreement_id   = bill_0_rec.agreement_id
           AND pf.project_id     = bill_0_rec.project_id
           AND nvl(pf.task_id,0) = nvl(bill_0_rec.task_id,0); /* MCB related changes */

      END LOOP;


      /*-----------------------------------------------------------------------
       |   Updating Total Billed Amount column for Project Level Funding      |
       -----------------------------------------------------------------------*/

      FOR pl_bill_amt_rec in spf_pl_bill_amt LOOP
   /* This new currency procs. is being used which covers the MCB2 as well as old functionality */

    IF g1_debug_mode  = 'Y' THEN
    	PA_MCB_INVOICE_PKG.log_message('Inside pa_billing.CHECK_SPF_AMOUNTS cursor spf_pl_bill_amt  : ');
    END IF;
      UPDATE pa_summary_project_fundings pf
           SET pf.total_billed_amount =
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                         (pl_bill_amt_rec.dii_funding_amount,pl_bill_amt_rec.funding_currency_code),
               pf.invproc_billed_amount =
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                         (pl_bill_amt_rec.dii_amount,pl_bill_amt_rec.invproc_currency_code),
               pf.projfunc_billed_amount =
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                         (pl_bill_amt_rec.dii_projfunc_amount,pl_bill_amt_rec.projfunc_currency_code),
               pf.project_billed_amount =
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                         (pl_bill_amt_rec.dii_project_amount,pl_bill_amt_rec.project_currency_code)
         WHERE pf.agreement_id   = pl_bill_amt_rec.agreement_id
           AND pf.project_id     = pl_bill_amt_rec.project_id /* MCB related changes */
	   AND nvl(pf.task_id,0) = 0 /* 2094391 */
	   AND pf.invproc_currency_code = pl_bill_amt_rec.invproc_currency_code;   /* Added for Bug 9402708 */

      END LOOP;


      /*-----------------------------------------------------------------------
       |   Updating Total Billed Amount column for Task Level Funding         |
       -----------------------------------------------------------------------*/

      FOR tl_bill_amt_rec in spf_tl_bill_amt LOOP

      /* This new currency procs. is being used which covers the MCB2 as well as old functionality */

    IF g1_debug_mode  = 'Y' THEN
    	PA_MCB_INVOICE_PKG.log_message('Inside pa_billing.CHECK_SPF_AMOUNTS cursor spf_tl_bill_amt  : ');
    END IF;

      UPDATE pa_summary_project_fundings pf
           SET pf.total_billed_amount =
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                              (tl_bill_amt_rec.dii_funding_amount,tl_bill_amt_rec.funding_currency_code),
               pf.invproc_billed_amount =
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                              (tl_bill_amt_rec.dii_amount,tl_bill_amt_rec.invproc_currency_code),
               pf.projfunc_billed_amount =
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                              (tl_bill_amt_rec.dii_projfunc_amount,tl_bill_amt_rec.projfunc_currency_code),
               pf.project_billed_amount =
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT
                              (tl_bill_amt_rec.dii_project_amount,tl_bill_amt_rec.project_currency_code)
         WHERE pf.agreement_id   = tl_bill_amt_rec.agreement_id
           AND pf.project_id     = tl_bill_amt_rec.project_id
           AND pf.task_id        = tl_bill_amt_rec.task_id  /* MCB related changes */
           AND pf.invproc_currency_code = tl_bill_amt_rec.invproc_currency_code;   /* Added for Bug 9402708 */

      END LOOP;

    END IF;

  END LOOP;

--  CLOSE sel_proj; Commented for bug 3372249
    /* Start of fix for bug 3372249 */
    IF(nvl(X_proj_id,0) <> 0) THEN
        CLOSE sel_proj;
    ELSE
        CLOSE sel_proj_seg;
    END IF;
    /* End of fix for bug 3372249 */

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing.CHECK_SPF_AMOUNTS   :');
END IF;
EXCEPTION
  WHEN OTHERS THEN
     -- CLOSE sel_proj; Commented for bug 3372249
        /* Start of fix for bug 3372249 */
    IF(nvl(X_proj_id,0) <> 0) THEN
        CLOSE sel_proj;
    ELSE
        CLOSE sel_proj_seg;
    END IF;
    /* End of fix for bug 3372249 */
     RAISE;


END CHECK_SPF_AMOUNTS;

PROCEDURE  Get_WriteOff_Revenue_Amount (p_project_id            IN  NUMBER DEFAULT NULL,
                                        p_task_id               IN  NUMBER DEFAULT NULL,
                                        p_agreement_id          IN  NUMBER DEFAULT NULL,
                                        p_funding_flag          IN  VARCHAR2 DEFAULT NULL,
                                        p_writeoff_amount       IN OUT NOCOPY NUMBER, /* It is funding currency MCB */ --File.Sql.39 bug 4440895
                                        x_projfunc_writeoff_amount  OUT NOCOPY NUMBER, /* MCB related changes */ --File.Sql.39 bug 4440895
                                        x_project_writeoff_amount   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_revproc_writeoff_amount   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                         ) IS
/* ------------------------------------------------------------------------
|| Procedure    :   Get_WriteOff_Revenue_Amount                            ||
|| Description  :   To get  Revenue WriteOff Amount                        ||
|| Parameters   :   Project ID               (IN)                          ||
||                  Task ID                  (IN)                          ||
||                  Agreement ID             (IN)                          ||
||                  Funding Flag             (IN)                          ||
||                  WriteOff Amount          (IN)    (OUT)                 ||
||                  Projfunc Writeoff Amount (OUT)                         ||
||                  Project Writeoff Amount  (OUT)                         ||
||                  Revproc Writeoff Amount  (OUT)                         ||
 --------------------------------------------------------------------------*/


g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
l_writeoff_amount NUMBER := p_writeoff_amount  ;

BEGIN

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.Get_WriteOff_Revenue_Amount   :');
END IF;
    BEGIN

        IF p_task_id IS NOT NULL THEN


          IF p_agreement_id IS NOT NULL THEN

           /*
           |  If the search has project id, task id, agreement id
           |     Driving Path  Events -> Event Types -> ERDL -> DR               */


                SELECT SUM(NVL(ERDL.amount,0)),SUM(NVL(ERDL.project_revenue_amount,0)),
                       SUM(NVL(ERDL.projfunc_revenue_amount,0)),SUM(NVL(ERDL.funding_revenue_amount,0))
                INTO x_revproc_writeoff_amount,x_project_writeoff_amount,
                     x_projfunc_writeoff_amount,p_writeoff_amount /* MCB related changes */
                FROM   PA_CUST_EVENT_RDL_ALL ERDL,
                        PA_DRAFT_REVENUES_ALL DR,
                        PA_EVENT_TYPES ET,
                        PA_EVENTS E
                WHERE   NVL(E.REVENUE_DISTRIBUTED_FLAG , 'N')  = 'Y'
                        AND   ERDL.PROJECT_ID=DR.PROJECT_ID
                        AND   E.EVENT_NUM = ERDL.EVENT_NUM
                        AND   E.TASK_ID = ERDL.TASK_ID
                        AND   ET.EVENT_TYPE = E.EVENT_TYPE
                        AND   ET.EVENT_TYPE_CLASSIFICATION ||''='WRITE OFF'
                        AND   E.PROJECT_ID =  ERDL.PROJECT_ID
                        AND   ERDL.PROJECT_ID = DECODE(ET.EVENT_TYPE,NULL,
                                              NULL, E.PROJECT_ID)
                        AND   E.TASK_ID =  p_task_id
                        AND   NVL(DR.AGREEMENT_ID,0) = NVL(p_agreement_id,DR.AGREEMENT_ID)
                        AND   E.PROJECT_ID = p_project_id
                        AND   DR.DRAFT_REVENUE_NUM = ERDL.DRAFT_REVENUE_NUM;

          ELSE

           /*
           |  If the search has project id, task id, agreement id is null
           |     Driving Path  Events -> Event Types                */

               /* MCB related changes */
                SELECT SUM(NVL(ERDL.amount,0)),SUM(NVL(ERDL.project_revenue_amount,0)),
                       SUM(NVL(ERDL.projfunc_revenue_amount,0)),
                       DECODE(p_funding_flag,'Y',SUM(NVL(ERDL.funding_revenue_amount,0)),0)
                INTO x_revproc_writeoff_amount,x_project_writeoff_amount,
                     x_projfunc_writeoff_amount,p_writeoff_amount /* MCB related changes */
                FROM   PA_CUST_EVENT_RDL_ALL ERDL,
                        PA_EVENT_TYPES ET,
                        PA_EVENTS E
                WHERE   NVL(E.REVENUE_DISTRIBUTED_FLAG , 'N')  = 'Y'
                        AND   E.EVENT_NUM = ERDL.EVENT_NUM
                        AND   E.TASK_ID = ERDL.TASK_ID
                        AND   ET.EVENT_TYPE = E.EVENT_TYPE
                        AND   ET.EVENT_TYPE_CLASSIFICATION ||''='WRITE OFF'
                        AND   E.PROJECT_ID =  ERDL.PROJECT_ID
                        AND   ERDL.PROJECT_ID = DECODE(ET.EVENT_TYPE,NULL,
                                              NULL, E.PROJECT_ID)
                        AND   E.TASK_ID =  p_task_id
                        AND   E.PROJECT_ID = p_project_id;

               /* This select is commented for MCB2, the same objective is fulfill by the above select */
         /*     SELECT SUM(NVL(E.revenue_amount,0)),SUM(NVL(E.project_revenue_amount,0)),
                     SUM(NVL(E.projfunc_revenue_amount,0)),SUM(NVL(E.funding_revenue_amount,0))
                INTO x_revproc_writeoff_amount,x_project_writeoff_amount,
                     x_projfunc_writeoff_amount,p_writeoff_amount
                FROM   PA_EVENT_TYPES ET,
                       PA_EVENTS E
                WHERE  NVL(E.REVENUE_DISTRIBUTED_FLAG , 'N')  = 'Y'
                       AND   ET.EVENT_TYPE = E.EVENT_TYPE
                       AND   ET.EVENT_TYPE_CLASSIFICATION ||''='WRITE OFF'
                       AND   E.TASK_ID =  p_task_id
                       AND   E.PROJECT_ID = p_project_id;
           */

           END IF;

        ELSIF p_project_id IS NOT NULL THEN


          IF p_agreement_id IS NOT NULL THEN

           /*
           | If Project id is not null, agreement id is not null
           |     Driving Path  Events -> Event Types -> ERDL -> DR               */


                SELECT SUM(NVL(ERDL.amount,0)),SUM(NVL(ERDL.project_revenue_amount,0)),
                       SUM(NVL(ERDL.projfunc_revenue_amount,0)),SUM(NVL(ERDL.funding_revenue_amount,0))
                INTO x_revproc_writeoff_amount,x_project_writeoff_amount,
                     x_projfunc_writeoff_amount,p_writeoff_amount /* MCB related changes */
                FROM   PA_CUST_EVENT_RDL_ALL ERDL,
                       PA_DRAFT_REVENUES_ALL DR,
                       PA_EVENT_TYPES ET,
                       PA_EVENTS E
                WHERE  NVL(E.REVENUE_DISTRIBUTED_FLAG , 'N')  = 'Y'
                       AND   ERDL.PROJECT_ID=DR.PROJECT_ID
                       AND   E.EVENT_NUM = ERDL.EVENT_NUM
                       AND   ET.EVENT_TYPE = E.EVENT_TYPE
                       AND   ET.EVENT_TYPE_CLASSIFICATION ||''='WRITE OFF'
                       AND   E.PROJECT_ID =  ERDL.PROJECT_ID
                       AND   ERDL.PROJECT_ID = DECODE(ET.EVENT_TYPE,NULL, NULL, E.PROJECT_ID)
                       AND   NVL(DR.AGREEMENT_ID,0) = NVL(p_agreement_id,DR.AGREEMENT_ID)
                       AND   E.PROJECT_ID = p_project_id
                       AND   DR.DRAFT_REVENUE_NUM = ERDL.DRAFT_REVENUE_NUM
                       AND NVL(E.TASK_ID,0) = NVL(ERDL.TASK_ID,0);  /* Added for bug 1504680 */
          ELSE

           /*
           | If Project id is not null, agreement id  is null
           |     Driving Path  Events -> Event Types           */

                /* MCB related changes */
                SELECT SUM(NVL(ERDL.amount,0)),SUM(NVL(ERDL.project_revenue_amount,0)),
                       SUM(NVL(ERDL.projfunc_revenue_amount,0)),
                       DECODE(p_funding_flag,'Y',SUM(NVL(ERDL.funding_revenue_amount,0)),0)
                INTO x_revproc_writeoff_amount,x_project_writeoff_amount,
                     x_projfunc_writeoff_amount,p_writeoff_amount /* MCB related changes */
                FROM   PA_CUST_EVENT_RDL_ALL ERDL,
                       PA_EVENT_TYPES ET,
                       PA_EVENTS E
                WHERE  NVL(E.REVENUE_DISTRIBUTED_FLAG ,'N')  = 'Y'
                       AND   E.EVENT_NUM = ERDL.EVENT_NUM
                       AND   ET.EVENT_TYPE = E.EVENT_TYPE
                       AND   ET.EVENT_TYPE_CLASSIFICATION ||''='WRITE OFF'
                       AND   E.PROJECT_ID =  ERDL.PROJECT_ID
                       AND   ERDL.PROJECT_ID = DECODE(ET.EVENT_TYPE,NULL, NULL, E.PROJECT_ID)
                       AND NVL(E.TASK_ID,0) = NVL(ERDL.TASK_ID,0)  /* Added for bug 1504680 */
                       AND   E.PROJECT_ID = p_project_id;

              /* This select is commented for MCB2, the same objective is fulfill by the above select */
              /*
                SELECT SUM(NVL(E.revenue_amount,0)),SUM(NVL(E.project_revenue_amount,0)),
                     SUM(NVL(E.projfunc_revenue_amount,0)),SUM(NVL(E.funding_revenue_amount,0))
                INTO x_revproc_writeoff_amount,x_project_writeoff_amount,
                     x_projfunc_writeoff_amount,p_writeoff_amount
                FROM  PA_EVENT_TYPES ET,
                      PA_EVENTS E
                WHERE  NVL(E.REVENUE_DISTRIBUTED_FLAG , 'N')  = 'Y'
                       AND   ET.EVENT_TYPE = E.EVENT_TYPE
                       AND   ET.EVENT_TYPE_CLASSIFICATION ||''='WRITE OFF'
                       AND   E.PROJECT_ID = p_project_id; */

          END IF;

        ELSIF p_agreement_id IS NOT NULL THEN

           /*
           | If Agreement id is not null, agreement id (might be null)
           |  Driving  path   DR -> ERDL -> Events -> Event Types           */


                SELECT SUM(NVL(ERDL.amount,0)),SUM(NVL(ERDL.project_revenue_amount,0)),
                       SUM(NVL(ERDL.projfunc_revenue_amount,0)),SUM(NVL(ERDL.funding_revenue_amount,0))
                INTO x_revproc_writeoff_amount,x_project_writeoff_amount,
                     x_projfunc_writeoff_amount,p_writeoff_amount /* MCB related changes */
                FROM   PA_CUST_EVENT_RDL_ALL ERDL,
                       PA_DRAFT_REVENUES_ALL DR,
                       PA_EVENT_TYPES ET,
                       PA_EVENTS E
               WHERE   NVL(E.REVENUE_DISTRIBUTED_FLAG , 'N')  = 'Y'
                       AND   ERDL.PROJECT_ID=DR.PROJECT_ID
                       AND   E.EVENT_NUM = ERDL.EVENT_NUM
                       AND   ET.EVENT_TYPE = E.EVENT_TYPE
                       AND   ET.EVENT_TYPE_CLASSIFICATION ||''='WRITE OFF'
                       AND   E.PROJECT_ID =  ERDL.PROJECT_ID
                       AND   ERDL.PROJECT_ID = DECODE(ET.EVENT_TYPE,NULL,NULL, E.PROJECT_ID)
                       AND   DR.AGREEMENT_ID = p_agreement_id
                       AND   DR.DRAFT_REVENUE_NUM = ERDL.DRAFT_REVENUE_NUM
                       AND NVL(E.TASK_ID,0) = NVL(ERDL.TASK_ID,0);  /* Added for bug 1504680 */


        ELSE
            /*
            | If Project ID is null, Task ID is null, Agreement ID is null
            | Driving path  Event Type -> Events -> ERDL -> DR              */


                        SELECT SUM(NVL(ERDL.amount,0)),SUM(NVL(ERDL.project_revenue_amount,0)),
                             SUM(NVL(ERDL.projfunc_revenue_amount,0)),SUM(NVL(ERDL.funding_revenue_amount,0))
                        INTO x_revproc_writeoff_amount,x_project_writeoff_amount,
                             x_projfunc_writeoff_amount,p_writeoff_amount /* MCB related changes */
                        FROM    PA_CUST_EVENT_RDL_ALL ERDL,
                                PA_DRAFT_REVENUES_ALL DR,
                                PA_EVENT_TYPES ET,
                                PA_EVENTS E
                        WHERE   NVL(E.REVENUE_DISTRIBUTED_FLAG , 'N')  = 'Y'
                                AND   ERDL.PROJECT_ID=DR.PROJECT_ID
                                AND   E.EVENT_NUM = ERDL.EVENT_NUM
                                AND   ET.EVENT_TYPE = E.EVENT_TYPE
                                AND   ET.EVENT_TYPE_CLASSIFICATION ='WRITE OFF'
                                AND   E.PROJECT_ID =  ERDL.PROJECT_ID
                        AND   ERDL.PROJECT_ID = DECODE(ET.EVENT_TYPE,NULL,
                                              NULL, E.PROJECT_ID)
                                AND   DR.DRAFT_REVENUE_NUM = ERDL.DRAFT_REVENUE_NUM
                       AND NVL(E.TASK_ID,0) = NVL(ERDL.TASK_ID,0);  /* Added for bug 1504680 */

        END IF;

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing.Get_WriteOff_Revenue_Amount   :');
END IF;
    EXCEPTION

    WHEN OTHERS THEN
         p_writeoff_amount   := l_writeoff_amount; -- NOCOPY
         x_projfunc_writeoff_amount  := NULL;
         x_project_writeoff_amount   := NULL;
         x_revproc_writeoff_amount  := NULL;
         RAISE;
END;

END Get_WriteOff_Revenue_Amount;

PROCEDURE forecast_rev_billamount
	      (NC in out NOCOPY number, --File.Sql.39 bug 4440895
	       process_irs in out NOCOPY varchar2, --File.Sql.39 bug 4440895
	       process_bill_rate  in out NOCOPY varchar2, --File.Sql.39 bug 4440895
	       message_code in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
	       rows_this_time  number,
	       error_code in out  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       reason     in out  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	       bill_amount in out   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	       d_rule_decode in out  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       sl_function in out  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       ei_id in   PA_PLSQL_DATATYPES.IdTabTyp,
	       t_rev_irs_id in out  NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	       rev_comp_set_id in out  NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	       rev_amount     in out  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	       mcb_flag in out  NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
	       x_bill_trans_currency_code in out NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	       x_bill_trans_bill_rate in out   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	       x_rate_source_id in  out  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       x_markup_percentage in  out  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
   ) is

/*--------------------------------------------------------------------------------------
 declare all the memory variables.
 --------------------------------------------------------------------------------------*/


g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    system_error          EXCEPTION;
    amount                number;
    rate_sch_rev_id       number;
    compiled_set_id       number;
    status                number;
    stage                 number;
    bill_rate_flag        varchar2(2);
    sys_linkage_func      varchar2(30);
    insert_error_message  boolean;
    fetched_amount        boolean;
    l_ind_cost_acct       number := NULL;
    l_ind_cost_denm       number := NULL;
    labor_sch_type        varchar2(2);
    j                     number;
    /* Bug# 2208288 */
    l_ind_cost_project    number := NULL;

    bill_trans_currency_code VARCHAR2(15);
    bill_trans_bill_rate     NUMBER;
    rate_source_id           NUMBER;
    markup_percentage        NUMBER;
   l_mcb_cost_flag    varchar2(50);    /* Added for bug 2638840 */

    BEGIN


/*--------------------------------------------------------------------------------------
 initialize array index j to 1,
 initialize flags which determine whether irs, bill rate
 schedules need to be processed or not
--------------------------------------------------------------------------------------*/

/* Indicator varoiables Bug# 634414  */
         NC  := 1201;
         j  := 1;
         process_irs:= 'N';
         process_bill_rate:= 'N';
         message_code:= 'No errors while processing IRS....';
/*--------------------------------------------------------------------------------------
 loop until all 100 ei's are processed
 -------------------------------------------------------------------------------------*/

         WHILE j <= rows_this_time LOOP
/* Indicator Variables Bug#634414 */
             NC := 1202;
          l_mcb_cost_flag := NULL;  /* Added for bug 2638840 */

             error_code( j ) := 0;
             reason( j )     := NULL;
             rate_sch_rev_id := NULL;
             compiled_set_id := NULL;
             amount := NULL;
             insert_error_message := FALSE;
             fetched_amount := FALSE;

/*-------------------------------------------------------------------------------------
  Call a client extension to fetch the bill amount for the ei.
  This has to be done for Labor exp items which have WORK
  distribution rule for Revenue or Invoice.
 -------------------------------------------------------------------------------------*/

         bill_amount( j ) := NULL;
/* Indicator Variables Bug# 634414 */
         NC := 1203;

	  IF ( d_rule_decode( j ) = 1 AND
              sl_function( j ) < 2     ) THEN


            amount         := NULL;
            status         := 0;
            bill_rate_flag := ' ';

            IF sl_function( j ) = 0 THEN
                sys_linkage_func := 'ST';
            ELSIF sl_function( j ) = 1 THEN
                   sys_linkage_func := 'OT';
            ELSIF sl_function( j ) = 2 THEN
                   sys_linkage_func := 'ER';
            ELSIF sl_function( j ) = 3 THEN
                   sys_linkage_func := 'USG';
            ELSIF sl_function( j ) = 4 THEN
                   sys_linkage_func := 'VI';
            ELSE
                   sys_linkage_func := NULL;
            END IF;
/* Indicator variables Bug# 634414 */
            NC := 1204;
    /* MCB Changes : Added the new param to the procedure Call_Calc_Bill_Amount
*/
            pa_billing.Call_Calc_Bill_Amount( 'ACTUAL',ei_id( j ),
                                                   sys_linkage_func,
                                                   amount,
                                                   bill_rate_flag,
                                                   status,
                                                   bill_trans_currency_code,
                                                   bill_trans_bill_rate,
                                                   rate_source_id,
                                                   markup_percentage);
/* Indicator variables Bug# 634414 */
            NC := 1205;
            IF ( status = 0 and amount is null ) THEN
                 null;
            ELSIF ( status = 0 and amount is not null ) THEN
                    bill_amount( j ) := to_char(amount);
                    fetched_amount := TRUE;
/* Indicator variables bug# 634414 */
            /* MCB Changes : Copy the output variables  from the procedure Call_Calc_Bill_Amount
                             to array variables    */


               x_bill_trans_currency_code(j) := bill_trans_currency_code;
               x_bill_trans_bill_rate(j) := to_char(bill_trans_bill_rate);
               x_rate_source_id(j) := rate_source_id;
               x_markup_percentage(j) := to_char(markup_percentage);

              /* End MCB Changes */

                  process_irs:= 'Y';
            ELSIF ( status > 0 ) THEN
                    fetched_amount := TRUE;
                    reason( j ) := 'CALC_BILL_AMOUNT_EXT_FAIL';
                    error_code( j ) := 1;
                    bill_amount( j ) := NULL;

                   /* MCB Changes : Initialize the MCB related columns */

                      x_bill_trans_currency_code(j) := NULL;
                      x_bill_trans_bill_rate(j) := NULL;
                      x_rate_source_id(j) := NULL;
                      x_markup_percentage(j) := NULL;
            ELSE
                    RAISE system_error;
            END IF;

        END IF;

/*-------------------------------------------------------------------------------------

 For Revenue :
 -------------
 check whether revenue distribution is WORK, labor/non labor
 schedule type is Indirect, irs sch id exists and ei is labor/
 non labor. If all of this is true only then call the api to
 calculate the indirect cost for Revenue.

 For Labor/non Labor expenditure items :
 -------------------------------------
 -------------------------------------------------------------------------------------*/

          /* The host variable array t_lab_sch is not used because of the ORA-1458
             Error (Invalid Length inside a variable string). Instead the select
             statement below has been used for populating labor_sch_type .
             This is a workaround and needs to be removed in future the select
             below is unneccessary and will affect performance */
/* Indicator variables Bug# 634414 */
          NC := 1206;
           select t.labor_sch_type
             into labor_sch_type
             from pa_tasks t, pa_expenditure_items_all e
            where t.task_id = e.task_id
              and e.expenditure_item_id = ei_id( j );
/* Indicator variables Bug# 634414 */
           NC := 1207;
           IF (  d_rule_decode( j ) = 1                           AND
                 t_rev_irs_id( j ) IS NOT NULL                          AND
                 labor_sch_type = 'I'                           ) AND
                 NOT fetched_amount                                 THEN


/* Bug # 2208288 - Added the param l_ind_cost_project */

                 pa_cost_plus.get_exp_item_indirect_cost(
                                                         ei_id( j ), 'R',
                                                         amount,
                                                         l_ind_cost_acct,
                                                         l_ind_cost_denm,
                                                         l_ind_cost_project,
                                                         rate_sch_rev_id,
                                                         compiled_set_id,
                                                         status, stage );

/*-------------------------------------------------------------------------------------

 Check for success/failure of the called api :
 ---------------------------------------------

 check whether indirect amount and sch rev id were retrieved successfully,
 if yes then assign these values to the host array variables for indirect
 amount and rate sct rev id respectively, else set error code to 1 which
 stands for 'NO COMPILED MULTIPLIER'.

 --------------------------------------------------------------------------------------*/
/* Indicator Variables Bug# 634414 */
                NC := 1208;
                 IF ( status = 100 and stage <> 400 ) THEN
                     rev_comp_set_id( j ) := NULL;
                     rev_amount( j ) := NULL;
         error_code( j ) := 1;
         message_code:= 'Error encountered during processing IRS....' ;
                     insert_error_message := TRUE;

/*-----------------------------------------------------------------------------------------
  NO_COST_BASE case whereby raw_revenue amount should be populated with
  raw_cost.
  ----------------------------------------------------------------------------------------*/
                 ELSIF ( status = 100 and stage = 400 ) THEN

                     rev_comp_set_id( j ):= 0;
                     rev_amount( j ) :=  to_char(0);
                     process_irs:= 'Y';
/*-----------------------------------------------------------------------------------------
  If everything is retrieved as expected which means success.
  ----------------------------------------------------------------------------------------*/
                 ELSIF ( rate_sch_rev_id IS NOT NULL AND
                         compiled_set_id IS NOT NULL AND
                         amount          IS NOT NULL AND
                         status = 0 ) THEN

                         rev_comp_set_id( j ):= compiled_set_id;
                        /* MCB changes : If Multi currency billing enabled then take the denom cost otherwise take the amount */

                        IF (mcb_flag(j) = 'Y') THEN
                  /* Commenting the following line for bug 2638840
                    rev_amount( j ) :=  to_char(l_ind_cost_denm); */

 /* Changes for bug 2638840 */
  /* Bug 2638840 : Get the BTC_COST_BASE_REV_CODE from pa_projects_all table */
BEGIN

   /* Added the following nvl so that code doesn't break even if upgrade script fails - For bug 2724185 */

   select nvl(BTC_COST_BASE_REV_CODE,'EXP_TRANS_CURR')
   into l_mcb_cost_flag
   from pa_projects_all
   where project_id =(select project_id from pa_expenditure_items_all where expenditure_item_id=ei_id(j));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   IF g1_debug_mode  = 'Y' THEN
   	PA_MCB_INVOICE_PKG.log_message('forecast_rev_billamount: ' || 'No Data Found for the ei_id:' ||  ei_id(j));
   END IF;
    RAISE system_error;
END;

     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('forecast_rev_billamount: ' || 'BTC_COST_BASE_REV_CODE  :' || l_mcb_cost_flag);
        PA_MCB_INVOICE_PKG.log_message('forecast_rev_billamount: ' || 'mcb_cost_bug l_ind_cost_denm ' || l_ind_cost_denm);
        PA_MCB_INVOICE_PKG.log_message('forecast_rev_billamount: ' || 'mcb_cost_bug l_ind_cost_acct ' || l_ind_cost_acct);
        PA_MCB_INVOICE_PKG.log_message('forecast_rev_billamount: ' || 'mcb_cost_bug amount ' || amount);
        PA_MCB_INVOICE_PKG.log_message('forecast_rev_billamount: ' || 'mcb_cost_bug l_indirect_cost_project ' || l_ind_cost_project);
     END IF;
           /* Bug 2638840 : Based on the BTC get the cost amount */
                             IF (l_mcb_cost_flag = 'EXP_TRANS_CURR') THEN

                                     rev_amount( j ) :=  to_char(l_ind_cost_denm);

                                 ELSIF (l_mcb_cost_flag = 'EXP_FUNC_CURR') THEN

                                     rev_amount( j ) :=   to_char(l_ind_cost_acct);

                                 ELSIF (l_mcb_cost_flag = 'PROJ_FUNC_CURR') THEN

                                     rev_amount( j ) :=   to_char(amount);

                                ELSIF (l_mcb_cost_flag = 'PROJECT_CURR') THEN

                                    rev_amount( j ) :=   to_char(l_ind_cost_project);

                                 END IF;


                 IF g1_debug_mode  = 'Y' THEN
                 	PA_MCB_INVOICE_PKG.log_message('forecast_rev_billamount: ' || 'mcb_cost_bug rev_amount ' || rev_amount(j));
                 END IF;
      /* End of Changes for bug 2638840 */
                        ELSE
                         rev_amount( j ) :=  to_char(amount);
                        END IF;
                         process_irs:= 'Y';
/*-----------------------------------------------------------------------------------------
  This case maynot arise, but has been added for safety reasons.
--------------------------------------------------------------------------------------*/
                 ELSE

                         RAISE system_error;
                 END IF;

/*--------------------------------------------------------------------------------------------
 if no condition satisfies which indirectly means that we need to process
 for bill rate schedule.
 -------------------------------------------------------------------------------------------*/
            ELSE
                process_bill_rate:= 'Y';
                rev_comp_set_id( j ) := NULL;
                rev_amount( j ) := NULL;

            END IF;


/*--------------------------------------------------------------------------------------------
   Rejection code error message which would be eventually populated in
   pa_expenditure_items_all table.
 --------------------------------------------------------------------------------------------*/
NC := 1209;

          IF ( insert_error_message ) THEN
            IF (stage = 200) THEN
                reason( j ) := 'NO_IND_RATE_SCH_REVISION';
            ELSIF (stage = 300) THEN
                reason( j ) := 'NO_COST_PLUS_STRUCTURE';
            ELSIF (stage = 500) THEN
                reason( j ) := 'NO_ORGANIZATION';
            ELSIF (stage = 600) THEN
                reason( j ) := 'NO_COMPILED_MULTIPLIER';/* Bug 5884742`*/
            ELSIF (stage = 700) THEN
                reason( j ) := 'NO_ACTIVE_COMPILED_SET';
            ELSE
                reason( j ) := 'GET_INDIRECT_COST_FAIL';
            END IF;
       END IF;

         j := j + 1;

       NC := 1210;

    END LOOP;

    NC := 12100;

EXCEPTION

WHEN system_error THEN
      message_code:= 'ORA error encountered while processing pa_client_extn.calc_bill_amount';

WHEN OTHERS THEN
   NC := -999;
   message_code:= sqlerrm( sqlcode );

END forecast_rev_billamount;

---******************* PROCEDURE Get_WriteOff_Rep_Revenue_Amt *******************---
/* This Procedure is added by Manish Gupta on 05/08/03 for MRC Schema Changes */

PROCEDURE Get_WriteOff_Rep_Revenue_Amt (p_project_id            IN  NUMBER DEFAULT NULL,
                                        p_task_id               IN  NUMBER DEFAULT NULL,
                                        p_agreement_id          IN  NUMBER DEFAULT NULL,
                                        p_funding_flag          IN  VARCHAR2 DEFAULT NULL,
                                        px_writeoff_amount      IN OUT NOCOPY NUMBER, /* It is funding currency MCB */ --File.Sql.39 bug 4440895
                                        x_rep_projfunc_writeoff_amt   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ) IS
/* ------------------------------------------------------------------------
|| Procedure    :   Get_WriteOff_Rep_Revenue_Amt                           ||
|| Description  :   To get  Revenue WriteOff Amount for Reporting Currency ||
|| Parameters   :   Project ID               (IN)                          ||
||                  Task ID                  (IN)                          ||
||                  Agreement ID             (IN)                          ||
||                  Funding Flag             (IN)                          ||
||                  WriteOff Amount          (IN)    (OUT)                 ||
||                  Rep Projfunc Writeoff Amount (OUT)                     ||
 --------------------------------------------------------------------------*/

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
l_writeoff_amount NUMBER := px_writeoff_amount;

BEGIN

    IF g1_debug_mode  = 'Y' THEN
       PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.Get_WriteOff_Rep_Revenue_Amt :');
    END IF;

    BEGIN
        IF p_task_id IS NOT NULL THEN

          IF p_agreement_id IS NOT NULL THEN

           /*
           |  If the search has project id, task id, agreement id
           |     Driving Path  Events -> Event Types -> ERDL -> DR               */

Null;

          ELSE

           /*
           |  If the search has project id, task id, agreement id is null
           |     Driving Path  Events -> Event Types                */

               /* MCB related changes */
NULL;
           END IF;

        ELSIF p_project_id IS NOT NULL THEN

          IF p_agreement_id IS NOT NULL THEN

           /*
           | If Project id is not null, agreement id is not null
           |     Driving Path  Events -> Event Types -> ERDL -> DR               */
          NULL;
          ELSE

           /*
           | If Project id is not null, agreement id  is null
           |     Driving Path  Events -> Event Types           */

                /* MCB related changes */
Null;

          END IF;

        ELSIF p_agreement_id IS NOT NULL THEN

           /*
           | If Agreement id is not null, agreement id (might be null)
           |  Driving  path   DR -> ERDL -> Events -> Event Types           */

          NULL;
        ELSE
            /*
            | If Project ID is null, Task ID is null, Agreement ID is null
            | Driving path  Event Type -> Events -> ERDL -> DR              */
  NULL;

        END IF;

        IF g1_debug_mode  = 'Y' THEN
	   PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing.Get_WriteOff_Rep_Revenue_Amt   :');
        END IF;

        EXCEPTION
          WHEN OTHERS THEN
           px_writeoff_amount := l_writeoff_amount; -- NOCOPY
           x_rep_projfunc_writeoff_amt := null; -- NOCOPY

             RAISE;
    END;

END Get_WriteOff_Rep_Revenue_Amt;

/* End of Addition for MRC Schema Changes */
PROCEDURE Call_Calc_Non_Labor_Bill_Amt
(
x_transaction_type       in varchar2 default 'ACTUAL',
x_expenditure_item_id   IN      NUMBER,
x_sys_linkage_function  IN      VARCHAR2,
x_amount                IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_expenditure_type      IN      VARCHAR2,
x_non_labor_resource    IN      VARCHAR2,
x_non_labor_res_org     IN      NUMBER,
x_bill_rate_flag        IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_status                IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_bill_trans_currency_code      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_bill_txn_bill_rate    OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_markup_percentage     OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_rate_source_id        OUT     NOCOPY NUMBER) --File.Sql.39 bug 4440895
 IS

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

l_amount NUMBER := x_amount;
l_bill_rate_flag VARCHAR2(1) := x_bill_rate_flag;

BEGIN
/* Change the call and aded new paras in this procs. for MCB2 */
IF g1_debug_mode  = 'Y' THEN
        PA_MCB_INVOICE_PKG.log_message('Entering pa_billing.Call_Calc_Non_Labor_Bill_Amt   :');
END IF;
 PA_NON_LABOR_BILL_CLT_EXTN.Calc_Bill_Amount(
                 x_transaction_type          =>   x_transaction_type        ,
                 x_expenditure_item_id       =>   x_expenditure_item_id     ,
                 x_sys_linkage_function      =>   x_sys_linkage_function    ,
                 x_amount                    =>   x_amount                  ,
                 x_expenditure_type          =>   x_expenditure_type        ,
                 x_non_labor_resource        =>   x_non_labor_resource      ,
                 x_non_labor_res_org         =>   x_non_labor_res_org       ,
                 x_bill_rate_flag            =>   x_bill_rate_flag          ,
                 x_status                    =>   x_status                  ,
                 x_bill_trans_currency_code  =>   x_bill_trans_currency_code,
                 x_bill_txn_bill_rate        =>   x_bill_txn_bill_rate      ,
                 x_markup_percentage         =>   x_markup_percentage       ,
                 x_rate_source_id            =>   x_rate_source_id
                 );

IF g1_debug_mode  = 'Y' THEN
        PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing.Call_Calc_Non_Labor_Bill_Amt   :');
END IF;
EXCEPTION WHEN OTHERS THEN
--      DBMS_OUTPUT.PUT(SQLERRM);
        x_amount :=  l_amount; --NOCOPY
        x_bill_rate_flag  := l_bill_rate_flag; --NOCOPY
        x_bill_trans_currency_code := NULL; --NOCOPY
        x_bill_txn_bill_rate := NUll; --NOCOPY
        x_markup_percentage  := NULL; --NOCOPY
        x_rate_source_id     := NULL; --NOCOPY
        RAISE;

END Call_Calc_Non_Labor_Bill_Amt;


 FUNCTION  Validate_Task_Customer(
           p_project_id           IN       NUMBER
           , p_customer_id        IN       NUMBER
           , p_task_id            IN       NUMBER
) RETURN VARCHAR2 as

    l_exist_flag   varchar2(1);

    Begin

    /*  Check whether the customer is associated with any of the top tasks */

              Select 'Y'
              Into   l_exist_flag
              From   dual
              Where  exists ( select null
                              from   pa_tasks
                              where  project_id  = p_project_id
                              and    customer_id = p_customer_id
                              and    task_id     = top_task_id
                              and    decode(p_task_id
                                      , null, top_task_id
                                      , p_task_id) = top_task_id
                              );

              Return l_exist_flag;

    Exception When others Then
              Return 'N';
    End Validate_Task_Customer;

END pa_billing;

/
