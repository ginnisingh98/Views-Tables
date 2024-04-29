--------------------------------------------------------
--  DDL for Package Body PA_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_PUB" AS
/* $Header: PAXIPUBB.pls 120.5.12010000.2 2010/04/05 12:01:47 rmandali ship $ */

--------------------------------------
--  PROCEDURE/FUNCTION IMPLEMENTATIONS
--

---------------------
--  GLOBALS
--
status			VARCHAR2(240);     -- For error messages from subprogs
last_updated_by		NUMBER(15);	   --|
created_by   		NUMBER(15);        --|
last_update_login	NUMBER(15);        --|Standard Who Columns
-- request_id		NUMBER(15);        --|
program_application_id	NUMBER(15);        --|
program_id		NUMBER(15);        --|

-- get_budget_amount modified to use User defined budget types
-- and use api pa_budget_utils.get_project_task_totals
--
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE get_budget_amount( X2_project_id           NUMBER,
			 X2_task_id                  NUMBER DEFAULT NULL,
			 X2_revenue_amount       OUT NOCOPY REAL,
			 X2_cost_amount    	 OUT NOCOPY REAL,
                         P_cost_budget_type_code IN  VARCHAR2  DEFAULT NULL,
                         P_rev_budget_type_code  IN  VARCHAR2  DEFAULT NULL,
                         P_cost_plan_type_id     IN  NUMBER    DEFAULT NULL, /* Added for Fin Plan impact */
                         P_rev_plan_type_id      IN  NUMBER    DEFAULT NULL, /* Added for Fin Plan impact */
                         X_cost_budget_type_code OUT NOCOPY VARCHAR2,
                         X_rev_budget_type_code  OUT NOCOPY VARCHAR2,
			 X_error_message	 OUT NOCOPY VARCHAR2,
			 X_status		 OUT NOCOPY NUMBER
			 ) IS

-- local variables for budget codes
l_cost_budget_type_code VARCHAR2(30) ;
l_rev_budget_type_code  VARCHAR2(30) ;
l_cost_budget_status_code VARCHAR2(1) ;
l_rev_budget_status_code  VARCHAR2(1) ;
dummy                     CHAR(1);
err_msg			  VARCHAR2(240);
err_status                NUMBER;
l_status                 NUMBER;
l_cost_budget_version_id      NUMBER;
l_rev_budget_version_id       NUMBER;
l_raw_cost_total              REAL := 0;
l_revenue_total               REAL := 0;
l_quantity_total              NUMBER;
l_burdened_cost_total         NUMBER;
l_err_code                    NUMBER;
l_err_stage                   VARCHAR2(30);
l_err_stack                   VARCHAR2(630);

/* Added for Fin Plan Impact */
l_cost_plan_type_id                NUMBER;
l_rev_plan_type_id                 NUMBER;
l_cost_plan_version_id             NUMBER;
l_rev_plan_version_id              NUMBER;
/* Till here */

invalid_cost_budget_code EXCEPTION;
invalid_rev_budget_code  EXCEPTION;
rev_budget_not_baselined EXCEPTION;
cost_budget_not_baselined EXCEPTION;

BEGIN
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_pub.get_budget_amount: ');
END IF;
   X_status := 0;
   X_error_message := NULL;
   BEGIN
-- If user doesnt provide the budget get the default value from biling extensions
--

   IF (P_cost_budget_type_code IS NULL OR P_rev_budget_type_code IS NULL
      OR P_cost_plan_type_id IS NULL OR P_rev_plan_type_id IS NULL ) /* Added for Fin plan impact */
       THEN

      SELECT   DECODE(P_cost_budget_type_code,NULL,default_cost_budget_type_code, P_cost_budget_type_code),
               DECODE(P_rev_budget_type_code,NULL,default_rev_budget_type_code,P_rev_budget_type_code),
               DECODE(P_cost_plan_type_id,NULL,default_cost_plan_type_id,
                      P_cost_plan_type_id),                  /* Added for Fin plan impact */
               DECODE(P_rev_plan_type_id,NULL,default_rev_plan_type_id,
                      P_rev_plan_type_id)                  /* Added for Fin plan impact */
      INTO     l_cost_budget_type_code,
	       l_rev_budget_type_code,
	       l_cost_plan_type_id,
	       l_rev_plan_type_id
      FROM     pa_billing_extensions
      WHERE    billing_extension_id=pa_billing.GetBillingExtensionId;

   END IF;


  -- The plan code should be a valid code and of the right version type
  -- If invalid then process will check for budget code
  /* Added this select for Fin plan Impact */
  BEGIN
   SELECT  'x'
   INTO    dummy
   FROM    dual
   WHERE   EXISTS( SELECT *
                   FROM pa_fin_plan_types_b f
                   WHERE f.fin_plan_type_id=l_cost_plan_type_id );

  EXCEPTION
   WHEN NO_DATA_FOUND THEN

    -- The budget code should be a valid code and of the right amount code
    -- If invalid then raise appropriate exception

    BEGIN

      SELECT  'x'
      INTO    dummy
      FROM    pa_budget_types
      WHERE   budget_type_code = l_cost_budget_type_code
      AND     budget_amount_code = 'C';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         raise invalid_cost_budget_code;
    END;

  END; /* End of newly added code for Fin plan Impact */




  /* Added this select for Fin plan Impact */
  BEGIN
   SELECT  'x'
   INTO    dummy
   FROM    dual
   WHERE   EXISTS( SELECT *
                   FROM  pa_fin_plan_types_b f
                   WHERE f.fin_plan_type_id=l_rev_plan_type_id );

  EXCEPTION
   WHEN NO_DATA_FOUND THEN

    -- The budget code should be a valid code and of the right amount code
    -- If invalid then raise appropriate exception

    BEGIN

      SELECT  'x'
      INTO    dummy
      FROM    pa_budget_types
      WHERE   budget_type_code = l_rev_budget_type_code
      AND     budget_amount_code = 'R';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise invalid_rev_budget_code;
    END ;

  END; /* End of newly added code for Fin plan Impact */

  -- Get the budget version id for cost and revenue plan
  -- Changed to use api pa_budget_utils.get_project_task_totals

  /* Added this select for Fin plan Impact */
  BEGIN

   SELECT v.budget_version_id
   INTO   l_cost_plan_version_id
   FROM   pa_budget_versions v
   WHERE  v.project_id = X2_project_id
   AND    v.current_flag = 'Y'
   AND    v.budget_status_code           = 'B'
   AND    v.fin_plan_type_id             = l_cost_plan_type_id
   AND    v.version_type IN ('COST','ALL');

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    --
    -- get the budget version id for cost and revenue budget
    -- Changed to use api pa_budget_utils.get_project_task_totals
    --

    BEGIN
      SELECT budget_version_id
      INTO   l_cost_budget_version_id
      FROM   pa_budget_versions pbv
      WHERE  project_id = X2_project_id
      AND    budget_type_code = l_cost_budget_type_code
      AND    budget_status_code = 'B'
      AND    current_flag = 'Y';

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
         raise cost_budget_not_baselined;
    END;

  END; /* End of newly added code for Fin plan Impact */

   l_cost_budget_version_id  := NVL(l_cost_plan_version_id,l_cost_budget_version_id);

  /* Added this select for Fin plan Impact */
  BEGIN

   SELECT v.budget_version_id
   INTO   l_rev_plan_version_id
   FROM   pa_budget_versions v
   WHERE  v.project_id = X2_project_id
   AND    v.current_flag = 'Y'
   AND    v.budget_status_code           = 'B'
   AND    v.fin_plan_type_id             = l_rev_plan_type_id
   AND    v.version_type IN ('REVENUE','ALL');

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    --
    -- get the budget version id for cost and revenue budget
    -- Changed to use api pa_budget_utils.get_project_task_totals
    --

    BEGIN

      SELECT budget_version_id
      INTO   l_rev_budget_version_id
      FROM   pa_budget_versions pbv
      WHERE  project_id = X2_project_id
      AND    budget_type_code = l_rev_budget_type_code
      AND    budget_status_code = 'B'
      AND    current_flag = 'Y';

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
         raise rev_budget_not_baselined;
    END;

  END; /* End of newly added code for Fin plan Impact */

   l_rev_budget_version_id  := NVL(l_rev_plan_version_id,l_rev_budget_version_id);

   -- Call api to get cost budget amount
   --
   pa_budget_utils.get_project_task_totals
           (l_cost_budget_version_id ,
                            x2_task_id ,
                            l_quantity_total,
                            l_raw_cost_total ,
                            l_burdened_cost_total ,
                            l_revenue_total ,
                            l_err_code ,
                            l_err_stage,
                            l_err_stack );

