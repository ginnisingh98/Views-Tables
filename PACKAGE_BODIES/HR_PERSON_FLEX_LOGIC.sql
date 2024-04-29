--------------------------------------------------------
--  DDL for Package Body HR_PERSON_FLEX_LOGIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_FLEX_LOGIC" AS
/* $Header: hrperlog.pkb 115.21 2003/07/07 18:21:17 asahay noship $ */


/************************************************************
 Function  	: GetABV
 Inputs		: ABV Formula ID
                  ABV eg. HeadCount / FTE
                  Assignment ID
                  Effective Date
                  Session Date
 Outputs        : Assignment Budget Value
 ************************************************************/

FUNCTION GetABV
  (p_ABV_formula_id  IN NUMBER
  ,p_assignment_id   IN NUMBER
  ,p_effective_date  IN DATE
  ,p_session_date    IN DATE)
RETURN NUMBER IS

  l_budget_value  number;
  l_inputs	  ff_exec.inputs_t;
  l_outputs	  ff_exec.outputs_t;

BEGIN

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 10');

   -- Initialise the Inputs and  Outputs tables

   FF_Exec.Init_Formula
	( p_ABV_formula_id
	, p_session_date
  	, l_inputs
	, l_outputs );

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 15');

   if (l_inputs.first is not null)
   and (l_inputs.last is not null)
   then

   -- Set up context values for the formula

      for i in l_inputs.first..l_inputs.last

      loop

      -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 20');

         if l_inputs(i).name = 'DATE_EARNED' then

            l_inputs(i).value := FND_Date.Date_To_Canonical (p_effective_date);

            -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 25');

         elsif l_inputs(i).name = 'ASSIGNMENT_ID' then

           l_inputs(i).value := p_assignment_id;

         end if;

      -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 30');

      end loop;

      -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 35');

   end if;

   -- Run the formula

   FF_Exec.Run_Formula (l_inputs, l_outputs);

   -- Get the result

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 40');

   l_budget_value := to_number( l_outputs(l_outputs.first).value );

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 45');

   return (l_budget_value);

EXCEPTION

  -- raises an exception and appropriate error message if
  -- the fast formula fails to run (usually due to not being compiled).

   when Others then

   Raise_FF_Not_Compiled( p_ABV_formula_id );

END GetABV;


FUNCTION GetABV
  (p_ABV            IN VARCHAR2
  ,p_assignment_id  IN NUMBER
  ,p_session_date   IN DATE	  default sysdate )
RETURN NUMBER IS

cursor c_budget_value
is
   select  value
   from	   per_assignment_budget_values_f
   where   assignment_id  = p_assignment_id
   and	   unit           = p_ABV
   and	   p_session_date between effective_start_date and effective_end_date;

l_budget_value  Number  := null;

BEGIN

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 50');

   open c_budget_value;
   fetch c_budget_value into l_budget_value;

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 55');

   if (c_budget_value%notfound)
   then

      -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 60');

      l_budget_value := null;

   end if;

   close c_budget_value;

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 65');

   return l_budget_value;

END GetABV;


FUNCTION GetABV
  (p_ABV_formula_id  IN NUMBER
  ,p_ABV	     IN VARCHAR2
  ,p_assignment_id   IN NUMBER
  ,p_effective_date  IN DATE
  ,p_session_date    IN DATE )
RETURN NUMBER IS

  l_metric_value   Number;
  l_ABV_formula_id Number;

BEGIN

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 70');

   -- First check Assignment Budget Values table

   l_metric_value := GetABV
                     ( p_ABV 		=> p_ABV
                     , p_assignment_id 	=> p_assignment_id
                     , p_session_date  	=> p_effective_date );

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 75');

   if (l_metric_value is null)
   then

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 16 p_ABV_formula_id = '||p_ABV_formula_id);
   -- There is no ABV value in table, so try FastFormula

      if (p_ABV_formula_id is not null)
      then

      -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 17');

      -- Execute FastFormula

      l_metric_value := GetABV
                        (p_ABV_formula_id  => p_ABV_formula_id
                        ,p_assignment_id   => p_assignment_id
                        ,p_effective_date  => p_effective_date
                        ,p_session_date    => p_session_date );

      else

      -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 18');

      -- raise an exception and appropriate error message if
      -- the fast formula does not exist, and no ABV exists for the assignment.

         Raise_FF_Not_exist( p_ABV );
       end if;
     end if;

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetABV - 19');

   return l_metric_value;

