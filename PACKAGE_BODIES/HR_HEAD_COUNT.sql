--------------------------------------------------------
--  DDL for Package Body HR_HEAD_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HEAD_COUNT" AS
/* $Header: perhdcnt.pkb 120.0.12010000.2 2008/08/06 09:32:04 ubhat ship $ */

--
function get_rev_start_val(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_start_val);
exception
when others then
  return (0);
end;
--
function get_nonrev_start_val(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_start_val);
exception
when others then
  return (0);
end;
--
function get_rev_perm(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_perm);
exception
when others then
  return (0);
end;
--
function get_nonrev_perm(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_perm);
exception
when others then
  return (0);
end;
--
function get_rev_cont(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_cont);
exception
when others then
  return (0);
end;
--
function get_nonrev_cont(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_cont);
exception
when others then
  return (0);
end;
--
function get_rev_temp(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_temp);
exception
when others then
  return (0);
end;
--
function get_nonrev_temp(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_temp);
exception
when others then
  return (0);
end;
--
function get_rev_cur_nh(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_cur_nh);
exception
when others then
  return (0);
end;
--
function get_nonrev_cur_nh(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_cur_nh);
exception
when others then
  return (0);
end;
--
function get_rev_nh(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_nh);
exception
when others then
  return (0);
end;
--
function get_nonrev_nh(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_nh);
exception
when others then
  return (0);
end;
--
function get_rev_transfer_in(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_transfer_in);
exception
when others then
  return (0);
end;
--
function get_nonrev_transfer_in(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_transfer_in);
exception
when others then
  return (0);
end;
--
function get_rev_transfer_out(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_transfer_out);
exception
when others then
  return (0);
end;
--
function get_nonrev_transfer_out(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_transfer_out);
exception
when others then
  return (0);
end;
--
function get_rev_open_offers(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_open_offers);
exception
when others then
  return (0);
end;
--
function get_nonrev_open_offers(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_open_offers);
exception
when others then
  return (0);
end;
--
function get_rev_accepted_offers(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_accepted_offers);
exception
when others then
  return (0);
end;
--
function get_nonrev_accepted_offers(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_accepted_offers);
exception
when others then
  return (0);
end;
--
function get_rev_vacant_FTE(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_vacant_FTE);
exception
when others then
  return (0);
end;
--
function get_nonrev_vacant_FTE(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_vacant_FTE);
exception
when others then
  return (0);
end;
--
function get_rev_vol_term(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_vol_term);
exception
when others then
  return (0);
end;
--
function get_nonrev_vol_term(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_vol_term);
exception
when others then
  return (0);
end;
--
function get_rev_invol_term(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_invol_term);
exception
when others then
  return (0);
end;
--
function get_nonrev_invol_term(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_invol_term);
exception
when others then
  return (0);
end;
--
function get_rev_cur_term(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_cur_term);
exception
when others then
  return (0);
end;
--
function get_nonrev_cur_term(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_cur_term);
exception
when others then
  return (0);
end;
--
function get_rev_change(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_end_val-HQOrgData(p_org_structure_element_id).rev_start_val);
exception
when others then
  return (0);
end;
--
function get_nonrev_change(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_end_val-HQOrgData(p_org_structure_element_id).nonrev_start_val);
exception
when others then
  return (0);
end;
--
function get_rev_end_val(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).rev_end_val);
exception
when others then
  return (0);
end;
--
function get_nonrev_end_val(p_org_structure_element_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_org_structure_element_id).nonrev_end_val);
exception
when others then
  return (0);
end;
--
function get_rev_pct_change(p_org_structure_element_id NUMBER) return NUMBER is
begin
--Changes for bug 6124652 starts here
if (HQOrgData(p_org_structure_element_id).rev_start_val > 0) then
--Changes for bug 6124652 ends here
	return(100*(HQOrgData(p_org_structure_element_id).rev_end_val-HQOrgData(p_org_structure_element_id).rev_start_val)/ HQOrgData(p_org_structure_element_id).rev_start_val);
--Changes for bug 6124652 starts here
else
	return(100*(HQOrgData(p_org_structure_element_id).rev_end_val-HQOrgData(p_org_structure_element_id).rev_start_val));
end if;
--Changes for bug 6124652 ends here
exception
when zero_divide then
  return (0);
when others then
  return (0);
end;
--
function get_nonrev_pct_change(p_org_structure_element_id NUMBER) return NUMBER is
begin
--Changes for bug 6124652 starts here
if (HQOrgData(p_org_structure_element_id).nonrev_start_val > 0) then
--Changes for bug 6124652 ends here
	return(100*(HQOrgData(p_org_structure_element_id).nonrev_end_val-HQOrgData(p_org_structure_element_id).nonrev_start_val)/ HQOrgData(p_org_structure_element_id).nonrev_start_val);
else
--Changes for bug 6124652 starts here
    return(100*(HQOrgData(p_org_structure_element_id).nonrev_end_val-HQOrgData(p_org_structure_element_id).nonrev_start_val));
end if;
--Changes for bug 6124652 ends here
exception
when zero_divide then
  return (0);
when others then
  return (0);
end;
--
--

procedure populate_headcount_table
( P_BUSINESS_GROUP_ID 		IN NUMBER
, P_TOP_ORGANIZATION_ID 	IN NUMBER
, P_ORGANIZATION_STRUCTURE_ID	IN NUMBER
, P_BUDGET 			IN VARCHAR2
, P_ROLL_UP 			IN VARCHAR2
, P_REPORT_DATE_FROM 		IN DATE
, P_REPORT_DATE_TO 		IN DATE
, P_REPORT_DATE			IN DATE
, P_INCLUDE_ASG_TYPE		IN VARCHAR2
, P_INCLUDE_TOP_ORG		IN VARCHAR2
, P_WORKER_TYPE			IN VARCHAR2
, P_DAYS_PRIOR_TO_END_DATE	IN NUMBER
, P_JOB_CATEGORY		IN VARCHAR2 default 'RG'
)
is

cursor	get_org_structure_version
(P_ORGANIZATION_STRUCTURE_ID	NUMBER
,P_REPORT_DATE_FROM			DATE
,P_REPORT_DATE_TO			DATE)
is
   select posv.org_structure_version_id
	 ,posv.date_from date_from
	 ,nvl(posv.date_to,to_date('31/12/4712','DD/MM/YYYY')) date_to
   from   per_org_structure_versions posv
   where  posv.organization_structure_id = P_ORGANIZATION_STRUCTURE_ID
   and 	 (P_REPORT_DATE_FROM between posv.date_from and
	  nvl(posv.date_to,to_date('31/12/4712','DD/MM/YYYY'))
         or posv.date_from between P_REPORT_DATE_FROM and P_REPORT_DATE_TO)
   order by   	 posv.org_structure_version_id
		,posv.date_from
		,posv.date_to;

cursor    get_org_structure_element
(P_ORG_STRUCTURE_VERSION_ID	NUMBER
,P_TOP_ORGANIZATION_ID		NUMBER)
is
   select ose.org_structure_element_id
         ,ose.organization_id_child organization_id
   from   per_org_structure_elements ose
   where  ose.org_structure_version_id +0    = P_ORG_STRUCTURE_VERSION_ID
   and    ose.organization_id_parent         = P_TOP_ORGANIZATION_ID
   order by	ose.organization_id_child;

cursor	get_organizations
( P_ORG_STRUCTURE_VERSION_ID  NUMBER
, P_ORGANIZATION_ID  	      NUMBER
, P_ROLL_UP 		      VARCHAR2)
is
   select ose.organization_id_child organization_id
   from   per_org_structure_elements ose
   where  ose.org_structure_version_id +0  	= P_ORG_STRUCTURE_VERSION_ID
   and	  P_ROLL_UP				= 'Y'
   connect by prior ose.organization_id_child 	= ose.organization_id_parent
   and    ose.org_structure_version_id  	= P_ORG_STRUCTURE_VERSION_ID
   start  with ose.organization_id_parent 	= P_ORGANIZATION_ID
   and    ose.org_structure_version_id  	= P_ORG_STRUCTURE_VERSION_ID
   UNION
   select P_ORGANIZATION_ID organization_id
   from	  dual
   where  P_ROLL_UP                          = 'Y'
   UNION
   select P_ORGANIZATION_ID organization_id
   from	  dual
   where  P_ROLL_UP                          = 'N';

--bug 6124652 starts here
cursor	get_assignment_start_end_fte
(P_EFFECTIVE_DATE	  DATE
,P_ORGANIZATION_ID_CHILD  NUMBER
,P_BUSINESS_GROUP_ID	  NUMBER
,P_WORKER_TYPE            VARCHAR2
,P_INCLUDE_ASG_TYPE       VARCHAR2
)
is
   select  paf.assignment_id
          ,paf.job_id
          ,paf.effective_start_date
          ,paf.assignment_type
   from    per_all_assignments_f        paf
          ,per_assignment_status_types  past
   where   paf.organization_id     =    P_ORGANIZATION_ID_CHILD
   and     P_EFFECTIVE_DATE  between paf.effective_start_date
                                 and paf.effective_end_date
   and     paf.assignment_status_type_id = past.assignment_status_type_id
   and     (
           (P_WORKER_TYPE IN ('E','B')
           and paf.assignment_type = 'E'
           and (
              (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_ASSIGN')
           OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_ASSIGN')
           OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_ASSIGN',
                                                                       'SUSP_ASSIGN'))
               )
           )
           OR
           (P_WORKER_TYPE IN ('C','B')
           and paf.assignment_type =  'C'
           and (
              (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_CWK')
           OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_CWK_ASG')
           OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_CWK',
                                                                       'SUSP_CWK_ASG'))
              )
           )
           );
--bug 6124652 ends here
cursor	get_assignment_start_end
(--bug 6124652 starts here
--P_EFFECTIVE_DATE	  DATE
P_START_DATE	  DATE
,P_END_DATE	  DATE
--bug 6124652 ends here
,P_ORGANIZATION_ID_CHILD  NUMBER
,P_BUSINESS_GROUP_ID	  NUMBER
,P_WORKER_TYPE            VARCHAR2
,P_INCLUDE_ASG_TYPE       VARCHAR2
)
is
   select  paf.assignment_id
          ,paf.job_id
          ,paf.effective_start_date
--bug 6124652 starts here
          ,paf.effective_end_date
--bug 6124652 ends here
          ,paf.assignment_type
   from    per_all_assignments_f        paf
          ,per_assignment_status_types  past
   where   paf.organization_id     =    P_ORGANIZATION_ID_CHILD
--bug 6124652 starts here
--   and     P_EFFECTIVE_DATE  between paf.effective_start_date
--                                 and paf.effective_end_date
and ((P_START_DATE <= paf.effective_start_date
                                 and paf.effective_end_date <=P_END_DATE)
or( P_START_DATE  between paf.effective_start_date
                                 and paf.effective_end_date)
or( P_END_DATE  between paf.effective_start_date
                                 and paf.effective_end_date)
          )
