--------------------------------------------------------
--  DDL for Package Body HR_HEAD_COUNT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HEAD_COUNT_SUMMARY" AS
/* $Header: perhdsum.pkb 115.11 2003/07/07 18:22:12 asahay noship $ */

--
function get_rev_start_val(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).rev_start_val);
exception
when others then
  return (0);
end;
--
function get_nonrev_start_val(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).nonrev_start_val);
exception
when others then
  return (0);
end;
--
function get_rev_end_val(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).rev_end_val);
exception
when others then
  return (0);
end;
--
function get_nonrev_end_val(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).nonrev_end_val);
exception
when others then
  return (0);
end;
--
function get_rev_net_change(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).rev_end_val-HQOrgData(p_organization_id).rev_start_val);
exception
when others then
  return (0);
end;
--
function get_nonrev_net_change(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).nonrev_end_val-HQOrgData(p_organization_id).nonrev_start_val);
exception
when others then
  return (0);
end;
--
function get_rev_nh(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).rev_nh);
exception
when others then
  return (0);
end;
--
function get_nonrev_nh(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).nonrev_nh);
exception
when others then
  return (0);
end;
--
function get_rev_term(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).rev_term);
exception
when others then
  return (0);
end;
--
function get_nonrev_term(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).nonrev_term);
exception
when others then
  return (0);
end;
--
--
function get_rev_other_net(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).rev_end_val-HQOrgData(p_organization_id).rev_start_val-HQOrgData(p_organization_id).rev_nh+HQOrgData(p_organization_id).rev_term);
exception
when others then
  return (0);
end;
--
function get_nonrev_other_net(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).nonrev_end_val-HQOrgData(p_organization_id).nonrev_start_val-HQOrgData(p_organization_id).nonrev_nh+HQOrgData(p_organization_id).nonrev_term);
exception
when others then
  return (0);
end;
--

procedure populate_summary_table
( P_BUSINESS_GROUP_ID 		IN NUMBER
, P_TOP_ORGANIZATION_ID 	IN NUMBER
, P_ORGANIZATION_STRUCTURE_ID	IN NUMBER
, P_BUDGET 			IN VARCHAR2
, P_ROLL_UP 			IN VARCHAR2
, P_INCLUDE_TOP_ORG		IN VARCHAR2
, P_REPORT_DATE_FROM 		IN DATE
, P_REPORT_DATE_TO 		IN DATE
, P_REPORT_DATE			IN DATE
, P_INCLUDE_ASG_TYPE		IN VARCHAR2
, P_JOB_CATEGORY		IN VARCHAR2 default 'RG'
)
is
cursor 	get_all_organizations
(P_ORGANIZATION_STRUCTURE_ID    NUMBER
,P_TOP_ORGANIZATION_ID		NUMBER
,P_REPORT_DATE_FROM             DATE
,P_REPORT_DATE_TO               DATE)
is
select 	distinct pose.ORGANIZATION_ID_CHILD organization_id
from    per_org_structure_elements pose
where   exists (select 1
from    per_org_structure_versions posv
where   posv.org_structure_version_id 	= pose.org_structure_version_id
and     posv.organization_structure_id 	= P_ORGANIZATION_STRUCTURE_ID
and     (posv.date_from <= P_REPORT_DATE_FROM
or     	nvl(posv.date_to,to_date('31/12/4712','DD/MM/YYYY'))
				>= P_REPORT_DATE_TO ))
and     pose.organization_id_parent 	= P_TOP_ORGANIZATION_ID
union
select  P_TOP_ORGANIZATION_ID
from    sys.dual
where   P_INCLUDE_TOP_ORG = 'Y';

cursor	get_org_structure_version
(P_ORGANIZATION_STRUCTURE_ID	NUMBER
,P_REPORT_DATE_FROM		DATE
,P_REPORT_DATE_TO		DATE)
is
select 	 posv.org_structure_version_id
	,posv.date_from date_from
	,nvl(posv.date_to,to_date('31/12/4712','DD/MM/YYYY')) date_to
from 	per_org_structure_versions posv
where 	posv.organization_structure_id = P_ORGANIZATION_STRUCTURE_ID
and 	(P_REPORT_DATE_FROM between posv.date_from and
	nvl(posv.date_to,to_date('31/12/4712','DD/MM/YYYY'))
	or posv.date_from between P_REPORT_DATE_FROM and P_REPORT_DATE_TO)
order by   posv.org_structure_version_id
	  ,posv.date_from
	  ,posv.date_to;

cursor    get_org_structure_element
(P_ORG_STRUCTURE_VERSION_ID	NUMBER
,P_TOP_ORGANIZATION_ID		NUMBER)
is
select  ose.org_structure_element_id,
	ose.organization_id_child organization_id1
from    per_org_structure_elements ose
where   ose.org_structure_version_id +0    = P_ORG_STRUCTURE_VERSION_ID
and     ose.organization_id_parent         = P_TOP_ORGANIZATION_ID
order by ose.organization_id_child;