END GetABV;


/************************************************************
 Function  	: GetAsgWorkerType
 Inputs		: Assignment ID
 Outputs 	: 'P' (Permanent) ,
		  'T' (Temporary) Worker Types
 ************************************************************/

Function GetAsgWorkerType
(p_AsgWorkerType_formula_id   IN NUMBER
,p_assignment_id              IN NUMBER
,p_effective_date             IN DATE
,p_session_date               IN DATE
) RETURN VARCHAR2 IS

l_asgpertype            varchar2(2000);
l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;

BEGIN

   -- dbms_output.put_line('Function GetAsgWorkerType - 20');

-- Initialise the Inputs and  Outputs tables
   ff_exec.init_formula(
           p_AsgWorkerType_formula_id
           ,p_session_date
           ,l_inputs
           ,l_outputs
           );
--
-- Set up context values for the formula
--

   if  (l_inputs.first is not null)
   and (l_inputs.last is not null)
   then

      -- dbms_output.put_line('Function GetAsgWorkerType - 25');

      for i in l_inputs.first..l_inputs.last

      loop

         -- dbms_output.put_line('Function GetAsgWorkerType - 30');

         if l_inputs(i).name = 'DATE_EARNED' then
         l_inputs(i).value := FND_Date.Date_To_Canonical (p_effective_date);

         -- dbms_output.put_line('Function GetAsgWorkerType - 35');

         elsif

         l_inputs(i).name = 'ASSIGNMENT_ID' then
         l_inputs(i).value := p_assignment_id;

         -- dbms_output.put_line('Function GetAsgWorkerType - 40');

         end if;

      end loop;

      -- dbms_output.put_line('Function GetAsgWorkerType - 45');

   end if;

   -- Run the formula

   ff_exec.run_formula( l_inputs, l_outputs);

   for i in l_outputs.first..l_outputs.last

   loop

      -- Get the result
      -- dbms_output.put_line('Function GetAsgWorkerType - 50');

      if l_outputs(i).name='PERSON' then

         l_asgpertype :=  l_outputs(i).value;

         -- dbms_output.put_line('Function GetAsgWorkerType - 55 '||l_outputs(i).name);

      end if;

   end loop;

   -- dbms_output.put_line('Function GetAsgWorkerType - 60');

return(l_asgpertype);

/*
EXCEPTION
when others then
return('');
*/

END GetAsgWorkerType;



/************************************************************
 Function  	: GetJobCategory
 Inputs		: Job Category
                : Job ID
 Outputs        : 'Y' (whether the Assignment is of
                  Job Catgeory passed )
 ************************************************************/

FUNCTION GetJobCategory
  (p_job_id       IN NUMBER
  ,p_job_category IN VARCHAR2)
RETURN VARCHAR2 IS

cursor getjobcatg
(p_job_id	NUMBER
,p_job_category	VARCHAR2)
is
   select 'Y'
   from   per_job_extra_info
   where  information_type    = 'Job Category'
   and    JEI_INFORMATION1    = p_job_category
   and    job_id              = p_job_id;

l_job_category  varchar2(1);

begin

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC - 25');

   open getjobcatg(p_job_id,p_job_category);

   fetch getjobcatg into l_job_category;

   if getjobcatg%notfound then

   close getjobcatg;

   -- dbms_output.put_line('HR_PERSON_FLEX_LOGIC - 26');

   l_job_category := 'N';

   end if;

   return(l_job_category);

end GetJobCategory;

/************************************************************
 Function  	: GetTermTypeFormula
 Inputs		: Business Group Id
 Outputs 	: Term Type Formula Id
 ************************************************************/

