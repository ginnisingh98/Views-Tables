--------------------------------------------------------
--  DDL for Package Body GMS_AWARDS_BOUNDARY_DATES_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARDS_BOUNDARY_DATES_CHK" AS
-- $Header: gmsawvdb.pls 120.6.12010000.4 2009/06/01 04:44:17 jjgeorge ship $

Procedure validate_start_date( 	P_AWARD_ID    	IN    	NUMBER,
                        	P_START_DATE    IN      DATE,
				X_MESSAGE	OUT	NOCOPY VARCHAR2) IS

      CURSOR    budget_lines_csr      IS
      SELECT    1
       FROM    	gms_budget_versions       pbv,
            	gms_resource_assignments pra,
               	gms_budget_lines       pbl
       WHERE    pbv.budget_version_id = pra.budget_version_id
       AND      pbv.award_id = P_AWARD_ID
       AND      pra.resource_assignment_id = pbl.resource_assignment_id
       AND      (pbv.budget_status_code = 'W' or (pbv.budget_status_code = 'B' and pbv.current_flag = 'Y'))
       and      pbl.start_date < P_START_DATE
       and      P_START_DATE NOT BETWEEN pbl.start_date AND pbl.end_date--Condition added for Bug 5402500
       and      pbl.burdened_cost IS NOT null;--Condition added for Bug 5402500

      CURSOR    exp_items_csr   IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_award_distributions adl,
                     	pa_expenditure_items_all exp
      		WHERE   adl.expenditure_item_id = exp.expenditure_item_id
      		AND     adl.document_type = 'EXP'
      		AND     adl.adl_status = 'A'
      		AND     adl.award_id = P_AWARD_ID
      		AND     exp.expenditure_item_date < P_START_DATE) ;

      CURSOR    enc_items_csr  IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_award_distributions adl,
                     	gms_encumbrance_items_all enc
      		WHERE   adl.expenditure_item_id = enc.encumbrance_item_id
      		AND 	adl.document_type = 'ENC'
      		AND     adl.adl_status = 'A'
      		AND     adl.award_id = P_AWARD_ID
		-- ==============================================================
		-- = Bug Fix 3543931
		-- = Award end date validations :
		-- = Allow to change before fully liquidated encumbrances.
		-- = ============================================================
		AND     NVL(enc.net_zero_adjustment_flag,'N') <> 'Y'
                AND     nvl(adl.reversed_flag, 'N') = 'N' --Bug 5726575
                AND     adl.line_num_reversed is null --Bug 5726575
      		AND     enc.encumbrance_item_date < P_START_DATE ) ;

      -- ==============================================================
      -- = Bug Fix 3543931
      -- = Award end date validations :
      -- = Allow to change before fully liquidated encumbrances.
      -- = ============================================================
      CURSOR    enc_items_csr2  IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_award_distributions adl1,
                     	gms_encumbrance_items_all enc1,
			gms_encumbrance_items_all enc2,
			gms_award_distributions   adl2
      		WHERE   adl1.expenditure_item_id               = enc1.encumbrance_item_id
      		AND 	adl1.document_type                     = 'ENC'
      		AND     adl1.adl_status                        = 'A'
                AND     nvl(adl1.reversed_flag, 'N')           = 'N' --Bug 5726575
                AND     adl1.line_num_reversed                 is null --Bug 5726575
      		AND     adl1.award_id                          = P_AWARD_ID
		AND     NVL(enc1.net_zero_adjustment_flag,'N') =  'Y'
		AND     NVL(enc2.net_zero_adjustment_flag,'N') =  'Y'
		AND     enc2.adjusted_encumbrance_item_id      = enc1.encumbrance_item_id
		AND     adl2.expenditure_item_id               = enc2.encumbrance_item_id
      		AND 	adl2.document_type                     = 'ENC'
      		AND     adl2.adl_status                        = 'A'
                AND     nvl(adl2.reversed_flag, 'N')           = 'N' --Bug 5726575
                AND     adl2.line_num_reversed                 is null --Bug 5726575
      		AND     adl2.award_id                          = P_AWARD_ID
		AND     adl2.fc_status                        <> adl1.fc_status
      		AND     ( enc1.encumbrance_item_date < P_START_DATE OR
			  enc2.encumbrance_item_date < P_START_DATE ) ) ;

      CURSOR po_items_csr IS
        SELECT 1
          FROM DUAL
         WHERE EXISTS
      	       (SELECT 'X'
      		  FROM gms_award_distributions adl,
                       po_distributions_all po ,
		       po_lines_all  pol	--Bug 7660803/8250302
      		 WHERE adl.po_distribution_id = po.po_distribution_id
      		   AND adl.adl_status = 'A'
      		   AND adl.award_id = P_AWARD_ID
                   AND adl.award_set_id = po.award_id -- Bug 3985177
                   AND adl.adl_line_num = 1           -- Bug 3985177
                   AND adl.document_type = 'PO'       -- Bug 3985177
      		   AND po.expenditure_item_date < P_START_DATE
		   AND po.po_line_id = pol.po_line_id
	           AND  nvl(cancel_flag,'N') <> 'Y' );

      CURSOR    ap_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM    gms_award_distributions adl,
                     	ap_invoice_distributions_all ap ,
			ap_invoices_all  ai --Bug 7660803/8250302
      		WHERE   adl.invoice_distribution_id = ap.invoice_distribution_id
      		AND     adl.adl_status = 'A'
      		AND     adl.award_id = P_AWARD_ID
      		AND     ap.expenditure_item_date < P_START_DATE
		AND     ap.invoice_id  =  ai.invoice_id  --Bug 7660803 / 8250302
		AND     ai.cancelled_date is null);

      CURSOR 	req_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM    gms_award_distributions adl,
                     	po_req_distributions_all req ,
			po_requisition_lines_all pol --Bug 7660803 / 8250302
      		WHERE   adl.distribution_id = req.distribution_id
      		AND     adl.adl_status = 'A'
      		AND     adl.award_id = P_AWARD_ID
      		AND     req.expenditure_item_date < P_START_DATE
		AND     req.requisition_line_id = pol.requisition_line_id --Bug 7660803	/ 8250302
                AND     nvl(pol.cancel_flag,'N') <> 'Y')  ;

      l_budget_lines      	NUMBER ;
      l_exp_items      		NUMBER ;
      l_enc_items      		NUMBER ;
      l_po_items      		NUMBER ;
      l_ap_items      		NUMBER ;
      l_req_items      		NUMBER ;
      l_document_type 		VARCHAR2(100) ;
      x_err_code    		NUMBER;
      x_err_stage     		VARCHAR2(4000);

