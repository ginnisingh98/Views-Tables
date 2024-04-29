--------------------------------------------------------
--  DDL for Package Body HXC_PREFERENCE_EVALUATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_PREFERENCE_EVALUATION" AS
/* $Header: hxcpfevl.pkb 120.18.12010000.2 2008/10/16 17:39:08 asrajago ship $ */

   g_migration_mode         BOOLEAN       := FALSE;
   g_package                VARCHAR2 (72) := 'hxc_preference_evaluation';
   g_debug boolean := hr_utility.debug_enabled;

-- will use PL/SQL tables in various places to manipulate preference information

TYPE t_str_version_row IS RECORD
( org_Structure_id      per_organization_structures.organization_structure_id%TYPE,
  org_version_id        per_org_structure_versions.org_structure_version_id%type,
  time_info             date);

TYPE t_requested_pref IS RECORD
( code      hxc_pref_definitions.code%TYPE,
  attr_list VARCHAR2(90) );

TYPE t_dated_pref_row IS RECORD
( start_date  DATE,
  end_date    DATE,
  code        hxc_pref_definitions.code%TYPE,
  rule_evaluation_order NUMBER,
  pref_ref    NUMBER,
  edit_allowed hxc_pref_hierarchies.edit_allowed%TYPE);

TYPE t_hierarchy_list_row IS RECORD
(
pref_hierarchy_id NUMBER,
start_date DATE,
end_date DATE,
elig_start_date DATE,
elig_end_date DATE,
rule_evaluation_order NUMBER);

TYPE t_requested_pref_list IS TABLE OF
  t_requested_pref
INDEX BY BINARY_INTEGER;

TYPE t_pref_trans IS TABLE OF
  hxc_pref_definitions.code%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_hierarchy_list IS TABLE OF
t_hierarchy_list_row
INDEX BY BINARY_INTEGER;

-- when evaluating preferences with a range of dates, its possible to have
-- more than one value for a single preference. The following structure is used
-- to keep track of which rows in a preference table are for which preference.

TYPE t_dated_prefs IS TABLE OF
t_dated_pref_row
INDEX BY BINARY_INTEGER;

TYPE t_str_version is table of t_str_version_row
index by binary_integer;

g_str_version t_str_version;

g_input_separator VARCHAR2(1) := '|';
g_raise_fatal_errors BOOLEAN := TRUE;
g_fatal_error_occurred BOOLEAN := FALSE;
g_fatal_error VARCHAR2(30) :='';

-- variables and type for sorted date range preference evaluation

g_sort_pref_table t_pref_table;

TYPE r_sort_cache IS RECORD ( resource_id NUMBER(15), start_date DATE, end_date DATE);
TYPE t_sort_cache IS TABLE OF r_sort_cache INDEX BY BINARY_INTEGER;

g_sort_cache t_sort_cache;

--------
-- Procedure RETURNs all the preferences for a given resource_id
--------
--------Function added for the bug 3868611

Function check_number(p_string in varchar2)  return number is
l_string number;
BEGIN
      l_string:= to_number(p_string);
      return(l_string);
EXCEPTION
 WHEN OTHERS THEN
 return(null);
END;



PROCEDURE resource_preferences(p_resource_id IN NUMBER,
                               p_pref_table  IN OUT NOCOPY t_pref_table,
                               p_evaluation_date IN DATE default sysdate,
                               p_user_id IN number default fnd_global.user_id,
	     		       p_resp_id IN number default -99,
			       p_ignore_user_id in boolean default false,
			       p_ignore_resp_id in boolean default false)

IS

l_req                NUMBER;
l_personal_hierarchy NUMBER;
l_hier               NUMBER;
l_requested_list     t_requested_pref_list;
l_pref_trans         t_pref_trans;
l_hierarchy_list     t_hierarchy_list;
l_evaluation_date    DATE;
l_hier_count    number;
l_employee_id NUMBER;

--Added By Mithun for CWK Terminate Bug
cwk_final_process_date	DATE;
l_num_of_days_to_add	NUMBER;

-- Bug 3297639
l_pref_index number;
l_preference_id number;
l_last_updated_date date;
l_use_cache boolean := FALSE;

--Added By Mithun
l_resp_id		NUMBER;
CURSOR c_get_last_updated_date(p_pref_hierarchy_id IN number) IS
	Select last_update_date
	From hxc_pref_hierarchies
	Where pref_hierarchy_id = p_pref_hierarchy_id;

-- CURSORs to find the hierarchies a resource is eligible for ...
-- To support new criteria add new CURSORs or add to existing CURSOR.

CURSOR get_employee_id(p_user_id IN Number) Is

  Select employee_id from fnd_user
  Where user_id = p_user_id;


/*Cursor Modified By Mithun for CWK Terminate Bug*/
-- Modified the cursor to support CWK.
CURSOR c_eligible_hierarchies_basic(p_resource_id IN NUMBER,
                                    p_evaluation_date IN DATE) IS

  SELECT hrr.pref_hierarchy_id, hrr.rule_evaluation_order
      FROM hxc_resource_rules hrr,
           per_all_assignments_f pa
     WHERE pa.person_id = p_resource_id
       AND nvl(hrr.business_group_id,pa.business_group_id) = pa.business_group_id
       AND pa.primary_flag = 'Y'
       and pa.assignment_type in ('E','C')
       AND p_evaluation_date
           BETWEEN pa.effective_start_date
           AND Decode(pa.assignment_type , 'C',
		Decode(cwk_final_process_date,pa.effective_END_date,pa.effective_END_date + l_num_of_days_to_add ,pa.effective_END_date),pa.effective_END_date)
       AND p_evaluation_date between hrr.start_date and hrr.end_date
       AND ((   to_char(pa.assignment_id) = hrr.eligibility_criteria_id
                    AND hrr.eligibility_criteria_type = 'ASSIGNMENT')
        OR (      to_char(pa.payroll_id) = hrr.eligibility_criteria_id
                    AND hrr.eligibility_criteria_type = 'PAYROLL')
        OR (       to_char(pa.person_id) = hrr.eligibility_criteria_id
                    AND hrr.eligibility_criteria_type = 'PERSON')
        OR (     to_char(pa.location_id) = hrr.eligibility_criteria_id
                    AND hrr.eligibility_criteria_type = 'LOCATION')
        OR (     pa.EMPLOYEE_CATEGORY = hrr.eligibility_criteria_id
                    AND hrr.eligibility_criteria_type = 'EMP_CATEGORY')
        OR (     pa.EMPLOYMENT_CATEGORY = hrr.eligibility_criteria_id
                    AND hrr.eligibility_criteria_type = 'ASGN_CATEGORY')
        OR (     to_char(pa.organization_id) = hrr.eligibility_criteria_id
                    AND hrr.eligibility_criteria_type = 'ORGANIZATION')
        OR (
             hrr.eligibility_criteria_type = 'ALL_PEOPLE'));


 -- Bug 7484448
 -- Added USE_NL in the below query for optimum perf.
/*Cursor Modified By Mithun for CWK Terminate Bug*/
CURSOR c_eligible_hierarchies_rollup(p_resource_id IN NUMBER,
                                    p_evaluation_date IN DATE) IS
    SELECT /*+ USE_NL(PA HRR) */
           hrr.pref_hierarchy_id, hrr.rule_evaluation_order
      FROM hxc_resource_rules hrr,
           per_all_assignments_f pa
     WHERE pa.person_id = p_resource_id
       AND nvl(hrr.business_group_id,pa.business_group_id) = pa.business_group_id
       AND pa.primary_flag = 'Y'
       and pa.assignment_type in ('E','C')
       AND p_evaluation_date
              BETWEEN pa.effective_start_date
	                 AND Decode(pa.assignment_type , 'C',
	      		Decode(cwk_final_process_date,pa.effective_END_date,pa.effective_END_date + l_num_of_days_to_add ,pa.effective_END_date),pa.effective_END_date)
       AND p_evaluation_date between hrr.start_date and hrr.end_date
       AND (
        ((HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,instr(hrr.eligibility_criteria_id,'-',1,1)+1)) in
           (SELECT pose.organization_id_parent
                  FROM
                 per_org_structure_elements pose
		 start with organization_id_child = pa.organization_id
                 and  pose.org_structure_version_id=
                      HXC_PREFERENCE_EVALUATION.return_version_id(HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,1,instr(hrr.eligibility_criteria_id,'-',1,1)-1)),
                                                                           hrr.eligibility_criteria_type)
                  connect by prior organization_id_parent=organization_id_child
                  and  pose.org_structure_version_id=
                               HXC_PREFERENCE_EVALUATION.return_version_id(HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,1,instr(hrr.eligibility_criteria_id,'-',1,1)-1)),
                                                                           hrr.eligibility_criteria_type)
                  union
                  select organization_id
                  from   hr_all_organization_units
                  where  organization_id =  pa.organization_id))
                  AND  hrr.eligibility_criteria_type = 'ROLLUP' )
        );

/*Cursor Modified By Mithun for CWK Terminate Bug*/
-- Modified cursor to support CWK.
CURSOR c_eligible_hierarchies_flex(p_resource_id IN NUMBER,
                                   p_evaluation_date IN DATE) IS
  SELECT hrr.pref_hierarchy_id, hrr.rule_evaluation_order
    FROM hxc_resource_rules hrr,
         per_all_assignments_f pa
   WHERE pa.person_id = p_resource_id
     AND nvl(hrr.business_group_id,pa.business_group_id) = pa.business_group_id
     AND pa.primary_flag = 'Y'
and pa.assignment_type in ('E','C')
     AND p_evaluation_date
              BETWEEN pa.effective_start_date
           AND Decode(pa.assignment_type , 'C',
		Decode(cwk_final_process_date,pa.effective_END_date,pa.effective_END_date + l_num_of_days_to_add ,pa.effective_END_date),pa.effective_END_date)
     AND p_evaluation_date between hrr.start_date and hrr.end_date
AND ( (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 3 ),
      'SCL', DECODE ( pa.soft_coding_keyflex_id, NULL, -1,
      hxc_resource_rules_utils.chk_flex_valid ('SCL', pa.soft_coding_keyflex_id,
      SUBSTR( hrr.eligibility_criteria_type, 5 ),
                  hrr.eligibility_criteria_id )), -1 ) = 1 )
OR
      (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 6 ),
      'PEOPLE', DECODE ( pa.people_group_id, NULL, -1,
      hxc_resource_rules_utils.chk_flex_valid ( 'PEOPLE', pa.people_group_id,
      SUBSTR( hrr.eligibility_criteria_type, 8 ),
                  hrr.eligibility_criteria_id )), -1 ) = 1 )
OR
      (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 5 ),
      'GRADE', DECODE ( pa.grade_id, NULL, -1,
      hxc_resource_rules_utils.chk_flex_valid ( 'GRADE', pa.grade_id,
      SUBSTR( hrr.eligibility_criteria_type, 7 ),
                  hrr.eligibility_criteria_id )), -1 ) = 1 )
OR

      (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 3 ),
      'JOB', hrr.eligibility_criteria_id, -1 ) = to_char(pa.job_id))-- Issue 4

OR

      (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 8 ),
      'POSITION', hrr.eligibility_criteria_id, -1 ) = to_char(pa.position_id)) -- Issue 4
);

-- Cursor to check whether the resource has personalized preferences.
-- Note that this CURSOR could be removed in order to possibly boost performance
-- But, keep it simple for now.

CURSOR c_personal_hierarchy(p_user_id IN NUMBER) IS
SELECT hrr.pref_hierarchy_id , hrr.rule_evaluation_order
FROM   hxc_resource_rules hrr
WHERE  hrr.resource_type='PERSON'
AND    hrr.eligibility_criteria_type = 'LOGIN'
AND    hrr.eligibility_criteria_id = to_char(p_user_id) ; -- Issue 4



-- Cursor to pick up any responsibility based prefs(both responsibility and perst responsibility)

     CURSOR c_resp_hierarchies(p_responsibility_id IN NUMBER,
                               p_evaluation_date IN DATE) IS
     SELECT hrr.pref_hierarchy_id ,
            hrr.rule_evaluation_order
       FROM hxc_resource_rules hrr
      WHERE hrr.resource_type='PERSON'
        AND p_evaluation_date BETWEEN hrr.start_date
                                  AND hrr.end_date
        AND hrr.eligibility_criteria_type IN ('RESPONSIBILITY','PERST_RESPONSIBILITY')
        AND hrr.eligibility_criteria_id = to_char(p_responsibility_id); -- Issue 4



--Added By Mithun
--Cursor to pick up only persistent responsibility based preference
    CURSOR c_perst_resp_hierarchies(p_responsibility_id IN NUMBER,
                                    p_evaluation_date   IN DATE) IS
    SELECT hrr.pref_hierarchy_id ,
           hrr.rule_evaluation_order
      FROM hxc_resource_rules hrr
     WHERE hrr.resource_type='PERSON'
       AND p_evaluation_date BETWEEN hrr.start_date
                                 AND hrr.end_date
       AND hrr.eligibility_criteria_type = 'PERST_RESPONSIBILITY'
       AND hrr.eligibility_criteria_id = to_char(p_responsibility_id);

 -- Issue 4


/*Cursor Modified By Mithun for CWK Terminate Bug*/
CURSOR c_person_type_hierarchies(p_resource_id IN NUMBER,p_evaluation_date IN DATE) IS
SELECT hrr.pref_hierarchy_id , hrr.rule_evaluation_order
FROM   hxc_resource_rules hrr,
per_person_types typ,
per_person_type_usages_f ptu
WHERE  hrr.resource_type='PERSON'
AND    p_evaluation_date between hrr.start_date and hrr.end_date
AND    hrr.eligibility_criteria_type = 'PERSON_TYPE'
AND    hrr.eligibility_criteria_id = to_char(ptu.person_type_id) -- Issue 4
AND    ptu.person_id = p_resource_id
AND    typ.system_person_type IN ('EMP','EX_EMP','EMP_APL','EX_EMP_APL','CWK','EX_CWK')
AND    typ.person_type_id = ptu.person_type_id
AND    p_evaluation_date between Ptu.effective_start_date
	and Decode(typ.system_person_type , 'CWK',
		Decode(cwk_final_process_date,Ptu.effective_end_date, Ptu.effective_end_date + l_num_of_days_to_add , Ptu.effective_end_date) ,Ptu.effective_end_date);
------------------------------------------------------------------------------------
-- Cursor to RETURN the preference nodes in a hierarchy. Note that this is based
-- on a hierchical query. This can be removed if necessary by denormalization
-- on the hxc_pref_hierarchy base table

CURSOR c_pref_nodes(p_hierarchy_id IN NUMBER)
IS
 SELECT pref_hierarchy_id
  ,pref_definition_id preference_id
  ,attribute1
  ,attribute2
  ,attribute3
  ,attribute4
  ,attribute5
  ,attribute6
  ,attribute7
  ,attribute8
  ,attribute9
  ,attribute10
  ,attribute11
  ,attribute12
  ,attribute13
  ,attribute14
  ,attribute15
  ,attribute16
  ,attribute17
  ,attribute18
  ,attribute19
  ,attribute20
  ,attribute21
  ,attribute22
  ,attribute23
  ,attribute24
  ,attribute25
  ,attribute26
  ,attribute27
  ,attribute28
  ,attribute29
  ,attribute30
  ,edit_allowed
  ,displayed
  ,name
  ,top_level_parent_id --Performance Fix
  ,code
  FROM hxc_pref_hierarchies
  WHERE top_level_parent_id = p_hierarchy_id;
--  pref_definition_id is not null
--  START WITH pref_hierarchy_id = p_hierarchy_id
--  CONNECT BY prior pref_hierarchy_id = parent_pref_hierarchy_id;
-- Performance Fix.
/*CURSOR c_pref_codes
IS
SELECT
 pref_definition_id, code
FROM hxc_pref_definitions;*/

l_user_id	NUMBER;

/* Mikarthi Terminated CWK Enhancement */
Cursor c_cwk_terminate_date( p_person_id IN NUMBER, p_evaluation_date IN DATE) is
Select NVL(final_process_date, hr_general.end_of_time)
from per_periods_of_placement
where person_id = p_person_id
and date_start <= p_evaluation_date
order by date_start desc;

/*End of Terminated CWK Enhancement Addtion */

l_find_resp_required	BOOLEAN DEFAULT FALSE;

BEGIN

--Here we are checking whether it is really required to do preference evaluation based on
--Responsibility. There can be three conditions
--1)  p_resp_id = -99 This is the default value for the parameter. So this could come
--    either because no value was passed while calling resource_preference,
--    or explicitly -99 was passed while calling resource preference. In either case
--    persistent responsibiilty preference evalution would be done. Which means, we
--    would obtain the responsibility stored in the timecard and then obtain preferences
--    attached to that responsibility, if any. If no valid responsibility is obtained
--    from the tc and if employee_id and the resource_id is the same, then we will do
--    persistent resp evalution based on the FND_global.resp_id
--2)  p_resp_id = -101 we dont have to do preference evalution on persistent responsibility
--

g_debug := hr_utility.debug_enabled;

       IF g_debug
       THEN
          hr_utility.trace('Evaluation pref for p_evaluation_date ');
       	  hr_utility.trace('p_resource_id '||p_resource_id);
       	  hr_utility.trace('p_evaluation_date '||p_evaluation_date);
       END IF;

       l_resp_id := p_resp_id;
       l_user_id := p_user_id;

       -- Find out if the resource himself is logged in.
       -- In that case, there is no need of looking into any
       -- timecard, consider persistent responsibility also as
       -- session responsibility.

       OPEN get_employee_id(fnd_global.user_id);

       FETCH get_employee_id
        INTO l_employee_id ;

       CLOSE get_employee_id;

       IF ( p_resp_id = -99 ) AND (l_employee_id <> p_resource_id)
       THEN

           l_find_resp_required := TRUE;

       ELSE

 	   l_find_resp_required := FALSE;

       END IF;

       -- Either ways, you need this responsibility. This is the key
       -- in case the user is the employee himself.

       l_resp_id := FND_GLOBAL.RESP_ID;


      IF g_debug
      THEN
         hr_utility.trace('Current user''s user_id is '||fnd_global.user_id);
         hr_utility.trace('Current user''s person_id is '||l_employee_id);
      END IF;

-- make sure pref table is empty - otherwise this will interfere with the evaluation
p_pref_table.delete;

-- l_evaluation_date:=trunc(p_evaluation_date); -- replaced for bug 3097015 with
-- the following function call ...
      l_evaluation_date :=
            evaluation_date (
               p_resource_id=> p_resource_id,
               p_evaluation_date=> p_evaluation_date
            );

-- populate table that will allow us to find a pref_code given an
-- pref_definition_id
-- note:
-- a) could do this join in one of the CURSORs - choose not to do this to avoid
--    complexity in the SQL which might lead to overly complex execution plan.
-- b) could denormalize the code onto the pref_hierarchies table thus making
-- this step redundent.
-- c) could turn this into a bulk collect - pick up the values AND THEN
-- populate the array later.
-- Probably do b) in conjunction with other denormalization

-- Performance Fix
--FOR pref_rec IN c_pref_codes LOOP
--  l_pref_trans(pref_rec.pref_definition_id) := pref_rec.code;
--END LOOP;

--Added By Mithun for CWK Terminate Bug
OPEN c_cwk_terminate_date (p_resource_id, p_evaluation_date);
FETCH c_cwk_terminate_date INTO cwk_final_process_date;
CLOSE c_cwk_terminate_date;

l_num_of_days_to_add := NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0);

if g_debug then

	HR_UTILITY.trace(g_package || ' cwk_final_process_date ' || cwk_final_process_date);
	HR_UTILITY.trace(g_package || 'l_num_of_days_to_add ' || l_num_of_days_to_add);

end if;
--End of Addition By Mithun for CWK Terminate Bug

l_hier_count:=0;
-- Now find the hierarchies which the person is eligible for ...
-- note:
-- a) IF we cycle through the hierarchies in order of increasing precidence
--    - dont even need to do evaluation as we cycle. Sort is probably more
--      expensive though ...

-- basic eligibility, must be at least one

FOR hier_rec IN c_eligible_hierarchies_basic(p_resource_id, l_evaluation_date) LOOP
   l_hierarchy_list(l_hier_count).rule_evaluation_order := hier_rec.rule_evaluation_order;
   l_hierarchy_list(l_hier_count).pref_hierarchy_id     := hier_rec.pref_hierarchy_id;
   l_hier_count:=l_hier_count+1;
END LOOP;

BEGIN
FOR hier_rec IN c_eligible_hierarchies_rollup(p_resource_id, l_evaluation_date) LOOP
   l_hierarchy_list(l_hier_count).rule_evaluation_order := hier_rec.rule_evaluation_order;
   l_hierarchy_list(l_hier_count).pref_hierarchy_id     := hier_rec.pref_hierarchy_id;
   l_hier_count:=l_hier_count+1;