cursor	get_organizations
( P_ORG_STRUCTURE_VERSION_ID  	NUMBER
, P_ORGANIZATION_ID  		NUMBER
, P_ROLL_UP 			VARCHAR2)
is
select 	ose.organization_id_child organization_id2
from   	per_org_structure_elements ose
where  	ose.org_structure_version_id +0  	= P_ORG_STRUCTURE_VERSION_ID
and	P_ROLL_UP				= 'Y'
connect by prior ose.organization_id_child 	= ose.organization_id_parent
and    	ose.org_structure_version_id  		= P_ORG_STRUCTURE_VERSION_ID
start with ose.organization_id_parent 		= P_ORGANIZATION_ID
and    	ose.org_structure_version_id  		= P_ORG_STRUCTURE_VERSION_ID
UNION
select 	P_ORGANIZATION_ID organization_id
from	dual
where	P_ROLL_UP                          = 'Y'
UNION
select 	P_ORGANIZATION_ID organization_id
from	dual
where	P_ROLL_UP                          = 'N';

cursor	get_assignment_start_end
( P_EFFECTIVE_DATE		DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
select 	paf.assignment_id
       ,paf.job_id
       ,paf.effective_start_date
       ,paf.assignment_type
from 	per_all_assignments_f 		paf,
	per_assignment_status_types 	past
where 	paf.organization_id 	= 	P_ORGANIZATION_ID_CHILD
   and     P_EFFECTIVE_DATE  between paf.effective_start_date
                                 and paf.effective_end_date
   and     paf.assignment_status_type_id = past.assignment_status_type_id
   and     (
           (paf.assignment_type = 'E'
           and (
              (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_ASSIGN')
           OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_ASSIGN')
           OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_ASSIGN',
                                                                       'SUSP_ASSIGN'))
               )
           )
           OR
           (paf.assignment_type =  'C'
           and (
              (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_CWK')
           OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_CWK_ASG')
           OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_CWK',
                                                                       'SUSP_CWK_ASG'))
              )
           )
           );


cursor	get_assignment
( P_DATE_FROM			DATE
, P_DATE_TO			DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
select 	paf.assignment_id
       ,paf.job_id
       ,paf.effective_start_date
       ,paf.assignment_type
from 	per_all_assignments_f 		paf,
	per_assignment_status_types 	past
where 	paf.organization_id 	= 	p_organization_id_child
and     paf.effective_start_date     <= P_DATE_FROM
and     paf.assignment_status_type_id = past.assignment_status_type_id
and     P_DATE_TO <= (select max(paf1.effective_end_date)
                      from   per_all_assignments_f          paf1
                            ,per_assignment_status_types    past1
                      where  paf.assignment_id              = paf1.assignment_id
                      and    paf1.assignment_status_type_id = past1.assignment_status_type_id
                      and    past.per_system_status         = past1.per_system_status)
and     (
        (paf.assignment_type = 'E'
         and (
             (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_ASSIGN')
          OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_ASSIGN')
          OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_ASSIGN',
                                                                      'SUSP_ASSIGN'))
             )
           )
           OR
          (paf.assignment_type =  'C'
           and (
              (P_INCLUDE_ASG_TYPE = 'A' and past.per_system_status = 'ACTIVE_CWK')
           OR (P_INCLUDE_ASG_TYPE = 'S' and past.per_system_status = 'SUSP_CWK_ASG')
           OR (P_INCLUDE_ASG_TYPE = 'B' and past.per_system_status IN ('ACTIVE_CWK',
                                                                       'SUSP_CWK_ASG'))
               )
           )
           );