X2_cost_amount := pa_currency.round_currency_amt(l_burdened_cost_total);

   -- Call api to get revenue budget amount
   --
   pa_budget_utils.get_project_task_totals
           (l_rev_budget_version_id ,
                            x2_task_id ,
                            l_quantity_total,
                            l_raw_cost_total ,
                            l_burdened_cost_total ,
                            l_revenue_total ,
                            l_err_code ,
                            l_err_stage,
                            l_err_stack );

X2_revenue_amount := pa_currency.round_currency_amt(l_revenue_total);

X_cost_budget_type_code := l_cost_budget_type_code;
X_rev_budget_type_code  := l_rev_budget_type_code;

-- If any exception then raise it to the calling pl/sql block
--
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_pub.get_budget_amount: ');
END IF;
   EXCEPTION
     WHEN invalid_cost_budget_code THEN
  	 status := pa_billing_values.get_message('INVALID_COST_BUDGET_TYPE');
	 l_status := 1;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN invalid_rev_budget_code  THEN
  	 status := pa_billing_values.get_message('INVALID_REV_BUDGET_TYPE');
	 l_status := 2;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN rev_budget_not_baselined  THEN
         status := pa_billing_values.get_message('REV_BUDGET_NOT_BASELINED');
	 l_status := 3;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN cost_budget_not_baselined THEN
         status := pa_billing_values.get_message('COST_BUDGET_NOT_BASELINED');
	 l_status := 4;
	 RAISE_APPLICATION_ERROR(-20101,status);
     WHEN OTHERS THEN
         status := substr(SQLERRM,1,240);
	 l_status := sqlcode;
	 RAISE;
     END;

EXCEPTION
	WHEN OTHERS THEN
--	DBMS_OUTPUT.PUT_LINE(status);
--	DBMS_OUTPUT.PUT_LINE(SQLERRM);
	X2_cost_amount := NULL;
	X2_revenue_amount := NULL;
	X_cost_budget_type_code := NULL;
	X_rev_budget_type_code  := NULL;
----

        X_error_message := status;
	X_status	:= l_status;

	insert_message
        (X_inserting_procedure_name =>'pa_billing_pub.get_budget_amount',
	 X_attribute1 => l_cost_budget_type_code,
	 X_attribute2 => l_rev_budget_type_code,
	 X_message => status,
         X_error_message=>err_msg,
         X_status=>err_status);

	 IF (l_status < 0 OR NVL(err_status,0) <0) THEN
	 RAISE;
	 END IF;

END get_budget_amount;

PROCEDURE get_amount(	X_project_id 	NUMBER,
			X_request_id	NUMBER,
			X_calling_process VARCHAR2,
			X_calling_place VARCHAR2 DEFAULT NULL,
			X_which_amount	VARCHAR2 DEFAULT 'R',
			X_amount OUT NOCOPY NUMBER,
			X_top_task_id 	NUMBER DEFAULT NULL,
			X_system_linkage VARCHAR2 DEFAULT NULL,
			X_cost_base	VARCHAR2 DEFAULT NULL,
			X_CP_structure	VARCHAR2 DEFAULT NULL,
			X_CB_type	VARCHAR2 DEFAULT NULL) IS


----------------------------
--  LOCAL CURSOR DECLARATION
--
  total_amount REAL;

  CURSOR ByRequest IS
	SELECT	ei.expenditure_item_id eid,
		decode( X_which_amount, 'I', nvl(rdl.bill_amount,0),
			      		'R', nvl(rdl.amount,0),
				   	'C', nvl(ei.raw_cost,0),
					'B', nvl(ei.burden_cost,0), nvl(ei.raw_cost,0)) amt
	FROM	pa_tasks t,
		pa_expenditure_items_all ei,
		pa_expenditure_items_all ei2,
		pa_cust_rev_dist_lines rdl
	WHERE
		ei.task_id = t.task_Id
	AND	(t.top_task_id = X_top_task_id
		OR X_top_task_id IS NULL)
	AND	rdl.project_id between nvl(X_project_id, 0)
			and nvl(X_project_id, 9999999999)
	AND	(ei.system_linkage_function||'' = X_system_linkage
		OR X_system_linkage IS NULL)
	AND	rdl.request_id = X_request_id
	AND	(EXISTS
		(select '1'
		 from    pa_cost_base_exp_types cb
		 where   cb.expenditure_type = ei.expenditure_type
		 and 	 cb.cost_base = X_cost_base
		 and	 cb.cost_plus_structure = X_CP_structure
		 and 	 cb.cost_base_type = X_CB_type)
		OR
		  (	X_cost_base IS NULL
		     OR X_CP_structure IS NULL
		     OR X_CB_type IS NULL))
	AND	ei.expenditure_item_id = rdl.expenditure_item_id
	AND	rdl.line_num = decode( X_which_amount, 'C', 1,
						     'B', 1, rdl.line_num)
	AND	ei.adjusted_expenditure_item_id = ei2.expenditure_item_id (+)
	AND	((X_calling_place = 'ADJ'
		        AND (rdl.line_num_reversed IS NOT NULL
			    OR  (ei.adjusted_expenditure_item_id IS NOT NULL
				and ei2.request_id <> X_request_id)))
		OR  (X_calling_place = 'REG'
		    AND	(rdl.line_num_reversed IS NULL
			and	rdl.reversed_flag IS NULL
			and 	(ei.adjusted_expenditure_item_id IS NULL
				or ei2.request_id = X_request_id))));

		-- For explanation of adjustment logic refer to explanation
		-- under function rdl_amount.
		-- In the ADJ section get all adjusting ei's, except those that
		-- are adjusting other ei's which are also being processed in
		-- this same run
		-- In the regular section get all regular ei's and also all
		-- adjusting ei's that are adjusting expenditure items being
		-- processed in this same run

