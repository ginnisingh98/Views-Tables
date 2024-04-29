--------------------------------------------------------
--  DDL for Package Body PER_EVS_MAG_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EVS_MAG_REPORT" AS
/* $Header: peevsmag.pkb 120.11.12010000.2 2009/06/01 11:59:33 kagangul ship $ */

----
-- Package Variables
--
g_package  VARCHAR2(33) :=  'per_evs_mag_report.';
g_file_id  UTL_FILE.FILE_TYPE;
g_file_name VARCHAR2(40);

--
--
-- Global variables representing parameters passed by PYUGEN
--
  g_start_date     VARCHAR2(11);
  g_end_date       VARCHAR2(11);
  g_tax_unit_id    VARCHAR2(30);
  g_evs_category   VARCHAR2(20);
  g_business_group_id            NUMBER;


-- ----------------------------------------------------------------------------
-- Sets up global list of parameters
-- ----------------------------------------------------------------------------
--
PROCEDURE get_parameters( p_payroll_action_id  IN NUMBER ) IS
l_proc varchar2(40) := g_package || 'get_parameters';
--
BEGIN
  --hr_utility.trace_on(NULL,'EVS');
  hr_utility.set_location(l_proc,10);
--
-- If parameters haven't already been set, then set them
--
  IF (g_business_group_id IS NULL) THEN
    hr_utility.set_location(l_proc,20);
  --
    SELECT
     ppa.business_group_id
    ,nvl(pay_core_utils.get_parameter('END_DATE',ppa.legislative_parameters), to_char(sysdate,'YYYY') || '/12/31')
    ,nvl(pay_core_utils.get_parameter('START_DATE',ppa.legislative_parameters),to_char(sysdate,'YYYY/MM/DD'))
    /*,pay_core_utils.get_parameter('STATE_DATE',ppa.legislative_parameters) */
    ,pay_core_utils.get_parameter('TAX_UNIT_ID',ppa.legislative_parameters)
    ,pay_core_utils.get_parameter('EVS_CATEGORY',ppa.legislative_parameters)
    INTO
     g_business_group_id
    ,g_end_date
    ,g_start_date
    ,g_tax_unit_id
    ,g_evs_category
    FROM pay_payroll_actions   ppa
    WHERE payroll_action_id = p_payroll_action_id;
    --
  --
    hr_utility.trace('g_business_group_id : ' || g_business_group_id);
    hr_utility.trace('g_start_date        : ' || g_start_date);
    hr_utility.trace('g_end_date          : ' || g_end_date);
    hr_utility.trace('g_tax_unit_id       : ' || g_tax_unit_id);

  END IF;
  hr_utility.set_location(l_proc,30);
--
END get_parameters;

-------------------------------------------------------------------------------
-- range_cursor
------------------------------------------------------------------------------
PROCEDURE range_cursor (pactid IN NUMBER, sqlstr OUT NOCOPY VARCHAR2) IS
--
l_proc VARCHAR2(40) := g_package || 'range_cursor';

CURSOR c_gre(p_business_group_id IN NUMBER) IS
SELECT hou.organization_id  organization_id,
       hou.name             org_name
FROM   hr_all_organization_units hou,
       hr_organization_information hoi
WHERE  hou.business_group_id = p_business_group_id
AND    hou.organization_id = hoi.organization_id
AND    hoi.org_information_context = 'CLASS'
AND    hoi.org_information1 = 'HR_LEGAL';

CURSOR c_get_requester_code(p_organization_id IN NUMBER) IS
SELECT hoi.org_information1 requester_code,
       hou.name             org_name
FROM   hr_all_organization_units hou,
       hr_organization_information hoi
WHERE  hoi.organization_id = hou.organization_id
AND    hoi.organization_id = p_organization_id
AND    hoi.org_information_context = 'EVS Filing';

CURSOR c_gre_name(p_organization_id IN NUMBER) IS
SELECT hou.name             org_name
FROM   hr_all_organization_units hou
WHERE  hou.organization_id = p_organization_id;


l_text VARCHAR(2000);
l_requester_code VARCHAR2(200);
l_org_name       VARCHAR2(2000);
l_gre_name       VARCHAR2(2000);

