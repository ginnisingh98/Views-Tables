--------------------------------------------------------
--  DDL for Package Body PA_PURGE_VALIDATE_CAPITAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_VALIDATE_CAPITAL" AS
/* $Header: PAXGCPVB.pls 120.1 2005/08/09 04:16:55 avajain noship $ */

  PROCEDURE validate_capital(p_project_id 	IN NUMBER,
                             p_purge_to_date    IN DATE,
                             p_active_flag      IN VARCHAR2,
                             p_err_code         IN OUT NOCOPY NUMBER,
                             p_err_stack        IN OUT NOCOPY VARCHAR2,
                             p_err_stage        IN OUT NOCOPY VARCHAR2) IS
    --
    --  Invoices in AP that are not yet transfered to PA
    --
/* Commented the cursor IsVenInvPending for the bug# 2389458
    CURSOR IsVenInvPending IS
      SELECT 'VENDOR INVOICE PENDING'
      FROM   dual
      WHERE EXISTS ( SELECT aid.invoice_id
                     FROM   ap_invoice_distributions_all aid
                     WHERE  aid.project_id = p_project_id
                     AND    (p_active_flag = 'C' or
                            aid.expenditure_item_date < trunc(p_purge_to_date))
                     AND    aid.pa_addition_flag <> 'Y');
*/

/* Modified the cursor IsVenInvPending for the bug# 2389458 as below */

/* Bug#2429757 Commented out this cursor as this is generating a similar validation
	       error message like the cursor IsCommitmentExist */
/* Bug#2407499: Reverted the fix of the bug#2429757 as the cancelled invoices are
		not handled by the pa_commitment_txns_v of the cursor IsCommitmentExist */
    CURSOR IsVenInvPending IS
      SELECT 'VENDOR INVOICE PENDING'
      FROM   dual
      WHERE EXISTS ( SELECT aid.invoice_id
                     FROM   ap_invoice_distributions_all aid,
                            ap_invoices_all ai
                     WHERE  aid.project_id = p_project_id
                     AND    aid.invoice_id = ai.invoice_id
                     AND    ai.invoice_type_lookup_code <> 'EXPENSE REPORT'
                     AND    (p_active_flag = 'C' or
                            trunc(aid.expenditure_item_date) <= trunc(p_purge_to_date))
    -- Bug 2767507 Added 'G' to the list of values which pa_addition_flag
    -- shouldnot check when looking for pending invoices.
                     AND    aid.pa_addition_flag NOT IN ('Z','T','E','Y','G', 'F') --bug# 4351752
    -- Bug# 2407499
                     AND    nvl(aid.reversal_flag, 'N') <> 'Y');

    --
    --  Asset Lines that are not yet transfered to FA
    --
    CURSOR IsAstLinNotXferred IS
      SELECT 'ASSET LINE NOT TRANSFERRED'
      FROM   dual
      WHERE EXISTS ( SELECT pal.project_asset_line_id
                     FROM   pa_project_asset_lines_all pal
                     WHERE  pal.project_id = p_project_id
                     AND    pal.transfer_status_code <> 'T');

    --
    --  CDLs that are not yet transfered to AP
    --
    CURSOR IsAdjNotXferToAP IS
      SELECT 'ADJ NOT TRANSFERRED TO AP'
      FROM dual
      WHERE EXISTS (SELECT ei.expenditure_item_id
  		    FROM   pa_cost_distribution_lines_all  cdl,
    			   pa_expenditure_items_all        ei
  		    WHERE  ei.expenditure_item_id = cdl.expenditure_item_id
                    AND    ((cdl.transfer_status_code in ('P','R','X')
                             and ei.system_linkage_function = 'VI') or
                            (cdl.transfer_status_code in ('P','R','X','T')
                             and ei.system_linkage_function = 'ER'))
                    AND    cdl.line_type  = 'R'
                    AND    (p_active_flag = 'C' or
                            trunc(ei.expenditure_item_date)<= trunc(p_purge_to_date))
                    AND    ei.project_id = p_project_id);

    --
    -- Expenditure items that are split/transfered,reversed and marked for Recalculation
    -- but not cost distributed.
    --