Rqst_rec	ByRequest%ROWTYPE;


  CURSOR ByRequestInv IS
	SELECT	ei.expenditure_item_id eid,
		decode( X_which_amount, 'I', nvl(rdl.bill_amount,0),
			      		'R', nvl(rdl.amount,0),
				   	'C', nvl(ei.raw_cost,0),
					'B', nvl(ei.burden_cost,0), nvl(ei.raw_cost,0)) amt
	FROM	pa_tasks t,
		pa_expenditure_items_all ei2,
		pa_expenditure_items_all ei,
		pa_cust_rev_dist_lines rdl2,
		pa_cust_rev_dist_lines rdl,
		pa_draft_invoice_items pdii,
		pa_draft_invoices pdi
	WHERE
		ei.task_id = t.task_Id
	AND	(t.top_task_id = X_top_task_id
		OR X_top_task_id IS NULL)
	AND	pdi.project_id between nvl(X_project_id, 0)
			and nvl(X_project_id, 9999999999)
	AND	(ei.system_linkage_function||'' = X_system_linkage
		OR X_system_linkage IS NULL)
	AND	pdii.project_id = rdl.project_id
	AND	pdii.draft_invoice_num = rdl.draft_invoice_num
	AND	pdii.line_num = rdl.draft_invoice_item_line_num
	AND	pdii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
	AND	pdii.project_id = pdi.project_id
	AND	pdii.draft_invoice_num = pdi.draft_invoice_num
	AND	pdi.request_id = X_request_id
	AND	ei.adjusted_expenditure_item_id = ei2.expenditure_item_id (+)
	AND	ei2.expenditure_item_id = rdl2.expenditure_item_id (+)
	AND	(EXISTS
		(select '1'
		 from    pa_cost_base_exp_types cb
		 where   cb.expenditure_type = ei.expenditure_type
		 and 	 cb.cost_base = X_cost_base
		 and	 cb.cost_plus_structure = X_CP_structure
		 and 	 cb.cost_base_type = X_CB_type)
		OR
		  (	X_cost_base IS NULL
		     OR X_CP_structure IS NULL
		     OR X_CB_type IS NULL))
	AND	ei.expenditure_item_id = rdl.expenditure_item_id
	AND	rdl.line_num = decode( X_which_amount, 'C', 1,
						     'B', 1, rdl.line_num)
	AND	((X_calling_place = 'ADJ'
		        AND (rdl.line_num_reversed IS NOT NULL
			    OR  (ei.adjusted_expenditure_item_id IS NOT NULL
				and rdl2.draft_invoice_num <> rdl.draft_invoice_num)))
		OR  (X_calling_place = 'REG'
		    AND	(rdl.line_num_reversed IS NULL
			and	rdl.reversed_flag IS NULL
			and 	(ei.adjusted_expenditure_item_id IS NULL
				or rdl2.draft_invoice_num = rdl.draft_invoice_num))));

RqstInv_rec	ByRequestInv%ROWTYPE;

  CURSOR ByProject IS
	SELECT	ei.expenditure_item_id eid,
		decode(X_which_amount, 'C', nvl(ei.raw_cost,0),
			      	       'B', nvl(ei.burden_cost,0),
				            nvl(ei.burden_cost,0)) amt,
		decode(ei.adjusted_expenditure_item_id, NULL, 'N','Y') ei_adj
	FROM	pa_expenditure_items_all ei,
            /*	pa_expenditure_items_all ei2, commented for Bug#2499051*/
		pa_tasks t
	WHERE
		ei.task_id = t.task_Id
	AND	(t.top_task_id = X_top_task_id
		OR X_top_task_id IS NULL)
	AND	t.project_id = X_project_id
	AND	(ei.system_linkage_function = X_system_linkage
		OR X_system_linkage IS NULL)
	AND	(EXISTS
		(select '1'
		 from    pa_cost_base_exp_types cb
		 where   cb.expenditure_type = ei.expenditure_type
		 and 	 cb.cost_base = X_cost_base
		 and	 cb.cost_plus_structure = X_CP_structure
		 and 	 cb.cost_base_type = X_CB_type)
		OR
		  (	X_cost_base IS NULL
		     OR X_CP_structure IS NULL
		     OR X_CB_type IS NULL))
	AND	(ei.request_id = X_request_id
		OR X_request_id IS NULL);

Proj_rec	ByProject%ROWTYPE;



BEGIN

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_pub.get_amount: ');
END IF;
  total_amount := 0;

  IF (X_Request_id IS NULL) THEN                           -->No RqstId given

    IF (X_which_amount = 'I' OR X_which_amount = 'R') THEN -->Want Inv/Rev amts
	FOR Proj_rec IN ByProject LOOP
	  total_amount := total_amount +
			nvl(pa_billing_amount.rdl_amount(X_which_amount,
				Proj_rec.eid, X_calling_place, Proj_rec.ei_adj),0);
	END LOOP;
    ELSE                                                   -->Want cost amounts
	FOR Proj_rec IN ByProject LOOP
	  total_amount := total_amount + nvl(Proj_rec.amt,0);
	END LOOP;
    END IF;

  ELSE                                                     -->Request Id given
    IF (X_calling_process = 'Invoice') THEN
      FOR RqstInv_rec IN ByRequestInv LOOP
           total_amount := total_amount + nvl(RqstInv_rec.amt,0);
      END LOOP;

    ELSE

      FOR Rqst_rec IN ByRequest LOOP
          total_amount := total_amount + nvl(Rqst_rec.amt,0);
      END LOOP;

    END IF;

  END IF;
  X_amount := pa_currency.round_currency_amt(total_amount);

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_pub.get_amount: ');
END IF;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
--    	 	DBMS_OUTPUT.PUT_LINE(SQLERRM);
		RAISE;
	WHEN OTHERS THEN
--		DBMS_OUTPUT.PUT_LINE(SQLERRM);
                X_amount := NULL;
		RAISE;
END get_amount;




PROCEDURE insert_message(X_inserting_procedure_name 	VARCHAR2,
			X_message			VARCHAR2,
			X_attribute1			VARCHAR2 DEFAULT NULL,
			X_attribute2			VARCHAR2 DEFAULT NULL,
			X_attribute3			VARCHAR2 DEFAULT NULL,
			X_attribute4			VARCHAR2 DEFAULT NULL,
			X_attribute5			VARCHAR2 DEFAULT NULL,
			X_attribute6			VARCHAR2 DEFAULT NULL,
			X_attribute7			VARCHAR2 DEFAULT NULL,
			X_attribute8			VARCHAR2 DEFAULT NULL,
			X_attribute9			VARCHAR2 DEFAULT NULL,
			X_attribute10			VARCHAR2 DEFAULT NULL,
			X_attribute11			VARCHAR2 DEFAULT NULL,
			X_attribute12			VARCHAR2 DEFAULT NULL,
			X_attribute13			VARCHAR2 DEFAULT NULL,
			X_attribute14			VARCHAR2 DEFAULT NULL,
			X_attribute15			VARCHAR2 DEFAULT NULL,
			X_error_message	OUT NOCOPY      VARCHAR2,
			X_status        OUT NOCOPY	NUMBER) IS

x_last_updated_by		NUMBER(15);	   --|
x_created_by   			NUMBER(15);        --|
x_last_update_login		NUMBER(15);        --|Standard Who Columns
x_request_id			NUMBER(15);        --|
x_program_application_id	NUMBER(15);        --|
x_program_id			NUMBER(15);        --|
xo_line_num			NUMBER(15);

BEGIN
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_pub.insert_message: ');
END IF;
   x_created_by      		:= FND_GLOBAL.USER_ID;
   x_last_updated_by 		:= FND_GLOBAL.USER_ID;
   x_last_update_login		:= FND_GLOBAL.LOGIN_ID;
   x_program_application_id	:= FND_GLOBAL.PROG_APPL_ID;
   x_program_id			:= FND_GLOBAL.CONC_PROGRAM_ID;

   X_status			:= 0;
   X_error_message		:= NULL;

SELECT max(BM.line_num)
INTO   xo_line_num
FROM   PA_BILLING_MESSAGES BM
WHERE  BM.project_id = pa_billing.GlobVars.ProjectId
AND    nvl(BM.task_Id,0) = nvl(pa_billing.GlobVars.TaskId,0)
AND    BM.calling_place = pa_billing.GlobVars.CallingPlace
AND    BM.calling_process = pa_billing.GlobVars.CallingProcess
AND    BM.request_id = pa_billing.GlobVars.ReqId;

IF 	(xo_line_num IS NULL) THEN
    	xo_line_num := 1;
ELSE 	xo_line_num := xo_line_num + 1;
END IF;