BEGIN

   hr_utility.set_location(l_proc,10);
   get_parameters(p_payroll_action_id => pactid);


  IF g_tax_unit_id IS NULL THEN

     --Fetching all the GREs.
  FOR i IN c_gre(g_business_group_id) LOOP

      OPEN c_gre_name(i.organization_id);
      FETCH c_gre_name INTO l_gre_name;
      CLOSE c_gre_name;

      OPEN c_get_requester_code(i.organization_id);
      FETCH c_get_requester_code INTO l_requester_code,l_org_name;
      IF c_get_requester_code%NOTFOUND THEN
         l_text := 'ERROR:Requester Identification Code is a mandatory field for the report. '||
                    'Please enter Requester Identification Code in EVS Filing for '||l_gre_name;
         fnd_file.put_line(fnd_file.LOG, l_text);
      ELSE
         IF l_requester_code IS NULL THEN
         l_text := 'ERROR:Requester Identification Code is a mandatory field for the report. '||
                    'Please enter Requester Identification Code in EVS Filing for '||l_gre_name;
         fnd_file.put_line(fnd_file.LOG, l_text);
         END IF;
      END IF;
      CLOSE c_get_requester_code;

  END LOOP;
  ELSE
      OPEN c_gre_name(g_tax_unit_id);
      FETCH c_gre_name INTO l_gre_name;
      CLOSE c_gre_name;

      OPEN c_get_requester_code(g_tax_unit_id);
      FETCH c_get_requester_code INTO l_requester_code,l_org_name;
      IF c_get_requester_code%NOTFOUND THEN
         l_text := 'ERROR:Requester Identification Code is a mandatory field for the report. '||
                    'Please enter Requester Identification Code in EVS Filing for '||l_gre_name;
         fnd_file.put_line(fnd_file.LOG, l_text);
      ELSE
         IF l_requester_code IS NULL THEN
         l_text := 'ERROR:Requester Identification Code is a mandatory field for the report. '||
                    'Please enter Requester Identification Code in EVS Filing for '||l_gre_name;
         fnd_file.put_line(fnd_file.LOG, l_text);
         END IF;
      END IF;
      CLOSE c_get_requester_code;

  END IF;


   sqlstr :=

   -- Bug# 5687781

 'SELECT /*+ INDEX(hsck,HR_SOFT_CODING_KEYFLEX_PK),
                       INDEX(HR_ORGANIZATION_UNITS_PK,hou)*/
 DISTINCT ppf.person_id
  FROM    per_all_people_f ppf
                 ,per_all_assignments_f paf
                 ,hr_soft_coding_keyflex hsck
                 ,hr_organization_units hou
                 ,hr_organization_information hoi
 WHERE  paf.assignment_type	= ''E''
  AND     paf.primary_flag = ''Y''
  AND  paf.effective_start_date <= to_date('''||g_end_date||''',''YYYY/MM/DD/'')
  AND  paf.effective_end_date >= to_date('''||g_start_date||''',''YYYY/MM/DD/'')
  AND paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
  AND paf.person_id = ppf.person_id
  AND ppf.effective_start_date <= to_date('''|| g_end_date||''',''YYYY/MM/DD/'')
  AND ppf.effective_end_date >= to_date('''||g_start_date||''',''YYYY/MM/DD/'')
 And  ppf.business_group_id +0 = ' ||g_business_group_id || '
 AND hou.business_group_id + 0 = ' ||g_business_group_id || '
 AND hou.date_from <= to_date('''|| g_end_date||''',''YYYY/MM/DD/'')
 AND nvl(hou.date_to,to_date(''4712-12-31'',''YYYY-MM-DD''))
       	        >= to_date('''||g_start_date||''',''YYYY/MM/DD/'')
  and  hsck.segment1= nvl('''||g_tax_unit_id||''',to_char(hou.organization_id))
  AND ppf.business_group_id = hou.business_group_id
  AND hou.organization_id = hoi.organization_id
  AND hoi.org_information_context = ''CLASS''
  AND hoi.org_information1 = ''HR_LEGAL''
  AND hoi.org_information2 = ''Y''
  AND :payroll_action_id is not NULL
  ORDER BY ppf.person_id';

  /*
   -- Bug: 5212175

     'select distinct ppf.person_id
      from per_all_people_f ppf
           ,per_all_assignments_f paf
           ,hr_soft_coding_keyflex hsck
           ,hr_organization_units hou
           ,hr_organization_information hoi
      where  paf.assignment_type	= ''E''
	and  paf.primary_flag		= ''Y''
        and  paf.effective_start_date <= to_date('''||g_end_date||''',''YYYY/MM/DD/'')
        and  paf.effective_end_date >= to_date('''||g_start_date||''',''YYYY/MM/DD/'')
        and  paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
        and  paf.person_id = ppf.person_id
        And  ppf.business_group_id +0          = ' ||g_business_group_id || '
	and  ppf.effective_start_date <= to_date('''|| g_end_date||''',''YYYY/MM/DD/'')
       	and  ppf.effective_end_date >= to_date('''||g_start_date||''',''YYYY/MM/DD/'')
	and ppf.business_group_id = hou.business_group_id
        and hou.date_from <= to_date('''|| g_end_date||''',''YYYY/MM/DD/'')
 	and nvl(hou.date_to,to_date(''4712-12-31'',''YYYY-MM-DD''))
       	        >= to_date('''||g_start_date||''',''YYYY/MM/DD/'')
        and  hsck.segment1= nvl('''||g_tax_unit_id||''',to_char(hou.organization_id))
        and hou.organization_id = hoi.organization_id
        and hoi.org_information_context = ''CLASS''
        and hoi.org_information1 = ''HR_LEGAL''
        and hoi.org_information2 = ''Y''
        and  :payroll_action_id is not NULL
        order by ppf.person_id';    */

    /*
      'select distinct ppf.person_id
       from
         per_people_f                ppf
        ,hr_soft_coding_keyflex      hsck
	,per_assignments_f	     paf
       where  ppf.person_id = paf.person_id
	and  ppf.effective_start_date <= to_date('''||g_end_date||''',''YYYY/MM/DD/'')
       	and  ppf.effective_end_date >= to_date('''||g_start_date||''',''YYYY/MM/DD/'')
	and  paf.effective_start_date <= to_date('''|| g_end_date||''',''YYYY/MM/DD/'')
        and  paf.effective_end_date >= to_date('''|| g_start_date||''',''YYYY/MM/DD/'')
        and  hsck.segment1 in
	(
		select distinct hsck2.segment1
		from hr_organization_information hoi
		,hr_organization_units      hou
		,hr_soft_coding_keyflex         hsck2
		where
		hou.business_group_id +0 = ' || g_business_group_id || '
		and hsck2.segment1 = nvl('''||g_tax_unit_id||''',to_char(hou.organization_id))
		and hoi.organization_id = hou.organization_id
		and hoi.org_information_context = ''CLASS''
	        and    hoi.org_information1 = ''HR_LEGAL''
 	        and    hoi.org_information2 = ''Y''
    		and    hou.date_from  <= to_date('''|| g_end_date||''',''YYYY/MM/DD/'')
 		and    nvl(hou.date_to,to_date(''4712-12-31'',''YYYY-MM-DD''))
       	                >= to_date('''||g_start_date||''',''YYYY/MM/DD/'')
	)
	and  paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
        and  paf.assignment_type	= ''E''
	and  paf.primary_flag		= ''Y''
        And  ppf.business_group_id +0          = ' ||g_business_group_id || '
        and  :payroll_action_id is not NULL
	order by ppf.person_id';
    */


    hr_utility.trace('RK Modified SQL: ' || sqlstr);

END range_cursor;

-- -----------------------------------------------------------------------------
--                   Returns list of people to be processed
-- -----------------------------------------------------------------------------
--
PROCEDURE action_creation(
  pactid      IN NUMBER,
  stperson    IN NUMBER,
  endperson   IN NUMBER,
  chunk       IN NUMBER ) IS

 --
 -- New Hire Only
 --
 CURSOR c_actions_nh
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
       select distinct paf.assignment_id
                      ,hsck.segment1
       from
         per_people_f            ppf
        ,hr_soft_coding_keyflex  hsck
        ,per_assignments_f       paf
        ,per_periods_of_service  pps
       where  ppf.person_id = pps.person_id
        and pps.date_start
         between to_date(g_start_date,'YYYY/MM/DD/')
                 and  to_date(g_end_date,'YYYY/MM/DD/')
        and  ppf.effective_start_date =
                (select max(ppf2.effective_start_date)
                from per_people_f ppf2
                where ppf2.person_id = ppf.person_id
                and  ppf2.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
                and  ppf2.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
                )
        and  ppf.person_id = paf.person_id
        /* and  pps.date_start = paf.effective_start_date */
        and  hsck.segment1 in
        (
                select distinct hsck2.segment1
                from
                 hr_organization_information hoi
                ,hr_organization_units      hou
                ,hr_soft_coding_keyflex     hsck2
                where
                hou.business_group_id +0 = g_business_group_id
                and hsck2.segment1 = nvl(g_tax_unit_id,to_char(hou.organization_id))
                and hoi.organization_id = hou.organization_id
                and hoi.org_information_context = 'CLASS'
                and    hoi.org_information1 = 'HR_LEGAL'
                and    hoi.org_information2 = 'Y'
                and    hou.date_from  <= to_date(g_end_date,'YYYY/MM/DD/')
                and    nvl(hou.date_to,to_date('4712-12-31','YYYY-MM-DD'))
                        >= to_date(g_start_date,'YYYY/MM/DD/')
        )
        and  paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
        and  paf.assignment_type        = 'E'
        and  paf.primary_flag           = 'Y'
        And ppf.business_group_id +0          = g_business_group_id
        and  paf.person_id between stperson and endperson
        order by paf.assignment_id;


 --
 -- Employee Only
 --
 CURSOR c_actions_ee
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is

 select /*+ index(hou,HR_ORGANIZATION_UNITS_FK1)*/
            distinct paf.assignment_id,
                        hsck.segment1
   from per_all_people_f ppf ,
           per_all_assignments_f paf,
           hr_soft_coding_keyflex hsck,
           hr_all_organization_units hou,
           hr_organization_information hoi,
           per_assignment_status_types past
   where paf.assignment_type = 'E'
   and paf.primary_flag = 'Y'
   and paf.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
   and paf.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
   and paf.person_id between stperson and endperson
   and paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
   and paf.assignment_status_type_id = past.assignment_status_type_id
   and past.per_system_status = 'ACTIVE_ASSIGN'
   and paf.person_id = ppf.person_id
   and ppf.current_employee_flag = 'Y'
   and ppf.effective_start_date = (select max(ppf2.effective_start_date)
	                                from per_all_people_f ppf2
					where ppf.person_id = ppf2.person_id
					and ppf2.current_employee_flag = 'Y'
					and ppf2.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
					and ppf2.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
					)
   and ppf.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
   and ppf.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
   and ppf.business_group_id +0 = g_business_group_id
   and hou.business_group_id + 0 = g_business_group_id
   and hou.date_from  <= to_date(g_end_date,'YYYY/MM/DD/')
   and nvl(hou.date_to,to_date('4712-12-31','YYYY-MM-DD'))
	        >= to_date(g_start_date,'YYYY/MM/DD/')
   and hsck.segment1 = nvl(g_tax_unit_id,to_char(hou.organization_id))
   and ppf.business_group_id = hou.business_group_id
   and hou.organization_id = hoi.organization_id
   and hoi.org_information_context = 'CLASS'
   and hoi.org_information1 = 'HR_LEGAL'
   and hoi.org_information2 = 'Y'
   order by paf.assignment_id;