END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN null;
END;

-- Issue 6
IF(l_hierarchy_list.count = 0)
then
  IF( g_raise_fatal_errors = TRUE) THEN
    hr_utility.set_message(809, 'HXC_NO_HIER_FOR_DATE');
    hr_utility.raise_error;
  ELSE
    g_fatal_error_occurred := TRUE;
    g_fatal_error := 'HXC_NO_HIER_FOR_DATE';
    RETURN;
  END IF;
END IF;

-- more complex eligibility, zero or more

BEGIN
FOR hier_rec in c_eligible_hierarchies_flex(p_resource_id, l_evaluation_date) LOOP
   l_hierarchy_list(l_hier_count).rule_evaluation_order := hier_rec.rule_evaluation_order;
   l_hierarchy_list(l_hier_count).pref_hierarchy_id     := hier_rec.pref_hierarchy_id;
   l_hier_count                                         := l_hier_count+1;

END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
END;

--IF(fnd_global.resp_id <> -1) THEN
--IF(p_resp_id <> -1) then

-- Issue 3
/*If (p_user_id = -1) Then
        -- we are defaulting the value
        -- from the fnd_global value
	l_employee_id 	:= fnd_global.employee_id;
	l_user_id	:= fnd_global.user_id;
Else*/

--End If;

-- Responsibility based hierarchies
-- ================================
--  If the resource himself is in session, you only look for session responsibility
--  Otherwise, you have to look into which timecard is in question to find out
--  which responsibility last touched the timecard.


If (l_resp_id <> -1  AND ( not p_ignore_resp_id)) Then

        -- Do a session based resp evaluation only when the user himself is logged
        -- in. But at this point consider even persistent responsibility. Note the
        -- defn of the cursor that is opened here.

	IF  l_employee_id = p_resource_id
	THEN
		BEGIN
			FOR hier_rec in c_resp_hierarchies(l_resp_id, l_evaluation_date) LOOP
			      l_hierarchy_list(l_hier_count).rule_evaluation_order := hier_rec.rule_evaluation_order;
			      l_hierarchy_list(l_hier_count).pref_hierarchy_id     := hier_rec.pref_hierarchy_id;

			      l_hier_count                                         := l_hier_count+1;
			END LOOP;
		EXCEPTION
		    WHEN NO_DATA_FOUND THEN null;
		END;
	END IF;

        --Checking If we have to obtain the resp_id value stored in  the timecard
	IF l_find_resp_required
	THEN
		l_resp_id := get_tc_resp(p_resource_id, l_evaluation_date);

		--l_resp_id = -101 here indicates that some other user (for eg TK) has modified this timecard
		--and the current resp_id stored is the resp_id used by that user. So we should not use
		--that resp_id for preference evalution. However we still have to do preference
		--evaluation on persistent responsibility using resp id as fnd_global.resp_id
		--if l_employee_id = p_resource_id
	        IF l_resp_id <> -101
	        THEN
			BEGIN

				FOR hier_rec IN c_perst_resp_hierarchies(l_resp_id, l_evaluation_date)
				LOOP
				      l_hierarchy_list(l_hier_count).rule_evaluation_order := hier_rec.rule_evaluation_order;
				      l_hierarchy_list(l_hier_count).pref_hierarchy_id     := hier_rec.pref_hierarchy_id;

				      l_hier_count                                         := l_hier_count+1;
				END LOOP;
			EXCEPTION
			    WHEN NO_DATA_FOUND THEN null;
			END;
		END IF;
	END IF;
End If;
--End of changes Done By Myth

-- personalisation, only one hierarchy possible
-- Issue 3 Added p_ignore_user_id

BEGIN
FOR hier_rec in c_person_type_hierarchies(p_resource_id, l_evaluation_date) LOOP
   l_hierarchy_list(l_hier_count).rule_evaluation_order := hier_rec.rule_evaluation_order;
   l_hierarchy_list(l_hier_count).pref_hierarchy_id     := hier_rec.pref_hierarchy_id;
   l_hier_count                                         := l_hier_count+1;

END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
END;

-----------------------------------------------------------------------------------------


if (( NOT p_ignore_user_id) AND l_employee_id = p_resource_id AND l_user_id <> -1) then
BEGIN
FOR hier_rec IN c_personal_hierarchy(l_user_id) LOOP
   l_hierarchy_list(l_hier_count).rule_evaluation_order := hier_rec.rule_evaluation_order;
   l_hierarchy_list(l_hier_count).pref_hierarchy_id     := hier_rec.pref_hierarchy_id;
   l_hier_count                                         := l_hier_count+1;
END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
END;
END if;

   -- Issue 6
/*IF(l_hierarchy_list.count = 0)
then
  IF( g_raise_fatal_errors = TRUE) THEN
    hr_utility.set_message(809, 'HXC_NO_HIER_FOR_DATE');
    hr_utility.raise_error;
  ELSE
    g_fatal_error_occurred := TRUE;
    g_fatal_error := 'HXC_NO_HIER_FOR_DATE';
    RETURN;
  END IF;
END IF;*/

-- loop over the hierarchies we have found

l_hier := l_hierarchy_list.first;

l_hier := l_hierarchy_list.first;
g_loop_count := 0;

-- Bug 3297639.
-- Modified the logic for caching Preference values.
LOOP
  EXIT WHEN NOT l_hierarchy_list.exists(l_hier);

  --reset for each Pref Id
  l_use_cache := FALSE;

  -- Check if the required data is already cached.
  If ( g_pref_hier_ct.exists(l_hierarchy_list(l_hier).pref_hierarchy_id) ) then

	Open c_get_last_updated_date(l_hierarchy_list(l_hier).pref_hierarchy_id);
	Fetch c_get_last_updated_date into l_last_updated_date;
	Close c_get_last_updated_date;

	-- checking if the cache data is outdated.
	if ( g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).caching_time >= l_last_updated_date) then
		l_use_cache := TRUE;
	else
	        l_use_cache := FALSE;
		-- Delete the Pref Values for this, since it has to be refreshed anyway.
		g_pref_values_ct.delete(g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index,g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index); -- table.delete(m,n)
	end if;
  end if;

  -- If l_use_cache = FALSE, then populate/refresh cache data by db fetch.
  If (not l_use_cache) then

    -- initialise main table.
    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).caching_time := sysdate;
    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index := -1;
    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index := -1;

    -- Initialize Start_Index for the Pref Values
    If (g_pref_values_ct.count > 0) then
	l_pref_index := g_pref_values_ct.last + 1;
    else
	l_pref_index := 1;
    End If;

    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index := l_pref_index;

    -- populate preference values into cache
    FOR pref_node in c_pref_nodes(l_hierarchy_list(l_hier).pref_hierarchy_id)
    LOOP

    g_pref_values_ct(l_pref_index).pref_hierarchy_id := pref_node.pref_hierarchy_id;
    g_pref_values_ct(l_pref_index).pref_definition_id := pref_node.preference_id;
    g_pref_values_ct(l_pref_index).attribute1:= pref_node.attribute1;
    g_pref_values_ct(l_pref_index).attribute2:= pref_node.attribute2;
    g_pref_values_ct(l_pref_index).attribute3:= pref_node.attribute3;
    g_pref_values_ct(l_pref_index).attribute4:= pref_node.attribute4;
    g_pref_values_ct(l_pref_index).attribute5:= pref_node.attribute5;
    g_pref_values_ct(l_pref_index).attribute6:= pref_node.attribute6;
    g_pref_values_ct(l_pref_index).attribute7:= pref_node.attribute7;
    g_pref_values_ct(l_pref_index).attribute8:= pref_node.attribute8;
    g_pref_values_ct(l_pref_index).attribute9:= pref_node.attribute9;
    g_pref_values_ct(l_pref_index).attribute10:= pref_node.attribute10;
    g_pref_values_ct(l_pref_index).attribute11:= pref_node.attribute11;
    g_pref_values_ct(l_pref_index).attribute12:= pref_node.attribute12;
    g_pref_values_ct(l_pref_index).attribute13:= pref_node.attribute13;
    g_pref_values_ct(l_pref_index).attribute14:= pref_node.attribute14;
    g_pref_values_ct(l_pref_index).attribute15:= pref_node.attribute15;
    g_pref_values_ct(l_pref_index).attribute16:= pref_node.attribute16;
    g_pref_values_ct(l_pref_index).attribute17:= pref_node.attribute17;
    g_pref_values_ct(l_pref_index).attribute18:= pref_node.attribute18;
    g_pref_values_ct(l_pref_index).attribute19:= pref_node.attribute19;
    g_pref_values_ct(l_pref_index).attribute20:= pref_node.attribute20;
    g_pref_values_ct(l_pref_index).attribute21:= pref_node.attribute21;
    g_pref_values_ct(l_pref_index).attribute22:= pref_node.attribute22;
    g_pref_values_ct(l_pref_index).attribute23:= pref_node.attribute23;
    g_pref_values_ct(l_pref_index).attribute24:= pref_node.attribute24;
    g_pref_values_ct(l_pref_index).attribute25:= pref_node.attribute25;
    g_pref_values_ct(l_pref_index).attribute26:= pref_node.attribute26;
    g_pref_values_ct(l_pref_index).attribute27:= pref_node.attribute27;
    g_pref_values_ct(l_pref_index).attribute28:= pref_node.attribute28;
    g_pref_values_ct(l_pref_index).attribute29:= pref_node.attribute29;
    g_pref_values_ct(l_pref_index).attribute30:= pref_node.attribute30;

    g_pref_values_ct(l_pref_index).edit_allowed:= pref_node.edit_allowed;
    g_pref_values_ct(l_pref_index).displayed:= pref_node.displayed;
    g_pref_values_ct(l_pref_index).name:= pref_node.name;
    g_pref_values_ct(l_pref_index).top_level_parent_id:= pref_node.top_level_parent_id;
    g_pref_values_ct(l_pref_index).code:= pref_node.code;

    l_pref_index := g_pref_values_ct.last + 1;
    End Loop;

    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index := l_pref_index - 1;

    -- check for valid start and stop index. Incase the only leaf node was deleted or no leaf nodes exists then reset start and stop index accordingly
    if (g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index < g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index) then
        g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index := 0;
	g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index := 0;
    end if;

    l_use_cache := TRUE; -- now data is in cache
  End If;

  -- Now required data is in cache. Populate this required data to the main table after evaluation.
  If (g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index <> 0 ) then     --(case where parent node has no children)
    For l_index in g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index..g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_index Loop
    Begin

        l_preference_id := g_pref_values_ct(l_index).pref_definition_id;
	IF( (l_hierarchy_list(l_hier).rule_evaluation_order >
                         p_pref_table(l_preference_id).rule_evaluation_order
           AND p_pref_table(l_preference_id).rule_evaluation_order <>0)
           OR (l_hierarchy_list(l_hier).rule_evaluation_order = 0
           AND p_pref_table(l_preference_id).edit_allowed = 'Y') ) THEN

	    p_pref_table(l_preference_id).attribute1 := g_pref_values_ct(l_index).attribute1;
	    p_pref_table(l_preference_id).attribute2 := g_pref_values_ct(l_index).attribute2;
	    p_pref_table(l_preference_id).attribute3 := g_pref_values_ct(l_index).attribute3;
	    p_pref_table(l_preference_id).attribute4 := g_pref_values_ct(l_index).attribute4;
	    p_pref_table(l_preference_id).attribute5 := g_pref_values_ct(l_index).attribute5;
	    p_pref_table(l_preference_id).attribute6 := g_pref_values_ct(l_index).attribute6;
	    p_pref_table(l_preference_id).attribute7 := g_pref_values_ct(l_index).attribute7;
	    p_pref_table(l_preference_id).attribute8 := g_pref_values_ct(l_index).attribute8;
	    p_pref_table(l_preference_id).attribute9 := g_pref_values_ct(l_index).attribute9;
	    p_pref_table(l_preference_id).attribute10 := g_pref_values_ct(l_index).attribute10;
	    p_pref_table(l_preference_id).attribute11 := g_pref_values_ct(l_index).attribute11;
	    p_pref_table(l_preference_id).attribute12 := g_pref_values_ct(l_index).attribute12;
	    p_pref_table(l_preference_id).attribute13 := g_pref_values_ct(l_index).attribute13;
	    p_pref_table(l_preference_id).attribute14 := g_pref_values_ct(l_index).attribute14;
	    p_pref_table(l_preference_id).attribute15 := g_pref_values_ct(l_index).attribute15;
	    p_pref_table(l_preference_id).attribute16 := g_pref_values_ct(l_index).attribute16;
	    p_pref_table(l_preference_id).attribute17 := g_pref_values_ct(l_index).attribute17;
	    p_pref_table(l_preference_id).attribute18 := g_pref_values_ct(l_index).attribute18;
	    p_pref_table(l_preference_id).attribute19 := g_pref_values_ct(l_index).attribute19;
	    p_pref_table(l_preference_id).attribute20 := g_pref_values_ct(l_index).attribute20;
	    p_pref_table(l_preference_id).attribute21 := g_pref_values_ct(l_index).attribute21;
	    p_pref_table(l_preference_id).attribute22 := g_pref_values_ct(l_index).attribute22;
	    p_pref_table(l_preference_id).attribute23 := g_pref_values_ct(l_index).attribute23;
	    p_pref_table(l_preference_id).attribute24 := g_pref_values_ct(l_index).attribute24;
	    p_pref_table(l_preference_id).attribute25 := g_pref_values_ct(l_index).attribute25;
	    p_pref_table(l_preference_id).attribute26 := g_pref_values_ct(l_index).attribute26;
	    p_pref_table(l_preference_id).attribute27 := g_pref_values_ct(l_index).attribute27;
	    p_pref_table(l_preference_id).attribute28 := g_pref_values_ct(l_index).attribute28;
	    p_pref_table(l_preference_id).attribute29 := g_pref_values_ct(l_index).attribute29;
	    p_pref_table(l_preference_id).attribute30 := g_pref_values_ct(l_index).attribute30;

	    p_pref_table(l_preference_id).edit_allowed := g_pref_values_ct(l_index).edit_allowed;
	    p_pref_table(l_preference_id).displayed := g_pref_values_ct(l_index).displayed;
	    p_pref_table(l_preference_id).rule_evaluation_order
					 := l_hierarchy_list(l_hier).rule_evaluation_order;
	    p_pref_table(l_preference_id).name := g_pref_values_ct(l_index).name;

	END IF;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		-- exception happens when there is no existing row with preference_code.
		-- ie first row of this preference_code

	    p_pref_table(l_preference_id).preference_code := g_pref_values_ct(l_index).code;--Performace Fix l_pref_trans(l_preference_id);
	    p_pref_table(l_preference_id).attribute1 := g_pref_values_ct(l_index).attribute1;
	    p_pref_table(l_preference_id).attribute2 := g_pref_values_ct(l_index).attribute2;
	    p_pref_table(l_preference_id).attribute3 := g_pref_values_ct(l_index).attribute3;
	    p_pref_table(l_preference_id).attribute4 := g_pref_values_ct(l_index).attribute4;
	    p_pref_table(l_preference_id).attribute5 := g_pref_values_ct(l_index).attribute5;
	    p_pref_table(l_preference_id).attribute6 := g_pref_values_ct(l_index).attribute6;
	    p_pref_table(l_preference_id).attribute7 := g_pref_values_ct(l_index).attribute7;
	    p_pref_table(l_preference_id).attribute8 := g_pref_values_ct(l_index).attribute8;
	    p_pref_table(l_preference_id).attribute9 := g_pref_values_ct(l_index).attribute9;
	    p_pref_table(l_preference_id).attribute10 := g_pref_values_ct(l_index).attribute10;
	    p_pref_table(l_preference_id).attribute11 := g_pref_values_ct(l_index).attribute11;
	    p_pref_table(l_preference_id).attribute12 := g_pref_values_ct(l_index).attribute12;
	    p_pref_table(l_preference_id).attribute13 := g_pref_values_ct(l_index).attribute13;
	    p_pref_table(l_preference_id).attribute14 := g_pref_values_ct(l_index).attribute14;
	    p_pref_table(l_preference_id).attribute15 := g_pref_values_ct(l_index).attribute15;
	    p_pref_table(l_preference_id).attribute16 := g_pref_values_ct(l_index).attribute16;
	    p_pref_table(l_preference_id).attribute17 := g_pref_values_ct(l_index).attribute17;
	    p_pref_table(l_preference_id).attribute18 := g_pref_values_ct(l_index).attribute18;
	    p_pref_table(l_preference_id).attribute19 := g_pref_values_ct(l_index).attribute19;
	    p_pref_table(l_preference_id).attribute20 := g_pref_values_ct(l_index).attribute20;
	    p_pref_table(l_preference_id).attribute21 := g_pref_values_ct(l_index).attribute21;
	    p_pref_table(l_preference_id).attribute22 := g_pref_values_ct(l_index).attribute22;
	    p_pref_table(l_preference_id).attribute23 := g_pref_values_ct(l_index).attribute23;
	    p_pref_table(l_preference_id).attribute24 := g_pref_values_ct(l_index).attribute24;
	    p_pref_table(l_preference_id).attribute25 := g_pref_values_ct(l_index).attribute25;
	    p_pref_table(l_preference_id).attribute26 := g_pref_values_ct(l_index).attribute26;
	    p_pref_table(l_preference_id).attribute27 := g_pref_values_ct(l_index).attribute27;
	    p_pref_table(l_preference_id).attribute28 := g_pref_values_ct(l_index).attribute28;
	    p_pref_table(l_preference_id).attribute29 := g_pref_values_ct(l_index).attribute29;
	    p_pref_table(l_preference_id).attribute30 := g_pref_values_ct(l_index).attribute30;

	    p_pref_table(l_preference_id).edit_allowed := g_pref_values_ct(l_index).edit_allowed;
	    p_pref_table(l_preference_id).displayed := g_pref_values_ct(l_index).displayed;
	    p_pref_table(l_preference_id).rule_evaluation_order
					     := l_hierarchy_list(l_hier).rule_evaluation_order;
	    p_pref_table(l_preference_id).name := g_pref_values_ct(l_index).name;
	  END;
    End loop;
  End if;

l_hier := l_hierarchy_list.next(l_hier);

--g_loop_count := g_loop_count + 1;

IF(g_loop_count > g_maxloop) THEN
      hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
      hr_utility.raise_error;
END IF;

END LOOP;

END resource_preferences;



---------
-- Procedure takes a string preference mask and parses it into a table preference mask
---------

PROCEDURE string_to_table_mask(p_string_mask IN VARCHAR2,
                               p_table_mask OUT NOCOPY t_requested_pref_list)
IS

l_pos NUMBER;
l_start NUMBER;
l_start_attr NUMBER;
l_end NUMBER;
l_req NUMBER;

BEGIN

l_start := 1;
l_pos := l_start;
l_req := 1;

g_loop_count := 0;

LOOP

  l_pos := instr(p_string_mask,',',l_start,1);

  IF l_pos = 0 THEN
    l_end := length(p_string_mask)+1;
  ELSE
    l_end := l_pos;
  END IF;

-- l_start and l_end now bound the description for a single preference code
-- such as 'TC_W_TCARD_DISPLAY_DAYS|1|2|'

  l_start_attr := instr(p_string_mask,g_input_separator,l_start,1);

  IF l_start_attr = 0 THEN
    l_start_attr := l_end;
  END IF;

  p_table_mask(l_req).code := substr(p_string_mask,l_start,l_start_attr-l_start);
  p_table_mask(l_req).attr_list := substr(p_string_mask,l_start_attr+1,l_end-l_start_attr);

  l_start := l_end + 1;

  l_req := l_req + 1;
  EXIT WHEN l_pos = 0;

--g_loop_count := g_loop_count + 1;

IF(g_loop_count > g_maxloop) THEN
      hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
      hr_utility.raise_error;
END IF;


END LOOP;

END string_to_table_mask;

---------
-- Function to prepare a list of preference values from a preference table and
-- a table preference mask
---------

FUNCTION string_from_mask_and_prefs(p_pref_table IN t_pref_table,
                                    p_table_mask IN t_requested_pref_list,
                                    p_output_separator IN varchar2)
RETURN VARCHAR2
IS
p_pref_value_list VARCHAR2(1000);
l_single_pref_str VARCHAR2(1000);
l_pref_table t_pref_table;
l_pref_start NUMBER;
l_first_attr NUMBER;
l_next_pipe NUMBER;
l_next_pref NUMBER;
l_attr NUMBER;
l_pref NUMBER;
l_req NUMBER;
l_found BOOLEAN;
p_val_to_append VARCHAR2(150);

BEGIN

l_req := p_table_mask.first;
p_pref_value_list := null;