/*****************************************
    This is already handled as part of costing validation

    CURSOR IsEiNotCosted IS
      SELECT 'EI NOT COSTED'
      FROM   dual
      WHERE EXISTS ( SELECT ei.expenditure_item_id
                     FROM   pa_expenditure_items_all   ei,
                            pa_tasks                   pt
                     WHERE  ei.system_linkage_function in ( 'VI', 'ER' )
                     AND    ei.task_id = pt.task_id
                     AND    pt.project_id = p_project_id
                     AND    (p_active_flag = 'C' or ei.expenditure_item_date < trunc(p_purge_to_date))
                     AND    ei.cost_distributed_flag||'' = 'N');
   *****************************************/
    --
    -- Expenditure items that are not yet Capitalized
    --
    CURSOR IsEiNotCapitalized IS
      SELECT 'EXP ITEM NOT CAPITALIZED'
      FROM   dual
      WHERE EXISTS ( SELECT pcdl.expenditure_item_id
                     FROM pa_cost_distribution_lines_all pcdl,
	                  pa_expenditure_items_all pei,
	                  pa_tasks pt,
	                  pa_projects pp,
	                  pa_project_types ppt
                     WHERE pcdl.expenditure_item_id = pei.expenditure_item_id
                     AND   pei.revenue_distributed_flag||'' = 'N'
                     AND   pcdl.line_type = DECODE(ppt.capital_cost_type_code,'B','D','R')
                     AND   pcdl.billable_flag = 'Y'
                     AND   pei.task_id = pt.task_id
                     AND   pt.project_id = pp.project_id
                     AND   pp.project_id = p_project_id
                     AND   (p_active_flag = 'C' or
                           trunc(pei.expenditure_item_date) <= trunc(p_purge_to_date))
                     AND   pp.project_type = ppt.project_type
                     AND   pei.task_id IN
                         ( select task_id
                           from pa_tasks pt2
                           where project_id = pp.project_id
                           and ( exists
                                 (SELECT task_id
                                  FROM pa_project_asset_assignments paa
                                  WHERE paa.project_id = pp.project_id
                                  and (paa.task_id = pt2.task_id or
                                       paa.task_id = pt2.top_task_id))
                           or exists       --- Return all common tasks
                              (SELECT task_id
                               FROM pa_project_asset_assignments paa
                               WHERE paa.project_id = pp.project_id
                               and task_id = pt2.task_id
                               AND paa.project_asset_id = 0))
                            UNION
                            SELECT task_id
                            FROM   pa_tasks
                            WHERE project_id IN
                               (SELECT project_id            --- project level asset assignment
                                  FROM pa_project_asset_assignments paa
                                 WHERE project_id = pp.project_id
                                   AND NVL(task_id, 0) = 0
                                 UNION
                                 SELECT project_id              --- return all common tasks
                                   FROM pa_project_asset_assignments paa
                                  WHERE paa.project_id = pp.project_id
	                                 and NVL(paa.task_id,0) = 0
                                    AND paa.project_asset_id = 0))
                     AND NOT EXISTS
	                    (
	                      SELECT 'This CDL was summarized before'
	                      FROM pa_project_asset_line_details pald
	                      WHERE pald.expenditure_item_id = pcdl.expenditure_item_id
	                      AND   pald.line_num = pcdl.line_num
	                      AND   pald.reversed_flag||'' = 'N'
	                    ));

    --
    -- Expenditure items that are not yet Capitalized
    --
    CURSOR IsCommitmentExist IS
      SELECT 'COMMITMENT EXISTS'
      FROM   dual
      WHERE EXISTS ( SELECT pctv.project_id
                     FROM   pa_commitment_txns_v pctv
                     WHERE  pctv.project_id = p_project_id
                     AND    pctv.expenditure_item_date is not null
                     AND    (p_active_flag = 'C' or
                            trunc(pctv.expenditure_item_date) <= trunc(p_purge_to_date))
                     AND    pctv.line_type not in  ('P','I') /* Bug 2503781.*/
           UNION     /*  Below lines added for bug 2503781 */
                     SELECT pctv1.project_id
                     FROM   pa_commitment_txns_v pctv1
                     WHERE  pctv1.project_id = p_project_id
                     AND    pctv1.expenditure_item_date is not null
                     AND    (p_active_flag = 'C' or
                            trunc(pctv1.expenditure_item_date) <= trunc(p_purge_to_date))
                     AND    pctv1.line_type = 'P'
                     AND    pctv1.tot_cmt_quantity > 0
                     AND    nvl(pctv1.quantity_cancelled,0) =0
           UNION     /* Added for bug 2553822 */
		   /* Bug 2598071  SELECT aid.invoice_id */
		     SELECT aid.invoice_id
		     FROM   ap_invoice_distributions_all aid,
			    ap_invoices_all ai
		     WHERE  aid.project_id = p_project_id
		     AND    aid.invoice_id = ai.invoice_id
                     AND    ai.source    <> 'Oracle Project Accounting'
		     AND    ai.invoice_type_lookup_code = 'EXPENSE REPORT'
		     AND    (p_active_flag = 'C' or
			    trunc(aid.expenditure_item_date) <= trunc(p_purge_to_date))
		     AND    aid.pa_addition_flag NOT IN ('Z','T','E','Y')
		     AND    nvl(aid.reversal_flag, 'N') <> 'Y');


    l_err_stack		VARCHAR2(2000);
    l_err_stage         VARCHAR2(500);
    l_exc_err_stage     VARCHAR2(500);
    l_err_code		NUMBER;
    l_dummy		VARCHAR2(500) := NULL;

  BEGIN

    l_err_code  := 0;
    l_err_stage := p_err_stage;
    l_err_stack := p_err_stack;

    pa_debug.debug('-- Performing Capital validation for the project '||to_char(p_project_id));

