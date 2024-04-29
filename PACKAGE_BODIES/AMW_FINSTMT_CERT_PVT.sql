--------------------------------------------------------
--  DDL for Package Body AMW_FINSTMT_CERT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_FINSTMT_CERT_PVT" as
/* $Header: amwvfscb.pls 120.4 2006/05/25 23:52:58 npanandi noship $ */

g_user_id              NUMBER;
g_login_id             NUMBER;
g_errbuf               VARCHAR2(2000) := null;
g_retcode              VARCHAR2(2);

G_PKG_NAME    CONSTANT VARCHAR2 (30) := 'AMW_FINSTMT_CERT_PVT';
G_API_NAME   CONSTANT VARCHAR2 (15) := 'amwvfcsb.pls';


/************comment by dong ************************
before AMW.D
this package was composed of 5 major procedures. one is main procedure, which calls the other
4 procedures to populate data in dashboard, process, organization and financial item-accounts
Main: Populate_Fin_Stmt_Cert_Sum:
1)Populate_All_Cert_General_Sum
2)Populate_All_Fin_Proc_Eval_Sum
3)Populate_All_Fin_Org_Eval_Sum
4)build_amw_fin_cert_eval_sum

after AMW.D
this package is composed of 2 procedures. one is main procedure, which is the similar as the one
before amw.d. but this new main procedure only calls one procedure which is Populate_All_Fin_Proc_Eval_Sum.
within in this one sub_procedure, we populate all of summary tables. note: all of logic are embeded in
anther package AMW_FINSTMT_CERT_BES_PKG, which is new pl/slq package from amw.d

Major feature in AMW.D is 1) bussiness event 2) combine previous independent 4 procedures into 1 proceudre.
so the execution order is critical.

***************************************************************/






PROCEDURE Update_Next_Level_Proc_Info(p_process_id IN NUMBER, p_org_id IN NUMBER, p_certification_id IN NUMBER) is

cursor c2 (l_process_id number,l_org_id number) is
    select CHILD_PROCESS_ID
 from Amw_Process_Org_Relations
    where PARENT_PROCESS_ID=l_process_id and ORGANIZATION_ID = l_org_id;

  c2_rec c2%rowtype;

l_sum_certified number;
l_subprocess_total number;
l_audit_result varchar2(50);



BEGIN

--Initialise the sums for each process to zero - no. of next-level subprocesses/ number among them --certified

 l_sum_certified := 0;
 l_subprocess_total := 0;

 -- loop through the org hierarchy and calculate sub_processes certified stats
 for c2_rec in c2(p_process_id, p_org_id) loop

   exit when c2%notfound;

-- Increment counter for next level subprocesses
  l_subprocess_total :=  l_subprocess_total + 1;

-- Fetch the certification result for each next level subprocess


select opinion.audit_result INTO l_audit_result
FROM AMW_OPINIONS_V opinion, AMW_OPINION_TYPES_TL opiniontype, FND_OBJECTS fndobject, AMW_OBJECT_OPINION_TYPES objectopiniontype
WHERE

(opinion.AUTHORED_DATE in (Select MAX(opinion.AUTHORED_DATE)
                                         from AMW_OPINIONS_V opinion
                                         Group By PK1_VALUE)) AND

opinion.PK3_VALUE = p_org_id AND
opinion.PK2_VALUE = p_certification_id AND
opinion.PK1_VALUE = c2_rec.CHILD_PROCESS_ID AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_NAME = 'Certification' AND
opiniontype.LANGUAGE = 'US' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_PROCESS';

-- Increment the counter of those certified appropriately

If ((l_audit_result = 'Certified') or (l_audit_result = 'Certified with Issues'))

then l_sum_certified := l_sum_certified + 1;

end if;

end loop;

-- /* Update the summary table with the certified subprocess info*/

               g_user_id  := fnd_global.user_id;
Update AMW_PROC_CERT_EVAL_SUM
SET SUB_PROCESS_CERT = l_sum_certified,TOTAL_SUB_PROCESS_CERT = l_subprocess_total, LAST_UPDATE_DATE = SYSDATE, LAST_UPDATED_BY = G_USER_ID
where PROCESS_ID = p_process_id and CERTIFICATION_ID = p_certification_id and ORGANIZATION_ID = p_org_id;

EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

---COMMIT;
end Update_Next_Level_Proc_Info;






--Update the summary table with the certification status (audit_result_code) - to facilitate image lookups etc.,last_updated_by, last_update_time for all these processes */


Procedure Update_Certification_Detail(p_process_id IN NUMBER, p_org_id IN NUMBER, p_certification_id IN NUMBER) is



BEGIN
               g_user_id  := fnd_global.user_id;

Update AMW_PROC_CERT_EVAL_SUM
SET (CERTIFICATION_OPINION_ID) =
(select opinion.OPINION_ID
FROM AMW_OPINIONS_V opinion, AMW_OPINION_TYPES_TL opiniontype, FND_OBJECTS fndobject, AMW_OBJECT_OPINION_TYPES objectopiniontype
WHERE

(opinion.AUTHORED_DATE in (Select MAX(AMW_OPINIONS_V.AUTHORED_DATE)
                                         from AMW_OPINIONS_V
                                         Group By PK1_VALUE)) AND
 opinion.PK3_VALUE = p_org_id AND
opinion.PK2_VALUE = p_certification_id AND
opinion.PK1_VALUE = p_process_id AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_NAME = 'Certification' AND
opiniontype.LANGUAGE = 'US' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_PROCESS'), LAST_UPDATE_DATE = SYSDATE, LAST_UPDATED_BY = G_USER_ID
WHERE PROCESS_ID = p_process_id and CERTIFICATION_ID = p_certification_id and ORGANIZATION_ID = p_org_id;

EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Certification_Detail'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Certification_Detail'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));




END Update_Certification_Detail;





-- For each process, calculate number of orgs in which the process is present, restricted by scope of the certification

PROCEDURE UPDATE_GLOBAL_PROC_INFO(p_process_id IN NUMBER, p_certification_id IN NUMBER, p_global_org_id IN NUMBER) is

l_total_org_cert NUMBER;
l_org_cert NUMBER;



BEGIN

-- Set Global Process flag for each row of the global process, also update the total no. of orgs in which
-- the process is executed in
               g_user_id  := fnd_global.user_id;
Update AMW_PROC_CERT_EVAL_SUM
SET TOTAL_ORG_PROCESS_CERT =
(Select distinct count(*) from AMW_PROCESS_ORGANIZATION processorg where
(processorg.PROCESS_ID = p_process_id) and
(processorg.ORGANIZATION_ID = p_global_org_id))
, GLOBAL_PROCESS ='Y', LAST_UPDATE_DATE = SYSDATE, LAST_UPDATED_BY = G_USER_ID
where PROCESS_ID = p_process_id and CERTIFICATION_ID = p_certification_id
and ORGANIZATION_ID = p_global_org_id;

-- Update the row again with number of orgs where the process is certified
Update AMW_PROC_CERT_EVAL_SUM
SET ORG_PROCESS_CERT =
(
select distinct count(*)
FROM AMW_OPINIONS_V opinion, AMW_OPINION_TYPES_TL opiniontype, FND_OBJECTS fndobject, AMW_OBJECT_OPINION_TYPES objectopiniontype
WHERE

(opinion.AUTHORED_DATE in (Select MAX(AMW_OPINIONS_V.AUTHORED_DATE)
                                         from AMW_OPINIONS_V
                                         Group By PK1_VALUE)) AND
opinion.PK2_VALUE = p_certification_id AND
opinion.PK1_VALUE = p_process_id AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_NAME = 'Certification' AND
opiniontype.LANGUAGE = 'US' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_PROCESS' AND
((opinion.AUDIT_RESULT = 'Certified') OR (opinion.AUDIT_RESULT = 'Certified with Issues'))
), LAST_UPDATE_DATE = SYSDATE, LAST_UPDATED_BY = G_USER_ID
WHERE PROCESS_ID = p_process_id and CERTIFICATION_ID = p_certification_id and ORGANIZATION_ID = p_global_org_id;


EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Global_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));


     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Global_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));



END UPDATE_GLOBAL_PROC_INFO;





-- The last evaluation results, unmitigated risks, ineffective controls and open findings are all populated based on audit opinions

PROCEDURE UPDATE_LAST_EVALUATION_INFO(p_process_id IN NUMBER, p_org_id IN NUMBER,p_certification_id IN NUMBER) is



BEGIN
               g_user_id  := fnd_global.user_id;

Update AMW_PROC_CERT_EVAL_SUM
SET (EVALUATION_OPINION_ID) =
(
select  opinion.OPINION_ID
FROM AMW_OPINIONS_V opinion, AMW_OPINION_TYPES_TL opiniontype, FND_OBJECTS fndobject, AMW_OBJECT_OPINION_TYPES objectopiniontype
WHERE

(opinion.AUTHORED_DATE in (Select MAX(AMW_OPINIONS_V.AUTHORED_DATE)
                                         from AMW_OPINIONS_V
                                         Group By PK1_VALUE)) AND
opinion.PK1_VALUE = p_process_id AND
opinion.PK3_VALUE = p_org_id AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_NAME = 'Evaluation' AND
opiniontype.LANGUAGE = 'US' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_PROCESS'
) , LAST_UPDATE_DATE = SYSDATE, LAST_UPDATED_BY = G_USER_ID
WHERE PROCESS_ID = p_process_id and CERTIFICATION_ID = p_certification_id and ORGANIZATION_ID = p_org_id;

EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Last_Evaluation_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Last_Evaluation_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));


END UPDATE_LAST_EVALUATION_INFO;




PROCEDURE UPDATE_UNMITIGATED_RISKS(p_process_id IN NUMBER, p_org_id IN NUMBER, p_certification_id IN NUMBER) is



BEGIN
               g_user_id  := fnd_global.user_id;

Update AMW_PROC_CERT_EVAL_SUM
SET UNMITIGATED_RISKS =
(
select  distinct count(*)
        from    amw_risk_associations assoctable,
        amw_risks_all_vl risktable,
        amw_audit_units_v orgtable,
        amw_wf_org_hierarchy_main_v processtable,
        fnd_objects fo,
        amw_opinion_types_tl optypes,
        AMW_OBJECT_OPINION_TYPES objoptypes,
        amw_opinions_v opinionstable,
        pa_project_lists_v pap,
        AMW_PROCESS_ORGANIZATION procorg

where       assoctable.object_type = 'PROCESS_ORG'
        and orgtable.organization_id = procorg.organization_id
        and processtable.process_id = procorg.process_id
        and assoctable.risk_id = risktable.risk_id
        and assoctable.pk1 = procorg.PROCESS_ORGANIZATION_ID
        and opinionstable.pk1_value = assoctable.risk_id
        and opinionstable.pk3_value = procorg.organization_id
		and opinionstable.pk3_value = p_org_id
        and opinionstable.pk4_value = procorg.process_id
		and opinionstable.pk4_value = p_process_id
        and opinionstable.pk5_value is null
        and opinionstable.object_opinion_type_id =
objoptypes.object_opinion_type_id

        and opinionstable.last_update_date in
            (   select max ( a.last_update_date )
                from amw_opinions_v a
                where a.pk1_value = opinionstable.pk1_value
                and a.pk3_value = opinionstable.pk3_value
                and a.pk4_value = opinionstable.pk4_value
                and a.object_opinion_type_id =
opinionstable.object_opinion_type_id
                group by a.pk1_value )

        and opinionstable.audit_result_code = 'INEFFECTIVE'
        and pap.project_id = opinionstable.pk2_value
        and pap.project_status_code = 'CLOSED'

        and objoptypes.object_id = fo.object_id
        and fo.obj_name = 'AMW_ORG_PROCESS_RISK'
        and objoptypes.opinion_type_id = optypes.opinion_type_id
        and optypes.opinion_type_name =  'Evaluation'
        and optypes.LANGUAGE = 'US'

) , LAST_UPDATE_DATE = SYSDATE, LAST_UPDATED_BY = G_USER_ID
WHERE PROCESS_ID = p_process_id and CERTIFICATION_ID = p_certification_id and ORGANIZATION_ID = p_org_id;


EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Unmitigated_Risks'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Unmitigated_Risks'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));



END UPDATE_UNMITIGATED_RISKS;



PROCEDURE UPDATE_INEFFECTIVE_CONTROLS(p_process_id IN NUMBER, p_org_id IN NUMBER, p_certification_id IN NUMBER) is




BEGIN
               g_user_id  := fnd_global.user_id;

Update AMW_PROC_CERT_EVAL_SUM
SET INEFFECTIVE_CONTROLS =
(select  distinct Count(*)

from    amw_control_associations ctrlassoc,
        amw_risk_associations riskassoc,
        amw_process_organization procorg,
        amw_controls_all_vl controltable,
        amw_audit_units_v orgtable,
        amw_wf_org_hierarchy_main_v processtable,
        fnd_objects fo,
        amw_opinion_types_tl optypes,
        AMW_OBJECT_OPINION_TYPES objoptypes,
        pa_project_lists_v pap,
        amw_opinions_v opinionstable

where   procorg.process_id = processtable.process_id
        and procorg.process_id = p_process_id
        and procorg.organization_id = orgtable.organization_id
		and procorg.organization_id = p_org_id
        and procorg.process_organization_id = riskassoc.pk1
        and riskassoc.object_type = 'PROCESS_ORG'
        and riskassoc.risk_association_id = ctrlassoc.pk1
        and ctrlassoc.object_type = 'RISK_ORG'
        and ctrlassoc.control_id = controltable.control_id

        and   opinionstable.pk1_value = controltable.control_id
        and   opinionstable.pk3_value = orgtable.organization_id
        and   opinionstable.pk4_value is null
        and   opinionstable.pk5_value is null
        and   opinionstable.object_opinion_type_id =
objoptypes.object_opinion_type_id

        and opinionstable.last_update_date in
            (   select max ( a.last_update_date )
                from amw_opinions_v a
                where a.pk1_value = opinionstable.pk1_value
                and a.pk3_value = opinionstable.pk3_value
                and a.object_opinion_type_id =
opinionstable.object_opinion_type_id
                group by a.pk1_value )

        and opinionstable.audit_result_code = 'INEFFECTIVE'
        and pap.project_id = opinionstable.pk2_value
        and pap.project_status_code = 'CLOSED'

        and objoptypes.object_id = fo.object_id
        and fo.obj_name = 'AMW_ORG_CONTROL'
        and objoptypes.opinion_type_id = optypes.opinion_type_id
        and optypes.opinion_type_name = 'Evaluation'
		and optypes.LANGUAGE = 'US'
), LAST_UPDATE_DATE = SYSDATE, LAST_UPDATED_BY = G_USER_ID
WHERE PROCESS_ID = p_process_id and CERTIFICATION_ID = p_certification_id and ORGANIZATION_ID = p_org_id;

EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Ineffective_Controls'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Ineffective_Controls'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));



END UPDATE_INEFFECTIVE_CONTROLS;




PROCEDURE Populate_Summary(p_certification_id IN VARCHAR2) IS

-- select all processes

cursor proc is

select process_id, organization_id
from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc,
     AMW_ACCT_ASSOCIATIONS acct_assoc, AMW_PROCESS_ORGANIZATION process_org
where cert.certification_id = p_certification_id and cert.object_type = 'FIN_STMT'
      and cert.statement_group_id = key_acc.statement_group_id and
      cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID and
      acct_assoc.natural_account_id = key_acc.natural_account_id and
      acct_assoc.object_type = 'PROCESS_ORG' and
      process_org.process_organization_id = acct_assoc.pk1;

c1_rec proc%rowtype;

proc_rec proc%rowtype;

l_global_org_id NUMBER;
l_count NUMBER;


BEGIN
-- Insert all this info into the summary table with one row per process, org.
l_global_org_id := fnd_profile.value('AMW_GLOBAL_ORG_ID');
               g_user_id  := fnd_global.user_id;
               g_login_id := fnd_global.conc_login_id;

for proc_rec in proc loop

select count(*) into l_count from amw_proc_cert_eval_sum
where certification_id = p_certification_id and
    process_id = proc_rec.process_id and organization_id = proc_rec.organization_id;

if l_count = 0 then