--bug 6124652 ends here
   and     paf.assignment_status_type_id = past.assignment_status_type_id
   and     (
           (P_WORKER_TYPE IN ('E','B')
           and paf.assignment_type = 'E'
           and (
              (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_ASSIGN')
           OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_ASSIGN')
           OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_ASSIGN',
                                                                       'SUSP_ASSIGN'))
               )
           )
           OR
           (P_WORKER_TYPE IN ('C','B')
           and paf.assignment_type =  'C'
           and (
              (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_CWK')
           OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_CWK_ASG')
           OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_CWK',
                                                                       'SUSP_CWK_ASG'))
              )
           )
           );


cursor	get_assignment
( P_DATE_FROM               DATE
, P_DATE_TO                 DATE
, P_ORGANIZATION_ID_CHILD   NUMBER
, P_BUSINESS_GROUP_ID       NUMBER
, P_WORKER_TYPE             VARCHAR2
, P_INCLUDE_ASG_TYPE        VARCHAR2
)
is
   select paf.assignment_id
         ,paf.job_id
         ,paf.effective_start_date
         ,paf.assignment_type
   from   per_all_assignments_f           paf
         ,per_assignment_status_types     past
   where  paf.organization_id           = P_ORGANIZATION_ID_CHILD
--Bug 6124652 starts here
--   and    paf.effective_start_date     <= P_DATE_FROM
   and     P_DATE_FROM  between paf.effective_start_date
                                 and paf.effective_end_date
--Bug 6124652 ends here
   and    paf.assignment_status_type_id = past.assignment_status_type_id
   and    P_DATE_TO <= (select max(paf1.effective_end_date)
                        from   per_all_assignments_f          paf1
                              ,per_assignment_status_types    past1
                        where  paf.assignment_id              = paf1.assignment_id
                        and    paf1.assignment_status_type_id = past1.assignment_status_type_id
                        and    past.per_system_status         = past1.per_system_status)
   and    (
          (P_WORKER_TYPE IN ('E','B')
          and paf.assignment_type = 'E'
          and (
             (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_ASSIGN')
          OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_ASSIGN')
          OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_ASSIGN',
                				                      'SUSP_ASSIGN'))
             )
           )
           OR
           (P_WORKER_TYPE IN ('C','B')
           and paf.assignment_type =  'C'
           and (
              (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_CWK')
           OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_CWK_ASG')
           OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_CWK',
               				                               'SUSP_CWK_ASG'))
               )
           )
           );