FUNCTION GetTermTypeFormula
  (p_business_group_id     IN NUMBER )
  RETURN NUMBER IS

  l_formula_id          NUMBER;

CURSOR c_term_formula
IS
   SELECT formula_id
   FROM   ff_formulas_f
   WHERE  business_group_id+0 = p_business_group_id
   AND    SYSDATE BETWEEN effective_start_date AND effective_end_date
   AND    formula_name        = 'HR_MOVE_TYPE';

CURSOR c_tmplt_term_formula
IS
   SELECT formula_id
   FROM   ff_formulas_f
   WHERE  business_group_id+0 is null
   AND    SYSDATE BETWEEN effective_start_date AND effective_end_date
   AND    formula_name = 'HR_MOVE_TYPE_TEMPLATE';

BEGIN

   -- Look for a customer formula

   OPEN  c_term_formula;

   FETCH c_term_formula INTO l_formula_id;

   -- If a customer formula does not exist

   IF (c_term_formula%NOTFOUND OR c_term_formula%NOTFOUND IS NULL) THEN

   CLOSE c_term_formula;

   -- Look for the template formula

   OPEN c_tmplt_term_formula;

   FETCH c_tmplt_term_formula INTO l_formula_id;

      -- If the template formula does not exist

      IF (c_tmplt_term_formula%NOTFOUND OR
          c_tmplt_term_formula%NOTFOUND IS NULL) THEN

      CLOSE c_tmplt_term_formula;

   -- Raise an error

      raise_ff_not_exist(0);

      ELSE

      CLOSE c_tmplt_term_formula;

      END IF;

   ELSE

   CLOSE c_term_formula;

   END IF;

RETURN l_formula_id;

END GetTermTypeFormula;

/************************************************************
 Function  : GetTermType
 Inputs	   : Term Formula ID
	     Leaving Reason
	     Session Date
 Outputs   : Term Type
 ************************************************************/

FUNCTION GetTermType
  ( p_term_formula_id	IN NUMBER
  , p_leaving_reason	IN VARCHAR2
  , p_session_date	IN DATE)
RETURN VARCHAR2 IS

  l_term_type		varchar2(10);
  l_inputs		ff_exec.inputs_t;
  l_outputs		ff_exec.outputs_t;

BEGIN
-- dbms_output.put_line('Entering HR_PERSON_FLEX_LOGIC.GetTermType - 27');
  -- Initialise the Inputs and  Outputs tables
  FF_Exec.Init_Formula
	( p_term_formula_id
	, p_session_date
  	, l_inputs
	, l_outputs );

-- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetTermType - 28');
  if (l_inputs.first is not null)
  and (l_inputs.last is not null)
  then
    -- Set up context values for the formula
    for i in l_inputs.first..l_inputs.last loop

-- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetTermType - 29');
      if l_inputs(i).name = 'LEAVING_REASON' then
        l_inputs(i).value := p_leaving_reason;
      end if;
    end loop;
  end if;

  -- Run the formula
-- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetTermType - 30');
  FF_Exec.Run_Formula (l_inputs, l_outputs);

  -- Get the result
  l_term_type := l_outputs(l_outputs.first).value ;

-- dbms_output.put_line('HR_PERSON_FLEX_LOGIC.GetTermType - 31');
  return (l_term_type);

EXCEPTION
  -- raises an exception and appropriate error message if
  -- the fast formula fails to run (usually due to not being compiled).
  when Others then
    Raise_FF_Not_compiled( p_term_formula_id );

END GetTermType;

/************************************************************
 Function  	: GetMovementCategory
 Inputs		: Organization_id
		  Assignment Id
		  Period Start Date
		  Period End Date
		  Movement Type
		  Assignment Type
 Outputs 	: Movement Category
 ************************************************************/