INSERT into AMW_PROC_CERT_EVAL_SUM(CERTIFICATION_ID, PROCESS_ID, ORGANIZATION_ID, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, lAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
VALUES (p_certification_id, proc_rec.PROCESS_ID, proc_rec.ORGANIZATION_ID,G_USER_ID,SYSDATE,G_USER_ID,SYSDATE,G_LOGIN_ID);

end if;

Update_Next_Level_Proc_Info(proc_rec.PROCESS_ID, proc_rec.ORGANIZATION_ID, p_certification_id);

Update_Certification_Detail(proc_rec.PROCESS_ID, proc_rec.ORGANIZATION_ID, p_certification_id);

if (l_global_org_id is not null) and(proc_rec.ORGANIZATION_ID = l_global_org_id)
 then UPDATE_GLOBAL_PROC_INFO(proc_rec.PROCESS_ID, p_certification_id, l_global_org_id);
 end if;

UPDATE_LAST_EVALUATION_INFO(proc_rec.PROCESS_ID, proc_rec.ORGANIZATION_ID, p_certification_id);

UPDATE_UNMITIGATED_RISKS(proc_rec.PROCESS_ID, proc_rec.ORGANIZATION_ID, p_certification_id);

UPDATE_INEFFECTIVE_CONTROLS(proc_rec.PROCESS_ID, proc_rec.ORGANIZATION_ID, p_certification_id);


end loop;

EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_Summary'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Summary'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

END Populate_Summary;


PROCEDURE POPULATE_ALL_CERT_SUMMARY
(x_errbuf 		OUT 	NOCOPY VARCHAR2,
 x_retcode 		OUT 	NOCOPY NUMBER,
 p_certification_id     IN    	NUMBER
)
IS

-- select all processes in scope for the certification

cursor c1 is
Select distinct CERTIFICATION_ID
from AMW_CERTIFICATION_VL
where object_type = 'FIN_STMT' and
CERTIFICATION_STATUS in ('ACTIVE','DRAFT');

c1_rec c1%rowtype;

BEGIN

for c1_rec in c1 loop

Populate_Summary(c1_rec.CERTIFICATION_ID);

end loop;


EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_All_Cert_Summary'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_All_Cert_Summary'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

END Populate_All_Cert_Summary;

/************* the implementation before bussiness event takes in place in amw.d   *********/
PROCEDURE  Populate_Cert_General_Sum(
    p_certification_id          IN    	NUMBER,
    p_start_date		IN  	DATE
)
is

    CURSOR new_risks_added IS
              SELECT count(1)
	  FROM AMW_RISK_ASSOCIATIONS
         WHERE creation_date >= p_start_date
           AND object_type = 'PROCESS_ORG'
           AND pk1 in (
           select distinct p_org.process_organization_id
                       from AMW_ACCT_ASSOCIATIONS acct_assoc,
                            AMW_PROCESS_ORGANIZATION process_org,
							AMW_PROCESS_ORGANIZATION p_org,
                            (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                       where acct_assoc.natural_account_id in
 --                            (select natural_account_id
 --                             from amw_fin_key_accounts_b
 --                             start with (natural_account_id, account_group_id) in
 --				(select natural_account_id, account_group_id
--				from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--				where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)
-- Note by Sanket: The above connect by was replaced by the below query
-- which uses the newly created flat table. We have to use a union because
-- the first part of the query only returns the children (if any) of the (natural
-- account id = x, account group id = y) pair returned by the subquery, while the
-- second part of the query returns the actual pair (x, y). Such unions
-- are used in all the flattened queries in this file.

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                           and acct_assoc.object_type = 'PROCESS_ORG' and
                           process_org.process_organization_id = acct_assoc.pk1 and
                           hier.process_id = process_org.process_id and
							 hier.organization_id = process_org.organization_id and
							 hier.up_down_ind = 'D' and
							 p_org.process_id = hier.child_process_id and
							 p_org.organization_id = hier.organization_id
                             );


    CURSOR new_controls_added IS
        SELECT count(1)
          FROM (
          SELECT distinct aca.control_id, p_org.organization_id
	          FROM AMW_CONTROL_ASSOCIATIONS aca,
	               AMW_RISK_ASSOCIATIONS ara,
	               AMW_PROCESS_ORGANIZATION apo,
                   AMW_ACCT_ASSOCIATIONS acct_assoc,
	               AMW_PROCESS_ORGANIZATION p_org,
				   (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in
--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)
-- Modifed for flatting key_acct table
		( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)


               AND acct_assoc.object_type = 'PROCESS_ORG'
               AND apo.process_organization_id = acct_assoc.pk1
			   AND hier.process_id = apo.process_id
			   AND hier.organization_id = apo.organization_id
               AND hier.up_down_ind = 'D'
			   AND p_org.process_id = hier.child_process_id
			   AND p_org.organization_id = hier.organization_id
			   AND ara.object_type = 'PROCESS_ORG'
           	   AND ara.pk1 = p_org.process_organization_id
			   AND aca.creation_date >= p_start_date
               AND aca.object_type = 'RISK_ORG'
               AND aca.pk1 = ara.risk_association_id
           	   AND not exists (SELECT 'Y'
           	   		        FROM AMW_CONTROL_ASSOCIATIONS aca2,
	               			  AMW_RISK_ASSOCIATIONS ara2
                 		     WHERE aca2.creation_date <  p_start_date
                   		       AND aca2.object_type = 'RISK_ORG'
                   		       AND aca2.pk1 = ara2.risk_association_id
                               AND ara2.object_type = 'PROCESS_ORG'
       	                       AND ara2.pk1 = p_org.process_organization_id
                               AND aca2.control_id = aca.control_id
                               ));


    CURSOR global_proc_not_certified IS
        SELECT count(1)
          FROM (
                  SELECT distinct hier.organization_id, hier.child_process_id
                  FROM AMW_PROCESS_ORGANIZATION apo,
                       AMW_ACCT_ASSOCIATIONS acct_assoc,
                        (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in
--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1
                   AND apo.organization_id = fnd_profile.value('AMW_GLOBAL_ORG_ID')
                   AND apo.process_id = hier.process_id
                   AND apo.organization_id = hier.organization_id
                   AND hier.up_down_ind = 'D'
                   AND not exists (SELECT 'Y'
                             FROM AMW_OPINIONS_V aov
                             WHERE aov.object_name = 'AMW_ORG_PROCESS'
                              AND aov.opinion_type_code = 'CERTIFICATION'
                              AND aov.pk3_value = hier.organization_id
                              AND aov.pk2_value in (select proc_cert_id from AMW_FIN_PROC_CERT_RELAN where fin_stmt_cert_id = p_certification_id)
                              AND aov.pk1_value = hier.child_process_id)
            );


    CURSOR global_proc_with_issue IS
        SELECT count(1)
          FROM (
          SELECT distinct hier.organization_id, hier.child_process_id
                  FROM AMW_PROCESS_ORGANIZATION apo,
                   AMW_ACCT_ASSOCIATIONS acct_assoc,
                   AMW_OPINIONS_V aov,
				    (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in
--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1
                   AND apo.organization_id = fnd_profile.value('AMW_GLOBAL_ORG_ID')
                   AND hier.process_id = apo.process_id
				   AND hier.organization_id = apo.organization_id
                   AND hier.up_down_ind = 'D'
                   AND aov.object_name = 'AMW_ORG_PROCESS'
                   AND aov.opinion_type_code = 'CERTIFICATION'
                   AND aov.pk3_value = hier.organization_id
                   AND aov.pk2_value in (select proc_cert_id from AMW_FIN_PROC_CERT_RELAN where fin_stmt_cert_id = p_certification_id)
                   AND aov.pk1_value = hier.child_process_id
                   AND aov.audit_result_code <> 'EFFECTIVE'
            );

    CURSOR local_proc_not_certified IS
        SELECT count(1)
          FROM (SELECT distinct hier.organization_id, hier.child_process_id
                  FROM AMW_PROCESS_ORGANIZATION apo,
                   AMW_ACCT_ASSOCIATIONS acct_assoc,
				   (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in
--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1
                   AND apo.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
				   AND hier.process_id = apo.process_id
				   AND hier.organization_id = apo.organization_id
                   AND hier.up_down_ind = 'D'
                   AND not exists (SELECT 'Y'
                             FROM AMW_OPINIONS_V aov
                            WHERE aov.object_name = 'AMW_ORG_PROCESS'
                              AND aov.opinion_type_code = 'CERTIFICATION'
                              AND aov.pk3_value = hier.organization_id
                              AND aov.pk2_value in (select proc_cert_id from AMW_FIN_PROC_CERT_RELAN where fin_stmt_cert_id = p_certification_id)
                              AND aov.pk1_value = hier.child_process_id));

    CURSOR local_proc_with_issue IS
        SELECT count(1)
          FROM (SELECT distinct hier.organization_id, hier.child_process_id
                  FROM AMW_PROCESS_ORGANIZATION apo,
                   AMW_ACCT_ASSOCIATIONS acct_assoc,
                   AMW_OPINIONS_V aov,
				   (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in
--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1
                   AND apo.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'), -999)
				   AND hier.process_id = apo.process_id
				   AND hier.organization_id = apo.organization_id
                   AND hier.up_down_ind = 'D'
                   AND aov.object_name = 'AMW_ORG_PROCESS'
                   AND aov.opinion_type_code = 'CERTIFICATION'
                   AND aov.pk3_value = hier.organization_id
                   AND aov.pk2_value in (select proc_cert_id from AMW_FIN_PROC_CERT_RELAN where fin_stmt_cert_id = p_certification_id)
                   AND aov.pk1_value = hier.child_process_id
                   AND aov.audit_result_code <> 'EFFECTIVE');

    CURSOR global_proc_with_ineff_ctrl IS
        SELECT count(distinct hier.child_process_id)
          FROM AMW_PROCESS_ORGANIZATION apo,
               AMW_ACCT_ASSOCIATIONS acct_assoc,
               AMW_OPINIONS_V aov,
			   (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
         WHERE acct_assoc.natural_account_id in
 --                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                          connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

           AND acct_assoc.object_type = 'PROCESS_ORG'
           AND apo.process_organization_id = acct_assoc.pk1
           AND apo.organization_id = fnd_profile.value('AMW_GLOBAL_ORG_ID')
                   AND hier.process_id = apo.process_id
				   AND hier.organization_id = apo.organization_id
                   AND hier.up_down_ind = 'D'
           AND aov.object_name = 'AMW_ORG_PROCESS'
           AND aov.opinion_type_code = 'EVALUATION'
           AND aov.pk3_value = hier.organization_id
           AND aov.pk1_value = hier.child_process_id
           AND aov.authored_date = (select max(aov2.authored_date)
			      		   from AMW_OPINIONS_V aov2
			      		  where aov2.object_opinion_type_id = aov.object_opinion_type_id
			      		    and aov2.pk3_value = aov.pk3_value
                            and aov2.pk1_value = aov.pk1_value)
                            and aov.audit_result_code <> 'EFFECTIVE';

    CURSOR local_proc_with_ineff_ctrl IS
        SELECT count(1)
          FROM (SELECT distinct hier.organization_id, hier.child_process_id
                  FROM AMW_PROCESS_ORGANIZATION apo,
                       AMW_ACCT_ASSOCIATIONS acct_assoc,
                       AMW_OPINIONS_V aov,
					   (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in

--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1
                   AND apo.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'), -999)
                   AND hier.process_id = apo.process_id
				   AND hier.organization_id = apo.organization_id
                   AND hier.up_down_ind = 'D'
                   AND aov.object_name = 'AMW_ORG_PROCESS'
                   AND aov.opinion_type_code = 'EVALUATION'
                   AND aov.pk3_value = hier.organization_id
                   AND aov.pk1_value = hier.child_process_id
                   AND aov.authored_date = (select max(aov2.authored_date)
			      		   from AMW_OPINIONS_V aov2
			      		  where aov2.object_opinion_type_id = aov.object_opinion_type_id
			      		        and aov2.pk3_value = aov.pk3_value
                                AND aov.audit_result_code <> 'EFFECTIVE'
                                and aov2.pk1_value = aov.pk1_value));


    CURSOR unmitigated_risks IS
        SELECT count(1)
          FROM (SELECT distinct p_org.organization_id, p_org.process_id, ara.risk_id
                  FROM AMW_PROCESS_ORGANIZATION apo,
                       AMW_ACCT_ASSOCIATIONS acct_assoc,
                       AMW_RISK_ASSOCIATIONS ara,
                       AMW_OPINIONS_V aov,
                       AMW_PROCESS_ORGANIZATION p_org,
					   (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in

--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1
                   AND hier.process_id = apo.process_id
				   AND hier.organization_id = apo.organization_id
                   AND hier.up_down_ind = 'D'
				   AND p_org.process_id = hier.child_process_id
				   AND p_org.organization_id = hier.organization_id
                   AND ara.object_type = 'PROCESS_ORG'
                   AND ara.pk1 = p_org.process_organization_id
                   AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
                   AND aov.opinion_type_code = 'EVALUATION'
                   AND aov.pk3_value = p_org.organization_id
                   AND aov.pk4_value = p_org.process_id
                   AND aov.pk1_value = ara.risk_id
  	           AND aov.authored_date =
			      		(select max(aov2.authored_date)
			      		   from AMW_OPINIONS_V aov2
			      		  where aov2.object_opinion_type_id = aov.object_opinion_type_id
			      		    and aov2.pk4_value = aov.pk4_value
			      		    and aov2.pk3_value = aov.pk3_value
                                            and aov2.pk1_value = aov.pk1_value)
                   AND aov.audit_result_code <> 'EFFECTIVE');

    CURSOR ineffective_controls IS
        SELECT count(1)
          FROM (SELECT distinct p_org.organization_id, aca.control_id
                  FROM AMW_PROCESS_ORGANIZATION apo,
                       AMW_ACCT_ASSOCIATIONS acct_assoc,
                       AMW_RISK_ASSOCIATIONS ara, AMW_CONTROL_ASSOCIATIONS aca,
                       AMW_OPINIONS_V aov,
                       AMW_PROCESS_ORGANIZATION p_org,
					   (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in

--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1
                   AND hier.process_id = apo.process_id
				   AND hier.organization_id = apo.organization_id
                   AND hier.up_down_ind = 'D'
				   AND p_org.process_id = hier.child_process_id
				   AND p_org.organization_id = hier.organization_id
               	   AND ara.object_type = 'PROCESS_ORG'
               	   AND ara.pk1 = p_org.process_organization_id
                   AND aca.object_type = 'RISK_ORG'
                   AND aca.pk1 = ara.risk_association_id
                   AND aov.object_name = 'AMW_ORG_CONTROL'
                   AND aov.opinion_type_code = 'EVALUATION'
                   AND aov.pk3_value = p_org.organization_id
                   AND aov.pk1_value = aca.control_id
                   AND aov.authored_date =
			      		(select max(aov2.authored_date)
			      		   from AMW_OPINIONS_V aov2
			      		  where aov2.object_opinion_type_id = aov.object_opinion_type_id
			      		    and aov2.pk3_value = aov.pk3_value
                                            and aov2.pk1_value = aov.pk1_value)
                   AND aov.audit_result_code <> 'EFFECTIVE');


    CURSOR orgs_pending_in_scope IS
        SELECT count(distinct p_org.organization_id)
                  FROM AMW_PROCESS_ORGANIZATION apo,
                       AMW_ACCT_ASSOCIATIONS acct_assoc,
                       AMW_PROCESS_ORGANIZATION p_org,
					   (select process_id, organization_id, parent_child_id child_process_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm
			 union
			 select process_id, organization_id, process_id child_process_id, 'D' up_down_ind
			 from amw_process_organization) hier
                 WHERE acct_assoc.natural_account_id in

--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1
                   AND hier.process_id = apo.process_id
				   AND hier.organization_id = apo.organization_id
                   AND hier.up_down_ind = 'D'
				   AND p_org.process_id = hier.child_process_id
				   AND p_org.organization_id = hier.organization_id
                   AND not exists (SELECT 'Y'
                             FROM AMW_OPINIONS_V aov
                            WHERE aov.object_name = 'AMW_ORG_PROCESS'
                              AND aov.opinion_type_code = 'CERTIFICATION'
                              AND aov.pk3_value = p_org.organization_id
                              AND aov.pk2_value = p_certification_id
                              AND aov.pk1_value = p_org.process_id);

    CURSOR orgs_in_scope IS
        SELECT count(distinct apo.organization_id)
                  FROM AMW_PROCESS_ORGANIZATION apo,
                       AMW_ACCT_ASSOCIATIONS acct_assoc
                 WHERE acct_assoc.natural_account_id in

--                             (select natural_account_id
--                              from amw_fin_key_accounts_b
--                              start with (natural_account_id, account_group_id) in
--							  (select natural_account_id, account_group_id
--							  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
--							  where cert.certification_id = p_certification_id and
--                             cert.object_type = 'FIN_STMT' and
--                             cert.statement_group_id = key_acc.statement_group_id and
--                             cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID)
--                              connect by parent_natural_account_id = PRIOR natural_account_id and
--                                         account_group_id = PRIOR account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC key_acc
					  where cert.certification_id = p_certification_id
                            		  and cert.object_type = 'FIN_STMT'
                           		  and cert.statement_group_id = key_acc.statement_group_id
                          		  and cert.financial_statement_id = key_acc.FINANCIAL_STATEMENT_ID
					)
				)

                   AND acct_assoc.object_type = 'PROCESS_ORG'
                   AND apo.process_organization_id = acct_assoc.pk1;

    l_new_risks_added                	NUMBER;
    l_new_controls_added             	NUMBER;
    l_global_proc_not_certified      	NUMBER;
    l_global_proc_with_issue 	     	NUMBER;
    l_local_proc_not_certified 	     	NUMBER;
    l_local_proc_with_issue          	NUMBER;
    l_global_proc_with_ineff_ctrl NUMBER;
    l_local_proc_with_ineff_ctrl 	NUMBER;
    l_unmitigated_risks 		NUMBER;
    l_ineffective_controls 		NUMBER;
    l_orgs_in_scope			NUMBER;
    l_orgs_pending_in_scope		NUMBER;

BEGIN

    fnd_file.put_line (fnd_file.LOG, 'p_certification_id='||to_char(p_certification_id));
    fnd_file.put_line(fnd_file.LOG, 'before new_risks_added :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN new_risks_added;
    FETCH new_risks_added INTO l_new_risks_added;
    CLOSE new_risks_added;

    fnd_file.put_line(fnd_file.LOG, 'before new_controls_added :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN new_controls_added;
    FETCH new_controls_added INTO l_new_controls_added;
    CLOSE new_controls_added;

    fnd_file.put_line(fnd_file.LOG, 'before global_proc_not_certified :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN global_proc_not_certified;
    FETCH global_proc_not_certified INTO l_global_proc_not_certified;
    CLOSE global_proc_not_certified;

    fnd_file.put_line(fnd_file.LOG, 'before global_proc_with_issue :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN global_proc_with_issue;
    FETCH global_proc_with_issue INTO l_global_proc_with_issue;
    CLOSE global_proc_with_issue;

    fnd_file.put_line(fnd_file.LOG, 'before local_proc_not_certified :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN local_proc_not_certified;
    FETCH local_proc_not_certified INTO l_local_proc_not_certified;
    CLOSE local_proc_not_certified;

    fnd_file.put_line(fnd_file.LOG, 'before local_proc_with_issue :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN local_proc_with_issue;
    FETCH local_proc_with_issue INTO l_local_proc_with_issue;
    CLOSE local_proc_with_issue;

    fnd_file.put_line(fnd_file.LOG, 'before global_proc_with_ineff_ctrl :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN global_proc_with_ineff_ctrl;
    FETCH global_proc_with_ineff_ctrl INTO l_global_proc_with_ineff_ctrl;
    CLOSE global_proc_with_ineff_ctrl;

    fnd_file.put_line(fnd_file.LOG, 'before local_proc_with_ineff_ctrl :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN local_proc_with_ineff_ctrl;
    FETCH local_proc_with_ineff_ctrl INTO l_local_proc_with_ineff_ctrl;
    CLOSE local_proc_with_ineff_ctrl;

    fnd_file.put_line(fnd_file.LOG, 'before unmitigated_risks :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN unmitigated_risks;
    FETCH unmitigated_risks INTO l_unmitigated_risks;
    CLOSE unmitigated_risks;

    fnd_file.put_line(fnd_file.LOG, 'before ineffective_controls :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN ineffective_controls;
    FETCH ineffective_controls INTO l_ineffective_controls;
    CLOSE ineffective_controls;

    fnd_file.put_line(fnd_file.LOG, 'before orgs_pending_in_scope :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN orgs_pending_in_scope;
    FETCH orgs_pending_in_scope INTO l_orgs_pending_in_scope;
    CLOSE orgs_pending_in_scope;

    fnd_file.put_line(fnd_file.LOG, 'before orgs_in_scope :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN orgs_in_scope;
    FETCH orgs_in_scope INTO l_orgs_in_scope;
    CLOSE orgs_in_scope;

    UPDATE  AMW_CERT_DASHBOARD_SUM
       SET NEW_RISKS_ADDED = l_new_risks_added,
           NEW_CONTROLS_ADDED = l_new_controls_added,
           PROCESSES_NOT_CERT = l_global_proc_not_certified,
           PROCESSES_CERT_ISSUES = l_global_proc_with_issue,
           ORG_PROCESS_NOT_CERT = l_local_proc_not_certified,
           ORG_PROCESS_CERT_ISSUES = l_local_proc_with_issue,
           PROC_INEFF_CONTROL = l_global_proc_with_ineff_ctrl,
           ORG_PROC_INEFF_CONTROL = l_local_proc_with_ineff_ctrl,
           UNMITIGATED_RISKS = l_unmitigated_risks,
           INEFFECTIVE_CONTROLS = l_ineffective_controls,
           ORGS_IN_SCOPE = l_orgs_in_scope,
           ORGS_PENDING_IN_SCOPE = l_orgs_pending_in_scope,
           PERIOD_START_DATE = p_start_date,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	   LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
     WHERE certification_id = p_certification_id;

    IF (SQL%NOTFOUND) THEN
       INSERT INTO AMW_CERT_DASHBOARD_SUM (
	          CERTIFICATION_ID,
                  NEW_RISKS_ADDED,
                  NEW_CONTROLS_ADDED,
                  PROCESSES_NOT_CERT,
                  PROCESSES_CERT_ISSUES,
                  ORG_PROCESS_NOT_CERT,
                  ORG_PROCESS_CERT_ISSUES,
                  PROC_INEFF_CONTROL,
                  ORG_PROC_INEFF_CONTROL,
                  UNMITIGATED_RISKS,
                  INEFFECTIVE_CONTROLS,
                  ORGS_IN_SCOPE,
                  ORGS_PENDING_IN_SCOPE,
                  PERIOD_START_DATE,
	          CREATED_BY,
	          CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
	          LAST_UPDATE_LOGIN)
	SELECT p_certification_id,
       	       l_new_risks_added,
       	       l_new_controls_added,
       	       l_global_proc_not_certified,
       	       l_global_proc_with_issue,
       	       l_local_proc_not_certified,
       	       l_local_proc_with_issue,
	       l_global_proc_with_ineff_ctrl,
               l_local_proc_with_ineff_ctrl,
               l_unmitigated_risks,
               l_ineffective_controls,
               l_orgs_in_scope,
               l_orgs_pending_in_scope,
               p_start_date,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               SYSDATE,
	       FND_GLOBAL.USER_ID,
	       FND_GLOBAL.USER_ID
	FROM  DUAL;
    END IF;

    commit;
EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_All_Cert_DetSummary'
              || SUBSTR (SQLERRM, 1, 100), 1, 200));
END Populate_Cert_General_Sum;


/***************************OBSOLATED. USED IN CONCURRENT PROGRAM BEFORE BES AMW.D  ********
PROCEDURE Populate_All_Cert_General_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id	IN	 NUMBER
)
IS
    -- select all processes in scope for the certification
    CURSOR c_cert IS
        SELECT cert.CERTIFICATION_ID, period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.object_type = 'FIN_STMT' and cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           and cert.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT');

    CURSOR c_start_date IS
    	SELECT period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.object_type = 'FIN_STMT' and cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           and cert.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT')
           AND cert.certification_id = p_certification_id;

    l_start_date DATE;
BEGIN
    fnd_file.put_line (fnd_file.LOG,
		      'Certification_Id:'||p_certification_id);
    IF p_certification_id IS NOT NULL THEN
        OPEN c_start_date;
        FETCH c_start_date INTO l_start_date;
        IF c_start_date%FOUND THEN
         Populate_Cert_General_Sum(p_certification_id, l_start_date);
        END IF;
        CLOSE c_start_date;
    ELSE
        FOR cert_rec IN c_cert LOOP
           Populate_Cert_General_Sum(cert_rec.certification_id, cert_rec.start_date);
        END LOOP;
    END IF;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_All_Cert_General_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
     WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_All_Cert_General_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
         retcode := FND_API.G_RET_STS_UNEXP_ERROR;
END Populate_All_Cert_General_Sum;

*******************************************************/

/**** the implemention before business event takes place since amw.d  ***********/
PROCEDURE  Populate_Fin_Process_Eval_Sum(
    p_certification_id          IN      NUMBER,
    p_start_date                IN      DATE,
    p_end_date                  IN      DATE,
    p_process_organization_id   IN	NUMBER,
    p_process_id		IN   	NUMBER,
    p_organization_id		IN 	NUMBER,
    p_account_process_flag      IN      VARCHAR2
)
IS

    CURSOR sub_processes_certified IS
    	SELECT  count(distinct aov.pk1_value)
      	FROM  	AMW_OPINIONS_V aov
        WHERE 	aov.object_name = 'AMW_ORG_PROCESS'
        AND 	aov.opinion_type_code = 'CERTIFICATION'
        AND 	aov.pk3_value = p_organization_id
--        AND 	aov.authored_date >= p_start_date
--        AND     aov.authored_date <= p_end_date
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id)
        AND     aov.pk1_value in (select distinct(orgrel.child_process_id)
                                  from AMW_PROCESS_ORG_RELATIONS orgrel
                                  START WITH orgrel.parent_process_id = p_process_id
                                  and orgrel.organization_id = p_organization_id
                                  CONNECT BY PRIOR orgrel.child_process_id = orgrel.parent_process_id
                                  and PRIOR orgrel.organization_id = orgrel.organization_id);

    CURSOR total_sub_processes IS
        SELECT  count(distinct child_process_id)
        FROM    AMW_PROCESS_ORG_RELATIONS
    	START WITH parent_process_id = p_process_id
               AND organization_id = p_organization_id
        CONNECT BY PRIOR child_process_id = parent_process_id
               AND PRIOR organization_id = organization_id;

/*
    CURSOR org_processes_certified IS
        SELECT  count(distinct aov.pk3_value)
        FROM    AMW_OPINIONS_V aov
        WHERE   aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'CERTIFICATION'
        AND     aov.pk3_value <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
        AND     aov.pk1_value = p_process_id
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id);
        --AND     aov.authored_date >= p_start_date
        --AND     aov.authored_date <= p_end_date ;


    CURSOR total_org_processes IS
        SELECT 	count(distinct po.organization_id)
        FROM   	AMW_ACCT_ASSOCIATIONS aa,
               	AMW_FIN_ITEMS_KEY_ACC fika,
	      	AMW_PROCESS_ORGANIZATION po,
		AMW_CERTIFICATION_B cert
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     aa.pk1 = po.process_organization_id
        AND    	aa.natural_account_id in
--		(select acc.natural_account_id
--                           from AMW_FIN_KEY_ACCOUNTS_B acc
--                         START WITH acc.natural_account_id = fika.natural_account_id
--                            and acc.account_group_id = fika.account_group_id
--                         CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                                and PRIOR acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
	  	  where acc.natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		)

        AND    	fika.statement_group_id =  cert.statement_group_id
	AND     fika.financial_statement_id = cert.financial_statement_id
	AND     cert.certification_id = p_certification_id
        AND     po.process_id = p_process_id
        AND     po.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999);
*/

    CURSOR certification_result IS
        SELECT 	aov.opinion_id
        FROM 	AMW_OPINIONS_V aov
        WHERE 	aov.object_name = 'AMW_ORG_PROCESS'
        AND 	aov.opinion_type_code = 'CERTIFICATION'
        AND 	aov.pk3_value = p_organization_id
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id)
        AND 	aov.pk1_value = p_process_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS_V aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value
				     and aov2.pk2_value in
				       (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			        where fin_stmt_cert_id = p_certification_id));
                                 --  and aov2.authored_date >= p_start_date
                                 --  and aov2.authored_date <= p_end_date) ;

    CURSOR last_evaluation IS
        SELECT 	aov.opinion_id
	FROM 	AMW_OPINIONS_V aov
       	WHERE 	aov.object_name = 'AMW_ORG_PROCESS'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk3_value = p_organization_id
        AND 	aov.pk1_value = p_process_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS_V aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value);

    CURSOR unmitigated_risks IS
        SELECT 	count(1)
       	FROM  	AMW_PROCESS_ORGANIZATION apo,
       		AMW_RISK_ASSOCIATIONS ara,
                AMW_OPINIONS_V aov
        WHERE   apo.organization_id = p_organization_id
        AND     apo.process_id in ( select distinct(orgrel.child_process_id)
                                    from AMW_PROCESS_ORG_RELATIONS orgrel
                                    START WITH orgrel.child_process_id = p_process_id
                                    and orgrel.organization_id = apo.organization_id
                                    CONNECT BY PRIOR orgrel.child_process_id = orgrel.parent_process_id
                                    and PRIOR orgrel.organization_id = orgrel.organization_id )
        AND 	ara.object_type = 'PROCESS_ORG'
        AND 	ara.pk1 = apo.process_organization_id
        AND 	aov.object_name = 'AMW_ORG_PROCESS_RISK'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk3_value = apo.organization_id
        AND 	aov.pk4_value = apo.process_id
        AND 	aov.pk1_value = ara.risk_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS_V aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk4_value = aov.pk4_value
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value)
				 -- commented by qliu
                                 --    and aov2.authored_date >= p_start_date
                                 --    and aov2.authored_date <= p_end_date)
      	AND 	aov.audit_result_code <> 'EFFECTIVE';



    CURSOR ineffective_controls IS
        SELECT 	count(distinct aca.control_id)
        FROM 	AMW_PROCESS_ORGANIZATION apo,
               	AMW_RISK_ASSOCIATIONS ara,
		AMW_CONTROL_ASSOCIATIONS aca,
                AMW_OPINIONS_V aov
        WHERE   apo.organization_id = p_organization_id
        AND     apo.process_id in ( select distinct(orgrel.child_process_id)
                                    from AMW_PROCESS_ORG_RELATIONS orgrel
                                    START WITH orgrel.child_process_id = p_process_id
                                    and orgrel.organization_id = apo.organization_id
                                    CONNECT BY PRIOR orgrel.child_process_id = orgrel.parent_process_id
                                    and PRIOR orgrel.organization_id = orgrel.organization_id )
        AND 	ara.object_type = 'PROCESS_ORG'
        AND 	ara.pk1 = apo.process_organization_id
        AND 	aca.object_type = 'RISK_ORG'
        AND 	aca.pk1 = ara.risk_association_id
        AND 	aov.object_name = 'AMW_ORG_CONTROL'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk3_value = apo.organization_id
        AND 	aov.pk1_value = aca.control_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS_V aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value)
				 -- commented by qliu
                                 --    and aov2.authored_date >= p_start_date
                                 --    and aov2.authored_date <= p_end_date)
        AND 	aov.audit_result_code <> 'EFFECTIVE';



   l_sub_processes_certified		NUMBER;
   l_total_sub_processes		NUMBER;
   l_org_processes_certified		NUMBER;
   l_total_org_processes		NUMBER;
   l_cert_opinion_id			NUMBER;
   l_eval_opinion_id			NUMBER;
   l_last_evaluation			NUMBER;
   l_unmitigated_risks			NUMBER;
   l_ineffective_controls		NUMBER;
   l_open_findings                      NUMBER;

BEGIN

    OPEN sub_processes_certified;
    FETCH sub_processes_certified INTO l_sub_processes_certified;
    CLOSE sub_processes_certified;

    OPEN total_sub_processes;
    FETCH total_sub_processes INTO l_total_sub_processes;
    CLOSE total_sub_processes;

    IF (p_organization_id = NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)) THEN
    /*
      OPEN org_processes_certified;
      FETCH org_processes_certified INTO l_org_processes_certified;
      CLOSE org_processes_certified;
     */
      l_org_processes_certified := 0;
    /*
      OPEN total_org_processes;
      FETCH total_org_processes INTO l_total_org_processes;
      CLOSE total_org_processes;
    */
      l_total_org_processes := 0;
    ELSE
      l_org_processes_certified := 0;
      l_total_org_processes := 0;
    END IF;


    OPEN certification_result;
    FETCH certification_result INTO l_cert_opinion_id;
    CLOSE certification_result;

    OPEN last_evaluation;
    FETCH last_evaluation INTO l_eval_opinion_id;
    CLOSE last_evaluation;

    OPEN unmitigated_risks;
    FETCH unmitigated_risks INTO l_unmitigated_risks;
    CLOSE unmitigated_risks;

    OPEN ineffective_controls;
    FETCH ineffective_controls INTO l_ineffective_controls;
    CLOSE ineffective_controls;

    BEGIN
        l_open_findings := amw_findings_pkg.calculate_open_findings (
               'AMW_PROJ_FINDING',
               'PROJ_ORG_PROC', p_process_id,
               'PROJ_ORG', p_organization_id,
               null, null,
               null, null,
               null, null );
    EXCEPTION
        WHEN OTHERS THEN
            null;
    END;


    UPDATE  AMW_FIN_PROCESS_EVAL_SUM
       SET CERT_OPINION_ID = l_cert_opinion_id,
           EVAL_OPINION_ID = l_eval_opinion_id,
           UNMITIGATED_RISKS = l_unmitigated_risks,
           INEFFECTIVE_CONTROLS = l_ineffective_controls,
           NUMBER_OF_SUB_PROCS_CERTIFIED = l_sub_processes_certified,
           TOTAL_NUMBER_OF_SUB_PROCS = l_total_sub_processes,
           SUB_PROCS_CERTIFIED_PRCNT = round((l_sub_processes_certified/decode(nvl(l_total_sub_processes,0),0,1,l_total_sub_processes) *100),0),
           NUMBER_OF_ORG_PROCS_CERTIFIED = l_org_processes_certified,
           TOTAL_NUMBER_OF_ORG_PROCS = l_total_org_processes,
           ORG_PROCS_CERTIFIED_PRCNT = round((l_org_processes_certified/decode(nvl(l_total_org_processes,0),0,1,l_total_org_processes) *100),0),
           OPEN_FINDINGS = l_open_findings,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
     WHERE fin_certification_id = p_certification_id
     AND   organization_id = p_organization_id
     AND   process_id = p_process_id;

    IF (SQL%NOTFOUND) THEN
       INSERT INTO AMW_FIN_PROCESS_EVAL_SUM(
         FIN_CERTIFICATION_ID,
         PROCESS_ID,
	 ORGANIZATION_ID,
         CERT_OPINION_ID,
         EVAL_OPINION_ID,
         UNMITIGATED_RISKS,
         INEFFECTIVE_CONTROLS,
         UNMITIGATED_RISKS_PRCNT,
         INEFFECTIVE_CONTROLS_PRCNT,
         TOTAL_NUMBER_OF_SUB_PROCS,
         NUMBER_OF_SUB_PROCS_CERTIFIED,
         SUB_PROCS_CERTIFIED_PRCNT,
         TOTAL_NUMBER_OF_ORG_PROCS,
         NUMBER_OF_ORG_PROCS_CERTIFIED,
         ORG_PROCS_CERTIFIED_PRCNT,
         OPEN_FINDINGS,
         ACCOUNT_PROCESS_FLAG,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN)
       SELECT p_certification_id,
              p_process_id,
              p_organization_id,
              l_cert_opinion_id,
              l_eval_opinion_id,
              l_unmitigated_risks,
              l_ineffective_controls,
              null,
              null,
              l_total_sub_processes,
              l_sub_processes_certified,
              round((l_sub_processes_certified/decode(nvl(l_total_sub_processes,0),0,1,l_total_sub_processes) *100),0),
              l_total_org_processes,
              l_org_processes_certified,
              round((l_org_processes_certified/decode(nvl(l_total_org_processes,0),0,1,l_total_org_processes) *100),0),
              l_open_findings,
              p_account_process_flag,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.USER_ID
        FROM  DUAL;
    END IF;


EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Fin_Process_Eval_Sum'
              || SUBSTR (SQLERRM, 1, 100), 1, 200));
END Populate_Fin_Process_Eval_Sum;

PROCEDURE Populate_All_Fin_Proc_Eval_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
)
IS

-- select all processes in scope for the certification
    CURSOR c_cert IS
        SELECT cert.CERTIFICATION_ID, period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.object_type = 'FIN_STMT' and cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           and cert.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT');

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_All_Fin_Proc_Eval_Sum';
l_certification_id number;


l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

  SAVEPOINT Populate_All_Fin_Proc_Eval_Sum;
    fnd_file.put_line(fnd_file.LOG, 'start populate_all_fin_proc_eval_sum:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    fnd_file.put_line(fnd_file.LOG, 'p_certification_id = :' || p_certification_id);

        -- Initialize API return status to SUCCESS
        l_return_status := FND_API.G_RET_STS_SUCCESS;

    l_certification_id := p_certification_id;

IF p_certification_id IS NOT NULL THEN

-- AMW_FINSTMT_CERT_BES_PKG.reset_amw_fin_cert_eval_sum(p_certification_id => l_certification_id) ;
--AMW_FINSTMT_CERT_BES_PKG.reset_amw_fin_proc_eval_sum(p_certification_id => l_certification_id);
--AMW_FINSTMT_CERT_BES_PKG.reset_amw_fin_org_eval_sum(p_certification_id => l_certification_id);
--AMW_FINSTMT_CERT_BES_PKG.reset_amw_cert_dashboard_sum(p_certification_id => l_certification_id);
--AMW_FINSTMT_CERT_BES_PKG.reset_fin_all(p_certification_id => l_certification_id);
amw_fin_coso_views_pvt.DELETE_ROWS(x_fin_certification_id => l_certification_id);

AMW_FINSTMT_CERT_BES_PKG.Master_Fin_Proc_Eval_Sum
   (p_certification_id => l_certification_id,
     x_return_status    => l_return_status,
     x_msg_count   => l_msg_count,
    x_msg_data    => l_msg_data);


ELSE
        FOR cert_rec IN c_cert LOOP
        	exit when c_cert%notfound;
--AMW_FINSTMT_CERT_BES_PKG.reset_amw_fin_cert_eval_sum(p_certification_id => cert_rec.certification_id) ;
--AMW_FINSTMT_CERT_BES_PKG.reset_amw_fin_proc_eval_sum(p_certification_id => cert_rec.certification_id);
--AMW_FINSTMT_CERT_BES_PKG.reset_amw_fin_org_eval_sum(p_certification_id => cert_rec.certification_id);
--AMW_FINSTMT_CERT_BES_PKG.reset_amw_cert_dashboard_sum(p_certification_id => cert_rec.certification_id);
--AMW_FINSTMT_CERT_BES_PKG.reset_fin_all(p_certification_id => cert_rec.certification_id);
amw_fin_coso_views_pvt.DELETE_ROWS(x_fin_certification_id  => cert_rec.certification_id);

AMW_FINSTMT_CERT_BES_PKG.Master_Fin_Proc_Eval_Sum
   (p_certification_id =>  cert_rec.certification_id,
     x_return_status    => l_return_status,
     x_msg_count   => l_msg_count,
    x_msg_data    => l_msg_data);

         END LOOP;

        END IF;


   /***05.25.2006 npanandi: bug 5250100 test***/
   if(AMW_FINSTMT_CERT_BES_PKG.G_ORG_ERROR = 'Y')then
      retcode := '1'; /**2 = EXCEPTION, 1 = WARNING, 0 = SUCCESS**/
      errbuf := 'Check out the Organizations';
   end if;
   /***05.25.2006 npanandi: bug 5250100 test ends***/


   EXCEPTION
   WHEN NO_DATA_FOUND THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in AMW_FINSTMT_CERT_PVT.Populate_All_Fin_Process_Eval_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
   WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in AMW_FINSTMT_CERT_PVT.Populate_All_Fin_Proc_Eval_Sum'
              || SUBSTR (SQLERRM, 1, 100), 1, 200));
        	ROLLBACK TO Populate_All_Fin_Proc_Eval_Sum;
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  l_msg_count,
                p_data    =>  l_msg_data);

                  errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
        	 retcode := FND_API.G_RET_STS_UNEXP_ERROR;

END Populate_All_Fin_Proc_Eval_Sum;


/********* USED IN THE CONCURRENT PROGRAM BEFORE BUSSINESS EVENT   ******************
PROCEDURE Populate_All_Fin_Proc_Eval_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
)
IS

    CURSOR c_cert IS
        SELECT 	cert.certification_id, period.start_date,period.end_date
        FROM 	AMW_CERTIFICATION_B cert,
		AMW_GL_PERIODS_V period
        WHERE 	cert.certification_period_name = period.period_name
        AND 	cert.certification_period_set_name = period.period_set_name
        AND     cert.object_type='FIN_STMT'
        AND     cert.certification_status in ('ACTIVE','DRAFT');

    CURSOR c_period_dates IS
        SELECT 	period.start_date,period.end_date
        FROM 	AMW_CERTIFICATION_B cert,
		AMW_GL_PERIODS_V period
        WHERE 	cert.certification_period_name = period.period_name
        AND 	cert.certification_period_set_name = period.period_set_name
        AND 	cert.certification_id = p_certification_id;

    -- select all the processes based on the certification_id
    CURSOR c_process(p_cert_id NUMBER) IS
        SELECT 	distinct aa.pk1 process_organization_id,po.process_id,po.organization_id
        FROM   	AMW_ACCT_ASSOCIATIONS aa,
               	AMW_FIN_ITEMS_KEY_ACC fika,
	      	AMW_PROCESS_ORGANIZATION po,
		AMW_CERTIFICATION_B cert
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     aa.pk1 = po.process_organization_id
        AND    	aa.natural_account_id in

--		(select acc.natural_account_id
--                           from AMW_FIN_KEY_ACCOUNTS_B acc
--                         START WITH acc.natural_account_id = fika.natural_account_id
--                            and acc.account_group_id = fika.account_group_id
--                         CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                                and PRIOR acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
	  	  where acc.natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		)

        AND    	fika.statement_group_id =  cert.statement_group_id
	AND     fika.financial_statement_id = cert.financial_statement_id
	AND     cert.certification_id = p_cert_id;

    --Select all the child processes .
    CURSOR c_child_processes(p_proc_id NUMBER, p_org_id NUMBER) IS
        SELECT  distinct child_process_id
        FROM    AMW_PROCESS_ORG_RELATIONS
        START WITH parent_process_id = p_proc_id
               AND organization_id = p_org_id
        CONNECT BY PRIOR child_process_id = parent_process_id
               AND PRIOR organization_id = organization_id;

    -- org process certified
    CURSOR org_processes_certified(p_cert_id NUMBER,p_process_id NUMBER) IS
        SELECT  count(distinct aov.pk3_value)
        FROM    AMW_OPINIONS_V aov
        WHERE   aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'CERTIFICATION'
        AND     aov.pk3_value <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
        AND     aov.pk1_value = p_process_id
	AND     aov.pk3_value in (select distinct evalsum.organization_id
                                from amw_fin_process_eval_sum evalsum
                                where evalsum.fin_certification_id = p_cert_id
				  and evalsum.process_id=p_process_id)
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_cert_id);

    CURSOR total_org_processes(p_cert_id NUMBER,p_process_id NUMBER) IS
        select count(distinct evalsum.organization_id)
        from   amw_fin_process_eval_sum evalsum
        where  evalsum.fin_certification_id = p_cert_id
	and    evalsum.process_id=p_process_id
        and    evalsum.organization_id <>
		NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999);

    --Begin variant process

    CURSOR var_procs(p_cert_id NUMBER) IS
        SELECT  fin_certification_id,organization_id,process_id
        FROM    AMW_FIN_PROCESS_EVAL_SUM
        WHERE   fin_certification_id = p_cert_id
        AND     organization_id = NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999);

    CURSOR org_var_processes_certified(p_cert_id NUMBER,p_start_date DATE,p_end_date DATE,p_process_id NUMBER) IS
        select count(1) from
          (SELECT  distinct aov.pk3_value,aov.pk1_value
           FROM    AMW_OPINIONS_V aov
           WHERE   aov.object_name = 'AMW_ORG_PROCESS'
           AND     aov.opinion_type_code = 'CERTIFICATION'
           --AND     aov.pk3_value <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
           --AND     aov.authored_date >= p_start_date
           --AND     aov.authored_date <= p_end_date
	   AND     aov.pk2_value in (
			select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           		where fin_stmt_cert_id = p_cert_id)
           AND     aov.pk1_value in (SELECT  varproc.process_id
                                     FROM    AMW_PROCESS varproc
                                     WHERE   varproc.standard_variation = p_process_id
                                     AND     varproc.standard_process_flag = 'N'
                                     AND     varproc.process_id in (select distinct evalsum.process_id
                                                                    from amw_fin_process_eval_sum evalsum
                                                                    where evalsum.fin_certification_id = p_cert_id)));


    CURSOR total_org_var_processes(p_cert_id NUMBER,p_process_id NUMBER) IS
        select count(1) from
          (select distinct evalsum.organization_id,evalsum.process_id
           from amw_fin_process_eval_sum evalsum
           where evalsum.fin_certification_id = p_cert_id
           and   evalsum.process_id in (select varproc.process_id
                                        FROM    AMW_PROCESS varproc
                                        WHERE   varproc.standard_variation = p_process_id
                                        AND     varproc.standard_process_flag = 'N'));
    -- end variant process

    l_start_date DATE;
    l_end_date   DATE;
    l_org_var_processes_certified NUMBER;
    l_org_processes_certified NUMBER;
    l_total_org_var_processes     NUMBER;
    l_total_org_processes     NUMBER;

BEGIN
    fnd_file.put_line (fnd_file.LOG, 'Certification_Id:'||p_certification_id);

    IF p_certification_id IS NOT NULL THEN

        DELETE from AMW_FIN_PROCESS_EVAL_SUM
        WHERE  fin_certification_id = p_certification_id;

        OPEN c_period_dates;
        FETCH c_period_dates INTO l_start_date,l_end_date;
        CLOSE  c_period_dates;

        FOR process_rec IN c_process(p_certification_id) LOOP
          Populate_Fin_Process_Eval_Sum(p_certification_id,l_start_date,l_end_date,process_rec.process_organization_id,
                                        process_rec.process_id,process_rec.organization_id,'Y');
          --Populate data for child processes
	  FOR child_rec IN c_child_processes(process_rec.process_id,process_rec.organization_id) LOOP
            Populate_Fin_Process_Eval_Sum(p_certification_id,l_start_date,l_end_date,process_rec.process_organization_id,
                                          child_rec.child_process_id,process_rec.organization_id,'N');
          END LOOP;
        END LOOP;

        -- Handle varient processes
        FOR var_rec IN var_procs(p_certification_id) LOOP

          OPEN org_var_processes_certified(var_rec.fin_certification_id,l_start_date,l_end_date,var_rec.process_id);
          FETCH org_var_processes_certified INTO l_org_var_processes_certified;
          CLOSE org_var_processes_certified;

          OPEN org_processes_certified(var_rec.fin_certification_id,var_rec.process_id);
          FETCH org_processes_certified INTO l_org_processes_certified;
          CLOSE org_processes_certified;

          l_org_processes_certified := l_org_processes_certified+
					l_org_var_processes_certified;

          OPEN total_org_var_processes(var_rec.fin_certification_id,var_rec.process_id);
          FETCH total_org_var_processes INTO l_total_org_var_processes;
          CLOSE total_org_var_processes;

          OPEN total_org_processes(var_rec.fin_certification_id,var_rec.process_id);
          FETCH total_org_processes INTO l_total_org_processes;
          CLOSE total_org_processes;

          l_total_org_processes := l_total_org_processes+
				    l_total_org_var_processes;

          UPDATE AMW_FIN_PROCESS_EVAL_SUM
          SET TOTAL_NUMBER_OF_ORG_PROCS = l_total_org_processes,
              NUMBER_OF_ORG_PROCS_CERTIFIED = l_org_processes_certified,
              ORG_PROCS_CERTIFIED_PRCNT =
	     round(((l_org_processes_certified/decode(l_total_org_processes,0,1,l_total_org_processes)) *100),0)
          WHERE FIN_CERTIFICATION_ID = var_rec.fin_certification_id
          AND   ORGANIZATION_ID = var_rec.organization_id
          AND   PROCESS_ID = var_rec.process_id;

        END LOOP;


        COMMIT;
    ELSE
        FOR cert_rec IN c_cert LOOP

            DELETE from AMW_FIN_PROCESS_EVAL_SUM
            WHERE  fin_certification_id = cert_rec.certification_id;

            FOR process_rec IN c_process(cert_rec.certification_id) LOOP
              Populate_Fin_Process_Eval_Sum(cert_rec.certification_id,cert_rec.start_date,cert_rec.end_date,process_rec.process_organization_id,
                                            process_rec.process_id,process_rec.organization_id,'Y');
              --Populate data for child processes
	      FOR child_rec IN c_child_processes(process_rec.process_id,process_rec.organization_id) LOOP
                Populate_Fin_Process_Eval_Sum(cert_rec.certification_id,cert_rec.start_date,cert_rec.end_date,process_rec.process_organization_id,
                                              child_rec.child_process_id,process_rec.organization_id,'N');
              END LOOP;
            END LOOP;

            -- Handle varient processes
            FOR var_rec IN var_procs(cert_rec.certification_id) LOOP

              OPEN org_var_processes_certified(var_rec.fin_certification_id,l_start_date,l_end_date,var_rec.process_id);
              FETCH org_var_processes_certified INTO l_org_var_processes_certified;
              CLOSE org_var_processes_certified;

	      OPEN org_processes_certified(var_rec.fin_certification_id,var_rec.process_id);
              FETCH org_processes_certified INTO l_org_processes_certified;
              CLOSE org_processes_certified;
              l_org_processes_certified := l_org_processes_certified+
					l_org_var_processes_certified;

              OPEN total_org_var_processes(var_rec.fin_certification_id,var_rec.process_id);
              FETCH total_org_var_processes INTO l_total_org_var_processes;
              CLOSE total_org_var_processes;

              OPEN total_org_processes(var_rec.fin_certification_id,var_rec.process_id);
              FETCH total_org_processes INTO l_total_org_processes;
              CLOSE total_org_processes;
	      l_total_org_processes := l_total_org_processes+
				    l_total_org_var_processes;

              UPDATE AMW_FIN_PROCESS_EVAL_SUM
              SET TOTAL_NUMBER_OF_ORG_PROCS = l_total_org_processes,
                NUMBER_OF_ORG_PROCS_CERTIFIED = l_org_processes_certified,
                ORG_PROCS_CERTIFIED_PRCNT =
		   round(((l_org_processes_certified/decode(l_total_org_processes,0,1,l_total_org_processes)) *100),0)
              WHERE FIN_CERTIFICATION_ID = var_rec.fin_certification_id
              AND   ORGANIZATION_ID = var_rec.organization_id
              AND   PROCESS_ID = var_rec.process_id;

            END LOOP;

            COMMIT;
        END LOOP;
    END IF;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_All_Fin_Process_Eval_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
     WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_All_Fin_Process_Eval_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
         retcode := FND_API.G_RET_STS_UNEXP_ERROR;
END Populate_All_Fin_Proc_Eval_Sum;

***********************************************************************/


/********implementation before bussiness event takes place since amw.d  ************/
PROCEDURE  Populate_Fin_Org_Eval_Sum(
    p_certification_id          IN      NUMBER,
    p_start_date                IN      DATE,
    p_end_date			IN      DATE,
    p_organization_id		IN 	NUMBER
)
IS
    CURSOR last_evaluation IS
        SELECT 	aov.opinion_id
	FROM 	AMW_OPINIONS_V aov
       	WHERE 	aov.object_name = 'AMW_ORGANIZATION'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk1_value = p_organization_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS_V aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk1_value = aov.pk1_value);

/*
    CURSOR proc_pending_cert IS
        SELECT count(distinct apo.process_id)
        FROM   AMW_ACCT_ASSOCIATIONS aa,
               AMW_FIN_ITEMS_KEY_ACC fika,
	       AMW_CERTIFICATION_B cert,
	       AMW_PROCESS_ORGANIZATION apo,
	       AMW_PROCESS_ORGANIZATION apo2
        WHERE  aa.object_type = 'PROCESS_ORG'
	AND    apo2.process_organization_id = aa.pk1
        AND    (apo.process_id, apo.organization_id) in
			(select child_process_id, organization_id
			   from Amw_Process_Org_Relations
			 start with child_process_id = apo2.process_id
			        and organization_id = apo2.organization_Id
			 CONNECT BY PRIOR child_process_id = parent_process_id
				and PRIOR organization_id = organization_id)
	AND    aa.natural_account_id in

--		        (select acc.natural_account_id
--                           from AMW_FIN_KEY_ACCOUNTS_B acc
--                         START WITH acc.natural_account_id = fika.natural_account_id
--                            and acc.account_group_id = fika.account_group_id
--                         CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                                and PRIOR acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
	  	  where acc.natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		)
        AND    fika.statement_group_id =  cert.statement_group_id
	AND    fika.financial_statement_id = cert.financial_statement_id
	AND    cert.certification_id = p_certification_id
	AND    apo.organization_id = p_organization_id
        AND    not exists (SELECT 'Y'
                             FROM AMW_OPINIONS_V aov
                            WHERE aov.object_name = 'AMW_ORG_PROCESS'
                              AND aov.opinion_type_code = 'CERTIFICATION'
                              AND aov.pk3_value = p_organization_id
                              AND aov.pk1_value = apo.process_id
			      AND aov.authored_date >= p_start_date
			      AND aov.authored_date <= p_end_date);
*/
    CURSOR total_num_of_proc IS
	SELECT	count(distinct hier.parent_child_id)
       	FROM	AMW_ACCT_ASSOCIATIONS aa,
	      	AMW_PROCESS_ORGANIZATION po,
	       (select process_id, organization_id, parent_child_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm hier
			 union select process_id, organization_id, process_id, 'D'
			 from amw_process_organization) hier
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     po.process_organization_id = aa.pk1
        AND     hier.organization_id = po.organization_id
        AND     hier.process_id = po.process_id
        AND     hier.up_down_ind = 'D'
	AND     aa.natural_account_id in

--		   (select acc.natural_account_id
--                      from AMW_FIN_KEY_ACCOUNTS_B acc
--                    START WITH ((acc.natural_account_id, acc.account_group_id) in
--                       	(select fika.natural_account_id, fika.account_group_id
--                       	 from AMW_FIN_ITEMS_KEY_ACC fika,
--			      AMW_CERTIFICATION_B cert
--			 where fika.statement_group_id =  cert.statement_group_id
--			 AND   fika.financial_statement_id = cert.financial_statement_id
--			 AND   cert.certification_id = p_certification_id))
--                    CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                           and PRIOR acc.account_group_id = acc.account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				)

        AND	po.organization_id = p_organization_id;


    CURSOR proc_with_issue IS
	SELECT	count(distinct hier.parent_child_id)
       	FROM	AMW_ACCT_ASSOCIATIONS aa,
	      	AMW_PROCESS_ORGANIZATION po,
	       (select process_id, organization_id, parent_child_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm hier
			 union select process_id, organization_id, process_id, 'D'
			 from amw_process_organization) hier,
	        AMW_OPINIONS_V aov
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     po.process_organization_id = aa.pk1
        AND     hier.organization_id = po.organization_id
        AND     hier.process_id = po.process_id
        AND     hier.up_down_ind = 'D'
	AND     aa.natural_account_id in

--		    (select acc.natural_account_id
--                        from AMW_FIN_KEY_ACCOUNTS_B acc
--                     START WITH ((acc.natural_account_id, acc.account_group_id) in
--                       	(select fika.natural_account_id, fika.account_group_id
--                       	 from AMW_FIN_ITEMS_KEY_ACC fika,
--			      AMW_CERTIFICATION_B cert
--			 where fika.statement_group_id =  cert.statement_group_id
--			 AND   fika.financial_statement_id = cert.financial_statement_id
--			 AND   cert.certification_id = p_certification_id))
--                     CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                            and PRIOR acc.account_group_id = acc.account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				)

        AND	po.organization_id = p_organization_id
        AND     aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'CERTIFICATION'
        AND     aov.pk3_value = p_organization_id
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id)
        AND     aov.pk1_value = hier.parent_child_id
	AND     aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS_V aov2
                               	     where aov2.object_opinion_type_id
					   = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
				     AND aov2.pk2_value in
					(select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			w	 where fin_stmt_cert_id = p_certification_id)
                                     and aov2.pk1_value = aov.pk1_value)
        AND     aov.audit_result_code <> 'EFFECTIVE';


    CURSOR proc_without_issue IS
	SELECT	count(distinct hier.parent_child_id)
       	FROM	AMW_ACCT_ASSOCIATIONS aa,
	      	AMW_PROCESS_ORGANIZATION po,
	       (select process_id, organization_id, parent_child_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm hier
			 union select process_id, organization_id, process_id, 'D'
			 from amw_process_organization) hier,
	        AMW_OPINIONS_V aov
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     po.process_organization_id = aa.pk1
        AND     hier.organization_id = po.organization_id
        AND     hier.process_id = po.process_id
        AND     hier.up_down_ind = 'D'
	AND     aa.natural_account_id in

--		    (select acc.natural_account_id
--                        from AMW_FIN_KEY_ACCOUNTS_B acc
--                     START WITH ((acc.natural_account_id, acc.account_group_id) in
--                       	(select fika.natural_account_id, fika.account_group_id
--                       	 from AMW_FIN_ITEMS_KEY_ACC fika,
--			      AMW_CERTIFICATION_B cert
--			 where fika.statement_group_id =  cert.statement_group_id
--			 AND   fika.financial_statement_id = cert.financial_statement_id
--			 AND   cert.certification_id = p_certification_id))
--                     CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                            and PRIOR acc.account_group_id = acc.account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				)

        AND	po.organization_id = p_organization_id
        AND     aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'CERTIFICATION'
        AND     aov.pk3_value = p_organization_id
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id)
        AND     aov.pk1_value = hier.parent_child_id
	AND     aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS_V aov2
                               	     where aov2.object_opinion_type_id
					   = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
				     AND aov2.pk2_value in
					(select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			w	 where fin_stmt_cert_id = p_certification_id)
                                     and aov2.pk1_value = aov.pk1_value)
        AND     aov.audit_result_code = 'EFFECTIVE';

    CURSOR proc_with_ineff_ctrl IS
	SELECT	count(distinct hier.parent_child_id)
       	FROM	AMW_ACCT_ASSOCIATIONS aa,
	      	AMW_PROCESS_ORGANIZATION po,
	       (select process_id, organization_id, parent_child_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm hier
			 union select process_id, organization_id, process_id, 'D'
			 from amw_process_organization) hier,
                AMW_OPINIONS_V aov
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     po.process_organization_id = aa.pk1
        AND     hier.organization_id = po.organization_id
        AND     hier.process_id = po.process_id
        AND     hier.up_down_ind = 'D'
	AND     aa.natural_account_id in