BEGIN
      l_budget_lines    := 0;
      l_exp_items       := 0;
      l_enc_items      	:= 0;
      l_po_items      	:= 0;
      l_ap_items      	:= 0;
      l_req_items      	:= 0;
      l_document_type 	:= NULL;

      OPEN      budget_lines_csr;
      FETCH      budget_lines_csr  INTO l_budget_lines;
         IF budget_lines_csr%FOUND THEN
            CLOSE   budget_lines_csr;
            X_MESSAGE := 'GMS_BUD_EXISTS';
            return;
         END IF;
      CLOSE   budget_lines_csr;

      OPEN      exp_items_csr;
      FETCH      exp_items_csr  INTO l_exp_items;
         IF exp_items_csr%FOUND THEN
            CLOSE   exp_items_csr;
            X_MESSAGE := 'GMS_EXP_EXISTS';
            return;
         END IF;
      CLOSE   exp_items_csr;

      OPEN      po_items_csr;
      FETCH      po_items_csr  INTO l_po_items;
         IF po_items_csr%FOUND THEN
            CLOSE   po_items_csr;
            X_MESSAGE := 'GMS_PO_EXISTS';
            return;
         END IF;
      CLOSE   po_items_csr;

      OPEN      ap_items_csr;
      FETCH      ap_items_csr  INTO l_ap_items;
         IF ap_items_csr%FOUND THEN
            CLOSE   ap_items_csr;
            X_MESSAGE := 'GMS_AP_EXISTS';
            return;
         END IF;
      CLOSE   ap_items_csr;

      OPEN      req_items_csr;
      FETCH      req_items_csr  INTO l_req_items;
         IF req_items_csr%FOUND THEN
            CLOSE   req_items_csr;
            X_MESSAGE := 'GMS_REQ_EXISTS';
            return;
         END IF;
      CLOSE   req_items_csr;

      --- S.N. Bug# 4138033
      -- Moved this code to here as
      -- the existense of encumbrances needs to be verified if at all there are no
      -- other transactions for the award such as actuals/po/req/ etc
      -- before the new start date.

      OPEN      enc_items_csr;
      FETCH      enc_items_csr  INTO l_enc_items;
         IF enc_items_csr%FOUND THEN
            CLOSE   enc_items_csr;
            X_MESSAGE := 'GMS_ENC_EXISTS';
            return;
         END IF;
      CLOSE   enc_items_csr;

      -- = Bug Fix 3543931
      OPEN      enc_items_csr2;
      FETCH      enc_items_csr2  INTO l_enc_items;
         IF enc_items_csr2%FOUND THEN
            CLOSE   enc_items_csr2;
            X_MESSAGE := 'GMS_ENC_EXISTS';
            return;
         END IF;
      CLOSE   enc_items_csr2;
      --- E.N. Bug# 4138033
END validate_start_date;