PROCEDURE GetMovementCategory(
 p_organization_id       IN   NUMBER
,p_assignment_id	 IN   NUMBER
,p_period_start_date	 IN   DATE
,p_period_end_date	 IN   DATE
,p_movement_type	 IN   VARCHAR2
,p_assignment_type       IN   VARCHAR2 default 'E'
,p_movement_category OUT NOCOPY  VARCHAR2
) IS
--
cursor asg_csr is
select ast.per_system_status status
,      asg.effective_start_date
,      asg.effective_end_date
,      asg.organization_id
from   per_assignment_status_types ast
,      per_all_assignments_f asg
where  asg.assignment_status_type_id = ast.assignment_status_type_id
and    asg.assignment_id = p_assignment_id
and    asg.effective_start_date	<= p_period_end_date
order by asg.effective_start_date desc;
--
cursor hire_date_csr is
select per.start_date
from   per_all_people_f		per
,      per_all_assignments_f		asg
where  asg.person_id	  = per.person_id
and    p_period_end_date between per.effective_start_date and per.effective_end_date
and    p_period_end_date between asg.effective_start_date and asg.effective_end_date
and    asg.assignment_id  = p_assignment_id;
--
cursor term_date_csr is
select pos.actual_termination_date
from   per_periods_of_service		pos
      ,per_all_assignments_f		asg
where  asg.period_of_service_id	= pos.period_of_service_id
and    p_period_start_date-1 between asg.effective_start_date
				 and asg.effective_end_date
and	asg.assignment_id = p_assignment_id;
--
cursor cwk_term_date_csr is
select pps.actual_termination_date
from   per_periods_of_placement		pps
      ,per_all_assignments_f		asg
where  asg.person_id	= pps.person_id
and    asg.period_of_placement_date_start = pps.date_start
and    p_period_start_date-1 between asg.effective_start_date
				 and asg.effective_end_date
and	asg.assignment_id = p_assignment_id;
--
asg_rec		 asg_csr%rowtype;
hire_date_rec	 hire_date_csr%rowtype;
term_date_rec	 term_date_csr%rowtype;
--
l_assignment_category	varchar2(30);
--
l_first_time      boolean := true;
l_hire_date	  date;
l_start_date	  date;
l_status	  varchar2(20);
l_term_date	  date;
--
BEGIN
--
-- dbms_output.put_line('Organization_id='||p_organization_id);
-- dbms_output.put_line('Assignment_id  ='||p_assignment_id);
-- dbms_output.put_line('Start Date     ='||to_char(p_period_start_date,'DD-MON-YYYY'));
-- dbms_output.put_line('End Date       ='||to_char(p_period_end_date,'DD-MON-YYYY'));
-- dbms_output.put_line('Movement Type  ='||p_movement_type);
--
  if p_movement_type = 'IN' then
--
-- If p_movement_type = 'IN', the employee assignment is Active at the
-- Period End Date, and is not Active at Period Start Date minus 1 day.
--
-- Loop backwards through date-tracked assignment rows
    for asg_rec in asg_csr loop
--
      if l_first_time = true then
        null;
--
      elsif asg_rec.status = 'SUSP_ASSIGN' then
        l_assignment_category := 'REACTIVATED';
        exit;
--
      elsif  (asg_rec.organization_id  <> p_organization_id
	      and asg_rec.effective_end_date >= p_period_start_date) -- Added Condition
      then
        l_assignment_category := 'TRANSFER_IN';
        exit;
--
      end if;
--
      l_first_time := false;
      l_start_date := asg_rec.effective_start_date;
--
    end loop;
--
    if l_assignment_category is null then
--
-- Determine Hire Date
      for hire_date_rec in hire_date_csr loop
        l_hire_date := hire_date_rec.start_date;
      end loop;
--
      if ((l_start_date = l_hire_date) and
	(l_hire_date > p_period_start_date)) -- Added check for New Hire
	then
        l_assignment_category := 'NEW_HIRE';
      else
        l_assignment_category := 'START';
      end if;
--
    end if;
--
    p_movement_category	:= l_assignment_category;
--
  elsif p_movement_type = 'OUT' then

-- If p_movement_type = 'OUT', the employee assignment is Active at
-- Period Start Date minus 1 day, and is not Active at Period End Date.

