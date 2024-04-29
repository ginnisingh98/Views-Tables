--------------------------------------------------------
--  DDL for Package Body PA_PO_INTEGRATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PO_INTEGRATION_UTILS" AS
/* $Header: PAPOUTLB.pls 120.8.12010000.9 2009/09/25 10:05:34 anuragar ship $ */



/*
Function   : Allow_Project_Info_Change.
Description: Checks to see if the sum of receipts interfaced to projects for the po distribution
             is zero, if sum is zero return 'Y' else 'N'.
	     Further is there is any Un-InterfacedLine to Projects, Return 'N'.--bmurthy bug 4049925
Arguments  : p_po_distribution_id - Purchase order distribution on which project information needs to be changed.
Return     : 'Y', if project information on the purchase order distribution can be updated.
             'N', if project information on the purchase order distribution cannot be updated.
*/
FUNCTION Allow_Project_Info_Change ( p_po_distribution_id IN po_distributions_all.po_distribution_id%type)
RETURN varchar2 IS

l_sum_amount_interfaced   number := 0;
l_uninterfaced_to_pa      number := 0;
l_po_distribution_id  number := 0;

BEGIN
	l_po_distribution_id  := nvl(p_po_distribution_id,-999);

   BEGIN
	select sum(nvl(entered_cr,0) - nvl(entered_dr,0))
	into l_sum_amount_interfaced
	from rcv_transactions rcv_txn,
	     rcv_receiving_sub_ledger rcv_sub
	where rcv_txn.po_distribution_id = l_po_distribution_id
	and rcv_sub.rcv_transaction_id = rcv_txn.transaction_id
	and rcv_sub.pa_addition_flag in ('Y','I')
     and ((rcv_txn.destination_type_code ='EXPENSE') OR
	/*and ((rcv_txn.destination_type_code ='EXPENSE' AND rcv_txn.transaction_type <> 'RETURN TO RECEIVING')  OR */--Bug4630478
	(rcv_txn.destination_type_code='RECEIVING' AND (rcv_txn.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING')) ) );

       IF l_sum_amount_interfaced <> 0 THEN
          Return 'N';
       END IF;

  EXCEPTION

  WHEN NO_DATA_FOUND THEN

        BEGIN

        select 1
        into l_uninterfaced_to_pa
	   FROM dual
	   WHERE EXISTS
	   (SELECT 1 FROM rcv_transactions rcv_txn,
           rcv_receiving_sub_ledger rcv_sub
  	     ,po_distributions_all podist/*Bug 3905697*/
           where rcv_txn.po_distribution_id = l_po_distribution_id
   	      and   podist.po_distribution_id=rcv_txn.po_distribution_id/*Bug 3905697*/
	      and   rcv_sub.code_combination_id = podist.code_combination_id/*Bug 3905697*/
           and rcv_sub.rcv_transaction_id = rcv_txn.transaction_id
           and ((rcv_txn.destination_type_code ='EXPENSE')  OR
             (rcv_txn.destination_type_code='RECEIVING' AND (rcv_txn.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING')) ) )
           and rcv_sub.pa_addition_flag ='N');

           If l_uninterfaced_to_pa = 1 THEN
              Return 'N';
           Else
              Return 'Y';
           End If;


        EXCEPTION

          WHEN NO_DATA_FOUND THEN
               Return 'Y';
          WHEN OTHERS THEN
               G_err_code   := SQLCODE;
               raise;

        END;

  END;



  BEGIN

        select 1
        into l_uninterfaced_to_pa
	   FROM dual
	   WHERE EXISTS
	   (SELECT 1 FROM rcv_transactions rcv_txn,
           rcv_receiving_sub_ledger rcv_sub
  	     ,po_distributions_all podist/*Bug 3905697*/
           where rcv_txn.po_distribution_id = l_po_distribution_id
   	      and   podist.po_distribution_id=rcv_txn.po_distribution_id/*Bug 3905697*/
	      and   rcv_sub.code_combination_id = podist.code_combination_id/*Bug 3905697*/
           and rcv_sub.rcv_transaction_id = rcv_txn.transaction_id
           and ((rcv_txn.destination_type_code ='EXPENSE')  OR
             (rcv_txn.destination_type_code='RECEIVING' AND (rcv_txn.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING')) ) )
           and rcv_sub.pa_addition_flag ='N');

	If l_uninterfaced_to_pa = 1 OR l_sum_amount_interfaced <> 0 THEN
           Return 'N';
        Else
           Return 'Y';
        End If;


  EXCEPTION

    WHEN NO_DATA_FOUND THEN

         If l_sum_amount_interfaced <> 0 THEN
            Return 'N';
         Else
            Return 'Y';
         End If;

    WHEN OTHERS THEN
         G_err_code   := SQLCODE;
         raise;
  END;

Exception

WHEN OTHERS THEN
G_err_code   := SQLCODE;
raise;

End Allow_Project_Info_Change;

--Added for bug 4407908
/*This is a public API, which will update PA_ADDITION_FLAG in
  rcv_receiving_sub_ledger table. This API will be called from
  purchasing module at the time of receipt creation.*/

PROCEDURE Update_PA_Addition_Flg (p_api_version       IN  NUMBER,
                                  p_init_msg_list     IN  VARCHAR2 default FND_API.G_FALSE,
                                  p_commit            IN  VARCHAR2 default FND_API.G_FALSE,
                                  p_validation_level  IN  NUMBER   default FND_API.G_VALID_LEVEL_FULL,
                                  x_return_status     OUT NOCOPY VARCHAR2,
                                  x_msg_count         OUT NOCOPY NUMBER,
                                  x_msg_data          OUT NOCOPY VARCHAR2,
                                  p_rcv_transaction_id  IN  NUMBER,
                                  p_po_distribution_id  IN  NUMBER,
				  p_accounting_event_id IN  NUMBER)
IS
  /*l_project_id           po_distributions_all.project_id%type; Bug 5585218 */
  l_po_distribution_id   po_distributions_all.po_distribution_id%type;
  l_rcv_transaction_id   rcv_receiving_sub_ledger.rcv_transaction_id%type;
  l_processed  Number := 0;

	PROCEDURE net_zero_adj_po IS

	   l_old_stack            VARCHAR2(630);
	   l_rcv_transaction_id1   NUMBER(15);
	   l_po_dist_id           NUMBER(15);
	   l_num_rows             NUMBER(15):=0;

	   l_rcv_txn_id_tbl       PA_PLSQL_DATATYPES.IdTabTyp;
	   l_po_dist_id_tbl       PA_PLSQL_DATATYPES.IdTabTyp;
	   l_rcv_acct_evt_tbl     PA_PLSQL_DATATYPES.IdTabTyp; -- pricing changes


	   CURSOR net_zero_po_proj (p_transaction_id IN number) IS /* Modified the cursor query for Bug 5585218 */
	   SELECT  /*+ leading(rcv_txn) index(rcvsub RCV_RECEIVING_SUB_LEDGER_N1) */ rcv_txn.transaction_id /*4338075*/
		 ,rcv_txn.po_distribution_id
		 ,rcvsub.accounting_event_id -- pricing changes
	    FROM rcv_transactions rcv_txn
		,po_distributions podist
		,rcv_receiving_sub_ledger rcvsub
	   WHERE rcv_txn.transaction_id = rcvsub.rcv_transaction_id
              AND rcv_txn.parent_transaction_id = (SELECT parent_transaction_id
                                                   FROM rcv_transactions rcv_txn3
                                         	   WHERE rcv_txn3.transaction_id = p_transaction_id)
	     and rcv_txn.po_distribution_id = podist.po_distribution_id
	     and podist.code_combination_id = rcvsub.code_combination_id
	     and rcvsub.actual_flag = 'A'
	     and podist.accrue_on_receipt_flag = 'Y'
	     /*and podist.project_id = p_project_id  Bug 5585218 */
	     and rcvsub.pa_addition_flag = 'N' -- pricing changes
	     and ((rcv_txn.destination_type_code = 'EXPENSE' ) OR
		  (rcv_txn.destination_type_code = 'RECEIVING' AND
		   rcv_txn.transaction_type in ('RETURN TO VENDOR','RETURN TO RECEIVING')
		 ))
	     and 0 = (SELECT /*+ INDEX(RCV_TXN2 RCV_TRANSACTIONS_N1) */sum(nvl(rcvsub2.entered_dr,0)-nvl(rcvsub2.entered_cr,0))/*4338075*/
			FROM rcv_transactions rcv_txn2
			    ,rcv_receiving_sub_ledger rcvsub2
			    ,po_distributions podist2
		       WHERE rcv_txn2.transaction_id        = rcvsub2.rcv_transaction_id
			 and podist2.po_distribution_id     = rcv_txn2.po_distribution_id
			 and podist2.code_combination_id    = rcvsub2.code_combination_id
			 and rcvsub2.actual_flag            = 'A'
			 and rcv_txn2.parent_transaction_id = rcv_txn.parent_transaction_id
			 and rcvsub2.code_combination_id    = rcvsub.code_combination_id
			 and trunc(rcv_txn2.transaction_date)      = trunc(rcv_txn.transaction_date)
			 and rcvsub2.pa_addition_flag      = 'N' -- pricing changes
			 and rcv_txn2.po_distribution_id    = rcv_txn.po_distribution_id
			 and ((rcv_txn2.destination_type_code = 'EXPENSE' ) OR
			      (rcv_txn2.destination_type_code = 'RECEIVING' AND
			       rcv_txn2.transaction_type      in ('RETURN TO VENDOR','RETURN TO RECEIVING')
			     ))
		      );

	BEGIN

	      l_po_dist_id          := l_po_distribution_id;

	--      l_old_stack := G_err_stack;
	--      G_err_stack := G_err_stack || '->PAAPIMP_PKG.net_zero_adj_po';
	--      G_err_code := 0;
	--      G_err_stage := 'UPDATING RCV TRANSACTIONS FOR net_zero_adj_po';

	--      write_log(LOG, G_err_stack);

		 OPEN net_zero_po_proj (l_rcv_transaction_id);

		 l_rcv_txn_id_tbl.delete;
		 l_po_dist_id_tbl.delete;
		 l_rcv_acct_evt_tbl.delete; -- pricing changes

		 FETCH net_zero_po_proj BULK COLLECT INTO l_rcv_txn_id_tbl
							 ,l_po_dist_id_tbl
							 ,l_rcv_acct_evt_tbl; -- pricing changes

		 IF l_rcv_txn_id_tbl.COUNT <> 0 THEN

		    FORALL i IN l_rcv_txn_id_tbl.FIRST..l_rcv_txn_id_tbl.LAST

		      UPDATE rcv_receiving_sub_ledger rcv_sub
			  SET rcv_sub.pa_addition_flag         = 'Z'
			WHERE rcv_sub.rcv_transaction_id           = l_rcv_txn_id_tbl(i) --pricing changes
			  AND rcv_sub.pa_addition_flag         = 'N'
			  AND (rcv_sub.accounting_event_id = l_rcv_acct_evt_tbl(i) --pricing changes
				OR rcv_sub.accounting_event_id IS NULL); --pricing changes
		    l_num_rows := SQL%ROWCOUNT;

		 END IF;

	--         write_log (LOG,'Total number of transctions updated to Z:'||l_num_rows);

		 l_rcv_txn_id_tbl.delete;
		 l_po_dist_id_tbl.delete;
		 l_rcv_acct_evt_tbl.delete; -- pricing changes

		 CLOSE net_zero_po_proj;

	EXCEPTION
	     WHEN Others THEN

		IF net_zero_po_proj%ISOPEN THEN
		   CLOSE net_zero_po_proj;
		END IF;

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	--        G_err_stack := l_old_stack;
	--        G_err_code := SQLCODE;
		raise;
	END net_zero_adj_po;

BEGIN

  x_return_status      := FND_API.G_RET_STS_SUCCESS;

  l_po_distribution_id := p_po_distribution_id;
  l_rcv_transaction_id := p_rcv_transaction_id;


UPDATE rcv_receiving_sub_ledger rcv_sub
   SET rcv_sub.pa_addition_flag = NULL
 WHERE rcv_sub.pa_addition_flag ='N'
   AND rcv_sub.rcv_transaction_id = l_rcv_transaction_id
   AND EXISTS
   (
    SELECT 'X'
    FROM rcv_transactions rcv_txn
    WHERE rcv_txn.TRANSACTION_ID = rcv_sub.RCV_TRANSACTION_ID
      AND ((rcv_txn.destination_type_code IN ('INVENTORY','MULTIPLE','SHOP FLOOR')
            OR
            (rcv_txn.destination_type_code = 'RECEIVING'
             AND
             (rcv_txn.transaction_type  NOT IN ('RETURN TO VENDOR','RETURN TO RECEIVING')
             )
            )
           )
           OR
           (EXISTS
            (SELECT po_distribution_id
             FROM po_distributions po_dist
             WHERE po_dist.po_distribution_id    = rcv_txn.po_distribution_id
               AND ((rcv_txn.destination_type_code = 'EXPENSE' AND
                     po_dist.project_id             IS NULL)
                    OR
                    (rcv_txn.destination_type_code   = 'EXPENSE' AND
                     nvl(po_dist.project_id,0)      > 0         AND
                     po_dist.accrue_on_receipt_flag = 'N')
                    OR
                    (rcv_txn.destination_type_code = 'RECEIVING' AND
                     po_dist.project_id           IS NULL)
                    OR
                    (rcv_txn.destination_type_code = 'RECEIVING' AND
                     po_dist.project_id            IS NOT NULL AND
                     po_dist.accrue_on_receipt_flag = 'N')
                   )
            )
           ) OR
            ( pa_nl_installed.is_nl_installed = 'Y'                 --EIB trackable items
                    AND  EXISTS (SELECT 'X'
                                     FROM  mtl_system_items si,
                                           po_lines_all pol,
                                           po_distributions_all po_dist1
                                     WHERE po_dist1.po_line_id = pol.po_line_id
                                     AND   po_dist1.po_distribution_id  = rcv_txn.po_distribution_id
                                     AND   si.inventory_item_id = pol.item_id
                                     AND   po_dist1.project_id IS NOT NULL
                                     AND   si.comms_nl_trackable_flag = 'Y')
            ) OR
           (
           rcv_sub.actual_flag <> 'A'
           )
          )
   );

l_processed := SQL%ROWCOUNT ;

   UPDATE rcv_receiving_sub_ledger rcv_sub
      SET rcv_sub.pa_Addition_Flag       = 'X'
    WHERE rcv_sub.pa_addition_flag       IN ('N','I')
      AND rcv_sub.rcv_transaction_id = l_rcv_transaction_id
      AND EXISTS
	( SELECT po_dist.code_combination_id
	FROM Rcv_Transactions rcv_txn, PO_Distributions po_dist
	WHERE
	(
	  (rcv_txn.destination_type_code ='EXPENSE' )
	  OR        (rcv_txn.destination_type_code = 'RECEIVING'
		AND (rcv_txn.transaction_type
		IN  ('RETURN TO VENDOR','RETURN TO RECEIVING')))
				)
--	AND rcv_txn.transaction_date      <= nvl(G_GL_DATE,rcv_txn.transaction_date)
	AND rcv_txn.PO_DISTRIBUTION_ID    =  po_dist.po_distribution_id
	AND rcv_sub.code_combination_id   <> po_dist.code_combination_id
	AND rcv_sub.rcv_transaction_id    =  rcv_txn.transaction_id
	AND rcv_sub.actual_flag           = 'A'
--	AND po_dist.expenditure_item_date <= nvl(G_TRANSACTION_DATE,po_dist.expenditure_item_date)
	AND po_dist.project_ID  > 0
	AND po_dist.accrue_on_receipt_flag= 'Y') ;

l_processed := l_processed + SQL%ROWCOUNT ;

      IF (l_processed  = 0) THEN
       net_zero_adj_po();
      END IF ;

EXCEPTION
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   raise;
END Update_PA_Addition_Flg;

/* Function to check whether the user has access to a particular project ie, he is a key member on
that project. This is used in PA_PO_PROJECTS_EXPEND_V to restrict the projects which user is key member on,in
Project LOV in Procurement.
This will be called from PO context and the profile PO_ENFORCE_PROJ_SECURITY will be used to enforce the same.
*/
FUNCTION PA_USER_PO_ACCESS_PROJ(x_proj_id IN NUMBER,
                                x_proj_user_id   IN NUMBER)
RETURN varchar2
is
l_user_c NUMBER :=0;
begin

/*To check if employee has key member access for a project*/
-- Bug 8937044 joined with fnd_user
select count(*)
into l_user_c
from per_all_people_f papf
where papf.person_id=(select max(employee_id) from fnd_user where user_id = x_proj_user_id)
and  trunc(sysdate) between papf.EFFECTIVE_START_DATE
        and  Nvl(papf.effective_end_date, Sysdate + 1)
and papf.person_id in
(
select f.person_id
from pa_project_parties pp, pa_resources pr,PA_PROJ_ROLES_V ppr
,per_all_people_f f, pa_resource_txn_attributes  ptn
where pp.resource_id = pr.resource_id
and trunc(sysdate) between pp.start_date_active and  Nvl(pp.end_date_active, Sysdate + 1) -- Bug 8943693
and pp.project_role_id = ppr.project_role_id
and ptn.resource_id=pp.resource_id
and f.person_id=ptn.person_id
and pp.project_id=x_proj_id);

if l_user_c = 0
then return 'N';
else
return 'Y';
end if;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          return 'N';
        WHEN OTHERS THEN
          RAISE;

end PA_USER_PO_ACCESS_PROJ;

/* Function to impose project based security in Procurement.It has two modes :UPDATE and VIEW
 * UPDATE : This mode should check if a person has access to 'ALL' the projects
 * in a PO.
 * VIEW :This mode should check if person has access to atleast 'ONE' project on
 * a PO.
 * This is used to restrict the access on PO for which the user is not key member on included projects.
 *This will be called from PO context and the profile PO_ENFORCE_PROJ_SECURITY will be used to enforce the same.
*/
FUNCTION PA_USER_PO_ACCESS_CHECK(x_po_header_id IN NUMBER,
                                 x_proj_user_id   IN NUMBER,
                                 x_mode IN  VARCHAR2 DEFAULT 'VIEW'  /* Mode can have 2 values 'VIEW'  or 'UPDATE'*/
								 )
RETURN VARCHAR2 IS

l_profile_value VARCHAR2(1) := NULL;
l_proj_id NUMBER := 0;
l_user_c NUMBER :=0;

cursor c_proj is
select distinct project_id from po_distributions_all
where po_header_id = x_po_header_id
 and  project_id is not NULL; /* added condition for 8920005 */

BEGIN
/*Profile to check project based security in procurement*/
l_profile_value := NVL(FND_PROFILE.value('PO_ENFORCE_PROJ_SECURITY'), 'N');
--l_profile_value :='Y';
if l_profile_value = 'Y' then
/*To check if employee has access to all projects on a PO*/
	if x_mode = 'UPDATE' then
	open c_proj;
	loop
	fetch c_proj into l_proj_id;
	exit when c_proj%NOTFOUND;

	select count(*)
	into l_user_c
	from per_all_people_f papf
	where papf.person_id=x_proj_user_id
        and  trunc(sysdate) between papf.EFFECTIVE_START_DATE
        and  Nvl(papf.effective_end_date, Sysdate + 1)
	and papf.person_id in
		(
		select f.person_id
		from pa_project_parties pp, pa_resources pr,PA_PROJ_ROLES_V ppr
		,per_all_people_f f, pa_resource_txn_attributes  ptn
		where pp.resource_id = pr.resource_id
		and trunc(sysdate) between pp.start_date_active and  Nvl(pp.end_date_active, Sysdate + 1) -- Bug 8943693
		and pp.project_role_id = ppr.project_role_id
		and ptn.resource_id=pp.resource_id
		and f.person_id=ptn.person_id
		and pp.project_id=l_proj_id);

			if l_user_c = 0
				then return 'N';
			end if;
	end loop;
	close c_proj;
	return 'Y';

	end if; --end for mode=update

/*To check if employee has access to atleast one project on a PO*/
	if x_mode = 'VIEW' then
	open c_proj;
	loop
	fetch c_proj into l_proj_id;
	exit when c_proj%NOTFOUND;

        select count(*)
        into l_user_c
        from per_all_people_f papf
        where papf.person_id=x_proj_user_id
        and  trunc(sysdate) between papf.EFFECTIVE_START_DATE
        and  Nvl(papf.effective_end_date, Sysdate + 1)
        and papf.person_id in
                (
                select f.person_id
                from pa_project_parties pp, pa_resources pr,PA_PROJ_ROLES_V ppr
                ,per_all_people_f f, pa_resource_txn_attributes  ptn
                where pp.resource_id = pr.resource_id
				and trunc(sysdate) between pp.start_date_active and  Nvl(pp.end_date_active, Sysdate + 1) -- Bug 8943693
                and pp.project_role_id = ppr.project_role_id
                and ptn.resource_id=pp.resource_id
                and f.person_id=ptn.person_id
                and pp.project_id=l_proj_id);

			if l_user_c = 1
				then return 'Y';
			end if;
	end loop;
	--Changes for 8830122 follows
	if c_proj%ROWCOUNT = 0
	then
	return 'Y';
	else
	return 'N';
	end if; --end for %ROWCOUNT check
	--Changes for 8830122 end
	end if; --end for mode=view
else
return 'Y';
end if; --end for profile check
EXCEPTION
        WHEN NO_DATA_FOUND THEN
          return 'N';
        WHEN OTHERS THEN
          RAISE;
END PA_USER_PO_ACCESS_CHECK;

End pa_po_integration_utils;

/