/* commented for the bug# 5344584(Base bug# 5212175) */
/* select distinct paf.assignment_id
                      ,hsck.segment1
       from
         per_people_f                ppf
        ,hr_soft_coding_keyflex      hsck
        ,per_assignments_f           paf
        ,per_periods_of_service      pps
        ,per_assignment_status_types past
       where  ppf.person_id = paf.person_id
        and  ppf.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
        and  ppf.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
        and  paf.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
        and  paf.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
        and  ppf.current_employee_flag = 'Y'
        and  ppf.effective_start_date =
              (select max(ppf2.effective_start_date)
              from per_people_f ppf2
              where ppf2.person_id = ppf.person_id
              and  ppf2.current_employee_flag = 'Y'
              and  ppf2.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
               and  ppf2.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
              )
        and  hsck.segment1 in
        (
                select distinct hsck2.segment1
                from hr_organization_information hoi
                ,hr_organization_units      hou
                ,hr_soft_coding_keyflex         hsck2
                where
                hou.business_group_id +0 = g_business_group_id
                and hsck2.segment1 = nvl(g_tax_unit_id,to_char(hou.organization_id))
                and hoi.organization_id = hou.organization_id
                and hoi.org_information_context = 'CLASS'
                and    hoi.org_information1 = 'HR_LEGAL'
                and    hoi.org_information2 = 'Y'
                and    hou.date_from  <= to_date(g_end_date,'YYYY/MM/DD/')
                and    nvl(hou.date_to,to_date('4712-12-31','YYYY-MM-DD'))
                        >= to_date(g_start_date,'YYYY/MM/DD/')
        )
        and  paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
        and  paf.assignment_type        = 'E'
        and  paf.primary_flag           = 'Y'
        and  paf.assignment_status_type_id    = past.assignment_status_type_id
        And  past.per_system_status            = 'ACTIVE_ASSIGN'
        And  ppf.business_group_id +0          = g_business_group_id
        and  paf.person_id between stperson and endperson
        order by paf.assignment_id;
*/
/* commented for bug# 5687781
        select distinct paf.assignment_id, hsck.segment1
	from   per_all_people_f             ppf
	      ,per_all_assignments_f       paf
	      ,hr_soft_coding_keyflex      hsck
	      ,hr_organization_units       hou
	      ,hr_organization_information hoi
	      ,per_assignment_status_types past
	where paf.assignment_type = 'E'
	and paf.primary_flag = 'Y'
	and paf.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
	and paf.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
	and paf.person_id between stperson and endperson
	and paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
	and paf.assignment_status_type_id = past.assignment_status_type_id
	and past.per_system_status = 'ACTIVE_ASSIGN'
	and paf.person_id = ppf.person_id
	and ppf.current_employee_flag = 'Y'
	and ppf.effective_start_date = (select max(ppf2.effective_start_date)
	                                from per_all_people_f ppf2
					where ppf.person_id = ppf2.person_id
					and ppf2.current_employee_flag = 'Y'
					and ppf2.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
					and ppf2.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
					)
                          and ppf.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
	and ppf.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
                          and ppf.business_group_id +0 = g_business_group_id
	and ppf.business_group_id = hou.business_group_id
	and hou.date_from  <= to_date(g_end_date,'YYYY/MM/DD/')
	and nvl(hou.date_to,to_date('4712-12-31','YYYY-MM-DD'))
	        >= to_date(g_start_date,'YYYY/MM/DD/')
	and hsck.segment1 = nvl(g_tax_unit_id,to_char(hou.organization_id))
	and hou.organization_id = hoi.organization_id
	and hoi.org_information_context = 'CLASS'
	and hoi.org_information1 = 'HR_LEGAL'
	and hoi.org_information2 = 'Y'
	order by paf.assignment_id;
*/

 --
 -- Retiree Only
 --
 CURSOR c_actions_rt
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
       select distinct paf.assignment_id
                      ,hsck.segment1
       from
         per_people_f             ppf
        ,hr_soft_coding_keyflex   hsck
        ,per_assignments_f        paf
        ,per_periods_of_service   pps
        ,per_person_type_usages_f ptu
        ,per_person_types         ppt
       where  ppf.person_id = pps.person_id
        and  pps.actual_termination_date is not NULL
        and  pps.actual_termination_date
         between to_date(g_start_date,'YYYY/MM/DD/')
                 and  to_date(g_end_date,'YYYY/MM/DD/')
        and  pps.leaving_reason = 'R'
        and  ppf.person_id = ptu.person_id
        and  ptu.effective_start_date <= to_date(g_end_date,'YYYY/MM/DD/')
        and  ptu.effective_end_date >= to_date(g_start_date,'YYYY/MM/DD/')
        and  paf.effective_start_date <= to_date( g_end_date,'YYYY/MM/DD/')
        and  ppt.person_type_id = ptu.person_type_id
        and  ppt.system_person_type = 'RETIREE'
        and  ppf.effective_start_date =
                (select max(ppf2.effective_start_date)
                from per_people_f ppf2
                where ppf2.person_id = ppf.person_id
                and  ppf2.current_employee_flag is null
               )
        and  ppf.person_id = paf.person_id
        and  paf.effective_start_date =
                (select max(paf2.effective_start_date)
                from per_assignments_f paf2
                where paf.assignment_id = paf2.assignment_id
                )
        and  hsck.segment1 in
             (
                select distinct hsck2.segment1
                from hr_organization_information hoi
                ,hr_organization_units      hou
                ,hr_soft_coding_keyflex         hsck2
                where
                hou.business_group_id +0 = g_business_group_id
                and hsck2.segment1 = nvl(g_tax_unit_id,to_char(hou.organization_id))
                and hoi.organization_id = hou.organization_id
                and hoi.org_information_context = 'CLASS'
                and    hoi.org_information1 = 'HR_LEGAL'
                and    hoi.org_information2 = 'Y'
                and    hou.date_from  <= to_date(g_end_date,'YYYY/MM/DD/')
                and    nvl(hou.date_to,to_date('4712-12-31','YYYY-MM-DD'))
                        >= to_date(g_start_date,'YYYY/MM/DD/')
        )
        and  paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
        and  paf.assignment_type        = 'E'
        and  paf.primary_flag           = 'Y'
        And ppf.business_group_id +0          = g_business_group_id
        and  paf.person_id between stperson and endperson
        order by paf.assignment_id;