cursor	get_open_offers
( P_DATE_FROM			DATE
, P_DATE_TO			DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
   select paf.assignment_id
         ,paf.job_id
         ,paf.effective_start_date
   from   per_all_assignments_f 	paf
         ,per_assignment_status_types 	past
   where  paf.organization_id 	= 	p_organization_id_child
   -- and paf.business_group_id	=	P_BUSINESS_GROUP_ID
   and	  paf.assignment_type	= 	'A'
   and	  paf.effective_start_date between P_DATE_FROM and P_DATE_TO
   and	  paf.assignment_status_type_id = past.assignment_status_type_id
   and	  past.per_system_status 	= 'OFFER';

cursor	get_accepted_offers
( P_DATE_FROM			DATE
, P_DATE_TO			DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
   select paf.assignment_id
         ,paf.job_id
         ,paf.effective_start_date
   from   per_all_assignments_f 		paf,
   	  per_assignment_status_types 	past
   where  paf.organization_id 		= 	p_organization_id_child
   -- and paf.business_group_id		=	P_BUSINESS_GROUP_ID
   and	paf.assignment_type		= 	'A'
   and	paf.effective_start_date between P_DATE_FROM and P_DATE_TO
   and	paf.assignment_status_type_id 	= past.assignment_status_type_id
   and	past.per_system_status 		= 'ACCEPTED';

cursor get_requisitions
(P_BUSINESS_GROUP_ID     NUMBER,
 P_ORGANIZATION_ID_CHILD NUMBER,
 P_BUDGET                VARCHAR2,
 P_DATE_TO               DATE)
is
   select vac.job_id,
          vac.BUDGET_MEASUREMENT_VALUE,
          vac.NUMBER_OF_OPENINGS
   from   per_vacancies vac
   	 ,per_requisitions req
   where  vac.organization_id          = P_ORGANIZATION_ID_CHILD
   --and  vac.business_group_id        = P_BUSINESS_GROUP_ID
   and    vac.BUDGET_MEASUREMENT_TYPE  = P_BUDGET
   and    vac.REQUISITION_ID           = req.REQUISITION_ID
   and    req.date_from                < P_DATE_TO
   and    nvl(req.date_to,to_date('31/12/4712','DD/MM/YYYY'))
   				       > P_DATE_TO;

cursor	get_terminations
( P_DATE_FROM			DATE
, P_DATE_TO			DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
   select pos.leaving_reason
         ,pos.actual_termination_date
         ,paf.job_id
         ,paf.assignment_id
   from   per_periods_of_service pos
         ,per_all_assignments_f  paf
   where  pos.date_start          <= P_DATE_FROM
   and    pos.actual_termination_date is not null
   and    pos.actual_termination_date between P_DATE_FROM
                                          and P_DATE_TO
   and    pos.period_of_service_id = paf.period_of_service_id
   and    paf.effective_end_date   = pos.actual_termination_date
   and    paf.organization_id      = P_ORGANIZATION_ID_CHILD
   order  by paf.assignment_id ;


cursor	get_cur_terminations
( P_DATE_FROM			DATE
, P_CUR_DATE_FROM		DATE
, P_CUR_DATE_TO			DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
   select pos.leaving_reason
         ,pos.actual_termination_date
         ,paf.job_id
         ,paf.assignment_id
   from   per_periods_of_service pos
         ,per_all_assignments_f  paf
   where  pos.date_start          <= P_DATE_FROM
   and    pos.actual_termination_date is not null
   and    pos.actual_termination_date between
                  P_CUR_DATE_FROM and P_CUR_DATE_TO
   and    pos.period_of_service_id = paf.period_of_service_id
   and    paf.effective_end_date   = pos.actual_termination_date
   and    paf.organization_id      = P_ORGANIZATION_ID_CHILD
   order  by paf.assignment_id ;

cursor	get_terminations_cwk
( P_DATE_FROM			DATE
, P_DATE_TO			DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
   select pop.termination_reason
         ,pop.actual_termination_date
         ,paf.job_id
         ,paf.assignment_id
   from   per_periods_of_placement       pop
         ,per_all_assignments_f  paf
   where  pop.date_start          <= P_DATE_FROM
   and    pop.actual_termination_date is not null
   and    pop.actual_termination_date between P_DATE_FROM
                                          and P_DATE_TO
   and    pop.date_start           = paf.period_of_placement_date_start
   and    pop.person_id            = paf.person_id
   and    paf.effective_end_date   = pop.actual_termination_date
   and    paf.assignment_type      = 'C'
   and    paf.organization_id      = P_ORGANIZATION_ID_CHILD
   order  by paf.assignment_id;


cursor	get_cur_terminations_cwk
( P_DATE_FROM			DATE
, P_CUR_DATE_FROM		DATE
, P_CUR_DATE_TO			DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
   select pop.termination_reason
         ,pop.actual_termination_date
         ,paf.job_id
         ,paf.assignment_id
   from   per_periods_of_placement pop
         ,per_all_assignments_f    paf
   where  pop.date_start          <= P_DATE_FROM
   and    pop.actual_termination_date is not null
   and    pop.actual_termination_date between P_CUR_DATE_FROM
                                          and P_CUR_DATE_TO
   and    pop.date_start = paf.period_of_placement_date_start
   and    pop.person_id  = paf.person_id
   and    paf.effective_end_date   = pop.actual_termination_date
   and    paf.assignment_type      = 'C'
   and    paf.organization_id      = P_ORGANIZATION_ID_CHILD
   order  by paf.assignment_id;

/*
cursor c_get_PerType_formula
(p_business_group_id NUMBER )
is
select formula_id
from   ff_formulas_f
where  p_business_group_id = business_group_id+0
and    trunc(sysdate) between effective_start_date and effective_end_date
and    formula_name = 'HR_PERSON_TYPE'
and    formula_type_id = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID('Oracle Payroll');

cursor c_get_tmplt_PerType_formula is
select formula_id
from   ff_formulas_f
where  business_group_id+0 is null
and    trunc(sysdate) between effective_start_date and effective_end_date
and    formula_name = 'HR_PERSON_TYPE_TEMPLATE'
and    formula_type_id = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID('Oracle Payroll');

cursor c_get_term_formula
(p_business_group_id NUMBER )
is
select formula_id
from   ff_formulas_f
where  business_group_id+0 = p_business_group_id
and    trunc(sysdate) between effective_start_date and effective_end_date
and    formula_name = 'HR_MOVE_TYPE'
and    formula_type_id = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID('Oracle Payroll');

cursor c_get_tmplt_term_formula is
select formula_id
from   ff_formulas_f
where  business_group_id+0 is null
and    trunc(sysdate) between effective_start_date and effective_end_date
and    formula_name = 'HR_MOVE_TYPE_TEMPLATE'
and    formula_type_id = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID('Oracle Payroll');
*/
cursor c_get_ABV_formula
( p_business_group_id NUMBER )
is
select formula_id
from   ff_formulas_f
where  p_business_group_id = business_group_id+0
and    trunc(sysdate) between effective_start_date and effective_end_date
and    formula_name = 'BUDGET_'||p_budget
and    formula_type_id = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID('Quickpaint');


cursor c_get_tmplt_ABV_formula is
select formula_id
from   ff_formulas_f
where  business_group_id+0 is null
and    trunc(sysdate) between effective_start_date and effective_end_date
and    formula_name = 'TEMPLATE_'||p_budget
and    formula_type_id = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID('Quickpaint');

cursor c_get_all_orgs
(P_ORGANIZATION_STRUCTURE_ID	NUMBER
,P_TOP_ORGANIZATION_ID		NUMBER
,P_REPORT_DATE_FROM		DATE
,P_REPORT_DATE_TO		DATE)
is
select
         pose.org_structure_version_id
        ,pose.org_structure_element_id
        ,pose.organization_id_child
        ,posv1.version_number
        ,greatest(posv1.date_from,P_REPORT_DATE_FROM) date_from
        ,least(nvl(posv1.date_to,to_date('31/12/4712','DD/MM/YYYY')),P_REPORT_DATE_TO) date_to
from     per_org_structure_elements pose
        ,per_org_structure_versions posv1
where   pose.organization_id_parent = P_TOP_ORGANIZATION_ID
and     pose.org_structure_version_id = posv1.org_structure_version_id
and     pose.org_structure_version_id in (
                select posv.org_structure_version_id
                from per_org_structure_versions posv
                where posv.organization_structure_id = P_ORGANIZATION_STRUCTURE_ID
                and (P_REPORT_DATE_FROM between posv.date_from and
                nvl(posv.date_to, P_REPORT_DATE_TO)
                or posv.date_from between P_REPORT_DATE_FROM and P_REPORT_DATE_TO))
order by pose.org_structure_version_id
        ,pose.organization_id_child;

cursor c_get_top_orgs
(P_ORGANIZATION_STRUCTURE_ID	NUMBER
,P_TOP_ORGANIZATION_ID		NUMBER
,P_REPORT_DATE_FROM		DATE
,P_REPORT_DATE_TO		DATE)
is
select posv.org_structure_version_id
      ,1-(posv.org_structure_version_id+P_TOP_ORGANIZATION_ID)
	 org_structure_element_id
      ,P_TOP_ORGANIZATION_ID organization_id_child
      ,posv.version_number
      ,greatest(posv.date_from,P_REPORT_DATE_FROM) date_from
      ,least(nvl(posv.date_to,to_date('31/12/4712','DD/MM/YYYY')),P_REPORT_DATE_TO) date_to
from   per_org_structure_versions posv
where  posv.organization_structure_id = P_ORGANIZATION_STRUCTURE_ID
and   (P_REPORT_DATE_FROM between posv.date_from and
                nvl(posv.date_to, P_REPORT_DATE_TO)
      or posv.date_from between P_REPORT_DATE_FROM and P_REPORT_DATE_TO)
order by posv.org_structure_version_id;

cursor c_cwk_profile IS
   select PARAMETER_VALUE
   from pay_action_parameters
   where PARAMETER_NAME = 'HR_HEADCOUNT_FOR_CWK';

l_AsgWorkerType_formula_id   	number;
l_ABV_formula_id   		number;
l_term_formula_id   		number;
l_cwk_term_formula_id           number;
l_ABV   			number;

l_cur_days			number :=0;
l_rev_start_val 		number := 0;
l_rev_end_val 	 		number := 0;
l_nonrev_start_val 		number := 0;
l_nonrev_end_val  		number := 0;
l_rev_perm  			number := 0;
l_nonrev_perm  			number := 0;
l_rev_temp  			number := 0;
l_nonrev_temp  			number := 0;
l_rev_cont  			number := 0;
l_nonrev_cont  			number := 0;
l_rev_transfer_in  		number := 0;
l_nonrev_transfer_in  		number := 0;
l_rev_transfer_out  		number := 0;
l_nonrev_transfer_out  		number := 0;
l_rev_nh  			number := 0;
l_nonrev_nh  			number := 0;
l_rev_cur_nh  			number := 0;
l_nonrev_cur_nh  		number := 0;
l_rev_open_offers  		number := 0;
l_rev_accepted_offers  		number := 0;
l_nonrev_open_offers  		number := 0;
l_nonrev_accepted_offers	number := 0;
l_rev_vol_term  		number := 0;
l_nonrev_vol_term  		number := 0;
l_rev_invol_term  		number := 0;
l_nonrev_invol_term  		number := 0;
l_rev_cur_term  		number := 0;
l_nonrev_cur_term  		number := 0;
l_vacant_FTE			number := 0;
l_rev_vacant_FTE		number := 0;
l_nonrev_vacant_FTE		number := 0;

l_jobcatg     	 		varchar2(1);
l_cur_nh     	 		varchar2(1);
l_pertype     	 		varchar2(10);
l_termtype  	 		varchar2(1);
l_cwk_termtype  	 	varchar2(1);
l_budget     	 		varchar2(30);
l_movement_category		varchar2(30);
l_cwk_profile       	        varchar2(1);

P_DATE_FROM  			date;
P_DATE_TO  			date;
l_cur_date_from			date;
l_cur_date_to			date;


begin

   l_cwk_profile := HR_PERSON_FLEX_LOGIC.HeadCountForCWK;

   -- Look for User Defined HR_PERSON_TYPE Formula

   l_AsgWorkerType_formula_id := HR_PERSON_FLEX_LOGIC.GetFormulaID
                   (p_business_group_id
                   ,'HR_PERSON_TYPE'
                   ,'Oracle Payroll');
/*

   open  c_get_PerType_formula(p_business_group_id);
   fetch c_get_PerType_formula into l_AsgWorkerType_formula_id;

   hr_utility.set_location('l_AsgWorkerType_formula_id = '|| l_AsgWorkerType_formula_id,10);

   if (c_get_PerType_formula%notfound)
   then
   close c_get_PerType_formula;

   hr_utility.set_location('Formula - HR_PERSON_TYPE does not exist.',15);

   -- If User Defined HR_PERSON_TYPE formula does not exist,
   -- look for seeded HR_PERSON_TYPE_TEMPLATE formula

      open c_get_tmplt_PerType_formula;
      fetch c_get_tmplt_PerType_formula into l_AsgWorkerType_formula_id;

      hr_utility.set_location('Template_AsgWorkerType_formula_id = '|| l_AsgWorkerType_formula_id,20);

      if (c_get_tmplt_PerType_formula%notfound)
      then
      close c_get_tmplt_PerType_formula;

      -- Set to null so that we can calculate values differently later

      l_AsgWorkerType_formula_id := null;

      hr_utility.set_location('Formula - HR_PERSON_TYPE_TEMPLATE does not exist.',20);

   else

      close c_get_tmplt_PerType_formula;

   end if;

  else

    close c_get_PerType_formula;

  end if;

*/

   -- Look for user defined BUDGET_FTE/HEAD Formula

   open  c_get_ABV_formula(p_business_group_id);
   fetch c_get_ABV_formula into l_ABV_formula_id;

   hr_utility.set_location('ABV Formula ID = '||l_ABV_formula_id,30);

   if (c_get_ABV_formula%notfound)
   then
   close c_get_ABV_formula;

   hr_utility.set_location('User Defined Formula - BUDGET_FTE/HEAD does not exist.',35);

   -- If User Defined BUDGET_FTE/HEAD formula does not exist,
   -- look for seeded TEMPLATE_FTE/HEAD formula

      open c_get_tmplt_ABV_formula;
      fetch c_get_tmplt_ABV_formula into l_ABV_formula_id;

      hr_utility.set_location('Template ABV Formula = '||l_ABV_formula_id,40);

      if (c_get_tmplt_ABV_formula%notfound)
      then
      close c_get_tmplt_ABV_formula;

      hr_utility.set_location('Seeded Formula - TEMPLATE_FTE/HEAD does not exist.',45);
      -- Set to null so that we can calculate values differently later

      l_ABV_formula_id := null;

      else

      close c_get_tmplt_ABV_formula;

      end if;

   else

   close c_get_ABV_formula;

   end if;


   -- Look for User Defined formula HR_MOVE_TYPE

   l_term_formula_id :=
       HR_PERSON_FLEX_LOGIC.GetFormulaID
                         (p_business_group_id
                         ,'HR_MOVE_TYPE'
                         ,'Oracle Payroll');


   l_cwk_term_formula_id :=
       HR_PERSON_FLEX_LOGIC.GetFormulaID
                         (p_business_group_id
                         ,'HR_CWK_MOVE_TYPE'
                         ,'Oracle Payroll');

/*
   open  c_get_term_formula(p_business_group_id);
   fetch c_get_term_formula into l_term_formula_id;

   hr_utility.set_location('Term Formula ID = '|| l_term_formula_id,50);

   if (c_get_term_formula%notfound)
   then
   close c_get_term_formula;

   hr_utility.set_location('User Defined Formula - HR_MOVE_TYPE does not exist.',55);

   -- If User Defined HR_MOVE_TYPE formula does not exist,
   -- look for seeded HR_MOVE_TYPE_TEMPLATE formula

      open c_get_tmplt_term_formula;
      fetch c_get_tmplt_term_formula into l_term_formula_id;

      hr_utility.set_location('Term Template Formula ID = '|| l_term_formula_id,60);

      if (c_get_tmplt_term_formula%notfound)
      then
      close c_get_tmplt_term_formula;

      hr_utility.set_location('User Defined Formula - HR_MOVE_TYPE_TEMPLATE does not exist.',65);

      -- Set to null so that we can calculate values differently later
      l_term_formula_id := null;
      else

      close c_get_tmplt_term_formula;

      end if;

   else
   close c_get_term_formula;

   end if;
*/
   hr_utility.set_location('P_REPORT_DATE_FROM='||P_REPORT_DATE_FROM,70);

   for osv_rec in get_org_structure_version
   (P_ORGANIZATION_STRUCTURE_ID
   ,P_REPORT_DATE_FROM
   ,P_REPORT_DATE_TO)

   loop

   hr_utility.set_location('osv_rec.date_from ='||osv_rec.date_from,90);
   hr_utility.set_location('osv_rec.date_to   ='||osv_rec.date_to,100);

   if P_REPORT_DATE_FROM > osv_rec.date_from then
      P_DATE_FROM := P_REPORT_DATE_FROM;
   else
      P_DATE_FROM :=osv_rec.date_from;
   end if;

   hr_utility.set_location('P_DATE_FROM='||P_DATE_FROM,110);

   if P_REPORT_DATE_TO < osv_rec.date_to then
      P_DATE_TO := P_REPORT_DATE_TO;
   else
      P_DATE_TO := osv_rec.date_to;
   end if;

   l_cur_date_to := P_DATE_TO;

   l_cur_date_from := l_cur_date_to - P_DAYS_PRIOR_TO_END_DATE;

   if l_cur_date_from < osv_rec.date_from then
      l_cur_date_from := osv_rec.date_from;
   end if;

   hr_utility.set_location('l_cur_date_from ='||l_cur_date_from,118);
   hr_utility.set_location('l_cur_date_to   ='||l_cur_date_to,119);

   hr_utility.set_location('P_DATE_TO ='||P_DATE_TO,120);

   for ose_rec in get_org_structure_element
      (osv_rec.org_structure_version_id
      ,P_TOP_ORGANIZATION_ID)
   loop

   -- Initializing the columns values

   HQOrgData(ose_rec.org_structure_element_id).rev_start_val		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_end_val 		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_start_val		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_end_val 		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_perm			:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_perm		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_cont			:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_cont		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_temp			:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_temp		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_transfer_in  	:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_transfer_in	:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_transfer_out  	:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_transfer_out 	:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_nh  			:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_nh  		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_cur_nh  		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_cur_nh  		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_vacant_FTE		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_vacant_FTE 	:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_vol_term		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_vol_term		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_invol_term		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_invol_term	:= 0;
   HQOrgData(ose_rec.org_structure_element_id).rev_cur_term		:= 0;
   HQOrgData(ose_rec.org_structure_element_id).nonrev_cur_term		:= 0;


   hr_utility.set_location('osv_rec.org_structure_version_id='||osv_rec.org_structure_version_id,130);
   hr_utility.set_location('ose_rec.organization_id         ='||ose_rec.organization_id,140);

   for org_rec in get_organizations
      (osv_rec.org_structure_version_id -- P_ORG_STRUCTURE_VERSION_ID
      ,ose_rec.organization_id 	   -- P_ORGANIZATION_ID
      ,P_ROLL_UP)
   loop

   l_rev_start_val 	:=0;
   l_rev_end_val 	:=0;
   l_nonrev_start_val 	:=0;
   l_nonrev_end_val  	:=0;
   l_rev_transfer_out 	:=0;
   l_nonrev_transfer_out:=0;

   hr_utility.set_location('org_rec.organization_id='||org_rec.organization_id,150);

--changes for bug 6124652 starts here
      for asg_rec in get_assignment_start_end_fte
			(P_DATE_FROM
			,org_rec.organization_id
			,P_BUSINESS_GROUP_ID
			,P_WORKER_TYPE
			,P_INCLUDE_ASG_TYPE)

      loop

      l_jobcatg := NULL;
      l_abv	:= NULL;

      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  			( p_ABV_formula_id  => l_ABV_formula_id
    			, p_ABV             => p_budget
 			, p_assignment_id   => asg_rec.assignment_id
   			, p_effective_date  => asg_rec.effective_start_date
			, p_session_date    => trunc(sysdate) );


      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
			(asg_rec.job_id
			,p_job_category);


      if l_jobcatg = 'Y'
      then
         l_rev_start_val       := l_rev_start_val    + l_abv;
      else
         l_nonrev_start_val    := l_nonrev_start_val + l_abv;
      end if;
end loop;
--changes for bug 6124652 ends here

      for asg_rec in get_assignment_start_end
			(P_DATE_FROM,
--bug 6124652 starts here
			P_DATE_TO
--bug 6124652 ends here
			,org_rec.organization_id
			,P_BUSINESS_GROUP_ID
			,P_WORKER_TYPE
			,P_INCLUDE_ASG_TYPE)

      loop

      l_jobcatg := NULL;
      l_abv	:= NULL;

      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  			( p_ABV_formula_id  => l_ABV_formula_id
    			, p_ABV             => p_budget
 			, p_assignment_id   => asg_rec.assignment_id
   			, p_effective_date  => asg_rec.effective_start_date
			, p_session_date    => trunc(sysdate) );


      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
			(asg_rec.job_id
			,p_job_category);


/*      if l_jobcatg = 'Y'
      then
         l_rev_start_val       := l_rev_start_val    + l_abv;
      else
         l_nonrev_start_val    := l_nonrev_start_val + l_abv;
      end if;*/

      l_movement_category := NULL;

      HR_PERSON_FLEX_LOGIC.GetMovementCategory(
		 p_organization_id     =>   org_rec.organization_id
		,p_assignment_id       =>   asg_rec.assignment_id
		,p_period_start_date   =>   asg_rec.effective_end_date
		,p_period_end_date     =>   P_DATE_TO
		,p_movement_type       =>   'OUT'
		,p_assignment_type     =>   P_WORKER_TYPE
		,p_movement_category   =>   l_movement_category
		);

      hr_utility.set_location('Movement Category 1 = '||l_movement_category,160);

      if (l_movement_category = 'TRANSFER_OUT' or
--	  l_movement_category = 'SEPARATED'    or
          l_movement_category = 'SUSPENDED' ) then

         if l_jobcatg = 'Y'
         then
            l_rev_transfer_out       := l_rev_transfer_out    + l_abv;
         else
            l_nonrev_transfer_out    := l_nonrev_transfer_out + l_abv;
         end if;

      end if;


      end loop; -- get_assignment_start_end

      HQOrgData(ose_rec.org_structure_element_id).rev_start_val :=
      HQOrgData(ose_rec.org_structure_element_id).rev_start_val + nvl(l_rev_start_val,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_start_val :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_start_val + nvl(l_nonrev_start_val,0);

      hr_utility.set_location('Beginning Head/FTE Count (R) = '||HQOrgData(ose_rec.org_structure_element_id).rev_start_val,170);
      hr_utility.set_location('Beginning Head/FTE Count (N) = '||HQOrgData(ose_rec.org_structure_element_id).nonrev_start_val,180);

      HQOrgData(ose_rec.org_structure_element_id).rev_transfer_out  :=
      HQOrgData(ose_rec.org_structure_element_id).rev_transfer_out  + nvl(l_rev_transfer_out,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_transfer_out  :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_transfer_out  + nvl(l_nonrev_transfer_out,0);

      l_rev_transfer_out   := 0;
      l_nonrev_transfer_out:= 0;
      l_rev_transfer_in    := 0;
      l_nonrev_transfer_in := 0;

--changes for bug 6124652 starts here
      for asg_rec in get_assignment_start_end_fte
      	                (P_DATE_TO
			,org_rec.organization_id
			,P_BUSINESS_GROUP_ID
			,P_WORKER_TYPE
			,P_INCLUDE_ASG_TYPE)

      loop -- get_assignment_start_end

      l_jobcatg := NULL;
      l_abv     := NULL;

      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
    			( p_ABV_formula_id  => l_ABV_formula_id
    			, p_ABV             => p_budget
	 		, p_assignment_id   => asg_rec.assignment_id
	   		, p_effective_date  => asg_rec.effective_start_date
			, p_session_date    => trunc(sysdate) );


      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
			(asg_rec.job_id
			,p_job_category);

      if l_jobcatg = 'Y'
      then
         l_rev_end_val       := l_rev_end_val    + l_abv;
      else
         l_nonrev_end_val    := l_nonrev_end_val + l_abv;
      end if;
end loop;
--changes for bug 6124652 ends here
      for asg_rec in get_assignment_start_end
      	                (
        --bug 6124652 starts here
			P_DATE_FROM,
            --bug 6124652 ends here
      	                P_DATE_TO
			,org_rec.organization_id
			,P_BUSINESS_GROUP_ID
			,P_WORKER_TYPE
			,P_INCLUDE_ASG_TYPE)

      loop -- get_assignment_start_end

      l_jobcatg := NULL;
      l_abv     := NULL;

      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
    			( p_ABV_formula_id  => l_ABV_formula_id
    			, p_ABV             => p_budget
	 		, p_assignment_id   => asg_rec.assignment_id
	   		, p_effective_date  => asg_rec.effective_start_date
			, p_session_date    => trunc(sysdate) );


      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
			(asg_rec.job_id
			,p_job_category);

/*      if l_jobcatg = 'Y'
      then
         l_rev_end_val       := l_rev_end_val    + l_abv;
      else
         l_nonrev_end_val    := l_nonrev_end_val + l_abv;
      end if;
*/
      HR_PERSON_FLEX_LOGIC.GetMovementCategory(
			 p_organization_id        =>   org_rec.organization_id
			,p_assignment_id          =>   asg_rec.assignment_id
			,p_period_start_date      =>   P_DATE_FROM
			,p_period_end_date        =>   asg_rec.effective_end_date
			,p_movement_type          =>   'IN'
		        ,p_assignment_type        =>   P_WORKER_TYPE
			,p_movement_category 	  =>   l_movement_category);

      if (l_movement_category = 'TRANSFER_IN' or
          l_movement_category = 'REACTIVATED') then

      hr_utility.set_location('Movement Category 2 = '||l_movement_category,190);
      hr_utility.set_location('Organization ID     = '||org_rec.organization_id,200);
      hr_utility.set_location('Assignment ID       = '||asg_rec.assignment_id,210);
      hr_utility.set_location('Start Date          = '||to_char(P_DATE_FROM,'DD-MON-YYYY'),220);
      hr_utility.set_location('End   Date          = '||to_char(P_DATE_TO,'DD-MON-YYYY'),230);

         if l_jobcatg = 'Y'
         then
            l_rev_transfer_in       := l_rev_transfer_in    + l_abv;
         else
            l_nonrev_transfer_in    := l_nonrev_transfer_in + l_abv;
         end if;

      elsif l_movement_category = 'NEW_HIRE' then

         if l_jobcatg = 'Y'
         then
            l_rev_nh       := l_rev_nh    + l_abv;
         else
            l_nonrev_nh    := l_nonrev_nh + l_abv;
         end if;

         l_cur_nh := NULL;

         l_cur_nh := HR_PERSON_FLEX_LOGIC.GetCurNHNew
                         ( p_organization_id    => org_rec.organization_id
                         , p_assignment_id      => asg_rec.assignment_id
                         , p_assignment_type    => P_WORKER_TYPE
                         , p_cur_date_from      => l_cur_date_from
                         , p_cur_date_to	 => l_cur_date_to);

         hr_utility.set_location('New Hire = '||l_cur_nh,240);

         if l_cur_nh = 'Y' then

            if l_jobcatg = 'Y'
            then
               l_rev_cur_nh       := l_rev_cur_nh    + l_abv;
            else
               l_nonrev_cur_nh    := l_nonrev_cur_nh + l_abv;
            end if;

         end if;

      end if;

      end loop; -- get_assignment_start_end

      hr_utility.set_location('org_structure_element_id = '||ose_rec.org_structure_element_id,250);
      HQOrgData(ose_rec.org_structure_element_id).rev_end_val :=
      HQOrgData(ose_rec.org_structure_element_id).rev_end_val + nvl(l_rev_end_val,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_end_val :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_end_val + nvl(l_nonrev_end_val,0);

      hr_utility.set_location('Ending HeadCount (R) = '||HQOrgData(ose_rec.org_structure_element_id).rev_end_val,260);
      hr_utility.set_location('Ending HeadCount (N) = '||HQOrgData(ose_rec.org_structure_element_id).nonrev_end_val,270);

      HQOrgData(ose_rec.org_structure_element_id).rev_transfer_in  :=
      HQOrgData(ose_rec.org_structure_element_id).rev_transfer_in  + nvl(l_rev_transfer_in,0);

      HQOrgData(ose_rec.org_structure_element_id).nonrev_transfer_in  :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_transfer_in  + nvl(l_nonrev_transfer_in,0);
      hr_utility.set_location('Transfer In',2701);

      HQOrgData(ose_rec.org_structure_element_id).rev_nh  :=
      HQOrgData(ose_rec.org_structure_element_id).rev_nh  + nvl(l_rev_nh,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_nh  :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_nh  + nvl(l_nonrev_nh,0);

      hr_utility.set_location('New Hire',2702);

      HQOrgData(ose_rec.org_structure_element_id).rev_cur_nh  :=
      HQOrgData(ose_rec.org_structure_element_id).rev_cur_nh  + nvl(l_rev_cur_nh,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_cur_nh  :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_cur_nh  + nvl(l_nonrev_cur_nh,0);

      hr_utility.set_location('Current New Hire',2703);

      l_rev_transfer_in 	:= 0;
      l_nonrev_transfer_in	:= 0;
      l_rev_nh 			:= 0;
      l_nonrev_nh		:= 0;
      l_rev_cur_nh 		:= 0;
      l_nonrev_cur_nh		:= 0;

      hr_utility.set_location('Current Organization',2704);

      -- For the Current Organization

      for assgt_rec in get_assignment
		( P_DATE_FROM
		, P_DATE_TO
		, org_rec.organization_id
		, P_BUSINESS_GROUP_ID
		, P_WORKER_TYPE
		, P_INCLUDE_ASG_TYPE)

      loop -- get_assignment

      hr_utility.set_location('Current Organization',2705);

      hr_utility.set_location('l_AsgWorkerType_formula_id = '||to_char(l_AsgWorkerType_formula_id),275);
      hr_utility.set_location('assgt_rec.assignment_id = '||to_char(assgt_rec.assignment_id),275);
      hr_utility.set_location('assgt_rec.effective_start_date = '||to_char(assgt_rec.effective_start_date,'DD/MM/YYYY'),275);

      if assgt_rec.assignment_type <> 'C' then

      l_pertype := NULL;
      l_pertype := HR_PERSON_FLEX_LOGIC.GetAsgWorkerType
	       (p_AsgWorkerType_formula_id  => l_AsgWorkerType_formula_id
	       ,p_assignment_id        	    => assgt_rec.assignment_id
	       ,p_effective_date       	    => assgt_rec.effective_start_date
	       ,p_session_date         	    => trunc(sysdate)
	       );

      end if;

      hr_utility.set_location('AsgWorkerType = '||l_pertype,280);

      l_jobcatg := NULL;
      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (assgt_rec.job_id
                                ,p_job_category);
      l_abv	:= 0;
      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  				( p_ABV_formula_id  => l_ABV_formula_id
    				, p_ABV             => p_budget
	 			, p_assignment_id   => assgt_rec.assignment_id
	   			, p_effective_date  => assgt_rec.effective_start_date
				, p_session_date    => trunc(sysdate) );

      hr_utility.set_location('l_abv     = '||l_abv,290);
      hr_utility.set_location('l_jobcatg = '||l_jobcatg,300);
      hr_utility.set_location('l_pertype = '||l_pertype,310);

      if l_pertype = 'P' then

         if l_jobcatg = 'Y'
         then
            l_rev_perm       := l_rev_perm    + l_abv;
         else
            l_nonrev_perm    := l_nonrev_perm + l_abv;
         end if;

      hr_utility.set_location('Rev Perm = '||to_char(l_rev_perm),320);
      hr_utility.set_location('NonRev Perm = '||to_char(l_nonrev_perm),330);

      elsif l_pertype = 'T' then

         if l_jobcatg = 'Y'
         then
            l_rev_temp       := l_rev_temp    + l_abv;
         else
            l_nonrev_temp    := l_nonrev_temp + l_abv;
         end if;

       elsif  l_cwk_profile = 'N' then

         if l_pertype = 'C' then

         if l_jobcatg = 'Y'
         then
            l_rev_cont       := l_rev_cont    + l_abv;
         else
            l_nonrev_cont    := l_nonrev_cont + l_abv;
         end if;

         end if;

        end if;

      if (l_cwk_profile = 'Y' and
          assgt_rec.assignment_type = 'C') then

         if l_jobcatg = 'Y'
         then
            l_rev_cont       := l_rev_cont + l_abv;
         else
            l_nonrev_cont    := l_nonrev_cont + l_abv;
         end if;

      end if;


      end loop; -- get_assignment

      HQOrgData(ose_rec.org_structure_element_id).rev_perm :=
      HQOrgData(ose_rec.org_structure_element_id).rev_perm + nvl(l_rev_perm,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_perm :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_perm + nvl(l_nonrev_perm,0);

      l_rev_perm 	:= 0;
      l_nonrev_perm 	:= 0;

      hr_utility.set_location('Permanent (R) = '||HQOrgData(ose_rec.org_structure_element_id).rev_perm,340);
      hr_utility.set_location('Permanent (N) = '||HQOrgData(ose_rec.org_structure_element_id).nonrev_perm,350);

      HQOrgData(ose_rec.org_structure_element_id).rev_temp :=
      HQOrgData(ose_rec.org_structure_element_id).rev_temp + nvl(l_rev_temp,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_temp :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_temp + nvl(l_nonrev_temp,0);

      l_rev_temp 	:= 0;
      l_nonrev_temp 	:= 0;

      HQOrgData(ose_rec.org_structure_element_id).rev_cont :=
      HQOrgData(ose_rec.org_structure_element_id).rev_cont + nvl(l_rev_cont,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_cont :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_cont + nvl(l_nonrev_cont,0);

      l_rev_cont 	:= 0;
      l_nonrev_cont 	:= 0;


      HQOrgData(ose_rec.org_structure_element_id).rev_open_offers	:= 0;
      HQOrgData(ose_rec.org_structure_element_id).nonrev_open_offers	:= 0;

      hr_utility.set_location('Permanent HeadCount (R) = '||HQOrgData(ose_rec.org_structure_element_id).rev_perm,360);
      hr_utility.set_location('Permanent HeadCount (N) = '||HQOrgData(ose_rec.org_structure_element_id).nonrev_perm,370);

      l_rev_open_offers := 0;
      l_nonrev_open_offers := 0;

      for appl_open_offers_rec in get_open_offers
		( P_DATE_FROM
		, P_DATE_TO
		, org_rec.organization_id
		, P_BUSINESS_GROUP_ID)

      loop -- get_open_offers

         l_jobcatg := NULL;
         l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (appl_open_offers_rec.job_id
                                ,p_job_category);

         if l_jobcatg = 'Y'
         then
            l_rev_open_offers       := l_rev_open_offers + 1;
         else
            l_nonrev_open_offers    := l_nonrev_open_offers + 1;
         end if;

      end loop; -- get_open_offers

      HQOrgData(ose_rec.org_structure_element_id).rev_open_offers :=
      HQOrgData(ose_rec.org_structure_element_id).rev_open_offers + nvl(l_rev_open_offers,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_open_offers :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_open_offers + nvl(l_nonrev_open_offers,0);

      HQOrgData(ose_rec.org_structure_element_id).rev_accepted_offers		:= 0;
      HQOrgData(ose_rec.org_structure_element_id).nonrev_accepted_offers	:= 0;

      l_rev_accepted_offers := 0;
      l_nonrev_accepted_offers := 0;

      for appl_accepted_offers_rec in get_accepted_offers
		( P_DATE_FROM
		, P_DATE_TO
		, org_rec.organization_id
		, P_BUSINESS_GROUP_ID)

      loop -- get_accepted_offers

      l_jobcatg := NULL;
      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (appl_accepted_offers_rec.job_id
                                ,p_job_category);

         if l_jobcatg = 'Y'
         then
            l_rev_accepted_offers       := l_rev_accepted_offers + 1;
         else
            l_nonrev_accepted_offers    := l_nonrev_accepted_offers + 1;
         end if;

      end loop; -- get_accepted_offers

      HQOrgData(ose_rec.org_structure_element_id).rev_accepted_offers :=
      HQOrgData(ose_rec.org_structure_element_id).rev_accepted_offers + nvl(l_rev_accepted_offers,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_accepted_offers :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_accepted_offers + nvl(l_nonrev_accepted_offers,0);

      l_rev_vacant_FTE	        :=0;
      l_nonrev_vacant_FTE	:=0;

      for vac_rec in get_requisitions
		(P_BUSINESS_GROUP_ID
		 ,org_rec.organization_id
		 ,P_BUDGET
		 ,P_DATE_TO )

      loop -- get_requisitions
      l_jobcatg := NULL;

      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
					(vac_rec.job_id
					,p_job_category);

         if vac_rec.budget_measurement_value <> 0
	      and vac_rec.number_of_openings <> 0
         then
            l_vacant_FTE := vac_rec.budget_measurement_value / vac_rec.number_of_openings;
         end if;

         if l_jobcatg = 'Y'
         then
            l_rev_vacant_FTE     := l_rev_vacant_FTE + l_vacant_FTE;
         else
            l_nonrev_vacant_FTE  := l_nonrev_vacant_FTE + l_vacant_FTE;
         end if;

      end loop; -- get_requisitions

      HQOrgData(ose_rec.org_structure_element_id).rev_vacant_FTE :=
      HQOrgData(ose_rec.org_structure_element_id).rev_vacant_FTE + l_rev_vacant_FTE;
      HQOrgData(ose_rec.org_structure_element_id).nonrev_vacant_FTE :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_vacant_FTE + l_nonrev_vacant_FTE;

      hr_utility.set_location('Organization ID............ '||org_rec.organization_id,400);

      if P_WORKER_TYPE <> 'C'  then

      hr_utility.set_location('Start of Worker Type <> C Current Terminations.......',405);

      l_rev_cur_term  		:=0;
      l_nonrev_cur_term		:=0;

      for cur_term_rec in get_cur_terminations
		( P_DATE_FROM
		, l_cur_date_from
		, l_cur_date_to
		, org_rec.organization_id
		, P_BUSINESS_GROUP_ID)

      loop -- get_cur_terminations

      l_jobcatg := NULL;
      l_abv     := NULL;

      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => cur_term_rec.assignment_id
                        , p_effective_date  => cur_term_rec.actual_termination_date
                        , p_session_date    => trunc(sysdate) );


      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (cur_term_rec.job_id
                                ,p_job_category);

         if l_jobcatg = 'Y'
         then
            l_rev_cur_term       := l_rev_cur_term + l_abv;
         else
            l_nonrev_cur_term    := l_nonrev_cur_term + l_abv;
         end if;

      end loop; -- get_cur_terminations

      HQOrgData(ose_rec.org_structure_element_id).rev_cur_term :=
      HQOrgData(ose_rec.org_structure_element_id).rev_cur_term + nvl(l_rev_cur_term,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_cur_term :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_cur_term + nvl(l_nonrev_cur_term,0);

      hr_utility.set_location('End of Worker Type <> C Current Terminations.......',450);

      l_rev_vol_term	    :=0;
      l_nonrev_vol_term	    :=0;
      l_rev_invol_term	    :=0;
      l_nonrev_invol_term   :=0;

      hr_utility.set_location('Start of Worker Type <> C Terminations.......',460);
      hr_utility.set_location('E Rev Vol T = '||l_rev_vol_term||'..........'||
                             HQOrgData(ose_rec.org_structure_element_id).rev_vol_term,480);

      for term_rec in get_terminations
		( P_DATE_FROM
		, P_DATE_TO
		, org_rec.organization_id
		, P_BUSINESS_GROUP_ID)

      loop -- get_terminations

      hr_utility.set_location('Leaving Reason  = '||term_rec.leaving_reason,465);

      l_termtype:= NULL;
      l_termtype:= HR_PERSON_FLEX_LOGIC.GetTermType
				(p_term_formula_id	=> l_term_formula_id
				,p_leaving_reason 	=> term_rec.leaving_reason
				,p_session_date	        => trunc(sysdate));

      hr_utility.set_location('Term Type       = '||l_termtype,470);

      l_jobcatg := NULL;
      l_abv     := NULL;

      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => term_rec.assignment_id
                        , p_effective_date  => term_rec.actual_termination_date
                        , p_session_date    => trunc(sysdate) );

      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (term_rec.job_id
                                ,p_job_category);

      hr_utility.set_location('Job Category     = '||l_jobcatg,475);

      if l_termtype = 'V'
      then
         if l_jobcatg = 'Y'
         then
            l_rev_vol_term       := l_rev_vol_term    + l_abv;
         else
            l_nonrev_vol_term    := l_nonrev_vol_term + l_abv;
         end if;
      elsif l_termtype = 'I'
      then
	   if l_jobcatg = 'Y'
           then
              l_rev_invol_term       := l_rev_invol_term + l_abv;
           else
              l_nonrev_invol_term    := l_nonrev_invol_term + l_abv;
           end if;
      end if;

      end loop; -- get_terminations

      hr_utility.set_location('E Rev Vol T = '||l_rev_vol_term||'..........'||
                             HQOrgData(ose_rec.org_structure_element_id).rev_vol_term,480);
      hr_utility.set_location('E NonRev Vol T = '||l_nonrev_vol_term||'.......'||
                             HQOrgData(ose_rec.org_structure_element_id).nonrev_vol_term,485);

      hr_utility.set_location('E Rev InVol T = '||l_rev_invol_term||'........'||
                             HQOrgData(ose_rec.org_structure_element_id).rev_invol_term,490);
      hr_utility.set_location('E NonRev InVol T = '||l_nonrev_invol_term||'.....'||
                             HQOrgData(ose_rec.org_structure_element_id).nonrev_invol_term,495);

      HQOrgData(ose_rec.org_structure_element_id).rev_vol_term :=
      HQOrgData(ose_rec.org_structure_element_id).rev_vol_term + nvl(l_rev_vol_term,0);
      HQOrgData(ose_rec.org_structure_element_id).rev_invol_term :=
      HQOrgData(ose_rec.org_structure_element_id).rev_invol_term + nvl(l_rev_invol_term,0);

      HQOrgData(ose_rec.org_structure_element_id).nonrev_vol_term :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_vol_term + nvl(l_nonrev_vol_term,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_invol_term :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_invol_term + nvl(l_nonrev_invol_term,0);

      l_rev_vol_term	    :=0;
      l_nonrev_vol_term	    :=0;
      l_rev_invol_term	    :=0;
      l_nonrev_invol_term   :=0;

      hr_utility.set_location('End of Worker Type <> C Terminations.......',500);

      end if;

      if P_WORKER_TYPE <> 'E'  then

      hr_utility.set_location('Start of Worker Type <> E Current Terminations.......',505);

      l_rev_cur_term  		:=0;
      l_nonrev_cur_term		:=0;

      for cur_term_rec in get_cur_terminations_cwk
		( P_DATE_FROM
		, l_cur_date_from
		, l_cur_date_to
		, org_rec.organization_id
		, P_BUSINESS_GROUP_ID)

      loop -- get_cur_terminations_cwk

      l_jobcatg := NULL;
      l_abv     := NULL;

      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => cur_term_rec.assignment_id
                        , p_effective_date  => cur_term_rec.actual_termination_date
                        , p_session_date    => trunc(sysdate) );


      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (cur_term_rec.job_id
                                ,p_job_category);

         if l_jobcatg = 'Y'
         then
            l_rev_cur_term       := l_rev_cur_term + l_abv;
         else
            l_nonrev_cur_term    := l_nonrev_cur_term + l_abv;
         end if;

      end loop; -- get_cur_terminations_cwk

      HQOrgData(ose_rec.org_structure_element_id).rev_cur_term :=
      HQOrgData(ose_rec.org_structure_element_id).rev_cur_term + nvl(l_rev_cur_term,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_cur_term :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_cur_term + nvl(l_nonrev_cur_term,0);

      hr_utility.set_location('End of Worker Type <> E Current Terminations.......',550);

      l_rev_vol_term	    :=0;
      l_nonrev_vol_term	    :=0;
      l_rev_invol_term	    :=0;
      l_nonrev_invol_term   :=0;

      hr_utility.set_location('Start of Worker Type <> E Terminations.......',560);

      for term_rec in get_terminations_cwk
		( P_DATE_FROM
		, P_DATE_TO
		, org_rec.organization_id
		, P_BUSINESS_GROUP_ID)

      loop -- get_terminations_cwk

      l_jobcatg := NULL;
      l_abv     := NULL;

      l_cwk_termtype := NULL;
      l_cwk_termtype := HR_PERSON_FLEX_LOGIC.GetTermType
                                (p_term_formula_id      => l_cwk_term_formula_id
                                ,p_leaving_reason       => term_rec.termination_reason
                                ,p_session_date         => trunc(sysdate));

      hr_utility.set_location('Term Type       = '||l_cwk_termtype,470);

      l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => term_rec.assignment_id
                        , p_effective_date  => term_rec.actual_termination_date
                        , p_session_date    => trunc(sysdate) );

      l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (term_rec.job_id
                                ,p_job_category);

      -- hr_utility.set_location('Job Categ = '||l_jobcatg,565);

      if l_cwk_termtype = 'V'
      then
         if l_jobcatg = 'Y'
         then
            l_rev_vol_term       := l_rev_vol_term    + l_abv;
         else
            l_nonrev_vol_term    := l_nonrev_vol_term + l_abv;
         end if;
      elsif l_cwk_termtype = 'I'
      then
         if l_jobcatg = 'Y'
         then
            l_rev_invol_term       := l_rev_invol_term    + l_abv;
         else
            l_nonrev_invol_term    := l_nonrev_invol_term + l_abv;
         end if;
       end if;

      end loop; -- get_terminations_cwk

      hr_utility.set_location('C Rev Vol T    = '||l_rev_vol_term,570);
      hr_utility.set_location('C NONRev Vol T = '||l_nonrev_vol_term,575);

      hr_utility.set_location('C Rev InVol T    = '||l_rev_vol_term,580);
      hr_utility.set_location('C NONRev InVol T = '||l_nonrev_vol_term,585);

      HQOrgData(ose_rec.org_structure_element_id).rev_vol_term :=
      HQOrgData(ose_rec.org_structure_element_id).rev_vol_term + nvl(l_rev_vol_term,0);
      HQOrgData(ose_rec.org_structure_element_id).nonrev_vol_term :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_vol_term + nvl(l_nonrev_vol_term,0);

      l_rev_vol_term	    :=0;
      l_nonrev_vol_term	    :=0;
      l_rev_invol_term	    :=0;
      l_nonrev_invol_term   :=0;

      hr_utility.set_location('End of Worker Type <> E Terminations.......',600);

      end if;

      if P_WORKER_TYPE = 'B' then

      hr_utility.set_location('Worker Type = B Terminations.......',605);

      HQOrgData(ose_rec.org_structure_element_id).rev_vol_term :=
      HQOrgData(ose_rec.org_structure_element_id).rev_vol_term +
      HQOrgData(ose_rec.org_structure_element_id).rev_invol_term;
      HQOrgData(ose_rec.org_structure_element_id).nonrev_vol_term :=
      HQOrgData(ose_rec.org_structure_element_id).nonrev_vol_term +
      HQOrgData(ose_rec.org_structure_element_id).nonrev_invol_term ;

      end if;

      end loop; -- get_organizations

   end loop; -- get_org_structure_element

   -- This is the start of the TOP Organization story for a version

   if P_INCLUDE_TOP_ORG = 'Y' then

   hr_utility.set_location('P_INCLUDE_TOP_ORG = Y',800);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_start_val      := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_end_val        := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_start_val   := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_end_val     := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_perm           := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_perm        := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cont           := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cont        := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_temp           := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_temp        := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_transfer_in    := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_transfer_in := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_transfer_out   := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_transfer_out:= 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_nh             := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_nh          := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cur_nh         := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cur_nh      := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vacant_FTE	    := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vacant_FTE  := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vol_term	    := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vol_term    := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_invol_term	    := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_invol_term  := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cur_term	    := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cur_term    := 0;


   hr_utility.set_location('Top Organization ='||(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)),810);
   hr_utility.set_location('osv_rec.org_structure_version_id = '||osv_rec.org_structure_version_id,820);
   hr_utility.set_location('P_TOP_ORGANIZATION_ID = '||P_TOP_ORGANIZATION_ID,830);

   l_rev_start_val 	:=0;
   l_rev_end_val 	:=0;
   l_nonrev_start_val 	:=0;
   l_nonrev_end_val  	:=0;
   l_rev_transfer_out 	:= 0;
   l_nonrev_transfer_out:= 0;
--bug 6124652 starts here
  for asg_rec in get_assignment_start_end_fte
			(P_DATE_FROM
			,P_TOP_ORGANIZATION_ID
			,P_BUSINESS_GROUP_ID
			,P_WORKER_TYPE
			,P_INCLUDE_ASG_TYPE)

   loop  -- get_assignment_start_end

   l_jobcatg := NULL;
   l_abv     := NULL;

   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  				( p_ABV_formula_id  => l_ABV_formula_id
    				, p_ABV             => p_budget
	 			, p_assignment_id   => asg_rec.assignment_id
	   			, p_effective_date  => asg_rec.effective_start_date
				, p_session_date    => trunc(sysdate) );






   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
				(asg_rec.job_id
				,p_job_category);

   hr_utility.set_location('Top Org l_jobcatg = '||l_jobcatg,880);

   if l_jobcatg = 'Y'
   then
      l_rev_start_val       := l_rev_start_val    + l_abv;
   else
      l_nonrev_start_val    := l_nonrev_start_val + l_abv;
   end if;
end loop;
--bug 6124652 ends here
   for asg_rec in get_assignment_start_end
			(P_DATE_FROM,
--bug 6124652 starts here
			P_DATE_TO
--bug 6124652 ends here
			,P_TOP_ORGANIZATION_ID
			,P_BUSINESS_GROUP_ID
			,P_WORKER_TYPE
			,P_INCLUDE_ASG_TYPE)

   loop  -- get_assignment_start_end

   l_jobcatg := NULL;
   l_abv     := NULL;

   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  				( p_ABV_formula_id  => l_ABV_formula_id
    				, p_ABV             => p_budget
	 			, p_assignment_id   => asg_rec.assignment_id
	   			, p_effective_date  => asg_rec.effective_start_date
				, p_session_date    => trunc(sysdate) );

   hr_utility.set_location('Top Org Assignment ID = '||asg_rec.assignment_id,840);
   hr_utility.set_location('Top Org Effective Start Date = '||to_char(asg_rec.effective_start_date,'DD/MM/YYYY'),850);
   hr_utility.set_location('Top Org Job ID = '||asg_rec.job_id,860);
   hr_utility.set_location('Top Org l_abv = '||l_abv,870);

   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
				(asg_rec.job_id
				,p_job_category);

   hr_utility.set_location('Top Org l_jobcatg = '||l_jobcatg,880);

/*   if l_jobcatg = 'Y'
   then
      l_rev_start_val       := l_rev_start_val    + l_abv;
   else
      l_nonrev_start_val    := l_nonrev_start_val + l_abv;
   end if;
*/
   l_movement_category := NULL;

   HR_PERSON_FLEX_LOGIC.GetMovementCategory(
		 p_organization_id     =>   P_TOP_ORGANIZATION_ID
		,p_assignment_id       =>   asg_rec.assignment_id
		,p_period_start_date   =>   asg_rec.effective_end_date
		,p_period_end_date     =>   P_DATE_TO
		,p_movement_type       =>   'OUT'
		,p_assignment_type     =>   P_WORKER_TYPE
		,p_movement_category   =>   l_movement_category
		);

   hr_utility.set_location('Top Org l_movement_category = '||l_movement_category,890);

   if (l_movement_category = 'TRANSFER_OUT' or
--     l_movement_category = 'SEPARATED' or
       l_movement_category = 'SUSPENDED' ) then

      if l_jobcatg = 'Y'
      then
         l_rev_transfer_out       := l_rev_transfer_out    + l_abv;
      else
         l_nonrev_transfer_out    := l_nonrev_transfer_out + l_abv;
      end if;

   end if;


   end loop;  -- get_assignment_start_end

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_start_val   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_start_val + nvl(l_rev_start_val,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_start_val   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_start_val + nvl(l_nonrev_start_val,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_transfer_out   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_transfer_out + nvl(l_rev_transfer_out,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_transfer_out   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_transfer_out + nvl(l_nonrev_transfer_out,0);


   l_rev_transfer_out 	:= 0;
   l_nonrev_transfer_out:= 0;
   l_rev_transfer_in 	:= 0;
   l_nonrev_transfer_in	:= 0;
--bug 6124652 starts here
 for asg_rec in get_assignment_start_end_fte
      	                (P_DATE_TO
			,P_TOP_ORGANIZATION_ID
			,P_BUSINESS_GROUP_ID
			,P_WORKER_TYPE
			,P_INCLUDE_ASG_TYPE)

   loop -- get_assignment_start_end

   l_jobcatg := NULL;
   l_abv	:= NULL;

   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  				( p_ABV_formula_id  => l_ABV_formula_id
    				, p_ABV             => p_budget
	 			, p_assignment_id   => asg_rec.assignment_id
	   			, p_effective_date  => asg_rec.effective_start_date
				, p_session_date    => trunc(sysdate) );


   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
				(asg_rec.job_id
				,p_job_category);

   if l_jobcatg = 'Y'
   then
      l_rev_end_val       := l_rev_end_val    + l_abv;
   else
      l_nonrev_end_val    := l_nonrev_end_val + l_abv;
   end if;
end loop;
--bug 6124652 ends here
   for asg_rec in get_assignment_start_end
      	                (
--bug 6124652 starts here
			P_DATE_FROM,
--bug 6124652 ends here
      	                P_DATE_TO
			,P_TOP_ORGANIZATION_ID
			,P_BUSINESS_GROUP_ID
			,P_WORKER_TYPE
			,P_INCLUDE_ASG_TYPE)

   loop -- get_assignment_start_end

   l_jobcatg := NULL;
   l_abv	:= NULL;

   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  				( p_ABV_formula_id  => l_ABV_formula_id
    				, p_ABV             => p_budget
	 			, p_assignment_id   => asg_rec.assignment_id
	   			, p_effective_date  => asg_rec.effective_start_date
				, p_session_date    => trunc(sysdate) );


   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
				(asg_rec.job_id
				,p_job_category);
/*
   if l_jobcatg = 'Y'
   then
      l_rev_end_val       := l_rev_end_val    + l_abv;
   else
      l_nonrev_end_val    := l_nonrev_end_val + l_abv;
   end if;
*/
   HR_PERSON_FLEX_LOGIC.GetMovementCategory(
		 p_organization_id     =>   P_TOP_ORGANIZATION_ID
		,p_assignment_id       =>   asg_rec.assignment_id
		,p_period_start_date   =>   P_DATE_FROM
		,p_period_end_date     =>   asg_rec.effective_end_date
		,p_movement_type       =>   'IN'
		,p_assignment_type     =>   P_WORKER_TYPE
		,p_movement_category   =>   l_movement_category
		);

   if (l_movement_category = 'TRANSFER_IN' or
       l_movement_category = 'REACTIVATED') then

   hr_utility.set_location('Top Org l_movement_category2 = '||l_movement_category,900);
   hr_utility.set_location('Top Org Start Date          = '||to_char(P_DATE_FROM,'DD-MON-YYYY'),910);
   hr_utility.set_location('Top Org End   Date          = '||to_char(P_DATE_TO,'DD-MON-YYYY'),920);

      if l_jobcatg = 'Y'
      then
         l_rev_transfer_in       := l_rev_transfer_in    + l_abv;
      else
         l_nonrev_transfer_in    := l_nonrev_transfer_in + l_abv;
      end if;

   elsif l_movement_category = 'NEW_HIRE' then

      if l_jobcatg = 'Y'
      then
         l_rev_nh       := l_rev_nh    + l_abv;
      else
         l_nonrev_nh    := l_nonrev_nh + l_abv;
      end if;

      l_cur_nh := NULL;

      l_cur_nh := HR_PERSON_FLEX_LOGIC.GetCurNHNew
	  ( p_organization_id    => P_TOP_ORGANIZATION_ID
	  , p_assignment_id      => asg_rec.assignment_id
          , p_assignment_type    => P_WORKER_TYPE
	  , p_cur_date_from      => l_cur_date_from
	  , p_cur_date_to	 => l_cur_date_to);

      hr_utility.set_location('Top Org New Hire = '||l_cur_nh,930);

      if l_cur_nh = 'Y' then

         if l_jobcatg = 'Y'
         then
            l_rev_cur_nh       := l_rev_cur_nh    + l_abv;
         else
            l_nonrev_cur_nh    := l_nonrev_cur_nh + l_abv;
         end if;

      end if;

   end if;

   end loop; -- get_assignment_start_end

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_end_val   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_end_val + nvl(l_rev_end_val,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_end_val   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_end_val + nvl(l_nonrev_end_val,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_transfer_in   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_transfer_in + nvl(l_rev_transfer_in,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_transfer_in   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_transfer_in + nvl(l_nonrev_transfer_in,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_nh   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_nh + nvl(l_rev_nh,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_nh   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_nh + nvl(l_nonrev_nh,0);


   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cur_nh   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cur_nh + nvl(l_rev_cur_nh,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cur_nh   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cur_nh + nvl(l_nonrev_cur_nh,0);


   l_rev_transfer_in    := 0;
   l_nonrev_transfer_in	:= 0;
   l_rev_nh 	        := 0;
   l_nonrev_nh	        := 0;
   l_rev_cur_nh 	:= 0;
   l_nonrev_cur_nh	:= 0;

   --	For the Current Organization


   for assgt_rec in get_assignment
		( P_DATE_FROM
		, P_DATE_TO
		, P_TOP_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID
		, P_WORKER_TYPE
		, P_INCLUDE_ASG_TYPE)

   loop -- get_assignment

   hr_utility.set_location('Top Org New Hire = '||l_cur_nh,930);
   hr_utility.set_location('Top Org assgt_rec.assignment_id = '||to_char(assgt_rec.assignment_id),940);
   hr_utility.set_location('assgt_rec.effective_start_date = '||to_char(assgt_rec.effective_start_date,'DD/MM/YYYY'),950);

   if assgt_rec.assignment_type <> 'C' then
   l_pertype := NULL;
   l_pertype := HR_PERSON_FLEX_LOGIC.GetAsgWorkerType
	 (p_AsgWorkerType_formula_id  => l_AsgWorkerType_formula_id
	 ,p_assignment_id         	=> assgt_rec.assignment_id
	 ,p_effective_date        	=> assgt_rec.effective_start_date
	 ,p_session_date          	=> trunc(sysdate)
	 );
   end if;

   hr_utility.set_location('Top Org AsgWorkerType = '||l_pertype,960);

   l_jobcatg := NULL;
   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (assgt_rec.job_id
                                ,p_job_category);
   l_abv     := 0;
   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  			( p_ABV_formula_id  => l_ABV_formula_id
    			, p_ABV             => p_budget
	 		, p_assignment_id   => assgt_rec.assignment_id
	   		, p_effective_date  => assgt_rec.effective_start_date
			, p_session_date    => trunc(sysdate) );

 hr_utility.set_location('Top Org l_abv = '||l_abv,970);
 hr_utility.set_location('Top Org l_jobcatg = '||l_jobcatg,980);
 hr_utility.set_location('Top Org l_pertype = '||l_pertype,990);

	if l_pertype = 'P' then
        if l_jobcatg = 'Y'
        then
	l_rev_perm       := l_rev_perm    + l_abv;
	else
	l_nonrev_perm    := l_nonrev_perm + l_abv;
	end if;

 hr_utility.set_location('Top Org Rev Perm = '||to_char(l_rev_perm),1000);
 hr_utility.set_location('Top Org NonRev Perm = '||to_char(l_nonrev_perm),1010);

	elsif l_pertype = 'T' then
        if l_jobcatg = 'Y'
        then
	l_rev_temp       := l_rev_temp    + l_abv;
	else
	l_nonrev_temp    := l_nonrev_temp + l_abv;
	end if;

        elsif  l_cwk_profile = 'N' then

         if l_pertype = 'C' then

         if l_jobcatg = 'Y'
         then
            l_rev_cont       := l_rev_cont    + l_abv;
         else
            l_nonrev_cont    := l_nonrev_cont + l_abv;
         end if;


	end if;

	end if;

	if (l_cwk_profile = 'Y' and
            assgt_rec.assignment_type = 'C') then

	if l_jobcatg = 'Y'
	then
	l_rev_cont       := l_rev_cont    + l_abv;
	else
	l_nonrev_cont    := l_nonrev_cont + l_abv;
	end if;

	end if;


	end loop; -- get_assignment

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_perm   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_perm + nvl(l_rev_perm,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_perm   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_perm + nvl(l_nonrev_perm,0);

   l_rev_perm 	  := 0;
   l_nonrev_perm  := 0;

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_temp   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_temp + nvl(l_rev_temp,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_temp   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_temp + nvl(l_nonrev_temp,0);


   l_rev_temp 	  := 0;
   l_nonrev_temp  := 0;

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cont   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cont + nvl(l_rev_cont,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cont   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cont + nvl(l_nonrev_cont,0);


   l_rev_cont 	 := 0;
   l_nonrev_cont := 0;

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_open_offers   := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_open_offers   := 0;

   l_rev_open_offers := 0;
   l_nonrev_open_offers := 0;

   for appl_open_offers_rec in get_open_offers
	( P_DATE_FROM
	, P_DATE_TO
	, P_TOP_ORGANIZATION_ID
	, P_BUSINESS_GROUP_ID)

   loop -- get_open_offers

   l_jobcatg := NULL;
   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                       (appl_open_offers_rec.job_id
                       ,p_job_category);

   if l_jobcatg = 'Y'
   then
      l_rev_open_offers       := l_rev_open_offers    + 1;
   else
      l_nonrev_open_offers    := l_nonrev_open_offers + 1;
   end if;

   end loop; -- get_open_offers

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_open_offers   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_open_offers + nvl(l_rev_open_offers,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_open_offers   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_open_offers + nvl(l_nonrev_open_offers,0);


   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_accepted_offers   := 0;
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_accepted_offers   := 0;

   l_rev_accepted_offers := 0;
   l_nonrev_accepted_offers := 0;

   for appl_accepted_offers_rec in get_accepted_offers
		( P_DATE_FROM
		, P_DATE_TO
		, P_TOP_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID)

   loop -- get_accepted_offers

   l_jobcatg := NULL;
   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                   (appl_accepted_offers_rec.job_id
                   ,p_job_category);

   if l_jobcatg = 'Y'
   then
      l_rev_accepted_offers       := l_rev_accepted_offers    + 1;
   else
      l_nonrev_accepted_offers    := l_nonrev_accepted_offers + 1;
   end if;

   end loop; -- get_accepted_offers

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_accepted_offers   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_accepted_offers + nvl(l_rev_accepted_offers,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_accepted_offers   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_accepted_offers + nvl(l_nonrev_accepted_offers,0);


   l_rev_vacant_FTE	:=0;
   l_nonrev_vacant_FTE	:=0;

   for vac_rec in get_requisitions
		(P_BUSINESS_GROUP_ID
		,P_TOP_ORGANIZATION_ID
		,P_BUDGET
		,P_DATE_TO )
   loop
   l_jobcatg := NULL;

   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
				(vac_rec.job_id
				,p_job_category);

   if vac_rec.budget_measurement_value <> 0
	and vac_rec.number_of_openings <> 0
   then
      l_vacant_FTE := vac_rec.budget_measurement_value / vac_rec.number_of_openings;
   end if;

   if l_jobcatg = 'Y'
   then
      l_rev_vacant_FTE     := l_rev_vacant_FTE    + l_vacant_FTE;
   else
      l_nonrev_vacant_FTE  := l_nonrev_vacant_FTE + l_vacant_FTE;
   end if;

   end loop; -- get_requisitions

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vacant_FTE   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vacant_FTE + nvl(l_rev_vacant_FTE,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vacant_FTE   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vacant_FTE + nvl(l_nonrev_vacant_FTE,0);

   l_rev_cur_term  	:=0;
   l_nonrev_cur_term 	:=0;


   if P_WORKER_TYPE <> 'C'  then

   for cur_term_rec in get_cur_terminations
		( P_DATE_FROM
		, l_cur_date_from
		, l_cur_date_to
		, P_TOP_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID)

   loop -- get_cur_terminations

   l_jobcatg := NULL;
   l_abv     := NULL;

   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => cur_term_rec.assignment_id
                        , p_effective_date  => cur_term_rec.actual_termination_date
                        , p_session_date    => trunc(sysdate) );


   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                               (cur_term_rec.job_id
                               ,p_job_category);

   if l_jobcatg = 'Y'
   then
      l_rev_cur_term       := l_rev_cur_term    + l_abv;
   else
      l_nonrev_cur_term    := l_nonrev_cur_term + l_abv;
   end if;

   end loop; -- get_cur_terminations

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cur_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cur_term + nvl(l_rev_cur_term,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cur_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cur_term + nvl(l_nonrev_cur_term,0);


   l_rev_vol_term	:=0;
   l_nonrev_vol_term	:=0;
   l_rev_invol_term	:=0;
   l_nonrev_invol_term	:=0;

   for term_rec in get_terminations
		( P_DATE_FROM
		, P_DATE_TO
		, P_TOP_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID)

   loop -- get_terminations

   l_termtype:= NULL;
   l_termtype:= HR_PERSON_FLEX_LOGIC.GetTermType
				(p_term_formula_id => l_term_formula_id
				,p_leaving_reason  => term_rec.leaving_reason
				,p_session_date	   => trunc(sysdate));

   hr_utility.set_location('Term Type = '||l_termtype,400);

   l_jobcatg := NULL;
   l_abv     := NULL;

   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => term_rec.assignment_id
                        , p_effective_date  => term_rec.actual_termination_date
                        , p_session_date    => trunc(sysdate) );


   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (term_rec.job_id
                                ,p_job_category);

   hr_utility.set_location('Job Categ = '||l_jobcatg,410);

   if l_termtype = 'V'
   then
      if l_jobcatg = 'Y'
      then
         l_rev_vol_term       := l_rev_vol_term    + l_abv;
      else
         l_nonrev_vol_term    := l_nonrev_vol_term + l_abv;
      end if;
   elsif l_termtype = 'I'
   then
      if l_jobcatg = 'Y'
      then
         l_rev_invol_term       := l_rev_invol_term    + l_abv;
      else
         l_nonrev_invol_term    := l_nonrev_invol_term + l_abv;
      end if;
   end if;

   end loop; -- get_terminations

   hr_utility.set_location('Rev Vol T = '||l_rev_vol_term,420);
   hr_utility.set_location('NONRev Vol T = '||l_nonrev_vol_term,430);

   end if;

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vol_term :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vol_term +
                                                                   nvl(l_rev_vol_term,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vol_term :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vol_term +
                                                                   nvl(l_nonrev_vol_term,0);


   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_invol_term :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_invol_term +
                                                                   nvl(l_rev_invol_term,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_invol_term :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_invol_term +
                                                                   nvl(l_nonrev_invol_term,0);

   if P_WORKER_TYPE <> 'E'  then

   for cur_term_rec in get_cur_terminations_cwk
		( P_DATE_FROM
		, l_cur_date_from
		, l_cur_date_to
		, P_TOP_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID)

   loop -- get_cur_terminations_cwk

   l_jobcatg := NULL;
   l_abv     := NULL;

   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => cur_term_rec.assignment_id
                        , p_effective_date  => cur_term_rec.actual_termination_date
                        , p_session_date    => trunc(sysdate) );


   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                               (cur_term_rec.job_id
                               ,p_job_category);

      if l_jobcatg = 'Y'
      then
         l_rev_cur_term       := l_rev_cur_term    + l_abv;
      else
         l_nonrev_cur_term    := l_nonrev_cur_term + l_abv;
      end if;

   end loop; -- get_cur_terminations_cwk

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cur_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_cur_term + nvl(l_rev_cur_term,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cur_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_cur_term + nvl(l_nonrev_cur_term,0);


   l_rev_vol_term	:=0;
   l_nonrev_vol_term	:=0;
   l_rev_invol_term	:=0;
   l_nonrev_invol_term	:=0;

   for term_rec in get_terminations_cwk
		( P_DATE_FROM
		, P_DATE_TO
		, P_TOP_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID)

   loop -- get_terminations_cwk

   l_jobcatg := NULL;
   l_abv     := NULL;

   l_cwk_termtype := NULL;
   l_cwk_termtype := HR_PERSON_FLEX_LOGIC.GetTermType
                            (p_term_formula_id      => l_cwk_term_formula_id
                            ,p_leaving_reason       => term_rec.termination_reason
                            ,p_session_date         => trunc(sysdate));

   l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => term_rec.assignment_id
                        , p_effective_date  => term_rec.actual_termination_date
                        , p_session_date    => trunc(sysdate) );


   l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (term_rec.job_id
                                ,p_job_category);

   hr_utility.set_location('Job Categ = '||l_jobcatg,410);

   if l_cwk_termtype = 'V'
   then
      if l_jobcatg = 'Y'
      then
         l_rev_vol_term       := l_rev_vol_term    + l_abv;
      else
         l_nonrev_vol_term    := l_nonrev_vol_term + l_abv;
      end if;
   elsif l_cwk_termtype = 'I'
   then
      if l_jobcatg = 'Y'
      then
         l_rev_invol_term       := l_rev_invol_term    + l_abv;
      else
         l_nonrev_invol_term    := l_nonrev_invol_term + l_abv;
      end if;
   end if;

   end loop; -- get_terminations

   hr_utility.set_location('Rev Vol T = '||l_rev_vol_term,420);
   hr_utility.set_location('NONRev Vol T = '||l_nonrev_vol_term,430);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vol_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vol_term + nvl(l_rev_vol_term,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vol_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vol_term + nvl(l_nonrev_vol_term,0);


   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_invol_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_invol_term + nvl(l_rev_invol_term,0);

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_invol_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_invol_term + nvl(l_nonrev_invol_term,0);

   if P_WORKER_TYPE = 'B' then

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vol_term   :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_vol_term +
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).rev_invol_term;

   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vol_term :=
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_vol_term +
   HQOrgData(1-(osv_rec.org_structure_version_id+P_TOP_ORGANIZATION_ID)).nonrev_invol_term;

   end if;

   end if;

   hr_utility.set_location(' End of P_INCLUDE_TOP_ORG = Y',1000);

   end if; -- if P_INCLUDE_TOP_ORG = 'Y'

   hr_utility.set_location(' Out of P_INCLUDE_TOP_ORG = Y',1000);

   end loop; -- get_org_structure_version

   hr_utility.set_location(' Out of get_org_structure_version ',1000);
   hr_utility.set_location('  ',1000);
   hr_utility.set_location('*Organiz*STAR*PERM*CONT*TEMP*CuNH*NewH*TrIN*TrOt*VoTM*InTM*ENDV*',8000);

   for all_org_rec in c_get_all_orgs
    (P_ORGANIZATION_STRUCTURE_ID
    ,P_TOP_ORGANIZATION_ID
    ,P_REPORT_DATE_FROM
    ,P_REPORT_DATE_TO)

   loop

   hr_utility.set_location('  ',8000);
 hr_utility.set_location('R'||lpad(to_char(all_org_rec.organization_id_child),7,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_start_val,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_perm,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_cont,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_temp,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_cur_nh,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_nh,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_transfer_in,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_transfer_out,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_vol_term,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_invol_term,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).rev_end_val,4,'*'),8000);

 hr_utility.set_location('N'||lpad(to_char(all_org_rec.organization_id_child),7,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_start_val,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_perm,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_cont,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_temp,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_cur_nh,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_nh,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_transfer_in,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_transfer_out,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_vol_term,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_invol_term,4,'.')||
 '*'||
 lpad(HQOrgData(all_org_rec.org_structure_element_id).nonrev_end_val,4,'*'),8000);

   end loop;

   if P_INCLUDE_TOP_ORG = 'Y' then

   hr_utility.set_location(' ',10000);
   hr_utility.set_location('start of c_get_top_orgs',10000);
   hr_utility.set_location(' ',10000);
   hr_utility.set_location('*Organiz*STAR*PERM*CONT*TEMP*CuNH*NewH*TrIN*TrOt*VoTM*InTM*ENDV*',8000);

   for all_top_org_rec in c_get_top_orgs
    (P_ORGANIZATION_STRUCTURE_ID
    ,P_TOP_ORGANIZATION_ID
    ,P_REPORT_DATE_FROM
    ,P_REPORT_DATE_TO)

   loop

   -- hr_utility.set_location('Top Org == '||all_top_org_rec.org_structure_element_id,10000);
 hr_utility.set_location('R'||lpad(to_char(all_top_org_rec.organization_id_child),7,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_start_val,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_perm,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_cont,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_temp,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_cur_nh,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_nh,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_transfer_in,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_transfer_out,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_vol_term,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_invol_term,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).rev_end_val,4,'.'),8000);

 hr_utility.set_location('N'||lpad(to_char(all_top_org_rec.organization_id_child),7,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_start_val,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_perm,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_cont,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_temp,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_cur_nh,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_nh,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_transfer_in,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_transfer_out,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_vol_term,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_invol_term,4,'.')||
 '*'||
 lpad(HQOrgData(all_top_org_rec.org_structure_element_id).nonrev_end_val,4,'.'),8000);
   hr_utility.set_location('  ',10000);


   end loop; -- c_get_top_orgs

   end if; -- if P_INCLUDE_TOP_ORG = 'Y'

 hr_utility.set_location('end populate_headcount_table',9999);

end populate_headcount_table;

END HR_HEAD_COUNT;

/