INSERT INTO PA_BILLING_MESSAGES
  (inserting_procedure_name,
   Billing_Assignment_Id,
   Project_Id,
   Task_Id,
   calling_place,
   calling_process,
   request_id,
   line_Num,
   message,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15)
VALUES (
   X_inserting_procedure_name,
   pa_billing.GlobVars.BillingAssignmentId,
   pa_billing.GlobVars.ProjectId,
   pa_billing.GlobVars.TaskId,
   pa_billing.GlobVars.CallingPlace,
   pa_billing.GlobVars.CallingProcess,
   pa_billing.GlobVars.ReqId,
   xo_line_num,
   X_message,
   sysdate,
   x_created_by,
   sysdate,
   x_last_updated_by,
   x_last_update_login,
   X_attribute1,
   X_attribute2,
   X_attribute3,
   X_attribute4,
   X_attribute5,
   X_attribute6,
   X_attribute7,
   X_attribute8,
   X_attribute9,
   X_attribute10,
   X_attribute11,
   X_attribute12,
   X_attribute13,
   X_attribute14,
   X_attribute15);

--commit;

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_pub.insert_message: ');
END IF;
EXCEPTION
	WHEN OTHERS THEN
--		DBMS_OUTPUT.PUT(SQLERRM);
		X_status := sqlcode;
		X_error_message := SQLERRM;
		RAISE;
END insert_message;


-- Modified to add the new audit parameters , validations for calling place

PROCEDURE insert_event (X_rev_amt			REAL DEFAULT NULL,
			X_bill_amt			REAL DEFAULT NULL,
			X_project_id			NUMBER DEFAULT NULL,
			X_event_type			VARCHAR2 DEFAULT NULL,
			X_top_task_id			NUMBER DEFAULT NULL,
			X_organization_id		NUMBER DEFAULT NULL,
			X_completion_date		DATE DEFAULT NULL,
                       	X_event_description		VARCHAR2 DEFAULT NULL,
                        X_event_num_reversed            NUMBER DEFAULT NULL,
			X_attribute_category		VARCHAR2 DEFAULT NULL,
                        X_attribute1			VARCHAR2 DEFAULT NULL,
                        X_attribute2			VARCHAR2 DEFAULT NULL,
                        X_attribute3			VARCHAR2 DEFAULT NULL,
                        X_attribute4			VARCHAR2 DEFAULT NULL,
                        X_attribute5			VARCHAR2 DEFAULT NULL,
                        X_attribute6			VARCHAR2 DEFAULT NULL,
                        X_attribute7			VARCHAR2 DEFAULT NULL,
                        X_attribute8			VARCHAR2 DEFAULT NULL,
                        X_attribute9			VARCHAR2 DEFAULT NULL,
                        X_attribute10			VARCHAR2 DEFAULT NULL,
                        X_audit_amount1	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount2	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount3	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount4	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount5	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount6	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount7	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount8	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount9	 IN      NUMBER DEFAULT NULL,
                        X_audit_amount10 IN      NUMBER DEFAULT NULL,
			X_audit_cost_budget_type_code IN      VARCHAR2 DEFAULT NULL,
			X_audit_rev_budget_type_code  IN      VARCHAR2 DEFAULT NULL,
                        x_inventory_org_id      IN      NUMBER   DEFAULT NULL,
                        x_inventory_item_id     IN      NUMBER   DEFAULT NULL,
                        x_quantity_billed       IN      NUMBER   DEFAULT NULL,
                        x_uom_code              IN      VARCHAR2 DEFAULT NULL,
                        x_unit_price            IN      NUMBER   DEFAULT NULL,
                        x_reference1            IN      VARCHAR2 DEFAULT NULL,
                        x_reference2            IN      VARCHAR2 DEFAULT NULL,
                        x_reference3            IN      VARCHAR2 DEFAULT NULL,
                        x_reference4            IN      VARCHAR2 DEFAULT NULL,
                        x_reference5            IN      VARCHAR2 DEFAULT NULL,
                        x_reference6            IN      VARCHAR2 DEFAULT NULL,
                        x_reference7            IN      VARCHAR2 DEFAULT NULL,
                        x_reference8            IN      VARCHAR2 DEFAULT NULL,
                        x_reference9            IN      VARCHAR2 DEFAULT NULL,
                        x_reference10           IN      VARCHAR2 DEFAULT NULL,
                        X_txn_currency_code                IN      VARCHAR2 DEFAULT NULL, /* Added  20 columns for MCB2 */
                        X_project_rate_type                IN      VARCHAR2 DEFAULT NULL,
                        X_project_rate_date                IN      DATE     DEFAULT NULL,
                        X_project_exchange_rate            IN      NUMBER   DEFAULT NULL,
                        X_project_func_rate_type           IN      VARCHAR2 DEFAULT NULL,
                        X_project_func_rate_date           IN      DATE     DEFAULT NULL,
                        X_project_func_exchange_rate       IN      NUMBER   DEFAULT NULL,
                        X_funding_rate_type                IN      VARCHAR2 DEFAULT NULL,
                        X_funding_rate_date                IN      DATE     DEFAULT NULL,
                        X_funding_exchange_rate            IN      NUMBER   DEFAULT NULL,
                        X_zero_revenue_amount_flag         IN      VARCHAR2 DEFAULT NULL,  /* Funding MRC Changes */
                        X_audit_cost_plan_type_id          IN      NUMBER   DEFAULT NULL, /* Added for Fin plan impact */
                        X_audit_rev_plan_type_id           IN      NUMBER   DEFAULT NULL, /* Added for Fin plan impact */
			X_error_message         OUT NOCOPY     VARCHAR2,
			X_status                OUT NOCOPY     NUMBER
			) IS

	XD_bill_trans_bill_amt		NUMBER(22,5); /* changed for MCB2 from rev/bill amount to trans bill/rev amount */
	XD_bill_trans_rev_amt		NUMBER(22,5);
	XD_organization_id	NUMBER(15);
	XD_completion_date	DATE;
        XD_event_description	VARCHAR2(240);
        XD_event_type		VARCHAR2(30);
	event_num		NUMBER(16);/*Increase size for bug 1742348*/
	invalid_id		EXCEPTION;
	event_type_error 	EXCEPTION;
	null_event_type_error 	EXCEPTION;
	invalid_project_event 	EXCEPTION;
	mandatory_prm_missing	EXCEPTION;
	zero_amounts		EXCEPTION;
        no_orig_event           EXCEPTION;
        invalid_calling_place   EXCEPTION;
        invalid_invent_id       EXCEPTION;

	l_status		NUMBER;
	err_status		NUMBER;
	err_message		VARCHAR2(240);

        /* MCB related changes as of 08/21/2001 by skannoji */
        l_project_id                      pa_projects_all.project_id%TYPE;
        l_multi_currency_billing_flag     pa_projects_all.multi_currency_billing_flag%TYPE;
        l_baseline_funding_flag           pa_projects_all.baseline_funding_flag%TYPE;
        l_revproc_currency_code           pa_projects_all.revproc_currency_code%TYPE;
        l_revproc_rate_type               pa_events.revproc_rate_type%TYPE;
        l_revproc_rate_date               pa_events.revproc_rate_date%TYPE;
        l_revproc_exchange_rate           pa_events.revproc_exchange_rate%TYPE;
        l_invproc_currency_code           pa_events.invproc_currency_code%TYPE;
        l_invproc_currency_type           pa_projects_all.invproc_currency_type%TYPE;
        l_invproc_rate_type               pa_events.invproc_rate_type%TYPE;
        l_invproc_rate_date               pa_events.invproc_rate_date%TYPE;
        l_invproc_exchange_rate           pa_events.invproc_exchange_rate%TYPE;
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
        l_txn_currency_code               pa_events.bill_trans_currency_code%TYPE;
        l_return_status                   VARCHAR2(30);
        l_msg_count                       NUMBER;
        l_msg_data                        VARCHAR2(30);
        l_found                           VARCHAR2(30);

        l_proj_exch_rate_not_passd             EXCEPTION;
        l_func_exch_rate_not_passd             EXCEPTION;
        l_fund_exch_rate_not_passd             EXCEPTION;
        l_proj_invalid_rate_type               EXCEPTION;
        l_func_invalid_rate_type               EXCEPTION;
        l_fund_invalid_rate_type               EXCEPTION;
        l_invalid_currency                     EXCEPTION;
        /* Till Here */