g_loop_count := 0;
LOOP
  EXIT WHEN NOT p_table_mask.exists(l_req);
  l_pref := p_pref_table.first;
  g_loop_count := 0;
  l_found:=FALSE;

  LOOP
    EXIT WHEN NOT p_pref_table.exists(l_pref);

    IF( p_table_mask(l_req).code=p_pref_table(l_pref).preference_code ) THEN

   l_found:=TRUE;
-- go through requested attribute list

  l_first_attr := 1;
   g_loop_count := 0;
   LOOP
    EXIT WHEN instr(p_table_mask(l_req).attr_list,g_input_separator,l_first_attr,1)  = 0 ;
    l_next_pipe := instr(p_table_mask(l_req).attr_list,g_input_separator,l_first_attr,1);
    l_attr := substr(p_table_mask(l_req).attr_list,l_first_attr,l_next_pipe-l_first_attr);

    IF   (l_attr=1) THEN p_val_to_append := p_pref_table(l_pref).attribute1;
    ELSIF(l_attr=2) THEN p_val_to_append := p_pref_table(l_pref).attribute2;
    ELSIF(l_attr=3) THEN p_val_to_append := p_pref_table(l_pref).attribute3;
    ELSIF(l_attr=4) THEN p_val_to_append := p_pref_table(l_pref).attribute4;
    ELSIF(l_attr=5) THEN p_val_to_append := p_pref_table(l_pref).attribute5;
    ELSIF(l_attr=6) THEN p_val_to_append := p_pref_table(l_pref).attribute6;
    ELSIF(l_attr=7) THEN p_val_to_append := p_pref_table(l_pref).attribute7;
    ELSIF(l_attr=8) THEN p_val_to_append := p_pref_table(l_pref).attribute8;
    ELSIF(l_attr=9) THEN p_val_to_append := p_pref_table(l_pref).attribute9;
    ELSIF(l_attr=10) THEN p_val_to_append := p_pref_table(l_pref).attribute10;
    ELSIF(l_attr=11) THEN p_val_to_append := p_pref_table(l_pref).attribute11;
    ELSIF(l_attr=12) THEN p_val_to_append := p_pref_table(l_pref).attribute12;
    ELSIF(l_attr=13) THEN p_val_to_append := p_pref_table(l_pref).attribute13;
    ELSIF(l_attr=14) THEN p_val_to_append := p_pref_table(l_pref).attribute14;
    ELSIF(l_attr=15) THEN p_val_to_append := p_pref_table(l_pref).attribute15;
    ELSIF(l_attr=16) THEN p_val_to_append := p_pref_table(l_pref).attribute16;
    ELSIF(l_attr=17) THEN p_val_to_append := p_pref_table(l_pref).attribute17;
    ELSIF(l_attr=18) THEN p_val_to_append := p_pref_table(l_pref).attribute18;
    ELSIF(l_attr=19) THEN p_val_to_append := p_pref_table(l_pref).attribute19;
    ELSIF(l_attr=20) THEN p_val_to_append := p_pref_table(l_pref).attribute20;
    ELSIF(l_attr=21) THEN p_val_to_append := p_pref_table(l_pref).attribute21;
    ELSIF(l_attr=22) THEN p_val_to_append := p_pref_table(l_pref).attribute22;
    ELSIF(l_attr=23) THEN p_val_to_append := p_pref_table(l_pref).attribute23;
    ELSIF(l_attr=24) THEN p_val_to_append := p_pref_table(l_pref).attribute24;
    ELSIF(l_attr=25) THEN p_val_to_append := p_pref_table(l_pref).attribute25;
    ELSIF(l_attr=26) THEN p_val_to_append := p_pref_table(l_pref).attribute26;
    ELSIF(l_attr=27) THEN p_val_to_append := p_pref_table(l_pref).attribute27;
    ELSIF(l_attr=28) THEN p_val_to_append := p_pref_table(l_pref).attribute28;
    ELSIF(l_attr=29) THEN p_val_to_append := p_pref_table(l_pref).attribute29;
    ELSIF(l_attr=30) THEN p_val_to_append := p_pref_table(l_pref).attribute30;
    END IF;
-- Return 'null' when there is no value. This makes the string easier to parse
-- using standard Java class

    IF (p_val_to_append IS null) THEN
      p_val_to_append:='null';
    END IF;

    p_pref_value_list :=p_pref_value_list||p_val_to_append||p_output_separator;

   l_first_attr := l_next_pipe+1;

-- debug, to be removed
--  g_loop_count := g_loop_count + 1;

IF(g_loop_count > g_maxloop) THEN
      hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
      hr_utility.raise_error;
END IF;
-- debug, to be removed

   END LOOP;
    END IF;
    l_pref := p_pref_table.next(l_pref);

--  g_loop_count := g_loop_count + 1;

IF(g_loop_count > g_maxloop) THEN
      hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
      hr_utility.raise_error;
END IF;

  END LOOP;

IF(l_found = FALSE) then
-- Raise an error as the requested preference was not found for the user.
-- This should never happen as all supported preferences MUST occur in the
-- default preference tree (even if the value is left blank)
 IF( g_raise_fatal_errors = TRUE) THEN
    hr_utility.set_message(809, 'HXC_NO_VALS_FOR_PREF_CODE');
    hr_utility.raise_error;
  ELSE
    g_fatal_error_occurred := TRUE;
    g_fatal_error := 'HXC_NO_VALS_FOR_PREF_CODE';
    RETURN null;
  END IF;
END IF;

  l_req := p_table_mask.next(l_req);

--  g_loop_count := g_loop_count + 1;

IF(g_loop_count > g_maxloop) THEN
      hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
      hr_utility.raise_error;
END IF;

END LOOP;
RETURN substr(p_pref_value_list,1,length(p_pref_value_list)-1);
END;


---------
-- PROCEDURE to restrict and order a preference table according to a preference table
-- and preference mask
---------

PROCEDURE trim_order_prefs(p_pref_table in out nocopy t_pref_table,
                           p_table_mask in t_requested_pref_list)
is
l_pref_table t_pref_table;
l_mask NUMBER;
l_pref NUMBER;

BEGIN

-- loop through the table mask

l_mask := p_table_mask.first;

g_loop_count := 0;

LOOP
 EXIT WHEN NOT p_table_mask.exists(l_mask) ;

-- loop through pref table

  l_pref := p_pref_table.first;

  g_loop_count := 0;
  LOOP
 EXIT WHEN NOT p_pref_table.exists(l_pref);

  IF( p_table_mask(l_mask).code =  p_pref_table(l_pref).preference_code )THEN
   l_pref_table(l_pref) := p_pref_table(l_pref);
  END IF;

  l_pref := p_pref_table.next(l_pref);

-- debug, to be removed
--  g_loop_count := g_loop_count + 1;

IF(g_loop_count > g_maxloop) THEN
      hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
      hr_utility.raise_error;
END IF;
-- debug, to be removed

  END LOOP;

l_mask := p_table_mask.next(l_mask);

-- debug, to be removed
--  g_loop_count := g_loop_count + 1;

IF(g_loop_count > g_maxloop) THEN
      hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
      hr_utility.raise_error;
END IF;
-- debug, to be removed
END LOOP;
p_pref_table := l_pref_table;

END trim_order_prefs;


---------
-- FUNCTION useful where results need to be in string format
---------

FUNCTION resource_pref_sep(p_resource_id     IN NUMBER ,
                              p_pref_spec_list  IN VARCHAR2,
                              p_output_separator IN varchar2,
                              p_evaluation_date IN DATE DEFAULT sysdate)
         RETURN VARCHAR2 IS


l_pref_value_list VARCHAR2(1000) :='';
l_pref_table t_pref_table;

l_requested_list t_requested_pref_list;


BEGIN

-- 1. Find out which preferences are being requested
string_to_table_mask(p_pref_spec_list,l_requested_list);

-- 2. get the preference for the resource
resource_preferences(p_resource_id,l_pref_table, p_evaluation_date);

IF(g_fatal_error_occurred = FALSE) THEN
-- 3. Organise the string to RETURN
l_pref_value_list := string_from_mask_and_prefs(l_pref_table,l_requested_list,p_output_separator);
END IF;

RETURN l_pref_value_list;


END resource_pref_sep;

---------
-- FUNCTION useful where caller wants any fatal error to be reported but not raised
---------



FUNCTION resource_pref_errcode(p_resource_id IN NUMBER,
                               p_pref_spec_list IN VARCHAR2,
                               p_message IN OUT NOCOPY VARCHAR,
                               p_evaluation_date IN DATE DEFAULT sysdate) RETURN VARCHAR2
IS
l_pref_spec_list varchar2(2000);
BEGIN

-- set global variable that controls how fatal errors are handled
g_raise_fatal_errors := FALSE;
g_fatal_error_occurred := FALSE;
g_fatal_error :='';

-- call base method
l_pref_spec_list := resource_preferences(p_resource_id =>p_resource_id,
                    p_pref_spec_list => p_pref_spec_list,
                    p_evaluation_date =>p_evaluation_date);

-- copy any error to p_message, and reset fatal error vars
p_message := g_fatal_error;
g_fatal_error_occurred := FALSE;
g_fatal_error :='';

-- set global variable back
g_raise_fatal_errors := TRUE;

RETURN l_pref_spec_list;

END resource_pref_errcode;

---------
-- FUNCTION useful where results need to be in string format. As above but defaults output separator to '|'
---------
FUNCTION resource_preferences(p_resource_id     IN NUMBER ,
                              p_pref_spec_list  IN VARCHAR2,
                              p_evaluation_date IN DATE DEFAULT sysdate)
         RETURN VARCHAR2 IS

BEGIN

return resource_pref_sep(p_resource_id => p_resource_id ,
                            p_pref_spec_list => p_pref_spec_list,
                            p_output_separator => '|',
                            p_evaluation_date => p_evaluation_date);


END resource_preferences;




-------
-- PROCEDURE useful when a limited NUMBER of preferences are needed
-------

PROCEDURE resource_preferences(p_resource_id      IN NUMBER,
                               p_pref_code_list   IN VARCHAR2,
                               p_pref_table       IN OUT NOCOPY t_pref_table,
                               p_evaluation_date  IN DATE  DEFAULT sysdate,
                               p_resp_id	  IN NUMBER DEFAULT -99)
IS
l_table_mask t_requested_pref_list;
BEGIN

-- Note that this currently only filters and orders the full preference table for a
-- resource. There is currently no performance saving from using this procedure. Will be
-- updating this procedure to improve performance further for this case

-- 1. Get full set of prefs
--resource_preferences(p_resource_id, p_pref_table, p_evaluation_date);
--Changed By Mithun for Persistent Responsibility Enhancement
resource_preferences(p_resource_id, p_pref_table, p_evaluation_date,FND_GLOBAL.user_id, p_resp_id);

-- 2. Turn the string into a table mask.
string_to_table_mask(p_pref_code_list,l_table_mask);

-- 3. filter the results to return only those requested
trim_order_prefs(p_pref_table,l_table_mask);

END;


------
-- Function useful in case where only one attribute of a given preference is required
------

FUNCTION resource_preferences(p_resource_id        IN NUMBER,
                              p_pref_code          IN VARCHAR2,
                              p_attribute_n        IN NUMBER,
                              p_evaluation_date    IN DATE  DEFAULT sysdate,
                              p_resp_id IN number default -99)
RETURN VARCHAR2 IS
l_pref_table t_pref_table;
l_table_mask t_requested_pref_list;
l_first NUMBER;
BEGIN

-- Note that this currently only filters and orders the full preference table for a
-- resource. There is currently no performance saving from using this procedure. Will
-- be updating this procedure to improve performance further for this case

-- 1. Turn the string into a table mask
string_to_table_mask(p_pref_code,l_table_mask);

-- 2. Get full set of prefs
--Changed By Mithun for persistent responsibility enhancement
resource_preferences(p_resource_id,l_pref_table, p_evaluation_date,fnd_global.user_id,p_resp_id);

-- 3. Filter for the pref we want
trim_order_prefs(l_pref_table,l_table_mask);

l_first := l_pref_table.first;

IF(p_attribute_n = 1) THEN      RETURN l_pref_table(l_first).attribute1;
ELSIF(p_attribute_n = 2) THEN   RETURN l_pref_table(l_first).attribute2;
ELSIF(p_attribute_n = 3) THEN   RETURN l_pref_table(l_first).attribute3;
ELSIF(p_attribute_n = 4) THEN   RETURN l_pref_table(l_first).attribute4;
ELSIF(p_attribute_n = 5) THEN   RETURN l_pref_table(l_first).attribute5;
ELSIF(p_attribute_n = 6) THEN   RETURN l_pref_table(l_first).attribute6;
ELSIF(p_attribute_n = 7) THEN   RETURN l_pref_table(l_first).attribute7;
ELSIF(p_attribute_n = 8) THEN   RETURN l_pref_table(l_first).attribute8;
ELSIF(p_attribute_n = 9) THEN   RETURN l_pref_table(l_first).attribute9;
ELSIF(p_attribute_n = 10) THEN  RETURN l_pref_table(l_first).attribute10;
ELSIF(p_attribute_n = 11) THEN  RETURN l_pref_table(l_first).attribute11;
ELSIF(p_attribute_n = 12) THEN  RETURN l_pref_table(l_first).attribute12;
ELSIF(p_attribute_n = 13) THEN  RETURN l_pref_table(l_first).attribute13;
ELSIF(p_attribute_n = 14) THEN  RETURN l_pref_table(l_first).attribute14;
ELSIF(p_attribute_n = 15) THEN  RETURN l_pref_table(l_first).attribute15;
ELSIF(p_attribute_n = 16) THEN  RETURN l_pref_table(l_first).attribute16;
ELSIF(p_attribute_n = 17) THEN  RETURN l_pref_table(l_first).attribute17;
ELSIF(p_attribute_n = 18) THEN  RETURN l_pref_table(l_first).attribute18;
ELSIF(p_attribute_n = 19) THEN  RETURN l_pref_table(l_first).attribute19;
ELSIF(p_attribute_n = 20) THEN  RETURN l_pref_table(l_first).attribute20;
ELSIF(p_attribute_n = 21) THEN  RETURN l_pref_table(l_first).attribute21;
ELSIF(p_attribute_n = 22) THEN  RETURN l_pref_table(l_first).attribute22;
ELSIF(p_attribute_n = 23) THEN  RETURN l_pref_table(l_first).attribute23;
ELSIF(p_attribute_n = 24) THEN  RETURN l_pref_table(l_first).attribute24;
ELSIF(p_attribute_n = 25) THEN  RETURN l_pref_table(l_first).attribute25;
ELSIF(p_attribute_n = 26) THEN  RETURN l_pref_table(l_first).attribute26;
ELSIF(p_attribute_n = 27) THEN  RETURN l_pref_table(l_first).attribute27;
ELSIF(p_attribute_n = 28) THEN  RETURN l_pref_table(l_first).attribute28;
ELSIF(p_attribute_n = 29) THEN  RETURN l_pref_table(l_first).attribute29;
ELSIF(p_attribute_n = 30) THEN  RETURN l_pref_table(l_first).attribute30;
END IF;

END resource_preferences;
------
-- Function populates the global preference array which can then be read by
-- get_resource_preferences
------

PROCEDURE set_resource_preferences(p_resource_id IN NUMBER,
                                   p_evaluation_date IN DATE DEFAULT sysdate )
IS
BEGIN

g_pref_table.delete;
resource_preferences(p_resource_id     => p_resource_id,
                     p_pref_table      => g_pref_table,
                     p_evaluation_date => p_evaluation_date);

END set_resource_preferences;


------
-- Function populates the global preference array which can then be read by
-- get_resource_preferences
------

PROCEDURE set_resource_preferences(p_resource_id IN NUMBER,
                                   p_start_evaluation_date IN DATE,
                                   p_end_evaluation_date IN DATE  )
IS
BEGIN

g_pref_table.delete;
resource_preferences(p_resource_id     => p_resource_id,
                     p_pref_table      => g_pref_table,
                     p_start_evaluation_date => p_start_evaluation_date,
                     p_end_evaluation_date => p_start_evaluation_date);

END set_resource_preferences;

------
-- Function gets resource preferences from global tables
------

FUNCTION get_resource_preferences(p_resource_id IN NUMBER,
                                  p_pref_id IN NUMBER,
                                  p_attn IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN

   IF(p_attn = '1')  then return g_pref_table(p_pref_id).attribute1;
elsif(p_attn = '2')  then return g_pref_table(p_pref_id).attribute2;
elsif(p_attn = '3')  then return g_pref_table(p_pref_id).attribute3;
elsif(p_attn = '4')  then return g_pref_table(p_pref_id).attribute4;
elsif(p_attn = '5')  then return g_pref_table(p_pref_id).attribute5;
elsif(p_attn = '6')  then return g_pref_table(p_pref_id).attribute6;
elsif(p_attn = '7')  then return g_pref_table(p_pref_id).attribute7;
elsif(p_attn = '8')  then return g_pref_table(p_pref_id).attribute8;
elsif(p_attn = '9')  then return g_pref_table(p_pref_id).attribute9;
elsif(p_attn = '10') then return g_pref_table(p_pref_id).attribute10;
elsif(p_attn = '11') then return g_pref_table(p_pref_id).attribute11;
elsif(p_attn = '12') then return g_pref_table(p_pref_id).attribute12;
elsif(p_attn = '13') then return g_pref_table(p_pref_id).attribute13;
elsif(p_attn = '14') then return g_pref_table(p_pref_id).attribute14;
elsif(p_attn = '15') then return g_pref_table(p_pref_id).attribute15;
elsif(p_attn = '16') then return g_pref_table(p_pref_id).attribute16;
elsif(p_attn = '17') then return g_pref_table(p_pref_id).attribute17;
elsif(p_attn = '18') then return g_pref_table(p_pref_id).attribute18;
elsif(p_attn = '19') then return g_pref_table(p_pref_id).attribute19;
elsif(p_attn = '20') then return g_pref_table(p_pref_id).attribute20;
elsif(p_attn = '21') then return g_pref_table(p_pref_id).attribute21;
elsif(p_attn = '22') then return g_pref_table(p_pref_id).attribute22;
elsif(p_attn = '23') then return g_pref_table(p_pref_id).attribute23;
elsif(p_attn = '24') then return g_pref_table(p_pref_id).attribute24;
elsif(p_attn = '25') then return g_pref_table(p_pref_id).attribute25;
elsif(p_attn = '26') then return g_pref_table(p_pref_id).attribute26;
elsif(p_attn = '27') then return g_pref_table(p_pref_id).attribute27;
elsif(p_attn = '28') then return g_pref_table(p_pref_id).attribute28;
elsif(p_attn = '29') then return g_pref_table(p_pref_id).attribute29;
elsif(p_attn = '30') then return g_pref_table(p_pref_id).attribute30;
elsif(p_attn = 'E')  then return g_pref_table(p_pref_id).edit_allowed;
elsif(p_attn = 'D')  then return g_pref_table(p_pref_id).displayed;
END IF;

END get_resource_preferences;

----
-- Procedure to return date range prefrences - complex evaluation
----

PROCEDURE resource_preferences(p_resource_id  in NUMBER,
                               p_start_evaluation_date DATE,
                               p_end_evaluation_date DATE,
                               p_pref_table IN OUT NOCOPY t_pref_table,
                               p_no_prefs_outside_asg IN BOOLEAN DEFAULT FALSE,
                               p_resp_id IN number default -99,
                               p_resp_appl_id IN NUMBER DEFAULT fnd_global.resp_appl_id,
			       p_ignore_resp_id in boolean default false)
IS

l_req                   NUMBER;
l_personal_hierarchy    NUMBER;
l_hier                  NUMBER;
l_requested_list        t_requested_pref_list;
l_pref_trans            t_pref_trans;
l_hierarchy_list        t_hierarchy_list;

l_pref_table            t_pref_table; --Performance Fix
l_dated_prefs           t_dated_prefs;

l_pref_count            NUMBER;
l_pref_ref              NUMBER;
l_dated_pref_count      NUMBER;
l_index                 NUMBER;
l_finish                NUMBER;
l_start_evaluation_date DATE;
l_end_evaluation_date   DATE;
l_hier_count            NUMBER;
l_tmp_date              DATE;

-- Bug 3297639
l_pref_index number;
l_preference_id number;
l_last_updated_date date;
l_use_cache boolean := FALSE;

CURSOR c_get_last_updated_date(p_pref_hierarchy_id IN number) IS
	Select last_update_date
	From hxc_pref_hierarchies
	Where pref_hierarchy_id = p_pref_hierarchy_id;

--Performance Fix
  TYPE t_pref_encountered IS TABLE OF
    number
  INDEX BY BINARY_INTEGER;
l_pref_encountered  t_pref_encountered;

-- CURSORs to find the hierarchies a resource is eligible for ...
-- To support new criteria add new CURSORs or add to existing CURSOR.

-- Modified cursor to support CWK.

-- Bug 7484448
-- Added USE_NL in the below query for optimum perf.
CURSOR c_eligible_hierarchies_basic(p_resource_id IN NUMBER,
                                    p_start_evaluation_date IN DATE,
                                    p_end_evaluation_date IN DATE) IS

  SELECT /*+ USE_NL(PA HRR) */
         hrr.pref_hierarchy_id,
         hrr.rule_evaluation_order,
         hrr.start_date,
         hrr.end_date,
         decode(hrr.eligibility_criteria_type,
                       'ALL_PEOPLE', hr_general.start_of_time
                                   , pa.effective_start_date)   elig_start_date,
         decode(hrr.eligibility_criteria_type,
                       'ALL_PEOPLE', hr_general.end_of_time
                                   , pa.effective_END_date)      elig_end_date
    FROM hxc_resource_rules hrr,
         per_all_assignments_f pa
   WHERE pa.person_id = p_resource_id
     AND nvl(hrr.business_group_id,pa.business_group_id) = pa.business_group_id
     AND pa.primary_flag = 'Y'
and pa.assignment_type in ('E','C')
   AND p_start_evaluation_date  <= pa.effective_END_date
   and pa.effective_start_date  <= p_end_evaluation_date
   and p_start_evaluation_date  <= hrr.end_date
   and hrr.start_date           <= p_end_evaluation_date
   and hrr.start_date <= pa.effective_end_date
   and hrr.end_date >=pa.effective_start_date
    AND ((   to_char(pa.assignment_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'ASSIGNMENT')
      OR (      to_char(pa.payroll_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'PAYROLL')
      OR (       to_char(pa.person_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'PERSON')
      OR (     to_char(pa.location_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'LOCATION')
      OR (     pa.EMPLOYEE_CATEGORY = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'EMP_CATEGORY')
      OR (     pa.EMPLOYMENT_CATEGORY = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'ASGN_CATEGORY')
      OR (     to_char(pa.organization_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'ORGANIZATION')
      OR ((HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,instr(hrr.eligibility_criteria_id,'-',1,1)+1)) in
           (SELECT pose.organization_id_parent
                  FROM
                 per_org_structure_elements pose
		    start with organization_id_child = pa.organization_id
                    and  pose.org_structure_version_id=
                               HXC_PREFERENCE_EVALUATION.return_version_id(HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,1,instr(hrr.eligibility_criteria_id,'-',1,1)-1)),
                                                                           hrr.eligibility_criteria_type)
                    connect by prior organization_id_parent=organization_id_child
                    and  pose.org_structure_version_id=
                               HXC_PREFERENCE_EVALUATION.return_version_id(HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,1,instr(hrr.eligibility_criteria_id,'-',1,1)-1)),
                                                                           hrr.eligibility_criteria_type)
                    union
                    select organization_id
                   from   hr_all_organization_units
                   where  organization_id =  pa.organization_id))
                 AND  hrr.eligibility_criteria_type = 'ROLLUP' )
      OR (
                  hrr.eligibility_criteria_type = 'ALL_PEOPLE'));


