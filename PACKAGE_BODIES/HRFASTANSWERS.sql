--------------------------------------------------------
--  DDL for Package Body HRFASTANSWERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRFASTANSWERS" AS
/* $Header: hrfstans.pkb 115.26 2004/06/17 23:16:15 prasharm ship $ */
--
-- Package Globals
--
G_BUSINESS_GROUP_ID 		number;
G_ORG_STRUCTURE_VERSION_ID 	number;

--
type OrgRecType is record
  ( organization_id_group  Number
  , organization_id_child  Number );
--
type OrgTabType is table of OrgRecType
  index by Binary_Integer;
--
type OrgIndType is table of Number
  index by Binary_Integer;
--
---------------------------------------------------------------------------
--
OrgTable		OrgTabType;
OrgIndex		OrgIndType;
LeavingReasons	LeavingReasonsType;
--
---------------------------------------------------------------------------
-- Private function to add an Organization pair
-- to the OrgTable and OrgIndex PL/SQL tables
procedure Add_Org
  ( p_org_id_group  in Number
  , p_org_id_child  in Number  )
is
  l_index  Number  := nvl(OrgTable.Last,0) + 1;
--
begin
  OrgTable(l_index).organization_id_group := p_org_id_group;
  OrgTable(l_index).organization_id_child := p_org_id_child;
--
  if (not OrgIndex.Exists(p_org_id_group))
  then
    OrgIndex(p_org_id_group) := l_index;
  end if;
end Add_Org;
--
---------------------------------------------------------------------------
-- Private function to determine whether a specified
-- Organization pair exists in the OrgTable table
function Find_Org
  ( p_org_id_group  in Number
  , p_org_id_child  in Number  )
return Number is
  l_found  Boolean  := FALSE;
  l_index  Number;
--
begin
  if (OrgIndex.Exists(p_org_id_group))
  then
    l_index := OrgIndex(p_org_id_group);
--
    loop
      if (OrgTable(l_index).organization_id_child = p_org_id_child)
      then
        l_found := TRUE;
      end if;
--
      exit when (l_index = OrgTable.Last) or (l_found);
      l_index := OrgTable.Next(l_index);
--
      exit when (OrgTable(l_index).organization_id_group <> p_org_id_group);
    end loop;
  end if;
--
  if (l_found)
  then
    return(1);
  else
    return(0);
  end if;

exception
  when Others then
    return(0);

end Find_Org;
--
---------------------------------------------------------------------------
-- Private function to get the ID of the BIS Organization Hierarchy to
-- to be used in reporting. This can be set by the System Administrator
-- using the profile option "HR:BIS Reporting Hierarchy"
--
-- 17-Jun-1999 (BG)
-- Altered to check for existence of Profile Option first. If not found
-- or Profile not set, we fetch the Organization Structure ID from the
-- Security Profile associated with the User/Resp/Appl/SecGroup.
--
function GetReportingHierarchy return Number is

    cursor c_struct
      ( cp_bus_id  Number
      , cp_str_id  Number )
    is
      select ost.organization_structure_id
      from   per_organization_structures 	ost
      where  ost.organization_structure_id 	= cp_str_id
      and    ost.business_group_id         	= cp_bus_id;

    cursor c_sp_bureau
      ( cp_user_id  Number
      , cp_resp_id  Number
      , cp_appl_id  Number
      , cp_secg_id  Number )
    is
      select spr.view_all_organizations_flag
      ,      spr.organization_structure_id
      from   per_security_profiles 		spr
      ,      per_sec_profile_assignments 	spa
      where  spr.security_profile_id           = spa.security_profile_id
      and    spa.user_id                       = cp_user_id
      and    spa.responsibility_id             = cp_resp_id
      and    spa.responsibility_application_id = cp_appl_id
      and    spa.security_group_id             = cp_secg_id;

-- Cursor added by S.Bhattal, 19-OCT-99, 115.9

    cursor c_sp_non_bureau
	( cp_security_profile_id	number )
    is
	select	 view_all_organizations_flag
		,organization_structure_id
	from	per_security_profiles
	where	security_profile_id	= cp_security_profile_id;

    cursor c_primary
      ( cp_bus_id  Number )
    is
      select ost.organization_structure_id
      from   per_organization_structures	ost
      where  ost.business_group_id      	= cp_bus_id
      and    ost.primary_structure_flag 	= 'Y';

    l_all_org			Varchar2(80);
    l_bus_id			Number		:= null;
    l_enable_sg			varchar2(1);
    l_security_profile_id	per_security_profiles.security_profile_id%type;
    l_str_id			Number		:= null;

    l_user_id	  		Number  := FND_Global.User_Id;
    l_resp_id  			Number  := FND_Global.Resp_Id;
    l_appl_id  			Number  := FND_Global.Resp_Appl_Id;
    l_secg_id  			Number	:= FND_Global.Security_Group_Id;

begin

  -- bug 2968520;
  l_bus_id := hr_bis.get_sec_profile_bg_id;

/************************************************************************
    1. Get org hierarchy from BIS Reporting Hierarchy profile option
	(for customers who have upgraded from BIS 1.2 to BIS 11i)
************************************************************************/

  if (FND_Profile.Value('HR_BIS_REPORTING_HIERARCHY') is not null) then

    l_str_id  := to_number( FND_Profile.Value('HR_BIS_REPORTING_HIERARCHY') );

    -- Check to see if Structure still exists
    if (l_str_id is not null) then

      open c_struct (l_bus_id, l_str_id);
      fetch c_struct into l_str_id;

      if (c_struct%notfound) then
        l_str_id := null;
      end if;

      close c_struct;
    end if;

  end if;

/************************************************************************
    2. Get org hierarchy from the appropriate Security Profile.

       If the customer is not a bureau, get the security profile from
       the system profile option.

       If the customer is a bureau, get the security profile using their
       login details (including the security group).
************************************************************************/

  if (l_str_id is null) then

    l_enable_sg := fnd_profile.value('ENABLE_SECURITY_GROUPS');

    if (l_enable_sg = 'N') then

-- Not a bureau, i.e. a regular customer

      l_security_profile_id := fnd_profile.value('PER_SECURITY_PROFILE_ID');

      open c_sp_non_bureau( l_security_profile_id );

      fetch c_sp_non_bureau into l_all_org, l_str_id;

      if (c_sp_non_bureau%notfound) or (l_all_org='Y')then
        l_str_id := null;
      end if;

      close c_sp_non_bureau;

    elsif (l_enable_sg = 'Y') then

-- A bureau with multiple Security Groups per responsibility

      open c_sp_bureau( l_user_id, l_resp_id, l_appl_id, l_secg_id);

      fetch c_sp_bureau into l_all_org, l_str_id;

      if (c_sp_bureau%notfound) or (l_all_org='Y') then
        l_str_id := null;
      end if;

      close c_sp_bureau;
    end if;

  end if;

/***************************************************************************
    3. Get org hierarchy from the primary hierarchy for the Business Group
***************************************************************************/

  if (l_str_id is null) then

      open c_primary (l_bus_id);
      fetch c_primary into l_str_id;
      close c_primary;

  end if;

  return (l_str_id);
end;

---------------------------------------------------------------------------
--
FUNCTION GetBudgetValue
  ( p_budget_metric_formula_id  IN NUMBER
  , p_assignment_id		          IN NUMBER
  , p_effective_date	          IN DATE
  , p_session_date	          	IN DATE)
RETURN NUMBER IS

  l_budget_value		number;
  l_inputs		ff_exec.inputs_t;
  l_outputs		ff_exec.outputs_t;

