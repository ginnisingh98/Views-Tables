--------------------------------------------------------
--  DDL for Package Body PA_BILLING_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_PROCESS_PKG" AS
/* $Header: PABIPROB.pls 120.0.12010000.7 2010/02/15 05:29:05 dlella noship $ */

PROCEDURE PA_PROCESS_REV_ADJ (pproject_id  IN NUMBER,
                              pfromproj    IN VARCHAR2,
			      ptoproj      IN VARCHAR2,
			      pmass_gen    IN NUMBER,
			      pacc_thru_dt IN DATE) is

	mass_gen		VARCHAR2(1);
	acc_thru_dt		DATE;
        projectstatus		BOOLEAN;
        status			BOOLEAN;
	temp			NUMBER(1);
	distribution_rule	VARCHAR2(4);
CURSOR cproj IS
	SELECT p.*
	FROM   pa_projects p, pa_project_types t
	WHERE ((segment1 BETWEEN pfromproj AND ptoproj)
	OR project_id =pproject_id)
	AND p.project_type = t.project_type
    AND t.project_type_class_code = 'CONTRACT'
    AND t.direct_flag = 'Y'  /*Added for bug 9359035*/
	AND pa_project_utils.check_prj_stus_action_allowed(p.project_status_code,'GENERATE_REV') = 'Y'; /* Added for bug 8887579*/
/*
CURSOR ctask(cproject_id VARCHAR2) is
	SELECT *
	FROM   pa_tasks a
	WHERE  project_id=cproject_id
	AND (
	        (task_id=top_task_id
	         AND ready_to_distribute_flag ='Y'
	        )
	     OR (chargeable_flag ='Y'
	         AND EXISTS ( SELECT null
		              FROM   pa_tasks b
		              WHERE  b.task_id                  = a.top_task_id
			      AND    b.ready_to_distribute_flag = 'Y'
			     )
		  )
	     ); commented for bug 8813330*/

CURSOR cspf(cproject_id VARCHAR2) is
	SELECT /*+ INDEX(pf pa_summary_project_fundings_u1)*/ 1
	FROM pa_summary_project_fundings spf
	WHERE spf.project_id = cproject_id
	AND nvl(spf.revproc_baselined_amount, 0) <> 0;


CURSOR cdri(cproject_id NUMBER) is
	SELECT 1
	FROM pa_draft_revenues dr
	WHERE dr.project_id = cproject_id
	AND dr.released_date IS NULL
	AND dr.generation_error_flag = decode(pmass_gen, 1, 'Y',dr.generation_error_flag);


BEGIN
       	PA_MCB_INVOICE_PKG.log_message('... Enter the procedure pa_process_rev_adj');
	IF pmass_gen =1 THEN
		mass_gen := 'N';
	ELSE
		mass_gen := 'E';
	END IF;

	IF pacc_thru_dt IS NULL THEN
		acc_thru_dt := SYSDATE;
	ELSE
		acc_thru_dt := pacc_thru_dt;
	END IF;
	IF pa_debug_mode  = 'Y' THEN
          PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Start Projects Loop');
        END IF;
	FOR Rproj IN Cproj
	LOOP
	  -- project loop
	  IF pa_debug_mode  = 'Y' THEN
             PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Project Id :'||Rproj.project_id);
          END IF;
	  projectstatus := FALSE;
	  OPEN cspf(Rproj.project_id);
	  FETCH cspf INTO temp;
	  IF cspf%FOUND THEN
	    projectstatus := TRUE;
	      IF pa_debug_mode  = 'Y' THEN
                PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Funding available ');
              END IF;
          ELSE
	      IF pa_debug_mode  = 'Y' THEN
                PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Funding not available');
              END IF;
	  END IF;
	  CLOSE cspf;
	  IF projectstatus THEN
	    OPEN cdri(Rproj.project_id);
	    FETCH cdri INTO temp;
  	    IF cdri%FOUND THEN
	       projectstatus := FALSE;
	    END IF;
	    CLOSE cdri;
          END IF;
	  IF projectstatus THEN
	    status            := FALSE;
	    distribution_rule := SUBSTR(Rproj.distribution_rule,1,4);
	    IF pa_debug_mode  = 'Y' THEN
	       PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Start task Loop');
	    END IF;
/*		FOR  Rtask IN ctask(Rproj.project_id)
		LOOP commented for bug 8813330*/
		  -- task loop
/*		        IF pa_debug_mode  = 'Y' THEN
		          PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Task Id :'||Rtask.task_id);
		        END IF; commented for bug 8813330*/