-- for rehired employees with preference breaks
-- Bug 7484448
-- Added USE_NL in the below query for optimum perf.
CURSOR c_rehire_elig_hier_basic(p_resource_id IN NUMBER,
                                    p_start_evaluation_date IN DATE,
                                    p_end_evaluation_date IN DATE) IS
  SELECT /*+ USE_NL(PA HRR) */
         hrr.pref_hierarchy_id,
         hrr.rule_evaluation_order,
         hrr.start_date,
         hrr.end_date,
         pa.effective_start_date elig_start_date,
         pa.effective_END_date elig_end_date
    FROM hxc_resource_rules hrr,
         per_all_assignments_f pa
   WHERE pa.person_id = p_resource_id
     AND nvl(hrr.business_group_id,pa.business_group_id) = pa.business_group_id
     AND pa.primary_flag = 'Y'
and pa.assignment_type in ('E','C')
   AND p_start_evaluation_date  <= pa.effective_END_date
   and pa.effective_start_date  <= p_end_evaluation_date
   and p_start_evaluation_date  <= hrr.end_date
   and hrr.start_date           <= p_end_evaluation_date
   and hrr.start_date <= pa.effective_end_date
   and hrr.end_date >=pa.effective_start_date
    AND ((   to_char(pa.assignment_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'ASSIGNMENT')
      OR (      to_char(pa.payroll_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'PAYROLL')
      OR (       to_char(pa.person_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'PERSON')
      OR (     to_char(pa.location_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'LOCATION')
      OR (     pa.EMPLOYEE_CATEGORY = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'EMP_CATEGORY')
      OR (     pa.EMPLOYMENT_CATEGORY = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'ASGN_CATEGORY')
      OR (     to_char(pa.organization_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = 'ORGANIZATION')
      OR ((HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,instr(hrr.eligibility_criteria_id,'-',1,1)+1)) in
           (SELECT pose.organization_id_parent
                  FROM
                 per_org_structure_elements pose
		    start with organization_id_child = pa.organization_id
                    and  pose.org_structure_version_id=
                               HXC_PREFERENCE_EVALUATION.return_version_id(HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,1,instr(hrr.eligibility_criteria_id,'-',1,1)-1)),
                                                                           hrr.eligibility_criteria_type)
                    connect by prior organization_id_parent=organization_id_child
                    and  pose.org_structure_version_id=
                               HXC_PREFERENCE_EVALUATION.return_version_id(HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,1,instr(hrr.eligibility_criteria_id,'-',1,1)-1)),
                                                                           hrr.eligibility_criteria_type)
                    union
                    select organization_id
                   from   hr_all_organization_units
                   where  organization_id =  pa.organization_id))
                 AND  hrr.eligibility_criteria_type = 'ROLLUP' )
      OR (
                  hrr.eligibility_criteria_type = 'ALL_PEOPLE'));

-- Modified cursor to support CWK.
CURSOR c_eligible_hierarchies_flex(p_resource_id IN NUMBER,
                                   p_start_evaluation_date IN DATE,
                                   p_end_evaluation_date IN DATE) IS

  SELECT hrr.pref_hierarchy_id,
         hrr.rule_evaluation_order,
         hrr.start_date, hrr.end_date,
         pa.effective_start_date elig_start_date,
         pa.effective_END_date elig_end_date
    FROM hxc_resource_rules hrr,
         per_all_assignments_f pa
   WHERE pa.person_id = p_resource_id
     AND nvl(hrr.business_group_id,pa.business_group_id) = pa.business_group_id
     AND pa.primary_flag = 'Y'
and pa.assignment_type in ('E','C')
     AND p_start_evaluation_date <= pa.effective_END_date
     and pa.effective_start_date  <= p_end_evaluation_date
     and p_start_evaluation_date <= hrr.end_date
     and hrr.start_date <= p_end_evaluation_date
     and hrr.start_date <= pa.effective_end_date
     and hrr.end_date >=pa.effective_start_date
AND ( (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 3 ),
      'SCL', DECODE ( pa.soft_coding_keyflex_id, NULL, -1,
      hxc_resource_rules_utils.chk_flex_valid ( 'SCL', pa.soft_coding_keyflex_id,
      SUBSTR( hrr.eligibility_criteria_type, 5 ), hrr.eligibility_criteria_id )), -1 ) = 1 )
OR
      (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 6 ),
      'PEOPLE', DECODE ( pa.people_group_id, NULL, -1,
      hxc_resource_rules_utils.chk_flex_valid ( 'PEOPLE', pa.people_group_id,
      SUBSTR( hrr.eligibility_criteria_type, 8 ), hrr.eligibility_criteria_id )), -1 ) = 1 )
OR
      (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 5 ),
      'GRADE', DECODE ( pa.grade_id, NULL, -1,
      hxc_resource_rules_utils.chk_flex_valid ( 'GRADE', pa.grade_id,
      SUBSTR( hrr.eligibility_criteria_type, 7 ), hrr.eligibility_criteria_id )), -1 ) = 1 )
OR

      (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 3 ),
      'JOB', hrr.eligibility_criteria_id, -1 ) = to_char(pa.job_id)) -- Issue 4

OR

      (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 8 ),
      'POSITION', hrr.eligibility_criteria_id, -1 ) = to_char(pa.position_id)) -- Issue 4
);

-- Cursor to check whether the resource has personalized preferences.
-- Note that this CURSOR could be removed in order to possible boost performance.
-- Need to alter c_eligible_hierarchies CURSOR to include LOGIN type. We would THEN need
-- to use a DECODE in the SELECT to give LOGIN type rules higest priority.
-- Decode expression would need to include the EDIT_ALLOWED flag.
-- But, keep it simple for now.



CURSOR c_personal_hierarchy(p_resource_id IN NUMBER) IS

SELECT hrr.pref_hierarchy_id , hrr.rule_evaluation_order, hrr.start_date, hrr.end_date
FROM   hxc_resource_rules hrr,
       fnd_user fu
WHERE  hrr.resource_type='PERSON'
AND    hrr.eligibility_criteria_type = 'LOGIN'
AND    hrr.eligibility_criteria_id = to_char(fu.user_id) -- Issue 4
AND    fu.employee_id = p_resource_id;

-- Cursor to pick up any responsibility based prefs

CURSOR c_resp_hierarchies(p_responsibility_id IN NUMBER,
		          p_resp_appl_id       IN NUMBER,
                          p_start_evaluation_date IN DATE,
                          p_end_evaluation_date IN DATE) IS
SELECT hrr.pref_hierarchy_id , hrr.rule_evaluation_order, hrr.start_date, hrr.end_date,
       fr.start_date elig_start_date,
       fr.end_date elig_end_date
  FROM hxc_resource_rules hrr,
       fnd_responsibility fr
 WHERE hrr.resource_type='PERSON'
   and p_start_evaluation_date <= hrr.end_date
   and hrr.start_date <= p_end_evaluation_date
   AND hrr.eligibility_criteria_type IN ( 'RESPONSIBILITY',
                                          'PERST_RESPONSIBILITY' )
   AND hrr.eligibility_criteria_id = to_char(p_responsibility_id) -- Issue 4
   and fr.responsibility_id = p_responsibility_id
   and fr.application_id= p_resp_appl_id
   and fr.responsibility_id = hrr.eligibility_criteria_id;



     CURSOR c_perst_resp_hierarchies(p_responsibility_id     NUMBER,
                                     p_start_evaluation_date DATE,
                                     p_end_evaluation_date   DATE)
         IS
     SELECT hrr.pref_hierarchy_id ,
            hrr.rule_evaluation_order,
            hrr.start_date,
            hrr.end_date,
            p_start_evaluation_date   elig_start_date,
            p_end_evaluation_date     elig_end_date
       FROM hxc_resource_rules hrr
      WHERE hrr.resource_type='PERSON'
        AND p_start_evaluation_date     BETWEEN hrr.start_date
                                            AND hrr.end_date
        AND p_end_evaluation_date       BETWEEN hrr.start_date
                                            AND hrr.end_date
        AND hrr.eligibility_criteria_type = 'PERST_RESPONSIBILITY'
        AND hrr.eligibility_criteria_id   = to_char(p_responsibility_id) ;





CURSOR get_employee_id(p_user_id IN Number) Is
  Select employee_id from fnd_user
  Where user_id = p_user_id;


CURSOR c_person_type_hierarchies(p_resource_id IN NUMBER,
	                          p_start_evaluation_date IN DATE,
		                  p_end_evaluation_date IN DATE) IS
SELECT	hrr.pref_hierarchy_id , hrr.rule_evaluation_order, hrr.start_date, hrr.end_date,
	ptu.effective_start_date elig_start_date,
	ptu.effective_end_date elig_end_date
FROM	hxc_resource_rules hrr,
	per_person_types typ,
	per_person_type_usages_f ptu
WHERE  hrr.resource_type='PERSON'
and    p_start_evaluation_date <= hrr.end_date
and    hrr.start_date <= p_end_evaluation_date
AND    hrr.eligibility_criteria_type = 'PERSON_TYPE'
AND    hrr.eligibility_criteria_id = to_char(ptu.person_type_id) -- Issue 4
AND    ptu.person_id = p_resource_id
AND    typ.system_person_type IN ('EMP','EX_EMP','EMP_APL','EX_EMP_APL','CWK','EX_CWK')
AND    typ.person_type_id = ptu.person_type_id
AND    p_start_evaluation_date <= ptu.effective_end_date
AND    ptu.effective_start_date <= p_end_evaluation_date;
--------------------------------------------------------------------------

-- Cursor to RETURN the preference nodes in a hierarchy. Note that this is based on a
-- hierchical query.
-- This can be removed if necessary by denormalization onto the hxc_pref_hierarchies base table
-- About 30% of preference evaluatuation time is spent in this query. Denormalization seems
-- to be appropriate at some point.

CURSOR c_pref_nodes(p_hierarchy_id IN NUMBER)
IS
 SELECT pref_hierarchy_id
  ,pref_definition_id preference_id
  ,attribute1
  ,attribute2
  ,attribute3
  ,attribute4
  ,attribute5
  ,attribute6
  ,attribute7
  ,attribute8
  ,attribute9
  ,attribute10
  ,attribute11
  ,attribute12
  ,attribute13
  ,attribute14
  ,attribute15
  ,attribute16
  ,attribute17
  ,attribute18
  ,attribute19
  ,attribute20
  ,attribute21
  ,attribute22
  ,attribute23
  ,attribute24
  ,attribute25
  ,attribute26
  ,attribute27
  ,attribute28
  ,attribute29
  ,attribute30
  ,edit_allowed
  ,displayed
  ,name
  ,top_level_parent_id --Performance Fix
  ,code
  FROM hxc_pref_hierarchies
  WHERE top_level_parent_id = p_hierarchy_id;
  --pref_definition_id is not null
  --START WITH pref_hierarchy_id = p_hierarchy_id
  --CONNECT BY prior pref_hierarchy_id = parent_pref_hierarchy_id;

CURSOR c_pref_codes
IS
SELECT
 pref_definition_id, code
FROM hxc_pref_definitions;

--VARIABLES ADDED by Mithun for Perst Resp enhancement
l_find_resp_required	BOOLEAN DEFAULT FALSE;
l_resp_id	NUMBER;
l_resp_appl_id  NUMBER;
l_employee_id NUMBER;
--l_tc_employee_id  NUMBER;

l_resptab       resplisttab;


BEGIN

l_resp_id	:= 	p_resp_id;


g_debug := hr_utility.debug_enabled;

   IF g_debug
   THEN
       hr_utility.trace('Evaluating pref for start and stop dates');
       hr_utility.trace('p_resource_id '||p_resource_id);
       hr_utility.trace('p_start_evaluation_date '||p_start_evaluation_date);
       hr_utility.trace('p_end_evaluation_date '||p_end_evaluation_date);
   END IF;



Open get_employee_id(fnd_global.user_id);
Fetch get_employee_id into l_employee_id;
Close get_employee_id;

 IF ( p_resp_id = -99 ) AND (l_employee_id <> p_resource_id)
 THEN
        -- By default we need to consider persistent responsibility also,
        -- so set the flag to TRUE.
 	l_find_resp_required := TRUE;

 ELSE
 	-- The call is by passing -101 explicitly, meaning we are not considering
 	-- persistent responsibility. Get the session responsibility and keep it.
 	-- Set the flag to FALSE.
 	l_find_resp_required := FALSE;

 END IF;

 l_resp_id := fnd_global.resp_id;

-- make sure pref table is empty - otherwise this will interfere with the evaluation
p_pref_table.delete;

l_hier_count:=1;

l_start_evaluation_date:=trunc(p_start_evaluation_date);
l_end_evaluation_date  :=trunc(p_end_evaluation_date);

l_dated_pref_count:=0;
l_pref_count:=0;




-- populate table that will allow us to find a pref_code given an pref_definition_id
-- Performance Fix (Loop Commented).
/*FOR pref_rec IN c_pref_codes LOOP
  l_pref_trans(pref_rec.pref_definition_id) := pref_rec.code;

-- set a dummy default preference for each preference code (start and ends at evaluation dates)
-- These will be overriden by default preferences

  l_dated_prefs(l_dated_pref_count).code                   := pref_rec.code;
  l_dated_prefs(l_dated_pref_count).start_date             := l_start_evaluation_date;
  l_dated_prefs(l_dated_pref_count).end_date               := l_end_evaluation_date;
  l_dated_prefs(l_dated_pref_count).rule_evaluation_order  := -1;
  l_dated_prefs(l_dated_pref_count).pref_ref               := 1;
  l_dated_pref_count                                       := l_dated_pref_count+1;

END LOOP;*/

-- Now find the hierarchies which the person is eligible for ...

-- basic eligibility, must be at least one

if p_no_prefs_outside_asg = TRUE then

	FOR hier_rec IN c_rehire_elig_hier_basic(p_resource_id,
						 l_start_evaluation_date,
						 l_end_evaluation_date) LOOP
	-- Performance Fix
	if(hier_rec.rule_evaluation_order = 1) then
	   l_hierarchy_list(0).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
	   l_hierarchy_list(0).rule_evaluation_order    := hier_rec.rule_evaluation_order;
	   l_hierarchy_list(0).start_date               := hier_rec.start_date;
	   l_hierarchy_list(0).end_date                 := hier_rec.end_date;
	   l_hierarchy_list(0).elig_start_date          := hier_rec.elig_start_date;
	   l_hierarchy_list(0).elig_end_date            := hier_rec.elig_end_date;

	else
	   l_hierarchy_list(l_hier_count).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
	   l_hierarchy_list(l_hier_count).rule_evaluation_order    := hier_rec.rule_evaluation_order;
	   l_hierarchy_list(l_hier_count).start_date               := hier_rec.start_date;
	   l_hierarchy_list(l_hier_count).end_date                 := hier_rec.end_date;
	   l_hierarchy_list(l_hier_count).elig_start_date          := hier_rec.elig_start_date;
	   l_hierarchy_list(l_hier_count).elig_end_date            := hier_rec.elig_end_date;
	   l_hier_count                                            := l_hier_count + 1;
	end if;

	END LOOP;

ELSE

	FOR hier_rec IN c_eligible_hierarchies_basic(p_resource_id,
                                             l_start_evaluation_date,
                                             l_end_evaluation_date) LOOP
	-- Performance Fix
	if(hier_rec.rule_evaluation_order = 1) then
	   l_hierarchy_list(0).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
	   l_hierarchy_list(0).rule_evaluation_order    := hier_rec.rule_evaluation_order;
	   l_hierarchy_list(0).start_date               := hier_rec.start_date;
	   l_hierarchy_list(0).end_date                 := hier_rec.end_date;
	   l_hierarchy_list(0).elig_start_date          := hier_rec.elig_start_date;
	   l_hierarchy_list(0).elig_end_date            := hier_rec.elig_end_date;

	else
	   l_hierarchy_list(l_hier_count).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
	   l_hierarchy_list(l_hier_count).rule_evaluation_order    := hier_rec.rule_evaluation_order;
	   l_hierarchy_list(l_hier_count).start_date               := hier_rec.start_date;
	   l_hierarchy_list(l_hier_count).end_date                 := hier_rec.end_date;
	   l_hierarchy_list(l_hier_count).elig_start_date          := hier_rec.elig_start_date;
	   l_hierarchy_list(l_hier_count).elig_end_date            := hier_rec.elig_end_date;
	   l_hier_count                                            := l_hier_count + 1;
	end if;

	END LOOP;
END IF;

-- Issue 6
if(l_hierarchy_list(0).pref_hierarchy_id is null)
then
 IF( g_raise_fatal_errors = TRUE) THEN
    hr_utility.set_message(809, 'HXC_NO_HIER_FOR_DATE');
    hr_utility.raise_error;
  ELSE
    g_fatal_error := 'HXC_NO_HIER_FOR_DATE';
    g_fatal_error_occurred := TRUE;
    RETURN;
  END IF;
end if;

-- more complex eligibility, zero or more

BEGIN
FOR hier_rec in c_eligible_hierarchies_flex(p_resource_id,
                                            l_start_evaluation_date,
                                            l_end_evaluation_date) LOOP
   l_hierarchy_list(l_hier_count).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
   l_hierarchy_list(l_hier_count).rule_evaluation_order    := hier_rec.rule_evaluation_order;
   l_hierarchy_list(l_hier_count).start_date               := hier_rec.start_date;
   l_hierarchy_list(l_hier_count).end_date                 := hier_rec.end_date;
   l_hierarchy_list(l_hier_count).elig_start_date          := hier_rec.elig_start_date;
   l_hierarchy_list(l_hier_count).elig_end_date            := hier_rec.elig_end_date;
   l_hier_count                                            := l_hier_count + 1;
END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
END;