BEGIN
  -- Initialise the Inputs and  Outputs tables
  FF_Exec.Init_Formula
    ( p_budget_metric_formula_id
	  , p_session_date
  	, l_inputs
	  , l_outputs );

  if (l_inputs.first is not null)
  and (l_inputs.last is not null)
  then
    -- Set up context values for the formula
    for i in l_inputs.first..l_inputs.last loop

      if l_inputs(i).name = 'DATE_EARNED' then
        l_inputs(i).value := FND_Date.Date_To_Canonical (p_effective_date);

      elsif l_inputs(i).name = 'ASSIGNMENT_ID' then
        l_inputs(i).value := p_assignment_id;
      end if;
    end loop;
  end if;

  -- Run the formula
  FF_Exec.Run_Formula (l_inputs, l_outputs);

  -- Get the result
  l_budget_value := to_number( l_outputs(l_outputs.first).value );

  return (l_budget_value);

EXCEPTION
  -- Changed so it raises an exception and appropriate error message if
  -- the fast formula fails to run (usually due to not being compiled).
  -- Previously the function just returned zero.
  -- mjandrew - 28-JUN-2000 Bug #1323212
  when Others then
    Raise_FF_Not_compiled( p_budget_metric_formula_id );

END GetBudgetValue;


FUNCTION GetBudgetValue
  ( p_budget_metric		IN VARCHAR2
  , p_assignment_id		IN NUMBER
  , p_session_date		IN DATE		default sysdate )
RETURN NUMBER IS

  cursor c_budget_value is
    select	value
    from	  per_assignment_budget_values_f
    where	  assignment_id	= p_assignment_id
    and	    unit = p_budget_metric
    and     p_session_date between effective_start_date and effective_end_date;

  l_budget_value  Number  := null;

BEGIN
  open c_budget_value;
  fetch c_budget_value into l_budget_value;

  if (c_budget_value%notfound)
  then
    l_budget_value := null;
  end if;

  close c_budget_value;

  return l_budget_value;

END GetBudgetValue;


FUNCTION GetBudgetValue
  ( p_budget_metric_formula_id  IN NUMBER
  , p_budget_metric		          IN VARCHAR2
  , p_assignment_id		          IN NUMBER
  , p_effective_date	          IN DATE
  , p_session_date		          IN DATE )
RETURN NUMBER IS

  l_metric_value  Number;

BEGIN
  -- First check Assignment Budget Values table
  l_metric_value := GetBudgetValue
    ( p_budget_metric => p_budget_metric
    , p_assignment_id => p_assignment_id
    , p_session_date  => p_effective_date );

  if (l_metric_value is null)
  then
    -- There is no ABV value in table, so try FastFormula
    if (p_budget_metric_formula_id is not null)
    then
      -- Execute FastFormula
      l_metric_value := GetBudgetValue
        ( p_budget_metric_formula_id => p_budget_metric_formula_id
        , p_assignment_id            => p_assignment_id
        , p_effective_date           => p_effective_date
        , p_session_date             => p_session_date );

    else
      -- Changed so it raises an exception and appropriate error message if
      -- the fast formula does not exist, and no ABV exists for the assignment.
      -- Previously the function just returned zero by setting l_metric_value to 0.
      -- mjandrew - 28-JUN-2000 Bug #1323212
      Raise_FF_Not_exist( p_budget_metric );
    end if;
  end if;

  return l_metric_value;