/* Bug#2429757 Commented out this cursor as this is generating a similar validation
               error message like the cursor IsCommitmentExist  */

/* Bug#2407499: Reverted the fix of the bug#2429757 as the cancelled invoices are
		not handled by the pa_commitment_txns_v of the cursor IsCommitmentExist */


    -- Check if there are any pending invoices in AP for this project which are not transferred
    -- to PA

    l_exc_err_stage := 'Opening Cursor IsVenInvPending';

    Open IsVenInvPending;

    l_exc_err_stage := 'Fetching Cursor IsVenInvPending';

    Fetch IsVenInvPending into l_dummy;

    IF l_dummy is not null then

      fnd_message.set_name('PA','PA_ARPR_VI_NOT_INFCED');
      fnd_msg_pub.add;
      l_err_code := 10;

      l_err_stage := 'After Open Cursor IsVenInvPending';
      l_err_stack := l_err_stack||'->After Open Cursor IsVenInvPending';
      pa_debug.debug(' *Pending vendor invoices exist for project '||to_char(p_project_id));

    End IF;

    l_exc_err_stage := 'Closing Cursor IsVenInvPending';

    Close IsVenInvPending;
    l_dummy := NULL;

    pa_debug.debug('Capital validation -- After Cursor IsVenInvPending');

    -- Check if there are any Expenditure items for this project which are not Capitalized

   if pa_purge_validate.g_project_type_class_code = 'CAPITAL' then /* Bug#2387342  */


    l_exc_err_stage := 'Opening Cursor IsEiNotCapitalized';

    Open IsEiNotCapitalized;

    l_exc_err_stage := 'Fetching Cursor IsEiNotCapitalized';

    Fetch IsEiNotCapitalized into l_dummy;

    IF l_dummy is not null then

      fnd_message.set_name('PA','PA_ARPR_EI_NOT_CAPTLZED');
      fnd_msg_pub.add;
      l_err_code := 10;

      l_err_stage := 'After Open Cursor IsEiNotCapitalized';
      l_err_stack := l_err_stack||'->After Open Cursor IsEiNotCapitalized';
      pa_debug.debug(' *UnCapitalized Expenditure Items exist for project '||to_char(p_project_id));

    End IF;

    l_exc_err_stage := 'Closing Cursor IsEiNotCapitalized';

    Close IsEiNotCapitalized;
    l_dummy := NULL;

    pa_debug.debug('Capital validation -- After Cursor IsEiNotCapitalized');

   end if;

    -- Check if there are any Adjustments for this project which are not Transferred to AP

    l_exc_err_stage := 'Opening Cursor IsAdjNotXferToAP';

    Open IsAdjNotXferToAP;

    l_exc_err_stage := 'Fetching Cursor IsAdjNotXferToAP';

    Fetch IsAdjNotXferToAP into l_dummy;

    IF l_dummy is not null then

      fnd_message.set_name('PA','PA_ARPR_VI_XFERED_NOT_INFCED');
      fnd_msg_pub.add;
      l_err_code := 10;

      l_err_stage := 'After Open Cursor IsAdjNotXferToAP';
      l_err_stack := l_err_stack||'->After Open Cursor IsAdjNotXferToAP';
      pa_debug.debug(' *Pending vendor invoice adjustments exist for project '||to_char(p_project_id));

    End IF;

    l_exc_err_stage := 'Closing Cursor IsAdjNotXferToAP';

    Close IsAdjNotXferToAP;
    l_dummy := NULL;

    pa_debug.debug('Capital validation -- After Cursor IsAdjNotXferToAP');

    -- Check if there are any Expenditure items for this project which are not Costed