-------------------------4215885-- ----------------------
BEGIN
FOR hier_rec in c_person_type_hierarchies(p_resource_id,
                                          l_start_evaluation_date,
                                          l_end_evaluation_date) LOOP
   l_hierarchy_list(l_hier_count).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
   l_hierarchy_list(l_hier_count).rule_evaluation_order    := hier_rec.rule_evaluation_order;
   l_hierarchy_list(l_hier_count).start_date               := hier_rec.start_date;
   l_hierarchy_list(l_hier_count).end_date                 := hier_rec.end_date;
   l_hierarchy_list(l_hier_count).elig_start_date          := hier_rec.elig_start_date;
   l_hierarchy_list(l_hier_count).elig_end_date            := hier_rec.elig_end_date;
   l_hier_count                                            := l_hier_count + 1;
END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
END;

-------------------------------------------------------------------
--IF(fnd_global.resp_id <> -1) THEN

--Changes done by Mithun for Persistent Responsibility Enhancement

If (l_resp_id <> -1  AND ( not p_ignore_resp_id)) Then

--This is Where we are evaluating for session responsibility.
--We check for l_employee_id = p_resource_id to make sure that employee himself has logged in
	IF  l_employee_id = p_resource_id   THEN

		BEGIN
			FOR hier_rec in c_resp_hierarchies(l_resp_id, p_resp_appl_id, l_start_evaluation_date, l_end_evaluation_date) LOOP

			      l_hierarchy_list(l_hier_count).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
				 l_hierarchy_list(l_hier_count).rule_evaluation_order    := hier_rec.rule_evaluation_order;
				 l_hierarchy_list(l_hier_count).start_date               := hier_rec.start_date;
				 l_hierarchy_list(l_hier_count).end_date                 := hier_rec.end_date;
				 l_hierarchy_list(l_hier_count).elig_start_date          := hier_rec.elig_start_date;
				l_hierarchy_list(l_hier_count).elig_end_date            := hier_rec.elig_end_date;

			      l_hier_count                                         := l_hier_count+1;
			END LOOP;
		EXCEPTION
		    WHEN NO_DATA_FOUND THEN null;
		END;
	END IF;

--Checking If we have to obtain the resp_id value stored in  the timecard
-- If we have to then get the responsibilities and calculate the hierarchies
-- associated.
--
	IF l_find_resp_required
	THEN
		-- We need Persistent responsibility, so get the valid responsibilities
		-- within the given date range.

		get_tc_resp(p_resource_id,
		            l_start_evaluation_date,
		            l_end_evaluation_date,
		            l_resptab );


		 -- If you got any timecards in the given date range, do the
		 -- following.

		 IF l_resptab.COUNT > 0
		 THEN
		     -- Do the following for all timecards.
		     FOR i IN l_resptab.FIRST..l_resptab.LAST
		     LOOP

		        -- The following condition means that this timecard
		        -- was updated by another person, not the employee
		        -- himself, meaning we dont have to consider persistent
		        -- responsibilities at all.

		        IF l_resptab(i).resp_id <> -1
		        THEN

			   BEGIN
				-- Run the cursor for all the responsibilities and
				-- timecards and keep recording the hierarchy rules.

				FOR hier_rec IN c_perst_resp_hierarchies(l_resptab(i).resp_id,
				                                         TRUNC(l_resptab(i).start_date),
				                                         TRUNC(l_resptab(i).stop_date))
				LOOP
					 l_hierarchy_list(l_hier_count).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
					 l_hierarchy_list(l_hier_count).rule_evaluation_order    := hier_rec.rule_evaluation_order;
					 l_hierarchy_list(l_hier_count).start_date               := hier_rec.start_date;
					 l_hierarchy_list(l_hier_count).end_date                 := hier_rec.end_date;
					 l_hierarchy_list(l_hier_count).elig_start_date          := hier_rec.elig_start_date;
					 l_hierarchy_list(l_hier_count).elig_end_date            := hier_rec.elig_end_date;

					l_hier_count                := l_hier_count+1;
				END LOOP;
			     EXCEPTION
			       WHEN NO_DATA_FOUND THEN null;
			   END ; --  BEGIN
		        END IF;	 --  IF l_resptab(i).resp_id <> -1
		     END LOOP;   --  FOR i IN l_resptab.FIRST..l_resptab.LAST

		 END IF;         --  IF l_resptab.COUNT > 0

	END IF;                  --  IF l_find_resp_required

End If;
-- personalisation, only one hierarchy possible. Note we give a start and end date
-- spanning all time. Personalizations are only applied over ranges of time in which the
-- granted preference has the edit_allowed flag. Note the the personalisation MUST
-- be the last hierarchy to be considered. Only when all the other hierarchies have
-- been considered can which ranges of time have the edit allowed flag

BEGIN
FOR hier_rec IN c_personal_hierarchy(p_resource_id) LOOP
   l_hierarchy_list(l_hier_count).pref_hierarchy_id        := hier_rec.pref_hierarchy_id;
   l_hierarchy_list(l_hier_count).rule_evaluation_order    := hier_rec.rule_evaluation_order;
   l_hierarchy_list(l_hier_count).start_date               := hr_general.start_of_time;
   l_hierarchy_list(l_hier_count).end_date                 := hr_general.end_of_time;
   l_hierarchy_list(l_hier_count).elig_start_date          := hr_general.start_of_time;
   l_hierarchy_list(l_hier_count).elig_end_date            := hr_general.end_of_time;
   l_hier_count                                            := l_hier_count+1;
END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
END;

-- sanity check
--Issue 6
/*if(l_hierarchy_list.count=0)
then
 IF( g_raise_fatal_errors = TRUE) THEN
    hr_utility.set_message(809, 'HXC_NO_HIER_FOR_DATE');
    hr_utility.raise_error;
  ELSE
    g_fatal_error := 'HXC_NO_HIER_FOR_DATE';
    g_fatal_error_occurred := TRUE;
    RETURN;
  END IF;
end if;*/

-- Performance Fix.
l_dated_pref_count :=0;

-- Bug 3297639
-- if data not in cache then fetch from db and populate the cache.
If ( not g_pref_hier_ct.exists(l_hierarchy_list(0).pref_hierarchy_id) ) then

    g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).caching_time := sysdate;
    g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Start_Index := -1;
    g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Stop_Index := -1;


    l_pref_index := 1;
    If (g_pref_values_ct.count > 0) then
	l_pref_index := g_pref_values_ct.last + 1;
    end if;

    g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Start_Index := l_pref_index;


    FOR pref_node in c_pref_nodes(l_hierarchy_list(0).pref_hierarchy_id)
    LOOP
    g_pref_values_ct(l_pref_index).pref_hierarchy_id := pref_node.pref_hierarchy_id;
    g_pref_values_ct(l_pref_index).pref_definition_id := pref_node.preference_id;
    g_pref_values_ct(l_pref_index).attribute1:= pref_node.attribute1;
    g_pref_values_ct(l_pref_index).attribute2:= pref_node.attribute2;
    g_pref_values_ct(l_pref_index).attribute3:= pref_node.attribute3;
    g_pref_values_ct(l_pref_index).attribute4:= pref_node.attribute4;
    g_pref_values_ct(l_pref_index).attribute5:= pref_node.attribute5;
    g_pref_values_ct(l_pref_index).attribute6:= pref_node.attribute6;
    g_pref_values_ct(l_pref_index).attribute7:= pref_node.attribute7;
    g_pref_values_ct(l_pref_index).attribute8:= pref_node.attribute8;
    g_pref_values_ct(l_pref_index).attribute9:= pref_node.attribute9;
    g_pref_values_ct(l_pref_index).attribute10:= pref_node.attribute10;
    g_pref_values_ct(l_pref_index).attribute11:= pref_node.attribute11;
    g_pref_values_ct(l_pref_index).attribute12:= pref_node.attribute12;
    g_pref_values_ct(l_pref_index).attribute13:= pref_node.attribute13;
    g_pref_values_ct(l_pref_index).attribute14:= pref_node.attribute14;
    g_pref_values_ct(l_pref_index).attribute15:= pref_node.attribute15;
    g_pref_values_ct(l_pref_index).attribute16:= pref_node.attribute16;
    g_pref_values_ct(l_pref_index).attribute17:= pref_node.attribute17;
    g_pref_values_ct(l_pref_index).attribute18:= pref_node.attribute18;
    g_pref_values_ct(l_pref_index).attribute19:= pref_node.attribute19;
    g_pref_values_ct(l_pref_index).attribute20:= pref_node.attribute20;
    g_pref_values_ct(l_pref_index).attribute21:= pref_node.attribute21;
    g_pref_values_ct(l_pref_index).attribute22:= pref_node.attribute22;
    g_pref_values_ct(l_pref_index).attribute23:= pref_node.attribute23;
    g_pref_values_ct(l_pref_index).attribute24:= pref_node.attribute24;
    g_pref_values_ct(l_pref_index).attribute25:= pref_node.attribute25;
    g_pref_values_ct(l_pref_index).attribute26:= pref_node.attribute26;
    g_pref_values_ct(l_pref_index).attribute27:= pref_node.attribute27;
    g_pref_values_ct(l_pref_index).attribute28:= pref_node.attribute28;
    g_pref_values_ct(l_pref_index).attribute29:= pref_node.attribute29;
    g_pref_values_ct(l_pref_index).attribute30:= pref_node.attribute30;
    g_pref_values_ct(l_pref_index).edit_allowed:= pref_node.edit_allowed;
    g_pref_values_ct(l_pref_index).displayed:= pref_node.displayed;
    g_pref_values_ct(l_pref_index).name:= pref_node.name;
    g_pref_values_ct(l_pref_index).top_level_parent_id:= pref_node.top_level_parent_id;
    g_pref_values_ct(l_pref_index).code:= pref_node.code;
    l_pref_index := g_pref_values_ct.last + 1;

    End Loop;


    g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Stop_Index := l_pref_index - 1;

    -- check for valid start and stop index. Incase the only leaf node was deleted or no leaf nodes exists then reset start and stop index accordingly
    if (g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Stop_Index < g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Start_Index) then
        g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Start_Index := 0;
	g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Stop_Index := 0;
    end if;

end if;

-- Not checking if cache info for this pref id is outdated since its seed data.
    For l_loop_index in g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Start_Index..g_pref_hier_ct(l_hierarchy_list(0).pref_hierarchy_id).Stop_index
    Loop
      l_dated_prefs(l_dated_pref_count).code		       := g_pref_values_ct(l_loop_index).code;
      l_dated_prefs(l_dated_pref_count).start_date             := l_start_evaluation_date;
      l_dated_prefs(l_dated_pref_count).end_date               := l_end_evaluation_date;
      l_dated_prefs(l_dated_pref_count).rule_evaluation_order  := -1;
      l_dated_prefs(l_dated_pref_count).pref_ref               := 1;
      l_dated_pref_count                                       := l_dated_pref_count+1;
    end loop;

/*    FOR pref_node in c_pref_nodes(l_hierarchy_list(0).pref_hierarchy_id) LOOP

      l_dated_prefs(l_dated_pref_count).code := pref_node.code;
      l_dated_prefs(l_dated_pref_count).start_date             := l_start_evaluation_date;
      l_dated_prefs(l_dated_pref_count).end_date               := l_end_evaluation_date;
      l_dated_prefs(l_dated_pref_count).rule_evaluation_order  := -1;
      l_dated_prefs(l_dated_pref_count).pref_ref               := 1;
      l_dated_pref_count                                       := l_dated_pref_count+1;

    end loop;
*/

l_hier := l_hierarchy_list.first;

-- loop over the hierarchies we have found

l_hier := l_hierarchy_list.first;

  g_loop_count := 0;

  LOOP --1
    EXIT WHEN NOT l_hierarchy_list.exists(l_hier);

  --reset for each Pref Id
  l_use_cache := FALSE;

  -- Check if the required data is already cached.
  If ( g_pref_hier_ct.exists(l_hierarchy_list(l_hier).pref_hierarchy_id) ) then

	Open c_get_last_updated_date(l_hierarchy_list(l_hier).pref_hierarchy_id);
	Fetch c_get_last_updated_date into l_last_updated_date;
	Close c_get_last_updated_date;

	-- checking if the cache data is outdated.
	if ( g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).caching_time >= l_last_updated_date) then
		l_use_cache := TRUE;
	else
	        l_use_cache := FALSE;
		-- Delete the Pref Values for this, since it has to be refreshed anyway.
		g_pref_values_ct.delete(g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index,g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index); -- table.delete(m,n)
	end if;
  end if;

  -- If l_use_cache = FALSE, then populate/refresh cache data by db fetch.
  If (not l_use_cache) then

    -- initialise main table.
    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).caching_time := sysdate;
    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index := -1;
    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index := -1;

    -- Initialize Start_Index for the Pref Values
    If (g_pref_values_ct.count > 0) then
	l_pref_index := g_pref_values_ct.last + 1;
    else
	l_pref_index := 1;
    End If;

    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index := l_pref_index;

    -- populate preference values into cache
    FOR pref_node in c_pref_nodes(l_hierarchy_list(l_hier).pref_hierarchy_id)
    LOOP

    g_pref_values_ct(l_pref_index).pref_hierarchy_id := pref_node.pref_hierarchy_id;
    g_pref_values_ct(l_pref_index).pref_definition_id := pref_node.preference_id;
    g_pref_values_ct(l_pref_index).attribute1:= pref_node.attribute1;
    g_pref_values_ct(l_pref_index).attribute2:= pref_node.attribute2;
    g_pref_values_ct(l_pref_index).attribute3:= pref_node.attribute3;
    g_pref_values_ct(l_pref_index).attribute4:= pref_node.attribute4;
    g_pref_values_ct(l_pref_index).attribute5:= pref_node.attribute5;
    g_pref_values_ct(l_pref_index).attribute6:= pref_node.attribute6;
    g_pref_values_ct(l_pref_index).attribute7:= pref_node.attribute7;
    g_pref_values_ct(l_pref_index).attribute8:= pref_node.attribute8;
    g_pref_values_ct(l_pref_index).attribute9:= pref_node.attribute9;
    g_pref_values_ct(l_pref_index).attribute10:= pref_node.attribute10;
    g_pref_values_ct(l_pref_index).attribute11:= pref_node.attribute11;
    g_pref_values_ct(l_pref_index).attribute12:= pref_node.attribute12;
    g_pref_values_ct(l_pref_index).attribute13:= pref_node.attribute13;
    g_pref_values_ct(l_pref_index).attribute14:= pref_node.attribute14;
    g_pref_values_ct(l_pref_index).attribute15:= pref_node.attribute15;
    g_pref_values_ct(l_pref_index).attribute16:= pref_node.attribute16;
    g_pref_values_ct(l_pref_index).attribute17:= pref_node.attribute17;
    g_pref_values_ct(l_pref_index).attribute18:= pref_node.attribute18;
    g_pref_values_ct(l_pref_index).attribute19:= pref_node.attribute19;
    g_pref_values_ct(l_pref_index).attribute20:= pref_node.attribute20;
    g_pref_values_ct(l_pref_index).attribute21:= pref_node.attribute21;
    g_pref_values_ct(l_pref_index).attribute22:= pref_node.attribute22;
    g_pref_values_ct(l_pref_index).attribute23:= pref_node.attribute23;
    g_pref_values_ct(l_pref_index).attribute24:= pref_node.attribute24;
    g_pref_values_ct(l_pref_index).attribute25:= pref_node.attribute25;
    g_pref_values_ct(l_pref_index).attribute26:= pref_node.attribute26;
    g_pref_values_ct(l_pref_index).attribute27:= pref_node.attribute27;
    g_pref_values_ct(l_pref_index).attribute28:= pref_node.attribute28;
    g_pref_values_ct(l_pref_index).attribute29:= pref_node.attribute29;
    g_pref_values_ct(l_pref_index).attribute30:= pref_node.attribute30;

    g_pref_values_ct(l_pref_index).edit_allowed:= pref_node.edit_allowed;
    g_pref_values_ct(l_pref_index).displayed:= pref_node.displayed;
    g_pref_values_ct(l_pref_index).name:= pref_node.name;
    g_pref_values_ct(l_pref_index).top_level_parent_id:= pref_node.top_level_parent_id;
    g_pref_values_ct(l_pref_index).code:= pref_node.code;

    l_pref_index := g_pref_values_ct.last + 1;
    End Loop;

    g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index := l_pref_index - 1;

    -- check for valid start and stop index. Incase the only leaf node was deleted or no leaf nodes exists then reset start and stop index accordingly
    if (g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index < g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index) then
        g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index := 0;
	g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index := 0;
    end if;

    l_use_cache := TRUE; -- now data is in cache
  End If;

  -- Now all required data is in cache.
    If (g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_Index <> 0 ) then     --(case where parent node has no children)
    For l_loop_index in g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Start_Index..g_pref_hier_ct(l_hierarchy_list(l_hier).pref_hierarchy_id).Stop_index Loop -- 2

    -- record node details in list
    -- Note. We shouldnt actually make these assignments before we know we are goiing to
    -- need the values. Need some reordering of code to achieve this. Also note that should
    -- try to make the assignments in bulk (i.e. record to record) for performance
    -- AND readability

    l_pref_count := l_pref_count+1;
    l_pref_table(l_pref_count).preference_code := g_pref_values_ct(l_loop_index).code;--Performance Fix l_pref_trans(pref_node.preference_id);
    l_pref_table(l_pref_count).attribute1 := g_pref_values_ct(l_loop_index).attribute1;
    l_pref_table(l_pref_count).attribute2 := g_pref_values_ct(l_loop_index).attribute2;
    l_pref_table(l_pref_count).attribute3 := g_pref_values_ct(l_loop_index).attribute3;
    l_pref_table(l_pref_count).attribute4 := g_pref_values_ct(l_loop_index).attribute4;
    l_pref_table(l_pref_count).attribute5 := g_pref_values_ct(l_loop_index).attribute5;
    l_pref_table(l_pref_count).attribute6 := g_pref_values_ct(l_loop_index).attribute6;
    l_pref_table(l_pref_count).attribute7 := g_pref_values_ct(l_loop_index).attribute7;
    l_pref_table(l_pref_count).attribute8 := g_pref_values_ct(l_loop_index).attribute8;
    l_pref_table(l_pref_count).attribute9 := g_pref_values_ct(l_loop_index).attribute9;
    l_pref_table(l_pref_count).attribute10 := g_pref_values_ct(l_loop_index).attribute10;
    l_pref_table(l_pref_count).attribute11 := g_pref_values_ct(l_loop_index).attribute11;
    l_pref_table(l_pref_count).attribute12 := g_pref_values_ct(l_loop_index).attribute12;
    l_pref_table(l_pref_count).attribute13 := g_pref_values_ct(l_loop_index).attribute13;
    l_pref_table(l_pref_count).attribute14 := g_pref_values_ct(l_loop_index).attribute14;
    l_pref_table(l_pref_count).attribute15 := g_pref_values_ct(l_loop_index).attribute15;
    l_pref_table(l_pref_count).attribute16 := g_pref_values_ct(l_loop_index).attribute16;
    l_pref_table(l_pref_count).attribute17 := g_pref_values_ct(l_loop_index).attribute17;
    l_pref_table(l_pref_count).attribute18 := g_pref_values_ct(l_loop_index).attribute18;
    l_pref_table(l_pref_count).attribute19 := g_pref_values_ct(l_loop_index).attribute19;
    l_pref_table(l_pref_count).attribute20 := g_pref_values_ct(l_loop_index).attribute20;
    l_pref_table(l_pref_count).attribute21 := g_pref_values_ct(l_loop_index).attribute21;
    l_pref_table(l_pref_count).attribute22 := g_pref_values_ct(l_loop_index).attribute22;
    l_pref_table(l_pref_count).attribute23 := g_pref_values_ct(l_loop_index).attribute23;
    l_pref_table(l_pref_count).attribute24 := g_pref_values_ct(l_loop_index).attribute24;
    l_pref_table(l_pref_count).attribute25 := g_pref_values_ct(l_loop_index).attribute25;
    l_pref_table(l_pref_count).attribute26 := g_pref_values_ct(l_loop_index).attribute26;
    l_pref_table(l_pref_count).attribute27 := g_pref_values_ct(l_loop_index).attribute27;
    l_pref_table(l_pref_count).attribute28 := g_pref_values_ct(l_loop_index).attribute28;
    l_pref_table(l_pref_count).attribute29 := g_pref_values_ct(l_loop_index).attribute29;
    l_pref_table(l_pref_count).attribute30 := g_pref_values_ct(l_loop_index).attribute30;
    l_pref_table(l_pref_count).edit_allowed := g_pref_values_ct(l_loop_index).edit_allowed;
    l_pref_table(l_pref_count).displayed := g_pref_values_ct(l_loop_index).displayed;
    l_pref_table(l_pref_count).rule_evaluation_order
                             := l_hierarchy_list(l_hier).rule_evaluation_order;

    -- the start date and end dates take into account eligibilty dates. Want the overlap between