--		   (select acc.natural_account_id
--                      from AMW_FIN_KEY_ACCOUNTS_B acc
--                    START WITH ((acc.natural_account_id, acc.account_group_id) in
--                       	(select fika.natural_account_id, fika.account_group_id
--                       	 from AMW_FIN_ITEMS_KEY_ACC fika,
--			      AMW_CERTIFICATION_B cert
--			 where fika.statement_group_id =  cert.statement_group_id
--			 AND   fika.financial_statement_id = cert.financial_statement_id
--			 AND   cert.certification_id = p_certification_id))
--                    CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                           and PRIOR acc.account_group_id = acc.account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				)

        AND	po.organization_id = p_organization_id
        AND     aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'EVALUATION'
        AND     aov.pk3_value = hier.organization_id
        AND     aov.pk1_value = hier.parent_child_id
        AND     aov.authored_date =
		      (select max(aov2.authored_date)
		       from   AMW_OPINIONS_V aov2
		       where aov2.object_opinion_type_id = aov.object_opinion_type_id
			 and aov2.pk3_value = aov.pk3_value
                         and aov2.pk1_value = aov.pk1_value)
           AND aov.audit_result_code <> 'EFFECTIVE';

    CURSOR unmitigated_risks IS
        SELECT 	count(distinct ara.risk_association_id)
       	FROM	AMW_ACCT_ASSOCIATIONS aa,
	      	AMW_PROCESS_ORGANIZATION po,
	       (select process_id, organization_id, parent_child_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm hier
			 union select process_id, organization_id, process_id, 'D'
			 from amw_process_organization) hier,
		AMW_PROCESS_ORGANIZATION po2,
       		AMW_RISK_ASSOCIATIONS ara,
                AMW_OPINIONS_V aov
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     po.process_organization_id = aa.pk1
        AND     hier.organization_id = po.organization_id
        AND     hier.process_id = po.process_id
        AND     hier.up_down_ind = 'D'
	AND     aa.natural_account_id in

--		   (select acc.natural_account_id
--                      from AMW_FIN_KEY_ACCOUNTS_B acc
--                    START WITH ((acc.natural_account_id, acc.account_group_id) in
--                       	(select fika.natural_account_id, fika.account_group_id
--                       	 from AMW_FIN_ITEMS_KEY_ACC fika,
--			      AMW_CERTIFICATION_B cert
--			 where fika.statement_group_id =  cert.statement_group_id
--			 AND   fika.financial_statement_id = cert.financial_statement_id
--			 AND   cert.certification_id = p_certification_id))
--                    CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                           and PRIOR acc.account_group_id = acc.account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				)

        AND	po.organization_id = p_organization_id
        AND     po2.process_id = hier.parent_child_id
	AND     po2.organization_id = hier.organization_id
        AND 	ara.object_type = 'PROCESS_ORG'
        AND 	ara.pk1 = po2.process_organization_id
        AND 	aov.object_name = 'AMW_ORG_PROCESS_RISK'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk3_value = po2.organization_id
        AND 	aov.pk4_value = po2.process_id
        AND 	aov.pk1_value = ara.risk_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS_V aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk4_value = aov.pk4_value
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value)
      	AND 	aov.audit_result_code <> 'EFFECTIVE';

    CURSOR total_risks IS
        SELECT 	count(distinct ara.risk_association_id)
       	FROM	AMW_ACCT_ASSOCIATIONS aa,
	      	AMW_PROCESS_ORGANIZATION po,
	       (select process_id, organization_id, parent_child_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm hier
			 union select process_id, organization_id, process_id, 'D'
			 from amw_process_organization) hier,
		AMW_PROCESS_ORGANIZATION po2,
       		AMW_RISK_ASSOCIATIONS ara
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     po.process_organization_id = aa.pk1
        AND     hier.organization_id = po.organization_id
        AND     hier.process_id = po.process_id
        AND     hier.up_down_ind = 'D'
	AND     aa.natural_account_id in
--		   (select acc.natural_account_id
--                      from AMW_FIN_KEY_ACCOUNTS_B acc
--                    START WITH ((acc.natural_account_id, acc.account_group_id) in
--                       	(select fika.natural_account_id, fika.account_group_id
--                       	 from AMW_FIN_ITEMS_KEY_ACC fika,
--			      AMW_CERTIFICATION_B cert
--			 where fika.statement_group_id =  cert.statement_group_id
--			 AND   fika.financial_statement_id = cert.financial_statement_id
--			 AND   cert.certification_id = p_certification_id))
--                    CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                           and PRIOR acc.account_group_id = acc.account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				)

        AND	po.organization_id = p_organization_id
        AND     po2.process_id = hier.parent_child_id
	AND     po2.organization_id = hier.organization_id
        AND 	ara.object_type = 'PROCESS_ORG'
        AND 	ara.pk1 = po2.process_organization_id;


    CURSOR ineffective_controls IS
        SELECT 	count(distinct aca.control_id)
       	FROM	AMW_ACCT_ASSOCIATIONS aa,
	      	AMW_PROCESS_ORGANIZATION po,
	       (select process_id, organization_id, parent_child_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm hier
			 union select process_id, organization_id, process_id, 'D'
			 from amw_process_organization) hier,
		AMW_PROCESS_ORGANIZATION po2,
       		AMW_RISK_ASSOCIATIONS ara,
		AMW_CONTROL_ASSOCIATIONS aca ,
                AMW_OPINIONS_V aov
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     po.process_organization_id = aa.pk1
        AND     hier.organization_id = po.organization_id
        AND     hier.process_id = po.process_id
        AND     hier.up_down_ind = 'D'
	AND     aa.natural_account_id in

--		   (select acc.natural_account_id
--                      from AMW_FIN_KEY_ACCOUNTS_B acc
--                    START WITH ((acc.natural_account_id, acc.account_group_id) in
--                       	(select fika.natural_account_id, fika.account_group_id
--                       	 from AMW_FIN_ITEMS_KEY_ACC fika,
--			      AMW_CERTIFICATION_B cert
--			 where fika.statement_group_id =  cert.statement_group_id
--			 AND   fika.financial_statement_id = cert.financial_statement_id
--			 AND   cert.certification_id = p_certification_id))
--                    CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                           and PRIOR acc.account_group_id = acc.account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				)

        AND	po.organization_id = p_organization_id
        AND     po2.process_id = hier.parent_child_id
	AND     po2.organization_id = hier.organization_id
        AND 	ara.object_type = 'PROCESS_ORG'
        AND 	ara.pk1 = po2.process_organization_id
        AND 	aca.object_type = 'RISK_ORG'
        AND 	aca.pk1 = ara.risk_association_id
        AND 	aov.object_name = 'AMW_ORG_CONTROL'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk3_value = po2.organization_id
        AND 	aov.pk1_value = aca.control_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS_V aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value)
        AND 	aov.audit_result_code <> 'EFFECTIVE';


    CURSOR total_controls IS
        SELECT 	count(distinct aca.control_id)
       	FROM	AMW_ACCT_ASSOCIATIONS aa,
	      	AMW_PROCESS_ORGANIZATION po,
	       (select process_id, organization_id, parent_child_id, up_down_ind
			 from Amw_Org_Hierarchy_Denorm hier
			 union select process_id, organization_id, process_id, 'D'
			 from amw_process_organization) hier,
		AMW_PROCESS_ORGANIZATION po2,
       		AMW_RISK_ASSOCIATIONS ara,
		AMW_CONTROL_ASSOCIATIONS aca
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     po.process_organization_id = aa.pk1
        AND     hier.organization_id = po.organization_id
        AND     hier.process_id = po.process_id
        AND     hier.up_down_ind = 'D'
	AND     aa.natural_account_id in