BEGIN
  BEGIN
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_billing_pub.insert_event:' );
END IF;
   -- Assigning who columns for insertion into PA_EVENTS.

   created_by      		:= FND_GLOBAL.USER_ID;
   last_updated_by 		:= FND_GLOBAL.USER_ID;
   last_update_login		:= FND_GLOBAL.LOGIN_ID;
   program_application_id	:= FND_GLOBAL.PROG_APPL_ID;
   program_id			:= FND_GLOBAL.CONC_PROGRAM_ID;

   X_status := 0;
   X_error_message := NULL;
   -- Validate Mandatory Parameters
	IF (pa_billing.GlobVars.BillingAssignmentId IS NULL OR
	   pa_billing.GlobVars.ReqId IS NULL OR
	   pa_billing.GlobVars.CallingPlace IS NULL OR
	   pa_billing.GlobVars.CallingProcess IS NULL) THEN
	raise mandatory_prm_missing;
	END IF;

    /* The following logic has been added for MCB2 functionality */
         l_project_id := nvl(X_project_id, pa_billing.GlobVars.ProjectId);
      PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  =>  l_project_id,
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

            l_txn_currency_code := NVL(x_txn_currency_code,l_projfunc_currency_code);
            BEGIN
               /* Validating Currency code */
               SELECT 'Y'
               INTO l_found
               FROM fnd_currencies /* Bug 4352166 Changed vl to base table*/
               WHERE currency_code = l_txn_currency_code
               AND TRUNC(SYSDATE) BETWEEN DECODE (TRUNC(start_date_active), NULL, TRUNC(SYSDATE),
                                           TRUNC(start_date_active))
                       AND DECODE(TRUNC(end_date_active), NULL, TRUNC(SYSDATE),TRUNC(end_date_active));
            EXCEPTION
              WHEN OTHERS THEN
               RAISE l_invalid_currency;
            END;

/* Rounding the transaction amount upto the precision of transaction currency for MCB2 */
	XD_bill_trans_rev_amt	:= PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(NVL(X_rev_amt, 0),l_txn_currency_code);
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('after pa_billing_pub.insert_event: rev amt'||to_char(XD_bill_trans_rev_amt));
END IF;
	XD_bill_trans_bill_amt 	:= PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(NVL(X_bill_amt,0),l_txn_currency_code);
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('after pa_billing_pub.insert_event: inv amt'||to_char(XD_bill_trans_bill_amt));
END IF;
  /* The following amounts have been commented for MCB2, the above amounts are satisfying the same requirement */
/* 	XD_bill_trans_rev_amt	:= (NVL(X_rev_amt, 0));
	XD_bill_trans_bill_amt 	:= (NVL(X_bill_amt,0)); */

   -- Get defaults for other non-mandatory parameters
	XD_completion_date 	:= nvl(X_completion_date,
					to_date(pa_billing.GlobVars.AccrueThruDate,'YYYY/MM/DD'));


-- Added check to prevent event creation from other calling places like 'PRE' 'POST'
-- 'DEL' etc.
--
        IF (pa_billing.GlobVars.CallingPlace NOT IN ('REG','ADJ','POST-REG')) THEN
	    raise invalid_calling_place;
        END IF;


	IF (X_organization_id IS NULL) THEN
	     XD_organization_id := pa_billing_values.get_dflt_org(
					nvl(X_project_id,
						pa_billing.GlobVars.ProjectId),
					nvl(X_top_task_id,
						pa_billing.GlobVars.TaskId));
	ELSE
           XD_organization_id := X_organization_id;
	END IF;

	IF (X_event_description 	IS NULL OR
	    X_event_type 		IS NULL) 	THEN
	     pa_billing_values.get_dflt_desc(pa_billing.GlobVars.BillingAssignmentId,
				XD_event_type, XD_event_description);
	     XD_event_description := nvl(X_event_description,
					XD_event_description);
	     XD_event_type 	  := nvl(X_event_type, XD_event_type);

	     IF (XD_event_type IS NULL) THEN
		RAISE null_event_type_error;
	     END IF;
	ELSE
	     XD_event_description 	:= X_event_description;
	     XD_event_type 		:= X_event_type;
	END IF;


   -- Validate Id's

	IF (pa_billing_validate.valid_proj_task_extn(
			nvl(X_project_id,  pa_billing.GlobVars.ProjectId),
			nvl(X_top_task_id, pa_billing.GlobVars.TaskId),
				pa_billing.GlobVars.BillingAssignmentId) AND
	    pa_billing_validate.valid_organization(XD_organization_id)) THEN
		NULL;
	ELSE
		RAISE INVALID_ID;
	END IF;



   -- Validate funding level

	IF (nvl(X_top_task_id, pa_billing.GlobVars.TaskId) IS NULL) THEN
	  IF (pa_billing_values.funding_level(nvl(X_project_id,
					pa_billing.GlobVars.ProjectId))
							<> 'PROJECT') THEN
	    RAISE invalid_project_event;
	  END IF;
	END IF;

   -- Funding MRC Changes added the flag X_zero_revenue_amount_flag
   -- If revenue amount is zero and X_zero_revenue_amount_flag = 'Y' is a valid case
   -- should not raise the exception. (Create zero dollar revenue event)

   -- Validate amounts based on which process is calling.
  IF ((((XD_bill_trans_rev_amt  = 0) AND (nvl(X_zero_revenue_amount_flag,'N') = 'N')) AND
        (XD_bill_trans_bill_amt = 0)) OR
       ((XD_bill_trans_rev_amt  = 0) AND  (nvl(X_zero_revenue_amount_flag,'N') = 'N')  AND
		pa_billing.GlobVars.CallingProcess = 'Revenue') OR
       ((XD_bill_trans_bill_amt = 0) AND
		pa_billing.GlobVars.CallingProcess = 'Invoice')) THEN
	RAISE zero_amounts;
   END IF;

   /* Modified the below condition for Bug 9154825 */
   -- Check original event num for the ADJ automatic events.
   IF (PA_BILLING.GetCallPlace = 'ADJ' AND
       (pa_billing.GlobVars.CallingProcess = 'Invoice' OR pa_billing.GlobVars.CallingProcess = 'Revenue') AND
        nvl(X_event_num_reversed, 0) = 0) THEN
        RAISE no_orig_event;
   END IF;

   event_num := pa_billing_seq.next_eventnum(
		nvl(X_project_id, pa_billing.GlobVars.ProjectId),
		nvl(X_top_task_id, pa_billing.GlobVars.TaskId));