END GetBudgetValue;
---------------------------------------------------------------------------
--
FUNCTION GetUtilHours(
 p_formula_id                   IN NUMBER
,p_assignment_id                IN NUMBER
,p_effective_date               IN DATE
,p_session_date                 IN DATE
) RETURN NUMBER IS
--
l_hours_value           number;
l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;
--
BEGIN
--
-- Initialise the Inputs and  Outputs tables
  ff_exec.init_formula(  p_formula_id
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
     for i in l_inputs.first..l_inputs.last loop
--
       if l_inputs(i).name = 'DATE_EARNED' then
         l_inputs(i).value := FND_Date.Date_To_Canonical (p_effective_date);
--
       elsif l_inputs(i).name = 'ASSIGNMENT_ID' then
         l_inputs(i).value := p_assignment_id;
       end if;
--
     end loop;
--
  end if;
--
-- Run the formula
  ff_exec.run_formula( l_inputs, l_outputs, FALSE );
--
-- Get the result
  l_hours_value := to_number( l_outputs(l_outputs.first).value );
--
    return( l_hours_value );
--
EXCEPTION
  when others then
    return(0);
END GetUtilHours;
--
---------------------------------------------------------------------------
--
FUNCTION Get_Hours_Worked(
 p_assign_id                    IN NUMBER
,p_earned_date                  IN DATE
,p_multiple                     IN NUMBER
) RETURN NUMBER IS
--
  l_hours_worked        number;
--
begin
--
/* 115.22 - Added to_char around p_multiple */
/*Bug 3658456: Rewritten the SQL to get l_hours_worked*/
  select sum(ev.screen_entry_value)
  into l_hours_worked
  from  pay_element_entry_values_f ev,
        pay_element_entries_f ee
  where ev.element_entry_id = ee.element_entry_id and
        ee.assignment_id = p_assign_id and
        (ev.input_value_id,ee.element_link_id) in
        ( select iv.input_value_id,el.element_link_id
          from pay_element_types_f et,
               pay_input_values_f iv,
               pay_element_links_f el
          where iv.name = 'Hours' and
                et.element_name = 'Overtime' and
                iv.element_type_id = et.element_type_id and
                et.element_type_id = el.element_type_id and
                p_earned_date between et.effective_start_date and et.effective_end_date and
                p_earned_date between iv.effective_start_date and iv.effective_end_date and
                p_earned_date between el.effective_start_date and el.effective_end_date
        ) and
        p_earned_date between ee.effective_start_date and ee.effective_end_date and
        exists (select null
                from pay_element_entry_values_f ev2,
                     pay_element_entries_f ee2
                where ev2.element_entry_id = ee2.element_entry_id and
                      ee2.assignment_id = p_assign_id and
                      ev2.screen_entry_value = to_char(p_multiple) and
                      ev2.element_entry_id = ev.element_entry_id and
                      (ev2.input_value_id,ee2.element_link_id) in
                      ( select iv2.input_value_id,el2.element_link_id
                        from pay_element_types_f et2,
                             pay_input_values_f iv2,
                             pay_element_links_f el2
                        where iv2.element_type_id = et2.element_type_id and
                              et2.element_type_id = el2.element_type_id and
                              iv2.name = 'Multiple' and
                              et2.element_name = 'Overtime' and
                              p_earned_date between et2.effective_start_date and et2.effective_end_date and
                              p_earned_date between iv2.effective_start_date and iv2.effective_end_date and
                              p_earned_date between el2.effective_start_date and el2.effective_end_date
                      ) and
                      p_earned_date between ee2.effective_start_date and  ee2.effective_end_date
                );
--
  return (l_hours_worked);
--
EXCEPTION
  when others then
    return(0);
END Get_Hours_Worked;

PROCEDURE GetAssignmentCategory(
 p_org_param_id        IN   NUMBER
,p_assignment_id		   IN   NUMBER
,p_period_start_date	 IN	  DATE
,p_period_end_date		 IN   DATE
,p_top_org             IN   NUMBER
,p_movement_type		   IN   VARCHAR2
,p_assignment_category OUT NOCOPY   VARCHAR2
,p_leaving_reason      OUT  NOCOPY  VARCHAR2
,p_service_band	    	 OUT NOCOPY 	VARCHAR2
) IS
--
cursor asg_csr is
select ast.per_system_status status
,      asg.effective_start_date
,      asg.effective_end_date
,      asg.organization_id
from	 per_assignment_status_types ast
,      per_all_assignments_f asg
where	 asg.assignment_status_type_id = ast.assignment_status_type_id
and	   asg.assignment_id = p_assignment_id
and	   asg.effective_start_date	<= p_period_end_date
order by asg.effective_start_date desc;
--
cursor hire_date_csr is
select per.start_date
from	 per_all_people_f		per
,      per_all_assignments_f		asg
where	asg.person_id	= per.person_id
and	p_period_end_date between per.effective_start_date and per.effective_end_date
and	p_period_end_date between asg.effective_start_date and asg.effective_end_date
and	asg.assignment_id	= p_assignment_id;
--
cursor term_date_csr is
select pos.actual_termination_date
,      pos.leaving_reason
,      decode( pos.actual_termination_date,
      		null, 'Not Terminated',
      		decode( floor(
            months_between( pos.actual_termination_date, pos.date_start ) / 12 ),
                  0, '<1 Year',
            			1, '1-3 Years',
            			2, '1-3 Years',
      			      3, '3-5 Years',
             			4, '3-5 Years',
			            '5 Years+'))			service_band
from	 per_periods_of_service		pos
,      per_all_assignments_f		asg
where	 asg.period_of_service_id	= pos.period_of_service_id
and	   p_period_start_date-1 between asg.effective_start_date	and asg.effective_end_date
and	asg.assignment_id = p_assignment_id;
--
asg_rec		     asg_csr%rowtype;
hire_date_rec	 hire_date_csr%rowtype;
term_date_rec	 term_date_csr%rowtype;
--
l_assignment_category	varchar2(30);
--
l_first_time		  boolean := true;
l_hire_date		    date;
l_start_date		  date;
l_status		      varchar2(20);
l_term_date		    date;
l_leaving_reason 	varchar2(30);
--
BEGIN
--
  p_leaving_reason := null;
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
      elsif HrBisOrgParams.OrgInHierarchy
        ( p_org_param_id
        , p_top_org
        , asg_rec.organization_id ) <>1
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
      if l_start_date = l_hire_date then
        l_assignment_category := 'NEW_HIRE';
      else
        l_assignment_category := 'START';
      end if;
--
    end if;
--
    p_assignment_category	:= l_assignment_category;
    p_leaving_reason		:= null;
    p_service_band		:= null;
--
  elsif p_movement_type = 'OUT' then

-- If p_movement_type = 'OUT', the employee assignment is Active at
-- Period Start Date minus 1 day, and is not Active at Period End Date.

-- Determine Actual Termination Date
    for term_date_rec in term_date_csr loop
      l_term_date 	:= term_date_rec.actual_termination_date;
      l_leaving_reason 	:= term_date_rec.leaving_reason;
      p_service_band	:= term_date_rec.service_band;
    end loop;
--
    for asg_rec in asg_csr loop
--
      if ( asg_rec.status = 'ACTIVE_ASSIGN' ) and
         ( HrBisOrgParams.OrgInHierarchy
           ( p_org_param_id
           , p_top_org
           , asg_rec.organization_id) = 1 )
      then

-- When an assignment's status is changed to 'End', all that happens is the
-- assignment row with status Active is given an Effective End Date. No new
-- rows are created, the status End is not stored on the database anywhere.
-- Consequently, the IF test above is satisfied the 1st time through the loop.

        if ( l_first_time = true ) then

          if l_term_date is null then

-- Assignment has been given an End Date

	          p_leaving_reason := 'NOTSEPARATED';
            p_assignment_category := 'ENDED';
            exit;
          else

-- Employee terminated with Actual Termination Date = Final Processing Date.
-- In this case, no assignment row with status TERM_ASSIGN is created.

            p_leaving_reason := l_leaving_reason;
            p_assignment_category :=  'SEPARATED';
            exit;
          end if;

        elsif ( l_status = 'TERM_ASSIGN' ) then
--
          p_leaving_reason := l_leaving_reason;
          p_assignment_category :=  'SEPARATED';
          exit;
--
        elsif ( l_status = 'SUSP_ASSIGN' ) then
	        p_leaving_reason := 'NOTSEPARATED';
          p_assignment_category :=  'SUSPENDED';
          exit;
--
        else
	        p_leaving_reason := 'NOTSEPARATED';
          p_assignment_category := 'TRANSFER_OUT';
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

END GetAssignmentCategory;

-- Overloaded version of GetAssignmentCategory,
-- so that Leaving Reason can be ignored

FUNCTION GetAssignmentCategory
  ( p_org_param_id      IN NUMBER
  , p_assignment_id		  IN NUMBER
  , p_period_start_date	IN DATE
  , p_period_end_date		IN DATE
  , p_top_org           IN NUMBER
  , p_movement_type		  IN VARCHAR2 )
RETURN VARCHAR2 IS
--
  l_assignment_category  varchar2(30);
  l_leaving_reason 		   varchar2(30);
  l_service_band		     varchar2(30);
--
BEGIN
--
   HrFastAnswers.GetAssignmentCategory
     ( p_org_param_id        => p_org_param_id
     , p_assignment_id 	     => p_assignment_id
     , p_period_start_date   => p_period_start_date
     , p_period_end_date     => p_period_end_date
     , p_top_org             => p_top_org
     , p_movement_type 	     => p_movement_type
     , p_assignment_category => l_assignment_category
     , p_leaving_reason 	   => l_leaving_reason
     , p_service_band		     => l_service_band);
--
   return (l_assignment_category);
--
END GetAssignmentCategory;

--
-- Overloaded version that accepts an organization_id instead of
-- an org_param_id and uses the first SINR org_param_id for that
-- organization_id it can find.
--
FUNCTION GetAssignmentCategory
  ( p_assignment_id     IN NUMBER
  , p_period_start_date IN DATE
  , p_period_end_date   IN DATE
  , p_top_org           IN NUMBER
  , p_movement_type     IN VARCHAR2 )
RETURN VARCHAR2 IS
--
  l_assignment_category  varchar2(30);
  l_leaving_reason       varchar2(30);
  l_service_band         varchar2(30);
--
  l_org_param_id         number;
--
-- This cursor will select the first org_param_id it finds for the organization
-- regardless of organization_structure_id
--
cursor c_org_param
      ( cp_organization_id  Number )
    is
      select org_param_id
      from   hri_org_params
      where  organization_id = cp_organization_id
      and    organization_process = 'SINR';
--
BEGIN
--
  open  c_org_param(p_top_org);
  fetch c_org_param into l_org_param_id;
  close c_org_param;
--
   HrFastAnswers.GetAssignmentCategory
     ( p_org_param_id        => l_org_param_id
     , p_assignment_id       => p_assignment_id
     , p_period_start_date   => p_period_start_date
     , p_period_end_date     => p_period_end_date
     , p_top_org             => p_top_org
     , p_movement_type       => p_movement_type
     , p_assignment_category => l_assignment_category
     , p_leaving_reason      => l_leaving_reason
     , p_service_band        => l_service_band);
--
   return (l_assignment_category);
--
END GetAssignmentCategory;
--

FUNCTION GetLeavingReason
  ( p_org_param_id      IN NUMBER
  , p_assignment_id		  IN NUMBER
  , p_period_start_date IN DATE
  , p_period_end_date		IN DATE
  , p_top_org           IN NUMBER
  , p_movement_type		  IN VARCHAR2 )
RETURN VARCHAR2 IS
--
  l_assignment_category	 varchar2(30);
  l_leaving_reason 		   varchar2(30);
  l_service_band		     varchar2(30);
--
BEGIN
--
  HrFastAnswers.GetAssignmentCategory
    ( p_org_param_id        => p_org_param_id
    , p_assignment_id     	=> p_assignment_id
	  , p_period_start_date	  => p_period_start_date
    , p_period_end_date 	  => p_period_end_date
    , p_top_org             => p_top_org
    , p_movement_type       => p_movement_type
	  , p_assignment_category	=> l_assignment_category
    , p_leaving_reason      => l_leaving_reason
	  , p_service_band		    => l_service_band	);
--
 RETURN (l_leaving_reason);
--
END GetLeavingReason;

FUNCTION GetLeavingReasonMeaning
  ( p_org_param_id      IN NUMBER
  , p_assignment_id		  IN NUMBER
  , p_period_start_date	IN DATE
  , p_period_end_date		IN DATE
  , p_top_org           IN NUMBER
  , p_movement_type		  IN VARCHAR2)
RETURN VARCHAR2 IS
--
  l_assignment_category		varchar2(30);
  l_leaving_reason 		varchar2(30);
  l_leaving_reason_meaning      varchar2(2000);
  l_service_band		varchar2(30);
--
  cursor get_meaning_csr( p_leaving_reason varchar2 ) is
  select meaning
  from   hr_lookups
  where  lookup_type = 'LEAV_REAS'
  and    lookup_code = p_leaving_reason;
--
  get_meaning_rec	get_meaning_csr%rowtype;
--
BEGIN
--
  HrFastAnswers.GetAssignmentCategory
    ( p_org_param_id        => p_org_param_id
    , p_assignment_id       => p_assignment_id
	  , p_period_start_date	  => p_period_start_date
    , p_period_end_date 	  => p_period_end_date
    , p_top_org             => p_top_org
    , p_movement_type 	    => p_movement_type
	  , p_assignment_category	=> l_assignment_category
    , p_leaving_reason      => l_leaving_reason
	  , p_service_band		    => l_service_band	);
--
  if (l_leaving_reason is null) then
    l_leaving_reason_meaning := fnd_message.get_string('HRI','HR_BIS_UNKNOWN');
  elsif
     (l_leaving_reason = 'NOTSEPARATED') then
--
     l_leaving_reason_meaning := 'NotSeparated';
  else
--
    for get_meaning_rec in get_meaning_csr(l_leaving_reason) loop
      l_leaving_reason_meaning := get_meaning_rec.meaning;
    end loop;
--
  end if;
--
 RETURN (l_leaving_reason_meaning);
--
END GetLeavingReasonMeaning;

FUNCTION Get_Service_Band_Name
  ( p_org_param_id      IN NUMBER
  , p_assignment_id		  IN NUMBER
  , p_period_start_date	IN DATE
  , p_period_end_date		IN DATE
  , p_top_org           IN NUMBER
  , p_movement_type		  IN VARCHAR2)
RETURN VARCHAR2 IS
--
  l_assignment_category	 varchar2(30);
  l_leaving_reason 		   varchar2(30);
  l_service_band		     varchar2(2000);
--
BEGIN
--
  HrFastAnswers.GetAssignmentCategory
    ( p_org_param_id        => p_org_param_id
    , p_assignment_id 	    => p_assignment_id
    , p_period_start_date	  => p_period_start_date
    , p_period_end_date 	  => p_period_end_date
    , p_top_org             => p_top_org
    , p_movement_type     	=> p_movement_type
	  , p_assignment_category	=> l_assignment_category
    , p_leaving_reason 	    => l_leaving_reason
	  , p_service_band		    => l_service_band	);

  l_service_band := substr(l_service_band,1,1);
--
  if(l_service_band = '<') then
    l_service_band := fnd_message.get_string('HRI','HR_BIS_LESS_THAN_1_YEAR');
  elsif(l_service_band = '1') then
    l_service_band := fnd_message.get_string('HRI','HR_BIS_1_TO_3_YEARS');
  elsif(l_service_band = '3') then
    l_service_band := fnd_message.get_string('HRI','HR_BIS_3_TO_5_YEARS');
  elsif(l_service_band = '5') then
    l_service_band := fnd_message.get_string('HRI','HR_BIS_5_YEARS+');
  end if;
--
  RETURN (l_service_band);
--
END Get_Service_Band_Name;

FUNCTION Get_Service_Band_Order
  ( p_org_param_id      IN NUMBER
  , p_assignment_id		  IN NUMBER
  , p_period_start_date	IN DATE
  , p_period_end_date		IN DATE
  , p_top_org           IN NUMBER
  , p_movement_type		  IN VARCHAR2)
RETURN NUMBER IS
--
  l_assignment_category	 varchar2(30);
  l_leaving_reason 		   varchar2(30);
  l_service_band		     varchar2(30);
--
BEGIN
--
  HrFastAnswers.GetAssignmentCategory
    ( p_org_param_id        => p_org_param_id
    , p_assignment_id 	    => p_assignment_id
	  , p_period_start_date	  => p_period_start_date
    , p_period_end_date 	  => p_period_end_date
    , p_top_org             => p_top_org
    , p_movement_type 	    => p_movement_type
	  , p_assignment_category	=> l_assignment_category
    , p_leaving_reason 	    => l_leaving_reason
	  , p_service_band		    => l_service_band	);

	  l_service_band := substr(l_service_band,1,1);
--
  if(l_service_band = '<') then
    RETURN (1);
  elsif(l_service_band = '1') then
    RETURN (2);
  elsif(l_service_band = '3') then
    RETURN (3);
  elsif(l_service_band = '5') then
    RETURN (4);
  else
    RETURN (0);
  end if;
--
END Get_Service_Band_Order;

procedure LoadOrgHierarchy
  ( p_organization_id        IN   Number
  , p_org_struct_version_id  IN   Number )
is
  l_org_list  Varchar2(2000);
--
begin
  LoadOrgHierarchy
    ( p_organization_id        => p_organization_id
    , p_org_struct_version_id  => p_org_struct_version_id
    , p_organization_process   => 'ISNR'
    , p_org_list               => l_org_list );
end LoadOrgHierarchy;
--
procedure LoadOrgHierarchy
  ( p_organization_id        IN   Number )
is
begin
  -- Clear both PL/SQL tables
  OrgTable.Delete;
  OrgIndex.Delete;

  -- Add single Organization to tables
  Add_Org (p_organization_id, p_organization_id);

end LoadOrgHierarchy;
--
procedure LoadOrgHierarchy
  ( p_organization_id        IN   Number
  , p_org_struct_version_id  IN   Number
  , p_organization_process   IN   Varchar2
  , p_org_list               OUT NOCOPY   Varchar2 )
is
  cursor c_toporg
  is
    select ose.organization_id_parent
    from   per_org_structure_elements ose
    where  ose.org_structure_element_id = GetOrgStructElement;

  cursor c_main
    ( cp_organization_id           Number
    , cp_org_structure_version_id  Number
    , cp_organization_process      Varchar2 )
  is
    select TREE.organization_id_start
    from   hr_organization_units org
    ,     (select  ele.organization_id_parent organization_id_start
           from    per_org_structure_elements ele
           where   cp_organization_process in ('ISNR', 'ISRO')
           connect by prior ele.organization_id_child = ele.organization_id_parent
           and     ele.org_structure_version_id = cp_org_structure_version_id
           start with ele.organization_id_parent = cp_organization_id
           and     ele.org_structure_version_id = cp_org_structure_version_id) TREE
    where  TREE.organization_id_start = org.organization_id
    UNION
    select TREE.organization_id_start
    from   hr_organization_units org
    ,     (select  ele.organization_id_child organization_id_start
           from    per_org_structure_elements ele
           where   cp_organization_process in ('ISNR', 'ISRO')
           connect by prior ele.organization_id_child = ele.organization_id_parent
           and     ele.org_structure_version_id = cp_org_structure_version_id
           start with ele.organization_id_parent = cp_organization_id
           and     ele.org_structure_version_id = cp_org_structure_version_id) TREE
    where  TREE.organization_id_start = org.organization_id
    UNION
    select org.organization_id organization_id_start
    from   hr_organization_units org
    where  org.organization_id = cp_organization_id
    order by 1;
--
  cursor c_child
    ( cp_organization_id_start     Number
    , cp_org_structure_version_id  Number
    , cp_organization_process      Varchar2 )
  is
    select TREE.organization_id_group
    ,      TREE.organization_id_child
    from   hr_organization_units org
    ,     (select  cp_organization_id_start  organization_id_group
           ,       ele.organization_id_child organization_id_child
           from    per_org_structure_elements ele
           where   cp_organization_process in ('SIRO', 'ISRO')
           connect by prior ele.organization_id_child = ele.organization_id_parent
           and     ele.org_structure_version_id = cp_org_structure_version_id
           start with ele.organization_id_parent = cp_organization_id_start
           and     ele.org_structure_version_id = cp_org_structure_version_id) TREE
    where  TREE.organization_id_child = org.organization_id
    UNION
    select org.organization_id organization_id_group
    ,      org.organization_id organization_id_child
    from   hr_organization_units org
    where  org.organization_id = cp_organization_id_start
    order by 1,2;
--
  l_org_id  Number;
  l_process  Varchar2(4);
--
  l_first   Boolean;
  l_index   Number;
--
begin
  HR_Utility.Set_Location('Load Org Hierarchy '||p_organization_process,5);

  -- If Organization parameter is -1 this means "whole hierarachy"
  -- so we need to point the SQL to the top org
  if (p_organization_id = -1)
  then
    open c_toporg;
    fetch c_toporg into l_org_id;
    close c_toporg;
    l_process := 'ISNR';  -- ||substr(p_organization_process,3);

  else
    l_org_id  := p_organization_id;
    l_process := p_organization_process;
  end if;

  -- Clear both PL/SQL tables
  OrgTable.Delete;
  OrgIndex.Delete;

  -- Populate OrgTable and OrgIndex
  for r_main in c_main
    ( l_org_id, p_org_struct_version_id, l_process )
  loop
    for r_child in c_child
      ( r_main.organization_id_start, p_org_struct_version_id, l_process )
    loop
      Add_Org
        ( r_child.organization_id_group
        , r_child.organization_id_child );
    end loop;
  end loop;

  -- Determine lexical for use in Reports
  if (l_process in ('SIRO', 'ISRO'))
  then
    l_first := TRUE;
    l_index := OrgIndex.First;

    loop
      if (l_first)
      then
        p_org_list := 'in (' || to_char(l_index);
        l_first := FALSE;
      else
        p_org_list := p_org_list || ',' || to_char(l_index);
      end if;

      exit when (l_index = OrgIndex.Last);
      l_index := OrgIndex.Next(l_index);
    end loop;

    p_org_list := p_org_list || ')';

  else
    p_org_list := '= 0';

  end if;

end LoadOrgHierarchy;
--
---------------------------------------------------------------------------
--
function OrgInHierarchy
  ( p_organization_id  Number )
return Number is
begin
  return (Find_Org
    ( p_org_id_group => p_organization_id
    , p_org_id_child => p_organization_id ));
end OrgInHierarchy;
--

function OrgInHierarchy
  ( p_organization_id_group  Number
  , p_organization_id_child  Number )
return Number is
begin
  if (p_organization_id_group = -1)
  then
    return (Find_Org
      ( p_org_id_group => p_organization_id_child
      , p_org_id_child => p_organization_id_child ));
  else
    return (Find_Org
      ( p_org_id_group => p_organization_id_group
      , p_org_id_child => p_organization_id_child ));
  end if;
end OrgInHierarchy;
--
---------------------------------------------------------------------------
--
function GetOrgStructElement
return Number is

  -- This cursor finds the top element in the current version of the
  -- primary org hierarchy within the responsibilities business group
  --
  -- It can return >1 row, they all have the same ORGANIZATION_ID_PARENT
  -- therefore just use the 1st one;
  --
  cursor c_get_element_id
    ( cp_bus_id  Number
    , cp_str_id  Number )
  is
    select ose.org_structure_element_id
    from   per_organization_structures ost
    ,      per_org_structure_versions  osv
    ,      per_org_structure_elements  ose
    where  ost.business_group_id       = cp_bus_id
    and    ost.organization_structure_id = cp_str_id
    and    ost.organization_structure_id = osv.organization_structure_id
    and    osv.org_structure_version_id  = ose.org_structure_version_id
    and    trunc(sysdate) between nvl(osv.date_from,trunc(sysdate)) and nvl(osv.date_to,sysdate)
    and    not exists
             ( select null
               from   per_org_structure_elements ose2
               where  ose2.org_structure_version_id = osv.org_structure_version_id
               and    ose.organization_id_parent    = ose2.organization_id_child );

  l_business_group_id         Number := hr_bis.get_sec_profile_bg_id ;
  l_org_structure_id          Number := GetReportingHierarchy;
  l_org_structure_element_id  Number;

BEGIN
   if (nvl(l_business_group_id,-1) = -1)
   then
     l_org_structure_element_id := -1;

   else
     open c_get_element_id
       ( l_business_group_id
       , l_org_structure_id );

     fetch c_get_element_id into l_org_structure_element_id;
     close c_get_element_id;
   end if;

   return (l_org_structure_element_id);

exception
  when Others then
    return (-1);

END GetOrgStructElement;
--
---------------------------------------------------------------------------
--
function GetOrgStructVersion
return Number is

  -- This cursor finds the current version of the
  -- primary org hierarchy within the responsibilities business group
  --
  cursor c_get_version_id
    ( cp_bus_id  Number
    , cp_str_id  Number )
  is
    select osv.org_structure_version_id
    from   per_organization_structures ost
    ,      per_org_structure_versions  osv
    where  ost.business_group_id       = cp_bus_id
    and    ost.organization_structure_id = cp_str_id
    and    ost.organization_structure_id = osv.organization_structure_id
    and    trunc(sysdate) between nvl(osv.date_from,trunc(sysdate)) and nvl(osv.date_to,sysdate);

  l_business_group_id         Number := hr_bis.get_sec_profile_bg_id ;
  l_org_structure_id          Number := GetReportingHierarchy;
  l_org_structure_version_id  Number;

BEGIN
   if (nvl(l_business_group_id,-1) = -1)
   then
     l_org_structure_version_id := -1;

   else
     open c_get_version_id
       ( l_business_group_id
       , l_org_structure_id );

     fetch c_get_version_id into l_org_structure_version_id;
     close c_get_version_id;
   end if;

   return (l_org_structure_version_id);

exception
  when Others then
    return (-1);

END GetOrgStructVersion;
--
---------------------------------------------------------------------------
-- Initialize package globals for use in the report
----------------------------------------------------
PROCEDURE Initialize
  ( p_user_id                   IN  Number
  , p_resp_id                   IN  Number
  , p_resp_appl_id              IN  Number
  , p_business_group_id         OUT NOCOPY  Number
  , p_org_structure_version_id  OUT NOCOPY  Number
  , p_sec_group_id              IN  Number  default 0 )
is

  cursor c_org_structure_version
    ( cp_bus_id  Number
    , cp_str_id  Number )
  is
    select v.org_structure_version_id
    from   per_organization_structures s
    ,      per_org_structure_versions v
    where  s.business_group_id       = cp_bus_id
    and    s.organization_structure_id = cp_str_id
    and    s.organization_structure_id = v.organization_structure_id
    and    trunc(sysdate) between nvl(v.date_from,trunc(sysdate)) and nvl(v.date_to,sysdate);

  l_business_group_id         Number;
  l_org_structure_id          Number;
  l_org_structure_version_id  Number;

BEGIN
  FND_Global.Apps_Initialize
    ( user_id           => p_user_id
    , resp_id           => p_resp_id
    , resp_appl_id      => p_resp_appl_id
    , security_group_id => p_sec_group_id );

  -- bug 2968520
  l_business_group_id := hr_bis.get_sec_profile_bg_id;

  if (l_business_group_id is not null)
  then
    l_org_structure_id  := GetReportingHierarchy;

    open c_org_structure_version
      ( l_business_group_id
      , l_org_structure_id );
    fetch c_org_structure_version into l_org_structure_version_id;
    close c_org_structure_version;

    -- Set package globals
    g_business_group_id := l_business_group_id;
    g_org_structure_version_id := l_org_structure_version_id;

    -- Return values to report
    p_business_group_id := l_business_group_id;
    p_org_structure_version_id := l_org_structure_version_id;
  end if;

END Initialize;
--
---------------------------------------------------------------------------
--
PROCEDURE ClearLeavingReasons IS
  l_count	number;
BEGIN
--
-- Clear down global PL/SQL table
  for l_count in 1..9 loop
    HrFastAnswers.LeavingReasons(l_count) := '';
  end loop;
--
END ClearLeavingReasons;
--
---------------------------------------------------------------------------
--
FUNCTION GetLeavingReasons RETURN LeavingReasonsType IS
  l_leaving_reasons        LeavingReasonsType;
BEGIN
  l_leaving_reasons := HrFastAnswers.LeavingReasons;
  return( l_leaving_reasons );
END GetLeavingReasons;
--
---------------------------------------------------------------------------
--
PROCEDURE SetLeavingReasons(
 p_index	IN NUMBER
,p_value	IN VARCHAR2 ) IS
--
BEGIN
  HrFastAnswers.LeavingReasons( p_index ) := p_value;
END SetLeavingReasons;
--
---------------------------------------------------------------------------
FUNCTION get_poplist(p_select_statement VARCHAR2
                    ,p_parameter_list   VARCHAR2
                    ,p_parameter_name   VARCHAR2
                    ,p_parameter_value  VARCHAR2
                    ,p_report_name      VARCHAR2
                    ,p_report_link VARCHAR2) RETURN VARCHAR2 AS
l_poplist VARCHAR2(32767);
l_cursorID INTEGER;
l_new_select_statement VARCHAR2(2000);
--l_name VARCHAR2(80);
--l_code VARCHAR2(80);
--l_from VARCHAR2(2000);
l_point1 INTEGER;
l_point2 INTEGER;
l_length1 INTEGER;
l_code_out VARCHAR2(80);
l_name_out VARCHAR2(80);
l_dummy VARCHAR2(1);
--
l_parameters VARCHAR2(2000);
--
BEGIN
--
-- open the cursor
  l_cursorID:=DBMS_SQL.OPEN_CURSOR;
--
  l_new_select_statement:=p_select_statement;
--
  l_poplist:='<form><select name="'||p_parameter_name||
             '" onChange="window.location=form.'||p_parameter_name||
             '.options[form.'||p_parameter_name||'.selectedIndex].value" size=1>';
--
  l_point1:=instr(p_parameter_list,p_parameter_name);
  l_point2:=instr(p_parameter_list,'*',l_point1);
--
  l_parameters:=substr(p_parameter_list,0,l_point1-1)||substr(p_parameter_list,l_point2+1);
  l_parameters:=l_parameters||p_parameter_name||'=';
--
-- Parse the query
  DBMS_SQL.PARSE(l_cursorID,l_new_select_statement,dbms_sql.v7);
--
-- Define the outputs
  DBMS_SQL.DEFINE_COLUMN(l_cursorID,1,l_code_out,80);
  DBMS_SQL.DEFINE_COLUMN(l_cursorID,2,l_name_out,80);
--
-- Execute the query
  l_dummy:=DBMS_SQL.EXECUTE(l_cursorID);
--
-- Loop over the output rows, building our statement
  LOOP
    -- fetch the next row and check it exists
    IF (DBMS_SQL.FETCH_ROWS(l_cursorID)=0) THEN
      hr_utility.set_location('get poplist',10);
      EXIT;
    END IF;
--
    DBMS_SQL.COLUMN_VALUE(l_cursorID,1,l_code_out);
    DBMS_SQL.COLUMN_VALUE(l_cursorID,2,l_name_out);
--
    l_poplist:=l_poplist||'<option ';
--
    if(p_parameter_value=l_code_out) then
      l_poplist:=l_poplist||'SELECTED ';
    end if;
--
    l_poplist:=l_poplist||'value='||p_report_link||'OracleOASIS.RunReport?parameters='||l_parameters||l_code_out;
    l_poplist:=l_poplist||'*plsql_basepath='||p_report_link||'*paramform=no*';
    l_poplist:=l_poplist||fnd_global.local_chr(38)||'report='||p_report_name||'>'||l_name_out; /*changed for bug 3282860*/
--

--
  END LOOP;
--
  l_poplist:=l_poplist||'</select>
</form>';
--
  return l_poplist;
END get_poplist;
--
function business_group_id return NUMBER is
begin
  if(g_business_group_id is not null) then
    return(g_business_group_id);
  else
    return(-1);
  end if;
exception
when others then
return (-1);
end business_group_id;
--
--
function org_structure_version_id return NUMBER is
begin
  if(G_ORG_STRUCTURE_VERSION_ID is not null) then
    return(G_ORG_STRUCTURE_VERSION_ID);
  else
    return(-1);
  end if;
exception
when others then
return (-1);
end org_structure_version_id;
--
  function ConvertToHours
    ( p_formula_id      in Number
    , p_assignment_id   in Number
    , p_screen_value    in Varchar2
    , p_uom             in Varchar2
    , p_effective_date  in Date
    , p_session_date    in Date )
  return Number is
    k_seconds_per_hour  Constant Number  := 60*60;

    l_days     Number  := 0;
    l_hours    Number  := 0;
    l_seconds  Number  := 0;

    l_ff_inputs   FF_Exec.Inputs_t;
    l_ff_outputs  FF_Exec.Outputs_t;

  begin
    if (p_uom like 'H_DECIMAL%') or (p_uom = 'H_HH')
    then
      l_hours := to_number(p_screen_value);

    elsif (p_uom = 'H_HHMM')
    then
      l_seconds := to_number(to_char(to_date(p_screen_value,'HH:MI'),'SSSSS'));
      l_hours   := l_seconds / k_seconds_per_hour;

    elsif (p_uom = 'H_HHMMSS')
    then
      l_seconds := to_number(to_char(to_date(p_screen_value,'HH:MI:SS'),'SSSSS'));
      l_hours   := l_seconds / k_seconds_per_hour;

    elsif (p_uom in ('I','N','ND'))
    then
      l_days := to_number(p_screen_value);

      -- Initialise the Inputs and Outputs tables
      FF_Exec.Init_Formula
        ( p_formula_id     => p_formula_id
        , p_effective_date => p_session_date
        , p_inputs         => l_ff_inputs
        , p_outputs        => l_ff_outputs );

      -- Set up context values for the formula
      for i in l_ff_inputs.first .. l_ff_inputs.last
      loop

        if (l_ff_inputs(i).name = 'DATE_EARNED')
        then
          l_ff_inputs(i).value := FND_Date.Date_To_Canonical(p_effective_date);

        elsif (l_ff_inputs(i).name = 'ASSIGNMENT_ID')
        then
          l_ff_inputs(i).value := p_assignment_id;

        elsif (l_ff_inputs(i).name = 'DAYS_WORKED')
        then
          l_ff_inputs(i).value := l_days;

        end if;

      end loop;

      -- Run the formula and get the return value
      FF_Exec.Run_Formula
        ( p_inputs  => l_ff_inputs
        , p_outputs => l_ff_outputs);

      l_hours := to_number(l_ff_outputs(l_ff_outputs.first).value);

    else
      l_hours := 0;

    end if;

    return (l_hours);

  exception
    when others then
      return (0);

  end ConvertToHours;
--
  FUNCTION TrainingConvertDuration
    ( p_formula_id             In Number
    , p_from_duration          In Number
    , p_from_units             In Varchar2
    , p_to_units               In Varchar2
    , p_activity_version_name  In Varchar2
    , p_event_name             In Varchar2
    , p_session_date           In Date )
  RETURN NUMBER IS
    l_inputs		   FF_Exec.Inputs_T;
    l_outputs		   FF_Exec.Outputs_T;

  BEGIN
    -- Initialise the Inputs and  Outputs tables
    FF_Exec.Init_Formula
      ( p_formula_id
    	, p_session_date
    	, l_inputs
    	, l_outputs );

    if (l_inputs.first is not null)
    and (l_inputs.last is not null)
    then
      -- Set up context values for the formula
      for i in l_inputs.first..l_inputs.last loop

        if l_inputs(i).name = 'FROM_DURATION' then
          l_inputs(i).value := to_char(p_from_duration);

        elsif l_inputs(i).name = 'FROM_DURATION_UNITS' then
          l_inputs(i).value := p_from_units;

        elsif l_inputs(i).name = 'TO_DURATION_UNITS' then
          l_inputs(i).value := p_to_units;

        elsif l_inputs(i).name = 'ACTIVITY_VERSION_NAME' then
          l_inputs(i).value := p_activity_version_name;

        elsif l_inputs(i).name = 'EVENT_NAME' then
          l_inputs(i).value := p_event_name;
        end if;

      end loop;
    end if;

    -- Run the formula
    FF_Exec.Run_Formula (l_inputs, l_outputs);

    return (to_number(l_outputs(l_outputs.first).value));

  END TrainingConvertDuration;

-------------------------------------------------------------------------------
--  Function to return the correct Location_Id for the Revenue Model reports.
--  This function is called from package HrViewBy in HRIRPRT.pll
--
--  It determines the Location_Id by travelling up the following hierarchy;
--  1. Assignment Location
--  2. Position Location
--  3. Organization Location
--  4. Business Group Location
--
--  Rewritten by S.Bhattal, 05-JAN-2000, version 115.11, bug 1123310.
--  (as a result of bugs found during Release 11i system testing)
-------------------------------------------------------------------------------

  function GetLocationId
    ( p_level             IN Number
    , p_location_id       IN Number
    , p_position_id       IN Number
    , p_organization_id   IN Number
    , p_business_group_id IN Number )
  return number is

    cursor location_csr is
      select  country
      from    hr_locations
      where   location_id = p_location_id;

    cursor c_get_loc_pos is
      select  pos.location_id
             ,loc.country
      from    hr_locations		loc
             ,per_positions		pos
      where  pos.position_id = p_position_id
      and    pos.location_id = loc.location_id;

    cursor c_get_loc_org is
      select  org.location_id
             ,loc.country
      from    hr_locations		loc
             ,hr_organization_units	org
      where  org.organization_id = p_organization_id
      and    org.location_id     = loc.location_id;

    cursor c_get_loc_bus is
      select  bg.location_id
             ,loc.country
      from    hr_locations		loc
             ,per_business_groups	bg
      where  bg.business_group_id = p_business_group_id
      and    bg.location_id       = loc.location_id;

    l_country      hr_locations.country%type;
    l_location_id  hr_locations.location_id%type;
    l_region       hr_locations.attribute1%type;

    type RefCursorType is REF CURSOR;
    ref_csr            RefCursorType;

begin

  if p_level in (1,2) then	-- Geography level = 'Area' or 'Country'

    if (p_location_id is not null) then
      open location_csr;
      fetch location_csr into l_country;
      close location_csr;
    end if;

    if (l_country is not null) then
      l_location_id := p_location_id;
    else

      if (p_position_id is not null) then
        open c_get_loc_pos;
        fetch c_get_loc_pos into l_location_id, l_country;
        close c_get_loc_pos;
      end if;

      if (l_country is null) then

        if (p_organization_id is not null) then
          open c_get_loc_org;
          fetch c_get_loc_org into l_location_id, l_country;
          close c_get_loc_org;
        end if;

        if (l_country is null) then
          open c_get_loc_bus;
          fetch c_get_loc_bus into l_location_id, l_country;
          close c_get_loc_bus;

          if (l_country is null) then
            l_location_id := null;
          end if;

        end if;
      end if;
    end if;

  elsif (p_level = 3) then	-- Geography level = 'Region'

    if (p_location_id is not null) then

      open ref_csr for
        'select loc.' || g_region_segment ||
        ' from hr_locations loc' ||
        ' where loc.location_id = :p_location_id'
      using p_location_id;

      fetch ref_csr into l_region;
      close ref_csr;
    end if;

    if (l_region is not null) then
      l_location_id := p_location_id;
    else

      if (p_position_id is not null) then

        open ref_csr for
          'select loc.' || g_region_segment ||
          ' ,loc.location_id' ||
          ' from hr_locations loc' ||
          ' ,    per_positions pos' ||
          ' where loc.location_id = pos.location_id' ||
          ' and pos.position_id = :p_position_id'
        using p_position_id;

        fetch ref_csr into l_region, l_location_id;
        close ref_csr;
      end if;

      if (l_region is null) then
        if (p_organization_id is not null) then

          open ref_csr for
            'select loc.' || g_region_segment ||
            ' ,loc.location_id' ||
            ' from hr_locations loc' ||
            ' ,    hr_organization_units hou' ||
            ' where loc.location_id = hou.location_id' ||
            ' and hou.organization_id = :p_organization_id'
          using p_organization_id;

          fetch ref_csr into l_region, l_location_id;
          close ref_csr;
        end if;

        if (l_region is null) then

          open ref_csr for
            'select loc.' || g_region_segment ||
            ' ,loc.location_id' ||
            ' from hr_locations loc' ||
            ' ,    per_business_groups bgr' ||
            ' where loc.location_id = bgr.location_id' ||
            ' and bgr.organization_id = :p_business_group_id'
          using p_business_group_id;

          fetch ref_csr into l_region, l_location_id;
          close ref_csr;

          if (l_region is null) then
            l_location_id := null;
          end if;

        end if;
      end if;
    end if;
  end if;

  return(l_location_id);

end GetLocationId;

-------------------------------------------------------------------------------
--  Function to return the Geography dimension level value
--  (either Area, Country or Region) for a single assignment.
--
--  This functionality is used by the Revenue Model reports.
--  This function is called from package HrViewBy in HRIRPRT.pll
--
--  It is passed the Location Id, Position Id, Organization Id and
--  Business Group Id of the assignment concerned.
--
--  It determines the Area,Country or Region by travelling up the following
--  hierarchy;
--  1. Assignment Location
--  2. Position Location
--  3. Organization Location
--  4. Business Group Location
-------------------------------------------------------------------------------

  function GetGeographyDimension
    ( p_level             IN Number
    , p_location_id       IN Number
    , p_position_id       IN Number
    , p_organization_id   IN Number
    , p_business_group_id IN Number )
   return varchar2 is

    -- First look at location on the assignment
    -- Need nvl on this query so that if a country is not
    -- assigned to an area the record will bring back a
    -- value of Unassigned.  This will stop it going on down
    -- to the next level as it's found a record
    cursor get_area is
      select nvl(ter.parent_territory_code,'Unassigned')
      from bis_territory_hierarchies_v ter
      ,    hr_locations loc
      where ter.child_territory_code(+) = loc.country
      and   decode(ter.parent_territory_type,null,'AREA'
                               ,ter.parent_territory_type) = 'AREA'
      and   loc.location_id = p_location_id;

    -- Then look at location on the position
    cursor get_area_pos is
      select nvl(ter.parent_territory_code, 'Unassigned')
      from bis_territory_hierarchies_v ter
      ,    hr_locations loc
      ,    per_positions pos
      where ter.child_territory_code(+) = loc.country
      and   decode(ter.parent_territory_type,null,'AREA'
                               ,ter.parent_territory_type) = 'AREA'
      and   pos.location_id = loc.location_id
      and   pos.position_id = p_position_id;

    -- Then look at location on the organization
    cursor get_area_org is
      select nvl(ter.parent_territory_code, 'Unassigned')
      from bis_territory_hierarchies_v ter
      ,    hr_locations loc
      ,    hr_organization_units hou
      where ter.child_territory_code(+) = loc.country
      and   decode(ter.parent_territory_type,null,'AREA'
                               ,ter.parent_territory_type) = 'AREA'
      and   hou.location_id = loc.location_id
      and   hou.organization_id = p_organization_id;

    -- Then look at location on the business group
    -- NB. Doesn't matter if don't find Unassigned here as
    -- don't want to drill any further
    cursor get_area_bus is
      select ter.parent_territory_code
      from bis_territory_hierarchies_v ter
      ,    hr_locations loc
      ,    per_business_groups bgr
      where ter.child_territory_code = loc.country
      and   ter.parent_territory_type = 'AREA'
      and   bgr.location_id = loc.location_id
      and   bgr.business_group_id = p_business_group_id;

    -- First look at location on the assignment
    cursor get_country is
      select loc.country
      from hr_locations loc
      where loc.location_id = p_location_id;

    -- Then look at location on the position
    cursor get_country_pos is
      select loc.country
      from hr_locations loc
      ,    per_positions pos
      where loc.location_id = pos.location_id
      and   pos.position_id = p_position_id;

    -- Then look at the location on the organization
    cursor get_country_org is
      select loc.country
      from hr_locations loc
      ,    hr_organization_units hou
      where loc.location_id = hou.location_id
      and   hou.organization_id = p_organization_id;

    -- Then look at the location on the business group
    cursor get_country_bus is
      select loc.country
      from hr_locations loc
      ,    per_business_groups bgr
      where loc.location_id = bgr.location_id
      and bgr.business_group_id = p_business_group_id;

    l_geog           varchar2(2000);
    l_sqlstring      varchar2(10000);

    TYPE RegCurType is REF CURSOR;
    reg_cv           RegCurType;

  begin
    if (p_level = 1) then

      -- If Geography Level is 1 then we are interested in Area

      open get_area;
      fetch get_area into l_geog;

      if (l_geog is null or get_area%notfound) then

        -- Not found at Assignment Level, now look at Position Level
        open get_area_pos;
        fetch get_area_pos into l_geog;

        if (l_geog is null or get_area_pos%notfound) then

          -- Not found at Position Level, now look at Organization Level
          open get_area_org;
          fetch get_area_org into l_geog;

          if (l_geog is null or get_area_org%notfound) then

            -- Not found at Organization Level, now look at Business Group Level
            open get_area_bus;
            fetch get_area_bus into l_geog;
            close get_area_bus;
          end if;

          close get_area_org;
        end if;

        close get_area_pos;
      end if;

      close get_area;

    elsif (p_level = 2) then

      -- If Geography Level is 2 then we are interested in Country
      open get_country;
      fetch get_country into l_geog;

      if (l_geog is null or get_country%notfound) then

        -- Not found at Assignment Level, now look at Position Level
        open get_country_pos;
        fetch get_country_pos into l_geog;

        if (l_geog is null or get_country_pos%notfound) then

          -- Not found at Position Level, now look at Organization Level
          open get_country_org;
          fetch get_country_org into l_geog;

          if (l_geog is null or get_country_org%notfound) then

            -- Not found at Organization Level, now look at Business Group Level
            open get_country_bus;
            fetch get_country_bus into l_geog;
            close get_country_bus;
          end if;

          close get_country_org;
        end if;

        close get_country_pos;
      end if;

      close get_country;

    elsif (p_level = 3) then

      -- Build and execute the dynamic sql statement

      open reg_cv for
                     'select loc.'||g_region_segment||
                     ' from hr_locations loc'||
                     ' where loc.location_id = :p_location_id'
           using p_location_id;

      fetch reg_cv into l_geog;

      if (l_geog is null or reg_cv%notfound) then

        -- Not found at Assignment Level, now look at Position Level
        -- Build and execute the dynamic sql statement

        close reg_cv;
        open reg_cv for
                       'select loc.'||g_region_segment||
                       ' from hr_locations loc'||
                       ' ,    per_positions pos'||
                       ' where loc.location_id = pos.location_id'||
                       ' and pos.position_id = :p_position_id'
             using p_position_id;

        fetch reg_cv into l_geog;

        if (l_geog is null or reg_cv%notfound) then

          -- Not found at Position Level, now look at Organization Level
          -- Build and execute the dynamic sql statement

          close reg_cv;

          open reg_cv for
                         'select loc.'||g_region_segment||
                         ' from hr_locations loc'||
                         ' ,    hr_organization_units hou'||
                         ' where loc.location_id = hou.location_id'||
                         ' and hou.organization_id = :p_organization_id'
               using p_organization_id;

          fetch reg_cv into l_geog;

          if (l_geog is null or reg_cv%notfound) then

            -- Not found at Organization Level, now look at Business Group Level
            -- Build and execute the dynamic sql statement

            close reg_cv;

            open reg_cv for
                           'select loc.'||g_region_segment||
                           ' from hr_locations loc'||
                           ' ,    per_business_groups bgr'||
                           ' where loc.location_id = bgr.location_id'||
                           ' and bgr.organization_id = :p_business_group_id'
                 using p_business_group_id;

            fetch reg_cv into l_geog;

          end if;
        end if;
      end if;

      close reg_cv;
    end if;

    return(l_geog);

  end GetGeographyDimension;

-------------------------------------------------------------------------------
--  New function added by S.Bhattal, 06-JAN-2000, version 115.11, bug 1123310
--  This function returns the DFF segment used to hold Region.
--  This function is called by package HrViewBy in report library HRIRPRT.pll
-------------------------------------------------------------------------------

  function Get_Region_Segment
  return varchar2 is

    -- Region is stored in a flex segment and mapped using flex wizard
    cursor region_csr is
      select bfm.application_column_name
      from  bis_flex_mappings_v    bfm
      ,     bis_dimensions         bd
      where bfm.dimension_id     = bd.dimension_id
      and   bd.short_name        = 'GEOGRAPHY'
      and   bfm.level_short_name = 'REGION'
      and   bfm.application_id   = 800;

  begin

    -- Determine which segment is being used to store the Region dimension

   open region_csr;

   LOOP
    fetch region_csr into g_region_segment;
      EXIT WHEN region_csr%NOTFOUND;
      IF region_csr%ROWCOUNT > 1 THEN
       g_region_segment := '*ERROR*';
      END IF;
   END LOOP;

    close region_csr;

    return(g_region_segment);

  end Get_Region_Segment;

-------------------------------------------------------------------------------
--  New procedures added by M.J.Andrews, 28-JUN-2000, version 115.14, bug 1323212
--  The CheckFastFormulaCompiled procedure should be called from a report's before
--  report trigger in all reports which use fast formula.  It checks if the
--  appropriate fast formula exists, and if it's compiled.  If either is false
--  then it raises the appropriate exception for the report trigger to catch and
--  display.
--  Raise_FF_Not_Compiled and Raise_FF_Not_Exist have been seperated out, so that
--  if the formulas are uncompiled and needed in GetBudgetValue, then it raises
--  the same exception, ensuring the correct error message is displayed.
-------------------------------------------------------------------------------

  PROCEDURE Raise_FF_Not_Exist
    ( p_bgttyp        in VarChar2  )
  IS
  BEGIN
    Fnd_Message.Set_Name('HRI', 'HR_BIS_FF_NOT_EXIST');

--  Removed tokens in version 115.15
--  Fnd_Message.Set_Token('BUDGET_FORMULA', 'BUDGET_'||p_bgttyp, FALSE);
--  Fnd_Message.Set_Token('TEMPLATE_FORMULA', 'TEMPLATE_'||p_bgttyp, FALSE);

    raise ff_not_exist;
  END Raise_FF_Not_Exist;

--

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

--

  PROCEDURE CheckFastFormulaCompiled
    ( p_formula_id    in Number
    , p_bgttyp        in VarChar2  )
  IS
    cursor fast_formula_compiled_csr is
      select formula_id
      from   ff_compiled_info_f
      where  formula_id = p_formula_id;

    l_formula_id   ff_compiled_info_f.formula_id%type   := null;

  BEGIN
    if p_formula_id is null then
      Raise_FF_Not_Exist( p_bgttyp );
    end if;

    open  fast_formula_compiled_csr;
    fetch fast_formula_compiled_csr into l_formula_id;
    close fast_formula_compiled_csr;
    if l_formula_id is null then
      Raise_FF_Not_Compiled( p_formula_id );
    end if;

  END CheckFastFormulaCompiled;


END HrFastAnswers;

/