Procedure validate_end_date( 	P_AWARD_ID    	IN 	NUMBER,
                        	P_END_DATE    	IN      DATE,
				X_MESSAGE	OUT	NOCOPY VARCHAR2) IS

      CURSOR    budget_lines_csr      IS
      SELECT    1
       FROM    	gms_budget_versions       pbv,
            	gms_resource_assignments pra,
               	gms_budget_lines       pbl
       WHERE    pbv.budget_version_id = pra.budget_version_id
       AND      pbv.award_id = P_AWARD_ID
       AND      pra.resource_assignment_id = pbl.resource_assignment_id
       AND      (pbv.budget_status_code = 'W' or (pbv.budget_status_code = 'B' and pbv.current_flag = 'Y'))
       and      pbl.end_date > P_END_DATE
       and      P_END_DATE NOT BETWEEN pbl.start_date AND pbl.end_date--Condition added for Bug 5411155
       and      pbl.burdened_cost IS NOT null;--Condition added for Bug 5411155


      CURSOR    exp_items_csr   IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_award_distributions adl,
                     	pa_expenditure_items_all exp
      		WHERE   adl.expenditure_item_id = exp.expenditure_item_id
      		AND     adl.document_type = 'EXP'
      		AND     adl.adl_status = 'A'
      		AND     adl.award_id = P_AWARD_ID
      		AND     exp.expenditure_item_date > P_END_DATE) ;

      CURSOR    enc_items_csr  IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_award_distributions adl,
                     	gms_encumbrance_items_all enc
      		WHERE   adl.expenditure_item_id = enc.encumbrance_item_id
      		AND 	adl.document_type = 'ENC'
      		AND     adl.adl_status = 'A'
      		AND     adl.award_id = P_AWARD_ID
		-- ==============================================================
		-- = Bug Fix 3543931
		-- = Award end date validations :
		-- = Allow to change before fully liquidated encumbrances.
		-- = ============================================================
		AND     NVL(enc.net_zero_adjustment_flag,'N') <> 'Y'
                AND     nvl(adl.reversed_flag, 'N') = 'N' --Bug 5726575
                AND     adl.line_num_reversed is null  --Bug 5726575
      		AND     enc.encumbrance_item_date > P_END_DATE ) ;

      -- ==============================================================
      -- = Bug Fix 3543931
      -- = Award end date validations :
      -- = Allow to change before fully liquidated encumbrances.
      -- = ============================================================
      CURSOR    enc_items_csr2  IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_award_distributions   adl1,
                     	gms_encumbrance_items_all enc1,
			gms_encumbrance_items_all enc2,
			gms_award_distributions   adl2
      		WHERE   adl1.expenditure_item_id               = enc1.encumbrance_item_id
      		AND 	adl1.document_type                     = 'ENC'
      		AND     adl1.adl_status                        = 'A'
                AND     nvl(adl1.reversed_flag, 'N')           = 'N' --Bug 5726575
                AND     adl1.line_num_reversed                 is null --Bug 5726575
      		AND     adl1.award_id                          = P_AWARD_ID
		AND     NVL(enc1.net_zero_adjustment_flag,'N') =  'Y'
		AND     NVL(enc2.net_zero_adjustment_flag,'N') =  'Y'
		AND     enc2.adjusted_encumbrance_item_id      = enc1.encumbrance_item_id
		AND     adl2.expenditure_item_id               = enc2.encumbrance_item_id
      		AND 	adl2.document_type                     = 'ENC'
      		AND     adl2.adl_status                        = 'A'
                AND     nvl(adl2.reversed_flag, 'N')           = 'N' --Bug 5726575
                AND     adl2.line_num_reversed                 is null --Bug 5726575
      		AND     adl2.award_id                          = P_AWARD_ID
		AND     adl2.fc_status                        <> adl1.fc_status
      		AND     ( enc1.encumbrance_item_date > P_END_DATE OR
			  enc2.encumbrance_item_date > P_END_DATE ) ) ;

      CURSOR po_items_csr IS
         SELECT 1
           FROM	DUAL
          WHERE	EXISTS
                (SELECT	'X'
      	           FROM gms_award_distributions adl,
                        po_distributions_all po ,
			po_lines_all pol --bug 7660803 / 8250302
      		  WHERE adl.po_distribution_id = po.po_distribution_id
      		    AND adl.adl_status = 'A'
      		    AND adl.award_id = P_AWARD_ID
                    AND adl.award_set_id = po.award_id -- Bug 3985177
                    AND adl.adl_line_num = 1           -- Bug 3985177
                    AND adl.document_type = 'PO'       -- Bug 3985177
      		    AND po.expenditure_item_date > P_END_DATE
		    AND po.po_line_id = pol.po_line_id --Bug 7660803
	            AND  nvl(cancel_flag,'N') <> 'Y');

      CURSOR    ap_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM    gms_award_distributions adl,
                     	ap_invoice_distributions_all ap ,
			ap_invoices_all ai  --Bug 7660803 / 8250302
      		WHERE   adl.invoice_distribution_id = ap.invoice_distribution_id
      		AND     adl.adl_status = 'A'
      		AND     adl.award_id = P_AWARD_ID
      		AND     ap.expenditure_item_date > P_END_DATE
		AND     AP.INVOICE_ID  =  AI.INVOICE_ID --Bug 7660803 /8250302
                AND  AI.CANCELLED_DATE is null);

      CURSOR 	req_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM    gms_award_distributions adl,
                     	po_req_distributions_all req ,
			po_requisition_lines_all pol  --Bug 7660803 /8250302
      		WHERE   adl.distribution_id = req.distribution_id
      		AND     adl.adl_status = 'A'
      		AND     adl.award_id = P_AWARD_ID
      		AND     req.expenditure_item_date > P_END_DATE
		AND     req.requisition_line_id = pol.requisition_line_id --Bug 7660803
		AND      nvl(pol.cancel_flag,'n') <> 'Y') ;

      l_budget_lines    NUMBER ;
      l_exp_items      	NUMBER ;
      l_enc_items      	NUMBER ;
      l_po_items      	NUMBER ;
      l_ap_items      	NUMBER ;
      l_req_items      	NUMBER ;
      l_document_type 	VARCHAR2(100) ;
      x_err_code    	NUMBER;
      x_err_stage     	VARCHAR2(4000);