/*			IF NOT (Rproj.enable_top_task_inv_mth_flag = 'N'
			         AND Rproj.distribution_rule	   = 'EVENT/EVENT'
			        )
			        AND Rtask.chargeable_flag	   = 'Y' THEN commented for bug 8813330*/
				 -- for expenditures
			    IF pa_debug_mode  = 'Y' THEN
			       PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Checking for EIs');
			    END IF;
			    BEGIN
			    /* Hint added for bug 8644400, Modified below query for bug 8813330*/
			    SELECT 1
 			    INTO   temp
			    FROM dual
			    WHERE EXISTS(
					SELECT /*+ INDEX(Rtask PA_TASKS_N8) INDEX(ei PA_EXPENDITURE_ITEMS_N9)*/ 1
					FROM  pa_expenditure_items_all ei,
					      pa_tasks Rtask
					WHERE Rtask.project_id = Rproj.project_id
					AND   ei.task_id		  = Rtask.task_id
					AND   Rtask.chargeable_flag	   = 'Y'
					AND ((Rproj.enable_top_task_inv_mth_flag = 'Y'
					       and (Rtask.revenue_accrual_method = 'WORK' or Rtask.invoice_method = 'WORK'))
				               OR
				             (Rproj.enable_top_task_inv_mth_flag = 'N'
					     and (Rproj.revenue_accrual_method = 'WORK' or Rproj.invoice_method = 'WORK')))
					AND   ei.cost_distributed_flag    = 'Y'
					AND   ei.revenue_distributed_flag = 'N'
					AND   ei.expenditure_item_date    <= acc_thru_dt
					AND EXISTS(    SELECT /*+ INDEX(crdl PA_CUST_REV_DIST_LINES_U1)*/ NULL
							FROM  pa_cust_rev_dist_lines crdl,pa_draft_revenues drx1
							WHERE ei.project_id = crdl.project_id
							AND  ((ei.expenditure_item_id = crdl.expenditure_item_id)
								OR  (ei.adjusted_expenditure_item_id IS NOT NULL
									AND ei.adjusted_expenditure_item_id = crdl.expenditure_item_id))
							AND NVL(crdl.reversed_flag,'N')   = 'N'
							AND NVL(crdl.line_num_reversed,0) = 0
							AND drx1.project_id		  = crdl.project_id
							AND drx1.draft_revenue_num        = crdl.draft_revenue_num
							AND DECODE(drx1.generation_error_flag,mass_gen,decode(drx1.released_date,NULL,1,0),0)
								= DECODE(drx1.released_date,NULL,1,0)
							UNION ALL
							SELECT 1
							FROM   pa_expenditure_items ei2
							WHERE  ei2.project_id               = ei.project_id
							AND    ei2.expenditure_item_id      = ei.adjusted_expenditure_item_id
							AND    ei2.revenue_distributed_flag = 'Y'
							AND    ei2.raw_revenue              =  0
						  )
				        );
			    IF pa_debug_mode  = 'Y' THEN
			       PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:EI found');
			    END IF;
				status := TRUE;
			  EXCEPTION
			   WHEN NO_DATA_FOUND THEN
			    IF pa_debug_mode  = 'Y' THEN
			       PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:EI not found');
			    END IF;
	    		    status := FALSE;
			  END;
--			END IF; commented for bug 8813330
			IF (NOT status ) THEN /* Modified for bug 8813330*/
				-- for events
	                   IF pa_debug_mode  = 'Y' THEN
			      PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Check for Events');
			   END IF;
			        BEGIN
				/* Modified below query for bug 8813330*/
				   SELECT 1
				   INTO   temp
				   FROM dual
				   WHERE
				   EXISTS(
					   SELECT 1
					   FROM pa_events ev,
					        pa_cust_event_rev_dist_lines erdl,
					        pa_draft_revenues drx,
						pa_tasks Rtask
					   WHERE ev.project_id = Rtask.project_id
					   AND   ev.task_id    = Rtask.task_id
					   AND   Rtask.project_id = Rproj.project_id
					   AND   Rtask.task_id=Rtask.top_task_id
					   AND   Rtask.ready_to_distribute_flag ='Y'
					   AND ((ev.revenue_distributed_flag = 'N'
					         AND ev.completion_date <= acc_thru_dt)
					      OR (distribution_rule = 'COST'
					          AND   ev.revenue_distributed_flag    = 'Y'
					          AND   ev.completion_date             > acc_thru_dt
                                                  )
                                                 )
					   AND   nvl(ev.revenue_hold_flag, 'N') = 'N'
					   AND   (decode(nvl(ev.bill_trans_rev_amount, 0), 0,
					 	 decode(nvl(ev.zero_revenue_amount_flag, 'N'), 'Y', 1, 0),1) = 1)
					   AND   erdl.project_id                = ev.project_id
					   AND   erdl.event_num		     = ev.event_num
					   AND   erdl.task_id		     = ev.task_id
					   AND   nvl(erdl.reversed_flag,'N')    = 'N'
					   AND   erdl.line_num_reversed IS NULL
					   AND   drx.project_id		     = erdl.project_id
					   AND   drx.draft_revenue_num	     = erdl.draft_revenue_num
					   AND   decode(drx.generation_error_flag,mass_gen,decode(drx.released_date,NULL,1,0),0)
							    = decode(drx.released_date,NULL,1,0)
					 );
				  IF pa_debug_mode  = 'Y' THEN
				     PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Event found');
				  END IF;
					status := TRUE;
				  EXCEPTION
				   WHEN NO_DATA_FOUND THEN
 				     IF pa_debug_mode  = 'Y' THEN
				      PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Event not found');
				     END IF;
				     status := FALSE;
				  END;
			END IF;