-- Determine Actual Termination Date
   if p_assignment_type = 'E' then
    for term_date_rec in term_date_csr loop
      l_term_date 	:= term_date_rec.actual_termination_date;
    end loop;
   elsif p_assignment_type = 'C' then
    for cwk_term_date_rec in cwk_term_date_csr loop
      l_term_date       := cwk_term_date_rec.actual_termination_date;
    end loop;

    end if;
--
    for asg_rec in asg_csr loop
--
      if (( asg_rec.status = 'ACTIVE_ASSIGN'
          OR asg_rec.status = 'ACTIVE_CWK' ) and
            asg_rec.organization_id  = p_organization_id )
      then

-- When an assignment's status is changed to 'End', all that happens is the
-- assignment row with status Active is given an Effective End Date. No new
-- rows are created, the status End is not stored on the database anywhere.
-- Consequently, the IF test above is satisfied the 1st time through the loop.

        if ( l_first_time = true ) then

          if l_term_date is null then

-- Assignment has been given an End Date

            p_movement_category := 'ENDED';
            exit;
          else

-- Employee terminated with Actual Termination Date = Final Processing Date.
-- In this case, no assignment row with status TERM_ASSIGN is created.

            p_movement_category :=  'SEPARATED';
            exit;
          end if;

        elsif ( l_status = 'TERM_ASSIGN'
              OR l_status = 'TERM_CWK_ASSIGN' ) then
--
          p_movement_category :=  'SEPARATED';
          exit;
--
        elsif ( l_status = 'SUSP_ASSIGN'
              OR l_status = 'SUSP_CWK_ASSIGN' ) then
          p_movement_category :=  'SUSPENDED';
          exit;
--
        else
          p_movement_category := 'TRANSFER_OUT';
          exit;
        end if;
--
      else

-- Save assignment status of the last row before the 'ACTIVE_ASSIGN' row
        l_status := asg_rec.status;
      end if;
--
      l_first_time := false;
    end loop;
  end if;

END GetMovementCategory;

/************************************************************
 Function  	: GetCurNH
 Inputs		: Organization ID
		    Assignment ID
		    Session Date
 Outputs 	: Current New Hire
 ************************************************************/

FUNCTION GetCurNH
  ( p_organization_id	IN NUMBER
  , p_assignment_id		IN VARCHAR2
  , p_report_date		IN DATE)
RETURN VARCHAR2 IS

cursor c_cur_nh
(p_organization_id	NUMBER,
p_assignment_id	NUMBER,
p_report_date  	DATE)
is
select 	'Y'
from 	per_periods_of_service pos
where	pos.date_start between add_months(p_report_date,-1) and p_report_date
and 		pos.period_of_service_id in (
			select    paf.period_of_service_id
			from	  per_all_assignments_f  paf
			where     paf.period_of_service_id = pos.period_of_service_id
			and	  paf.organization_id = p_organization_id
			and	  paf.assignment_id   = p_assignment_id);

l_cur_nh		varchar2(1);

BEGIN

l_cur_nh := 'N';

open c_cur_nh
	 (p_organization_id
  	, p_assignment_id
     , p_report_date);
fetch c_cur_nh into l_cur_nh;
if c_cur_nh%NOTFOUND then
   close c_cur_nh;
end if;
-- close c_cur_nh;

return (l_cur_nh);

end GetCurNH;

/************************************************************
 Function  	: GetCurNHNew
 Inputs		: Organization ID
		  Assignment ID
		  Date From
		  Date To
 Outputs 	: Current New Hire
 ************************************************************/

FUNCTION GetCurNHNew
  ( p_organization_id	IN NUMBER
  , p_assignment_id	IN VARCHAR2
  , p_assignment_type	IN VARCHAR2
  , p_cur_date_from	IN DATE
  , p_cur_date_to	IN DATE)
RETURN VARCHAR2 IS