/******************************
    l_exc_err_stage := 'Opening Cursor IsEiNotCosted';

    Open IsEiNotCosted;

    l_exc_err_stage := 'Fetching Cursor IsEiNotCosted';

    Fetch IsEiNotCosted into l_dummy;

    IF l_dummy is not null then

      fnd_message.set_name('PA','PA_ARPR_EI_NOT_COSTED');
      fnd_msg_pub.add;
      l_err_code := 10;

      l_err_stage := 'After Open Cursor IsEiNotCosted';
      l_err_stack := l_err_stack||'->After Open Cursor IsEiNotCosted';
      pa_debug.debug(' *Uncosted Expenditure items exist for project '||to_char(p_project_id));

    End IF;

    l_exc_err_stage := 'Closing Cursor IsEiNotCosted';

    Close IsEiNotCosted;
    l_dummy := NULL;

    pa_debug.debug('Capital validation -- After Cursor IsEiNotCosted');

********************************/
/*    IF ( (g_purge_capital_flag = 'Y') AND   Commented for Bug 2786753 */

      IF (pa_purge_validate.g_project_type_class_code = 'CAPITAL')  then /* Bug#2387342  */

      -- Check if there are any Asset Lines for this project which are not amortized

      l_exc_err_stage := 'Opening Cursor IsAstLinNotXferred';

      Open IsAstLinNotXferred;

      l_exc_err_stage := 'Fetching Cursor IsAstLinNotXferred';

      Fetch IsAstLinNotXferred into l_dummy;

      IF l_dummy is not null then

        fnd_message.set_name('PA','PA_ARPR_ASSET_LN_NOT_INFCED');
        fnd_msg_pub.add;
        l_err_code := 10;

        l_err_stage := 'After Open Cursor IsAstLinNotXferred';
        l_err_stack := l_err_stack||'->After Open Cursor IsAstLinNotXferred';
        pa_debug.debug(' *Unamortized Asset Lines exist for project '||to_char(p_project_id));

      End IF;

      l_exc_err_stage := 'Closing Cursor IsAstLinNotXferred';

      Close IsAstLinNotXferred;
      l_dummy := NULL;

      pa_debug.debug('Capital validation -- After Cursor IsAstLinNotXferred');

    End IF;

    Open IsCommitmentExist;

    l_exc_err_stage := 'Fetching Cursor IsCommitmentExist';

/*    Fetch IsEiNotCosted into l_dummy;    */
      Fetch IsCommitmentExist into l_dummy;

    IF l_dummy is not null then

      fnd_message.set_name('PA','PA_ARPR_COMM_EXISTS');
      fnd_msg_pub.add;
      l_err_code := 10;

      l_err_stage := 'After Open Cursor IsCommitmentExist';
      l_err_stack := l_err_stack||'->After Open Cursor IsCommitmentExist';
      pa_debug.debug(' *Commitments exist for project '||to_char(p_project_id));

    End IF;

    l_exc_err_stage := 'Closing Cursor IsCommitmentExist';

    Close IsCommitmentExist;
    l_dummy := NULL;

    pa_debug.debug('Capital validation -- After Cursor IsCommitmentExist');

    p_err_code  := l_err_code;
    p_err_stage := l_err_stage;
    p_err_stack := l_err_stack;

  EXCEPTION
    WHEN OTHERS THEN
      p_err_code  := -1;
      p_err_stage := to_char(SQLCODE);
      fnd_msg_pub.add_exc_msg(
         p_pkg_name		=> 'PA_PURGE_VALIDATE_CAPITAL',
         p_procedure_name	=> 'VALIDATE_CAPITAL'||'-'||l_exc_err_stage,
         p_error_text		=> 'ORA-'||LPAD(substr(p_err_stage,2),5,'0'));

  END validate_capital;

END PA_PURGE_VALIDATE_CAPITAL;

/