--
lockingactid      NUMBER;
l_proc varchar2(40) := g_package || 'action_creation';
--
BEGIN
--
  --hr_utility.trace_on(NULL,'EVS');
  hr_utility.set_location('Entering.. ' || l_proc,10);
  get_parameters( p_payroll_action_id => pactid );

  hr_utility.trace('g_business_group_id :'||to_char(g_business_group_id));
  hr_utility.trace('g_start_date :'||to_char(g_start_date));
  hr_utility.trace('g_end_date :'||to_char(g_end_date));
  hr_utility.trace('Stperson :'||to_char(stperson));
  hr_utility.trace('Endperson :'||to_char(endperson));
  hr_utility.trace('tax_unit_id :'||to_char(g_tax_unit_id));

  hr_utility.trace('g_evs_category : ' || g_evs_category);

  if g_evs_category = 'EMPLOYEE' then
    hr_utility.set_location(l_proc,20);
    for asgrec in c_actions_ee(pactid,stperson, endperson) loop
     hr_utility.trace('RK in c_actions_ee cursor');
     SELECT pay_assignment_actions_s.nextval
         INTO lockingactid
         FROM dual;
        -- insert the action record.
       hr_nonrun_asact.insact(lockingactid,asgrec.assignment_id,pactid,chunk,
asgrec.segment1);
--
    end loop;
  elsif g_evs_category = 'NEWHIRE' then
    hr_utility.set_location(l_proc,30);
    hr_utility.trace('g_evs_category = NEWHIRE Satisfied ');
    for asgrec in c_actions_nh(pactid,stperson, endperson) loop

     SELECT pay_assignment_actions_s.nextval
         INTO lockingactid
         FROM dual;

      -- insert the action record.
       hr_nonrun_asact.insact(lockingactid,asgrec.assignment_id,pactid,chunk,
asgrec.segment1);
       hr_utility.trace('Created New Asg_Action: '||to_char(lockingactid));
       hr_utility.trace('Asg_id: '||to_char(asgrec.assignment_id));
       hr_utility.trace('GRE: '||asgrec.segment1);
--
    end loop;
  elsif g_evs_category = 'RETIREE' then
    hr_utility.set_location(l_proc,40);
    for asgrec in c_actions_rt(pactid,stperson, endperson) loop

     SELECT pay_assignment_actions_s.nextval
         INTO lockingactid
         FROM dual;

      -- insert the action record.
       hr_nonrun_asact.insact(lockingactid,asgrec.assignment_id,pactid,chunk,
asgrec.segment1);
--
    end loop;
  elsif g_evs_category = 'EMPRTR'  then
    hr_utility.set_location(l_proc,50);
    for asgrec in c_actions_ee(pactid,stperson, endperson) loop

     SELECT pay_assignment_actions_s.nextval
         INTO lockingactid
         FROM dual;

      -- insert the action record.
       hr_nonrun_asact.insact(lockingactid,asgrec.assignment_id,pactid,chunk,
asgrec.segment1);
--
    end loop;
  end if;

  --
  hr_utility.set_location('Leaving.. ' || l_proc,60);
 /* hr_utility.trace_off; */
END action_creation;
--

-- ----------------------------------------------------------------------------
--                  Initialization - sets up global parameters
-- ----------------------------------------------------------------------------
--
PROCEDURE init_code( p_payroll_action_id  IN NUMBER) IS
--
  --
  l_test  VARCHAR2(20);
  --
BEGIN
--
  --
  get_parameters( p_payroll_action_id => p_payroll_action_id );
  --
--
END init_code;



---------------------------------------------------------------------------
-- The following is old version code using UTL_FILE
---------------------------------------------------------------------------



-- ------------------------- GET_ROOT_DIR ---------------------------------
-- Description: Opens the specified file in the named location
--
--  Input Parameters
--      p_path   -    utl_file_dir directores
--
--
--  Output Parameters
--      l_directory - output directory
--
-- ------------------------------------------------------------------------
FUNCTION  get_root_dir
 (p_path                         IN  VARCHAR2
 )
 RETURN VARCHAR2
IS

  l_proc        varchar2(72);
BEGIN
  l_proc        := g_package||'get_root_dir';

  hr_utility.set_location('Entering:' || l_proc,10);

  IF INSTR(p_path,',',1) = 0 THEN
     IF INSTR(p_path,';',1) = 0 THEN
        RETURN SUBSTR(p_path , 1 ,LENGTH(p_path));
     ELSE
        RETURN SUBSTR(p_path , 1 ,INSTR(p_path,';',1)-1);
     END IF;
  ELSE
     RETURN SUBSTR(p_path , 1 ,INSTR(p_path,',',1)-1);
  END IF;
  hr_utility.set_location('Leaving:' || l_proc,20);

EXCEPTION
WHEN OTHERS  THEN
   hr_utility.set_location(l_proc || substr(sqlerrm,1,50),999);
   fnd_file.put_line(fnd_file.log,SQLERRM);
END get_root_dir;