BEGIN

      l_budget_lines     := 0;
      l_exp_items      	 := 0;
      l_enc_items      	 := 0;
      l_po_items      	 := 0;
      l_ap_items      	 := 0;
      l_req_items      	 := 0;
      l_document_type 	 := NULL;

      OPEN      budget_lines_csr;
      FETCH      budget_lines_csr  INTO l_budget_lines;
         IF budget_lines_csr%FOUND THEN
            CLOSE   budget_lines_csr;
            X_MESSAGE := 'GMS_BUD_EXISTS';
            return;
         END IF;
      CLOSE   budget_lines_csr;

      OPEN      exp_items_csr;
      FETCH      exp_items_csr  INTO l_exp_items;
         IF exp_items_csr%FOUND THEN
            CLOSE   exp_items_csr;
            X_MESSAGE := 'GMS_EXP_EXISTS';
            return;
         END IF;
      CLOSE   exp_items_csr;

      OPEN      po_items_csr;
      FETCH      po_items_csr  INTO l_po_items;
         IF po_items_csr%FOUND THEN
            CLOSE   po_items_csr;
            X_MESSAGE := 'GMS_PO_EXISTS';
            return;
         END IF;
      CLOSE   po_items_csr;

      OPEN      ap_items_csr;
      FETCH      ap_items_csr  INTO l_ap_items;
         IF ap_items_csr%FOUND THEN
            CLOSE   ap_items_csr;
            X_MESSAGE := 'GMS_AP_EXISTS';
            return;
         END IF;
      CLOSE   ap_items_csr;

      OPEN      req_items_csr;
      FETCH      req_items_csr  INTO l_req_items;
         IF req_items_csr%FOUND THEN
            CLOSE   req_items_csr;
            X_MESSAGE := 'GMS_REQ_EXISTS';
            return;
         END IF;
      CLOSE   req_items_csr;

      --- S.N. Bug# 4138033
      -- Moved this code to here as
      -- the existense of encumbrances needs to be verified if at all there are no
      -- other transactions for the award such as actuals/po/req/ etc
      -- after the new close date.

      OPEN      enc_items_csr;
      FETCH      enc_items_csr  INTO l_enc_items;
         IF enc_items_csr%FOUND THEN
            CLOSE   enc_items_csr;
            X_MESSAGE := 'GMS_ENC_EXISTS';
            return;
         END IF;
      CLOSE   enc_items_csr;

      -- = Bug Fix 3543931
      OPEN      enc_items_csr2;
      FETCH      enc_items_csr2  INTO l_enc_items;
         IF enc_items_csr2%FOUND THEN
            CLOSE   enc_items_csr2;
            X_MESSAGE := 'GMS_ENC_EXISTS';
            return;
         END IF;
      CLOSE   enc_items_csr2;
      --- E.N. Bug# 4138033

END validate_end_date;
-- ------------------------------------------------------------------------------------+
-- Added for Bug:2269791 (CHANGING INSTALLMENT DATE WHEN BASELINED BUDGET EXISTS)

-- This procedure will loop thru all the active installments of the Award whose ID is
-- passed in and validate the installment dates and funding amounts against all
-- the Award Budgets (both draft and current).


procedure validate_installment (x_award_id in NUMBER)
is

cursor draft_budget_csr (p_award_id in NUMBER)
is
select  budget_version_id, project_id
from    gms_budget_versions
where   award_id = p_award_id
and     budget_status_code in ('W','S');

cursor baselined_budget_csr (p_award_id in NUMBER)
is
select  budget_version_id, project_id
from    gms_budget_versions
where   award_id = p_award_id
and     budget_status_code = 'B'
and     current_flag = 'Y';

cursor  budget_lines_csr (p_budget_version_id in NUMBER)
is
select  gra.resource_list_member_id,
        gra.task_id,
        gbl.start_date,
        gbl.end_date
from    gms_resource_assignments gra,
        gms_budget_lines gbl
where   gra.resource_assignment_id = gbl.resource_assignment_id
and     gra.budget_version_id = p_budget_version_id;

l_return_status NUMBER ;

Begin
        l_return_status := 0;
        for baselined_budget_rec in baselined_budget_csr ( p_award_id => x_award_id)
        loop
            for budget_lines_rec in budget_lines_csr (  p_budget_version_id => baselined_budget_rec.budget_version_id)
            loop
                gms_budget_pub.validate_budget( x_budget_version_id => baselined_budget_rec.budget_version_id,
                                            x_award_id => x_award_id,
                                            x_project_id => baselined_budget_rec.project_id,
					    x_task_id => budget_lines_rec.task_id,
                                            x_resource_list_member_id => budget_lines_rec.resource_list_member_id,
                                            x_start_date => budget_lines_rec.start_date,
                                            x_end_date  =>budget_lines_rec.end_date,
                                            x_return_status => l_return_status);
                if l_return_status <> 0 then
                    app_exception.raise_exception;
                end if;
            end loop;
        end loop;

        for draft_budget_rec in draft_budget_csr (p_award_id => x_award_id)
        loop
            for budget_lines_rec in budget_lines_csr (  p_budget_version_id => draft_budget_rec.budget_version_id)
            loop
                gms_budget_pub.validate_budget( x_budget_version_id => draft_budget_rec.budget_version_id,
                                            x_award_id => x_award_id,
                                            x_project_id => draft_budget_rec.project_id,
					    x_task_id => budget_lines_rec.task_id,
                                            x_resource_list_member_id => budget_lines_rec.resource_list_member_id,
                                            x_start_date => budget_lines_rec.start_date,
                                            x_end_date  =>budget_lines_rec.end_date,
                                            x_return_status => l_return_status);
                if l_return_status <> 0 then
                    app_exception.raise_exception;
                end if;
            end loop; -- budget lines loop
        end loop; -- budget loop