/* Adding validation of newly added columns in event table for project contract integration */
   -- Validating inventory_org_id and inventory_item_id

	IF (x_inventory_org_id IS NOT NULL) THEN
	   IF (pa_billing_validate.valid_organization(x_inventory_org_id)) THEN
              NULL;
	   ELSE
              RAISE INVALID_INVENT_ID;
	   END IF;
        END IF;

	IF (x_inventory_item_id IS NOT NULL) THEN
          DECLARE
             l_dummy      varchar2(30);
          BEGIN
             SELECT  'Valid item'
             INTO    l_dummy
             FROM    mtl_item_flexfields
             WHERE   inventory_item_id = x_inventory_item_id;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               RAISE INVALID_INVENT_ID;
             WHEN TOO_MANY_ROWS THEN
               null;
          END;
        END IF;

       /* MCB2: The following code have benn added to populate the conversion attributes  */

            IF ( l_txn_currency_code <> l_projfunc_currency_code ) THEN
              l_found := NULL;
             IF ( X_project_func_rate_type IS NOT NULL) THEN
              BEGIN
                  SELECT 'found'
                  INTO l_found
                  FROM ( SELECT conversion_type, user_conversion_type
                         FROM   pa_conversion_types_v
                         WHERE  conversion_type <>'User'
                         AND    (pa_multi_currency.is_user_rate_type_allowed(
                                 l_txn_currency_code,
                                 l_projfunc_currency_code,
                         DECODE(l_projfunc_bil_rate_date_code,
                            'PA_INVOICE_DATE', NVL(X_project_func_rate_date,l_projfunc_bil_rate_date),
                            'FIXED_DATE', NVL(X_project_func_rate_date,l_projfunc_bil_rate_date)))= 'N')
                         UNION
                         SELECT conversion_type, user_conversion_type
                         FROM   pa_conversion_types_v
                         WHERE  pa_multi_currency.is_user_rate_type_allowed(
                                l_txn_currency_code,
                                l_projfunc_currency_code,
                                DECODE(l_projfunc_bil_rate_date_code,
                                   'PA_INVOICE_DATE',NVL(X_project_func_rate_date,l_projfunc_bil_rate_date),
                                   'FIXED_DATE',NVL(X_project_func_rate_date,l_projfunc_bil_rate_date) ))= 'Y')
                  WHERE DECODE(conversion_type,X_project_func_rate_type,'Y','N') = 'Y';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RAISE l_func_invalid_rate_type;
               END;
              END IF;

              IF ( X_project_func_rate_type IS NULL AND l_projfunc_bil_rate_type = 'User') THEN
                   l_projfunc_bil_rate_date := NULL;
                   IF ( X_project_func_exchange_rate IS NULL ) THEN
                      null;
                   ELSE
                      l_projfunc_bil_exchange_rate := X_project_func_exchange_rate;
                   END IF;
              ELSIF (X_project_func_rate_type = 'User') THEN
                   l_projfunc_bil_rate_date := NULL;
                   l_projfunc_bil_rate_type := X_project_func_rate_type;
                   IF ( X_project_func_exchange_rate IS NULL ) THEN
                     RAISE l_func_exch_rate_not_passd;
                   ELSE
                      l_projfunc_bil_exchange_rate := X_project_func_exchange_rate;
                   END IF;
              ELSIF ( X_project_func_rate_type <> 'User' OR l_projfunc_bil_rate_type <> 'User') THEN
                   l_projfunc_bil_rate_type := NVL(X_project_func_rate_type,l_projfunc_bil_rate_type);
                   l_projfunc_bil_exchange_rate := NULL;
              END IF;


              IF ( l_projfunc_bil_rate_type <> 'User' AND l_projfunc_bil_rate_date_code = 'FIXED_DATE'
                   AND X_project_func_rate_date IS NOT NULL ) THEN
                   l_projfunc_bil_rate_date := X_project_func_rate_date;
              ELSIF (l_projfunc_bil_rate_type <> 'User' AND l_projfunc_bil_rate_date_code = 'PA_INVOICE_DATE'
                    AND X_project_func_rate_date IS NOT NULL ) THEN
                    l_projfunc_bil_rate_date := X_project_func_rate_date;
              END IF;
            END IF;

            /* Project currency code logic */
            IF ( l_txn_currency_code <> l_project_currency_code ) THEN
              l_found := NULL;
             IF ( X_project_rate_type IS NOT NULL) THEN
               BEGIN
                  SELECT 'found'
                  INTO l_found
                  FROM ( SELECT conversion_type, user_conversion_type
                         FROM   pa_conversion_types_v
                         WHERE  conversion_type <>'User'
                         AND    (pa_multi_currency.is_user_rate_type_allowed(
                                 l_txn_currency_code,
                                 l_project_currency_code,
                         DECODE(l_project_bil_rate_date_code,
                            'PA_INVOICE_DATE', NVL(X_project_rate_date,l_project_bil_rate_date),
                            'FIXED_DATE', NVL(X_project_rate_date,l_project_bil_rate_date)))= 'N')
                         UNION
                         SELECT conversion_type, user_conversion_type
                         FROM   pa_conversion_types_v
                         WHERE  pa_multi_currency.is_user_rate_type_allowed(
                                l_txn_currency_code,
                                l_project_currency_code,
                                DECODE(l_project_bil_rate_date_code,
                                   'PA_INVOICE_DATE',NVL(X_project_rate_date,l_project_bil_rate_date),
                                   'FIXED_DATE',NVL(X_project_rate_date,l_project_bil_rate_date) ))= 'Y')
                  WHERE DECODE(conversion_type,X_project_rate_type,'Y','N') = 'Y';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                   RAISE  l_proj_invalid_rate_type;
               END;
              END IF;

              IF ( X_project_rate_type IS NULL AND l_project_bil_rate_type = 'User') THEN
                   l_project_bil_rate_date := NULL;
                   IF ( X_project_exchange_rate IS NULL ) THEN
                      null;
                   ELSE
                      l_project_bil_exchange_rate := X_project_exchange_rate;
                   END IF;
              ELSIF (X_project_rate_type = 'User') THEN
                   l_project_bil_rate_date := NULL;
                   l_project_bil_rate_type := X_project_rate_type;
                   IF ( X_project_exchange_rate IS NULL ) THEN
                     RAISE l_proj_exch_rate_not_passd;
                   ELSE
                      l_project_bil_exchange_rate := X_project_exchange_rate;
                   END IF;
              ELSIF ( X_project_rate_type <> 'User' OR l_project_bil_rate_type <> 'User') THEN
                   l_project_bil_rate_type := NVL(X_project_rate_type,l_project_bil_rate_type);
                   l_project_bil_exchange_rate := NULL;
              END IF;
              IF ( l_project_bil_rate_type <> 'User' AND l_project_bil_rate_date_code = 'FIXED_DATE'
                   AND X_project_rate_date IS NOT NULL ) THEN
                   l_project_bil_rate_date := X_project_rate_date;
              ELSIF (l_project_bil_rate_type <> 'User' AND l_project_bil_rate_date_code = 'PA_INVOICE_DATE'
                    AND X_project_rate_date IS NOT NULL ) THEN
                    l_project_bil_rate_date := X_project_rate_date;
              END IF;
            END IF;

            /* Funding Currency code logic */
            IF ( l_multi_currency_billing_flag = 'Y' OR l_multi_currency_billing_flag = 'y') THEN
              l_found := NULL;
             IF ( X_funding_rate_type IS NOT NULL) THEN
              BEGIN
                  SELECT 'found'
                  INTO l_found
                  FROM ( SELECT conversion_type, user_conversion_type
                         FROM   pa_conversion_types_v)
                  WHERE DECODE(conversion_type,X_funding_rate_type,'Y','N') = 'Y';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                   RAISE  l_fund_invalid_rate_type;
               END;
              END IF;

              IF ( X_funding_rate_type IS NULL AND l_funding_rate_type = 'User') THEN
                   l_funding_rate_date := NULL;
                   IF ( X_funding_exchange_rate IS NULL ) THEN
                      null;
                   ELSE
                      l_funding_exchange_rate := X_funding_exchange_rate;
                   END IF;
              ELSIF (X_funding_rate_type = 'User') THEN
                   l_funding_rate_date := NULL;
                   l_funding_rate_type := X_funding_rate_type;
                   IF ( X_funding_exchange_rate IS NULL ) THEN
                     RAISE l_fund_exch_rate_not_passd;
                   ELSE
                      l_funding_exchange_rate := X_funding_exchange_rate;
                   END IF;
              ELSIF ( X_funding_rate_type <> 'User' OR l_funding_rate_type <> 'User') THEN
                   l_funding_rate_type := NVL(X_funding_rate_type,l_funding_rate_type);
                   l_funding_exchange_rate := NULL;
              END IF;
              IF ( l_funding_rate_type <> 'User' AND l_funding_rate_date_code = 'FIXED_DATE'
                   AND X_funding_rate_date IS NOT NULL ) THEN
                   l_funding_rate_date := X_funding_rate_date;
              ELSIF (l_funding_rate_type <> 'User' AND l_funding_rate_date_code = 'PA_INVOICE_DATE'
                    AND X_funding_rate_date IS NOT NULL ) THEN
                    l_funding_rate_date := X_funding_rate_date;
              END IF;
            END IF;

          /* Added for Bug3068864 */
            IF ( l_txn_currency_code = l_projfunc_currency_code ) THEN
               l_projfunc_bil_rate_type := Null;
               l_projfunc_bil_rate_date := Null;
               l_projfunc_bil_exchange_rate := Null;
            ELSIF (l_txn_currency_code = l_project_currency_code ) THEN
                  l_project_bil_rate_type := Null;
                  l_project_bil_rate_date := Null;
                  l_project_bil_exchange_rate := Null;
            END IF;
          /* till here for Bug3068864 */

              /* Populating Invoice attributes */

            IF ( l_invproc_currency_code = l_projfunc_currency_code ) THEN
               l_invproc_currency_code := l_projfunc_currency_code;
               l_invproc_rate_type     := l_projfunc_bil_rate_type;
               l_invproc_rate_date     := l_projfunc_bil_rate_date;
               l_invproc_exchange_rate := l_projfunc_bil_exchange_rate;
            ELSIF (l_invproc_currency_code = l_project_currency_code ) THEN
                  l_invproc_currency_code := l_project_currency_code;
                  l_invproc_rate_type     := l_project_bil_rate_type;
                  l_invproc_rate_date     := l_project_bil_rate_date;
                  l_invproc_exchange_rate := l_project_bil_exchange_rate;
            ELSE
                  l_invproc_currency_code := '';
                  l_invproc_rate_type     := l_funding_rate_type;
                  l_invproc_rate_date     := l_funding_rate_date;
                  l_invproc_exchange_rate := l_funding_exchange_rate;
            END IF;

              /* Populating Revenue attributes */

            IF ( l_revproc_currency_code = l_projfunc_currency_code ) THEN
               l_revproc_currency_code := l_projfunc_currency_code;
               l_revproc_rate_type     := l_projfunc_bil_rate_type;
               l_revproc_rate_date     := l_projfunc_bil_rate_date;
               l_revproc_exchange_rate := l_projfunc_bil_exchange_rate;
            END IF;

   /* MCB2: Removed Revenue amount and Bill amount because,these amounts are being used only for transactions */
   IF (pa_billing_validate.automatic_event(XD_event_type)) THEN
     insert into pa_events
     (PROJECT_ID, TASK_ID, ORGANIZATION_ID, EVENT_NUM, EVENT_TYPE,       -- 1
     REVENUE_AMOUNT,BILL_AMOUNT,COMPLETION_DATE, REQUEST_ID,             -- 2
     DESCRIPTION, BILL_HOLD_FLAG, REV_DIST_REJECTION_CODE,               -- 3
     REVENUE_DISTRIBUTED_FLAG, PROGRAM_APPLICATION_ID, PROGRAM_ID,       -- 4
     PROGRAM_UPDATE_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY,             -- 5
     CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, ATTRIBUTE_CATEGORY,   -- 6
     ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,         -- 7
     ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,        -- 8
     BILLING_ASSIGNMENT_ID, calling_place, calling_process,              -- 9
     EVENT_NUM_REVERSED,                                                 -- 10
     AUDIT_AMOUNT1,
     AUDIT_AMOUNT2,
     AUDIT_AMOUNT3,
     AUDIT_AMOUNT4,
     AUDIT_AMOUNT5,
     AUDIT_AMOUNT6,
     AUDIT_AMOUNT7,
     AUDIT_AMOUNT8,
     AUDIT_AMOUNT9,
     AUDIT_AMOUNT10,
     AUDIT_COST_BUDGET_TYPE_CODE,
     AUDIT_REV_BUDGET_TYPE_CODE,
     EVENT_ID,
     INVENTORY_ORG_ID,
     INVENTORY_ITEM_ID,
     QUANTITY_BILLED,
     UOM_CODE,
     UNIT_PRICE,
     REFERENCE1,
     REFERENCE2,
     REFERENCE3,
     REFERENCE4,
     REFERENCE5,
     REFERENCE6,
     REFERENCE7,
     REFERENCE8,
     REFERENCE9,
     REFERENCE10,
     BILL_TRANS_CURRENCY_CODE, /* These 22 columns have been added for MCB2 */
     BILL_TRANS_REV_AMOUNT,
     BILL_TRANS_BILL_AMOUNT,
     PROJECT_CURRENCY_CODE,
     PROJECT_RATE_TYPE,
     PROJECT_RATE_DATE,
     PROJECT_EXCHANGE_RATE,
     PROJFUNC_CURRENCY_CODE,
     PROJFUNC_RATE_TYPE,
     PROJFUNC_RATE_DATE,
     PROJFUNC_EXCHANGE_RATE,
     FUNDING_RATE_TYPE,
     FUNDING_RATE_DATE,
     FUNDING_EXCHANGE_RATE,
     INVPROC_CURRENCY_CODE,
     INVPROC_RATE_TYPE,
     INVPROC_RATE_DATE,
     INVPROC_EXCHANGE_RATE,
     REVPROC_CURRENCY_CODE,
     REVPROC_RATE_TYPE,
     REVPROC_RATE_DATE,
     REVPROC_EXCHANGE_RATE,
     ZERO_REVENUE_AMOUNT_FLAG,              /* Funding MRC Changes */
     AUDIT_COST_PLAN_TYPE_ID,               /* Added for Fin Plan impact */
     AUDIT_REV_PLAN_TYPE_ID                 /* Added for Fin Plan impact */
     )
     values
     (nvl(X_project_id, pa_billing.GlobVars.ProjectId), nvl(X_top_task_id,pa_billing.GlobVars.TaskId),
	XD_organization_id, event_num, XD_event_type,   		 -- 1
     0,0,XD_completion_date, pa_billing.GlobVars.ReqId,        -- 2
     XD_event_description, 'N', NULL,                                    -- 3
     'N', program_application_id,program_id,                             -- 4
     sysdate, sysdate, nvl(last_updated_by,0),                           -- 5
     sysdate, nvl(created_by,0), nvl(last_update_login,0),
					X_attribute_category,            -- 6
     X_attribute1, X_attribute2, X_attribute3, X_attribute4,
						X_attribute5,            -- 7
     X_attribute6, X_attribute7, X_attribute8, X_attribute9,
						X_attribute10,           -- 8
     pa_billing.GlobVars.BillingAssignmentId, pa_billing.GlobVars.CallingPlace,
				pa_billing.GlobVars.CallingProcess,   	 -- 9
     X_event_num_reversed,                                               -- 10
     pa_currency.round_currency_amt(X_audit_amount1),
     pa_currency.round_currency_amt(X_audit_amount2),
     pa_currency.round_currency_amt(X_audit_amount3),
     pa_currency.round_currency_amt(X_audit_amount4),
     pa_currency.round_currency_amt(X_audit_amount5),
     pa_currency.round_currency_amt(X_audit_amount6),
     pa_currency.round_currency_amt(X_audit_amount7),
     pa_currency.round_currency_amt(X_audit_amount8),
     pa_currency.round_currency_amt(X_audit_amount9),
     pa_currency.round_currency_amt(X_audit_amount10),
     X_audit_cost_budget_type_code,
     X_audit_rev_budget_type_code,
     pa_events_s.nextval,
     x_inventory_org_id,
     x_inventory_item_id,
     x_quantity_billed,
     x_uom_code,
     x_unit_price,
     x_reference1,
     x_reference2,
     x_reference3,
     x_reference4,
     x_reference5,
     x_reference6,
     x_reference7,
     x_reference8,
     x_reference9,
     x_reference10,
     l_txn_currency_code,
     XD_bill_trans_rev_amt,
     XD_bill_trans_bill_amt,
     l_project_currency_code,
     l_project_bil_rate_type,
     l_project_bil_rate_date,
     l_project_bil_exchange_rate,
     l_projfunc_currency_code,
     l_projfunc_bil_rate_type,
     l_projfunc_bil_rate_date,
     l_projfunc_bil_exchange_rate,
     l_funding_rate_type,
     l_funding_rate_date,
     l_funding_exchange_rate,
     l_invproc_currency_code,
     l_invproc_rate_type,
     l_invproc_rate_date,
     l_invproc_exchange_rate,
     l_revproc_currency_code,
     l_revproc_rate_type,
     l_revproc_rate_date,
     l_revproc_exchange_rate,
     NVL(X_zero_revenue_amount_flag, 'N'),
     X_audit_cost_plan_type_id,
     X_audit_rev_plan_type_id
     );
   ELSE RAISE EVENT_TYPE_ERROR;
   END IF;