/*			IF Status THEN
			 if records found for that project for one task no need to check for other tasks
			  EXIT;
			END IF;commented for bug 8873015 */
 --		END LOOP; commented for bug 8813330 task loop
   	        IF pa_debug_mode  = 'Y' THEN
	          PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:End task Loop');
	        END IF;
		IF NOT status THEN
    	           IF pa_debug_mode  = 'Y' THEN
		     PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:checking for Project level events');
		   END IF;
			-- For project level events
		        BEGIN
			    SELECT 1
			    INTO   temp
			    FROM   dual
   			    WHERE  EXISTS(
					SELECT 1
					FROM pa_events ev,
					     pa_cust_event_rev_dist_lines erdl,
					     pa_draft_revenues drx
					WHERE ev.project_id                  = Rproj.project_id
					AND   ev.task_id IS NULL
				        AND ((ev.revenue_distributed_flag = 'N'
					         AND ev.completion_date <= acc_thru_dt)
					      OR (distribution_rule = 'COST'
					          AND   ev.revenue_distributed_flag    = 'Y'
					          AND   ev.completion_date             > acc_thru_dt
                                                  )
                                                )
					AND   nvl(ev.revenue_hold_flag, 'N') = 'N'
					AND   (decode(nvl(ev.bill_trans_rev_amount, 0), 0,
						 decode(nvl(ev.zero_revenue_amount_flag, 'N'), 'Y', 1, 0),1) = 1)
					AND   erdl.project_id                = ev.project_id
					AND   erdl.task_id IS NULL
					AND   erdl.event_num		     = ev.event_num
					AND   nvl(erdl.reversed_flag,'N')    = 'N'
					AND   erdl.line_num_reversed IS NULL
					AND   drx.project_id		     = erdl.project_id
					AND   drx.draft_revenue_num	     = erdl.draft_revenue_num
					AND   decode(drx.generation_error_flag,mass_gen,decode(drx.released_date,NULL,1,0),0)
				       		    = decode(drx.released_date,NULL,1,0)
				      );
			    IF pa_debug_mode  = 'Y' THEN
			      PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Project level Event found');
			    END IF;
			    status := TRUE;
			  EXCEPTION
			   WHEN NO_DATA_FOUND THEN
 	       	             IF pa_debug_mode  = 'Y' THEN
			      PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Project level Event not found');
			     END IF;
 			     status := FALSE;
			  END;
		END IF;
		IF NOT status THEN
 	       	        IF pa_debug_mode  = 'Y' THEN
			 PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Checking for Billing extensions');
		        END IF;
		--Billing extension
		        BEGIN
			    SELECT 1
			    INTO   temp
			    FROM dual
			    WHERE EXISTS(
					SELECT 1
					FROM pa_billing_extensions be,
					     pa_billing_assignments bea
					WHERE bea.active_flag        = 'Y'
					AND bea.billing_extension_id = be.billing_extension_id
					AND (bea.project_id  = Rproj.project_id
					     OR bea.project_type = Rproj.project_type
					     OR bea.distribution_rule = Rproj.distribution_rule)
					AND be.calling_process in ('Revenue','Both')
					AND be.call_after_adj_flag    = 'Y'
					AND be.trx_independent_flag   = 'Y'
					);
 	       	          IF pa_debug_mode  = 'Y' THEN
			   PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Billing extensions Found');
		          END IF;
			  status := TRUE;
			  EXCEPTION
			   WHEN NO_DATA_FOUND THEN
 	       	             IF pa_debug_mode  = 'Y' THEN
			       PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Billing extensions Not Found');
		             END IF;
			     status := FALSE;
			  END;
		END IF;
		IF status THEN
  	          IF pa_debug_mode  = 'Y' THEN
		     PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:Inserting project id :'||Rproj.project_id);
		  END IF;
		  INSERT INTO PA_BILLING_PROCESS_GT(project_id,request_id,process)
		  VALUES(Rproj.project_id,g_request_id,'REV_ADJ');
		 --insert record
		END IF;
	  END IF; -- If projectstatus then
	END LOOP; -- project loop
/*        IF pa_debug_mode  = 'Y' THEN
	   PA_MCB_INVOICE_PKG.log_message('pa_process_rev_adj:End task Loop');
	END IF; commented for bug 8813330 */
       	PA_MCB_INVOICE_PKG.log_message('... Leaving the procedure pa_process_rev_adj');
END PA_PROCESS_REV_ADJ;
END PA_BILLING_PROCESS_PKG;

/