cursor c_cur_nh
(p_organization_id	NUMBER,
p_assignment_id		NUMBER,
p_cur_date_from  	DATE,
p_cur_date_to		DATE)
is
select 	'Y'
from 	per_periods_of_service pos
where	pos.date_start between p_cur_date_from and p_cur_date_to
and 		pos.period_of_service_id in (
			select paf.period_of_service_id
			from	  per_all_assignments_f  paf
			where     paf.period_of_service_id = pos.period_of_service_id
			and	  paf.organization_id = p_organization_id
			and	  paf.assignment_id   = p_assignment_id);

cursor c_cwk_cur_nh
(p_organization_id	NUMBER,
p_assignment_id		NUMBER,
p_cur_date_from  	DATE,
p_cur_date_to		DATE)
is
select 	'Y'
from 	per_periods_of_placement pps
where	pps.date_start between p_cur_date_from and p_cur_date_to
and     exists (select 1
               from      per_all_assignments_f  paf
               where     paf.person_id = pps.person_id
               and       paf.period_of_placement_date_start = pps.date_start
               and       paf.organization_id   = p_organization_id
               and       paf.assignment_id     = p_assignment_id);

l_cur_nh		varchar2(1);

BEGIN

l_cur_nh := 'N';
if p_assignment_type = 'E' then
open c_cur_nh
	 (p_organization_id
  	 ,p_assignment_id
	 ,p_cur_date_from
	 ,p_cur_date_to);
fetch c_cur_nh into l_cur_nh;
if c_cur_nh%NOTFOUND then
   close c_cur_nh;
end if;

return (l_cur_nh);

elsif p_assignment_type = 'C' then
open c_cwk_cur_nh
         (p_organization_id
         ,p_assignment_id
         ,p_cur_date_from
         ,p_cur_date_to);
fetch c_cwk_cur_nh into l_cur_nh;
if c_cwk_cur_nh%NOTFOUND then
   close c_cwk_cur_nh;
end if;

return (l_cur_nh);

end if;

return (l_cur_nh);

end GetCurNHNew;


/*****************************************************
 Function	: GetOrgAliasName
 Description	: This function returns alias name for
			  for Organization in
			  hr_organization_information
			  else returns name from
			  hr_organization_units
 Inputs 		: Organization_id
			  Report Date
 Output 		: Organization Name

 ****************************************************/
Function GetOrgAliasName
	(P_ORGANIZATION_ID	IN NUMBER,
	 P_REPORT_DATE		IN DATE)
RETURN VARCHAR2 IS

cursor c_org_alias_name is
select substr(org_information1,1,60)
from hr_organization_information
where organization_id = P_ORGANIZATION_ID
and org_information_context = 'Organization Name Alias'
and P_REPORT_DATE between
	nvl(fnd_date.canonical_to_date(org_information3),hr_api.g_sot)
	and nvl(fnd_date.canonical_to_date(org_information4),hr_api.g_eot);

cursor c_org_name is
select name
from hr_organization_units
where organization_id = P_ORGANIZATION_ID
and P_REPORT_DATE between  date_from and
		nvl(date_to,to_date('31/12/4712','DD/MM/YYYY'));

l_org_alias_name	varchar2(240);

BEGIN

open c_org_alias_name;
fetch c_org_alias_name into l_org_alias_name;

if c_org_alias_name%notfound
then close c_org_alias_name;

open c_org_name;
fetch c_org_name into l_org_alias_name;
close c_org_name;

end if;

return (l_org_alias_name);

end GetOrgAliasName;

/************************************************************
 Procedures to return meaningful error messages
*************************************************************/

PROCEDURE Raise_FF_Not_Exist
( p_formula_id        in number  )
IS
BEGIN
Fnd_Message.Set_Name('HRI', 'HR_BIS_FF_NOT_EXIST');
raise ff_not_exist;
END Raise_FF_Not_Exist;



PROCEDURE Raise_FF_Not_Compiled
( p_formula_id    in Number )
IS
cursor fast_formula_csr is
select formula_name
from   ff_formulas_f
where  formula_id = p_formula_id;

l_formula_name ff_formulas_f.formula_name%type      := null;
BEGIN
open  fast_formula_csr;
fetch fast_formula_csr into l_formula_name;
close fast_formula_csr;