-- eligbility range and rule range

    if(l_hierarchy_list(l_hier).start_date>=l_hierarchy_list(l_hier).elig_start_date) then
      l_pref_table(l_pref_count).start_date := l_hierarchy_list(l_hier).start_date;
    else
      l_pref_table(l_pref_count).start_date := l_hierarchy_list(l_hier).elig_start_date;
    end if;

    if(l_hierarchy_list(l_hier).end_date>=l_hierarchy_list(l_hier).elig_end_date) then
      l_pref_table(l_pref_count).end_date := l_hierarchy_list(l_hier).elig_end_date;
    else
      l_pref_table(l_pref_count).end_date := l_hierarchy_list(l_hier).end_date;
    end if;

-- further restrict by start / end evaluation_dates
    if(l_pref_table(l_pref_count).start_date<l_start_evaluation_date) then
      l_pref_table(l_pref_count).start_date := l_start_evaluation_date;
    end if;

    if(l_pref_table(l_pref_count).end_date>l_end_evaluation_date) then
      l_pref_table(l_pref_count).end_date := l_end_evaluation_date;
    end if;

    l_pref_table(l_pref_count).name := g_pref_values_ct(l_loop_index).name;

-- now work out what to do with this row by looping over the l_dated_prefs structure.
-- Note we only want to compare against nodes of the same pref code. Shouldnt have to
-- loop through entire l_dated_prefs table to do this. Should structure the data so that
-- it can be accessed faster.

     -- Performance Fix.
/*     if(not l_pref_encountered.exists(pref_node.preference_id)) THEN
     -- set a dummy default preference for each preference code (start and ends at evaluation dates)
     -- These will be overridden by default preferences
       l_dated_prefs(l_dated_pref_count).start_date             := l_hierarchy_list(0).start_date;
       l_dated_prefs(l_dated_pref_count).end_date               := l_hierarchy_list(0).end_date;
       l_dated_prefs(l_dated_pref_count).rule_evaluation_order  := -1;
       l_dated_prefs(l_dated_pref_count).pref_ref               := 1;
       l_dated_pref_count                                       := l_dated_pref_count+1;
     -- mark this preference as having being defaulted (initialized).
       l_pref_encountered(pref_node.preference_id) := '1';
     end if;*/

    l_index:=l_dated_prefs.first;
    l_finish:=l_dated_prefs.last;

    LOOP --3

       -- for all dated pref rows with the same code as the new pref and that the precidence
       -- of the new pref is higher
       -- (also take into account personalization - which has a rule_evaluation_order of 0
       -- but overrides everything where the base pref has the edit allowed flag

       if(     l_dated_prefs(l_index).code = l_pref_table(l_pref_count).preference_code
           AND (
                  (
                     (l_dated_prefs(l_index).rule_evaluation_order <=
                             l_pref_table(l_pref_count).rule_evaluation_order)
                      AND l_dated_prefs(l_index).rule_evaluation_order <>0
                  )
                  OR
                  (
                     l_pref_table(l_pref_count).rule_evaluation_order = 0
                    AND l_dated_prefs(l_index).edit_allowed = 'Y'
                  )
               )
          ) THEN

       -- check that new / old pref overlap

       if(l_dated_prefs(l_index).start_date<=l_pref_table(l_pref_count).end_date and
         l_pref_table(l_pref_count).start_date<=l_dated_prefs(l_index).end_date) then

         -- overlap of rows: Four possible cases - one special case

         if(  l_dated_prefs(l_index).start_date =  l_pref_table(l_pref_count).start_date
          and l_dated_prefs(l_index).end_date   =  l_pref_table(l_pref_count).end_date  )  then

           l_dated_prefs(l_index).pref_ref := l_pref_count;
           l_dated_prefs(l_index).rule_evaluation_order
                                 := l_pref_table(l_pref_count).rule_evaluation_order;
           l_dated_prefs(l_index).edit_allowed := l_pref_table(l_pref_count).edit_allowed;

      elsif(  l_dated_prefs(l_index).start_date >= l_pref_table(l_pref_count).start_date
          and l_dated_prefs(l_index).end_date   <= l_pref_table(l_pref_count).end_date  )  then

      -- case 1: New row spans /equivalent to old row.
      --         Change row attribution but keep dates
      --         Number of rows does not change
      --         |++++++++|
      --             +
      --         |-------|
      --             =
      --         |+++++++|

           l_dated_prefs(l_index).pref_ref := l_pref_count;
           l_dated_prefs(l_index).rule_evaluation_order
                                    := l_pref_table(l_pref_count).rule_evaluation_order;
           l_dated_prefs(l_index).edit_allowed := l_pref_table(l_pref_count).edit_allowed;


      elsif(  l_dated_prefs(l_index).start_date >= l_pref_table(l_pref_count).start_date
          and l_dated_prefs(l_index).end_date   >= l_pref_table(l_pref_count).end_date)  then

      -- case 2: New row paritally overlaps old row (spans old row start_date)
      --         Create row with new row attribution between old row start date and new row
      --         stop date
      --         Change start date of old row to end date of new row
      --         Number of rows increased by 1
      --      |+++++|
      --             +
      --         |-------|
      --             =
      --         |++|----|

   l_dated_prefs(l_index).start_date := l_pref_table(l_pref_count).end_date+1;
   l_dated_pref_count:=l_dated_pref_count+1;
   l_dated_prefs(l_dated_pref_count).start_date := l_pref_table(l_pref_count).start_date;
   l_dated_prefs(l_dated_pref_count).end_date := l_pref_table(l_pref_count).end_date;
   l_dated_prefs(l_dated_pref_count).rule_evaluation_order
                     := l_pref_table(l_pref_count).rule_evaluation_order;
   l_dated_prefs(l_dated_pref_count).edit_allowed := l_pref_table(l_pref_count).edit_allowed;
   l_dated_prefs(l_dated_pref_count).code := l_pref_table(l_pref_count).preference_code;
   l_dated_prefs(l_dated_pref_count).pref_ref := l_pref_count;

       elsif(   l_dated_prefs(l_index).start_date <= l_pref_table(l_pref_count).start_date
              and l_dated_prefs(l_index).end_date <= l_pref_table(l_pref_count).end_date)  then

      -- case 3: New row paritally overlaps old row (spans old row stop_date)
      --         Create row with new row attribution between old row start date and new
      --         row stop date
      --         Change end of old row to start date of new row
      --         Number of rows increased by 1
      --              |+++++|
      --             +
      --         |-------|
      --             =
      --         |----|++|
   l_tmp_date:=l_dated_prefs(l_index).end_date;
   l_dated_prefs(l_index).end_date := l_pref_table(l_pref_count).start_date-1;
-- -1 because new row has precedence
   l_dated_pref_count:=l_dated_pref_count+1;
   l_dated_prefs(l_dated_pref_count).start_date := l_pref_table(l_pref_count).start_date;
   l_dated_prefs(l_dated_pref_count).end_date :=  l_tmp_date;
   l_dated_prefs(l_dated_pref_count).rule_evaluation_order
                        := l_pref_table(l_pref_count).rule_evaluation_order;
   l_dated_prefs(l_dated_pref_count).edit_allowed := l_pref_table(l_pref_count).edit_allowed;
   l_dated_prefs(l_dated_pref_count).code := l_pref_table(l_pref_count).preference_code;
   l_dated_prefs(l_dated_pref_count).pref_ref := l_pref_count;

        elsif( l_dated_prefs(l_index).start_date <= l_pref_table(l_pref_count).start_date
             and l_dated_prefs(l_index).end_date >= l_pref_table(l_pref_count).end_date)  then

      -- case 4: New row spanned / equivalent to old row
      --         Create 2 new rows.
      --         Change end date of old row to be start date of new row
      --         create row with start date of new row and end date of new row with new
      --         row attribution
      --         create new row with start date of end date of new row and end date of old
      --         row with attribution of old row
      --           |+++|
      --             +
      --         |-------|
      --             =
      --         |-|+++|-|
   l_tmp_date:=l_dated_prefs(l_index).start_date;
   l_dated_prefs(l_index).start_date := l_pref_table(l_pref_count).end_date+1;
   l_dated_pref_count:=l_dated_pref_count+1;
   l_dated_prefs(l_dated_pref_count).start_date := l_pref_table(l_pref_count).start_date;
   l_dated_prefs(l_dated_pref_count).end_date := l_pref_table(l_pref_count).end_date;
   l_dated_prefs(l_dated_pref_count).rule_evaluation_order
                        := l_pref_table(l_pref_count).rule_evaluation_order;
   l_dated_prefs(l_dated_pref_count).edit_allowed := l_pref_table(l_pref_count).edit_allowed;
   l_dated_prefs(l_dated_pref_count).code := l_pref_table(l_pref_count).preference_code;
   l_dated_prefs(l_dated_pref_count).pref_ref := l_pref_count;
   l_dated_pref_count:=l_dated_pref_count+1;
   l_dated_prefs(l_dated_pref_count).start_date := l_tmp_date;
   l_dated_prefs(l_dated_pref_count).end_date := l_pref_table(l_pref_count).start_date-1;
   l_dated_prefs(l_dated_pref_count).rule_evaluation_order
                               :=l_dated_prefs(l_index).rule_evaluation_order;
   l_dated_prefs(l_dated_pref_count).edit_allowed :=l_dated_prefs(l_index).edit_allowed;
   l_dated_prefs(l_dated_pref_count).code := l_pref_table(l_pref_count).preference_code;
   l_dated_prefs(l_dated_pref_count).pref_ref := l_dated_prefs(l_index).pref_ref;
          end if;

        end if;
      end if;

      exit when (l_index = l_finish);

      l_index := l_dated_prefs.next(l_index);

--      IF(g_loop_count > g_maxloop) THEN
--        hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
--        hr_utility.raise_error;
--      END IF;

--      g_loop_count := g_loop_count + 1;

    END LOOP; --3 update of existing dated prefrences

  END LOOP; --2 node loop;
 End if;

  l_hier := l_hierarchy_list.next(l_hier);

--  g_loop_count := g_loop_count + 1;

  IF(g_loop_count > g_maxloop) THEN
      hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
      hr_utility.raise_error;
  END IF;

END LOOP; --1 hierarchy loop;

-- now build out results table based on calculations
-- create an entry for each pref - also assign dates


l_index:=l_dated_prefs.first;
l_pref_count:=0;


LOOP
  EXIT when not l_dated_prefs.exists(l_index);

  IF (p_no_prefs_outside_asg = TRUE AND l_dated_prefs(l_index).rule_evaluation_order <> -1)
	OR p_no_prefs_outside_asg = FALSE
  THEN

  l_pref_ref := l_dated_prefs(l_index).pref_ref;

  p_pref_table(l_pref_count).preference_code        := l_dated_prefs(l_index).code;
  p_pref_table(l_pref_count).start_date             := l_dated_prefs(l_index).start_date;
  p_pref_table(l_pref_count).end_date               := l_dated_prefs(l_index).end_date;
  p_pref_table(l_pref_count).rule_evaluation_order
                 := l_dated_prefs(l_index).rule_evaluation_order;
  p_pref_table(l_pref_count).attribute1
                 := l_pref_table(l_pref_ref).attribute1;
  p_pref_table(l_pref_count).attribute2 := l_pref_table(l_pref_ref).attribute2;
  p_pref_table(l_pref_count).attribute3 := l_pref_table(l_pref_ref).attribute3;
  p_pref_table(l_pref_count).attribute4 := l_pref_table(l_pref_ref).attribute4;
  p_pref_table(l_pref_count).attribute5 := l_pref_table(l_pref_ref).attribute5;
  p_pref_table(l_pref_count).attribute6 := l_pref_table(l_pref_ref).attribute6;
  p_pref_table(l_pref_count).attribute7 := l_pref_table(l_pref_ref).attribute7;
  p_pref_table(l_pref_count).attribute8 := l_pref_table(l_pref_ref).attribute8;
  p_pref_table(l_pref_count).attribute9 := l_pref_table(l_pref_ref).attribute9;
  p_pref_table(l_pref_count).attribute10 := l_pref_table(l_pref_ref).attribute10;
  p_pref_table(l_pref_count).attribute11 := l_pref_table(l_pref_ref).attribute11;
  p_pref_table(l_pref_count).attribute12 := l_pref_table(l_pref_ref).attribute12;
  p_pref_table(l_pref_count).attribute13 := l_pref_table(l_pref_ref).attribute13;
  p_pref_table(l_pref_count).attribute14 := l_pref_table(l_pref_ref).attribute14;
  p_pref_table(l_pref_count).attribute15 := l_pref_table(l_pref_ref).attribute15;
  p_pref_table(l_pref_count).attribute16 := l_pref_table(l_pref_ref).attribute16;
  p_pref_table(l_pref_count).attribute17 := l_pref_table(l_pref_ref).attribute17;
  p_pref_table(l_pref_count).attribute18 := l_pref_table(l_pref_ref).attribute18;
  p_pref_table(l_pref_count).attribute19 := l_pref_table(l_pref_ref).attribute19;
  p_pref_table(l_pref_count).attribute20 := l_pref_table(l_pref_ref).attribute20;
  p_pref_table(l_pref_count).attribute21 := l_pref_table(l_pref_ref).attribute21;
  p_pref_table(l_pref_count).attribute22 := l_pref_table(l_pref_ref).attribute22;
  p_pref_table(l_pref_count).attribute23 := l_pref_table(l_pref_ref).attribute23;
  p_pref_table(l_pref_count).attribute24 := l_pref_table(l_pref_ref).attribute24;
  p_pref_table(l_pref_count).attribute25 := l_pref_table(l_pref_ref).attribute25;
  p_pref_table(l_pref_count).attribute26 := l_pref_table(l_pref_ref).attribute26;
  p_pref_table(l_pref_count).attribute27 := l_pref_table(l_pref_ref).attribute27;
  p_pref_table(l_pref_count).attribute28 := l_pref_table(l_pref_ref).attribute28;
  p_pref_table(l_pref_count).attribute29 := l_pref_table(l_pref_ref).attribute29;
  p_pref_table(l_pref_count).attribute30 := l_pref_table(l_pref_ref).attribute30;
  p_pref_table(l_pref_count).edit_allowed := l_pref_table(l_pref_ref).edit_allowed;
  p_pref_table(l_pref_count).displayed := l_pref_table(l_pref_ref).displayed;

  END IF;

l_index:=l_dated_prefs.next(l_index);

     IF(g_loop_count > g_maxloop) THEN
        hr_utility.set_message(809, 'HXC_LPS_GT_MAX');
        hr_utility.raise_error;
      END IF;

--      g_loop_count := g_loop_count + 1;

l_pref_count:=l_pref_count+1;

END LOOP;

END resource_preferences;


----
-- Supporting function to allow inquiries as to whether specific values have been used
-- in preference hierarchies. Useful for data integrity checking.
----

FUNCTION  num_hierarchy_occurances(p_preference_code IN VARCHAR2,
                                   p_attributen      IN NUMBER,
                                   p_value           IN VARCHAR2) RETURN NUMBER
IS

-- note this cursor contains a decode in the WHERE clause. Could cause performance issue.
-- Hovever the SQL is very light and this is a function that will be called during application
-- setup and is therefore not performance critical

l_count NUMBER;

CURSOR get_num_hierarchy_occurances(p_preference_code VARCHAR2,
                                    p_attributen NUMBER,
                                    p_value VARCHAR2)
IS
SELECT count(*)
FROM   hxc_pref_hierarchies hph,
       hxc_pref_definitions hpd
WHERE  hph.pref_definition_id = hpd.pref_definition_id
AND    hpd.code = p_preference_code
AND    decode (p_attributen, 1, hph.attribute1,  2, hph.attribute2,  3, hph.attribute3,
                             4, hph.attribute4,  5, hph.attribute5,  6, hph.attribute6,
                             7, hph.attribute7,  8, hph.attribute8,  9, hph.attribute9,
                            10, hph.attribute10,11, hph.attribute11,12, hph.attribute12,
                            13, hph.attribute13,14, hph.attribute14,15, hph.attribute15,
                            16, hph.attribute16,17, hph.attribute17,18, hph.attribute18,
                            19, hph.attribute19,20, hph.attribute20,21, hph.attribute21,
                            22, hph.attribute22,23, hph.attribute23,24, hph.attribute24,
                            25, hph.attribute25,26, hph.attribute26,27, hph.attribute27,
                            28, hph.attribute28,29, hph.attribute29,30, hph.attribute30) = p_value;

BEGIN

OPEN get_num_hierarchy_occurances(p_preference_code,
                                  p_attributen,
                                  p_value);

FETCH get_num_hierarchy_occurances INTO l_count;

RETURN l_count;

END num_hierarchy_occurances;


PROCEDURE resource_preferences(p_resource_id  in NUMBER,
			       p_preference_code IN VARCHAR2,
                               p_start_evaluation_date DATE,
                               p_end_evaluation_date DATE,
                               p_sorted_pref_table IN OUT NOCOPY  t_pref_table,
			       p_clear_cache BOOLEAN DEFAULT FALSE,
                               p_no_prefs_outside_asg IN BOOLEAN DEFAULT FALSE ) IS

l_prefs t_pref_table;

l_prefs_filter t_pref_table; -- filtered table
l_prefs_sorted t_pref_table; -- filtered in date order table

l_ind BINARY_INTEGER;
l_sort_ind BINARY_INTEGER := 1;

l_not_sorted BOOLEAN := TRUE;

l_temp_pref_rec t_pref_table_row;
l_temp_ind BINARY_INTEGER;

BEGIN

IF ( g_sort_pref_table.COUNT <> 0 )
THEN

	IF (     p_clear_cache
             OR (   g_sort_cache(1).resource_id <> p_resource_id )
             OR ( ( g_sort_cache(1).start_date <> p_start_evaluation_date ) OR
                  ( g_sort_cache(1).end_date   <> p_end_evaluation_date   ) ) )
	THEN

		g_sort_pref_table.DELETE;

		hxc_preference_evaluation.resource_preferences(p_resource_id => p_resource_id,
                               p_start_evaluation_date => p_start_evaluation_date,
                               p_end_evaluation_date => p_end_evaluation_date,
                               p_pref_table => g_sort_pref_table,
                               p_no_prefs_outside_asg => p_no_prefs_outside_asg );

		g_sort_cache(1).resource_id := p_resource_id;
		g_sort_cache(1).start_date := p_start_evaluation_date;
		g_sort_cache(1).end_date   := p_end_evaluation_date;

	END IF;

ELSE

	hxc_preference_evaluation.resource_preferences(p_resource_id => p_resource_id,
                              p_start_evaluation_date => p_start_evaluation_date,
                              p_end_evaluation_date => p_end_evaluation_date,
                              p_pref_table => g_sort_pref_table,
                              p_no_prefs_outside_asg => p_no_prefs_outside_asg );

	g_sort_cache(1).resource_id := p_resource_id;
	g_sort_cache(1).start_date := p_start_evaluation_date;
	g_sort_cache(1).end_date   := p_end_evaluation_date;


END IF;


l_ind := g_sort_pref_table.FIRST;

-- filter out the desired preference

WHILE l_ind IS NOT NULL
LOOP

	IF ( g_sort_pref_table(l_ind).preference_code = p_preference_code )
	THEN
		l_temp_ind := to_char(g_sort_pref_table(l_ind).start_date,'J');

		IF l_prefs_filter.exists(l_temp_ind) AND
		   l_prefs_filter(l_temp_ind).end_date >= g_sort_pref_table(l_ind).end_date THEN

		   	NULL;
		ELSE
  		   l_prefs_filter(l_temp_ind) := g_sort_pref_table(l_ind);
		END IF;

		END IF;

	l_ind := g_sort_pref_table.NEXT(l_ind);

END LOOP;

-- now copy sorted table into table with binary index incremented by 1

l_ind := l_prefs_filter.FIRST;

WHILE l_ind IS NOT NULL
LOOP

	l_prefs_sorted(l_sort_ind) := l_prefs_filter(l_ind);

	l_ind := l_prefs_filter.NEXT(l_ind);

	l_sort_ind := l_sort_ind + 1;

END LOOP;

l_prefs_filter.DELETE;

p_sorted_pref_table := l_prefs_sorted;

end resource_preferences;

PROCEDURE resource_preferences(p_resource_id  in NUMBER,
			       p_preference_code IN VARCHAR2,
                               p_start_evaluation_date DATE,
                               p_end_evaluation_date DATE,
                               p_sorted_pref_table IN OUT NOCOPY  t_pref_table,
			       p_clear_cache BOOLEAN DEFAULT FALSE,
			       p_master_pref_table t_pref_table ) IS

l_tmp_pref_table t_pref_table;

l_ind BINARY_INTEGER := 1;

BEGIN

	g_sort_pref_table.DELETE;

	g_sort_pref_table := p_master_pref_table;

	g_sort_cache(1).resource_id := p_resource_id;
	g_sort_cache(1).start_date := p_start_evaluation_date;
	g_sort_cache(1).end_date   := p_end_evaluation_date;

	resource_preferences (
		       p_resource_id           => p_resource_id,
		       p_preference_code       => p_preference_code,
                       p_start_evaluation_date => p_start_evaluation_date,
                       p_end_evaluation_date   => p_end_evaluation_date,
                       p_sorted_pref_table     => p_sorted_pref_table,
		       p_clear_cache           => FALSE );

	-- GPM 115.27 start
	-- the preference table passed here was for all dates
	-- filter out the unwanted dates

	FOR x in 1 .. p_sorted_pref_table.LAST
	LOOP
		-- Bug 6123330
		IF ( to_date(to_char(p_sorted_pref_table(x).end_date,'DD-MM-YYYY'),'DD-MM-YYYY')   >= to_date(to_char(p_start_evaluation_date,'DD-MM-YYYY'),'DD-MM-YYYY') AND
                     to_date(to_char(p_sorted_pref_table(x).start_date,'DD-MM-YYYY'),'DD-MM-YYYY') <= to_date(to_char(p_end_evaluation_date,'DD-MM-YYYY'),'DD-MM-YYYY') )
		THEN

			l_tmp_pref_table(l_ind) := p_sorted_pref_table(x);

			l_ind := l_ind + 1;

		END IF;

	END LOOP;

	p_sorted_pref_table := l_tmp_pref_table;

	l_tmp_pref_table.DELETE;

	-- GPM 115.27 end

END resource_preferences;

-- this clears the pref table cache when preference evaluation is finished
-- to allow memory saving.

PROCEDURE clear_sort_pref_table_cache IS

BEGIN

	g_sort_pref_table.DELETE;

END clear_sort_pref_table_cache;

   FUNCTION migration_mode
       RETURN BOOLEAN
    IS
       l_proc    VARCHAR2 (72);
    BEGIN
       g_debug := hr_utility.debug_enabled;

       if g_debug then
        l_proc := g_package|| 'migration_mode';
       	hr_utility.set_location (   'Entering:'
       	                         || l_proc, 10);
       end if;

       IF (g_migration_mode)
       THEN
          if g_debug then
          	hr_utility.set_location ('   returning g_migration_mode = TRUE', 20);
          end if;
       ELSE
          if g_debug then
          	hr_utility.set_location ('   returning g_migration_mode = FALSE', 30);
          end if;
       END IF;

       if g_debug then
       	hr_utility.set_location (   'Leaving:'
       	                         || l_proc, 100);
       end if;
       RETURN g_migration_mode;
    END migration_mode;
    PROCEDURE set_migration_mode (p_migration_mode IN BOOLEAN)
    IS
       l_proc    VARCHAR2 (72);
    BEGIN
       g_debug := hr_utility.debug_enabled;

       if g_debug then
       	l_proc := g_package||'set_migration_mode';
       	hr_utility.set_location (   'Entering:'|| l_proc, 10);
       end if;

       IF (p_migration_mode)
       THEN
          if g_debug then
          	hr_utility.set_location ('   setting g_migration_mode to TRUE', 20);
          end if;
       ELSE
          if g_debug then
          	hr_utility.set_location ('   setting g_migration_mode to FALSE', 30);
          end if;
       END IF;

       g_migration_mode := p_migration_mode;
       if g_debug then
       	hr_utility.set_location (   'Leaving:'
       	                         || l_proc, 100);
       end if;
    END set_migration_mode;
    FUNCTION employment_ended (
       p_person_id        per_all_people_f.person_id%TYPE,
       p_effective_date   per_all_assignments_f.effective_start_date%TYPE
             DEFAULT SYSDATE
    )
       RETURN BOOLEAN
    IS
       l_proc          VARCHAR2 (72);
       l_employment_ended      BOOLEAN;

       CURSOR csr_existing_employment (
          p_person_id        per_all_people_f.person_id%TYPE,
          p_effective_date   per_all_assignments_f.effective_start_date%TYPE
       )
       IS
          SELECT 1
            FROM per_all_assignments_f paaf, per_assignment_status_types past
           WHERE paaf.person_id = p_person_id
             AND p_effective_date BETWEEN paaf.effective_start_date
                                      AND paaf.effective_end_date
             AND paaf.assignment_type IN ( 'E','C')
             AND past.assignment_status_type_id = paaf.assignment_status_type_id
             AND past.per_system_status IN ('ACTIVE_ASSIGN','ACTIVE_CWK');

       l_existing_employment   csr_existing_employment%ROWTYPE;
    BEGIN
       g_debug := hr_utility.debug_enabled;

       if g_debug then
       	l_proc := g_package|| 'employment_ended';
       	hr_utility.set_location (   'Entering:'
       	                         || l_proc, 10);
       end if;
       OPEN csr_existing_employment (p_person_id, p_effective_date);
       FETCH csr_existing_employment INTO l_existing_employment;

       IF (csr_existing_employment%NOTFOUND)
       THEN
          if g_debug then
          	hr_utility.set_location (
          	      '   The employment for '
          	   || p_person_id
          	   || 'ended.',
          	   20
          	);
          end if;
          l_employment_ended := TRUE;
       ELSE
          l_employment_ended := FALSE;
       END IF;

       CLOSE csr_existing_employment;
       if g_debug then
       	hr_utility.set_location (   'Leaving:'
       	                         || l_proc, 100);
       end if;
       RETURN l_employment_ended;
    END employment_ended;

    FUNCTION assignment_last_eff_dt (
       p_person_id        per_all_people_f.person_id%TYPE,
       p_effective_date   per_all_assignments_f.effective_start_date%TYPE
             DEFAULT SYSDATE
    )
       RETURN per_all_assignments_f.effective_start_date%TYPE
    IS
       l_proc             VARCHAR2 (72);
       l_assignment_last_eff_dt   per_all_assignments_f.effective_start_date%TYPE;

       CURSOR csr_assignment_last_eff_dt (
          p_person_id        per_all_people_f.person_id%TYPE,
          p_effective_date   per_all_assignments_f.effective_start_date%TYPE
       )
       IS
          SELECT MAX (paaf.effective_end_date)
            FROM per_all_assignments_f paaf, per_assignment_status_types past
           WHERE paaf.person_id = p_person_id
             AND paaf.effective_end_date <= p_effective_date
             AND paaf.assignment_type IN ( 'E', 'C')
             AND past.assignment_status_type_id = paaf.assignment_status_type_id
             AND past.per_system_status IN ( 'ACTIVE_ASSIGN','ACTIVE_CWK');
    BEGIN
       g_debug := hr_utility.debug_enabled;

       if g_debug then
       	l_proc := g_package|| 'assignment_last_eff_dt';
       	hr_utility.set_location (   'Entering:'
       	                         || l_proc, 10);
       end if;
       OPEN csr_assignment_last_eff_dt (p_person_id, p_effective_date);
       FETCH csr_assignment_last_eff_dt INTO l_assignment_last_eff_dt;

       IF (csr_assignment_last_eff_dt%NOTFOUND)
       THEN
          -- this will get handled during the actuall preference evaluation, we don't
          -- have to act on it here.
          l_assignment_last_eff_dt := NULL;
       ELSE
          if g_debug then
          	hr_utility.set_location (
          	      '   The last available effective date for person '
          	   || p_person_id
          	   || ' is '
          	   || l_assignment_last_eff_dt,
          	   20
          	);
          end if;
       END IF;

       CLOSE csr_assignment_last_eff_dt;
       if g_debug then
       	hr_utility.set_location (   'Leaving:'
       	                         || l_proc, 100);
       end if;
       RETURN l_assignment_last_eff_dt;
    END assignment_last_eff_dt;

    FUNCTION evaluation_date (
       p_resource_id       hxc_time_building_blocks.resource_id%TYPE,
       p_evaluation_date   DATE
    )
       RETURN DATE
    IS
       l_proc      VARCHAR2 (72);
       l_evaluation_date   DATE;
    BEGIN
       g_debug := hr_utility.debug_enabled;

       if g_debug then
       	l_proc := g_package|| 'evaluation_date';
       	hr_utility.set_location (   'Entering:'
       	                         || l_proc, 10);
       end if;

       IF (    (migration_mode)
           AND (employment_ended (p_person_id => p_resource_id))
           AND TRUNC (p_evaluation_date) = TRUNC (SYSDATE)
          )
       THEN
          l_evaluation_date :=
                            assignment_last_eff_dt (p_person_id => p_resource_id);
       ELSE
          l_evaluation_date := TRUNC (p_evaluation_date);
       END IF;

       if g_debug then
       	hr_utility.set_location (
       	      '   Returning evaluation_date ='
       	   || l_evaluation_date,
       	   20
       	);
       	hr_utility.set_location (   'Leaving:'
       	                         || l_proc, 100);
       end if;
       RETURN l_evaluation_date;
    END evaluation_date;

-- Procedure for Bulk preference evaluation. Calculates the preference for a set of resource_ids.
-- Its a single date evaluation and does not consider responsibility or login based preferences.

procedure resource_prefs_bulk (p_evaluation_date in date,
                                p_pref_table IN OUT NOCOPY t_pref_table,
                                p_resource_pref_table IN OUT NOCOPY t_resource_pref_table,
                                p_resource_sql in varchar2  )
                                is


l_current_resource_id number;
l_matches number;

l_pref_sets_index_table t_pref_sets_index_table;
l_pref_sets_index_table_idx number;

l_pref_sets_table       t_pref_sets_table;
l_pref_sets_table_idx number;

l_flat_table t_pref_sets_table;
l_flat_table_idx number;

l_resource_elig_table t_resource_elig_table;
l_resource_elig_table_idx number;


l_pref_table_idx number;

l_eval_pref_table hxc_preference_evaluation.t_pref_table;
l_eval_pref_table_idx number;

l_set_start number;
l_set_stop number;
l_result_start number;
l_result_stop number;

l_index number;

l_sql_statement varchar2(32000);
TYPE PrefCurTyp IS REF CURSOR;

prefs_cv   PrefCurTyp;


begin

-- Bug 7484448
-- Added USE_NL in the below query for optimum perf.
l_sql_statement :=  ' SELECT /*+ USE_NL(PA HRR) */
                             pa.person_id as criteria_id,
                             hrr.pref_hierarchy_id,
			     hrr.rule_evaluation_order
    FROM hxc_resource_rules hrr,
         per_all_assignments_f pa
   WHERE  pa.person_id  '||p_resource_sql||'
      AND nvl(hrr.business_group_id,pa.business_group_id) = pa.business_group_id
      AND pa.primary_flag =''Y''
      AND pa.assignment_type in (''E'',''C'')
      AND :evaluation_date
            BETWEEN pa.effective_start_date AND pa.effective_END_date
      AND :evaluation_date between hrr.start_date and hrr.end_date
      AND ((   to_char(pa.assignment_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = ''ASSIGNMENT'')
        OR (      to_char(pa.payroll_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = ''PAYROLL'')
        OR (       to_char(pa.person_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = ''PERSON'')
        OR (     pa.EMPLOYEE_CATEGORY = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = ''EMP_CATEGORY'')
        OR (     pa.EMPLOYMENT_CATEGORY = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = ''ASGN_CATEGORY'')
        OR (     to_char(pa.location_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = ''LOCATION'')
        OR (     to_char(pa.organization_id) = hrr.eligibility_criteria_id
                  AND hrr.eligibility_criteria_type = ''ORGANIZATION'')
      	OR  ((HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,instr(hrr.eligibility_criteria_id,''-'',1,1)+1)) in
           (SELECT pose.organization_id_parent
                  FROM
                 per_org_structure_elements pose
		 start with organization_id_child = pa.organization_id
                    and  pose.org_structure_version_id=
                               HXC_PREFERENCE_EVALUATION.return_version_id(HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,1,instr(hrr.eligibility_criteria_id,''-'',1,1)-1)),
                                                         hrr.eligibility_criteria_type)
                    connect by prior organization_id_parent=organization_id_child
                    and  pose.org_structure_version_id=
                               HXC_PREFERENCE_EVALUATION.return_version_id(HXC_PREFERENCE_EVALUATION.check_number(substr(hrr.eligibility_criteria_id,1,instr(hrr.eligibility_criteria_id,''-'',1,1)-1)),
                                                         hrr.eligibility_criteria_type)
                    union
                    select organization_id
                   from   hr_all_organization_units
                   where  organization_id =  pa.organization_id))
                 AND  hrr.eligibility_criteria_type = ''ROLLUP'' )
        OR (     HXC_PREFERENCE_EVALUATION.check_number(hrr.eligibility_criteria_id)
                            in ( SELECT typ.person_type_id
                                               FROM per_person_types typ
                                                   ,per_person_type_usages_f ptu
                                               WHERE typ.system_person_type IN (''EMP'',''EX_EMP'',''EMP_APL'',''EX_EMP_APL'',''CWK'',''EX_CWK'')
                                                 AND typ.person_type_id = ptu.person_type_id
                                                 AND :evaluation_date BETWEEN ptu.effective_start_date AND ptu.effective_end_date
                                                 AND pa.effective_start_date <= ptu.effective_end_date
                                                 AND  pa.effective_end_date >=ptu.effective_start_date
                                                 AND ptu.person_id = pa.person_id)
                 AND hrr.eligibility_criteria_type = ''PERSON_TYPE'')
        OR (
                  hrr.eligibility_criteria_type = ''ALL_PEOPLE''))'|| 'union '||
    ' SELECT pa.person_id as criteria_id,hrr.pref_hierarchy_id, hrr.rule_evaluation_order
    FROM hxc_resource_rules hrr,
         per_all_assignments_f pa
   WHERE pa.person_id  '||p_resource_sql||'
     AND nvl(hrr.business_group_id,pa.business_group_id) = pa.business_group_id
     AND pa.primary_flag = ''Y''
     AND pa.assignment_type in (''E'',''C'')
     AND :evaluation_date
              BETWEEN pa.effective_start_date AND pa.effective_END_date
     AND :evaluation_date between hrr.start_date and hrr.end_date
     AND ( (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 3 ),
                   ''SCL'', DECODE ( pa.soft_coding_keyflex_id, NULL, -1,
                   hxc_resource_rules_utils.chk_flex_valid (''SCL'', pa.soft_coding_keyflex_id,
                   SUBSTR( hrr.eligibility_criteria_type, 5 ),
                   hrr.eligibility_criteria_id )), -1 ) = 1 )
      OR  (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 6 ),
                  ''PEOPLE'', DECODE ( pa.people_group_id, NULL, -1,
                  hxc_resource_rules_utils.chk_flex_valid ( ''PEOPLE'', pa.people_group_id,
                  SUBSTR( hrr.eligibility_criteria_type, 8 ),
                  hrr.eligibility_criteria_id )), -1 ) = 1 )
      OR  (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 5 ),
                  ''GRADE'', DECODE ( pa.grade_id, NULL, -1,
                  hxc_resource_rules_utils.chk_flex_valid ( ''GRADE'', pa.grade_id,
                  SUBSTR( hrr.eligibility_criteria_type, 7 ),
                  hrr.eligibility_criteria_id )), -1 ) = 1 )
      OR  (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 3 ),
                 ''JOB'', hrr.eligibility_criteria_id, -1 ) = to_char(pa.job_id))-- Issue 4
      OR  (DECODE ( SUBSTR( hrr.eligibility_criteria_type, 1, 8 ),
                 ''POSITION'', hrr.eligibility_criteria_id, -1 ) = to_char(pa.position_id)) -- Issue 4
)
order by criteria_id';