end validate_installment;

--- S.C Bug# 4138033
-- Added the parameter P_TASK_ID for the procedures validate_proj_start_date,
-- validate_proj_completion_date to enable validation for the task level if the task id is passed.
-- P_START_DATE and P_COMPLETION_DATE will be project/task start and completeion dates
-- If task id is not null then the P_START_DATE and P_COMPLETION_DATE will be for task
-- otherwise they represent the start and completion dates of Project.
--- E.C Bug# 4138033

Procedure validate_proj_start_date( 	P_PROJECT_ID    	IN    	NUMBER,
                        	        P_START_DATE            IN      DATE,
				        X_MESSAGE	        OUT	NOCOPY VARCHAR2,
					P_TASK_ID               IN      PA_TASKS.TASK_ID%TYPE DEFAULT NULL) IS  /* Bug# 4138033 */


      CURSOR    budget_lines_csr      IS
      SELECT    1
       FROM    	gms_budget_versions      pbv,
            	gms_resource_assignments pra,
               	gms_budget_lines         pbl
       WHERE    pbv.budget_version_id = pra.budget_version_id
       AND      pbv.project_id = P_PROJECT_ID
       AND      pra.resource_assignment_id = pbl.resource_assignment_id
       AND      (pbv.budget_status_code = 'W' or (pbv.budget_status_code = 'B' and pbv.current_flag = 'Y'))
       /*Code change for bug 5470902 : Start */
       --AND      pbl.start_date < P_START_DATE;
       AND      pbl.end_date < P_START_DATE
       AND      pbl.burdened_cost IS NOT null;
       /*Code change for bug 5470902 : End  */

      /* Bug# 4138033, apart from adding the task id condition, removed the joing with pa_task
         as the project_id is available on expenditure items itself */
      CURSOR    exp_items_csr   IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	pa_expenditure_items_all exp
                        /* pa_tasks tsk 4138033 */
      		WHERE   /*exp.task_id = tsk.task_id
                AND      */ exp.project_id = P_PROJECT_ID
		and     exp.task_id = nvl(P_TASK_ID, exp.task_id)
      		AND     exp.expenditure_item_date < P_START_DATE) ;

      CURSOR    enc_items_csr  IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_encumbrance_items_all enc,
                        pa_tasks tsk
      		WHERE   enc.task_id = tsk.task_id
                AND     tsk.project_id = P_PROJECT_ID
                AND     tsk.task_id = nvl(P_TASK_ID, tsk.task_id)
		-- ==============================================================
		-- = Bug Fix 3543931
		-- = Award end date validations :
		-- = Allow to change before fully liquidated encumbrances.
		-- = ============================================================
		AND     NVL(enc.net_zero_adjustment_flag,'N') <> 'Y'
      		AND     enc.encumbrance_item_date < P_START_DATE ) ;


      -- ==============================================================
      -- = Bug Fix 3543931
      -- = Award end date validations :
      -- = Allow to change before fully liquidated encumbrances.
      -- = ============================================================
/*    CURSOR    enc_items_csr2  IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_encumbrance_items_all enc1,
                        gms_encumbrance_items_all enc2,
                        pa_tasks tsk
      		WHERE   enc1.task_id                           = tsk.task_id
		AND     enc2.adjusted_encumbrance_item_id      = enc1.encumbrance_item_id
		AND     NVL(enc1.net_zero_adjustment_flag,'N') = 'Y'
		AND     NVL(enc2.net_zero_adjustment_flag,'N') = 'Y'
		AND     enc2.enc_distributed_flag             <>  enc1.enc_distributed_flag
                AND     tsk.project_id                         = P_PROJECT_ID
		AND     tsk.task_id                            = NVL(P_TASK_ID, tsk.task_id)
      		AND     ( enc1.encumbrance_item_date < P_START_DATE OR
			  enc2.encumbrance_item_date < P_START_DATE ) ) ; */