--   COMMIT;

IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Exiting pa_billing_pub.insert_events: ');
END IF;
   EXCEPTION
     WHEN mandatory_prm_missing THEN
       status := pa_billing_values.get_message('MANDATORY_PRM_MISSING');
       l_status := 1;
	RAISE;
     WHEN invalid_id THEN
       status := pa_billing_values.get_message('INVALID_ID');
       l_status := 2;
	RAISE;
     WHEN invalid_project_event THEN
       status := pa_billing_values.get_message('INVALID_PROJECT_EVENT');
       l_status := 3;
	RAISE;
     /*WHEN event_type_error THEN commenting this for bug 3492506
       status := pa_billing_values.get_message('EVENT_TYPE_ERROR');
	RAISE;*/
     WHEN null_event_type_error THEN
       status := pa_billing_values.get_message('NULL_EVENT_TYPE_ERROR');
       l_status := 4;
	RAISE;
     WHEN zero_amounts THEN
	status := pa_billing_values.get_message('ZERO_AMOUNTS');
       l_status := 5;
	RAISE;
     WHEN no_orig_event THEN
        status := pa_billing_values.get_message('NO_ORIG_EVENT');
       l_status := 6;
        RAISE;
     WHEN invalid_calling_place THEN
        status := pa_billing_values.get_message('INVALID_CALLING_PLACE');
       l_status := 7;
        RAISE;
     WHEN invalid_invent_id THEN
        status := pa_billing_values.get_message('INVALID_INVENT_ID');
       l_status := 8;
        RAISE;
     WHEN l_func_exch_rate_not_passd THEN /* Added for MCB2 */
        status := pa_billing_values.get_message('PA_FUNC_EXCH_RATE_NOT_PASSD');
        l_status := 9;
        RAISE;
     WHEN l_proj_exch_rate_not_passd THEN /* Added for MCB2  */
        status := pa_billing_values.get_message('PA_PROJ_EXCH_RATE_NOT_PASSD');
        l_status := 10;
        RAISE;
     WHEN l_fund_exch_rate_not_passd THEN /* Added for MCB2  */
        status := pa_billing_values.get_message('PA_FUND_EXCH_RATE_NOT_PASSD');
        l_status := 11;
        RAISE;
     WHEN l_func_invalid_rate_type THEN /* Added for MCB2  */
        status := pa_billing_values.get_message('PA_FUNC_INVALID_RATE_TYPE');
        l_status := 12;
        RAISE;
     WHEN l_proj_invalid_rate_type THEN /* Added for MCB2  */
        status := pa_billing_values.get_message('PA_PROJ_INVALID_RATE_TYPE');
        l_status := 13;
        RAISE;
     WHEN l_fund_invalid_rate_type THEN /* Added for MCB2  */
        status := pa_billing_values.get_message('PA_FUND_INVALID_RATE_TYPE');
        l_status := 14;
        RAISE;
     WHEN l_invalid_currency THEN /* Added for MCB2  */
        status := pa_billing_values.get_message('PA_CURR_NOT_VALID_BC');
        l_status := 15;
        RAISE;
     WHEN event_type_error THEN /* adding this here for bug 3492506 */
        status := pa_billing_values.get_message('EVENT_TYPE_ERROR');
        l_status := 16;
        RAISE;
     WHEN OTHERS THEN
       status := substr(SQLERRM,1,240);
       l_status := sqlcode;