l_resource_elig_table_idx := 0;
-- Cache the Rules of all the resource_ids
   OPEN prefs_cv FOR l_sql_statement using p_evaluation_date,p_evaluation_date,p_evaluation_date,p_evaluation_date,p_evaluation_date;

   loop
      FETCH prefs_cv INTO l_resource_elig_table(l_resource_elig_table_idx);
      l_resource_elig_table_idx := l_resource_elig_table_idx + 1;

      EXIT WHEN prefs_cv%NOTFOUND;
   end loop;


l_resource_elig_table_idx := l_resource_elig_table.first;
l_flat_table_idx := 0;

while (l_resource_elig_table_idx is not null)
loop

	l_current_resource_id := l_resource_elig_table(l_resource_elig_table_idx).criteria_id;

	-- populate the flat table;
	l_flat_table(l_flat_table_idx).pref_hier_id := l_resource_elig_table(l_resource_elig_table_idx).pref_hier_id;
	l_flat_table(l_flat_table_idx).reo := l_resource_elig_table(l_resource_elig_table_idx).reo;
	l_flat_table_idx := l_flat_table_idx + 1;

	if(l_resource_elig_table.next(l_resource_elig_table_idx) is not null and
	   l_resource_elig_table(l_resource_elig_table.next(l_resource_elig_table_idx)).criteria_id = l_current_resource_id) then

		-- If there are still rules associated to this resource, then fetch them into flat table before processing
		l_resource_elig_table_idx := l_resource_elig_table.next(l_resource_elig_table_idx);

	-- The flat table now has all the rules associated to the current resource_id. Hence process.
	else

		l_matches := 0;

		l_pref_sets_index_table_idx := l_pref_sets_index_table.first;
		while (l_pref_sets_index_table_idx is not null)
		loop

			l_flat_table_idx := l_flat_table.first;

			for l_index in l_pref_sets_index_table(l_pref_sets_index_table_idx).set_start .. l_pref_sets_index_table(l_pref_sets_index_table_idx).set_stop
			loop
				-- if all entries in the flat table match sets-table but number of entries in flat and sets table is diff, then

				if (l_flat_table_idx is null) then
					--  Flat table no data or is exhausted
					l_matches := 0;
					exit;
				end if;
				l_matches := 1;
				if (l_pref_sets_table(l_index).pref_hier_id <> l_flat_table(l_flat_table_idx).pref_hier_id or
				l_pref_sets_table(l_index).reo <> l_flat_table(l_flat_table_idx).reo) then
				-- No match with the current set. Check the next set.

					l_matches := 0;
					exit;

				end if;
				l_flat_table_idx := l_flat_table.next(l_flat_table_idx);

			end loop;


			-- Case where match found for avaliable entries..but number of entries not same
			if ((l_index is null and l_flat_table_idx is not null) or (l_index is not null and l_flat_table_idx is null)) then
				l_matches := 0;
			end if;

			if (l_matches = 1) then
			-- Found the matching set and hence the preference values
			-- Update the Out table p_resource_pref_table

				p_resource_pref_table(l_current_resource_id).start_index := l_pref_sets_index_table(l_pref_sets_index_table_idx).result_start;

				p_resource_pref_table(l_current_resource_id).stop_index := l_pref_sets_index_table(l_pref_sets_index_table_idx).result_stop;

				exit;
			end if;

			l_pref_sets_index_table_idx := l_pref_sets_index_table.next(l_pref_sets_index_table_idx);
		end loop;

		-- if no match found, then need to evaluate preferences.
		if (l_matches = 0) then
			-- Call preference evaluation proc
			hxc_preference_evaluation.resource_preferences(
			                         p_resource_id =>l_current_resource_id,
                                                 p_evaluation_date =>p_evaluation_date,
                                                 p_pref_table =>l_eval_pref_table,
						 p_ignore_user_id => true,
						 p_ignore_resp_id => true);

			-- 1. Add the Pref-REO set of this resource into l_pref_sets table
			l_flat_table_idx := l_flat_table.first;
			l_pref_sets_table_idx := l_pref_sets_table.last + 1;
			if (l_pref_sets_table.last is null) then
				l_pref_sets_table_idx := 0;
			end if;

			l_set_start := l_pref_sets_table_idx;
			while(l_flat_table_idx is not null)
			loop
				l_pref_sets_table(l_pref_sets_table_idx).pref_hier_id := l_flat_table(l_flat_table_idx).pref_hier_id;

				l_pref_sets_table(l_pref_sets_table_idx).reo := l_flat_table(l_flat_table_idx).reo;

				l_pref_sets_table_idx := l_pref_sets_table_idx + 1;
				l_flat_table_idx := l_flat_table.next(l_flat_table_idx);
			end loop;
			l_set_stop := l_pref_sets_table_idx - 1;

			-- 2. Add Preference Values into Out table p_pref_table
			l_eval_pref_table_idx := l_eval_pref_table.first;
			l_pref_table_idx := p_pref_table.last + 1;
			if (l_pref_table_idx is null) then
				l_pref_table_idx  := 0;
			end if;

			l_result_start := l_pref_table_idx;
			while (l_eval_pref_table_idx is not null)
			loop
				p_pref_table(l_pref_table_idx) := l_eval_pref_table(l_eval_pref_table_idx);

				l_eval_pref_table_idx := l_eval_pref_table.next(l_eval_pref_table_idx);
				l_pref_table_idx := l_pref_table_idx + 1;
			end loop;
			l_result_stop := l_pref_table_idx - 1;

			-- 3. Update the sets_index table
			l_pref_sets_index_table_idx := l_pref_sets_index_table.last + 1;
			if (l_pref_sets_index_table_idx is null) then
				l_pref_sets_index_table_idx := 0;
			end if;
			l_pref_sets_index_table(l_pref_sets_index_table_idx).set_start := l_set_start;
			l_pref_sets_index_table(l_pref_sets_index_table_idx).set_stop := l_set_stop;
			l_pref_sets_index_table(l_pref_sets_index_table_idx).result_start := l_result_start;
			l_pref_sets_index_table(l_pref_sets_index_table_idx).result_stop := l_result_stop;

			-- 4. Update the Out table p_resource_pref_table
			p_resource_pref_table(l_current_resource_id).start_index := l_result_start;
			p_resource_pref_table(l_current_resource_id).stop_index := l_result_stop;
		end if;


		-- The current resource has been processed. So delete the l_flat_table for fresh data to be populated.

		l_flat_table.delete;
		l_flat_table_idx := 0;

		-- Fetch data for the next resource
		l_resource_elig_table_idx := l_resource_elig_table.next(l_resource_elig_table_idx);
	end if;
