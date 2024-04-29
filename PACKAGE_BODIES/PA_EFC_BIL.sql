--------------------------------------------------------
--  DDL for Package Body PA_EFC_BIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EFC_BIL" AS
/* $Header: PAEFCBLB.pls 120.2 2005/08/16 14:59:19 hsiu ship $ */
PROCEDURE Get_B_Ub_Rev_Inv_Amts(p_project_id	IN  	NUMBER,
			       p_task_id    	IN  	NUMBER,
			       p_agreement_id  	IN  	NUMBER,
                               p_baselined      IN OUT  NOCOPY NUMBER,
                               p_ubaselined     IN OUT  NOCOPY NUMBER,
                               p_billed         IN OUT  NOCOPY NUMBER,
                               p_accr_rev       IN OUT  NOCOPY NUMBER,
                               p_adjust_amt     OUT     NOCOPY NUMBER,
			       p_rev_limit_flag   IN      VARCHAR2) IS
pl_baselined 	NUMBER:=0;
pl_unbaselined 	NUMBER:=0;
pl_billed	NUMBER:=0;
pl_accr_rev	NUMBER:=0;
pl_adjusted	NUMBER:=0;

 -- this cursor will bring the BASELINE and DRAFT amounts

      CURSOR spf_bas_amt(pl_project_id   NUMBER,
			 pl_task_id      NUMBER,
			 pl_agreement_id NUMBER) IS
          SELECT f.budget_type_code budget_type_code,
                 NVL(SUM(f.allocated_amount),0) tot_amt
          FROM   pa_project_fundings f
          WHERE  f.project_id = pl_project_id
	    AND  f.agreement_id = pl_agreement_id
	    AND  nvl(f.task_id,-99) = nvl(pl_task_id,-99)
       GROUP BY  f.budget_type_code;

BEGIN

	-- get the baselined amount and unbaselined amount

	FOR rec_spf_bas_amt IN spf_bas_amt(p_project_id,
					   p_task_id,
					   p_agreement_id) LOOP

                    IF rec_spf_bas_amt.budget_type_code = 'BASELINE' THEN

			pl_baselined := rec_spf_bas_amt.tot_amt;

/* The budget_type_code 'ORIGINAL' should not be considered hence below change */

                    ELSIF  rec_spf_bas_amt.budget_type_code = 'DRAFT' THEN /* added draft for 2001272 */

			pl_unbaselined := rec_spf_bas_amt.tot_amt;

                    END IF;

	END LOOP;



	IF NVL(p_accr_rev,0) <> 0 THEN

        	--  Get the total accrued revenue amount

   		SELECT 	NVL(SUM(dri.amount),0) dri_amount
	  	INTO 	pl_accr_rev
           	FROM 	pa_draft_revenue_items dri,
               	 	pa_draft_revenues_all dr
          	WHERE   dri.project_id = dr.project_id
            	  AND 	dri.draft_revenue_num = dr.draft_revenue_num
            	  AND   ( NVL(p_task_id,0) = 0
                          OR dri.task_id = p_task_id )
                  AND dr.project_id = p_project_id
                  AND dr.agreement_id = p_agreement_id;

	END IF;

	IF NVL(p_billed,0) <> 0 AND NVL(p_task_id,0) =0 THEN

	   -- get the total accrued revenue for project level funding

       		SELECT 	sum(dii.amount) dii_amount
	 	  INTO 	pl_billed
         	  FROM 	pa_draft_invoice_items dii,
                	pa_draft_invoices_all di
         	 WHERE 	dii.project_id = di.project_id
           	   AND 	dii.draft_invoice_num = di.draft_invoice_num
           	   AND 	di.project_id = p_project_id
           	   AND 	di.agreement_id = p_agreement_id
           	   AND 	dii.invoice_line_type <> 'RETENTION';

	ELSIF  NVL(p_billed,0) <> 0 AND NVL(p_task_id,0) <> 0 THEN

	   -- get the total accrued revenue for task level funding

    		SELECT 	round(sum(dii.amount * (1 -
                    	( nvl(di.retention_percentage,0)/100 )) ),2) dii_amount
		  INTO 	pl_billed
                  FROM 	pa_draft_invoice_items dii,
                	pa_draft_invoices_all di
         	 WHERE 	dii.project_id = di.project_id
           	   AND 	dii.draft_invoice_num = di.draft_invoice_num
           	   AND 	dii.task_id = p_task_id
           	   AND 	dii.invoice_line_type <> 'RETENTION'
           	   AND 	di.project_id = p_project_id
           	   AND 	di.agreement_id = p_agreement_id;

       END IF;

/* Commented for bug 2000454
   This is commented because it is possible in projects to have accrued and billed amounts
   greater than zero even if baselined amount is zero for the agreement. This is possible becasuse
   of a bug in agreement form which allows to reduce funding below amount accrued or billed against
   this agreement.


	IF NVL(pl_baselined,0) = 0 THEN

	-- All case if there is no baselined amount, billed and accrued amount should be zero

		pl_billed 	:= 0;
		pl_accr_rev 	:= 0;

	END IF;
*/

        IF NVL(p_rev_limit_flag,'N') = 'Y' THEN


	     IF NVL(pl_baselined,0) <> 0 AND
	   		NVL(pl_baselined,0) < GREATEST(NVL(pl_billed,0),NVL(pl_accr_rev,0)) THEN

	   		pl_adjusted 	:= GREATEST(NVL(pl_billed,0),NVL(pl_accr_rev,0))- NVL(pl_baselined,0);
	   		pl_baselined := GREATEST(NVL(pl_billed,0),NVL(pl_accr_rev,0));


	     END IF;

	 END IF;

  		p_baselined 	:=  pl_baselined;
        	p_ubaselined 	:=  pl_unbaselined;
		p_billed	:=  pl_billed;
		p_accr_rev	:=  pl_accr_rev;
		p_adjust_amt	:=  pl_adjusted;