--       ROLLBACK;
	RAISE;
  END;
   EXCEPTION
	WHEN OTHERS THEN
--	DBMS_OUTPUT.PUT_LINE(status);
--	DBMS_OUTPUT.PUT_LINE(SQLERRM);
	X_error_message := status;
	X_status 	:= l_status;

	insert_message(X_inserting_procedure_name => 'pa_billing_pub.insert_event',
			X_attribute1 => XD_bill_trans_rev_amt,
			X_attribute2 => XD_bill_trans_bill_amt,
			X_message => status,
			X_status => err_status,
			X_error_message => err_message);

	IF (l_status <0 OR err_status <0) THEN
		RAISE;
	END IF;

--	COMMIT;
END insert_event;

function GET_MRC_FOR_FUND_FLAG return boolean
is
l_enabled_flag varchar2(1);
begin

    SELECT 'N' -- MRC migration to SLA
      INTO l_enabled_flag
      FROM pa_implementations;

/* Changed for bug 2729975*/
	if l_enabled_flag = 'N' then
	   return FALSE;
	else
	   return TRUE;
	end if;
end GET_MRC_FOR_FUND_FLAG;

-- Following APIs added for FP_M changes
-- If the Project is enabled with Top Task Customer Enabled then
-- return the value as 'Y' else 'N'
Function Get_Top_Task_Customer_Flag (
	P_Project_ID  IN NUMBER
)
Return Varchar2
IS
l_Enable_Top_Task_Cust_Flag VARCHAR2(1);

Begin
  Select NVL(Enable_Top_Task_Customer_Flag, 'N')
  Into   l_Enable_Top_Task_Cust_Flag
  From   PA_Projects_all
  Where  Project_ID = P_Project_ID;

  Return l_Enable_Top_Task_Cust_Flag;

  Exception When Others then
	Return 'N';
End Get_Top_Task_Customer_Flag;


-- If the Project is enabled with Override Invoice Method as Enabled then
-- return the value as 'Y' else 'N'
Function Get_Inv_Method_Override_Flag (
	P_Project_ID  IN NUMBER
	)
Return Varchar2 IS

l_ENABLE_TOP_TASK_INV_MTH_FLAG VARCHAR2(1);

Begin
  Select NVL(ENABLE_TOP_TASK_INV_MTH_FLAG, 'N')
  Into   l_ENABLE_TOP_TASK_INV_MTH_FLAG
  From   PA_Projects_all
  Where  Project_ID = P_Project_ID;

  Return l_ENABLE_TOP_TASK_INV_MTH_FLAG;

  Exception When Others then
    Return 'N';
End Get_Inv_Method_Override_Flag;

-- End of APIs added for FP_M changes => Customer at Top Task

END pa_billing_pub;

/