---------------------------------------------------------------------------
-- EVS_MAG_REPORT
-- Description: Call evs_put_record foreach report_category
--
---------------------------------------------------------------------------
procedure evs_mag_report
 (p_path			in	varchar2
 ,p_report_category		in	varchar2
 ,p_user_control_data		in	varchar2
 ,p_requester_id_code		in	varchar2
 ,p_business_group_id		in	number
 ,p_tax_unit_id			in	number
 ,p_start_date			in	date
 ,p_end_date			in	date
 ,p_count			in	number
 ,p_media_type                  in      varchar2
 ,p_gre_count		        out nocopy  number
)
is
  --
  -- Define cursor
  --
  --
  -- All Employee
  --
  cursor csr_get_ee_info(p_tax_unit_id in number) is
  select
	 distinct ppf.PERSON_ID   -- BUG4084819
	,substr(ppf.LAST_NAME,1,13) last_name
	,substr(ppf.MIDDLE_NAMES,1,7) middle_name
	,substr(ppf.FIRST_NAME,1,10) first_name
	,ppf.NATIONAL_IDENTIFIER
	,ppf.DATE_OF_BIRTH
	,substr(ppf.SEX,1,1) GENDER
	--,paf.ASSIGNMENT_ID

  From
  	per_people_f	            ppf
       ,hr_soft_coding_keyflex	    hsck
       ,per_assignments_f	    paf
       ,per_periods_of_service      pps
       ,per_assignment_status_types past
  Where
      pps.person_id     = ppf.person_id
  and ppf.person_id	= paf.person_id
  and ppf.effective_start_date <= p_end_date
  and ppf.effective_end_date >= p_start_date
  and paf.effective_start_date <= p_end_date
  and paf.effective_end_date >= p_start_date
  and ppf.current_employee_flag = 'Y'
  and ppf.effective_start_date =
      (select max(ppf2.effective_start_date)
       from per_people_f ppf2
       where ppf2.person_id = ppf.person_id
       and   ppf2.current_employee_flag = 'Y'
       and   ppf2.effective_start_date <= p_end_date
       and   ppf2.effective_end_date >= p_start_date
      )
  And hsck.segment1	= to_char(p_tax_unit_id)
  And paf.soft_coding_keyflex_id	= hsck.soft_coding_keyflex_id
  And paf.assignment_type		= 'E'
  And paf.primary_flag			= 'Y'
  And paf.assignment_status_type_id     = past.assignment_status_type_id
  And past.per_system_status            = 'ACTIVE_ASSIGN'
  And ppf.business_group_id +0		= p_business_group_id
  Order by   national_identifier ;

  --
  -- New Hires only
  --
  cursor csr_get_nh_info(p_tax_unit_id in number) is
  select
	 distinct ppf.PERSON_ID
	,substr(ppf.LAST_NAME,1,13) last_name
	,substr(ppf.MIDDLE_NAMES,1,7) middle_name
	,substr(ppf.FIRST_NAME,1,10) first_name
	,ppf.NATIONAL_IDENTIFIER
	,ppf.DATE_OF_BIRTH
	,substr(ppf.SEX,1,1) GENDER
	--,paf.ASSIGNMENT_ID

  From
  	per_people_f	        ppf
       ,hr_soft_coding_keyflex	hsck
       ,per_assignments_f	paf
       ,per_periods_of_service  pps
  Where
      ppf.person_id     = pps.person_id
  and pps.date_start between
      p_start_date and p_end_date
  and ppf.effective_start_date =
      (select max(ppf2.effective_start_date)
       from  per_people_f ppf2
       where ppf2.person_id = ppf.person_id
       and   ppf2.effective_start_date <= p_end_date
       and   ppf2.effective_end_date >= p_start_date
      )
  and ppf.person_id	= paf.person_id
  and pps.date_start = paf.effective_start_date
  And hsck.segment1	= to_char(p_tax_unit_id)
  And paf.soft_coding_keyflex_id	= hsck.soft_coding_keyflex_id
  And paf.assignment_type		= 'E'
  And paf.primary_flag			= 'Y'
  And ppf.business_group_id +0		= p_business_group_id
  Order by   national_identifier ;

  --
  -- Retirees only
  --
  cursor csr_get_retire_info(p_tax_unit_id in number) is
  select
	 distinct ppf.PERSON_ID
	,substr(ppf.LAST_NAME,1,13) last_name
	,substr(ppf.MIDDLE_NAMES,1,7) middle_name
	,substr(ppf.FIRST_NAME,1,10) first_name
	,ppf.NATIONAL_IDENTIFIER
	,ppf.DATE_OF_BIRTH
	,substr(ppf.SEX,1,1) GENDER
	--,paf.ASSIGNMENT_ID

  From
  	per_people_f	        ppf
       ,hr_soft_coding_keyflex	hsck
       ,per_assignments_f	paf
       ,per_periods_of_service  pps
       ,per_person_type_usages_f ptu
       ,per_person_types         ppt
  Where
      ppf.person_id     = pps.person_id
  and pps.actual_termination_date is not NULL
  and pps.actual_termination_date
      between p_start_date and p_end_date
  and pps.leaving_reason = 'R'
  and ppf.person_id = ptu.person_id
  and ptu.effective_start_date <= p_end_date
  and ptu.effective_end_date >= p_start_date
  and ppt.person_type_id = ptu.person_type_id
  and ppt.system_person_type = 'RETIREE'
  and ppf.effective_start_date =
      (select max(ppf2.effective_start_date)
       from per_people_f ppf2
       where
           ppf2.person_id = ppf.person_id
       and ppf2.current_employee_flag is null
      )
  and ppf.person_id	= paf.person_id
  and paf.effective_start_date =
      (select max(paf2.effective_start_date)
       from per_assignments_f paf2
       where
           paf.assignment_id = paf2.assignment_id
       )
  And hsck.segment1	= to_char(p_tax_unit_id)
  And paf.soft_coding_keyflex_id	= hsck.soft_coding_keyflex_id
  And paf.assignment_type		= 'E'
  And paf.primary_flag			= 'Y'
  And ppf.business_group_id +0		= p_business_group_id
  Order by   national_identifier ;


  --
  -- Employees and Retirees
  --
  cursor csr_get_ee_and_rtr_info(p_tax_unit_id in number) is
  select
	 distinct ppf.PERSON_ID
	,substr(ppf.LAST_NAME,1,13) last_name
	,substr(ppf.MIDDLE_NAMES,1,7) middle_name
	,substr(ppf.FIRST_NAME,1,10) first_name
	,ppf.NATIONAL_IDENTIFIER
	,ppf.DATE_OF_BIRTH
	,substr(ppf.SEX,1,1) GENDER
	--,paf.ASSIGNMENT_ID

  From
  	per_people_f	         ppf
       ,hr_soft_coding_keyflex	 hsck
       ,per_assignments_f	 paf
       ,per_periods_of_service   pps
       ,per_person_type_usages_f ptu
       ,per_person_types         ppt
  Where
      ppf.person_id     = pps.person_id
  and pps.actual_termination_date is not NULL
  and pps.actual_termination_date
      between p_start_date and p_end_date
  and pps.leaving_reason = 'R'
  and ppf.person_id = ptu.person_id
  and ptu.effective_start_date <= p_end_date
  and ptu.effective_end_date >= p_start_date
  and ppt.person_type_id = ptu.person_type_id
  and ppt.system_person_type = 'RETIREE'
  and ppf.effective_start_date =
      (select max(ppf2.effective_start_date)
       from per_people_f ppf2
       where
           ppf2.person_id = ppf.person_id
       and ppf2.current_employee_flag is null
      )
  and ppf.person_id	= paf.person_id
  and paf.effective_start_date =
      (select max(paf2.effective_start_date)
       from per_assignments_f paf2
       where
           paf.assignment_id = paf2.assignment_id
       )
  And hsck.segment1	= to_char(p_tax_unit_id)
  And paf.soft_coding_keyflex_id	= hsck.soft_coding_keyflex_id
  And paf.assignment_type		= 'E'
  And paf.primary_flag			= 'Y'
  And ppf.business_group_id +0		= p_business_group_id
  and exists
      (select null
          from per_people_f           ppf2
              ,per_periods_of_service pps2
          where
              ppf2.person_id = ppf.person_id
          and ppf2.current_employee_flag = 'Y'
          and pps2.person_id			= ppf2.person_id
          and pps2.date_start
              between p_start_date and p_end_date
          and pps2.date_start			= ppf2.effective_start_date
      )
  Order by   national_identifier ;


  --
  -- local variable
  --
  l_proc		varchar2(72);
  l_count		number;
  l_gre_count		number;
  l_file_count		number;
  l_report_category     varchar2(40);
  l_multiple_req_indicator varchar2(3);