--commented for bug6888744 and modified as below:

   CURSOR    enc_items_csr2  IS
      SELECT    1
      FROM      DUAL
      WHERE     EXISTS
                (SELECT 'X'
                FROM    gms_encumbrance_items_all enc1,
--                        gms_encumbrance_items_all enc2,
                        pa_tasks tsk
                WHERE   enc1.task_id                           = tsk.task_id
  --              AND     enc2.adjusted_encumbrance_item_id      =enc1.encumbrance_item_id
                AND     NVL(enc1.net_zero_adjustment_flag,'N') = 'Y'
    --            AND     NVL(enc2.net_zero_adjustment_flag,'N') = 'Y'
      --          AND     enc2.enc_distributed_flag             <>enc1.enc_distributed_flag
              AND     enc1.enc_distributed_flag = 'N'
                AND     tsk.project_id                         = P_PROJECT_ID
                AND     tsk.task_id                            = NVL(P_TASK_ID,tsk.task_id)
                AND      enc1.encumbrance_item_date < P_START_DATE   );

      CURSOR po_items_csr IS
         SELECT	1
           FROM	DUAL
          WHERE	EXISTS
      		(SELECT	'X'
      	           FROM  po_distributions_all po ,
				         po_lines_all  pol 	--Bug 8431879
      		   WHERE po.project_id = P_PROJECT_ID
		   AND   po.task_id = nvl(P_TASK_ID, po.task_id)
      		   AND   po.expenditure_item_date < P_START_DATE
			   AND po.po_line_id = pol.po_line_id   --Bug 8431879
			   AND  nvl(cancel_flag,'N') <> 'Y' ) ;

             --Bug 3985177 : Removed pa_tasks join in po_items_csr

      CURSOR    ap_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	ap_invoice_distributions_all ap,
			        ap_invoices_all  ai --Bug 8431879
      		WHERE   ap.project_id = P_PROJECT_ID
		AND     ap.task_id = nvl(P_TASK_ID, ap.task_id)
      		AND     ap.expenditure_item_date < P_START_DATE
			AND     ap.invoice_id  =  ai.invoice_id  --Bug 8431879
		    AND     ai.cancelled_date is null ) ;

             --Bug 3985177 : Removed pa_tasks join in ap_items_csr

      CURSOR 	req_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	po_req_distributions_all req,
			        po_requisition_lines_all pol --Bug 8431879
      		WHERE   req.project_id = P_PROJECT_ID
	        AND     req.task_id = nvl(P_TASK_ID, req.task_id)
      		AND     req.expenditure_item_date < P_START_DATE
			AND     req.requisition_line_id = pol.requisition_line_id --Bug 8431879
		    AND     nvl(pol.cancel_flag,'N') <> 'Y') ;

             --Bug 3985177 : Removed pa_tasks join in req_items_csr

      CURSOR budget_lines_exist_csr IS
      SELECT    1
      FROM      DUAL
      WHERE     EXISTS
      ( SELECT    1
       FROM     gms_budget_versions       pbv,
                gms_resource_assignments pra,
                gms_budget_lines       pbl
       WHERE    pbv.budget_version_id = pra.budget_version_id
       AND      pbv.project_id = P_PROJECT_ID
       AND      pra.resource_assignment_id = pbl.resource_assignment_id
       AND      (pbv.budget_status_code = 'W' or (pbv.budget_status_code = 'B' and pbv.current_flag = 'Y')));


     CURSOR     txn_exists_csr         IS
      SELECT    1
      FROM      DUAL
      WHERE EXISTS
                (SELECT 1
                FROM    gms_award_distributions adl
                WHERE   adl.project_id = P_PROJECT_ID
		AND     adl.task_id = nvl(P_TASK_ID, adl.task_id));


      l_budget_lines      	NUMBER ;
      l_exp_items      		NUMBER ;
      l_enc_items      		NUMBER ;
      l_po_items      		NUMBER ;
      l_ap_items      		NUMBER ;
      l_req_items      		NUMBER ;
      l_txn_exists     		NUMBER ;
      l_document_type 		VARCHAR2(100) ;
      x_err_code    		NUMBER;
      x_err_stage     		VARCHAR2(4000);

BEGIN

      l_budget_lines     := 0;
      l_exp_items      	 := 0;
      l_enc_items      	 := 0;
      l_po_items      	 := 0;
      l_ap_items      	 := 0;
      l_req_items      	 := 0;
      l_txn_exists     	 := 0;
      l_document_type 	 := NULL;

        -- If the project start date is nullified we need to see if it is used any where in the system.
        -- If used then we donot allow the nullification.

     IF P_START_DATE IS NULL THEN
       OPEN       budget_lines_exist_csr;
       FETCH      budget_lines_exist_csr  INTO l_budget_lines;
         IF budget_lines_exist_csr%FOUND THEN
            CLOSE   budget_lines_exist_csr;
            X_MESSAGE := 'GMS_BUD_EXISTS';
            return;
         END IF;
       CLOSE   budget_lines_exist_csr;
     END IF;

     IF P_START_DATE IS NULL THEN
      OPEN       txn_exists_csr;
      FETCH      txn_exists_csr INTO l_txn_exists;
         IF txn_exists_csr%FOUND THEN
            CLOSE   txn_exists_csr;
            X_MESSAGE := 'GMS_TXN_EXISTS';
            return;
         END IF;
      CLOSE      txn_exists_csr;
     END IF;

     IF P_TASK_ID IS NULL THEN
      OPEN       budget_lines_csr;
      FETCH      budget_lines_csr  INTO l_budget_lines;
         IF budget_lines_csr%FOUND THEN
            CLOSE   budget_lines_csr;
	    X_MESSAGE := 'GMS_BUD_EXISTS';
            return;
         END IF;
      CLOSE   budget_lines_csr;
    END IF;

      OPEN       exp_items_csr;
      FETCH      exp_items_csr  INTO l_exp_items;
         IF exp_items_csr%FOUND THEN
            CLOSE   exp_items_csr;
            X_MESSAGE := 'GMS_EXP_EXISTS';
            return;
         END IF;
      CLOSE   exp_items_csr;

      OPEN       po_items_csr;
      FETCH      po_items_csr  INTO l_po_items;
         IF po_items_csr%FOUND THEN
            CLOSE   po_items_csr;
            X_MESSAGE := 'GMS_PO_EXISTS';
            return;
         END IF;
      CLOSE   po_items_csr;

      OPEN       ap_items_csr;
      FETCH      ap_items_csr  INTO l_ap_items;
         IF ap_items_csr%FOUND THEN
            CLOSE   ap_items_csr;
            X_MESSAGE := 'GMS_AP_EXISTS';
            return;
         END IF;
      CLOSE   ap_items_csr;

      OPEN       req_items_csr;
      FETCH      req_items_csr  INTO l_req_items;
         IF req_items_csr%FOUND THEN
            CLOSE   req_items_csr;
            X_MESSAGE := 'GMS_REQ_EXISTS';
            return;
         END IF;
      CLOSE   req_items_csr;

      --- S.N. Bug# 4138033
      -- Moved this code to here as
      -- the existense of encumbrances needs to be verified if at all there are no
      -- other transactions for the project/task such as actuals/po/req/ etc
      -- after the new close date.

      OPEN       enc_items_csr;
      FETCH      enc_items_csr  INTO l_enc_items;
         IF enc_items_csr%FOUND THEN
            CLOSE   enc_items_csr;
            X_MESSAGE := 'GMS_ENC_EXISTS';
            return;
         END IF;
      CLOSE   enc_items_csr;

      -- = Bug Fix 3543931
      OPEN       enc_items_csr2;
      FETCH      enc_items_csr2  INTO l_enc_items;
         IF enc_items_csr2%FOUND THEN
            CLOSE   enc_items_csr2;
            X_MESSAGE := 'GMS_ENC_EXISTS';
            return;
         END IF;
      CLOSE   enc_items_csr2;
      --- E.N Bug# 4138033