--		   (select acc.natural_account_id
--                      from AMW_FIN_KEY_ACCOUNTS_B acc
--                    START WITH ((acc.natural_account_id, acc.account_group_id) in
--                       	(select fika.natural_account_id, fika.account_group_id
--                       	 from AMW_FIN_ITEMS_KEY_ACC fika,
--			      AMW_CERTIFICATION_B cert
--			 where fika.statement_group_id =  cert.statement_group_id
--			 AND   fika.financial_statement_id = cert.financial_statement_id
--			 AND   cert.certification_id = p_certification_id))
--                    CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                           and PRIOR acc.account_group_id = acc.account_group_id)

				( select distinct acc.child_natural_account_id
				  from amw_fin_key_acct_flat acc
				  where ( acc.parent_natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				  union
				  select distinct acc.natural_account_id
				  from amw_fin_key_accounts_b acc
				  where ( acc.natural_account_id, acc.account_group_id ) in
					( select natural_account_id, account_group_id
					  from amw_certification_b cert, AMW_FIN_ITEMS_KEY_ACC fika
					  where cert.certification_id = p_certification_id
                           		  and cert.statement_group_id = fika.statement_group_id
                          		  and cert.financial_statement_id = fika.FINANCIAL_STATEMENT_ID
					)
				)

        AND	po.organization_id = p_organization_id
        AND     po2.process_id = hier.parent_child_id
	AND     po2.organization_id = hier.organization_id
        AND 	ara.object_type = 'PROCESS_ORG'
        AND 	ara.pk1 = po2.process_organization_id
        AND 	aca.object_type = 'RISK_ORG'
        AND 	aca.pk1 = ara.risk_association_id;

    CURSOR c_org IS
        SELECT  subsidiary_valueset, company_code, lob_valueset, lob_code
        FROM    amw_audit_units_v
        WHERE   organization_id = p_organization_id;

    l_eval_opinion_id		NUMBER;
    l_proc_pending_cert		NUMBER;
    l_total_num_of_procs	NUMBER;
    l_proc_with_issue		NUMBER;
    l_proc_without_issue	NUMBER;
    l_proc_certified		NUMBER;
    l_proc_with_ineff_ctrl	NUMBER;
    l_unmitigated_risks		NUMBER;
    l_risks			NUMBER;
    l_ineff_controls		NUMBER;
    l_controls			NUMBER;
    l_open_findings		NUMBER;
    l_sub_vs			VARCHAR2(150);
    l_lob_vs			VARCHAR2(150);
    l_sub_code			VARCHAR2(150);
    l_lob_code			VARCHAR2(150);
BEGIN

    fnd_file.put_line (fnd_file.LOG, 'p_certification_id='||to_char(p_certification_id));
    fnd_file.put_line(fnd_file.LOG, 'p_organization_id='||to_char(p_organization_id));
    fnd_file.put_line(fnd_file.LOG, 'before last_evaludation:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN last_evaluation;
    FETCH last_evaluation INTO l_eval_opinion_id;
    CLOSE last_evaluation;
    fnd_file.put_line(fnd_file.LOG, 'after last_evaludation:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

/*
    OPEN proc_pending_cert;
    FETCH proc_pending_cert INTO l_proc_pending_cert;
    CLOSE proc_pending_cert;
    fnd_file.put_line(fnd_file.LOG, 'after proc_pending_cert:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
*/

    OPEN total_num_of_proc;
    FETCH total_num_of_proc INTO l_total_num_of_procs;
    CLOSE total_num_of_proc;
    fnd_file.put_line(fnd_file.LOG, 'after total_num_of_proc:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN proc_with_issue;
    FETCH proc_with_issue INTO l_proc_with_issue;
    CLOSE proc_with_issue;
    fnd_file.put_line(fnd_file.LOG, 'after proc_with_issue:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN proc_without_issue;
    FETCH proc_without_issue INTO l_proc_without_issue;
    CLOSE proc_without_issue;
    fnd_file.put_line(fnd_file.LOG, 'after proc_without_issue:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    l_proc_certified := l_proc_with_issue+l_proc_without_issue;
    l_proc_pending_cert := l_total_num_of_procs-l_proc_certified;

    OPEN proc_with_ineff_ctrl;
    FETCH proc_with_ineff_ctrl INTO l_proc_with_ineff_ctrl;
    CLOSE proc_with_ineff_ctrl;
    fnd_file.put_line(fnd_file.LOG, 'after proc_with_ineff_ctrl:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN unmitigated_risks;
    FETCH unmitigated_risks INTO l_unmitigated_risks;
    CLOSE unmitigated_risks;
    fnd_file.put_line(fnd_file.LOG, 'after unmitigated:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN total_risks;
    FETCH total_risks INTO l_risks;
    CLOSE total_risks;
    fnd_file.put_line(fnd_file.LOG, 'after total_risks:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN ineffective_controls;
    FETCH ineffective_controls INTO l_ineff_controls;
    CLOSE ineffective_controls;
    fnd_file.put_line(fnd_file.LOG, 'after ineffective_controls:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN total_controls;
    FETCH total_controls INTO l_controls;
    CLOSE total_controls;
    fnd_file.put_line(fnd_file.LOG, 'after total_controls:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN c_org;
    FETCH c_org INTO l_sub_vs, l_sub_code, l_lob_vs, l_lob_code;
    CLOSE c_org;
    fnd_file.put_line(fnd_file.LOG, 'after c_org:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    BEGIN
        l_open_findings := amw_findings_pkg.calculate_open_findings (
               'AMW_PROJ_FINDING',
	       'PROJ_ORG', p_organization_id,
	       null, null,
	       null, null,
	       null, null,
	       null, null );
    EXCEPTION
        WHEN OTHERS THEN
            null;
    END;
    fnd_file.put_line(fnd_file.LOG, 'after open_findings:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    UPDATE  AMW_FIN_ORG_EVAL_SUM
       SET EVAL_OPINION_ID = l_eval_opinion_id,
           PROC_PENDING_CERTIFICATION = l_proc_pending_cert,
	   TOTAL_NUMBER_OF_PROCS = l_total_num_of_procs,
	   PROC_CERTIFIED_WITH_ISSUES = l_proc_with_issue,
	   PROC_VERIFIED = l_proc_certified,
	   PROC_WITH_INEFFECTIVE_CONTROLS = l_proc_with_ineff_ctrl,
	   UNMITIGATED_RISKS = l_unmitigated_risks,
	   RISKS_VERIFIED = l_risks,
	   INEFFECTIVE_CONTROLS	= l_ineff_controls,
	   CONTROLS_VERIFIED = l_controls,
	   PROC_PENDING_CERT_PRCNT =
	      round(l_proc_pending_cert/decode(l_total_num_of_procs, 0,1,l_total_num_of_procs),2)*100,
	   PROCESSES_WITH_ISSUES_PRCNT =
              round(l_proc_with_issue/decode(l_total_num_of_procs, 0,1,l_total_num_of_procs),2)*100,
	   PROC_WITH_INEFF_CONTROLS_PRCNT =
	      round(l_proc_with_ineff_ctrl/decode(l_total_num_of_procs, 0,1,l_total_num_of_procs),2)*100,
	   UNMITIGATED_RISKS_PRCNT = round(l_unmitigated_risks/decode(l_risks,0,1,l_risks), 2)*100,
	   INEFFECTIVE_CONTROLS_PRCNT = round(l_ineff_controls/decode(l_controls,0,1,l_controls), 2)*100,
	   OPEN_FINDINGS = l_open_findings,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID,
	   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
	   SUBSIDIARY_VS = l_sub_vs,
	   SUBSIDIARY_CODE = l_sub_code,
	   LOB_VS = l_lob_vs,
	   LOB_CODE = l_lob_code
     WHERE fin_certification_id = p_certification_id
     AND   organization_id = p_organization_id;



    IF (SQL%NOTFOUND) THEN
       INSERT INTO AMW_FIN_ORG_EVAL_SUM(
	      FIN_CERTIFICATION_ID,
	      ORGANIZATION_ID,
	      EVAL_OPINION_ID,
	      PROC_PENDING_CERTIFICATION,
	      TOTAL_NUMBER_OF_PROCS,
	      PROC_CERTIFIED_WITH_ISSUES,
	      PROC_VERIFIED,
	      PROC_WITH_INEFFECTIVE_CONTROLS,
	      UNMITIGATED_RISKS,
	      RISKS_VERIFIED,
	      INEFFECTIVE_CONTROLS,
	      CONTROLS_VERIFIED,
	      PROC_PENDING_CERT_PRCNT,
	      PROCESSES_WITH_ISSUES_PRCNT,
	      PROC_WITH_INEFF_CONTROLS_PRCNT,
	      UNMITIGATED_RISKS_PRCNT,
	      INEFFECTIVE_CONTROLS_PRCNT,
	      OPEN_FINDINGS,
	      CREATED_BY,
	      CREATION_DATE,
	      LAST_UPDATED_BY,
	      LAST_UPDATE_DATE,
	      LAST_UPDATE_LOGIN,
	      OBJECT_VERSION_NUMBER,
	      SUBSIDIARY_VS,
	      SUBSIDIARY_CODE,
	      LOB_VS,
	      LOB_CODE)
       SELECT p_certification_id,
              p_organization_id,
	      l_eval_opinion_id,
	      l_proc_pending_cert,
	      l_total_num_of_procs,
	      l_proc_with_issue,
	      l_proc_certified,
	      l_proc_with_ineff_ctrl,
	      l_unmitigated_risks,
	      l_risks,
	      l_ineff_controls,
	      l_controls,
	      round(l_proc_pending_cert/decode(l_total_num_of_procs, 0,1,l_total_num_of_procs),2)*100,
	      round(l_proc_with_issue/decode(l_total_num_of_procs, 0,1,l_total_num_of_procs),2)*100,
	      round(l_proc_with_ineff_ctrl/decode(l_total_num_of_procs, 0,1,l_total_num_of_procs),2)*100,
	      round(l_unmitigated_risks/decode(l_risks,0,1,l_risks), 2)*100,
	      round(l_ineff_controls/decode(l_controls,0,1,l_controls), 2)*100,
	      l_open_findings,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
	      1,
	      l_sub_vs,
	      l_sub_code,
	      l_lob_vs,
	      l_lob_code
        FROM  DUAL;
    END IF;

    commit;
EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Fin_Org_Eval_Sum'
              || SUBSTR (SQLERRM, 1, 100), 1, 200));
END Populate_Fin_Org_Eval_Sum;



/*********************OBSOLATED. USED IN CONCURRENT PROGRAM BEFORE BES AMW.D ******************
PROCEDURE Populate_All_Fin_Org_Eval_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
)
IS

    CURSOR c_cert IS
        SELECT 	cert.certification_id, period.start_date, period.end_date
        FROM 	AMW_CERTIFICATION_B cert,
		AMW_GL_PERIODS_V period
        WHERE 	cert.certification_period_name = period.period_name
        AND 	cert.certification_period_set_name = period.period_set_name
        AND     cert.object_type='FIN_STMT'
        AND     cert.certification_status in ('ACTIVE','DRAFT');


    CURSOR c_period_date IS
        SELECT 	period.start_date, period.end_date
        FROM 	AMW_CERTIFICATION_B cert,
		AMW_GL_PERIODS_V period
        WHERE 	cert.certification_period_name = period.period_name
        AND 	cert.certification_period_set_name = period.period_set_name
        AND 	cert.certification_id = p_certification_id;

    -- select all the processes based on the certification_id
    CURSOR c_org(p_cert_id NUMBER) IS
        SELECT 	distinct po.organization_id
        FROM   	AMW_ACCT_ASSOCIATIONS aa,
               	AMW_FIN_ITEMS_KEY_ACC fika,
	      	AMW_PROCESS_ORGANIZATION po,
		AMW_CERTIFICATION_B cert
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     aa.pk1 = po.process_organization_id
	AND     aa.natural_account_id in

--		(select acc.natural_account_id
--                           from AMW_FIN_KEY_ACCOUNTS_B acc
--                         START WITH acc.natural_account_id = fika.natural_account_id
--                            and acc.account_group_id = fika.account_group_id
--                         CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                                and PRIOR acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		)

        AND    	fika.statement_group_id =  cert.statement_group_id
	AND     fika.financial_statement_id = cert.financial_statement_id
	AND     cert.certification_id = p_cert_id;

    l_start_date DATE;
    l_end_date DATE;

BEGIN
    fnd_file.put_line (fnd_file.LOG, 'Certification_Id:'||p_certification_id);

    IF p_certification_id IS NOT NULL THEN
        OPEN c_period_date;
        FETCH c_period_date INTO l_start_date, l_end_date;
        CLOSE c_period_date;

        DELETE from AMW_FIN_ORG_EVAL_SUM orgevalsum
	where FIN_CERTIFICATION_ID = p_certification_id
	  and not exists
		  (SELECT  'Y'
		     FROM  AMW_ACCT_ASSOCIATIONS aa,
			   AMW_FIN_ITEMS_KEY_ACC fika,
	      	           AMW_PROCESS_ORGANIZATION po,
		           AMW_CERTIFICATION_B cert
                    WHERE  aa.object_type = 'PROCESS_ORG'
	              AND  aa.pk1 = po.process_organization_id
                      AND  aa.natural_account_id in

--		(select acc.natural_account_id
--                           from AMW_FIN_KEY_ACCOUNTS_B acc
--                         START WITH acc.natural_account_id = fika.natural_account_id
--                            and acc.account_group_id = fika.account_group_id
--                         CONNECT BY PRIOR acc.natural_account_id = acc.parent_natural_account_id
--                                and PRIOR acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		)
                      AND  fika.statement_group_id =  cert.statement_group_id
	              AND  fika.financial_statement_id = cert.financial_statement_id
	              AND  cert.certification_id = p_certification_id
		      AND  po.organization_id = orgevalsum.organization_id);

        FOR org_rec IN c_org(p_certification_id) LOOP
          Populate_Fin_Org_Eval_Sum(p_certification_id, l_start_date,
				    l_end_date, org_rec.organization_id);
        END LOOP;
    ELSE
        DELETE from AMW_FIN_ORG_EVAL_SUM orgevalsum
	where not exists
		  (SELECT  'Y'
		     FROM  AMW_ACCT_ASSOCIATIONS aa,
			   AMW_FIN_ITEMS_KEY_ACC fika,
	      	           AMW_PROCESS_ORGANIZATION po,
		           AMW_CERTIFICATION_B cert
                    WHERE  aa.object_type = 'PROCESS_ORG'
	              AND  aa.pk1 = po.process_organization_id
                      AND  aa.natural_account_id = fika.natural_account_id
                      AND  fika.statement_group_id =  cert.statement_group_id
	              AND  fika.financial_statement_id = cert.financial_statement_id
                      AND  cert.certification_status in ('ACTIVE','DRAFT')
	              AND  cert.certification_id = orgevalsum.fin_certification_id
		      AND  po.organization_id = orgevalsum.organization_id);

        FOR cert_rec IN c_cert LOOP
            FOR org_rec IN c_org(cert_rec.certification_id) LOOP
              Populate_Fin_Org_Eval_Sum(cert_rec.certification_id,
			cert_rec.start_date, cert_rec.end_date, org_rec.organization_id);
            END LOOP;
        END LOOP;
    END IF;

EXCEPTION
     WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_All_Fin_Org_Eval_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
         retcode := FND_API.G_RET_STS_UNEXP_ERROR;
END Populate_All_Fin_Org_Eval_Sum;

********************************************/


/**************************************OBSOLATED. USED IN THE CONCURRENT PROGRAM BEFORE BES AMW.D *******/
/*****----------- Code Added  by Krishnan --------------------------------------------------------
PROCEDURE build_amw_fin_cert_eval_sum(errbuf OUT NOCOPY  VARCHAR2,retcode OUT NOCOPY VARCHAR2, P_CERTIFICATION_ID in number)
is
begin
  declare

   M_CERTIFICATION_ID NUMBER := 0;
   M_FINANCIAL_STATEMENT_ID NUMBER := 0;
   M_STATEMENT_GROUP_ID NUMBER := 0;
   M_OBJECT_TYPE varchar2(25) := null;
   param_cert_id number := P_CERTIFICATION_ID ;

   M_START_DATE DATE;
   M_END_DATE DATE;

 -- variables for totals
      M_PROC_PENDING_CERTIFICATION number :=0;
      M_TOTAL_NUMBER_OF_PROCESSES  number :=0;
      M_PROC_CERTIFIED_WITH_ISSUES number :=0;
      M_PROC_VERIFIED              number :=0;
      M_org_with_ineffective_ctrls  number :=0;
      M_org_certified              number :=0;
      M_proc_with_ineffective_ctrls  number :=0;
      M_unmitigated_risks          number :=0;
      M_risks_verified             number :=0;
      M_ineffective_controls       number :=0;
      M_controls_verified          number :=0;
      M_open_issues                number :=0;
      M_PRO_PENDING_CERT_PRCNT number :=0;
      M_PROCESSES_WITH_ISSUES_PRCNT number :=0;
      M_ORG_WITH_INEFF_CTRLS_PRCNT number :=0;
      M_PROC_WITH_INEFF_CTRLS_PRCNT number :=0;
      M_UNMITIGATED_RISKS_PRCNT number  :=0;
      M_INEFFECTIVE_CONTROLS_PRCNT number :=0;
      M_PROCS_FOR_CERT_DONE  number :=0;
      m_org_evaluated   number :=0;
      T_PROC_PENDING_CERTIFICATION number :=0;
      T_TOTAL_NUMBER_OF_PROCESSES  number :=0;
      T_PROC_CERTIFIED_WITH_ISSUES number :=0;
      T_PROC_VERIFIED              number :=0;
      T_org_with_ineffective_ctrls  number :=0;
      T_org_certified              number :=0;
      T_proc_with_ineffective_ctrls  number :=0;
      T_unmitigated_risks          number :=0;
      T_risks_verified             number :=0;
      T_ineffective_controls       number :=0;
      T_controls_verified          number :=0;
      T_open_issues                number :=0;
      T_PRO_PENDING_CERT_PRCNT number :=0;
      T_PROCESSES_WITH_ISSUES_PRCNT number :=0;
      T_ORG_WITH_INEFF_CTRLS_PRCNT number :=0;
      T_PROC_WITH_INEFF_CTRLS_PRCNT number :=0;
      T_UNMITIGATED_RISKS_PRCNT number  :=0;
      T_INEFFECTIVE_CONTROLS_PRCNT number :=0;




   cursor Get_Cert_for_processing
   is
   select
        certifcationVL.CERTIFICATION_ID ,
        certifcationVL.FINANCIAL_STATEMENT_ID,
        certifcationVL.STATEMENT_GROUP_ID
   FROM
        AMW_CERTIFICATION_vl certifcationVL
   where
        certifcationVL.OBJECT_TYPE='FIN_STMT'
    and certifcationVL.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT');

   cursor Get_Only_One_Cert
   is
   select
        certifcationVL.CERTIFICATION_ID ,
        certifcationVL.FINANCIAL_STATEMENT_ID,
        certifcationVL.STATEMENT_GROUP_ID
   FROM
        AMW_CERTIFICATION_vl certifcationVL
   where
        certifcationVL.OBJECT_TYPE='FIN_STMT'
   and certifcationVL.CERTIFICATION_ID = P_CERTIFICATION_ID;


   begin

    g_errbuf      := null;
    g_retcode     :=  '0';

    reset_amw_fin_cert_eval_sum(p_certification_id => param_cert_id ); -- reset all existing computed values to 0


    if P_CERTIFICATION_ID is null then
       for certifications in Get_Cert_for_processing
       loop

        exit when Get_Cert_for_processing%notfound;

        M_CERTIFICATION_ID := certifications.CERTIFICATION_ID ;
        M_FINANCIAL_STATEMENT_ID := certifications.FINANCIAL_STATEMENT_ID;
        M_STATEMENT_GROUP_ID := certifications.STATEMENT_GROUP_ID;
        M_OBJECT_TYPE := 'FINANCIAL STATEMENT';

        AMW_FINSTMT_CERT_PVT.GetGLPeriodfor_FinCertEvalSum(
                       P_Certification_ID => M_CERTIFICATION_ID ,
                       P_start_date => M_START_DATE,
                       P_end_date => M_END_DATE);


        AMW_FINSTMT_CERT_PVT.compute_values_for_eval_sum
                 (P_CERTIFICATION_ID => M_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID ,
               --   P_PARENT_FIN_ITEM_ID => null,
                  P_ACCOUNT_ID         => null,
                  P_ACCOUNT_GROUP_ID   => null,
                  P_FINANCIAL_ITEM_ID => null,
                  P_OBJECT_TYPE => 'FINANCIAL STATEMENT',
                  P_PROC_PENDING_CERTIFICATION =>
                  M_PROC_PENDING_CERTIFICATION ,
                  P_TOTAL_NUMBER_OF_PROCESSES  =>
                  M_TOTAL_NUMBER_OF_PROCESSES ,
                  P_PROC_CERTIFIED_WITH_ISSUES =>
                  M_PROC_CERTIFIED_WITH_ISSUES ,
                  P_PROC_VERIFIED              =>
                  M_PROC_VERIFIED              ,
                  P_org_with_ineffective_ctrls  =>
                  M_org_with_ineffective_ctrls  ,
                  P_org_certified              =>
                  M_org_certified              ,
                  P_proc_with_ineffective_ctrls  =>
                  M_proc_with_ineffective_ctrls,
                  P_unmitigated_risks          =>
                  M_unmitigated_risks          ,
                  P_risks_verified             =>
                  M_risks_verified             ,
                  P_ineffective_controls       =>
                  M_ineffective_controls    ,
                  P_controls_verified          =>
                  M_controls_verified         ,
                  P_open_issues                =>
                  M_open_issues                ,
                  P_PRO_PENDING_CERT_PRCNT =>
                  M_PRO_PENDING_CERT_PRCNT ,
                  P_PROCESSES_WITH_ISSUES_PRCNT =>
                  M_PROCESSES_WITH_ISSUES_PRCNT,
                  P_ORG_WITH_INEFF_CTRLS_PRCNT =>
                  M_ORG_WITH_INEFF_CTRLS_PRCNT ,
                  P_PROC_WITH_INEFF_CTRLS_PRCNT =>
                  M_PROC_WITH_INEFF_CTRLS_PRCNT,
                  P_UNMITIGATED_RISKS_PRCNT =>
                  M_UNMITIGATED_RISKS_PRCNT ,
                  P_INEFFECTIVE_CONTROLS_PRCNT =>
                  M_INEFFECTIVE_CONTROLS_PRCNT,
                  P_START_DATE  => M_START_DATE ,
                  P_END_DATE   => M_END_DATE,
                  p_PROCS_FOR_CERT_DONE => M_PROCS_FOR_CERT_DONE  ,
                  p_org_evaluated  => M_org_evaluated );


       end loop; -- end of main loop
      else
       for certifications in Get_Only_One_Cert
       loop

        exit when Get_Only_One_Cert%notfound;

        M_CERTIFICATION_ID := certifications.CERTIFICATION_ID ;
        M_FINANCIAL_STATEMENT_ID := certifications.FINANCIAL_STATEMENT_ID;
        M_STATEMENT_GROUP_ID := certifications.STATEMENT_GROUP_ID;
        M_OBJECT_TYPE := 'FINANCIAL STATEMENT';

        AMW_FINSTMT_CERT_PVT.GetGLPeriodfor_FinCertEvalSum(
                       P_Certification_ID => M_CERTIFICATION_ID ,
                       P_start_date => M_START_DATE,
                       P_end_date => M_END_DATE);



        AMW_FINSTMT_CERT_PVT.compute_values_for_eval_sum
                 (P_CERTIFICATION_ID => M_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID ,
               --   P_PARENT_FIN_ITEM_ID => null,
                  P_ACCOUNT_ID         => null,
                  P_ACCOUNT_GROUP_ID   => null,
                  P_FINANCIAL_ITEM_ID => null,
                  P_OBJECT_TYPE => 'FINANCIAL STATEMENT',
                  P_PROC_PENDING_CERTIFICATION =>
                  M_PROC_PENDING_CERTIFICATION ,
                  P_TOTAL_NUMBER_OF_PROCESSES  =>
                  M_TOTAL_NUMBER_OF_PROCESSES ,
                  P_PROC_CERTIFIED_WITH_ISSUES =>
                  M_PROC_CERTIFIED_WITH_ISSUES ,
                  P_PROC_VERIFIED              =>
                  M_PROC_VERIFIED              ,
                  P_org_with_ineffective_ctrls  =>
                  M_org_with_ineffective_ctrls  ,
                  P_org_certified              =>
                  M_org_certified              ,
                  P_proc_with_ineffective_ctrls  =>
                  M_proc_with_ineffective_ctrls,
                  P_unmitigated_risks          =>
                  M_unmitigated_risks          ,
                  P_risks_verified             =>
                  M_risks_verified             ,
                  P_ineffective_controls       =>
                  M_ineffective_controls    ,
                  P_controls_verified          =>
                  M_controls_verified         ,
                  P_open_issues                =>
                  M_open_issues                ,
                  P_PRO_PENDING_CERT_PRCNT =>
                  M_PRO_PENDING_CERT_PRCNT ,
                  P_PROCESSES_WITH_ISSUES_PRCNT =>
                  M_PROCESSES_WITH_ISSUES_PRCNT,
                  P_ORG_WITH_INEFF_CTRLS_PRCNT =>
                  M_ORG_WITH_INEFF_CTRLS_PRCNT ,
                  P_PROC_WITH_INEFF_CTRLS_PRCNT =>
                  M_PROC_WITH_INEFF_CTRLS_PRCNT,
                  P_UNMITIGATED_RISKS_PRCNT =>
                  M_UNMITIGATED_RISKS_PRCNT ,
                  P_INEFFECTIVE_CONTROLS_PRCNT =>
                  M_INEFFECTIVE_CONTROLS_PRCNT,
                  P_START_DATE  => M_START_DATE ,
                  P_END_DATE   => M_END_DATE,
                  p_PROCS_FOR_CERT_DONE => M_PROCS_FOR_CERT_DONE  ,
                  p_org_evaluated  => M_org_evaluated );

         end loop; -- end of main loop


      end if;
  end;
  errbuf := g_errbuf    ;
  retcode := g_retcode;

END build_amw_fin_cert_eval_sum;

****************************************/

----------------------------- ********************************** ----------------------
PROCEDURE reset_amw_fin_cert_eval_sum(p_certification_id in number)
is
  begin
  if p_certification_id is not null then
   update amw_fin_cert_eval_sum
   set
      PROC_PENDING_CERTIFICATION = 0,
      TOTAL_NUMBER_OF_PROCESSES  =0,
      PROC_CERTIFIED_WITH_ISSUES =0,
      --PROC_VERIFIED              =0 ,
      PROCS_FOR_CERT_DONE       =0 ,
      proc_evaluated            =0 ,
      org_with_ineffective_controls  =0,
      --org_certified              =0,
      orgs_FOR_CERT_DONE             =0,
      orgs_evaluated                    =0,
      proc_with_ineffective_controls  =0,
      unmitigated_risks          =0,
      risks_verified             =0,
      ineffective_controls       =0,
      controls_verified          =0,
      open_issues                =0,
      PRO_PENDING_CERT_PRCNT =0,
      PROCESSES_WITH_ISSUES_PRCNT =0,
      ORG_WITH_INEFF_CONTROLS_PRCNT =0,
      PROC_WITH_INEFF_CONTROLS_PRCNT =0,
      UNMITIGATED_RISKS_PRCNT =0,
      INEFFECTIVE_CONTROLS_PRCNT =0,
      total_number_of_risks = 0,
      total_number_of_ctrls = 0,
      total_number_of_orgs = 0
      WHERE fin_certification_id = p_certification_id;
  else
    update amw_fin_cert_eval_sum
    set
      PROC_PENDING_CERTIFICATION = 0,
      TOTAL_NUMBER_OF_PROCESSES  =0,
      PROC_CERTIFIED_WITH_ISSUES =0,
      --PROC_VERIFIED              =0 ,
       PROCS_FOR_CERT_DONE            =0 ,
     proc_evaluated                    =0 ,
      org_with_ineffective_controls  =0,
      -- org_certified              =0,
      orgs_FOR_CERT_DONE        =0,
      orgs_evaluated            =0,
      proc_with_ineffective_controls  =0,
      unmitigated_risks          =0,
      risks_verified             =0,
      ineffective_controls       =0,
      controls_verified          =0,
      open_issues                =0,
      PRO_PENDING_CERT_PRCNT =0,
      PROCESSES_WITH_ISSUES_PRCNT =0,
      ORG_WITH_INEFF_CONTROLS_PRCNT =0,
      PROC_WITH_INEFF_CONTROLS_PRCNT =0,
      UNMITIGATED_RISKS_PRCNT =0,
      INEFFECTIVE_CONTROLS_PRCNT =0,
       total_number_of_risks = 0,
      total_number_of_ctrls = 0,
      total_number_of_orgs = 0
      WHERE fin_certification_id IN
      (select
          certifcationVL.CERTIFICATION_ID
       FROM    AMW_CERTIFICATION_vl certifcationVL
       where
           certifcationVL.OBJECT_TYPE='FIN_STMT'
       and certifcationVL.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT'));

   end if;

END reset_amw_fin_cert_eval_sum;

----------------------------- ********************************** ----------------------
Procedure  compute_values_for_eval_sum(P_CERTIFICATION_ID IN NUMBER,
  P_FINANCIAL_STATEMENT_ID in number, P_STATEMENT_GROUP_ID in number,
      --P_PARENT_FIN_ITEM_ID  NUMBER,
      P_ACCOUNT_ID in NUMBER, P_ACCOUNT_GROUP_ID in number, P_FINANCIAL_ITEM_ID in number,
      P_OBJECT_TYPE in varchar2           ,          P_PROC_PENDING_CERTIFICATION out NOCOPY  number,
      P_TOTAL_NUMBER_OF_PROCESSES  out NOCOPY  number, P_PROC_CERTIFIED_WITH_ISSUES out NOCOPY  number,
      P_PROC_VERIFIED              out NOCOPY  number, P_org_with_ineffective_ctrls  out NOCOPY  number,
      P_org_certified              out NOCOPY  number, P_proc_with_ineffective_ctrls  out NOCOPY  number,
      P_unmitigated_risks          out NOCOPY  number, P_risks_verified             out NOCOPY  number,
      P_ineffective_controls       out NOCOPY  number, P_controls_verified          out NOCOPY  number,
      P_open_issues                out NOCOPY  number, P_PRO_PENDING_CERT_PRCNT out NOCOPY  number,
      P_PROCESSES_WITH_ISSUES_PRCNT out NOCOPY  number, P_ORG_WITH_INEFF_CTRLS_PRCNT out NOCOPY  number,
      P_PROC_WITH_INEFF_CTRLS_PRCNT out NOCOPY  number, P_UNMITIGATED_RISKS_PRCNT out NOCOPY  number,
      P_INEFFECTIVE_CONTROLS_PRCNT out NOCOPY  number, P_START_DATE  IN DATE ,
      P_END_DATE  IN  DATE, P_PROCS_FOR_CERT_DONE out NOCOPY  NUMBER, p_org_evaluated out NOCOPY  NUMBER) is


     /*  P_FINANCIAL_STATEMENT_ID in number, P_STATEMENT_GROUP_ID in number,
      --P_PARENT_FIN_ITEM_ID  NUMBER,
      P_ACCOUNT_ID in NUMBER, P_ACCOUNT_GROUP_ID in number, P_FINANCIAL_ITEM_ID in number,
      P_OBJECT_TYPE in varchar2           ,          P_PROC_PENDING_CERTIFICATION in out NOCOPY  number,
      P_TOTAL_NUMBER_OF_PROCESSES  in out NOCOPY  number, P_PROC_CERTIFIED_WITH_ISSUES in out NOCOPY  number,
      P_PROC_VERIFIED              in out NOCOPY  number, P_org_with_ineffective_ctrls  in out NOCOPY  number,
      P_org_certified              in out NOCOPY  number, P_proc_with_ineffective_ctrls  in out NOCOPY  number,
      P_unmitigated_risks          in out NOCOPY  number, P_risks_verified             in out NOCOPY  number,
      P_ineffective_controls       in out NOCOPY  number, P_controls_verified          in out NOCOPY  number,
      P_open_issues                in out NOCOPY  number, P_PRO_PENDING_CERT_PRCNT in out NOCOPY  number,
      P_PROCESSES_WITH_ISSUES_PRCNT in out NOCOPY  number, P_ORG_WITH_INEFF_CTRLS_PRCNT in out NOCOPY  number,
      P_PROC_WITH_INEFF_CTRLS_PRCNT in out NOCOPY  number, P_UNMITIGATED_RISKS_PRCNT in out NOCOPY  number,
      P_INEFFECTIVE_CONTROLS_PRCNT in out NOCOPY  number, P_START_DATE  IN DATE ,
      P_END_DATE  IN  DATE, P_PROCS_FOR_CERT_DONE in out NUMBER, p_org_evaluated in out NUMBER) is*/

begin
 declare


   M_CERTIFICATION_ID NUMBER := 0;
   M_START_DATE  DATE  ;
   M_END_DATE DATE   ;

   M_FINANCIAL_STATEMENT_ID NUMBER := 0;
   M_STATEMENT_GROUP_ID NUMBER := 0;
   M_OBJECT_TYPE varchar2(25) := null;
   M_ACCOUNT_GROUP_ID NUMBER := 0;
   M_NATURAL_ACCOUNT_ID NUMBER := 0;
   M_NATURAL_ACCOUNT_ID_2 NUMBER := 0;
   M_FINANCIAL_ITEM_ID    NUMBER := 0;

-- variables for totals
      M_PROC_PENDING_CERTIFICATION number :=0;
      M_TOTAL_NUMBER_OF_PROCESSES  number :=0;
      M_PROC_CERTIFIED_WITH_ISSUES number :=0;
      M_PROC_VERIFIED              number :=0;
      M_org_with_ineffective_ctrls  number :=0;
      M_org_certified              number :=0;
      M_proc_with_ineffective_ctrls  number :=0;
      M_unmitigated_risks          number :=0;
      M_risks_verified             number :=0;
      M_ineffective_controls       number :=0;
      M_controls_verified          number :=0;
      M_open_issues                number :=0;

       M_PRO_PENDING_CERT_PRCNT number :=0;
      M_PROCESSES_WITH_ISSUES_PRCNT number :=0;
      M_ORG_WITH_INEFF_CTRLS_PRCNT number :=0;
      M_PROC_WITH_INEFF_CTRLS_PRCNT number :=0;
      M_UNMITIGATED_RISKS_PRCNT number  :=0;
      M_INEFFECTIVE_CONTROLS_PRCNT number :=0;
      M_PROCS_FOR_CERT_DONE number :=0;
      M_org_evaluated number :=0;

      T_PROC_PENDING_CERTIFICATION number :=0;
      T_TOTAL_NUMBER_OF_PROCESSES  number :=0;
      T_PROC_CERTIFIED_WITH_ISSUES number :=0;
      T_PROC_VERIFIED              number :=0;
      T_org_with_ineffective_ctrls  number :=0;
      T_org_certified              number :=0;
      T_proc_with_ineffective_ctrls  number :=0;
      T_unmitigated_risks          number :=0;
      T_risks_verified             number :=0;
      T_ineffective_controls       number :=0;
      T_controls_verified          number :=0;
      T_open_issues                number :=0;
      T_PRO_PENDING_CERT_PRCNT number :=0;
      T_PROCESSES_WITH_ISSUES_PRCNT number :=0;
      T_ORG_WITH_INEFF_CTRLS_PRCNT number :=0;
      T_PROC_WITH_INEFF_CTRLS_PRCNT number :=0;
      T_UNMITIGATED_RISKS_PRCNT number  :=0;
      T_INEFFECTIVE_CONTROLS_PRCNT number :=0;



 -- CURRSOR TO GET ONLY THE TOP LEVEL FINANCIAL ITEMS WHICH HAS NO PARENT
 cursor Get_toplevel_fin_items is
 select
  STATEMENT_GROUP_ID,
  FINANCIAL_STATEMENT_ID,
  FINANCIAL_ITEM_ID
 from
  AMW_FIN_STMNT_ITEMS_B
 where
  STATEMENT_GROUP_ID = P_STATEMENT_GROUP_ID
  and FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
  and PARENT_FINANCIAL_ITEM_ID is null;

  -- CURRSOR TO GET ONLY THE FINANCIAL ITEMS WHICH HAS A PARENT

 cursor Get_child_fin_items
 --(PAR_PARENT_FIN_ITEM_ID  NUMBER)
 is
 select
  STATEMENT_GROUP_ID,
  FINANCIAL_STATEMENT_ID,
  FINANCIAL_ITEM_ID,
  PARENT_FINANCIAL_ITEM_ID
 from
  AMW_FIN_STMNT_ITEMS_B
 where
  STATEMENT_GROUP_ID = P_STATEMENT_GROUP_ID
  and FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
  and PARENT_FINANCIAL_ITEM_ID = P_FINANCIAL_ITEM_ID ;


  -- CURRSOR TO GET ONLY THE ACOUNTS THOSE ARE DIRECTLY ASSOCIATED TO  A FINANCIAL ITEM
  -- The Accounts (which could be a Child of another account) whose parents are not linked to a financial item need to be selected
  -- Accounts (with a parent natural account) whose parents  are attached to a financial items shoudl not be selected here

 cursor Get_fin_accs is
 select
  STATEMENT_GROUP_ID,
  ACCOUNT_GROUP_ID,
  FINANCIAL_STATEMENT_ID,
  FINANCIAL_ITEM_ID,
  NATURAL_ACCOUNT_ID
 from
  AMW_FIN_ITEMS_KEY_ACC finitemAcc
 where
  STATEMENT_GROUP_ID = P_STATEMENT_GROUP_ID
  and FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
  and FINANCIAL_ITEM_ID = P_FINANCIAL_ITEM_ID
   and not exists
   -- make sure that children accounts whose parents are also attached to a financial item are not selected
   -- again, as we will select them in next union
    (
    Select
    KeyAccChild2.ACCOUNT_GROUP_ID  ,
    KeyAccChild2.NATURAL_ACCOUNT_ID,
    KeyAccChild2.PARENT_NATURAL_ACCOUNT_ID,
    KeyAccChild2.NATURAL_ACCOUNT_VALUE
   From
     AMW_FIN_KEY_ACCOUNTS_B  KeyAccChild2,
     AMW_FIN_ITEMS_KEY_ACC finitemAcc2
   Where
       (KeyAccChild2.PARENT_NATURAL_ACCOUNT_ID is not null)
   and    KeyAccChild2.ACCOUNT_GROUP_ID = finitemAcc.ACCOUNT_GROUP_ID
   AND KeyAccChild2.NATURAL_ACCOUNT_ID = finitemAcc.NATURAL_ACCOUNT_ID
   AND KeyAccChild2.PARENT_NATURAL_ACCOUNT_ID = finitemAcc2.NATURAL_ACCOUNT_ID
   and    KeyAccChild2.ACCOUNT_GROUP_ID = finitemAcc2.ACCOUNT_GROUP_ID
   ------------------- ADDED THE REST OF CRITERIA TO CHECK THE MASTER ACCOUT EXISTS FOR THE SAME STATEMENT AND ITEM
  and   finitemAcc2.STATEMENT_GROUP_ID = finitemAcc.STATEMENT_GROUP_ID
 and finitemAcc2.FINANCIAL_STATEMENT_ID = finitemAcc.FINANCIAL_STATEMENT_ID
 and finitemAcc2.FINANCIAL_ITEM_ID = finitemAcc.FINANCIAL_ITEM_ID
   )
;


/*  ---- NOT USED -------  Commented as the Child whose parents are not linked to a financial item was not treated
 --- differently from those whose parents also are attached to financial items
 cursor Get_fin_accs is
 select
  STATEMENT_GROUP_ID,
  ACCOUNT_GROUP_ID,
  FINANCIAL_STATEMENT_ID,
  FINANCIAL_ITEM_ID,
  NATURAL_ACCOUNT_ID
 from
  AMW_FIN_ITEMS_KEY_ACC
 where
  STATEMENT_GROUP_ID = P_STATEMENT_GROUP_ID
  and FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
  and FINANCIAL_ITEM_ID = P_FINANCIAL_ITEM_ID ;
*/

 -- CURRSOR TO GET ONLY THE ACCOUNTS THOSE ARE CHILDREN TO AN ACCOUNT WHICH INTRUN IS ASSOCIATED TO  A FINANCIAL ITEM

cursor Get_sub_accs
--(PAR_ACCOUNT_ID NUMBER, PAR_ACCOUNT_GROUP_ID NUMBER)
is
select
     ACCOUNT_GROUP_ID,
     NATURAL_ACCOUNT_ID
from
  AMW_FIN_KEY_ACCOUNTS_B
where
        PARENT_NATURAL_ACCOUNT_ID   = P_ACCOUNT_ID
   and  ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID;


 begin
       -- THE NEXT 3 VARIABLES (M_CERTIFICATION_ID , M_START_DATE AND M_END_DATE) ARE EACH TIME
       -- PASSED TO ITS CORRESPONDING PARAMETER AND STORED BACK AS THIS PROC
       -- IS CALLED IN RECURSIVE MODE AND DO NOT WANT TO REQUERY TO GET THESE INFORMATION
       M_CERTIFICATION_ID := P_CERTIFICATION_ID ;
       M_START_DATE := P_START_DATE  ;
       M_END_DATE := P_END_DATE   ;

       if P_OBJECT_TYPE = 'FINANCIAL STATEMENT' then

           for statement_items in Get_toplevel_fin_items
           loop
               exit when Get_toplevel_fin_items%notfound;
               M_STATEMENT_GROUP_ID := statement_items.STATEMENT_GROUP_ID;
               M_FINANCIAL_STATEMENT_ID := statement_items.FINANCIAL_STATEMENT_ID;
               M_FINANCIAL_ITEM_ID := statement_items.FINANCIAL_ITEM_ID;

               g_user_id  := fnd_global.user_id;
               g_login_id := fnd_global.conc_login_id;

               AMW_FINSTMT_CERT_PVT.compute_values_for_eval_sum
                 (P_CERTIFICATION_ID => M_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID ,
               --   P_PARENT_FIN_ITEM_ID => null,
                  P_ACCOUNT_ID         => null,
                  P_ACCOUNT_GROUP_ID   => null,
                  P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM',
                  P_PROC_PENDING_CERTIFICATION =>
                  M_PROC_PENDING_CERTIFICATION ,
                  P_TOTAL_NUMBER_OF_PROCESSES  =>
                  M_TOTAL_NUMBER_OF_PROCESSES ,
                  P_PROC_CERTIFIED_WITH_ISSUES =>
                  M_PROC_CERTIFIED_WITH_ISSUES ,
                  P_PROC_VERIFIED              =>
                  M_PROC_VERIFIED              ,
                  P_org_with_ineffective_ctrls  =>
                  M_org_with_ineffective_ctrls  ,
                  P_org_certified              =>
                  M_org_certified              ,
                  P_proc_with_ineffective_ctrls  =>
                  M_proc_with_ineffective_ctrls,
                  P_unmitigated_risks          =>
                  M_unmitigated_risks          ,
                  P_risks_verified             =>
                  M_risks_verified             ,
                  P_ineffective_controls       =>
                  M_ineffective_controls    ,
                  P_controls_verified          =>
                  M_controls_verified         ,
                  P_open_issues                =>
                  M_open_issues                ,
                  P_PRO_PENDING_CERT_PRCNT =>
                  M_PRO_PENDING_CERT_PRCNT ,
                  P_PROCESSES_WITH_ISSUES_PRCNT =>
                  M_PROCESSES_WITH_ISSUES_PRCNT,
                  P_ORG_WITH_INEFF_CTRLS_PRCNT =>
                  M_ORG_WITH_INEFF_CTRLS_PRCNT ,
                  P_PROC_WITH_INEFF_CTRLS_PRCNT =>
                  M_PROC_WITH_INEFF_CTRLS_PRCNT,
                  P_UNMITIGATED_RISKS_PRCNT =>
                  M_UNMITIGATED_RISKS_PRCNT ,
                  P_INEFFECTIVE_CONTROLS_PRCNT =>
                  M_INEFFECTIVE_CONTROLS_PRCNT,
                  P_START_DATE  => M_START_DATE ,
                  P_END_DATE   => M_END_DATE,
                  p_PROCS_FOR_CERT_DONE => M_PROCS_FOR_CERT_DONE  ,
                  p_org_evaluated  => M_org_evaluated  );


                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                   M_PRO_PENDING_CERT_PRCNT       := (m_PROC_PENDING_CERTIFICATION / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;

               /*  if (m_PROCS_FOR_CERT_DONE is not null and m_PROCS_FOR_CERT_DONE <> 0) then
                   M_PROCESSES_WITH_ISSUES_PRCNT  := (m_PROC_CERTIFIED_WITH_ISSUES / m_PROCS_FOR_CERT_DONE  ) * 100 ;
                 end if; */

                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                   M_PROCESSES_WITH_ISSUES_PRCNT  := (m_PROC_CERTIFIED_WITH_ISSUES / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;


                 if  (m_org_evaluated is not null and m_org_evaluated <> 0) then
                   M_ORG_WITH_INEFF_CTRLS_PRCNT   := (m_org_with_ineffective_ctrls / m_org_evaluated) * 100;
                 end if;

                 /* --if (m_PROC_VERIFIED is not null and m_PROC_VERIFIED <> 0)  then
                     M_PROC_WITH_INEFF_CTRLS_PRCNT  := (m_proc_with_ineffective_ctrls / m_PROC_VERIFIED) * 100 ;
                 end if; */

                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                    M_PROC_WITH_INEFF_CTRLS_PRCNT  := (m_proc_with_ineffective_ctrls / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;

                 if (m_risks_verified is not null and m_risks_verified <> 0)    then
                   M_UNMITIGATED_RISKS_PRCNT      := (m_unmitigated_risks / m_risks_verified) * 100;
                 end if;
                 if (m_controls_verified is not null and m_controls_verified <> 0) then
                   M_INEFFECTIVE_CONTROLS_PRCNT   := (m_ineffective_controls / m_controls_verified) * 100;
                 end if;


               -- insert a fin item record
           AMW_FINSTMT_CERT_PVT.insert_fin_cert_eval_sum(
                X_FIN_CERTIFICATION_ID                       => M_CERTIFICATION_ID,
                X_FINANCIAL_STATEMENT_ID                     => M_FINANCIAL_STATEMENT_ID,
                X_FINANCIAL_ITEM_ID                          => M_FINANCIAL_ITEM_ID,
                X_ACCOUNT_GROUP_ID                           => NULL      ,
                X_NATURAL_ACCOUNT_ID                         => NULL,
                X_OBJECT_TYPE                                => 'FINANCIAL ITEM',
                X_PROC_PENDING_CERTIFICATION                 => M_PROC_PENDING_CERTIFICATION,
                X_TOTAL_NUMBER_OF_PROCESSES                  => M_TOTAL_NUMBER_OF_PROCESSES,
                X_PROC_CERTIFIED_WITH_ISSUES                 => M_PROC_CERTIFIED_WITH_ISSUES,
                --X_PROC_VERIFIED                              => M_PROC_VERIFIED,
                X_PROCS_FOR_CERT_DONE                        => M_PROCS_FOR_CERT_DONE,
                x_proc_evaluated                             => M_PROC_VERIFIED,
                X_ORG_WITH_INEFFECTIVE_CTRLS                 => M_org_with_ineffective_ctrls,
                -- X_ORG_CERTIFIED                              => M_org_certified,
                x_orgs_FOR_CERT_DONE                        => M_org_certified,
                x_orgs_evaluated                            => M_org_evaluated,
                X_PROC_WITH_INEFFECTIVE_CTRLS                => M_proc_with_ineffective_ctrls,
                X_UNMITIGATED_RISKS                          => M_unmitigated_risks,
                X_RISKS_VERIFIED                             => M_risks_verified,
                X_INEFFECTIVE_CONTROLS                       => M_ineffective_controls,
                X_CONTROLS_VERIFIED                          => M_controls_verified,
                X_OPEN_ISSUES                                => M_open_issues,
                X_PRO_PENDING_CERT_PRCNT                     => M_PRO_PENDING_CERT_PRCNT,
                X_PROCESSES_WITH_ISSUES_PRCNT                => M_PROCESSES_WITH_ISSUES_PRCNT,
                X_ORG_WITH_INEFF_CTRLS_PRCNT                 => M_ORG_WITH_INEFF_CTRLS_PRCNT,
                X_PROC_WITH_INEFF_CTRLS_PRCNT                => M_PROC_WITH_INEFF_CTRLS_PRCNT,
                X_UNMITIGATED_RISKS_PRCNT                    => M_UNMITIGATED_RISKS_PRCNT,
                X_INEFFECTIVE_CTRLS_PRCNT                    => M_INEFFECTIVE_CONTROLS_PRCNT,
                X_OBJ_CONTEXT                                => NULL,
                X_CREATED_BY                                 => g_user_id,
                X_CREATION_DATE                              => SYSDATE,
                X_LAST_UPDATED_BY                            => g_user_id,
                X_LAST_UPDATE_DATE                           => SYSDATE,
                X_LAST_UPDATE_LOGIN                          => g_login_id,
                X_SECURITY_GROUP_ID                          => NULL,
                X_OBJECT_VERSION_NUMBER                      => NULL);


            end loop;
       elsif P_OBJECT_TYPE = 'FINANCIAL ITEM' then

                M_FINANCIAL_STATEMENT_ID := P_FINANCIAL_STATEMENT_ID ;
                M_STATEMENT_GROUP_ID := P_STATEMENT_GROUP_ID;
                M_FINANCIAL_ITEM_ID := P_FINANCIAL_ITEM_ID ;

                GetTotalProcesses_for_finitem(
                      P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                      P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                      P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                      P_TOTAL_NUMBER_OF_PROCESSES => M_TOTAL_NUMBER_OF_PROCESSES);

       IF (M_TOTAL_NUMBER_OF_PROCESSES IS NOT NULL OR
           M_TOTAL_NUMBER_OF_PROCESSES <> 0)
       THEN

                   CountProcsCertRecorded_finitem(
                      P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                      P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                      P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                        P_PROCS_IN_CERTIFICATION  => M_PROCS_FOR_CERT_DONE
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE
                       , p_fin_cert_id => M_CERTIFICATION_ID) ;


                   CountProcsEvaluated_finitem(
                      P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                      P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                      P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                       P_PROCS_EVALUATED  => M_PROC_VERIFIED
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;


                   M_PROC_PENDING_CERTIFICATION := M_TOTAL_NUMBER_OF_PROCESSES - M_PROCS_FOR_CERT_DONE ;

                   CountProcswithIssues_finitem(
                        P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                        P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                        P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                        P_PROC_CERTIFIED_WITH_ISSUES  => M_PROC_CERTIFIED_WITH_ISSUES
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE
                       , p_fin_cert_id => M_CERTIFICATION_ID) ;

                   CountOrgsIneffCtrl_finitem(
                         P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                         P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                         P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                         P_org_with_ineffective_ctrls =>M_org_with_ineffective_ctrls
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                    CountOrgsEvaluated_finitem(
                          P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                          P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                          P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                          P_org_evaluated  => M_org_evaluated
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;


                 /* CountOrgswithIssues_Accounts(P_NATURAL_ACCOUNT_ID in number,
                ?  P_org_cert_with_issues OUT  Number,
                   p_start_date in date, p_end_date in date)  ;
                   */

                 CountOrgsCertified_finitem(
                      P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                      P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                      P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                      P_org_certified =>M_org_certified
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                  CountProcsIneffCtrl_finitem(
                      P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                      P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                      P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                      P_proc_with_ineffective_ctrls =>  M_proc_with_ineffective_ctrls
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                  CountIneffectiveCtrls_finitem(
                        P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                        P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                        P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                         p_ineffective_controls => M_ineffective_controls
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                  CountUnmittigatedRisk_finitem(
                        P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                        P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                        P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                         p_unmitigated_risks => M_unmitigated_risks
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                  CountRisksVerified_finitem(
                         P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                        P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                        P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                         p_risks_verified => M_risks_verified
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                 CountControlsVerified_finitem(
                         P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID,
                         P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                         P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID ,
                         p_controls_verified => M_controls_verified
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;


                  P_PROC_PENDING_CERTIFICATION  := NVL(M_PROC_PENDING_CERTIFICATION,0);
                  P_TOTAL_NUMBER_OF_PROCESSES   := NVL(M_TOTAL_NUMBER_OF_PROCESSES,0)  ;
                  P_PROC_CERTIFIED_WITH_ISSUES  := NVL(M_PROC_CERTIFIED_WITH_ISSUES,0) ;
                  P_PROC_VERIFIED               := NVL(M_PROC_VERIFIED,0)              ;
                  P_org_with_ineffective_ctrls  := NVL(M_org_with_ineffective_ctrls,0);
                  P_org_certified               := NVL(M_org_certified,0)             ;
                  P_proc_with_ineffective_ctrls := NVL(M_proc_with_ineffective_ctrls,0)  ;
                  P_unmitigated_risks           := NVL(M_unmitigated_risks,0)          ;
                  P_risks_verified              := NVL(M_risks_verified,0)             ;
                  P_ineffective_controls        := NVL(M_ineffective_controls,0)       ;
                  P_controls_verified           := NVL(M_controls_verified,0)          ;
                  P_open_issues                 := NVL(M_open_issues,0)                ;
                  P_PROCS_FOR_CERT_DONE         := nvl(m_PROCS_FOR_CERT_DONE,0);
                  p_org_evaluated               := NVL(M_org_evaluated,0) ;





             for stmnt_child_items in Get_child_fin_items
             loop
                 exit when Get_child_fin_items%notfound;
                 M_STATEMENT_GROUP_ID := stmnt_child_items.STATEMENT_GROUP_ID;
                 M_FINANCIAL_STATEMENT_ID := stmnt_child_items.FINANCIAL_STATEMENT_ID;
                 M_FINANCIAL_ITEM_ID := stmnt_child_items.FINANCIAL_ITEM_ID;


                  AMW_FINSTMT_CERT_PVT.compute_values_for_eval_sum
                 (P_CERTIFICATION_ID => M_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID ,
                  --P_PARENT_FIN_ITEM_ID => null;
                  P_ACCOUNT_ID         => null,
                  P_ACCOUNT_GROUP_ID   => null,
                  P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM',
                  P_PROC_PENDING_CERTIFICATION =>
                  M_PROC_PENDING_CERTIFICATION ,
                  P_TOTAL_NUMBER_OF_PROCESSES  =>
                  M_TOTAL_NUMBER_OF_PROCESSES ,
                  P_PROC_CERTIFIED_WITH_ISSUES =>
                  M_PROC_CERTIFIED_WITH_ISSUES ,
                  P_PROC_VERIFIED              =>
                  M_PROC_VERIFIED              ,
                  P_org_with_ineffective_ctrls  =>
                  M_org_with_ineffective_ctrls  ,
                  P_org_certified              =>
                  M_org_certified              ,
                  P_proc_with_ineffective_ctrls  =>
                  M_proc_with_ineffective_ctrls,
                  P_unmitigated_risks          =>
                  M_unmitigated_risks          ,
                  P_risks_verified             =>
                  M_risks_verified             ,
                  P_ineffective_controls       =>
                  M_ineffective_controls    ,
                  P_controls_verified          =>
                  M_controls_verified         ,
                  P_open_issues                =>
                  M_open_issues                ,
                  P_PRO_PENDING_CERT_PRCNT =>
                  M_PRO_PENDING_CERT_PRCNT ,
                  P_PROCESSES_WITH_ISSUES_PRCNT =>
                  M_PROCESSES_WITH_ISSUES_PRCNT,
                  P_ORG_WITH_INEFF_CTRLS_PRCNT =>
                  M_ORG_WITH_INEFF_CTRLS_PRCNT ,
                  P_PROC_WITH_INEFF_CTRLS_PRCNT =>
                  M_PROC_WITH_INEFF_CTRLS_PRCNT,
                  P_UNMITIGATED_RISKS_PRCNT =>
                  M_UNMITIGATED_RISKS_PRCNT ,
                  P_INEFFECTIVE_CONTROLS_PRCNT =>
                  M_INEFFECTIVE_CONTROLS_PRCNT,
                  P_START_DATE  => M_START_DATE ,
                  P_END_DATE   => M_END_DATE,
                  p_PROCS_FOR_CERT_DONE => M_PROCS_FOR_CERT_DONE  ,
                  p_org_evaluated  => M_org_evaluated );



                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                   M_PRO_PENDING_CERT_PRCNT       := (m_PROC_PENDING_CERTIFICATION / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;

                 /*if (m_PROCS_FOR_CERT_DONE is not null and m_PROCS_FOR_CERT_DONE <> 0) then
                   M_PROCESSES_WITH_ISSUES_PRCNT  := (m_PROC_CERTIFIED_WITH_ISSUES / m_PROCS_FOR_CERT_DONE  ) * 100 ;
                 end if;*/

                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                   M_PROCESSES_WITH_ISSUES_PRCNT  := (m_PROC_CERTIFIED_WITH_ISSUES / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;

                 if  (m_org_evaluated is not null and m_org_evaluated <> 0) then
                   M_ORG_WITH_INEFF_CTRLS_PRCNT   := (m_org_with_ineffective_ctrls / m_org_evaluated) * 100;
                 end if;

                 /* if (m_PROC_VERIFIED is not null and m_PROC_VERIFIED <> 0)  then
                     M_PROC_WITH_INEFF_CTRLS_PRCNT  := (m_proc_with_ineffective_ctrls / m_PROC_VERIFIED) * 100 ;
                 end if; */

                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                     M_PROC_WITH_INEFF_CTRLS_PRCNT  := (m_proc_with_ineffective_ctrls / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;


                 if (m_risks_verified is not null and m_risks_verified <> 0)    then
                   M_UNMITIGATED_RISKS_PRCNT      := (m_unmitigated_risks / m_risks_verified) * 100;
                 end if;
                 if (m_controls_verified is not null and m_controls_verified <> 0) then
                   M_INEFFECTIVE_CONTROLS_PRCNT   := (m_ineffective_controls / m_controls_verified) * 100;
                 end if;



                  -- insert a financial item record which will take care of the child financial items
               AMW_FINSTMT_CERT_PVT.insert_fin_cert_eval_sum(
                X_FIN_CERTIFICATION_ID                       => M_CERTIFICATION_ID,
                X_FINANCIAL_STATEMENT_ID                     => M_FINANCIAL_STATEMENT_ID,
                X_FINANCIAL_ITEM_ID                          => M_FINANCIAL_ITEM_ID,
                X_ACCOUNT_GROUP_ID                           => NULL,
                X_NATURAL_ACCOUNT_ID                         => NULL,
                X_OBJECT_TYPE                                => 'FINANCIAL ITEM',
                X_PROC_PENDING_CERTIFICATION                 => M_PROC_PENDING_CERTIFICATION,
                X_TOTAL_NUMBER_OF_PROCESSES                  => M_TOTAL_NUMBER_OF_PROCESSES,
                X_PROC_CERTIFIED_WITH_ISSUES                 => M_PROC_CERTIFIED_WITH_ISSUES,
               -- X_PROC_VERIFIED                              => M_PROC_VERIFIED,
                X_PROCS_FOR_CERT_DONE                        => M_PROCS_FOR_CERT_DONE,
                x_proc_evaluated                             => M_PROC_VERIFIED,
                X_ORG_WITH_INEFFECTIVE_CTRLS                 => M_org_with_ineffective_ctrls,
            --    X_ORG_CERTIFIED                              => M_org_certified,
                x_orgs_FOR_CERT_DONE                        => M_org_certified,
                x_orgs_evaluated                            => M_org_evaluated,
                X_PROC_WITH_INEFFECTIVE_CTRLS                => M_proc_with_ineffective_ctrls,
                X_UNMITIGATED_RISKS                          => M_unmitigated_risks,
                X_RISKS_VERIFIED                             => M_risks_verified,
                X_INEFFECTIVE_CONTROLS                       => M_ineffective_controls,
                X_CONTROLS_VERIFIED                          => M_controls_verified,
                X_OPEN_ISSUES                                => M_open_issues,
                X_PRO_PENDING_CERT_PRCNT                     => M_PRO_PENDING_CERT_PRCNT,
                X_PROCESSES_WITH_ISSUES_PRCNT                => M_PROCESSES_WITH_ISSUES_PRCNT,
                X_ORG_WITH_INEFF_CTRLS_PRCNT                 => M_ORG_WITH_INEFF_CTRLS_PRCNT,
                X_PROC_WITH_INEFF_CTRLS_PRCNT                => M_PROC_WITH_INEFF_CTRLS_PRCNT,
                X_UNMITIGATED_RISKS_PRCNT                    => M_UNMITIGATED_RISKS_PRCNT,
                X_INEFFECTIVE_CTRLS_PRCNT                    => M_INEFFECTIVE_CONTROLS_PRCNT,
                X_OBJ_CONTEXT                                => NULL,
                X_CREATED_BY                                 => g_user_id,
                X_CREATION_DATE                              => SYSDATE,
                X_LAST_UPDATED_BY                            => g_user_id,
                X_LAST_UPDATE_DATE                           => SYSDATE,
                X_LAST_UPDATE_LOGIN                          => g_login_id,
                X_SECURITY_GROUP_ID                          => NULL,
                X_OBJECT_VERSION_NUMBER                      => NULL);



             end loop;


             for stmnt_accs in Get_fin_accs
             loop
                 exit when Get_fin_accs%notfound;

                 M_STATEMENT_GROUP_ID := stmnt_accs.STATEMENT_GROUP_ID;
                 M_FINANCIAL_STATEMENT_ID := stmnt_accs.FINANCIAL_STATEMENT_ID;
                 M_FINANCIAL_ITEM_ID := stmnt_accs.FINANCIAL_ITEM_ID;
                 M_ACCOUNT_GROUP_ID  := stmnt_accs.ACCOUNT_GROUP_ID;
                 M_NATURAL_ACCOUNT_ID := stmnt_accs.NATURAL_ACCOUNT_ID;

                 AMW_FINSTMT_CERT_PVT.compute_values_for_eval_sum
                 (P_CERTIFICATION_ID => M_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID ,
                  --P_PARENT_FIN_ITEM_ID => null;
                  P_ACCOUNT_ID         => M_NATURAL_ACCOUNT_ID ,
                  P_ACCOUNT_GROUP_ID   => M_ACCOUNT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID,
                  P_OBJECT_TYPE => 'ACCOUNT',
                  P_PROC_PENDING_CERTIFICATION =>
                  M_PROC_PENDING_CERTIFICATION ,
                  P_TOTAL_NUMBER_OF_PROCESSES  =>
                  M_TOTAL_NUMBER_OF_PROCESSES ,
                  P_PROC_CERTIFIED_WITH_ISSUES =>
                  M_PROC_CERTIFIED_WITH_ISSUES ,
                  P_PROC_VERIFIED              =>
                  M_PROC_VERIFIED              ,
                  P_org_with_ineffective_ctrls  =>
                  M_org_with_ineffective_ctrls  ,
                  P_org_certified              =>
                  M_org_certified              ,
                  P_proc_with_ineffective_ctrls  =>
                  M_proc_with_ineffective_ctrls,
                  P_unmitigated_risks          =>
                  M_unmitigated_risks          ,
                  P_risks_verified             =>
                  M_risks_verified             ,
                  P_ineffective_controls       =>
                  M_ineffective_controls    ,
                  P_controls_verified          =>
                  M_controls_verified         ,
                  P_open_issues                =>
                  M_open_issues                ,
                  P_PRO_PENDING_CERT_PRCNT =>
                  M_PRO_PENDING_CERT_PRCNT ,
                  P_PROCESSES_WITH_ISSUES_PRCNT =>
                  M_PROCESSES_WITH_ISSUES_PRCNT,
                  P_ORG_WITH_INEFF_CTRLS_PRCNT =>
                  M_ORG_WITH_INEFF_CTRLS_PRCNT ,
                  P_PROC_WITH_INEFF_CTRLS_PRCNT =>
                  M_PROC_WITH_INEFF_CTRLS_PRCNT,
                  P_UNMITIGATED_RISKS_PRCNT =>
                  M_UNMITIGATED_RISKS_PRCNT ,
                  P_INEFFECTIVE_CONTROLS_PRCNT =>
                  M_INEFFECTIVE_CONTROLS_PRCNT,
                  P_START_DATE  => M_START_DATE ,
                  P_END_DATE   => M_END_DATE,
                  p_PROCS_FOR_CERT_DONE => M_PROCS_FOR_CERT_DONE  ,
                  p_org_evaluated  => M_org_evaluated );



                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                   M_PRO_PENDING_CERT_PRCNT       := (m_PROC_PENDING_CERTIFICATION / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;

                 /* if (m_PROCS_FOR_CERT_DONE is not null and m_PROCS_FOR_CERT_DONE <> 0) then
                   M_PROCESSES_WITH_ISSUES_PRCNT  := (m_PROC_CERTIFIED_WITH_ISSUES / m_PROCS_FOR_CERT_DONE  ) * 100 ;
                 end if; */

                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                   M_PROCESSES_WITH_ISSUES_PRCNT  := (m_PROC_CERTIFIED_WITH_ISSUES / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;


                 if  (m_org_evaluated is not null and m_org_evaluated <> 0) then
                   M_ORG_WITH_INEFF_CTRLS_PRCNT   := (m_org_with_ineffective_ctrls / m_org_evaluated) * 100;
                 end if;

                 /*if (m_PROC_VERIFIED is not null and m_PROC_VERIFIED <> 0)  then
                     M_PROC_WITH_INEFF_CTRLS_PRCNT  := (m_proc_with_ineffective_ctrls / m_PROC_VERIFIED) * 100 ;
                 end if; */

                if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                     M_PROC_WITH_INEFF_CTRLS_PRCNT  := (m_proc_with_ineffective_ctrls / m_TOTAL_NUMBER_OF_PROCESSES ) * 100 ;
                 end if;

                 if (m_risks_verified is not null and m_risks_verified <> 0)    then
                   M_UNMITIGATED_RISKS_PRCNT      := (m_unmitigated_risks / m_risks_verified) * 100;
                 end if;
                 if (m_controls_verified is not null and m_controls_verified <> 0) then
                   M_INEFFECTIVE_CONTROLS_PRCNT   := (m_ineffective_controls / m_controls_verified) * 100;
                 end if;

                   -- insert a KEY ACCOUNT record

               AMW_FINSTMT_CERT_PVT.insert_fin_cert_eval_sum(
                X_FIN_CERTIFICATION_ID                       => M_CERTIFICATION_ID,
                X_FINANCIAL_STATEMENT_ID                     => M_FINANCIAL_STATEMENT_ID,
                X_FINANCIAL_ITEM_ID                          => M_FINANCIAL_ITEM_ID,
                X_ACCOUNT_GROUP_ID                           => M_ACCOUNT_GROUP_ID      ,
                X_NATURAL_ACCOUNT_ID                         => M_NATURAL_ACCOUNT_ID,
                X_OBJECT_TYPE                                => 'ACCOUNT',
                X_PROC_PENDING_CERTIFICATION                 => M_PROC_PENDING_CERTIFICATION,
                X_TOTAL_NUMBER_OF_PROCESSES                  => M_TOTAL_NUMBER_OF_PROCESSES,
                X_PROC_CERTIFIED_WITH_ISSUES                 => M_PROC_CERTIFIED_WITH_ISSUES,
           --     X_PROC_VERIFIED                              => M_PROC_VERIFIED,
                X_PROCS_FOR_CERT_DONE                        => M_PROCS_FOR_CERT_DONE,
                x_proc_evaluated                             => M_PROC_VERIFIED,
                X_ORG_WITH_INEFFECTIVE_CTRLS                 => M_org_with_ineffective_ctrls,
               -- X_ORG_CERTIFIED                              => M_org_certified,
                x_orgs_FOR_CERT_DONE                        => M_org_certified,
                x_orgs_evaluated                            => M_org_evaluated,
                X_PROC_WITH_INEFFECTIVE_CTRLS                => M_proc_with_ineffective_ctrls,
                X_UNMITIGATED_RISKS                          => M_unmitigated_risks,
                X_RISKS_VERIFIED                             => M_risks_verified,
                X_INEFFECTIVE_CONTROLS                       => M_ineffective_controls,
                X_CONTROLS_VERIFIED                          => M_controls_verified,
                X_OPEN_ISSUES                                => M_open_issues,
                X_PRO_PENDING_CERT_PRCNT                     => M_PRO_PENDING_CERT_PRCNT,
                X_PROCESSES_WITH_ISSUES_PRCNT                => M_PROCESSES_WITH_ISSUES_PRCNT,
                X_ORG_WITH_INEFF_CTRLS_PRCNT                 => M_ORG_WITH_INEFF_CTRLS_PRCNT,
                X_PROC_WITH_INEFF_CTRLS_PRCNT                => M_PROC_WITH_INEFF_CTRLS_PRCNT,
                X_UNMITIGATED_RISKS_PRCNT                    => M_UNMITIGATED_RISKS_PRCNT,
                X_INEFFECTIVE_CTRLS_PRCNT                    => M_INEFFECTIVE_CONTROLS_PRCNT,
                X_OBJ_CONTEXT                                => NULL,
                X_CREATED_BY                                 => g_user_id,
                X_CREATION_DATE                              => SYSDATE,
                X_LAST_UPDATED_BY                            => g_user_id,
                X_LAST_UPDATE_DATE                           => SYSDATE,
                X_LAST_UPDATE_LOGIN                          => g_login_id,
                X_SECURITY_GROUP_ID                          => NULL,
                X_OBJECT_VERSION_NUMBER                      => NULL);

             end loop;


       END IF;--If condition to check if M_TOTAL_NUMBER_OF_PROCESSES is = 0 or null

       elsif P_OBJECT_TYPE = 'ACCOUNT' then

                  M_NATURAL_ACCOUNT_ID := P_ACCOUNT_ID ;
                  M_ACCOUNT_GROUP_ID := P_ACCOUNT_GROUP_ID    ;

                   GetTotalProcesses_for_account(
                      P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                      P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                      P_TOTAL_NUMBER_OF_PROCESSES => M_TOTAL_NUMBER_OF_PROCESSES);

      IF (M_TOTAL_NUMBER_OF_PROCESSES IS NOT NULL OR
          M_TOTAL_NUMBER_OF_PROCESSES <> 0)

       THEN

                   CountProcsCertRecorded_Accnts(
                       P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                       P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                       P_PROCS_IN_CERTIFICATION  => M_PROCS_FOR_CERT_DONE
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE
                       , p_fin_cert_id => M_CERTIFICATION_ID) ;

                   CountProcsEvaluated_Accnts(
                       P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                       P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                       P_PROCS_EVALUATED  => M_PROC_VERIFIED
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                   M_PROC_PENDING_CERTIFICATION := M_TOTAL_NUMBER_OF_PROCESSES - M_PROCS_FOR_CERT_DONE ;

                   CountProcswithIssues_Accounts(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                        P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                        P_PROC_CERTIFIED_WITH_ISSUES  => M_PROC_CERTIFIED_WITH_ISSUES
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE
                       , p_fin_cert_id => M_CERTIFICATION_ID) ;

                   CountOrgsIneffCtrl_Accounts(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                         P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                         P_org_with_ineffective_ctrls =>M_org_with_ineffective_ctrls
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                    CountOrgsEvaluated_accounts(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                        P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                         P_org_evaluated  => M_org_evaluated
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;


                 /* CountOrgswithIssues_Accounts(P_NATURAL_ACCOUNT_ID in number,
                ?  P_org_cert_with_issues OUT  Number,
                   p_start_date in date, p_end_date in date)  ;
                   */

                 CountOrgsCertified_accounts(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                        P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                        P_org_certified =>M_org_certified
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                  CountProcsIneffCtrl_accounts(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                       P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                        P_proc_with_ineffective_ctrls =>  M_proc_with_ineffective_ctrls
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                  CountIneffectiveCtrls_account(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                        P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                        p_ineffective_controls =>M_ineffective_controls
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                  CountUnmittigatedRisk_account(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                         P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                         p_unmitigated_risks =>M_unmitigated_risks
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                  CountRisksVerified_account(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                        P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                         p_risks_verified =>M_risks_verified
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;

                 CountControlsVerified_account(P_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                         P_account_group_id   => M_ACCOUNT_GROUP_ID ,
                         p_controls_verified =>M_controls_verified
                       , p_start_date =>   M_START_DATE
                       , p_end_date => M_END_DATE) ;


                  P_PROC_PENDING_CERTIFICATION  := NVL(M_PROC_PENDING_CERTIFICATION,0);
                  P_TOTAL_NUMBER_OF_PROCESSES   := NVL(M_TOTAL_NUMBER_OF_PROCESSES,0)  ;
                  P_PROC_CERTIFIED_WITH_ISSUES  := NVL(M_PROC_CERTIFIED_WITH_ISSUES,0) ;
                  P_PROC_VERIFIED               := NVL(M_PROC_VERIFIED,0)              ;
                  P_org_with_ineffective_ctrls  := NVL(M_org_with_ineffective_ctrls,0);
                  P_org_certified               := NVL(M_org_certified,0)             ;
                  P_proc_with_ineffective_ctrls := NVL(M_proc_with_ineffective_ctrls,0)  ;
                  P_unmitigated_risks           := NVL(M_unmitigated_risks,0)          ;
                  P_risks_verified              := NVL(M_risks_verified,0)             ;
                  P_ineffective_controls        := NVL(M_ineffective_controls,0)       ;
                  P_controls_verified           := NVL(M_controls_verified,0)          ;
                  P_open_issues                 := NVL(M_open_issues,0)                ;
                  P_PROCS_FOR_CERT_DONE         := nvl(m_PROCS_FOR_CERT_DONE,0);
                  p_org_evaluated               := NVL(M_org_evaluated,0) ;





             for stmnt_child_accs in Get_sub_accs
             loop
                 exit when Get_sub_accs%notfound;

                 M_STATEMENT_GROUP_ID := P_STATEMENT_GROUP_ID ;
                 M_FINANCIAL_STATEMENT_ID := P_FINANCIAL_STATEMENT_ID ;
                 M_FINANCIAL_ITEM_ID := P_FINANCIAL_ITEM_ID;
                 M_ACCOUNT_GROUP_ID  := stmnt_child_accs.ACCOUNT_GROUP_ID;
                 M_NATURAL_ACCOUNT_ID_2 := stmnt_child_accs.NATURAL_ACCOUNT_ID;

                 AMW_FINSTMT_CERT_PVT.compute_values_for_eval_sum
                 (P_CERTIFICATION_ID => M_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => M_FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID ,
                  --P_PARENT_FIN_ITEM_ID => null;
                  P_ACCOUNT_ID         => M_NATURAL_ACCOUNT_ID_2 ,
                  P_ACCOUNT_GROUP_ID   => M_ACCOUNT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => M_FINANCIAL_ITEM_ID,
                  P_OBJECT_TYPE => 'ACCOUNT',
                  P_PROC_PENDING_CERTIFICATION =>
                  M_PROC_PENDING_CERTIFICATION ,
                  P_TOTAL_NUMBER_OF_PROCESSES  =>
                  M_TOTAL_NUMBER_OF_PROCESSES ,
                  P_PROC_CERTIFIED_WITH_ISSUES =>
                  M_PROC_CERTIFIED_WITH_ISSUES ,
                  P_PROC_VERIFIED              =>
                  M_PROC_VERIFIED              ,
                  P_org_with_ineffective_ctrls  =>
                  M_org_with_ineffective_ctrls  ,
                  P_org_certified              =>
                  M_org_certified              ,
                  P_proc_with_ineffective_ctrls  =>
                  M_proc_with_ineffective_ctrls,
                  P_unmitigated_risks          =>
                  M_unmitigated_risks          ,
                  P_risks_verified             =>
                  M_risks_verified             ,
                  P_ineffective_controls       =>
                  M_ineffective_controls    ,
                  P_controls_verified          =>
                  M_controls_verified         ,
                  P_open_issues                =>
                  M_open_issues                ,
                  P_PRO_PENDING_CERT_PRCNT =>
                  M_PRO_PENDING_CERT_PRCNT ,
                  P_PROCESSES_WITH_ISSUES_PRCNT =>
                  M_PROCESSES_WITH_ISSUES_PRCNT,
                  P_ORG_WITH_INEFF_CTRLS_PRCNT =>
                  M_ORG_WITH_INEFF_CTRLS_PRCNT ,
                  P_PROC_WITH_INEFF_CTRLS_PRCNT =>
                  M_PROC_WITH_INEFF_CTRLS_PRCNT,
                  P_UNMITIGATED_RISKS_PRCNT =>
                  M_UNMITIGATED_RISKS_PRCNT ,
                  P_INEFFECTIVE_CONTROLS_PRCNT =>
                  M_INEFFECTIVE_CONTROLS_PRCNT,
                  P_START_DATE  => M_START_DATE ,
                  P_END_DATE   => M_END_DATE,
                  p_PROCS_FOR_CERT_DONE => M_PROCS_FOR_CERT_DONE  ,
                  p_org_evaluated  => M_org_evaluated );


                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                   M_PRO_PENDING_CERT_PRCNT       := (m_PROC_PENDING_CERTIFICATION / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;

                 /* if (m_PROCS_FOR_CERT_DONE is not null and m_PROCS_FOR_CERT_DONE <> 0) then
                   M_PROCESSES_WITH_ISSUES_PRCNT  := (m_PROC_CERTIFIED_WITH_ISSUES / m_PROCS_FOR_CERT_DONE  ) * 100 ;
                 end if; */

                 if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                    M_PROCESSES_WITH_ISSUES_PRCNT  := (m_PROC_CERTIFIED_WITH_ISSUES / m_TOTAL_NUMBER_OF_PROCESSES) * 100 ;
                 end if;

                 if  (m_org_evaluated is not null and m_org_evaluated <> 0) then
                   M_ORG_WITH_INEFF_CTRLS_PRCNT   := (m_org_with_ineffective_ctrls / m_org_evaluated) * 100;
                 end if;

                 /* if (m_PROC_VERIFIED is not null and m_PROC_VERIFIED <> 0)  then
                     M_PROC_WITH_INEFF_CTRLS_PRCNT  := (m_proc_with_ineffective_ctrls / m_PROC_VERIFIED) * 100 ;
                 end if;*/

                if (m_TOTAL_NUMBER_OF_PROCESSES is not null and m_TOTAL_NUMBER_OF_PROCESSES <> 0) then
                     M_PROC_WITH_INEFF_CTRLS_PRCNT  := (m_proc_with_ineffective_ctrls / m_TOTAL_NUMBER_OF_PROCESSES ) * 100 ;
                 end if;

                 if (m_risks_verified is not null and m_risks_verified <> 0)    then
                   M_UNMITIGATED_RISKS_PRCNT      := (m_unmitigated_risks / m_risks_verified) * 100;
                 end if;
                 if (m_controls_verified is not null and m_controls_verified <> 0) then
                   M_INEFFECTIVE_CONTROLS_PRCNT   := (m_ineffective_controls / m_controls_verified) * 100;
                 end if;

                -- insert a KEY ACCOUNT record which will take care of all child accounts

               AMW_FINSTMT_CERT_PVT.insert_fin_cert_eval_sum(
                X_FIN_CERTIFICATION_ID                       => M_CERTIFICATION_ID,
                X_FINANCIAL_STATEMENT_ID                     => M_FINANCIAL_STATEMENT_ID,
                X_FINANCIAL_ITEM_ID                          => M_FINANCIAL_ITEM_ID,
                X_ACCOUNT_GROUP_ID                           => M_ACCOUNT_GROUP_ID      ,
                X_NATURAL_ACCOUNT_ID                         => M_NATURAL_ACCOUNT_ID_2,
                X_OBJECT_TYPE                                => 'ACCOUNT',
                X_PROC_PENDING_CERTIFICATION                 => M_PROC_PENDING_CERTIFICATION,
                X_TOTAL_NUMBER_OF_PROCESSES                  => M_TOTAL_NUMBER_OF_PROCESSES,
                X_PROC_CERTIFIED_WITH_ISSUES                 => M_PROC_CERTIFIED_WITH_ISSUES,
                -- X_PROC_VERIFIED                           => M_PROC_VERIFIED,
                X_PROCS_FOR_CERT_DONE                        => M_PROCS_FOR_CERT_DONE,
                x_proc_evaluated                             => M_PROC_VERIFIED,
                X_ORG_WITH_INEFFECTIVE_CTRLS                 => M_org_with_ineffective_ctrls,
                --X_ORG_CERTIFIED                            => M_org_certified,
                x_orgs_FOR_CERT_DONE                         => M_org_certified,
                x_orgs_evaluated                             => M_org_evaluated,
                X_PROC_WITH_INEFFECTIVE_CTRLS                => M_proc_with_ineffective_ctrls,
                X_UNMITIGATED_RISKS                          => M_unmitigated_risks,
                X_RISKS_VERIFIED                             => M_risks_verified,
                X_INEFFECTIVE_CONTROLS                       => M_ineffective_controls,
                X_CONTROLS_VERIFIED                          => M_controls_verified,
                X_OPEN_ISSUES                                => M_open_issues,
                X_PRO_PENDING_CERT_PRCNT                     => M_PRO_PENDING_CERT_PRCNT,
                X_PROCESSES_WITH_ISSUES_PRCNT                => M_PROCESSES_WITH_ISSUES_PRCNT,
                X_ORG_WITH_INEFF_CTRLS_PRCNT                 => M_ORG_WITH_INEFF_CTRLS_PRCNT,
                X_PROC_WITH_INEFF_CTRLS_PRCNT                => M_PROC_WITH_INEFF_CTRLS_PRCNT,
                X_UNMITIGATED_RISKS_PRCNT                    => M_UNMITIGATED_RISKS_PRCNT,
                X_INEFFECTIVE_CTRLS_PRCNT                    => M_INEFFECTIVE_CONTROLS_PRCNT,
                X_OBJ_CONTEXT                                => NULL,
                X_CREATED_BY                                 => g_user_id,
                X_CREATION_DATE                              => SYSDATE,
                X_LAST_UPDATED_BY                            => g_user_id,
                X_LAST_UPDATE_DATE                           => SYSDATE,
                X_LAST_UPDATE_LOGIN                          => g_login_id,
                X_SECURITY_GROUP_ID                          => NULL,
                X_OBJECT_VERSION_NUMBER                      => NULL);



            end loop;

       END IF;--If condition to check if M_TOTAL_NUMBER_OF_PROCESSES is = 0 or null

       end if;

     end;
 EXCEPTION WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
 --dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';

 RAISE ;
 RETURN;


END compute_values_for_eval_sum;
----------------------------- ********************************** ----------------------
procedure insert_fin_cert_eval_sum(
 X_FIN_CERTIFICATION_ID                       IN         NUMBER,
 X_FINANCIAL_STATEMENT_ID                     IN         NUMBER,
 X_FINANCIAL_ITEM_ID                          IN         NUMBER,
 X_ACCOUNT_GROUP_ID                           IN         NUMBER,
 X_NATURAL_ACCOUNT_ID                         IN         NUMBER,
 X_OBJECT_TYPE                                IN         VARCHAR,
 X_PROC_PENDING_CERTIFICATION                 IN         NUMBER,
 X_TOTAL_NUMBER_OF_PROCESSES                  IN         NUMBER,
 X_PROC_CERTIFIED_WITH_ISSUES                 IN         NUMBER,
 X_PROCS_FOR_CERT_DONE                        IN         NUMBER,
 x_proc_evaluated                             IN         NUMBER,
 X_ORG_WITH_INEFFECTIVE_CTRLS                 IN         NUMBER,
-- X_ORG_CERTIFIED                              IN         NUMBER,
 x_orgs_FOR_CERT_DONE                         IN         NUMBER,
 x_orgs_evaluated                             IN         NUMBER,
 X_PROC_WITH_INEFFECTIVE_CTRLS                IN         NUMBER,
 X_UNMITIGATED_RISKS                          IN         NUMBER,
 X_RISKS_VERIFIED                             IN         NUMBER,
 X_INEFFECTIVE_CONTROLS                       IN         NUMBER,
 X_CONTROLS_VERIFIED                          IN         NUMBER,
 X_OPEN_ISSUES                                IN         NUMBER,
 X_PRO_PENDING_CERT_PRCNT                     IN         NUMBER,
 X_PROCESSES_WITH_ISSUES_PRCNT                IN         NUMBER,
 X_ORG_WITH_INEFF_CTRLS_PRCNT                 IN         NUMBER,
 X_PROC_WITH_INEFF_CTRLS_PRCNT                IN         NUMBER,
 X_UNMITIGATED_RISKS_PRCNT                    IN         NUMBER,
 X_INEFFECTIVE_CTRLS_PRCNT                    IN         NUMBER,
 X_OBJ_CONTEXT                                IN         NUMBER,
 X_CREATED_BY                                 IN         NUMBER,
 X_CREATION_DATE                              IN         DATE,
 X_LAST_UPDATED_BY                            IN         NUMBER,
 X_LAST_UPDATE_DATE                           IN         DATE,
 X_LAST_UPDATE_LOGIN                          IN         NUMBER,
 X_SECURITY_GROUP_ID                          IN         NUMBER,
 X_OBJECT_VERSION_NUMBER                      IN         NUMBER
)
IS begin

DECLARE
M_COUNT NUMBER := 0;
begin
SELECT COUNT(1) INTO M_COUNT FROM amw_fin_cert_eval_sum
        WHERE FIN_CERTIFICATION_ID = X_FIN_CERTIFICATION_ID
        AND FINANCIAL_STATEMENT_ID = X_FINANCIAL_STATEMENT_ID
        AND NVL(FINANCIAL_ITEM_ID,0) = NVL(X_FINANCIAL_ITEM_ID,0)
        AND NVL(NATURAL_ACCOUNT_ID,0)     = NVL(X_NATURAL_ACCOUNT_ID,0)
        AND NVL(ACCOUNT_GROUP_ID,0)       = NVL(X_ACCOUNT_GROUP_ID,0)
        AND OBJECT_TYPE            = X_OBJECT_TYPE;


 IF (M_COUNT is null or M_COUNT = 0) then
insert into amw_fin_cert_eval_sum(
FIN_CERTIFICATION_ID                   ,
FINANCIAL_STATEMENT_ID                 ,
FINANCIAL_ITEM_ID                      ,
NATURAL_ACCOUNT_ID                     ,
ACCOUNT_GROUP_ID                       ,
OBJECT_TYPE                            ,
PROC_PENDING_CERTIFICATION             ,
TOTAL_NUMBER_OF_PROCESSES              ,
PROC_CERTIFIED_WITH_ISSUES             ,
PROCS_FOR_CERT_DONE                   ,
proc_evaluated                        ,
ORG_WITH_INEFFECTIVE_CONTROLS          ,
orgs_FOR_CERT_DONE                    ,
--org_certified                         ,
orgs_evaluated                         ,
PROC_WITH_INEFFECTIVE_CONTROLS         ,
UNMITIGATED_RISKS                      ,
RISKS_VERIFIED                         ,
INEFFECTIVE_CONTROLS                   ,
CONTROLS_VERIFIED                      ,
OPEN_ISSUES                            ,
PRO_PENDING_CERT_PRCNT                 ,
PROCESSES_WITH_ISSUES_PRCNT            ,
ORG_WITH_INEFF_CONTROLS_PRCNT          ,
PROC_WITH_INEFF_CONTROLS_PRCNT         ,
UNMITIGATED_RISKS_PRCNT                ,
INEFFECTIVE_CONTROLS_PRCNT             ,
OBJ_CONTEXT                            ,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
values
(
 X_FIN_CERTIFICATION_ID,
 X_FINANCIAL_STATEMENT_ID,
 X_FINANCIAL_ITEM_ID     ,
 X_NATURAL_ACCOUNT_ID    ,
 X_ACCOUNT_GROUP_ID      ,
 X_OBJECT_TYPE           ,
 X_PROC_PENDING_CERTIFICATION,
 X_TOTAL_NUMBER_OF_PROCESSES ,
 X_PROC_CERTIFIED_WITH_ISSUES,
X_TOTAL_NUMBER_OF_PROCESSES ,
-- X_PROCS_FOR_CERT_DONE  -- was replaced by total processes,
X_TOTAL_NUMBER_OF_PROCESSES , --x_proc_evaluated was commented as the denominator
                              --for Proc with Ineffective Ctrl became total processes
 --x_proc_evaluated      ,
-- X_PROC_VERIFIED not used          ,
 X_ORG_WITH_INEFFECTIVE_CTRLS,
 --X_ORG_CERTIFIED             ,
 x_orgs_FOR_CERT_DONE                     ,
 x_orgs_evaluated                         ,
 X_PROC_WITH_INEFFECTIVE_CTRLS,
 X_UNMITIGATED_RISKS          ,
 X_RISKS_VERIFIED             ,
 X_INEFFECTIVE_CONTROLS       ,
 X_CONTROLS_VERIFIED          ,
 X_OPEN_ISSUES                ,
 round(X_PRO_PENDING_CERT_PRCNT)     ,
 round(X_PROCESSES_WITH_ISSUES_PRCNT),
 round(X_ORG_WITH_INEFF_CTRLS_PRCNT) ,
 round(X_PROC_WITH_INEFF_CTRLS_PRCNT),
 round(X_UNMITIGATED_RISKS_PRCNT)    ,
 round(X_INEFFECTIVE_CTRLS_PRCNT)    ,
 X_OBJ_CONTEXT                ,
 X_CREATED_BY                 ,
 X_CREATION_DATE              ,
 X_LAST_UPDATED_BY            ,
 X_LAST_UPDATE_DATE           ,
 X_LAST_UPDATE_LOGIN          ,
 X_SECURITY_GROUP_ID          ,
 X_OBJECT_VERSION_NUMBER
);

else -- update

  update amw_fin_cert_eval_sum set
  FIN_CERTIFICATION_ID
= X_FIN_CERTIFICATION_ID,
FINANCIAL_STATEMENT_ID
 = X_FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID
 = X_FINANCIAL_ITEM_ID     ,
NATURAL_ACCOUNT_ID
 = X_NATURAL_ACCOUNT_ID,
ACCOUNT_GROUP_ID
 = X_ACCOUNT_GROUP_ID      ,
OBJECT_TYPE
 = X_OBJECT_TYPE           ,
PROC_PENDING_CERTIFICATION
 = X_PROC_PENDING_CERTIFICATION,
TOTAL_NUMBER_OF_PROCESSES
 = X_TOTAL_NUMBER_OF_PROCESSES,
PROC_CERTIFIED_WITH_ISSUES
 = X_PROC_CERTIFIED_WITH_ISSUES,
PROCS_FOR_CERT_DONE
= X_TOTAL_NUMBER_OF_PROCESSES ,
-- X_PROCS_FOR_CERT_DONE  -- was replaced by total processes,
-- = X_PROCS_FOR_CERT_DONE ,
proc_evaluated
= X_TOTAL_NUMBER_OF_PROCESSES , --x_proc_evaluated was commented as the denominator
                              --for Proc with Ineffective Ctrl became total processes
----- = X_proc_evaluated      ,
ORG_WITH_INEFFECTIVE_CONTROLS
 = X_ORG_WITH_INEFFECTIVE_CTRLS,
orgs_FOR_CERT_DONE
 = X_orgs_FOR_CERT_DONE                     ,
orgs_evaluated
 = X_orgs_evaluated                         ,
PROC_WITH_INEFFECTIVE_CONTROLS
= X_PROC_WITH_INEFFECTIVE_CTRLS,
UNMITIGATED_RISKS
 = X_UNMITIGATED_RISKS          ,
RISKS_VERIFIED
 = X_RISKS_VERIFIED             ,
INEFFECTIVE_CONTROLS
 = X_INEFFECTIVE_CONTROLS,
CONTROLS_VERIFIED
 = X_CONTROLS_VERIFIED        ,
OPEN_ISSUES
 = X_OPEN_ISSUES                ,
PRO_PENDING_CERT_PRCNT
 = round(X_PRO_PENDING_CERT_PRCNT),
PROCESSES_WITH_ISSUES_PRCNT
= round(X_PROCESSES_WITH_ISSUES_PRCNT),
ORG_WITH_INEFF_CONTROLS_PRCNT
 = round(X_ORG_WITH_INEFF_CTRLS_PRCNT) ,
PROC_WITH_INEFF_CONTROLS_PRCNT
= round(X_PROC_WITH_INEFF_CTRLS_PRCNT),
UNMITIGATED_RISKS_PRCNT
 = round(X_UNMITIGATED_RISKS_PRCNT)    ,
INEFFECTIVE_CONTROLS_PRCNT
 = round(X_INEFFECTIVE_CTRLS_PRCNT)    ,
OBJ_CONTEXT
 = X_OBJ_CONTEXT                ,
CREATED_BY
 = X_CREATED_BY                 ,
CREATION_DATE
 = X_CREATION_DATE           ,
LAST_UPDATED_BY
 = X_LAST_UPDATED_BY      ,
LAST_UPDATE_DATE
 = X_LAST_UPDATE_DATE     ,
LAST_UPDATE_LOGIN
 = X_LAST_UPDATE_LOGIN    ,
SECURITY_GROUP_ID
 = X_SECURITY_GROUP_ID      ,
OBJECT_VERSION_NUMBER
 = X_OBJECT_VERSION_NUMBER
 WHERE FIN_CERTIFICATION_ID = X_FIN_CERTIFICATION_ID
   AND FINANCIAL_STATEMENT_ID = X_FINANCIAL_STATEMENT_ID
        AND NVL(FINANCIAL_ITEM_ID,0) = NVL(X_FINANCIAL_ITEM_ID,0)
        AND NVL(NATURAL_ACCOUNT_ID,0)     = NVL(X_NATURAL_ACCOUNT_ID,0)
        AND NVL(ACCOUNT_GROUP_ID,0)       = NVL(X_ACCOUNT_GROUP_ID,0)
        AND OBJECT_TYPE            = X_OBJECT_TYPE;
 end if;
end;
 EXCEPTION WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';

 RAISE ;
 RETURN;


END insert_fin_cert_eval_sum;
--------------------------------------- ******************************** ----------------------------
Procedure GetGLPeriodfor_FinCertEvalSum(P_Certification_ID in number, P_start_date out NOCOPY  date, P_end_date out NOCOPY  date)
is
begin
Select
GL_PERIODS.START_DATE ,
GL_PERIODS.END_DATE
into P_start_date, P_end_Date
from
AMW_CERTIFICATION_VL CERTIFICATION,
amw_gl_periods_v GL_PERIODS
WHERE
GL_PERIODS.PERIOD_NAME = CERTIFICATION.CERTIFICATION_PERIOD_NAME
AND GL_PERIODS.PERIOD_SET_NAME = CERTIFICATION.CERTIFICATION_PERIOD_SET_NAME
and CERTIFICATION.OBJECT_TYPE='FIN_STMT'
AND CERTIFICATION.CERTIFICATION_ID = P_Certification_ID;
-- AND GL_PERIODS.PERIOD_SET_NAME = fnd_profile.value('AMW_CALENDAR') ;

 EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));

     g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
     g_retcode := '2';

     RAISE ;
     RETURN;

 WHEN OTHERS then

 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';

 RAISE ;
 RETURN;

END GetGLPeriodfor_FinCertEvalSum;

--------------------------------------- ******************************** ----------------------------
Procedure GetTotalProcesses_for_account(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number,
                                        P_TOTAL_NUMBER_OF_PROCESSES OUT NOCOPY  number)

---- ********************************* Modified on 1/31/04 by knair ---------------------------------
--  Based on the Natural Account ID Passed Computes total number of all the Processes and the child-processes of these
--- Processes that are associated to that Natural Account and its sub-accounts
---***************************************************************************************************
is
begin
 declare
  m_Total_Number_of_Processes number := 0;
  begin

	Select
	Count(1) into P_TOTAL_NUMBER_OF_PROCESSES from
(select  distinct procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
     --(select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =  P_NATURAL_ACCOUNT_ID
--  and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID);

  end;
end GetTotalProcesses_for_account;
-------------------------------------------- *********************** --------------------------------
Procedure CountProcsCertRecorded_Accnts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number,
                                                P_PROCS_IN_CERTIFICATION OUT NOCOPY   Number,
                                                p_start_date in date, p_end_date in date, p_fin_cert_id in number)

is
 begin

--******************* Last Modified on 1/31/04 by knair *********************************************
-- Based on the Natural Account ID Passed Computed the Number Processes and the child-processes of
-- these Processes, for which  Certifications (which are associated to the current Financial Certification,
-- was recorded , that are associated to that Natural Account and its sub-accounts
--***************************************************************************************************
	Select
		    count(1) into P_PROCS_IN_CERTIFICATION
	from
	(
 Select distinct  orgprocess.PROCESS_ID, orgprocess.ORGANIZATION_ID
	FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
	amw_process_org_basicinfo_v orgprocess
	WHERE
	opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_CODE = 'CERTIFICATION' AND
	fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
	fndobject.obj_name = 'AMW_ORG_PROCESS'
 and  opinion.PK2_VALUE in (select PROC_CERT_ID  from AMW_FIN_PROC_CERT_RELAN where FIN_STMT_CERT_ID = p_fin_cert_id)
 and   (opinion.PK3_VALUE = orgprocess.ORGANIZATION_ID
 and       opinion.PK1_VALUE = orgprocess.PROCESS_ID)
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
  --     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =     P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

END CountProcsCertRecorded_Accnts;

-------------------------------------------- *********************** --------------------------------
Procedure  CountProcswithIssues_Accounts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number, P_PROC_CERTIFIED_WITH_ISSUES  OUT NOCOPY   Number,
p_start_date in date, p_end_date in date, p_fin_cert_id in number)  is

--******************* Last Modified on 1/31/04 by knair ---------------------------------------
-- Based on the Natural Account ID Passed Computed the Number Processes and the child-processes
-- of these Processes, for which Certifications (the certification that are associated to the financial
---  certification) with a Not Effective type result was recorded during
-- the given period, that are associated to that Natural Account and its sub-accounts
--************************************************************************************************

begin
Select
	    count(1) INTO P_PROC_CERTIFIED_WITH_ISSUES
from
(
Select distinct  orgprocess.PROCESS_ID, orgprocess.ORGANIZATION_ID
	FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
		amw_process_org_basicinfo_v orgprocess
	WHERE
       (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
where
      opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID
      and  opinion2.PK2_VALUE in
     (select PROC_CERT_ID  from AMW_FIN_PROC_CERT_RELAN where FIN_STMT_CERT_ID = p_fin_cert_id) and
      opinion2.PK1_VALUE = opinion.PK1_VALUE and
	opinion2.PK3_VALUE = opinion.PK3_VALUE
      ) AND
	opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_CODE = 'CERTIFICATION' AND
	fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
	fndobject.obj_name = 'AMW_ORG_PROCESS' and
      opinion.audit_result_CODE <> 'EFFECTIVE')
 and  opinion.PK2_VALUE in
      (select PROC_CERT_ID  from AMW_FIN_PROC_CERT_RELAN where FIN_STMT_CERT_ID = p_fin_cert_id)
 and     (opinion.PK3_VALUE = orgprocess.ORGANIZATION_ID
 and       opinion.PK1_VALUE = orgprocess.PROCESS_ID)
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =    P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =   P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

END CountProcswithIssues_Accounts;

-------------------------------------------- *********************** --------------------------------
Procedure  CountOrgsIneffCtrl_Accounts(P_NATURAL_ACCOUNT_ID in number,P_account_group_id in number,P_org_with_ineffective_ctrls OUT NOCOPY   Number,
p_start_date in date, p_end_date in date)  is

--******************* Last Modified on 1/31/04 by knair ---------------------------------------
-- Based on the Natural Account ID Passed Computes the Organization, for which a Evaluation
-- (Means Not Effective Result) was recorded during the given period, that are associated to that
-- Natural Account and its sub-accounts
--******************* ****************************************************************************

begin
	Select
	    count(1)  into P_org_with_ineffective_ctrls
from (
select distinct   orgprocess.ORGANIZATION_ID
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess
WHERE
  (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE
        --- Commented chekcing whether the opinion date falls within the period as
             ---  per discussion with Say and Bastin on 2/9/04
               ---AND
                 ---- opinion2.AUTHORED_DATE  >= p_start_date and
            -- opinion2.AUTHORED_DATE  <= p_end_date
           ) AND
 opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORGANIZATION'
and opinion.audit_result_CODE <> 'EFFECTIVE'
)
and opinion.PK1_VALUE = orgprocess.ORGANIZATION_ID
and  orgprocess.ORGANIZATION_ID
 in
(select  procRln.ORGANIZATION_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =  P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);
End CountOrgsIneffCtrl_Accounts;
--------------------------------------- ********************************--------------------------------------
Procedure  CountOrgswithIssues_Accounts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number, P_org_cert_with_issues OUT NOCOPY Number,
p_start_date in date, p_end_date in date)  is

--******************* Last Modified on 1/31/04 by knair ---------------------------------------
-- Based on the Natural Account ID Passed Computes the Organization, for which a  Certification with Not
-- Effective result was recorded during the given period, that are associated to that
-- Natural Account and its sub-accounts
--******************* ****************************************************************************

begin
 	Select
      count(1)  into P_org_cert_with_issues
from
 (
select distinct   orgprocess.ORGANIZATION_ID
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess
WHERE
  (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE       AND
              opinion2.AUTHORED_DATE  >= p_start_date and
             opinion2.AUTHORED_DATE  <= p_end_date
           ) AND
 opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'CERTIFICATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORGANIZATION'
and opinion.audit_result_CODE <> 'EFFECTIVE'
)
and opinion.PK1_VALUE = orgprocess.ORGANIZATION_ID
and  orgprocess.ORGANIZATION_ID
 in
(select  procRln.ORGANIZATION_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =  P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

END CountOrgswithIssues_Accounts;

-------------------------------------- ******************************* --------------------------------------
Procedure  CountOrgsCertified_accounts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number, P_org_certified OUT  NOCOPY  Number,
p_start_date in date, p_end_date in date)  is

--******************* Last Modified on 1/31/04 by knair ---------------------------------------
-- Based on the Natural Account ID Passed Computes the Organization, for which a  Certification
-- was recorded during the given period (do not check result as it is the total number of orgs for which
-- a certification was recorded, that are associated to that Natural Account and its sub-accounts
--******************* ****************************************************************************


begin
	Select
		    count(1) into P_org_certified
 		from
		(
select distinct   orgprocess.ORGANIZATION_ID
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess
WHERE
  (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE AND
               opinion2.AUTHORED_DATE  >= p_start_date and
            opinion2.AUTHORED_DATE  <= p_end_date
           ) AND
 opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'CERTIFICATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORGANIZATION'
)
and opinion.PK1_VALUE = orgprocess.ORGANIZATION_ID
and  orgprocess.ORGANIZATION_ID
 in
(select  procRln.ORGANIZATION_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =  P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

END CountOrgsCertified_accounts;
-------------------------------------- ******************************* --------------------------------------
Procedure  CountOrgsEvaluated_accounts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number, P_org_evaluated OUT NOCOPY   Number,
p_start_date in date, p_end_date in date)  is

--******************* Last Modified on 1/31/04 by knair ---------------------------------------
--  the total number of orgs for which
--  are associated to that Natural Account and its sub-accounts
--******************* ****************************************************************************
begin

	Select
	Count(1)
      into P_org_evaluated
    from
(select  distinct procRln.ORGANIZATION_ID  from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =   P_NATURAL_ACCOUNT_ID
--  and acc.account_group_id  =   P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID);

/*---
commented as the Denominbator for the "Org with Ineffective Control" columns is no longer the Total Orgs for which
 an evluation is made but it is the Total Orgs Attached to the Processes which in trun attached to the accounts

	Select
		    count(1) into P_org_evaluated
 		from
		(
select distinct   orgprocess.ORGANIZATION_ID
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess
WHERE
  (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE AND
               ----- **** opinion2.AUTHORED_DATE  >= p_start_date and
               opinion2.AUTHORED_DATE  <= p_end_date
           ) AND
 opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORGANIZATION'
)
and opinion.PK1_VALUE = orgprocess.ORGANIZATION_ID
and  orgprocess.ORGANIZATION_ID
 in
(select  procRln.ORGANIZATION_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =   P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);
--------------------------------*/

END CountOrgsEvaluated_accounts;
--------------------------------------- ******************************* -------------------------------------
Procedure  CountProcsIneffCtrl_accounts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number,
                                        P_proc_with_ineffective_ctrls OUT NOCOPY  Number,
                                        p_start_date in date, p_end_date in date)  is

--******************* Last Modified on 1/31/04 by knair ---------------------------------------
-- Based on the Natural Account ID Passed Computes the Processes and its subprocesses, for which a Evaluation
-- (Means Not Effective Result) was recorded during the given period, that are associated to that
-- Natural Account and its sub-accounts
--******************* ****************************************************************************


begin

Select
    count(1) into P_proc_with_ineffective_ctrls
from (
Select distinct  orgprocess.PROCESS_ID, orgprocess.ORGANIZATION_ID
	FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
		amw_process_org_basicinfo_v orgprocess
	WHERE
       (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
where
      opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID and
      opinion2.PK1_VALUE = opinion.PK1_VALUE and
	  opinion2.PK3_VALUE = opinion.PK3_VALUE
             --- Commented chekcing whether the opinion date falls within the period as
             ---  per discussion with Say and Bastin on 2/9/04
       -- AND
      --- ********opinion2.AUTHORED_DATE  >= p_start_date    and
     -- opinion2.AUTHORED_DATE  <= p_end_date
    ) AND
	opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
	fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
	fndobject.obj_name = 'AMW_ORG_PROCESS' and
      opinion.audit_result_CODE <> 'EFFECTIVE'
            )
      	  	 and     (opinion.PK3_VALUE = orgprocess.ORGANIZATION_ID
 and       opinion.PK1_VALUE = orgprocess.PROCESS_ID)
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =    P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =   P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

END CountProcsIneffCtrl_accounts;
-------------------------------------------------------------------------------------------------------------------
Procedure CountProcsEvaluated_Accnts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number,
P_PROCS_EVALUATED OUT NOCOPY  Number, p_start_date in date, p_end_date in date)


--******************* Last Modified on 1/31/04 by knair ---------------------------------------------------------
-- Based on the Natural Account ID Passed Computed the Number Processes and the child-processes of these Processes,
-- for which an  Evaluation was recorded during the given period, that are associated to that Natural Account and
-- its sub-accounts
--****************************************************************************************************************
is
 begin
	Select
		    count(1) into P_PROCS_EVALUATED from
	(
Select distinct  orgprocess.PROCESS_ID, orgprocess.ORGANIZATION_ID
	FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
		amw_process_org_basicinfo_v orgprocess
	WHERE
       (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
where
        opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID and
        opinion2.PK1_VALUE = opinion.PK1_VALUE and
	  opinion2.PK3_VALUE = opinion.PK3_VALUE AND
        --- ****** opinion2.AUTHORED_DATE  >= p_start_date    and
        opinion2.AUTHORED_DATE  <= p_end_date
      ) AND
	opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
	fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
	fndobject.obj_name = 'AMW_ORG_PROCESS'
     --- *** RESULT IS IRRILEVENT FOR THIS COMPUTATION and opinion.audit_result_CODE <> 'EFFECTIVE'
    )
 and     (opinion.PK3_VALUE = orgprocess.ORGANIZATION_ID
 and       opinion.PK1_VALUE = orgprocess.PROCESS_ID)
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  = P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  = P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

END CountProcsEvaluated_Accnts;
--------------------------------------- ********************************--------------------------------------
Procedure  CountIneffectiveCtrls_account(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number, p_ineffective_controls OUT NOCOPY Number,
p_start_date in date, p_end_date in date)  is

-- ******************************* last updated on 1/31/2004 by knair ********************************************--
---- Based on the Natural Account ID Passed Computed the Number of Controls , for which an  Evaluation
---- was recorded as "Not Effective" during the given period, that are associated to that Natural Account
---- and its sub-accounts
-- ****************************************************************************************************************--

begin

Select
	    count(1) into p_ineffective_controls
from (
select distinct  ctrlassoc.control_id, orgprocess.organization_id
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess,
amw_risk_associations riskassoc,
amw_control_associations ctrlassoc
WHERE
      (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
          where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE and
	           opinion2.PK3_VALUE = opinion.PK3_VALUE
                 ---AND
               --- Commented chekcing whether the opinion date falls within the period as
               ---  per discussion with Say and Bastin on 2/9/04
               --- opinion2.AUTHORED_DATE  >= p_start_date  and
                 ---opinion2.AUTHORED_DATE  <= p_end_date
               )AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_CONTROL' and
   	        opinion.pk1_value = ctrlassoc.control_id
        and opinion.pk3_value = orgprocess.organization_id --??
--        and opinion.pk4_value is null
--        and opinion.pk5_value is null
	and orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
	and riskassoc.risk_association_id = ctrlassoc.pk1
	and ctrlassoc.object_type = 'RISK_ORG'
        and  opinion.audit_result_CODE <> 'EFFECTIVE')
and opinion.pk3_value = orgprocess.ORGANIZATION_ID
--and opinion.pk4_value = orgprocess.PROCESS_ID  and
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
 --           and ( opinion.pk4_value ) in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =   P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);
END CountIneffectiveCtrls_account;
--------------------------------------- ********************************--------------------------------------
Procedure  CountUnmittigatedRisk_account(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number, p_unmitigated_risks OUT NOCOPY  Number,
p_start_date in date, p_end_date in date)  is

-- ******************************* last updated on 1/31/2004 by knair ********************************************--
-- This procedure, based on the Natural Account ID Passed, Computes the Number of Risks, for which an  Evaluation
-- was recorded during the given period with a value equal to  "Not Effective", that are associated to that Natural
-- Account and its sub-accounts
-- ****************************************************************************************************************--

begin

Select
    count(1) into p_unmitigated_risks
from (select distinct  riskassoc.risk_id ,orgprocess.organization_id, orgprocess.Process_ID
FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
	amw_process_org_basicinfo_v orgprocess,
	amw_risk_associations riskassoc
WHERE
      (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE and
             opinion2.PK3_VALUE = opinion.PK3_VALUE and
                opinion2.PK4_VALUE = opinion.PK4_VALUE
             --- Commented chekcing whether the opinion date falls within the period as
             ---  per discussion with Say and Bastin on 2/9/04
               -- and
               -- opinion2.AUTHORED_DATE  >= p_start_date       and
               -- opinion2.AUTHORED_DATE  <= p_end_date
               ) AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_PROCESS_RISK' and
-- 	AccProcs .natural_account_id = P_NATURAL_ACCOUNT_ID and -- from procedure parameter
         opinion.pk1_value = riskassoc.risk_id
       --and opinion.pk3_value = orgprocess.organization_id
       -- and opinion.pk4_value = orgprocess.Process_ID
        and orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
 	and  opinion.audit_result_CODE <> 'EFFECTIVE')
-- and (opinion.pk3_value , opinion.pk4_value )
 and (opinion.pk3_value = orgprocess.ORGANIZATION_ID and opinion.pk4_value = orgprocess.PROCESS_ID ) and
 ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
 --           and ( opinion.pk4_value ) in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
 --     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =  P_NATURAL_ACCOUNT_ID
--  and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

END CountUnmittigatedRisk_account;
--------------------------------------- ********************************--------------------------------------
Procedure  CountRisksVerified_account(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number, p_risks_verified OUT NOCOPY  Number,
p_start_date in date, p_end_date in date)  is

-- ******************************* last updated on 1/31/2004 by knair ********************************************--
-- This procedure, based on the Natural Account ID Passed, Computes the Number of Risks
-- that are associated to that Natural  Account and its sub-accounts
-- ****************************************************************************************************************--


begin

Select
    count(1) into p_risks_verified
from (select distinct  riskassoc.risk_id ,orgprocess.organization_id, orgprocess.Process_ID
FROM
	amw_process_org_basicinfo_v orgprocess,
	amw_risk_associations riskassoc
WHERE
         orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'  AND
 ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =   P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =   P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

/* -- commented as the Denominator for the "Unmitigated Risks" columns is no longer the Total Risk for which an evaluation
 is made but it is the Total Risk Attached to the Processe which in turn attached to the accounts

Select
    count(1) into p_risks_verified
from (select distinct  riskassoc.risk_id ,orgprocess.organization_id, orgprocess.Process_ID
FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
	amw_process_org_basicinfo_v orgprocess,
	amw_risk_associations riskassoc
WHERE
      (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE and
             opinion2.PK3_VALUE = opinion.PK3_VALUE and
                opinion2.PK4_VALUE = opinion.PK4_VALUE
                and
                opinion2.AUTHORED_DATE  >= p_start_date       and
               opinion2.AUTHORED_DATE  <= p_end_date
               ) AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_PROCESS_RISK' and
-------- 	AccProcs .natural_account_id = P_NATURAL_ACCOUNT_ID and -- from procedure parameter
         opinion.pk1_value = riskassoc.risk_id
       --------and opinion.pk3_value = orgprocess.organization_id
       ------ and opinion.pk4_value = orgprocess.Process_ID
        and orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
 	)
--- and (opinion.pk3_value , opinion.pk4_value )
 and (opinion.pk3_value = orgprocess.ORGANIZATION_ID and opinion.pk4_value = orgprocess.PROCESS_ID ) and
 ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
 --           and ( opinion.pk4_value ) in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =  P_NATURAL_ACCOUNT_ID
--  and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

*/

END CountRisksVerified_account;
--------------------------------------- ********************************--------------------------------------
Procedure  CountControlsVerified_account(P_NATURAL_ACCOUNT_ID in number, P_account_group_id in number, p_controls_verified OUT NOCOPY  Number,
p_start_date in date, p_end_date in date)  is

-- ******************************* last updated on 1/31/2004 by knair ********************************************--
-- This procedure, based on the Natural Account ID Passed, Computes the Number of Controls, for which an  Evaluation
-- was recorded during the given period (do not consider the result of evaluation.. this total number of Controls
-- which are evaluated), that are associated to that Natural  Account and its sub-accounts
-- ****************************************************************************************************************--


begin

	SELECT
		    COUNT(1) into p_controls_verified
	FROM
    ( select distinct ctrlassoc.control_id, orgprocess.organization_id
FROM
amw_process_org_basicinfo_v orgprocess,
amw_risk_associations riskassoc,
amw_control_associations ctrlassoc
WHERE
       orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
	and riskassoc.risk_association_id = ctrlassoc.pk1
	and ctrlassoc.object_type = 'RISK_ORG'
  and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
 (select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =   P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =   P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

/* -------------------------------------------------------
-- commented as the Denominator for the "Ineffective Controls" columns is no longer the Total Controls for which an
-- evaluation is made but it is the Total Risk Attached to the Processes which in turn attached to the accounts

	SELECT
		    COUNT(1) into p_controls_verified
	FROM
    (select distinct  ctrlassoc.control_id, orgprocess.organization_id
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess,
amw_risk_associations riskassoc,
amw_control_associations ctrlassoc
WHERE
      (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
          where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE and
	           opinion2.PK3_VALUE = opinion.PK3_VALUE AND
               opinion2.AUTHORED_DATE  >= p_start_date  and
               opinion2.AUTHORED_DATE  <= p_end_date
               )AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_CONTROL' and
   	        opinion.pk1_value = ctrlassoc.control_id
        and opinion.pk3_value = orgprocess.organization_id --??
--        and opinion.pk4_value is null
--        and opinion.pk5_value is null
	and orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
	and riskassoc.risk_association_id = ctrlassoc.pk1
	and ctrlassoc.object_type = 'RISK_ORG')
and opinion.pk3_value = orgprocess.ORGANIZATION_ID
--and opinion.pk4_value = orgprocess.PROCESS_ID  and
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
 --           and ( opinion.pk4_value ) in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs .object_type = 'PROCESS_ORG'  and
	AccProcs .pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--     (select
--    distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH acc.natural_account_id  =   P_NATURAL_ACCOUNT_ID
-- and acc.account_group_id  =  P_account_group_id
--CONNECT BY PRIOR
-- acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id)

		( select distinct acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		  union
		  select distinct acc.natural_account_id
		  from amw_fin_key_accounts_b acc
		  where acc.natural_account_id = p_natural_account_id
		  and acc.account_group_id = p_account_group_id
		)

))
 CONNECT BY
 PRIOR procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);
-------------------------------------------------------  */

End CountControlsVerified_account;
--------------------------------------------------------------------------------------------------------------------
Procedure GetTotalProcesses_for_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_TOTAL_NUMBER_OF_PROCESSES OUT NOCOPY Number
                                        )
--******************************** Last Updated 1/31/04 by knair ************************************---
-- Based on the Natural Account ID Passed Computed all the Processes and the child-processes of these Processes
-- that are associated to that Natural Account and its sub-accounts
--******************************** ************************************************************************---

is begin

 select COUNT(1) into P_TOTAL_NUMBER_OF_PROCESSES  from (
(select  distinct procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
 --(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =  P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =  P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =  P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =  P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =  P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

end GetTotalProcesses_for_finitem;
--------------------------------------------------------------------------------------------------------------------

Procedure CountProcsCertRecorded_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_PROCS_IN_CERTIFICATION OUT NOCOPY Number
                                        , p_start_date in DATE  , p_end_date in DATE, p_fin_cert_id in number)

is begin

--******************************** Last Updated 1/31/04 by knair ************************************---
-- Based on the Financial Item ID Passed Computed the Number Processes and the child-processes of these Processes,
-- for which a  Certifications (process certification that are associated to the financial certification)
-- was recorded during the given period, that are associated to that Fincnail Items
-- and Sub Finacial Items Natural Account and its sub-accounts
---**************************************************************************************************************

select count(1) into P_PROCS_IN_CERTIFICATION from (
 Select distinct  orgprocess.PROCESS_ID, orgprocess.ORGANIZATION_ID
	FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
	amw_process_org_basicinfo_v orgprocess
	WHERE
	opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_CODE = 'CERTIFICATION' AND
	fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
	fndobject.obj_name = 'AMW_ORG_PROCESS'
 and  opinion.PK2_VALUE in (select PROC_CERT_ID  from AMW_FIN_PROC_CERT_RELAN where FIN_STMT_CERT_ID = p_fin_cert_id)
 and     (opinion.PK3_VALUE = orgprocess.ORGANIZATION_ID
 and       opinion.PK1_VALUE = orgprocess.PROCESS_ID)
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in

--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  = P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   = P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =  P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     = P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)

 );


end CountProcsCertRecorded_finitem;

--------------------------------------------------------------------------------------------------------------------
Procedure  CountProcsEvaluated_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_PROCS_EVALUATED   OUT NOCOPY Number
                                        , p_start_date in DATE  , p_end_date in DATE)

--******************************** Last Updated 1/31/04 by knair ************************************---
--Based on the Financial Item ID Passed Computed the Number Processes and the child-processes of these Processes,
--for which an  Evaluation was recorded during the given period, that are associated to that Finncial Items and Sub
--Finacial Items Natural Account and its sub-accounts
---**************************************************************************************************************


is begin

select count(1) into P_PROCS_EVALUATED  from (
 Select distinct  orgprocess.PROCESS_ID, orgprocess.ORGANIZATION_ID
	FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
	amw_process_org_basicinfo_v orgprocess
WHERE
       (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
where
        opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID and
        opinion2.PK1_VALUE = opinion.PK1_VALUE and
	  opinion2.PK3_VALUE = opinion.PK3_VALUE
        --AND
        --opinion2.AUTHORED_DATE  >=  p_start_date
        --and
        --opinion2.AUTHORED_DATE  <=  p_end_date
      ) AND
	opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
	fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
	fndobject.obj_name = 'AMW_ORG_PROCESS' and
      opinion.audit_result_CODE <> 'EFFECTIVE'    )
 and     (opinion.PK3_VALUE = orgprocess.ORGANIZATION_ID
 and       opinion.PK1_VALUE = orgprocess.PROCESS_ID)
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in

--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =  P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =  P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =  P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     = P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =  P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)

);

end CountProcsEvaluated_finitem;
--------------------------------------------------------------------------------------------------------------------
Procedure   CountProcswithIssues_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_PROC_CERTIFIED_WITH_ISSUES  OUT NOCOPY Number
                                        , p_start_date in DATE  , p_end_date in DATE, p_fin_cert_id in number)

--******************************** Last Updated 1/31/04 by knair ************************************---
-- Based on the Financial Item ID Passed Computed the Number Processes and the child-processes of these Processes
-- for which a  Certification (process certification that are associated to the financial certification)
-- with Not Effective result was recorded, that are associated
-- to that Financial Items and Sub Finacial Items  Natural Account  and its sub-accounts
--------------------------------------------------------------------------------------------------------------------

is begin


select count(1) into P_PROC_CERTIFIED_WITH_ISSUES  from (
Select distinct  orgprocess.PROCESS_ID, orgprocess.ORGANIZATION_ID
	FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
		amw_process_org_basicinfo_v orgprocess
	WHERE
       (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
where
      opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID
      and  opinion2.PK2_VALUE in
         (select PROC_CERT_ID  from AMW_FIN_PROC_CERT_RELAN where FIN_STMT_CERT_ID = p_fin_cert_id) and
      opinion2.PK1_VALUE = opinion.PK1_VALUE and
	  opinion2.PK3_VALUE = opinion.PK3_VALUE ) AND
	opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_CODE = 'CERTIFICATION' AND
	fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
	fndobject.obj_name = 'AMW_ORG_PROCESS' and
      opinion.audit_result_CODE <> 'EFFECTIVE')
 and  opinion.PK2_VALUE in (select PROC_CERT_ID  from AMW_FIN_PROC_CERT_RELAN where FIN_STMT_CERT_ID = p_fin_cert_id)
 and     (opinion.PK3_VALUE = orgprocess.ORGANIZATION_ID
 and       opinion.PK1_VALUE = orgprocess.PROCESS_ID)
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in

--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =  P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =  P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =  P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =  P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =  P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

end CountProcswithIssues_finitem;

--------------------------------------------------------------------------------------------------------------------


Procedure   CountOrgsIneffCtrl_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_org_with_ineffective_ctrls  OUT NOCOPY  number
                                        , p_start_date in DATE  , p_end_date in DATE)

--******************************** Last Updated 1/31/04 by knair *************************************************
-- Based on the Finacial Item ID Passed Computes the Organization, for which a Evaluation (Not Effective Result)
-- was recorded during the given period, that are associated to that Financial Items and Sub Finacial Items
-- Natural Account and its sub-accounts
--******************************************************************************************************************
is begin

select count(1) into P_org_with_ineffective_ctrls   from (
select distinct   orgprocess.ORGANIZATION_ID
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess
WHERE
  (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE
               --AND
               --opinion2.AUTHORED_DATE  >= p_start_date
               --and
               --opinion2.AUTHORED_DATE  <=  p_end_date
           ) AND
 opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORGANIZATION' and
opinion.audit_result_CODE <> 'EFFECTIVE'
)
and opinion.PK1_VALUE = orgprocess.ORGANIZATION_ID
and  orgprocess.ORGANIZATION_ID
 in
-- ?
(select  procRln.ORGANIZATION_ID  from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in

--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  = P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   = P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  = P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =  P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)

);


end CountOrgsIneffCtrl_finitem;
--------------------------------------------------------------------------------------------------------------------

Procedure   CountOrgsEvaluated_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number ,   P_org_evaluated  OUT NOCOPY  number
                                        , p_start_date in DATE  , p_end_date in DATE)

--******************************** Last Updated 1/31/04 by knair ************************************---
-- Based on the Financial Iem ID Passed Computed the Number Orgs, for which an  Eavluation was recorded during
-- the given period, that are associated to that Finncial Items and Sub Financial Items  Natural Account and
--its sub-accounts
--------------------------------------------------------------------------------------------------------------


is begin

 select COUNT(1)
  into P_org_evaluated
  from (
(select  distinct procRln.ORGANIZATION_ID  from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =   P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =   P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =   P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =   P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =  P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);







/* ------------------------
select count(1) into P_org_evaluated   from (
select distinct   orgprocess.ORGANIZATION_ID
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess
WHERE
  (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE AND
               opinion2.AUTHORED_DATE  >= p_start_date
               and
               opinion2.AUTHORED_DATE  <= p_end_date
           ) AND
 opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORGANIZATION'
)
and opinion.PK1_VALUE = orgprocess.ORGANIZATION_ID
and  orgprocess.ORGANIZATION_ID
 in
(select  procRln.ORGANIZATION_ID  from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =  P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =  P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =  P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =  P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =  P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);
------------------------------*/

end   CountOrgsEvaluated_finitem;
--------------------------------------------------------------------------------------------------------------------

Procedure   CountOrgsCertified_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number ,    P_org_certified OUT NOCOPY  number
                                        , p_start_date in DATE  , p_end_date in DATE)

--******************************** Last Updated 1/31/04 by knair ************************************---
-- Based on the Financial Iem ID Passed Computed the Number Orgs, for which an  Evlauation was recorded
--during the given period, that are associated to that Finncial Items and Sub Finacial Items  Natural Account
-- and its sub-accounts
--********************************************************************************************************

is begin

select count(1) into P_org_certified  from (
select
 distinct   orgprocess.ORGANIZATION_ID
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess
WHERE
  (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE AND
               opinion2.AUTHORED_DATE  >= p_start_date
               and
            opinion2.AUTHORED_DATE  <=  p_end_date
           ) AND
 opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'CERTIFICATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORGANIZATION'
)
and opinion.PK1_VALUE = orgprocess.ORGANIZATION_ID
and  orgprocess.ORGANIZATION_ID
 in
(select  procRln.ORGANIZATION_ID  from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =  P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =  P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =  P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =  P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =  P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

end CountOrgsCertified_finitem;
--------------------------------------------------------------------------------------------------------------------

Procedure   CountProcsIneffCtrl_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_proc_with_ineffective_ctrls OUT NOCOPY  number
                                        , p_start_date in DATE  , p_end_date in DATE)

--******************************** Last Updated 1/31/04 by knair ************************************---
-- Based on the Financial Item ID ID Passed Computed the Number Processes and the child-processes of these
-- Processes, for which an  Evaluation was recorded as not Effective during the given period, associated
--to to that Financial Items and Sub Finacial Items  that Natural Account and its sub-accounts
--*****************************************************************************************************---
is begin

select count(1) into P_proc_with_ineffective_ctrls from (
Select distinct  orgprocess.PROCESS_ID, orgprocess.ORGANIZATION_ID
	FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
		amw_process_org_basicinfo_v orgprocess
	WHERE
       (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
where
      opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID and
      opinion2.PK1_VALUE = opinion.PK1_VALUE and
	  opinion2.PK3_VALUE = opinion.PK3_VALUE
    --AND
      --opinion2.AUTHORED_DATE  >=  p_start_date
      --and
     -- opinion2.AUTHORED_DATE  <= p_end_date
      ) AND
	opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
	opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
	fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
	fndobject.obj_name = 'AMW_ORG_PROCESS'
    and  opinion.audit_result_CODE <> 'EFFECTIVE'
            )
      	  	 and     (opinion.PK3_VALUE = orgprocess.ORGANIZATION_ID
 and       opinion.PK1_VALUE = orgprocess.PROCESS_ID)
 and ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 IN
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =   P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =   P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =   P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =   P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =   P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)

);

end CountProcsIneffCtrl_finitem;
--------------------------------------------------------------------------------------------------------------------

Procedure   CountIneffectiveCtrls_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number, p_ineffective_controls OUT NOCOPY  number
                                      , p_start_date in DATE  , p_end_date in DATE)

------------------- Last updted on 1/31/04 by knair -----------------------------------------------
-- Based on the Financial Item ID Passed Computed the Number of Controls , for which an
-- Evaluation was recorded as "Not Effective" during the given period,  that Financial Items and
---Sub Finacial Items that Natural Account  and its sub-accounts
--************************************************************************************************
is begin



select count(1) into p_ineffective_controls  from(
select distinct  ctrlassoc.control_id, orgprocess.organization_id
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess,
amw_risk_associations riskassoc,
amw_control_associations ctrlassoc
WHERE
      (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
          where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE and
	           opinion2.PK3_VALUE = opinion.PK3_VALUE

             --- Commented chekcing whether the opinion date falls within the period as
             ---  per discussion with Say and Bastin on 2/9/04

   --AND
   --  opinion2.AUTHORED_DATE  >= p_start_date and
   -- opinion2.AUTHORED_DATE  <= p_end_date
    ) AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_CONTROL' and
-- 	AccProcs .natural_account_id = P_NATURAL_ACCOUNT_ID and -- from procedure parameter
     	        opinion.pk1_value = ctrlassoc.control_id
         and opinion.pk3_value = orgprocess.organization_id --??
 	and orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
	and riskassoc.risk_association_id = ctrlassoc.pk1
	and ctrlassoc.object_type = 'RISK_ORG'
        and  opinion.audit_result_CODE <> 'EFFECTIVE')
        and opinion.pk3_value = orgprocess.ORGANIZATION_ID
         and (opinion.pk3_value = orgprocess.ORGANIZATION_ID)
         --and opinion.pk4_value = orgprocess.PROCESS_ID )
         and
 ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
---  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  = P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   = P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  = P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     = P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID));




end CountIneffectiveCtrls_finitem;
--------------------------------------------------------------------------------------------------------------------
Procedure CountUnmittigatedRisk_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number,  p_unmitigated_risks OUT NOCOPY  number
                                       , p_start_date in DATE  , p_end_date in DATE)
is begin

---************************ Last Edited on 1/31/04 by knair **************************************
-- Based on the Financial Item ID Passed Computed the Number of Risks, for which an  Evaluation was
-- recorded during the given period as "Not Effective", that Financial Items and Sub Finacial Items
-- that Natural Account and its sub-accounts
---************************ ****************************************************************************

select count(1) into p_unmitigated_risks from (
select distinct  riskassoc.risk_id ,orgprocess.organization_id, orgprocess.Process_ID
FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
	amw_process_org_basicinfo_v orgprocess,
	amw_risk_associations riskassoc
WHERE
      (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE and
             opinion2.PK3_VALUE = opinion.PK3_VALUE and
                opinion2.PK4_VALUE = opinion.PK4_VALUE
             --- Commented chekcing whether the opinion date falls within the period as
             ---  per discussion with Say and Bastin on 2/9/04
            --    and
            --   opinion2.AUTHORED_DATE  >= p_start_date and
            --   opinion2.AUTHORED_DATE  <= p_end_date
               ) AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_PROCESS_RISK' and
-- 	AccProcs .natural_account_id = P_NATURAL_ACCOUNT_ID and -- from procedure parameter
         opinion.pk1_value = riskassoc.risk_id
       --and opinion.pk3_value = orgprocess.organization_id
       -- and opinion.pk4_value = orgprocess.Process_ID
        and orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
 	and  opinion.audit_result_CODE <> 'EFFECTIVE'
    )
-- and (opinion.pk3_value , opinion.pk4_value )
 and (opinion.pk3_value = orgprocess.ORGANIZATION_ID and opinion.pk4_value = orgprocess.PROCESS_ID ) and
 ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in

--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  = P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   = P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  = P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     = P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

end  CountUnmittigatedRisk_finitem;
--------------------------------------------------------------------------------------------------------------------

Procedure  CountRisksVerified_finitem( P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                       P_FINANCIAL_ITEM_ID in number,  p_risks_verified OUT NOCOPY  number
                                       , p_start_date in DATE  , p_end_date in DATE)

---************************ Last Edited on 1/31/04 by knair ******************************************************
-- Based on the Financial Item ID Passed Computed the Number of Risks that Financial Items and Sub Finacial Items
-- that Natural Account and its sub-accounts
---****************************************************************************************************************


is begin

select count(1)
 into p_risks_verified
from (
select distinct  riskassoc.risk_id ,orgprocess.organization_id, orgprocess.Process_ID
FROM
 	amw_process_org_basicinfo_v orgprocess,
	amw_risk_associations riskassoc
WHERE
    orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
 and (orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =  P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   = P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  = P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =  P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

/* -- commented as the Denominator for the "Unmitigated Risks" columns is no longer the Total Risk for which an evaluation
 is made but it is the Total Risk Attached to the Processe which in turn attached to the accounts

select count(1) into p_risks_verified from (
select distinct  riskassoc.risk_id ,orgprocess.organization_id, orgprocess.Process_ID
FROM
	AMW_OPINIONS_V opinion,
	AMW_OPINION_TYPES_B  opiniontype,
	FND_OBJECTS fndobject,
	AMW_OBJECT_OPINION_TYPES objectopiniontype,
	amw_process_org_basicinfo_v orgprocess,
	amw_risk_associations riskassoc
WHERE
      (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE and
             opinion2.PK3_VALUE = opinion.PK3_VALUE and
                opinion2.PK4_VALUE = opinion.PK4_VALUE
                and
               opinion2.AUTHORED_DATE  >= p_start_date and
               opinion2.AUTHORED_DATE  <= p_end_date
               ) AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_PROCESS_RISK' and
-- 	AccProcs .natural_account_id = P_NATURAL_ACCOUNT_ID and -- from procedure parameter
         opinion.pk1_value = riskassoc.risk_id
       --and opinion.pk3_value = orgprocess.organization_id
       -- and opinion.pk4_value = orgprocess.Process_ID
        and orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
    )
-- and (opinion.pk3_value , opinion.pk4_value )
 and (opinion.pk3_value = orgprocess.ORGANIZATION_ID and opinion.pk4_value = orgprocess.PROCESS_ID ) and
 ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in

--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  = P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   = P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  = P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     = P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

--------------------------------------------------------------*/

end CountRisksVerified_finitem;
--------------------------------------------------------------------------------------------------------------------


Procedure  CountControlsVerified_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                       P_FINANCIAL_ITEM_ID in number,   p_controls_verified OUT NOCOPY  number
                                       , p_start_date in DATE  , p_end_date in DATE)
is begin

------------------- Last updted on 1/31/04 by knair -----------------------------------------------
-- Based on the Financial Item ID Passed Computed the Number of Controls , for which an
-- Evaluation was recorded during the given period (irrespective of what is the opinion result is as
-- this is a total count  of Controls which were evaluated), ,  that Financial Items and
---Sub Finacial Items  that Natural Account  and its sub-accounts
--************************************************************************************************

select count(1)
 into p_controls_verified
from (
select distinct  ctrlassoc.control_id, orgprocess.organization_id
FROM
amw_process_org_basicinfo_v orgprocess,
amw_risk_associations riskassoc,
amw_control_associations ctrlassoc
WHERE
  orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
	and riskassoc.risk_association_id = ctrlassoc.pk1
	and ctrlassoc.object_type = 'RISK_ORG'
           and
 ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =  P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =  P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =  P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =  P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =  P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID));


/* -- commented as the Denominator for the "Ineff Controls" columns is no longer the Total Controls for which an evaluation
 is made but it is the Total Controls that are Attached to the Process-risks which in turn attached to the accounts


select count(1) into p_controls_verified  from (
select distinct  ctrlassoc.control_id, orgprocess.organization_id
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess,
amw_risk_associations riskassoc,
amw_control_associations ctrlassoc
WHERE
      (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
          where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE and
	           opinion2.PK3_VALUE = opinion.PK3_VALUE AND
          opinion2.AUTHORED_DATE  >= p_start_date and
               opinion2.AUTHORED_DATE  <= p_end_date
    ) AND
opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'EVALUATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORG_CONTROL' and
-- 	AccProcs .natural_account_id = P_NATURAL_ACCOUNT_ID and -- from procedure parameter
     	        opinion.pk1_value = ctrlassoc.control_id
         and opinion.pk3_value = orgprocess.organization_id --??
 	and orgprocess.process_organization_id = riskassoc.pk1
	and riskassoc.object_type = 'PROCESS_ORG'
	and riskassoc.risk_association_id = ctrlassoc.pk1
	and ctrlassoc.object_type = 'RISK_ORG'
        and  opinion.audit_result_CODE <> 'EFFECTIVE')
        and opinion.pk3_value = orgprocess.ORGANIZATION_ID
         and (opinion.pk3_value = orgprocess.ORGANIZATION_ID)
         --and opinion.pk4_value = orgprocess.PROCESS_ID )
         and
 ( orgprocess.ORGANIZATION_ID , orgprocess.PROCESS_ID )
 in
(select  procRln.ORGANIZATION_ID ,procRln.CHILD_PROCESS_ID from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  = P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   = P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  = P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     = P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID = P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID));
------------------------------------------------------------------------- */

end CountControlsVerified_finitem;

--------------------------------------------------------------------------------------------------------------------
Procedure  CountOrgswithIssues_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                       P_FINANCIAL_ITEM_ID in number,   P_org_cert_with_issues OUT NOCOPY number
                                       , p_start_date in DATE  , p_end_date in DATE)

--------------------------- Last updted on 1/31/04 by knair --------------------------------------------------
--Based on the Financial Item ID Passed Computed the Number Orgs, for which a  Certification with Not Effective
-- result was recorded during the given period, that are associated to that Natural Account and its sub-accounts
--**************************************************************************************************************
is begin
select count(1) into P_org_cert_with_issues  from (
select distinct   orgprocess.ORGANIZATION_ID
FROM
AMW_OPINIONS_V opinion,
AMW_OPINION_TYPES_B  opiniontype,
FND_OBJECTS fndobject,
AMW_OBJECT_OPINION_TYPES objectopiniontype,
amw_process_org_basicinfo_v orgprocess
WHERE
  (opinion.AUTHORED_DATE in
      	(Select
    		MAX(opinion2.AUTHORED_DATE)
       	 from
                       AMW_OPINIONS_V opinion2
         where
               opinion.OBJECT_OPINION_TYPE_ID = opinion2.OBJECT_OPINION_TYPE_ID AND
               opinion2.PK1_VALUE = opinion.PK1_VALUE AND
               opinion2.AUTHORED_DATE  >=  p_start_date
               and
            opinion2.AUTHORED_DATE  <=  p_end_date
           ) AND
 opinion.OBJECT_OPINION_TYPE_ID = objectopiniontype.OBJECT_OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_ID = objectopiniontype.OPINION_TYPE_ID AND
opiniontype.OPINION_TYPE_CODE = 'CERTIFICATION' AND
fndobject.OBJECT_ID = objectopiniontype.OBJECT_ID AND
fndobject.obj_name = 'AMW_ORGANIZATION'
and opinion.audit_result_CODE <> 'EFFECTIVE'
)
and opinion.PK1_VALUE = orgprocess.ORGANIZATION_ID
and  orgprocess.ORGANIZATION_ID
  in
(select  procRln.ORGANIZATION_ID  from Amw_Process_Org_Relations procRln
  START WITH ((procRln.CHILD_PROCESS_ID , procRln.ORGANIZATION_ID) in
  ( select orgprocess2.PROCESS_ID , orgprocess2.ORGANIZATION_ID from 	amw_process_org_basicinfo_v orgprocess2,
	Amw_acct_associations AccProcs where AccProcs.object_type = 'PROCESS_ORG'  and
	AccProcs.pk1= orgprocess2.PROCESS_ORGANIZATION_ID
     and AccProcs.natural_account_id in
--(select distinct(acc.natural_account_id)
-- from AMW_FIN_KEY_ACCOUNTS_B acc
--  START WITH ( (acc.natural_account_id, acc.account_group_id) in
--  (select finkeyacc.NATURAL_ACCOUNT_ID,finkeyacc.account_group_id from   AMW_FIN_ITEMS_KEY_ACC finkeyacc
--where
--     finkeyacc.STATEMENT_GROUP_ID  =   P_STATEMENT_GROUP_ID
--  and finkeyacc.FINANCIAL_STATEMENT_ID   =   P_FINANCIAL_STATEMENT_ID
-- and finkeyacc.FINANCIAL_ITEM_ID    IN  (select
--      distinct(stmtitem.FINANCIAL_ITEM_ID )
--   from AMW_FIN_STMNT_ITEMS_B stmtitem
--        START WITH (stmtitem.FINANCIAL_ITEM_ID  =   P_FINANCIAL_ITEM_ID
--  and stmtitem.STATEMENT_GROUP_ID     =   P_STATEMENT_GROUP_ID
--  and stmtitem.FINANCIAL_STATEMENT_ID =   P_FINANCIAL_STATEMENT_ID
--  )
--  CONNECT BY PRIOR
--    stmtitem.FINANCIAL_ITEM_ID  = stmtitem.PARENT_FINANCIAL_ITEM_ID
--and PRIOR stmtitem.STATEMENT_GROUP_ID = stmtitem.STATEMENT_GROUP_ID
--and PRIOR stmtitem.FINANCIAL_STATEMENT_ID = stmtitem.FINANCIAL_STATEMENT_ID)
--)
--)
-- CONNECT BY PRIOR
--acc.natural_account_id = acc.parent_natural_account_id
--                                               and PRIOR
--acc.account_group_id = acc.account_group_id) -- end of acc

( select distinct acc.child_natural_account_id
  from amw_fin_key_acct_flat acc
  where ( acc.parent_natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
  union
  select distinct acc.natural_account_id
  from amw_fin_key_accounts_b acc
  where ( acc.natural_account_id, acc.account_group_id ) in
             ( select finkeyacc.natural_account_id, finkeyacc.account_group_id
               from amw_fin_items_key_acc finkeyacc
               where finkeyacc.statement_group_id = p_statement_group_id
               and finkeyacc.financial_statement_id = p_financial_statement_id
               and finkeyacc.financial_item_id in
                 ( select distinct item.child_financial_item_id
		   from amw_fin_item_flat item
		   where item.parent_financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
		   union
		   select distinct item.financial_item_id
		   from amw_fin_stmnt_items_b item
		   where item.financial_item_id = p_financial_item_id
		   and item.statement_group_id = p_statement_group_id
		   and item.financial_statement_id = p_financial_statement_id
                 )
              )
)

)
)
--) --?
 CONNECT BY PRIOR
    procRln.ORGANIZATION_ID = procRln.ORGANIZATION_ID
    and PRIOR procRln.CHILD_PROCESS_ID = procRln.PARENT_PROCESS_ID)
);

end CountOrgswithIssues_finitem;


--------------------------------------- End of Block of Code Added by Krishnan  ---------------------------------------

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Populate_Fin_Stmt_Cert_Sum                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  This procedure is called by the concurrent program.                      |
 |  This procedure will call 4 sub requests to synchronize the Financial     |
 |  Statement Certification Data.                                            |
 |                                                                           |
 | SCOPE -                                                                   |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |    p_certification_id : The Certification id
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by yreddy - 03-FEB-2004                    |
 |                                                                           |
 +===========================================================================*/
PROCEDURE  Populate_Fin_Stmt_Cert_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
)
IS

l_request_id            NUMBER;
l_msg                   VARCHAR2(2000);
l_reqdata               VARCHAR2(240);

BEGIN
  fnd_file.put_line (fnd_file.LOG,'Certification Id :' || p_certification_id);



  l_reqdata := FND_CONC_GLOBAL.request_data;
  IF (l_reqdata is NOT NULL) THEN
     return;
  END IF;
  l_reqdata := 1;


---comment out because we have to obey a certain sequence to populate the summary tables in amw.d---
--so remove 3 CM request and left one ----
  /* Sub Request for Process Summary */
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW',
                                             'FCPROSUM',
                                             null,
                                             null,
                                             TRUE,
                                             to_char(p_certification_id));
  IF l_request_id = 0 THEN
    l_msg:=FND_MESSAGE.GET;
    fnd_file.put_line (fnd_file.LOG,l_msg);
  ELSE
    fnd_file.put_line (fnd_file.LOG,'Submitted Request for Process Summary :' || l_request_id );
  END IF;

  /*********************
  ----Sub Request for Financial Item Summary --
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW',
                                             'FSIEVLSUM',
                                             null,
                                             null,
                                             TRUE,
                                             to_char(p_certification_id));
  IF l_request_id = 0 THEN
    l_msg:=FND_MESSAGE.GET;
    fnd_file.put_line (fnd_file.LOG,l_msg);
  ELSE
    fnd_file.put_line (fnd_file.LOG,'Submitted Request for Financial Item Summary :' || l_request_id );
  END IF;


  ---Sub Request for Dashboard Summary --
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW',
                                             'FSDASHSUM',
                                             null,
                                             null,
                                             TRUE,
                                             to_char(p_certification_id));
  IF l_request_id = 0 THEN
    l_msg:=FND_MESSAGE.GET;
    fnd_file.put_line (fnd_file.LOG,l_msg);
  ELSE
    fnd_file.put_line (fnd_file.LOG,'Submitted Request for Dashboard Summary :' || l_request_id );
  END IF;


  ---Sub Request for Organization Summary ---
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW',
                                             'FCORGSUM',
                                             null,
                                             null,
                                             TRUE,
                                             to_char(p_certification_id));
  IF l_request_id = 0 THEN
    l_msg:=FND_MESSAGE.GET;
    fnd_file.put_line (fnd_file.LOG,l_msg);
  ELSE
    fnd_file.put_line (fnd_file.LOG,'Submitted Request for Organization Summary :' || l_request_id );
  END IF;

**********************/



  FND_CONC_GLOBAL.set_req_globals(conc_status       => 'PAUSED',
                                   request_data      => l_reqdata);
  COMMIT;


EXCEPTION
     WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Fin_Stmt_Cert_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
         retcode := FND_API.G_RET_STS_UNEXP_ERROR;

END Populate_Fin_Stmt_Cert_Sum;



END AMW_FINSTMT_CERT_PVT;

/