begin

    l_proc        := g_package||'evs_mag_report';
    hr_utility.set_location('Enteriing : ' || l_proc,10);
    hr_utility.trace('p_path              = ' || p_path);
    hr_utility.trace('p_start_date        = ' || p_start_date);
    hr_utility.trace('p_end_date          = ' || p_end_date);
    hr_utility.trace('p_tax_unit_id       = ' || p_tax_unit_id);
    hr_utility.trace('p_report_category   = ' || p_report_category);
    hr_utility.trace('p_user_control_data = ' || p_user_control_data);
    hr_utility.trace('p_requester_id_code = ' || p_requester_id_code);
    hr_utility.trace('p_report_category   = ' || p_report_category);


    l_count := p_count;
    l_file_count := 0;
    l_gre_count := 0;
    l_multiple_req_indicator := to_char(l_file_count + 1);

    if p_report_category is NULL then
        l_report_category := 'NEWHIRE';
    else
        l_report_category := p_report_category;
    end if;

    hr_utility.trace('l_report_category    = ' || l_report_category);

    if l_report_category = 'EMPLOYEE' then
       hr_utility.set_location(l_proc,20);
       FOR ee_record IN csr_get_ee_info(p_tax_unit_id) LOOP
           evs_put_record
             	(p_file_id		=> g_file_id
             	,p_ssn       		=> ee_record.national_identifier
             	,p_last_name 		=> ee_record.last_name
  		,p_first_name   	=> ee_record.first_name
  		,p_middle_name		=> ee_record.middle_name
  		,p_date_of_birth	=> ee_record.date_of_birth
  		,p_gender		=> ee_record.gender
  		,p_user_control_data	=> p_user_control_data
  		,p_requester_id_code	=> p_requester_id_code
  		,p_multiple_req_indicator => l_file_count
          );
          l_count := l_count + 1;
          l_gre_count := l_gre_count + 1;
          hr_utility.trace('l_count              = ' || l_count);
          hr_utility.trace('l_gre_count          = ' || l_gre_count);
          if p_media_type = 'DISKETTE' then
            if l_count >= 11000 then
               utl_file.fclose(g_file_id);
               l_file_count := l_file_count + 1 ;
               hr_utility.set_location(l_proc,25);
               g_file_id := utl_file.fopen(p_path, g_file_name || l_file_count, 'w');
               l_count := 0;
            end if;
          end if;
       END LOOP;
    elsif l_report_category = 'NEWHIRE' then
      hr_utility.set_location(l_proc,30);
       FOR ee_record IN csr_get_nh_info(p_tax_unit_id) LOOP
           evs_put_record
             	(p_file_id		=> g_file_id
             	,p_ssn       		=> ee_record.national_identifier
             	,p_last_name 		=> ee_record.last_name
  		,p_first_name   	=> ee_record.first_name
  		,p_middle_name		=> ee_record.middle_name
  		,p_date_of_birth	=> ee_record.date_of_birth
  		,p_gender		=> ee_record.gender
  		,p_user_control_data	=> p_user_control_data
  		,p_requester_id_code	=> p_requester_id_code
  		,p_multiple_req_indicator	=> l_file_count
          );
          l_count := l_count + 1;
          l_gre_count := l_gre_count + 1;
          hr_utility.trace('l_count              = ' || l_count);
          hr_utility.trace('l_gre_count          = ' || l_gre_count);
          if p_media_type = 'DISKETTE' then
            if l_count >= 11000 then
               hr_utility.set_location(l_proc,35);
               utl_file.fclose(g_file_id);
               l_file_count := l_file_count + 1 ;
               g_file_id := utl_file.fopen(p_path, g_file_name || l_file_count, 'w');
               l_count := 0;
            end if;
          end if;
       END LOOP;
    elsif l_report_category = 'RETIREE' then
      hr_utility.set_location(l_proc,40);
       FOR ee_record IN csr_get_retire_info(p_tax_unit_id) LOOP
           evs_put_record
             	(p_file_id		=> g_file_id
             	,p_ssn       		=> ee_record.national_identifier
             	,p_last_name 		=> ee_record.last_name
  		,p_first_name   	=> ee_record.first_name
  		,p_middle_name		=> ee_record.middle_name
  		,p_date_of_birth	=> ee_record.date_of_birth
  		,p_gender		=> ee_record.gender
  		,p_user_control_data	=> p_user_control_data
  		,p_requester_id_code	=> p_requester_id_code
  		,p_multiple_req_indicator	=> l_file_count
          );
          l_count := l_count + 1;
          l_gre_count := l_gre_count + 1;
          hr_utility.trace('l_count              = ' || l_count);
          hr_utility.trace('l_gre_count          = ' || l_gre_count);
          if p_media_type = 'DISKETTE' then
            if l_count >= 11000 then
               hr_utility.set_location(l_proc,45);
               utl_file.fclose(g_file_id);
               l_file_count := l_file_count + 1 ;
               g_file_id := utl_file.fopen(p_path, g_file_name || l_file_count, 'w');
               l_count := 0;
            end if;
         end if;
       END LOOP;
    elsif l_report_category = 'EMPRTR' then
      hr_utility.set_location(l_proc,50);
       FOR ee_record IN csr_get_ee_info(p_tax_unit_id) LOOP --BUG3930540
           evs_put_record
             	(p_file_id		=> g_file_id
             	,p_ssn       		=> ee_record.national_identifier
             	,p_last_name 		=> ee_record.last_name
  		,p_first_name   	=> ee_record.first_name
  		,p_middle_name		=> ee_record.middle_name
  		,p_date_of_birth	=> ee_record.date_of_birth
  		,p_gender		=> ee_record.gender
  		,p_user_control_data	=> p_user_control_data
  		,p_requester_id_code	=> p_requester_id_code
  		,p_multiple_req_indicator	=> l_file_count
          );
          l_count := l_count + 1;
          hr_utility.trace('l_count              = ' || l_count);
          l_gre_count := l_gre_count + 1;
          hr_utility.trace('l_gre_count          = ' || l_gre_count);
          if p_media_type = 'DISKETTE' then
            if l_count >= 11000 then
               hr_utility.set_location(l_proc,55);
               utl_file.fclose(g_file_id);
               l_file_count := l_file_count + 1 ;
               g_file_id := utl_file.fopen(p_path, g_file_name || l_file_count, 'w');
               l_count := 0;
            end if;
         end if;
       END LOOP;
    end if;
    p_gre_count := l_gre_count;
    hr_utility.set_location('Leaving : ' || l_proc,100);