Fnd_Message.Set_Name('HRI', 'HR_BIS_FF_NOT_COMPILED');
Fnd_Message.Set_Token('FORMULA', l_formula_name, FALSE);

raise ff_not_compiled;
END Raise_FF_Not_Compiled;

/************************************************************
 Function       : GetFormulaTypeID
 Inputs         : Formula Type Name
 Outputs        : Formula_Type_ID
 ************************************************************/

FUNCTION GetFormulaTypeID
  (p_formula_type_name       IN VARCHAR2)
RETURN NUMBER IS

cursor formulatypeid
is
   select formula_type_id
   from   ff_formula_types
   where  upper(formula_type_name) = upper(p_formula_type_name);

l_formula_type_id      NUMBER;

BEGIN

--   dbms_output.put_line('GetFormulaTypeID');

   open formulatypeid;
   fetch formulatypeid into l_formula_type_id;
      if formulatypeid%notfound
      then
      hr_utility.set_message(800,'PER_289164_INVAL_FORMULA_TYPE');
      hr_utility.set_message_token('FORMULA_TYPE', p_formula_type_name);
      hr_utility.raise_error;
      end if;
      close formulatypeid;
   return l_formula_type_id;

END GetFormulaTypeID;

/************************************************************
 Function  	: GetFormulaID
 Inputs		: Business Group Id
                  Formula Name
                  Formula Type
 Outputs 	: Formula Id
 Logic          : Checks for the formula and if it does not find it
                  looks for Formula Name ||'_TEMPLATE'
 ************************************************************/

FUNCTION GetFormulaID
  (p_business_group_id     IN NUMBER
  ,p_formula_name          IN VARCHAR2
  ,p_formula_type          IN VARCHAR2 )
  RETURN NUMBER IS

  l_formula_id          NUMBER;

CURSOR c_formula
IS
   SELECT formula_id
   FROM   ff_formulas_f
   WHERE  business_group_id+0 = p_business_group_id
   AND    SYSDATE BETWEEN effective_start_date AND effective_end_date
   AND    formula_name        = p_formula_name
   AND    formula_type_id
               = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID(p_formula_type);

CURSOR c_tmplt_formula
IS
   SELECT formula_id
   FROM   ff_formulas_f
   WHERE  business_group_id+0 is null
   AND    SYSDATE BETWEEN effective_start_date AND effective_end_date
   AND    formula_name = p_formula_name||'_TEMPLATE'
   AND    formula_type_id
               = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID(p_formula_type);

BEGIN

   -- Look for a customer formula

   OPEN  c_formula;

   FETCH c_formula INTO l_formula_id;

   -- If a customer formula does not exist

   IF (c_formula%NOTFOUND OR c_formula%NOTFOUND IS NULL) THEN

   CLOSE c_formula;

   -- Look for the template formula

   OPEN c_tmplt_formula;

   FETCH c_tmplt_formula INTO l_formula_id;

      -- If the template formula does not exist

      IF (c_tmplt_formula%NOTFOUND OR
          c_tmplt_formula%NOTFOUND IS NULL) THEN

      CLOSE c_tmplt_formula;

   -- Raise an error

      raise_ff_not_exist(0);

      ELSE

      CLOSE c_tmplt_formula;

      END IF;

   ELSE

   CLOSE c_formula;

   END IF;

RETURN l_formula_id;

END GetFormulaID;

/************************************************************
 Function  	: HeadCountForCWK
 Inputs		: N/A
 Outputs 	: Y or N
 Logic          : Checks Table pay_action_parameters  if data
                  has been migrated to using CWK. This is done by Users.
 ************************************************************/

FUNCTION HeadCountForCWK
  RETURN VARCHAR2 IS

  l_profile_value          VARCHAR2(1);

BEGIN

  l_profile_value := nvl(fnd_profile.value('HR_HEADCOUNT_FOR_CWK'),'N');

  RETURN l_profile_value;

END HeadCountForCWK;


END HR_PERSON_FLEX_LOGIC;

/