END validate_proj_start_date;


Procedure validate_proj_completion_date( 	P_PROJECT_ID    	IN 	NUMBER,
                        	                P_COMPLETION_DATE       IN      DATE,
				                X_MESSAGE	        OUT	NOCOPY VARCHAR2,
					        P_TASK_ID               IN      PA_TASKS.TASK_ID%TYPE DEFAULT NULL) IS  /* Bug# 4138033 */

      CURSOR    budget_lines_csr      IS
      SELECT    1
       FROM    	gms_budget_versions       pbv,
            	gms_resource_assignments pra,
               	gms_budget_lines       pbl
       WHERE    pbv.budget_version_id = pra.budget_version_id
       AND      pbv.project_id = P_PROJECT_ID
       AND      pra.resource_assignment_id = pbl.resource_assignment_id
       AND      (pbv.budget_status_code = 'W' or (pbv.budget_status_code = 'B' and pbv.current_flag = 'Y'))
       AND      pbl.start_date > P_COMPLETION_DATE
       AND      pbl.burdened_cost IS NOT null;       /*Code change for bug 5470902 */

      CURSOR    exp_items_csr   IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	pa_expenditure_items_all exp
                        /* pa_tasks tsk */
      		WHERE   /* exp.task_id = tsk.task_id
                AND      */ exp.project_id = P_PROJECT_ID
		AND     exp.task_id = nvl(P_TASK_ID, exp.task_id)
      		AND     exp.expenditure_item_date > P_COMPLETION_DATE) ;

      CURSOR    enc_items_csr  IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_encumbrance_items_all enc,
                        pa_tasks tsk
      		WHERE   enc.task_id = tsk.task_id
                AND     tsk.project_id = P_PROJECT_ID
		AND     tsk.task_id = nvl(P_TASK_ID, tsk.task_id)
		-- ==============================================================
		-- = Bug Fix 3543931
		-- = Award end date validations :
		-- = Allow to change before fully liquidated encumbrances.
		-- = ============================================================
		AND     NVL(enc.net_zero_adjustment_flag,'N') <> 'Y'
      		AND     enc.encumbrance_item_date > P_COMPLETION_DATE ) ;

      -- ==============================================================
      -- = Bug Fix 3543931
      -- = Award end date validations :
      -- = Allow to change before fully liquidated encumbrances.
      -- = ============================================================
  /*  CURSOR    enc_items_csr2  IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	gms_encumbrance_items_all enc1,
                        gms_encumbrance_items_all enc2,
                        pa_tasks tsk
      		WHERE   enc1.task_id                           = tsk.task_id
		AND     enc2.adjusted_encumbrance_item_id      = enc1.encumbrance_item_id
		AND     NVL(enc1.net_zero_adjustment_flag,'N') = 'Y'
		AND     NVL(enc2.net_zero_adjustment_flag,'N') = 'Y'
		AND     enc2.enc_distributed_flag              <>  enc1.enc_distributed_flag
                AND     tsk.project_id                         = P_PROJECT_ID
		AND     tsk.task_id                            = nvl(P_TASK_ID, tsk.task_id)
      		AND     ( enc1.encumbrance_item_date           > P_COMPLETION_DATE OR
			  enc2.encumbrance_item_date           > P_COMPLETION_DATE ) ) ;
*/