end loop;

end resource_prefs_bulk;

function return_version_id
		(p_criteria  hxc_resource_rules.eligibility_criteria_id%TYPE,
         p_eligibility_type hxc_resource_rules.eligibility_criteria_type%TYPE)
		return number is

cursor c_version_id(p_number number) is
select   org_structure_version_id
  from   per_org_structure_versions
            where organization_structure_id  = p_number
            and   trunc(sysdate) between nvl(date_from,trunc(sysdate)) and
                  nvl(date_to,sysdate);

l_version_id number;
l_number number;

begin

if (p_eligibility_type = 'ROLLUP')  then

l_number:=to_number(p_criteria);
--Caching logic implemented to improve the performance. If the output for
--given input value exists in global table and not older than 30 second,
--then return the output from global table else hit back the query
--against DB to fetch the output and store the value in global table
--for next reference,,if required-.

if(g_str_version.exists(l_number)
   and (sysdate-g_str_version(l_number).time_info)*24*60*60<30) then
return g_str_version(l_number).org_version_id;
end if;


open c_version_id(l_number);
fetch c_version_id into l_version_id;
     if(c_version_id %found) then
     close c_version_id ;
	g_str_version(l_number).org_version_id:=l_version_id;
	g_str_version(l_number).time_info:=sysdate;
        return l_version_id;
     else
     close c_version_id ;
	g_str_version(l_number).org_version_id:=null;
	g_str_version(l_number).time_info:=sysdate;
	return null;
     end if;

else
  return null;
end if;

end return_version_id;
--==================================================================
FUNCTION get_tc_resp (	p_resource_id NUMBER,
			p_evaluation_date DATE)
RETURN NUMBER
IS
cursor get_resp_id(p_resource_id IN NUMBER, p_evaluation_date IN DATE) is
SELECT  ta.attribute4 , ta.attribute3
from HXC_TIME_ATTRIBUTES ta, HXC_TIME_ATTRIBUTE_USAGES tau, hxc_latest_details ld, hxc_timecard_summary tbd
where ta.time_attribute_id = tau.time_attribute_id
and tau.time_building_block_id = ld.time_building_block_id
and tau.time_building_block_ovn = ld.object_version_number
and ld.resource_id = p_resource_id
and p_evaluation_date between trunc(tbd.START_TIME) and trunc(tbd.STOP_TIME)
and tbd.resource_id = p_resource_id
and trunc(ld.start_time) <= trunc(tbd.STOP_TIME)
and trunc(ld.stop_time) >= trunc(tbd.start_time)
and ta.attribute_category = 'SECURITY'
--and tbd.scope = 'TIMECARD'
order by ld.last_update_date DESC;
resp_id VARCHAR2(100);
l_tc_user_id   VARCHAR2(150);
l_tc_employee_id  NUMBER;
CURSOR get_employee_id(p_user_id IN Number) Is
  Select employee_id from fnd_user
  Where user_id = p_user_id;
BEGIN
	g_debug := hr_utility.debug_enabled;
	if g_debug then
		hr_utility.set_location ('Starting get_tc_resp' , 10 );
	end if;
	OPEN get_resp_id (p_resource_id,p_evaluation_date);
	FETCH get_resp_id into resp_id, l_tc_user_id;
	close get_resp_id;
	open get_employee_id(l_tc_user_id);
	Fetch get_employee_id into l_tc_employee_id;
	Close get_employee_id;
	IF  p_resource_id = l_tc_employee_id then
		if g_debug then
			hr_utility.set_location ('Returning resp_id =' || resp_id, 20 );
			hr_utility.set_location ('Returning l_tc_employee_id =' || l_tc_employee_id, 20 );
		end if;
		return to_number(resp_id);
	ELSE
		hr_utility.set_location ('Returning resp_id = -101' , 20 );
		return(-101);
	END IF;
	if g_debug then
		hr_utility.set_location ('Stopping get_tc_resp' , 30 );
	end if;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		hr_utility.set_location ('Resp_id not found in Security attribute ' || resp_id || 'for resource ' || p_resource_id , 40 );
	 	RETURN(-101);
	WHEN INVALID_NUMBER THEN
		hr_utility.set_location ('Invalid Number Value found in resp_id ' || resp_id || 'for resource ' || p_resource_id , 40 );
		RETURN(-101);
END get_tc_resp;




--================================================================================

PROCEDURE get_tc_resp (	p_resource_id IN NUMBER,
			p_start_evaluation_date IN DATE,
			p_end_evaluation_date IN DATE,
			p_resp_id OUT NOCOPY NUMBER,
			p_resp_appl_id OUT NOCOPY NUMBER)
IS



cursor get_latest_detail_bbid (p_resource_id IN NUMBER, p_start_evaluation_date IN DATE, p_end_evaluation_date DATE) is
SELECT ld.time_building_block_id, ld.object_version_number
from hxc_latest_details ld
WHERE ld.resource_id = p_resource_id
and trunc(ld.start_time) <= trunc(p_end_evaluation_date)
and trunc(ld.stop_time) >= trunc(p_start_evaluation_date)
order by ld.last_update_date DESC;

cursor get_resp_id (detail_building_block_id IN NUMBER, detail_builiding_block_ovn IN NUMBER) IS
SELECT ta.attribute4, ta.attribute5, ta.attribute3
FROM HXC_TIME_ATTRIBUTES ta, HXC_TIME_ATTRIBUTE_USAGES tau
WHERE   ta.attribute_category = 'SECURITY'
	and ta.time_attribute_id = tau.time_attribute_id
	and tau.time_building_block_id = detail_building_block_id
	and tau.time_building_block_ovn = detail_builiding_block_ovn;



resp_id VARCHAR2(100);
resp_appl_id VARCHAR2(100);
l_tc_user_id   VARCHAR2(150);
l_tc_employee_id  NUMBER;
CURSOR get_employee_id(p_user_id IN Number) Is
  Select employee_id from fnd_user
  Where user_id = p_user_id;



Cursor get_tc_start_stop(  p_resource_id IN NUMBER, l_detail_building_block_id IN NUMBER, detail_builiding_block_ovn IN NUMBER) is
select START_TIME, STOP_TIME, DATE_TO from hxc_time_building_blocks t
where scope = 'TIMECARD' AND
      resource_id =p_resource_id
connect by  prior parent_building_block_id = time_building_block_id
	and prior parent_building_block_ovn = object_version_number
start with time_building_block_id = l_detail_building_block_id
	and object_version_number = detail_builiding_block_ovn
order by time_building_block_id asc, object_version_number desc;

l_detail_building_block_id	NUMBER;
l_detail_building_block_ovn	NUMBER;
l_tc_start_time			DATE;
l_tc_stop_time			DATE;
l_tc_date_to			DATE;


BEGIN
	g_debug := hr_utility.debug_enabled;
	if g_debug then
		       	hr_utility.set_location ('Starting get_tc_resp' , 40 );
	end if;



	OPEN get_latest_detail_bbid (p_resource_id,p_start_evaluation_date,p_end_evaluation_date );
	FETCH get_latest_detail_bbid into l_detail_building_block_id, l_detail_building_block_ovn ;
	close get_latest_detail_bbid;

	/*OPEN get_resp_id (p_resource_id,p_start_evaluation_date,p_end_evaluation_date );
	FETCH get_resp_id into resp_id, resp_appl_id, l_tc_user_id,l_detail_building_block_id, l_detail_building_block_ovn ;
	close get_resp_id;*/




	OPEN get_tc_start_stop(p_resource_id, l_detail_building_block_id, l_detail_building_block_ovn);
	FETCH get_tc_start_stop INTO l_tc_start_time, l_tc_stop_time,l_tc_date_to;
	CLOSE get_tc_start_stop;

	IF trunc(l_tc_start_time) = trunc(p_start_evaluation_date)
		AND trunc(l_tc_stop_time) = trunc(p_end_evaluation_date)
		AND trunc(l_tc_date_to) = trunc(hr_general.end_of_time) THEN


		OPEN get_resp_id (l_detail_building_block_id, l_detail_building_block_ovn );
		FETCH get_resp_id into resp_id, resp_appl_id, l_tc_user_id;
		close get_resp_id;


		open get_employee_id(l_tc_user_id);
		Fetch get_employee_id into l_tc_employee_id;
		Close get_employee_id;


		IF p_resource_id = l_tc_employee_id then

			--return to_number(resp_id);
			p_resp_id := to_number(resp_id);
			p_resp_appl_id := to_number(resp_appl_id);


			if g_debug then
				hr_utility.set_location ('Returning resp_id =' || resp_id, 50 );
				hr_utility.set_location ('Returning resp_appl_id =' || resp_appl_id, 50 );
			end if;

		ELSE
			p_resp_id := -101;
			p_resp_appl_id := to_number(fnd_global.resp_appl_id);
			if g_debug then
				hr_utility.set_location ('Returning resp_id =' || p_resp_id, 55 );
				hr_utility.set_location ('Returning resp_appl_id =' || p_resp_appl_id, 55 );
			end if;
		END IF;
	ELSE


		p_resp_id := to_number(fnd_global.resp_id);
		p_resp_appl_id := to_number(fnd_global.resp_appl_id);

		if g_debug then
			hr_utility.set_location ('10 Returning resp_id =' || p_resp_id, 58 );
			hr_utility.set_location ('10 Returning resp_appl_id =' || p_resp_appl_id, 58 );
		end if;

	END IF;


	if g_debug then
		hr_utility.set_location ('Stopping get_tc_resp' , 60 );
	end if;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		p_resp_id := -101;
		p_resp_appl_id := to_number(fnd_global.resp_appl_id);
	WHEN INVALID_NUMBER THEN
		p_resp_id := -101;
		p_resp_appl_id := to_number(fnd_global.resp_appl_id);
		hr_utility.set_location ('Invalid Number Value found in resp_id ' || resp_id || 'for resource ' || p_resource_id , 70 );
END get_tc_resp;





-- PROCEDURE get_tc_resp
-- Returns a PL/SQL table structure holding the timecard start and
-- stop dates and the last touched responsibility for that timecard.
-- Overloaded from get_tc_resp used above, but this version is used
-- for actual persistent responsibility evaluation.


PROCEDURE get_tc_resp (	p_resource_id           IN  NUMBER,
			p_start_evaluation_date IN  DATE,
			p_end_evaluation_date   IN  DATE,
                        p_resplist              OUT NOCOPY resplisttab )
IS



  -- The below cursor would return all the timecard start, stop
  -- dates within the given range. The WHERE clause looks at
  -- the passed in resource_id, and start and end evaluation
  -- dates. Since we anyway have to do this, why not pull out
  -- the last touched time building block id and ovn ?
  -- The RANK function will partition based on resource_id,
  -- start_time and stop_time, meaning for a logical timecard
  -- structure for a resource, it will rank the available records
  -- based on these -- and we identify one valid timecard per
  -- resource_id-start_time-stop_time combination in the system.
  -- The Rank is determined ordering by date_to, tbb_id, and ovn
  -- This means that the first record out there would be the
  -- latest timecard, hence the outer query is looking at only
  -- the first rank.
  -- Since the rank is partitioned on resource_id, start_time
  -- and stop_time, we would get only one record even if there
  -- are multiple deletions and resubmissions for the same
  -- time periods -- we always get the latest one.



  CURSOR get_time_periods ( p_resource_id           NUMBER,
                            p_start_evaluation_date DATE,
                            p_end_evaluation_date   DATE )
      IS SELECT timecard_id,
                timecard_ovn,
                start_time,
                stop_time,
                date_to
           FROM ( SELECT time_building_block_id timecard_id,
                         object_version_number timecard_ovn,
	                 start_time,
	                 stop_time,
	                 date_to,
    	                 RANK() OVER ( PARTITION BY resource_id,
    	                                            start_time,
    	                                            stop_time
	                                   ORDER BY date_to DESC,
	                                            time_building_block_id DESC,
	                                            object_version_number DESC ) rank
                    FROM hxc_time_building_blocks
                   WHERE resource_id       = p_resource_id
                     AND scope             = 'TIMECARD'
                     AND TRUNC(start_time) BETWEEN p_start_evaluation_date
                                               AND p_end_evaluation_date
                     AND TRUNC(stop_time)  BETWEEN p_start_evaluation_date
                                               AND p_end_evaluation_date
                )
          WHERE rank = 1;


  -- This cursor pulls out the SECURITY attribute values
  -- for the given time_building_block_id and OVN.


  CURSOR get_tc_resp_id ( p_timecard_id  NUMBER,
                          p_timecard_ovn NUMBER )
      IS SELECT ha.attribute4,
                ha.attribute5,
                ha.attribute3
           FROM hxc_time_attribute_usages hau,
                hxc_time_attributes       ha
          WHERE hau.time_building_block_id  = p_timecard_id
            AND hau.time_building_block_ovn = p_timecard_ovn
            AND ha.time_attribute_id        = hau.time_attribute_id
            AND attribute_category = 'SECURITY' ;


  -- This cursor would pull out SECURITY attributes for
  -- the latest updated detail from hxc_latest_details.
  -- We pick only one record from the below cursor, the first
  -- one when its ordered Descending based on last_update_date.


  CURSOR get_tc_det_resp_id ( p_resource_id NUMBER,
                              p_start_date  DATE,
                              p_stop_date   DATE )
      IS SELECT ha.attribute4,
                ha.attribute5,
                ha.attribute3
           FROM hxc_time_attribute_usages hau,
                hxc_time_attributes       ha,
                hxc_latest_details        hld
          WHERE hld.resource_id              = p_resource_id
            AND TRUNC(hld.start_time)       >= p_start_date
            AND TRUNC(hld.stop_time)        <= TRUNC(p_stop_date)
            AND hau.time_building_block_id   = hld.time_building_block_id
            AND hau.time_building_block_ovn  = hld.object_version_number
            AND hau.time_attribute_id        = ha.time_attribute_id
            AND attribute_category           = 'SECURITY'
            ORDER BY hld.last_update_date DESC ;


  CURSOR get_user_person_id ( p_user_id  NUMBER )
      IS SELECT employee_id
           FROM fnd_user
          WHERE user_id = p_user_id;

  TYPE time_periodsrec IS RECORD
  (  timecard_id   NUMBER,
     timecard_ovn  NUMBER,
     start_time    DATE,
     stop_time     DATE,
     date_to       DATE ) ;

  TYPE time_periodstab IS TABLE OF time_periodsrec ;

  time_periods  time_periodstab;

  l_resp_id    NUMBER;
  l_user_id    NUMBER;
  l_resp_appln_id NUMBER;
  l_resource_id   NUMBER;

  resplist resplisttab := resplisttab () ;

  cnt  NUMBER;




BEGIN
	-- Public Procedure get_tc_resp
	-- Takes in the resource_id for whom the process is executed
	--    and the evaluation start and end dates.
	-- Get the valid time periods from hxc_time_building_blocks
	--    table falling within the given start and end dates for
	--    evaluation. Need to consider only those periods which
	--    fall within the given range, not the ones crossing over
	--    the boundaries, because Persistent responsibility can
	--    be evaluated only when the whole timecard is looked at.
	--    While the time periods ( timecard start dates and stop dates
	--    are picked up, also pick up the latest OVNs and tbb ids
	--    for each tc start- stop times.
	-- If the last touched upon timecard record is deleted, there
	--    is no point in looking at latest details, rather look
	--    into the timecard record's SECURITY attributes.
	-- If the last touched upon timecard is still live look at
	--    HXC_LATEST_DETAILS table to find out who touched the
	--    timecard last and get the SECURITY attribute.
	-- Get the resource_id attached to the user.
	-- If its the same resource_id as the parameter of this procedure
	--    it means its the employee himself, and we need his
	--    persistent responsibility preferences. Record the fetched
	--    responsibility ids and periods into the data structure.
	-- If its somebody else, it is a Time Keeper or a Line Manager
	--    or an Authorized Delegate, never mind his preferences;
	--    put down -1 for responsibilities.
	-- Repeat the above steps for all the valid time periods
	--    ( timecard start-stop dates in the given date range)
	--



	IF g_debug
	THEN
           hr_utility.trace ('get_tc_resp');
	END IF;

	OPEN get_time_periods ( p_resource_id           => p_resource_id,
	                        p_start_evaluation_date => p_start_evaluation_date,
	                        p_end_evaluation_date   => p_end_evaluation_date ) ;

        FETCH get_time_periods
         BULK COLLECT INTO time_periods ;

        CLOSE get_time_periods;

        cnt := 0;

        IF time_periods.COUNT > 0
        THEN
           FOR i IN time_periods.FIRST..time_periods.LAST
           LOOP

               -- For all the available time periods and tbb_ids and OVNs
               -- last updated for those time periods, check if the last
               -- updation was a deletion -- meaning there would not be
               -- end of time in the date_to column. For these timecards,
               -- neednt go to details, just get the responsibility which
               -- deleted the timecard.

               IF time_periods(i).date_to <> hr_general.end_of_time
               THEN
                      OPEN get_tc_resp_id( time_periods(i).timecard_id,
                                           time_periods(i).timecard_ovn );
                      FETCH get_tc_resp_id
                       INTO l_resp_id,
                            l_resp_appln_id,
                            l_user_id ;
                      CLOSE get_tc_resp_id;


	       -- For others, you have to go to the details and find
	       -- out which one was last modified. You take only one
	       -- record -- meaning, even if there are multiple records
	       -- out there, we take only the last one for each timecard.

               ELSE
                      OPEN get_tc_det_resp_id ( p_resource_id,
                                                time_periods(i).start_time,
                                                time_periods(i).stop_time) ;
                      FETCH get_tc_det_resp_id
                       INTO l_resp_id,
                            l_resp_appln_id,
                            l_user_id ;

                      CLOSE get_tc_det_resp_id;
               END IF;

               OPEN get_user_person_id( l_user_id );

               FETCH get_user_person_id
                INTO l_resource_id ;

               CLOSE get_user_person_id ;



               resplist.EXTEND(1);
               cnt := cnt + 1;

               -- Only if the person who touched the timecard last is
               -- the same person to whom the timecard belongs to, need
               -- the responsibility be recorded. Else record -1.
               IF l_resource_id = p_resource_id
               THEN
                  resplist(cnt).resp_id          := l_resp_id;
                  resplist(cnt).start_date       := time_periods(i).start_time ;
                  resplist(cnt).stop_date        := time_periods(i).stop_time;
               ELSE
                  resplist(cnt).resp_id          := -1 ;
                  resplist(cnt).start_date       := time_periods(i).start_time ;
                  resplist(cnt).stop_date        := time_periods(i).stop_time;
               END IF;

               l_resp_id       := NULL;
               l_user_id       := NULL;
               l_resp_appln_id := NULL;

           END LOOP;

        END IF;


        -- Return the responsibility table to resource_preferences.
        p_resplist  := resplist;



END get_tc_resp;







FUNCTION resource_preferences(p_resource_id        IN NUMBER,
                              p_pref_code          IN VARCHAR2,
                              p_attribute_n        IN NUMBER,
                              p_resp_id 	   IN NUMBER  )
RETURN VARCHAR2 IS
l_pref_table t_pref_table;
l_table_mask t_requested_pref_list;
l_first NUMBER;
BEGIN
RETURN resource_preferences(p_resource_id,p_pref_code,p_attribute_n,SYSDATE,p_resp_id);
END resource_preferences;
--===============================================

END hxc_preference_evaluation;


/