end evs_mag_report;
------------------------------------------------------------------------------
-- Bug # 8528862
-- F_EVS_REM_SPL_CHAR
-- Description : Removes the special character like <'. -> from the input
--               string and returns the remaining string.
------------------------------------------------------------------------------
FUNCTION f_evs_rem_spl_char(p_input_string IN VARCHAR2)
RETURN VARCHAR2 IS

ls_output_string VARCHAR2(100);

BEGIN
   hr_utility.trace('Original string passed : ' || p_input_string);
   ls_output_string := translate(p_input_string,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz''. -0123456789',
		                   'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');
   hr_utility.trace('String returned : ' || ls_output_string);
   RETURN ls_output_string;
EXCEPTION
   WHEN OTHERS THEN
      RETURN p_input_string;
END f_evs_rem_spl_char;
---------------------------------------------------------------------------
-- EVS_PUT_REPORT
-- Description: Output mag file
--
---------------------------------------------------------------------------
procedure evs_put_record
  (p_file_id                     in utl_file.file_type
  ,p_ssn                         in varchar2
  ,p_last_name                   in varchar2
  ,p_first_name                  in varchar2
  ,p_middle_name                 in varchar2
  ,p_date_of_birth               in date
  ,p_gender                      in varchar2
  ,p_user_control_data           in varchar2
  ,p_requester_id_code           in varchar2
  ,p_multiple_req_indicator      in varchar2
  )
is
  --
  l_buff      varchar2(130);   -- XXXXX
  l_delimiter varchar2(1);
  l_proc      varchar2(72);
  l_multiple_req_indicator varchar2(3);

begin
      l_proc := g_package || 'evs_put_record';
      hr_utility.set_location('Entering : ' || l_proc,10);

      if p_multiple_req_indicator = 0 then
        l_multiple_req_indicator := '  ';
      else
        l_multiple_req_indicator := p_multiple_req_indicator;
      end if;

      l_delimiter := fnd_global.local_chr(10);

      l_buff :=
      -- 1-9
         rpad(nvl((substr(p_ssn,1,3) || substr(p_ssn,5,2) || substr(p_ssn,8,4)),' '),9,' ')
      -- 10-12
      || 'TPV'
      -- 13-15
      || '214'
      -- 16-28
      || rpad(p_last_name,13,' ')
      -- 29-38
      || rpad(nvl(p_first_name,' ') ,10,' ')
      -- 39-45
      || rpad(nvl(p_middle_name,' '),7,' ')
      -- 46-53
      || nvl(to_char(p_date_of_birth,'MMDDYYYY'),'       ')
      -- 54
      || nvl(p_gender,' ')
      -- 55-89
      || rpad(' ',35,' ')
      -- 90-103
      || rpad(nvl(p_user_control_data,' '),14,' ')
      -- 104-123
      || rpad(' ',20,' ')
      -- 124-127
      || p_requester_id_code
      -- 128-130
      || rpad(nvl(l_multiple_req_indicator,' '),3,' ')
      --
      || l_delimiter  -- BUG4447245
      ;
      hr_utility.trace('l_buff = ' || l_buff);

      fnd_file.put_line
      (which => fnd_file.output
      ,buff  => l_buff
      );

      utl_file.put(g_file_id,l_buff);
      utl_file.fflush(g_file_id); -- XXXXX

      hr_utility.set_location('Leavning : ' || l_proc,100);
end evs_put_record;
------------------------------------------------------------------------------
--
-- EVS_MAG_REPORT_MAIN
-- Description : Electronic EVS Report main routine
--
------------------------------------------------------------------------------
procedure evs_mag_report_main
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  --
  ,p_start_date                  in  varchar2
  ,p_end_date                    in  varchar2
  ,p_tax_unit_id                 in  number
  ,p_business_group_id           in  number
  ,p_report_category             in  varchar2
  ,p_media_type                  in  varchar2
  ) is
  --
  -- local variables
  --
  l_proc                         VARCHAR2(72);
  l_requester_id_code            varchar2(4);
  l_user_control_data            varchar2(20); -- BUG3917159
  l_multiple_req_indicator       varchar2(3);
  l_buff                         varchar2(200);
  l_start_date                   date;
  l_end_date                     date;
  l_path                         varchar2(2000);
  l_valid_profile                varchar2(2000);
  l_delimiter                    varchar2(1);
  l_count                        number;
  l_file_count                   number;
  l_gre_count                    number;
  l_header                       number;
  l_all_count                    number;
  l_gre_name                     varchar2(200);
  l_media_type                   varchar2(40);

  --
  -- Define cursor
  --
  CURSOR csr_valid_profile IS
  SELECT value
  FROM v$parameter
  WHERE name='utl_file_dir';

  --
  -- Retrieve GREs if gre parameter is blank
  --
  cursor csr_get_gre is
  select distinct hou.name           -- BUG4192188
        ,hsck.segment1               tax_unit_id
        ,hoi2.org_information1       requester_id_code
        ,hoi2.org_information2       user_control_data
  from   hr_organization_information hoi
        ,hr_organization_units       hou
        ,hr_soft_coding_keyflex      hsck
        ,hr_organization_information hoi2
  where  hou.business_group_id = p_business_group_id
  and    hsck.segment1 = to_char(hou.organization_id)
  and    hoi.organization_id = hou.organization_id
  and    hoi.org_information_context = 'CLASS'
  and    hoi.org_information1 = 'HR_LEGAL'
  and    hoi.org_information2 = 'Y'
  and    hou.date_from  <= l_end_date
  and    nvl(hou.date_to,to_date('4712-12-31','YYYY-MM-DD')) >= l_start_date
  and    hoi2.organization_id(+) = hou.organization_id
  and    hoi2.org_information_context(+) = 'EVS Filing'
  order by hou.name;

  cursor csr_get_org_info is
  SELECT
         hoi.org_information1 requester_id_code
        ,hoi.org_information2 user_control_data
        ,hou.name	name
  FROM
         hr_organization_information    hoi
        ,hr_organization_units      	hou
  WHERE
         hoi.organization_id 		=  p_tax_unit_id
  AND    hoi.org_information_context 	= 'EVS Filing'
  and    hoi.organization_id		= hou.organization_id
  ;

begin

  g_package     := 'per_evs_mag_report.';
  l_proc        := g_package||'evs_mag_report_main';
  g_file_name   := 'EVSREQ2K';
  l_file_count  := 0;
  l_count       := 0;
  l_all_count   := 0;
  l_header      := 0;
  l_gre_count   := 0;

  hr_utility.set_location('Entering:' || l_proc,10);
  --
  -- GET UTL_FILE_DIR
  --
  OPEN csr_valid_profile;
  FETCH csr_valid_profile INTO l_valid_profile;
  if csr_valid_profile%FOUND then
    close csr_valid_profile;
    hr_utility.trace('l_valid_profile : ' || l_valid_profile);
    l_path     := GET_ROOT_DIR(l_valid_profile);
    hr_utility.trace('UTL_FILE_DIR : ' || l_path    );
  else
   null;
    close csr_valid_profile;
  end if;