--commented for bug6888744 and modified as below:

      CURSOR    enc_items_csr2  IS
      SELECT    1
      FROM      DUAL
      WHERE     EXISTS
                (SELECT 'X'
                FROM    gms_encumbrance_items_all enc1,
--                        gms_encumbrance_items_all enc2,
                        pa_tasks tsk
                WHERE   enc1.task_id                           = tsk.task_id
  --              AND     enc2.adjusted_encumbrance_item_id      =enc1.encumbrance_item_id
                AND     NVL(enc1.net_zero_adjustment_flag,'N') = 'Y'
    --            AND     NVL(enc2.net_zero_adjustment_flag,'N') = 'Y'
      --          AND     enc2.enc_distributed_flag              <>enc1.enc_distributed_flag
             AND     enc1.enc_distributed_flag = 'N'
                AND     tsk.project_id                         = P_PROJECT_ID
                AND     tsk.task_id                            = nvl(P_TASK_ID,tsk.task_id)
                AND    enc1.encumbrance_item_date           >P_COMPLETION_DATE ) ;

      CURSOR	po_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	po_distributions_all po,
			        po_lines_all  pol	--Bug 8431879
      		WHERE   po.project_id = P_PROJECT_ID
		AND     po.task_id = nvl(P_TASK_ID, po.task_id)
      		AND     po.expenditure_item_date > P_COMPLETION_DATE
			AND po.po_line_id = pol.po_line_id  --Bug 8431879
			AND  nvl(cancel_flag,'N') <> 'Y') ;

             --Bug 3985177 : Removed pa_tasks join in po_items_csr

      CURSOR    ap_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      		(SELECT	'X'
      		FROM  	ap_invoice_distributions_all ap,
			         ap_invoices_all  ai --Bug 8431879
      		WHERE   ap.project_id = P_PROJECT_ID
		AND     ap.task_id = nvl(P_TASK_ID, ap.task_id)
      		AND     ap.expenditure_item_date > P_COMPLETION_DATE
			AND     ap.invoice_id  =  ai.invoice_id  --Bug  8431879
		    AND     ai.cancelled_date is null) ;


             --Bug 3985177 : Removed pa_tasks join in ap_items_csr

      CURSOR 	req_items_csr         IS
      SELECT 	1
      FROM 	DUAL
      WHERE 	EXISTS
      	       (SELECT	'X'
      		FROM  	po_req_distributions_all req,
			        po_requisition_lines_all pol --Bug 8431879
      		WHERE   req.project_id = P_PROJECT_ID
		    AND     req.task_id = nvl(P_TASK_ID, req.task_id)
      		AND     req.expenditure_item_date > P_COMPLETION_DATE
			AND     req.requisition_line_id = pol.requisition_line_id --Bug 8431879
		    AND     nvl(pol.cancel_flag,'N') <> 'Y') ;

             --Bug 3985177 : Removed pa_tasks join in req_items_csr

      l_budget_lines      	NUMBER ;
      l_exp_items      		NUMBER ;
      l_enc_items      		NUMBER ;
      l_po_items      		NUMBER ;
      l_ap_items      		NUMBER ;
      l_req_items      		NUMBER ;
      l_document_type 		VARCHAR2(100) ;
      x_err_code    		NUMBER;
      x_err_stage     		VARCHAR2(4000);

BEGIN

      l_budget_lines    := 0;
      l_exp_items      	:= 0;
      l_enc_items      	:= 0;
      l_po_items      	:= 0;
      l_ap_items      	:= 0;
      l_req_items      	:= 0;
      l_document_type 	:= NULL;

      IF P_TASK_ID IS NULL THEN
        OPEN       budget_lines_csr;
        FETCH      budget_lines_csr  INTO l_budget_lines;
           IF budget_lines_csr%FOUND THEN
              CLOSE   budget_lines_csr;
              X_MESSAGE := 'GMS_BUD_EXISTS';
              return;
           END IF;
        CLOSE   budget_lines_csr;
      END IF;

      OPEN       exp_items_csr;
      FETCH      exp_items_csr  INTO l_exp_items;
         IF exp_items_csr%FOUND THEN
            CLOSE   exp_items_csr;
            X_MESSAGE := 'GMS_EXP_EXISTS';
            return;
         END IF;
      CLOSE   exp_items_csr;

      OPEN       po_items_csr;
      FETCH      po_items_csr  INTO l_po_items;
         IF po_items_csr%FOUND THEN
            CLOSE   po_items_csr;
            X_MESSAGE := 'GMS_PO_EXISTS';
            return;
         END IF;
      CLOSE   po_items_csr;

      OPEN       ap_items_csr;
      FETCH      ap_items_csr  INTO l_ap_items;
         IF ap_items_csr%FOUND THEN
            CLOSE   ap_items_csr;
            X_MESSAGE := 'GMS_AP_EXISTS';
            return;
         END IF;
      CLOSE   ap_items_csr;

      OPEN       req_items_csr;
      FETCH      req_items_csr  INTO l_req_items;
         IF req_items_csr%FOUND THEN
            CLOSE   req_items_csr;
            X_MESSAGE := 'GMS_REQ_EXISTS';
            return;
         END IF;
      CLOSE   req_items_csr;

      --- S.N. Bug# 4138033
      -- Moved this code to here as
      -- the existense of encumbrances needs to be verified if at all there are no
      -- other transactions for the project/task such as actuals/po/req/ etc
      -- after the new close date.

      OPEN       enc_items_csr;
      FETCH      enc_items_csr  INTO l_enc_items;
         IF enc_items_csr%FOUND THEN
            CLOSE   enc_items_csr;
            X_MESSAGE := 'GMS_ENC_EXISTS';
            return;
         END IF;
      CLOSE   enc_items_csr;

      -- = Bug Fix 3543931
      OPEN       enc_items_csr2;
      FETCH      enc_items_csr2  INTO l_enc_items;
         IF enc_items_csr2%FOUND THEN
            CLOSE   enc_items_csr2;
            X_MESSAGE := 'GMS_ENC_EXISTS';
            return;
         END IF;
      CLOSE   enc_items_csr2;

      --- E.N. Bug# 4138033

END validate_Proj_completion_date;

END GMS_AWARDS_BOUNDARY_DATES_CHK;

/