cursor	get_terminations
( P_DATE_FROM			DATE
, P_DATE_TO			DATE
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
select  paf.job_id
from     per_periods_of_service pos
	,per_all_assignments_f 	 paf
where   pos.date_start                  <= P_DATE_FROM
and     pos.actual_termination_date is not null
and     pos.actual_termination_date between P_DATE_FROM and P_DATE_TO
and     pos.period_of_service_id        = paf.period_of_service_id
and	paf.assignment_type		= 'E'
and	paf.primary_flag		= 'Y'
and     paf.organization_id  		= P_ORGANIZATION_ID_CHILD
and     paf.effective_start_date in
				(select max(paf1.effective_start_date)
				from 	per_all_assignments_f paf1
				where 	paf1.assignment_id = paf.assignment_id
				and 	paf1.effective_end_date
						between P_DATE_FROM
						and  P_DATE_TO)
UNION
select paf.job_id
from   per_periods_of_placement       pop
      ,per_all_assignments_f  paf
where  pop.date_start          <= P_DATE_FROM
and    pop.actual_termination_date is not null
and    pop.actual_termination_date between P_DATE_FROM
                                          and P_DATE_TO
and    pop.date_start = paf.period_of_placement_date_start
and    paf.effective_end_date   = pop.actual_termination_date
and    paf.assignment_type      = 'C'
and    paf.primary_flag		= 'Y'
and    paf.organization_id      = P_ORGANIZATION_ID_CHILD
and    paf.effective_start_date in
                                (select max(paf1.effective_start_date)
                                from    per_all_assignments_f paf1
                                where   paf1.assignment_id = paf.assignment_id
                                and     paf1.effective_end_date
                                                between P_DATE_FROM
                                                and  P_DATE_TO);

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

l_ABV_formula_id   			number;
l_ABV   	 			number;
l_jobcatg     	 			varchar2(1);
l_budget     	 			varchar2(30);
l_rev_start_val 			number := 0;
l_rev_end_val 	 			number := 0;
l_nonrev_start_val 			number := 0;
l_nonrev_end_val  			number := 0;
l_rev_nh  				number := 0;
l_nonrev_nh  				number := 0;
l_rev_term  				number := 0;
l_nonrev_term  				number := 0;
l_movement_category			varchar2(30);
P_DATE_FROM  				date;
P_DATE_TO  				date;
l_min_org_structure_version_id		number;
l_max_org_structure_version_id		number;
l_min_date_from 			date;
l_min_date_to    			date;
l_max_date_from 			date;
l_max_date_to    			date;

begin

 hr_utility.set_location('Look for ABV Formula - 1',10);

/* Look for ABV Formula */

  open  c_get_ABV_formula(p_business_group_id);

  fetch c_get_ABV_formula into l_ABV_formula_id;

   hr_utility.set_location('ABV Formula ID = '||l_ABV_formula_id,20);

  if (c_get_ABV_formula%notfound)

  then

    close c_get_ABV_formula;

     hr_utility.set_location('c_get_ABV_formula Not Found - 2',30);

    /* If the ABV formula does not exist, look for the template formula */

    open c_get_tmplt_ABV_formula;

    fetch c_get_tmplt_ABV_formula into l_ABV_formula_id;

     hr_utility.set_location('Template ABV Formula = '||l_ABV_formula_id,40);

    if (c_get_tmplt_ABV_formula%notfound)

    then

      close c_get_tmplt_ABV_formula;

       hr_utility.set_location('c_get_tmpt_ABV_formula Not Found - 3',50);

      -- Set to null so that we can calculate values differently later

      l_ABV_formula_id := null;

    else

      close c_get_tmplt_ABV_formula;

       hr_utility.set_location('close c_get_tmpt_ABV_formula - 4',60);

    end if;

  else

    close c_get_ABV_formula;

     hr_utility.set_location('close c_get_ABV_formula - 5',70);

  end if;



 hr_utility.set_location('P_BUSINESS_GROUP_ID='||to_char(P_BUSINESS_GROUP_ID),80);
 hr_utility.set_location('P_TOP_ORGANIZATION_ID='||to_char(P_TOP_ORGANIZATION_ID),90);
 hr_utility.set_location('P_ORGANIZATION_STRUCTURE_ID='||to_char(P_ORGANIZATION_STRUCTURE_ID),100);
 hr_utility.set_location('P_REPORT_DATE_FROM='||to_char(P_REPORT_DATE_FROM,'DD-MON-YYYY'),110);
 hr_utility.set_location('P_REPORT_DATE_TO='||to_char(P_REPORT_DATE_TO,'DD-MON-YYYY'),120);
 hr_utility.set_location('P_REPORT_DATE='||to_char(P_REPORT_DATE,'DD-MON-YYYY'),130);
 hr_utility.set_location('P_JOB_CATEGORY='||P_JOB_CATEGORY,140);
 hr_utility.set_location('P_INCLUDE_TOP_ORG='||P_INCLUDE_TOP_ORG,150);

begin

select  min(posv.org_structure_version_id)
into	l_min_org_structure_version_id
from    per_org_structure_versions posv
where   posv.organization_structure_id = P_ORGANIZATION_STRUCTURE_ID
and 	P_REPORT_DATE_FROM between posv.date_from
	and nvl(posv.date_to,to_date('31/12/4712','DD/MM/YYYY'));

 hr_utility.set_location('min_org_structure_version_id='||l_min_org_structure_version_id,160);

select  greatest(posv.date_from,P_REPORT_DATE_FROM),
	least(nvl(posv.date_to,P_REPORT_DATE_TO),P_REPORT_DATE_TO)
into	l_min_date_from,l_min_date_to
from    per_org_structure_versions posv
where   posv.org_structure_version_id = l_min_org_structure_version_id;

 hr_utility.set_location('l_min_date_from='||l_min_date_from,170);
 hr_utility.set_location('l_min_date_to='||l_min_date_to,180);

select  max(posv.org_structure_version_id)
into    l_max_org_structure_version_id
from    per_org_structure_versions posv
where   posv.organization_structure_id = P_ORGANIZATION_STRUCTURE_ID
and 	P_REPORT_DATE_TO between posv.date_from
	and nvl(posv.date_to,to_date('31/12/4712','DD/MM/YYYY'));

 hr_utility.set_location('max_org_structure_version_id='||l_max_org_structure_version_id,190);

select  least(nvl(posv.date_to,P_REPORT_DATE_TO),P_REPORT_DATE_TO),
	greatest(posv.date_from,P_REPORT_DATE_FROM)
into	l_max_date_to,l_max_date_from
from    per_org_structure_versions posv
where   posv.org_structure_version_id = l_max_org_structure_version_id;

exception
when NO_DATA_FOUND then
raise;
end;

 hr_utility.set_location('l_max_date_from='||l_max_date_from,200);
 hr_utility.set_location('l_max_date_to='||l_max_date_to,210);

for all_organizations_rec in get_all_organizations
(P_ORGANIZATION_STRUCTURE_ID
,P_TOP_ORGANIZATION_ID
,P_REPORT_DATE_FROM
,P_REPORT_DATE_TO)
loop

HQOrgData(all_organizations_rec.organization_id).rev_start_val		:= 0;
HQOrgData(all_organizations_rec.organization_id).rev_end_val 		:= 0;
HQOrgData(all_organizations_rec.organization_id).nonrev_start_val	:= 0;
HQOrgData(all_organizations_rec.organization_id).nonrev_end_val 	:= 0;
HQOrgData(all_organizations_rec.organization_id).rev_nh  		:= 0;
HQOrgData(all_organizations_rec.organization_id).nonrev_nh  		:= 0;
HQOrgData(all_organizations_rec.organization_id).rev_term		:= 0;
HQOrgData(all_organizations_rec.organization_id).nonrev_term		:= 0;

 hr_utility.set_location('all_organizations_rec.organization_id='||all_organizations_rec.organization_id,220);
 hr_utility.set_location('rev_start_val='||HQOrgData(all_organizations_rec.organization_id).rev_start_val,230);
 hr_utility.set_location('rev_end_val='||HQOrgData(all_organizations_rec.organization_id).rev_end_val,240);
 hr_utility.set_location('nonrev_start_val='||HQOrgData(all_organizations_rec.organization_id).nonrev_start_val,250);
 hr_utility.set_location('nonrev_end_val='||HQOrgData(all_organizations_rec.organization_id).nonrev_end_val,260);

end loop;


for  org_str_ele in get_org_structure_element
(l_min_org_structure_version_id
,P_TOP_ORGANIZATION_ID
)

loop  -- get_org_structure_element

 hr_utility.set_location('org_str_ele.organization_id1='||org_str_ele.organization_id1,270);

l_rev_start_val         :=0;
l_nonrev_start_val      :=0;

for  start_orgs_rec in get_organizations
(l_min_org_structure_version_id
,org_str_ele.organization_id1
,P_ROLL_UP)

loop  -- get_organizations

 hr_utility.set_location('start_orgs_rec.organization_id2='||start_orgs_rec.organization_id2,280);

for asg_start_rec in get_assignment_start_end
(l_min_date_from
,start_orgs_rec.organization_id2
,P_BUSINESS_GROUP_ID
)
loop  -- get_assignment_start_end

 hr_utility.set_location('asg_start_rec.assignment_id='||asg_start_rec.assignment_id,290);


        l_jobcatg := NULL;
        l_abv   := NULL;

        l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                         ( p_ABV_formula_id  => l_ABV_formula_id
                         , p_ABV             => p_budget
                         , p_assignment_id   => asg_start_rec.assignment_id
                         , p_effective_date  => asg_start_rec.effective_start_date
                         , p_session_date    => trunc(sysdate) );

 hr_utility.set_location('l_abv='||l_abv,300);


        l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (asg_start_rec.job_id
                                ,p_job_category);

        if l_jobcatg = 'Y'
        then

        l_rev_start_val       := l_rev_start_val + l_abv;
        else

        l_nonrev_start_val    := l_nonrev_start_val + l_abv;
        end if;

	end loop; -- get_assignment_start_end

	end loop; -- get_organizations


HQOrgData(org_str_ele.organization_id1).rev_start_val		:=
HQOrgData(org_str_ele.organization_id1).rev_start_val+ l_rev_start_val;
HQOrgData(org_str_ele.organization_id1).nonrev_start_val 		:=
HQOrgData(org_str_ele.organization_id1).nonrev_start_val+l_nonrev_start_val;

 hr_utility.set_location('org_str_ele.organization_id1='||org_str_ele.organization_id1,310);
 hr_utility.set_location('rev_start_val='||HQOrgData(org_str_ele.organization_id1).rev_start_val,320);
 hr_utility.set_location('nonrev_start_val='||HQOrgData(org_str_ele.organization_id1).nonrev_start_val,330);

	end loop; -- get_org_structure_element

 hr_utility.set_location('100',340);

for  org_str_ele in get_org_structure_element
(l_max_org_structure_version_id
,P_TOP_ORGANIZATION_ID
)

loop -- get_org_structure_element

 hr_utility.set_location('end.org_str_ele.organization_id1='||org_str_ele.organization_id1,350);

l_rev_end_val         :=0;
l_nonrev_end_val      :=0;

for  end_orgs_rec in get_organizations
(l_max_org_structure_version_id
,org_str_ele.organization_id1
,P_ROLL_UP)

loop -- get_organizations

 hr_utility.set_location('end_orgs_rec.organization_id2='||end_orgs_rec.organization_id2,360);

for asg_end_rec in get_assignment_start_end
(l_max_date_to
,end_orgs_rec.organization_id2
,P_BUSINESS_GROUP_ID
)
loop  -- get_assignment_start_end

 hr_utility.set_location('asg_end_rec.assignment_id='||asg_end_rec.assignment_id,370);


        l_jobcatg := NULL;
        l_abv   := NULL;

        l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                         ( p_ABV_formula_id  => l_ABV_formula_id
                         , p_ABV             => p_budget
                         , p_assignment_id   => asg_end_rec.assignment_id
                         , p_effective_date  => asg_end_rec.effective_start_date
                         , p_session_date    => trunc(sysdate) );


 hr_utility.set_location('l_abv='||l_abv,380);

        l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (asg_end_rec.job_id
                                ,p_job_category);

        if l_jobcatg = 'Y'
        then

        l_rev_end_val       := l_rev_end_val + l_abv;
        else

        l_nonrev_end_val    := l_nonrev_end_val + l_abv;
        end if;

	end loop; -- get_assignment_start_end

	end loop; -- get_organizations

HQOrgData(org_str_ele.organization_id1).rev_end_val		:=
HQOrgData(org_str_ele.organization_id1).rev_end_val+ l_rev_end_val;
HQOrgData(org_str_ele.organization_id1).nonrev_end_val 		:=
HQOrgData(org_str_ele.organization_id1).nonrev_end_val+l_nonrev_end_val;

 hr_utility.set_location('org_str_ele.organization_id1='||org_str_ele.organization_id1,390);
 hr_utility.set_location('rev_end_val='||HQOrgData(org_str_ele.organization_id1).rev_end_val,400);
 hr_utility.set_location('nonrev_end_val='||HQOrgData(org_str_ele.organization_id1).nonrev_end_val,410);

	end loop; -- get_org_structure_element

--  Start of New Hires and Terminations Count

for org_structure_version_rec in get_org_structure_version
(P_ORGANIZATION_STRUCTURE_ID
,P_REPORT_DATE_FROM
,P_REPORT_DATE_TO)
loop

 hr_utility.set_location('org_structure_version_rec.date_from ='||org_structure_version_rec.date_from,420);
 hr_utility.set_location('org_structure_version_rec.date_to ='||org_structure_version_rec.date_to,430);
if P_REPORT_DATE_FROM > org_structure_version_rec.date_from then
P_DATE_FROM := P_REPORT_DATE_FROM;
else
P_DATE_FROM :=org_structure_version_rec.date_from;
end if;

 hr_utility.set_location('P_DATE_FROM='||P_DATE_FROM,440);

if P_REPORT_DATE_TO < org_structure_version_rec.date_to then
P_DATE_TO := P_REPORT_DATE_TO;
else
P_DATE_TO := org_structure_version_rec.date_to;
end if;

 hr_utility.set_location('P_DATE_TO='||P_DATE_TO,450);

for org_structure_element_rec in get_org_structure_element
(org_structure_version_rec.org_structure_version_id
,P_TOP_ORGANIZATION_ID)
loop


 hr_utility.set_location('org_structure_version_rec.org_structure_version_id='||org_structure_version_rec.org_structure_version_id,460);
 hr_utility.set_location('org_structure_element_rec.organization_id1='||org_structure_element_rec.organization_id1,470);


     for org_rec in get_organizations
	( org_structure_version_rec.org_structure_version_id
	-- P_ORG_STRUCTURE_VERSION_ID
	, org_structure_element_rec.organization_id1
	-- P_ORGANIZATION_ID
	, P_ROLL_UP)
	loop

-- Start of New Hires Story

 hr_utility.set_location('org_rec.organization_id2='||org_rec.organization_id2,480);

	for asg_rec in get_assignment_start_end
		( P_DATE_TO
		, org_rec.organization_id2
		, P_BUSINESS_GROUP_ID)

	loop -- get_assignment_start_end

	l_jobcatg := NULL;
	l_abv	:= NULL;

 hr_utility.set_location('asg_rec.assignment_id='||asg_rec.assignment_id,490);
	l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
  			( p_ABV_formula_id  => l_ABV_formula_id
    			, p_ABV             => p_budget
	 		, p_assignment_id   => asg_rec.assignment_id
	   		, p_effective_date  => asg_rec.effective_start_date
			, p_session_date    => trunc(sysdate) );


	l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
				(asg_rec.job_id
				,p_job_category);

	HR_PERSON_FLEX_LOGIC.GetMovementCategory(
		 p_organization_id        =>   org_rec.organization_id2
		,p_assignment_id          =>   asg_rec.assignment_id
		,p_period_start_date      =>   P_DATE_FROM
		,p_period_end_date        =>   P_DATE_TO
		,p_movement_type          =>   'IN'
		,p_assignment_type        =>   asg_rec.assignment_type
		,p_movement_category 	  =>   l_movement_category
		);

 hr_utility.set_location('Movement Category 2 = '||l_movement_category,500);

	if l_movement_category = 'NEW_HIRE'
	then
	if l_jobcatg = 'Y'
        then
        l_rev_nh       := l_rev_nh + 1;
        else
        l_nonrev_nh    := l_nonrev_nh + 1;
        end if;
	end if;

	end loop; -- get_assignment_start_end

 hr_utility.set_location('organization_id1 = '||org_structure_element_rec.organization_id1,510);

HQOrgData(org_structure_element_rec.organization_id1).rev_nh  :=
HQOrgData(org_structure_element_rec.organization_id1).rev_nh  + nvl(l_rev_nh,0);
HQOrgData(org_structure_element_rec.organization_id1).nonrev_nh  :=
HQOrgData(org_structure_element_rec.organization_id1).nonrev_nh  + nvl(l_nonrev_nh,0);

l_rev_nh 	:= 0;
l_nonrev_nh	:= 0;

-- End of New Hires Story


	l_rev_term		:=0;
	l_nonrev_term		:=0;


 hr_utility.set_location('org_rec.organization_id2='||org_rec.organization_id2,520);

	for term_rec in get_terminations
		( P_DATE_FROM
		, P_DATE_TO
		, org_rec.organization_id2
		, P_BUSINESS_GROUP_ID)

	loop -- get_terminations

 hr_utility.set_location('Organization ID2 = '||org_rec.organization_id2,530);

	l_jobcatg := NULL;
        l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (term_rec.job_id
                                ,p_job_category);

 hr_utility.set_location('Job Categ = '||l_jobcatg,540);

        if l_jobcatg = 'Y'
        then
	l_rev_term       := l_rev_term + 1;

 hr_utility.set_location('Rev Terms = '||l_rev_term,550);

	else
	l_nonrev_term    := l_nonrev_term + 1;
 hr_utility.set_location('NONRev Terms = '||l_nonrev_term,560);
	end if;

	end loop; -- get_terminations

 hr_utility.set_location('Rev Terms1 = '||l_rev_term,570);
 hr_utility.set_location('NONRev Terms1 = '||l_nonrev_term,580);

HQOrgData(org_structure_element_rec.organization_id1).rev_term :=
HQOrgData(org_structure_element_rec.organization_id1).rev_term + nvl(l_rev_term,0);
HQOrgData(org_structure_element_rec.organization_id1).nonrev_term :=
HQOrgData(org_structure_element_rec.organization_id1).nonrev_term + nvl(l_nonrev_term,0);

	end loop; -- get_organizations

end loop; -- get_org_structure_element

end loop; -- get_org_structure_version

--  End of New Hires and Terminations Count

--  Start of Top Organization Values

l_rev_start_val         :=0;
l_nonrev_start_val      :=0;

if P_INCLUDE_TOP_ORG = 'Y' THEN

for asg_start_rec in get_assignment_start_end
(P_REPORT_DATE_FROM
,P_TOP_ORGANIZATION_ID
,P_BUSINESS_GROUP_ID
)
loop  -- get_assignment_start_end

 hr_utility.set_location('asg_start_rec.assignment_id='||asg_start_rec.assignment_id,590);

        l_jobcatg := NULL;
        l_abv   := NULL;

        l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                         ( p_ABV_formula_id  => l_ABV_formula_id
                         , p_ABV             => p_budget
                         , p_assignment_id   => asg_start_rec.assignment_id
                         , p_effective_date  => asg_start_rec.effective_start_date
                         , p_session_date    => trunc(sysdate) );

 hr_utility.set_location('l_abv='||l_abv,600);


        l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (asg_start_rec.job_id
                                ,p_job_category);

        if l_jobcatg = 'Y'
        then

        l_rev_start_val       := l_rev_start_val + l_abv;
        else

        l_nonrev_start_val    := l_nonrev_start_val + l_abv;
        end if;

       end loop; -- get_assignment_start_end

HQOrgData(P_TOP_ORGANIZATION_ID).rev_start_val           :=
HQOrgData(P_TOP_ORGANIZATION_ID).rev_start_val+ l_rev_start_val;
HQOrgData(P_TOP_ORGANIZATION_ID).nonrev_start_val                :=
HQOrgData(P_TOP_ORGANIZATION_ID).nonrev_start_val+l_nonrev_start_val;


l_rev_end_val         :=0;
l_nonrev_end_val      :=0;

for asg_end_rec in get_assignment_start_end
(P_REPORT_DATE_TO
,P_TOP_ORGANIZATION_ID
,P_BUSINESS_GROUP_ID
)
loop  -- get_assignment_start_end

 hr_utility.set_location('asg_end_rec.assignment_id='||asg_end_rec.assignment_id,610);

        l_jobcatg := NULL;
        l_abv   := NULL;

        l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                         ( p_ABV_formula_id  => l_ABV_formula_id
                         , p_ABV             => p_budget
                         , p_assignment_id   => asg_end_rec.assignment_id
                         , p_effective_date  => asg_end_rec.effective_start_date
                         , p_session_date    => trunc(sysdate) );

 hr_utility.set_location('l_abv='||l_abv,620);


        l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (asg_end_rec.job_id
                                ,p_job_category);

        if l_jobcatg = 'Y'
        then

        l_rev_end_val       := l_rev_end_val + l_abv;
        else

        l_nonrev_end_val    := l_nonrev_end_val + l_abv;
        end if;

       end loop; -- get_assignment_start_end

HQOrgData(P_TOP_ORGANIZATION_ID).rev_end_val           :=
HQOrgData(P_TOP_ORGANIZATION_ID).rev_end_val+ l_rev_end_val;
HQOrgData(P_TOP_ORGANIZATION_ID).nonrev_end_val                :=
HQOrgData(P_TOP_ORGANIZATION_ID).nonrev_end_val+l_nonrev_end_val;

-- Start of New Hires Story for Top Organization

        for asg_rec in get_assignment_start_end
                ( P_REPORT_DATE_TO
                , P_TOP_ORGANIZATION_ID
                , P_BUSINESS_GROUP_ID)

        loop -- get_assignment_start_end

        l_jobcatg := NULL;
        l_abv   := NULL;

 hr_utility.set_location('asg_rec.assignment_id='||asg_rec.assignment_id,630);

        l_abv     := HR_PERSON_FLEX_LOGIC.GetABV
                        ( p_ABV_formula_id  => l_ABV_formula_id
                        , p_ABV             => p_budget
                        , p_assignment_id   => asg_rec.assignment_id
                        , p_effective_date  => asg_rec.effective_start_date
                        , p_session_date    => trunc(sysdate) );


        l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (asg_rec.job_id
                                ,p_job_category);

        HR_PERSON_FLEX_LOGIC.GetMovementCategory(
                 p_organization_id        =>   P_TOP_ORGANIZATION_ID
                ,p_assignment_id          =>   asg_rec.assignment_id
                ,p_period_start_date      =>   P_REPORT_DATE_FROM
                ,p_period_end_date        =>   P_REPORT_DATE_TO
                ,p_movement_type          =>   'IN'
                ,p_assignment_type        =>   asg_rec.assignment_type
                ,p_movement_category      =>   l_movement_category
                );

 hr_utility.set_location('Movement Category 2 = '||l_movement_category,640);

        if l_movement_category = 'NEW_HIRE'
        then
        if l_jobcatg = 'Y'
        then
        l_rev_nh       := l_rev_nh + 1;
        else
        l_nonrev_nh    := l_nonrev_nh + 1;
        end if;
        end if;

        end loop; -- get_assignment_start_end


HQOrgData(P_TOP_ORGANIZATION_ID).rev_nh  :=
HQOrgData(P_TOP_ORGANIZATION_ID).rev_nh  + nvl(l_rev_nh,0);
HQOrgData(P_TOP_ORGANIZATION_ID).nonrev_nh  :=
HQOrgData(P_TOP_ORGANIZATION_ID).nonrev_nh  + nvl(l_nonrev_nh,0);

-- Start of Terminations Story of Top Organization

        l_rev_term              :=0;
        l_nonrev_term           :=0;

        for term_rec in get_terminations
                ( P_REPORT_DATE_FROM
                , P_REPORT_DATE_TO
                , P_TOP_ORGANIZATION_ID
                , P_BUSINESS_GROUP_ID)

        loop -- get_terminations

        l_jobcatg := NULL;
        l_jobcatg := HR_PERSON_FLEX_LOGIC.GetJobCategory
                                (term_rec.job_id
                                ,p_job_category);

 hr_utility.set_location('Job Categ = '||l_jobcatg,650);

        if l_jobcatg = 'Y'
        then
        l_rev_term       := l_rev_term + 1;

 hr_utility.set_location('Rev Terms = '||l_rev_term,660);

        else
        l_nonrev_term    := l_nonrev_term + 1;
 hr_utility.set_location('NONRev Terms = '||l_nonrev_term,670);
        end if;

        end loop; -- get_terminations

 hr_utility.set_location('Rev Terms1 = '||l_rev_term,680);
 hr_utility.set_location('NONRev Terms1 = '||l_nonrev_term,690);

HQOrgData(P_TOP_ORGANIZATION_ID).rev_term :=
HQOrgData(P_TOP_ORGANIZATION_ID).rev_term + nvl(l_rev_term,0);
HQOrgData(P_TOP_ORGANIZATION_ID).nonrev_term :=
HQOrgData(P_TOP_ORGANIZATION_ID).nonrev_term + nvl(l_nonrev_term,0);

end if;

--  End of Top Organization Values
--  Start of Totals

l_rev_start_val 			:= 0;
l_rev_end_val 	 			:= 0;
l_nonrev_start_val 			:= 0;
l_nonrev_end_val  			:= 0;
l_rev_nh  				:= 0;
l_nonrev_nh  				:= 0;
l_rev_term  				:= 0;
l_nonrev_term  				:= 0;

for all_organizations_rec in get_all_organizations
(P_ORGANIZATION_STRUCTURE_ID
,P_TOP_ORGANIZATION_ID
,P_REPORT_DATE_FROM
,P_REPORT_DATE_TO)
loop

l_rev_start_val := l_rev_start_val
		   + HQOrgData(all_organizations_rec.organization_id).rev_start_val;
l_rev_end_val := l_rev_end_val
		   + HQOrgData(all_organizations_rec.organization_id).rev_end_val;
l_rev_nh := l_rev_nh
		   + HQOrgData(all_organizations_rec.organization_id).rev_nh;
l_rev_term := l_rev_term
		   + HQOrgData(all_organizations_rec.organization_id).rev_term;
l_nonrev_start_val := l_nonrev_start_val
		   + HQOrgData(all_organizations_rec.organization_id).nonrev_start_val;
l_nonrev_end_val := l_nonrev_end_val
		   + HQOrgData(all_organizations_rec.organization_id).nonrev_end_val;
l_nonrev_nh := l_nonrev_nh
		   + HQOrgData(all_organizations_rec.organization_id).nonrev_nh;
l_nonrev_term := l_nonrev_term
		   + HQOrgData(all_organizations_rec.organization_id).nonrev_term;

 hr_utility.set_location('Org='||all_organizations_rec.organization_id||
 '*RS='||HQOrgData(all_organizations_rec.organization_id).rev_start_val||
 '*RE='||HQOrgData(all_organizations_rec.organization_id).rev_end_val||
 '*RNC='||to_char(HQOrgData(all_organizations_rec.organization_id).rev_end_val
 	-HQOrgData(all_organizations_rec.organization_id).rev_start_val)||
 '*RH='||HQOrgData(all_organizations_rec.organization_id).rev_nh||
 '*RT='||HQOrgData(all_organizations_rec.organization_id).rev_term||
 '*RON='||to_char(HQOrgData(all_organizations_rec.organization_id).rev_end_val
 	-HQOrgData(all_organizations_rec.organization_id).rev_start_val
 	-HQOrgData(all_organizations_rec.organization_id).rev_nh
 	+HQOrgData(all_organizations_rec.organization_id).rev_term),700);

 hr_utility.set_location('--------'||
 '*NS='||HQOrgData(all_organizations_rec.organization_id).nonrev_start_val||
 '*NE='||HQOrgData(all_organizations_rec.organization_id).nonrev_end_val||
 '*NNC='||(HQOrgData(all_organizations_rec.organization_id).nonrev_end_val
 	-HQOrgData(all_organizations_rec.organization_id).nonrev_start_val)||
 '*NH='||HQOrgData(all_organizations_rec.organization_id).nonrev_nh||
 '*NT='||HQOrgData(all_organizations_rec.organization_id).nonrev_term||
 '*NON='||to_char(HQOrgData(all_organizations_rec.organization_id).nonrev_end_val
 	-HQOrgData(all_organizations_rec.organization_id).nonrev_start_val
 	-HQOrgData(all_organizations_rec.organization_id).nonrev_nh
 	+HQOrgData(all_organizations_rec.organization_id).nonrev_term),800);

end loop;

HQOrgData(-1).rev_start_val 	:= l_rev_start_val;
HQOrgData(-1).rev_end_val 	:= l_rev_end_val;
HQOrgData(-1).rev_nh 		:= l_rev_nh;
HQOrgData(-1).rev_term 		:= l_rev_term;
HQOrgData(-1).nonrev_start_val 	:= l_nonrev_start_val;
HQOrgData(-1).nonrev_end_val 	:= l_nonrev_end_val;
HQOrgData(-1).nonrev_nh 	:= l_nonrev_nh;
HQOrgData(-1).nonrev_term 	:= l_nonrev_term;

end populate_summary_table;

END HR_HEAD_COUNT_SUMMARY;

/