--
  hr_utility.set_location(l_proc,20);

  if p_start_date is null then
    l_start_date := fnd_date.canonical_to_date(to_char(sysdate,'YYYY/MM/DD'));
  else
    l_start_date := fnd_date.canonical_to_date(p_start_date);
  end if;

  if p_end_date is null then
    l_end_date := to_date(to_char(sysdate,'YYYY') || '-12-31', 'YYYY-MM-DD');
  else
    l_end_date := fnd_date.canonical_to_date(p_end_date);
  end if;

  if p_media_type is NULL then
    l_media_type := 'DISKETTE';
  else
    l_media_type := p_media_type;
  end if;

  hr_utility.trace('l_start_date         = ' || l_start_date);
  hr_utility.trace('l_end_date           = ' || l_end_date);
  hr_utility.trace('p_tax_unit_id        = ' || p_tax_unit_id);
  hr_utility.trace('p_business_group_id  = ' || p_business_group_id);
  hr_utility.trace('p_report_category    = ' || p_report_category);
  hr_utility.trace('p_media_type         = ' || l_media_type);


  if p_tax_unit_id is not NULL then

    hr_utility.set_location(l_proc,30);

    open csr_get_org_info;
    fetch csr_get_org_info into l_requester_id_code
                             ,l_user_control_data
                             ,l_gre_name;

    if csr_get_org_info%NOTFOUND then
      close csr_get_org_info;
      select name  into l_gre_name
         from hr_organization_units
         where organization_id = p_tax_unit_id;
      fnd_message.set_name('PER','HR_449246_EVS_NO_REQ_ID');
      fnd_message.set_token('GRE',l_gre_name);
      fnd_message.raise_error;
    else
       close csr_get_org_info;
    end if;

    hr_utility.set_location(l_proc,40);

    hr_utility.trace('l_requestoer_id_code = ' || l_requester_id_code);
    hr_utility.trace('l_user_control_data  = ' || l_user_control_data);
    hr_utility.trace('p_report_category    = ' || p_report_category);

    --
    -- File Open
    --
    g_file_id := utl_file.fopen(l_path,g_file_name,'w');

    evs_mag_report
         (p_path                        =>      l_path
         ,p_report_category             =>      p_report_category
         ,p_user_control_data           =>      l_user_control_data
         ,p_requester_id_code           =>      l_requester_id_code
         ,p_business_group_id           =>      p_business_group_id
         ,p_tax_unit_id                 =>      p_tax_unit_id
         ,p_start_date                  =>      l_start_date
         ,p_end_date                    =>      l_end_date
         ,p_count                       =>      l_count
         ,p_media_type                  =>      l_media_type
         ,p_gre_count                   =>      l_gre_count
         );

    hr_utility.set_location(l_proc,50);
    utl_file.fclose(g_file_id);
    if l_header = 0 then
      fnd_file.put_line
       (which  => fnd_file.log
       ,buff   => '                                                         '
      );
      fnd_file.put_line
       (which  => fnd_file.log
       ,buff   => '  EVS Report Summary                                     '
      );
      fnd_file.put_line
       (which  => fnd_file.log
       ,buff   => '                                                         '
      );
      fnd_file.put_line
       (which  => fnd_file.log
       ,buff   => '  GRE Name                Total number                   '
      );
      fnd_file.put_line
       (which  => fnd_file.log
       ,buff   => '  -------------------     -------------                  '
      );
      l_header := 1;
    end if;
    fnd_file.put_line
      (which  => fnd_file.log
      ,buff   => '  ' || rpad(l_gre_name,20,' ') || '    ' || to_char(l_gre_count)
    );
    fnd_file.put_line
     (which  => fnd_file.log
     ,buff   => '                                                         '
    );
  else
      hr_utility.set_location(l_proc,60);
      --
      -- GRE parameter is blank
      --

      --
      -- File Open
      --
      g_file_id := utl_file.fopen(l_path,g_file_name,'w');

      FOR gre_record IN csr_get_gre LOOP
         if gre_record.requester_id_code is NULL then
           fnd_message.set_name('PER','HR_449246_EVS_NO_REQ_ID');
           fnd_message.set_token('GRE',gre_record.name);
           fnd_message.raise_error;
         end if;

         evs_mag_report
         (p_path                        =>      l_path
         ,p_report_category             =>      p_report_category
         ,p_user_control_data           =>      gre_record.user_control_data
         ,p_requester_id_code           =>      gre_record.requester_id_code
         ,p_business_group_id           =>      p_business_group_id
         ,p_tax_unit_id                 =>      gre_record.tax_unit_id
         ,p_start_date                  =>      l_start_date
         ,p_end_date                    =>      l_end_date
         ,p_count                       =>      l_count
         ,p_media_type                  =>      l_media_type
         ,p_gre_count                   =>	l_gre_count
         );

         hr_utility.set_location(l_proc,70);

         if l_header = 0 then
           fnd_file.put_line
            (which  => fnd_file.log
            ,buff   => '                                                      '
           );
           fnd_file.put_line
            (which  => fnd_file.log
            ,buff   => '  EVS Report Summary                                  '
           );
           fnd_file.put_line
            (which  => fnd_file.log
            ,buff   => '                                                      '
           );
           fnd_file.put_line
            (which  => fnd_file.log
            ,buff   => '  GRE Name                Total number                '
           );
           fnd_file.put_line
            (which  => fnd_file.log
            ,buff   => '  -------------------     -------------               '
           );
           l_header := 1;
         end if;
         hr_utility.set_location(l_proc,71);
         fnd_file.put_line
         (which  => fnd_file.log
         ,buff   => '  ' || rpad(gre_record.name,20,' ') ||
                   '    ' || to_char(l_gre_count)
         );
         l_all_count := l_all_count + l_gre_count;
      END LOOP;
      hr_utility.set_location(l_proc,72);
      fnd_file.put_line
      (which  => fnd_file.log
      ,buff   => '  ' || rpad('ALL GREs',20,' ') ||
                 '    ' || to_char(l_all_count)
      );
      fnd_file.put_line
      (which  => fnd_file.log
       ,buff   => '                                                      '
      );
      -- utl_file.fclose(g_file_id);   -- 08-JUL-2005
      hr_utility.set_location(l_proc,74);
  end if;
  hr_utility.set_location('Leaving..: ' || l_proc,100);

EXCEPTION
  WHEN OTHERS THEN
   hr_utility.set_location(l_proc || substr(sqlerrm,1,50),999);
   fnd_file.put_line(fnd_file.log,SQLERRM);
   RAISE;

end evs_mag_report_main;

end per_evs_mag_report;

/