END Get_B_Ub_Rev_Inv_Amts;
  /*---------------------------------------------------------------------------
   |     Procedure to update the adjusted amount in    project funding table   |
   |     and summary project funding efc table 				       |
   ----------------------------------------------------------------------------*/

PROCEDURE Update_Adjusted_Amount (p_project_id		IN	NUMBER,
				  p_agreement_id	IN	NUMBER,
				  p_task_id		IN	NUMBER,
				  p_adjusted		IN	NUMBER) IS

-- get the latest funding id to update the adjusted amount

CURSOR cur_adj	IS
	SELECT f.project_funding_id project_funding_id
	  FROM pa_project_fundings f
	WHERE  f.project_id = p_project_id
	  AND  f.agreement_id = p_agreement_id
          AND  NVL(f.task_id,-99)= NVL(p_task_id,-99)
	  AND  f.budget_type_code = 'BASELINE'
     ORDER BY  creation_date DESC;

	rec_adj 	cur_adj%ROWTYPE;
	update_flag   	BOOLEAN:= FALSE;

BEGIN
	BEGIN
		OPEN cur_adj;

	    		LOOP
				FETCH cur_adj INTO rec_adj;
	        		EXIT WHEN cur_adj%NOTFOUND;

			-- update the Project Funding record

				UPDATE pa_project_fundings pf
			   	   SET pf.allocated_amount=(pf.allocated_amount+p_adjusted)
			 	 WHERE pf.project_funding_id = rec_adj.project_funding_id;

			-- update the Project Funding EFC record

				UPDATE pa_project_fundings_efc pfefc
			   	   SET pfefc.adjusted_amount=p_adjusted
			 	 WHERE pfefc.project_funding_id = rec_adj.project_funding_id;

				  update_flag :=  TRUE;

				EXIT WHEN (update_flag);
	    		END LOOP;

		CLOSE cur_adj;
	END;

	BEGIN

	-- update the Summary Project Funding EFC record

		UPDATE pa_summary_proj_fundings_efc
		   SET adjusted_amount	= p_adjusted
		 WHERE project_id 	= p_project_id
		   AND NVL(task_id,-99) = NVL(p_task_id,-99)
		   AND agreement_id 	= p_agreement_id;

	END;

END Update_Adjusted_Amount ;

FUNCTION sum_mc_cust_rdl_erdl( p_project_id                   IN   NUMBER,
                               p_draft_revenue_num            IN   NUMBER,
                               p_draft_revenue_item_line_num  IN   NUMBER,
			       p_set_of_books_id              IN   NUMBER) RETURN NUMBER IS
   rdl_amt   NUMBER;
   erdl_amt  NUMBER;
BEGIN

 SELECT  sum(nvl(rdl.amount,0))
 INTO    rdl_amt
 FROM    pa_mc_cust_rdl_all rdl
 WHERE   rdl.project_id                  = p_project_id
 AND     rdl.draft_revenue_num           = p_draft_revenue_num
 AND     rdl.draft_revenue_item_line_num = p_draft_revenue_item_line_num
 AND     rdl.set_of_books_id             = p_set_of_books_id;

 SELECT  sum(nvl(erdl.amount,0))
 INTO    erdl_amt
 FROM    pa_mc_cust_event_rdl_all erdl
 WHERE   erdl.project_id                  = p_project_id
 AND     erdl.draft_revenue_num           = p_draft_revenue_num
 AND     erdl.draft_revenue_item_line_num = p_draft_revenue_item_line_num
 AND     erdl.set_of_books_id             = p_set_of_books_id;

 RETURN (nvl(rdl_amt,0) + nvl(erdl_amt,0));

EXCEPTION WHEN OTHERS THEN
  RAISE;

END sum_mc_cust_rdl_erdl;


FUNCTION SUM_MC_CUST_RDL_ERDL2
   (x_project_id         IN NUMBER,
    x_draft_revenue_num  IN NUMBER,
    x_set_of_books_id    IN NUMBER)
RETURN NUMBER
IS
   rdl_amt   NUMBER;
   erdl_amt  NUMBER;
BEGIN
 SELECT  sum(nvl(rdl.amount,0))
 INTO    rdl_amt
 FROM    pa_mc_cust_rdl_all rdl,
         pa_implementations imp
 WHERE   rdl.project_id                  = x_project_id
 AND     rdl.draft_revenue_num           = x_draft_revenue_num
 AND     rdl.set_of_books_id             = x_set_of_books_id;
 SELECT  sum(nvl(erdl.amount,0))
 INTO    erdl_amt
 FROM    pa_mc_cust_event_rdl_all erdl,
         pa_implementations imp
 WHERE   erdl.project_id                  = x_project_id
 AND     erdl.draft_revenue_num           = x_draft_revenue_num
 AND     erdl.set_of_books_id             = x_set_of_books_id ;
 RETURN (nvl(rdl_amt,0) + nvl(erdl_amt,0));
EXCEPTION WHEN OTHERS THEN
  RAISE;
END sum_mc_cust_rdl_erdl2;


END pa_efc_bil;

/
