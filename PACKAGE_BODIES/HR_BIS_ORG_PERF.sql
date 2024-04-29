--------------------------------------------------------
--  DDL for Package Body HR_BIS_ORG_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BIS_ORG_PERF" AS
/* $Header: hrbisorg.pkb 115.9 2002/04/17 03:43:52 pkm ship     $ */
--
function get_start(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).start_val);
exception
when others then
  return (0);
end;
--
function get_end(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).end_val);
exception
when others then
  return (0);
end;
--
function get_increase(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).end_val- OrgPerfData(p_organization_id).start_val);
exception
when others then
  return (0);
end;
--
function get_pct_increase(p_organization_id NUMBER) return NUMBER is
begin
  return(100*(OrgPerfData(p_organization_id).end_val- OrgPerfData(p_organization_id).start_val)/ OrgPerfData(p_organization_id).start_val);
exception
when zero_divide then
  return (0);
when others then
  return (0);
end;
--
function get_gains(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).gains);
exception
when others then
  return (0);
end;
--
function get_ended(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).ended);
exception
when others then
  return (0);
end;
--
function get_transfered_out(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).transfered_out);
exception
when others then
  return (0);
end;
--
function get_suspended(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).suspended);
exception
when others then
  return (0);
end;
--
function get_sep_reason(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).sep_reason);
exception
when others then
  return (0);
end;
--
function get_others(p_organization_id NUMBER) return NUMBER is
begin
  return(OrgPerfData(p_organization_id).others);
exception
when others then
  return (0);
end;
--
function get_sep_pct_increase(p_organization_id NUMBER) return NUMBER is
begin
  return(100*OrgPerfData(p_organization_id).sep_reason/ OrgPerfData(p_organization_id).start_val);
exception
when zero_divide then
  return (0);
when others then
  return (0);
end;
--
procedure populate_manpower_table
  ( p_org_param_id      IN     NUMBER
  , p_budget_metric     IN     VARCHAR2
  , p_business_group_id IN     NUMBER
  , p_top_org           IN     NUMBER
  , p_start_date        IN     DATE
  , p_end_date          IN     DATE )
is

  cursor get_assignment
    ( cp_org_param_id  NUMBER
    , cp_eff_date      DATE )
  is
    select opl.organization_id_group organization_id  -- S.Bhattal, 19/07/99
    ,      asg.assignment_id
    from   per_assignment_status_types ast
    ,      per_assignments_f           asg
    ,      hri_org_param_list          opl
    where  opl.org_param_id            = cp_org_param_id
    and    opl.organization_id_child   = asg.organization_id
    and    cp_eff_date between asg.effective_start_date and
		asg.effective_end_date
    and    asg.assignment_type = 'E'
    and    asg.assignment_status_type_id = ast.assignment_status_type_id
    and    ast.per_system_status = 'ACTIVE_ASSIGN';

  cursor get_organizations
    ( cp_org_param_id  NUMBER )
  is
    select org.organization_id
    from   hr_organization_units org
    ,      hri_org_param_list    opl
    where  opl.org_param_id          = cp_org_param_id
    and    opl.organization_id_child = org.organization_id
    group by org.organization_id;  -- S.Bhattal, 19/07/99

  cursor c_get_bgt_formula
    ( cp_business_group_id NUMBER )
  is
    select formula_id
    from   ff_formulas_f
    where  cp_business_group_id = business_group_id
    and    trunc(sysdate) between effective_start_date and effective_end_date
    and    formula_name = 'BUDGET_'||p_budget_metric;

  cursor c_get_tmplt_formula is
    select formula_id
    from   ff_formulas_f
    where  business_group_id   is null
    and    trunc(sysdate) between effective_start_date and effective_end_date
    and    formula_name = 'TEMPLATE_'||p_budget_metric;

  l_formula_id      NUMBER;
  l_manpower_start  NUMBER;
  l_manpower_end    NUMBER;

begin
  -- Populate the data table with zeros
  for org_rec in get_organizations
    ( p_org_param_id )
  loop
    OrgPerfData(org_rec.organization_id).start_val := 0;
    OrgPerfData(org_rec.organization_id).end_val   := 0;
  end loop;

  -- Look for the budget formula

  open c_get_bgt_formula (p_business_group_id);
  fetch c_get_bgt_formula into l_formula_id;

  if (c_get_bgt_formula%notfound)
  then
    close c_get_bgt_formula;

    -- If the budget formula does not exist, look for the template formula
    open c_get_tmplt_formula;
    fetch c_get_tmplt_formula into l_formula_id;

    if (c_get_tmplt_formula%notfound)
    then
      close c_get_tmplt_formula;

      -- Set to null so that we can calculate values differently later
      l_formula_id := null;
    else
      close c_get_tmplt_formula;
    end if;

  else
    close c_get_bgt_formula;
  end if;

/****************************************
*  Modified code starts here            *
*  S.Bhattal, 08-JUL-99, version 110.7  *
****************************************/

    for ass_rec in get_assignment
      ( p_org_param_id
      , p_start_date )
    loop

      l_manpower_start := HrFastAnswers.GetBudgetValue
      ( p_budget_metric_formula_id => l_formula_id
      , p_budget_metric            => p_budget_metric
      , p_assignment_id            => ass_rec.assignment_id
      , p_effective_date           => p_start_date
      , p_session_date             => sysdate );

      OrgPerfData(ass_rec.organization_id).start_val :=
      OrgPerfData(ass_rec.organization_id).start_val + nvl(l_manpower_start,0);

    end loop;

    for ass_rec in get_assignment
      ( p_org_param_id
      , p_end_date )
    loop

      l_manpower_end := HrFastAnswers.GetBudgetValue
      ( p_budget_metric_formula_id => l_formula_id
      , p_budget_metric            => p_budget_metric
      , p_assignment_id            => ass_rec.assignment_id
      , p_effective_date           => p_end_date
      , p_session_date             => sysdate );

      OrgPerfData(ass_rec.organization_id).end_val :=
       OrgPerfData(ass_rec.organization_id).end_val + nvl(l_manpower_end,0);

    end loop;

end populate_manpower_table;

/* checks if an assignment is active and returns TRUE if it is */
/* part of bug fix 1747233 */
function check_asg_is_active(p_assignment_id number, p_effective_date date) return BOOLEAN
is

/* return a row if the assignment is active on cp_effective_date */
cursor cur_check_asg_active(cp_assignment_id number, cp_effective_date date) is
select 1
from per_all_assignments_f asg
where asg.assignment_id = cp_assignment_id
and   cp_effective_date between asg.effective_start_date and asg.effective_end_date;

l_check_asg number;

begin

     if (p_assignment_id is null) or (p_effective_date is null) then
	return (FALSE);
     end if;

     open cur_check_asg_active(p_assignment_id , p_effective_date );
     fetch cur_check_asg_active into l_check_asg;

     if (cur_check_asg_active%rowcount = 0) or (cur_check_asg_active%notfound) then
        close cur_check_asg_active;
        return (FALSE);
     end if;

     close cur_check_asg_active;
     return (TRUE);

exception
  when others then
      close cur_check_asg_active;
      return(FALSE);

end check_asg_is_active;



procedure populate_separations_table
  ( p_org_param_id      IN     NUMBER
  , p_budget_metric     IN     VARCHAR2
  , p_business_group_id IN     NUMBER
  , p_top_org           IN     NUMBER
  , p_start_date        IN     DATE
  , p_end_date          IN     DATE
  , p_leaving_reason    IN     VARCHAR2)
is
  cursor get_assignment
    ( cp_org_param_id  NUMBER
    , cp_start_date    DATE
    , cp_end_date      DATE
    , cp_org_id        NUMBER )
  is
    select asg.organization_id
    ,      asg.assignment_id
    ,      1 no_change
    ,      0 gain
    ,      0 loss
    from   per_assignment_status_types ast
    ,      per_assignments_f           asg
    ,      hr_all_organization_units   org
    ,      hri_org_param_list          opl
    where  opl.org_param_id = cp_org_param_id
    and    opl.organization_id_group = cp_org_id
    and    opl.organization_id_child = asg.organization_id
    and    org.organization_id = asg.organization_id
    and    cp_end_date between asg.effective_start_date and asg.effective_end_date
    and    asg.assignment_type = 'E'
    and    asg.assignment_status_type_id = ast.assignment_status_type_id
    and    ast.per_system_status = 'ACTIVE_ASSIGN'
    and    exists (
             select 1
             from   per_assignment_status_types ast2
             ,      per_assignments_f           asg2
             ,      hri_org_param_list          opl2
             where  opl2.org_param_id = cp_org_param_id
             and    opl2.organization_id_group = cp_org_id
             and    opl2.organization_id_child = asg2.organization_id
             and    asg2.assignment_id = asg.assignment_id
             and    asg2.assignment_status_type_id = ast2.assignment_status_type_id
             and    asg2.assignment_type = 'E'
             and    ast2.per_system_status = 'ACTIVE_ASSIGN'
             and    cp_start_date between asg2.effective_start_date and asg2.effective_end_date )
    UNION
    select asg.organization_id
    ,      asg.assignment_id
    ,      0 no_change
    ,      1 gain
    ,      0 loss
    from   per_assignment_status_types ast
    ,      per_assignments_f           asg
    ,      hr_all_organization_units   org
    ,      hri_org_param_list          opl
    where  opl.org_param_id = cp_org_param_id
    and    opl.organization_id_group = cp_org_id
    and    opl.organization_id_child = asg.organization_id
    and    org.organization_id = asg.organization_id
    and    asg.assignment_type = 'E'
    and    cp_end_date between asg.effective_start_date and asg.effective_end_date
    and    asg.assignment_status_type_id = ast.assignment_status_type_id
    and    ast.per_system_status = 'ACTIVE_ASSIGN'
    and    not exists (
             select 1
             from   per_assignment_status_types ast2
             ,      per_assignments_f           asg2
             ,      hri_org_param_list          opl2
             where  opl2.org_param_id = cp_org_param_id
             and    opl2.organization_id_group = cp_org_id
             and    opl2.organization_id_child = asg2.organization_id
             and    asg2.assignment_id=asg.assignment_id
             and    asg2.assignment_status_type_id = ast2.assignment_status_type_id
             and    asg2.assignment_type = 'E'
             and    ast2.per_system_status = 'ACTIVE_ASSIGN'
             and    cp_start_date between asg2.effective_start_date and asg2.effective_end_date)
    UNION
    select asg.organization_id
    ,      asg.assignment_id
    ,      0 no_change
    ,      0 gain
    ,      1 loss
    from   per_assignment_status_types ast
    ,      per_assignments_f           asg
    ,      hr_all_organization_units   org
    ,      hri_org_param_list          opl
    where  opl.org_param_id = cp_org_param_id
    and    opl.organization_id_group = cp_org_id
    and    opl.organization_id_child = asg.organization_id
    and    org.organization_id = asg.organization_id
    and    asg.assignment_type = 'E'
    and    cp_start_date between asg.effective_start_date and asg.effective_end_date
    and    asg.assignment_status_type_id = ast.assignment_status_type_id
    and    ast.per_system_status = 'ACTIVE_ASSIGN'
    and    not exists (
             select 1
             from   per_assignment_status_types ast2
             ,      per_assignments_f asg2
             ,      hri_org_param_list          opl2
             where  opl2.org_param_id = cp_org_param_id
             and    opl2.organization_id_group = cp_org_id
             and    opl2.organization_id_child = asg2.organization_id
             and    asg2.assignment_id=asg.assignment_id
             and    asg2.assignment_status_type_id = ast2.assignment_status_type_id
             and    asg2.assignment_type = 'E'
             and    ast2.per_system_status = 'ACTIVE_ASSIGN'
             and    cp_end_date between asg2.effective_start_date and asg2.effective_end_date);

  cursor get_organizations
    ( cp_org_param_id  NUMBER )
  is
    select org.organization_id
    from   hr_organization_units org
    ,      hri_org_param_list    opl
    where  opl.org_param_id          = cp_org_param_id
    and    opl.organization_id_child = org.organization_id
    group by org.organization_id;  -- S.Bhattal, 19/07/99

  cursor c_get_bgt_formula
    ( cp_business_group_id NUMBER )
  is
    select formula_id
    from   ff_formulas_f
    where  cp_business_group_id = business_group_id
    and    trunc(sysdate) between effective_start_date and effective_end_date
    and    formula_name = 'BUDGET_'||p_budget_metric;

  cursor c_get_tmplt_formula
  is
    select formula_id
    from   ff_formulas_f
    where business_group_id   is null
    and     trunc(sysdate) between effective_start_date and effective_end_date
    and     formula_name = 'TEMPLATE_'||p_budget_metric;

  l_formula_id            NUMBER;
  l_manpower_start        NUMBER :=0;
  l_manpower_end          NUMBER :=0;
  l_assignment_category   VARCHAR2(80);
  l_leaving_reason        VARCHAR2(80);
  l_service_band          VARCHAR2(80);
  l_start                 NUMBER;
  l_end                   NUMBER;
  l_gains                 NUMBER;
  l_ended                 NUMBER;
  l_suspended             NUMBER;
  l_transfered            NUMBER;
  l_separated             NUMBER;
  l_other                 NUMBER;

begin
  -- Populate the data table with zeros
  for org_rec in get_organizations
    ( p_org_param_id )
  loop
    OrgPerfData(org_rec.organization_id).start_val      := 0;
    OrgPerfData(org_rec.organization_id).end_val        := 0;
    OrgPerfData(org_rec.organization_id).gains          := 0;
    OrgPerfData(org_rec.organization_id).ended          := 0;
    OrgPerfData(org_rec.organization_id).suspended      := 0;
    OrgPerfData(org_rec.organization_id).transfered_out := 0;
    OrgPerfData(org_rec.organization_id).sep_reason     := 0;
    OrgPerfData(org_rec.organization_id).others         := 0;
  end loop;

  -- Look for the budget formula

  open c_get_bgt_formula (p_business_group_id);
  fetch c_get_bgt_formula into l_formula_id;

  if (c_get_bgt_formula%notfound)
  then
    close c_get_bgt_formula;

    -- If the budget formula does not exist, look for the template formula

    open c_get_tmplt_formula;
    fetch c_get_tmplt_formula into l_formula_id;

    if (c_get_tmplt_formula%notfound)
    then
      close c_get_tmplt_formula;

      -- set to null so that we can calculate values differently later
      l_formula_id := null;
    else
      close c_get_tmplt_formula;
    end if;
  else
    close c_get_bgt_formula;
  end if;

/****************************************
*  Modified code starts here            *
*  S.Bhattal, 08-JUL-99, version 110.7  *
****************************************/

    for org_rec in get_organizations
      ( p_org_param_id )
    loop

      for ass_rec in get_assignment
        ( p_org_param_id
        , p_start_date
        , p_end_date
        , org_rec.organization_id)
      loop

        /* bug fix 1747233 03-MAY-2001 */
        /* only call the fast formula if ass_rec.assignment_id exists on  p_start_date */
        if check_asg_is_active(ass_rec.assignment_id, p_start_date) then

	    l_manpower_start := nvl( HrFastAnswers.GetBudgetValue
	    ( p_budget_metric_formula_id => l_formula_id
	    , p_budget_metric            => p_budget_metric
	    , p_assignment_id            => ass_rec.assignment_id
	    , p_effective_date           => p_start_date
	    , p_session_date             => sysdate ), 0 );

        end if;

        /* bug fix 1747233 03-MAY-2001 */
        /* only call the fast formula if ass_rec.assignment_id exists on p_end_date */
        if check_asg_is_active(ass_rec.assignment_id, p_end_date) then

	    l_manpower_end := nvl( HrFastAnswers.GetBudgetValue
	    ( p_budget_metric_formula_id => l_formula_id
	    , p_budget_metric            => p_budget_metric
	    , p_assignment_id            => ass_rec.assignment_id
	    , p_effective_date           => p_end_date
	    , p_session_date             => sysdate ), 0 );

        end if;

       OrgPerfData(org_rec.organization_id).start_val :=
         OrgPerfData(org_rec.organization_id).start_val +
	(ass_rec.no_change + ass_rec.loss) * l_manpower_start;

       OrgPerfData(org_rec.organization_id).end_val :=
         OrgPerfData(org_rec.organization_id).end_val +
	(ass_rec.no_change + ass_rec.gain) * l_manpower_end;

       if (ass_rec.gain = 1)
       then
         OrgPerfData(org_rec.organization_id).gains :=
           OrgPerfData(org_rec.organization_id).gains + l_manpower_end;

       elsif (ass_rec.loss = 1)
       then
         HRFastAnswers.GetAssignmentCategory
           ( p_org_param_id
           , ass_rec.assignment_id
           , p_start_date+1
           , p_end_date
           , org_rec.organization_id
           , 'OUT'
           , l_assignment_category
           , l_leaving_reason
           , l_service_band );

         if (l_assignment_category = 'ENDED')
         then
           OrgPerfData(org_rec.organization_id).ended :=
             OrgPerfData(org_rec.organization_id).ended + l_manpower_start;

         elsif (l_assignment_category = 'TRANSFER_OUT')
         then
           OrgPerfData(org_rec.organization_id).transfered_out :=
             OrgPerfData(org_rec.organization_id).transfered_out + l_manpower_start;

         elsif (l_assignment_category = 'SUSPENDED')
         then
           OrgPerfData(org_rec.organization_id).suspended :=
             OrgPerfData(org_rec.organization_id).suspended + l_manpower_start;

         elsif (l_assignment_category = 'SEPARATED')
         then
           if (l_leaving_reason = p_leaving_reason or p_leaving_reason='BIS_ALL')
           then
             OrgPerfData(org_rec.organization_id).sep_reason :=
               OrgPerfData(org_rec.organization_id).sep_reason + l_manpower_start;
           else
             OrgPerfData(org_rec.organization_id).others :=
               OrgPerfData(org_rec.organization_id).others + l_manpower_start;
           end if;

         end if;

       end if;
      end loop;
    end loop;

end populate_separations_table;


procedure populate_budget_table
  ( p_budget_id         IN     NUMBER
  , p_business_group_id IN     NUMBER
  , p_report_date       IN     DATE)
is
  -- The subquery in the following cursor originally had DISTINCT
  -- Removed by BDG on 28/04/1999
  cursor get_assignment
    ( cp_budget_id    NUMBER
    , cp_report_date  DATE )
  is
    select asg.organization_id
    ,      asg.assignment_id
    from   per_assignment_status_types ast
    ,      per_assignments_f asg
    where  cp_report_date between asg.effective_start_date and asg.effective_end_date
    and    asg.assignment_type = 'E'
    and    ast.assignment_status_type_id = asg.assignment_status_type_id
    and    ast.per_system_status = 'ACTIVE_ASSIGN'
    and    asg.organization_id in (
             select be.organization_id
             from   per_budget_values      bval
             ,      per_budget_elements    be
           	 ,      per_budget_versions    bver
           	 ,      per_time_periods       tp
           	 ,      per_budgets_v          bud
             where  bud.budget_id	= cp_budget_id
             and	  bud.budget_id = bver.budget_id
             and    sysdate between bver.date_from and nvl(bver.date_to, sysdate+1)
             and	  be.budget_version_id = bver.budget_version_id
             and	  be.budget_element_id = bval.budget_element_id
             and	  tp.time_period_id	= bval.time_period_id
             and	  cp_report_date between tp.start_date and tp.end_date );

  cursor get_organizations
    ( cp_budget_id    NUMBER
    , cp_report_date  DATE )
  is
    select distinct be.organization_id
    from   per_budget_values    bval
    ,      per_budget_elements  be
    ,      per_budget_versions  bver
    ,      per_time_periods     tp
    ,      per_budgets_v        bud
    where  bud.budget_id = cp_budget_id
    and	   bud.budget_id = bver.budget_id
    and    sysdate between bver.date_from and nvl(bver.date_to, sysdate+1)
    and	   be.budget_version_id	= bver.budget_version_id
    and	   be.budget_element_id	= bval.budget_element_id
    and	   tp.time_period_id = bval.time_period_id
    and	   cp_report_date between tp.start_date and tp.end_date
    -- bug 2324688
    and    be.organization_id is not null;

  cursor get_budget_values
    ( cp_budget_id    NUMBER
    , cp_report_date  DATE )
  is
    select sum(bval.value) budget_value
    ,      be.organization_id
    from   per_budget_values    bval
    ,      per_budget_elements  be
    ,      per_budget_versions  bver
    ,      per_time_periods	    tp
    ,      per_budgets_v		    bud
    where  bud.budget_id = cp_budget_id
    and	   bud.budget_id = bver.budget_id
    and    sysdate between bver.date_from and nvl(bver.date_to, sysdate+1)
    and	   be.budget_version_id	= bver.budget_version_id
    and	   be.budget_element_id	= bval.budget_element_id
    and	   tp.time_period_id = bval.time_period_id
    and	   be.organization_id	is not null
    and	   cp_report_date between tp.start_date and tp.end_date
    group by be.organization_id;

  cursor c_get_bgt_formula
    ( cp_business_group_id NUMBER
    , cp_budget_metric     VARCHAR2 )
  is
    select formula_id
    from   ff_formulas_f
    where  cp_business_group_id = business_group_id
    and    trunc(sysdate) between effective_start_date and effective_end_date
    and    formula_name = 'BUDGET_'||cp_budget_metric;

  cursor c_get_tmplt_formula
    ( cp_budget_metric     VARCHAR2 )
  is
    select formula_id
    from   ff_formulas_f
    where  business_group_id   is null
    and    trunc(sysdate) between effective_start_date and effective_end_date
    and    formula_name = 'TEMPLATE_'||cp_budget_metric;

  l_formula_id      NUMBER;
  l_manpower_start  NUMBER;
  l_manpower_end    NUMBER;
  l_budget_metric   VARCHAR2(80);

begin
  -- Populate the data table with zeros
  for org_rec in get_organizations
    ( p_budget_id
    , p_report_date )
  loop
    OrgPerfData(org_rec.organization_id).start_val := 0;
    OrgPerfData(org_rec.organization_id).end_val   := 0;
  end loop;

  select  unit
  into    l_budget_metric
  from    per_budgets
  where   budget_id = p_budget_id;

  -- Look for the budget formula
  open c_get_bgt_formula (p_business_group_id, l_budget_metric);
  fetch c_get_bgt_formula into l_formula_id;

  if (c_get_bgt_formula%notfound)
  then
    close c_get_bgt_formula;

    -- if the budget formula does not exist, look for the template formula

    open c_get_tmplt_formula (l_budget_metric);
    fetch c_get_tmplt_formula into l_formula_id;

    if (c_get_tmplt_formula%notfound)
    then

      -- set to null so that we can calculate values differently later
      close c_get_tmplt_formula;
      l_formula_id := null;
    else
      close c_get_tmplt_formula;
    end if;
  else
    close c_get_bgt_formula;
  end if;

/****************************************
*  Modified code starts here            *
*  S.Bhattal, 08-JUL-99, version 110.7  *
****************************************/

    for ass_rec in get_assignment
      ( p_budget_id
      , p_report_date )
    loop

      l_manpower_start := HrFastAnswers.GetBudgetValue
      ( p_budget_metric_formula_id => l_formula_id
      , p_budget_metric            => l_budget_metric
      , p_assignment_id            => ass_rec.assignment_id
      , p_effective_date           => p_report_date
      , p_session_date             => sysdate );

       OrgPerfData(ass_rec.organization_id).start_val :=
         OrgPerfData(ass_rec.organization_id).start_val + nvl(l_manpower_start,0);

    end loop;

/****************************************
*  Modified code ends here              *
*  S.Bhattal, 08-JUL-99, version 110.7  *
****************************************/

  -- Get the actuals

  for bgt_rec in get_budget_values
    ( p_budget_id
    , p_report_date )
  loop
    OrgPerfData(bgt_rec.organization_id).end_val :=
      OrgPerfData(bgt_rec.organization_id).end_val + bgt_rec.budget_value;
  end loop;

end populate_budget_table;

-- cbridge, 25/10/2000, pqh budget reports changes
procedure populate_pqh_budget_table
  ( p_budget_id         IN     NUMBER
  , p_business_group_id IN     NUMBER
  , p_budget_metric     IN     VARCHAR2
  , p_budget_unit       IN     NUMBER
  , p_report_date       IN     DATE)
is
  cursor get_assignment
    ( cp_budget_id    NUMBER
    , cp_report_date  DATE )
  is
    select asg.organization_id
    ,      asg.assignment_id
    from   per_assignment_status_types ast
    ,      per_assignments_f asg
    where  cp_report_date between asg.effective_start_date and asg.effective_end_date
    and    asg.assignment_type = 'E'
    and    ast.assignment_status_type_id = asg.assignment_status_type_id
    and    ast.per_system_status = 'ACTIVE_ASSIGN'
    and    asg.organization_id in (
select  distinct  bdet.organization_id
from      pqh_budgets bud
        , pqh_budget_versions bver
        , pqh_budget_details  bdet
        , pqh_budget_periods  bper
        , per_shared_types pst1
        , per_time_periods ptp
where bud.budget_id = cp_budget_id
and   bud.budget_id  = bver.budget_id
and   sysdate between bver.date_from and nvl(bver.date_to, sysdate +1)
and   bver.budget_version_id  = bdet.budget_version_id
and   bdet.budget_detail_id      = bper.budget_detail_id
and   bper.start_time_period_id  = ptp.time_period_id
and   bdet.organization_id   is not null
and   cp_report_date between ptp.start_date and ptp.end_date);

  cursor get_organizations
    ( cp_budget_id    NUMBER
    , cp_report_date  DATE )
  is
select  distinct  bdet.organization_id
from      pqh_budgets bud
        , pqh_budget_versions bver
        , pqh_budget_details  bdet
        , pqh_budget_periods  bper
        , per_shared_types pst1
        , per_time_periods ptp
where bud.budget_id = cp_budget_id
and   bud.budget_id  = bver.budget_id
and   sysdate between bver.date_from and nvl(bver.date_to, sysdate +1)
and   bver.budget_version_id  = bdet.budget_version_id
and   bdet.budget_detail_id      = bper.budget_detail_id
and   bper.start_time_period_id  = ptp.time_period_id
and   bdet.organization_id   is not null
and   cp_report_date between ptp.start_date and ptp.end_date;

  cursor get_budget_values
    ( cp_budget_id    NUMBER
    , cp_report_date  DATE )
  is
select    SUM(bper.budget_unit1_value)           budget_value1
           , SUM(bper.budget_unit2_value)           budget_value2
           , SUM(bper.budget_unit3_value)           budget_value3
        , bdet.organization_id
from      pqh_budgets bud
        , pqh_budget_versions bver
        , pqh_budget_details  bdet
        , pqh_budget_periods  bper
        , per_shared_types pst1
        , per_shared_types pst2
        , per_shared_types pst3
        , per_time_periods ptp
where bud.budget_id = cp_budget_id
and   bud.budget_unit1_id = pst1.shared_type_id
and   bud.budget_unit2_id = pst2.shared_type_id (+)
and   bud.budget_unit3_id = pst3.shared_type_id (+)
and   bud.budget_id  = bver.budget_id
and   sysdate between bver.date_from and nvl(bver.date_to, sysdate+1)
and   bver.budget_version_id  = bdet.budget_version_id
and   bdet.budget_detail_id      = bper.budget_detail_id
and   bper.start_time_period_id  = ptp.time_period_id
and   bdet.organization_id   is not null
and   cp_report_date between ptp.start_date and ptp.end_date
group by  bdet.organization_id;


  cursor c_get_bgt_formula
    ( cp_business_group_id NUMBER
    , cp_budget_metric     VARCHAR2 )
  is
    select formula_id
    from   ff_formulas_f
    where  cp_business_group_id = business_group_id
    and    trunc(sysdate) between effective_start_date and effective_end_date
    and    formula_name = 'BUDGET_'||cp_budget_metric;

  cursor c_get_tmplt_formula
    ( cp_budget_metric     VARCHAR2 )
  is
    select formula_id
    from   ff_formulas_f
    where  business_group_id   is null
    and    trunc(sysdate) between effective_start_date and effective_end_date
    and    formula_name = 'TEMPLATE_'||cp_budget_metric;


  l_formula_id      NUMBER;
  l_manpower_start  NUMBER;
  l_manpower_end    NUMBER;
  l_budget_metric   VARCHAR2(80);
  l_error varchar2(100) := '1';

begin



  -- Populate the data table with zeros
  for org_rec in get_organizations
    ( p_budget_id
    , p_report_date )
  loop
    OrgPerfData(org_rec.organization_id).start_val := 0;
    OrgPerfData(org_rec.organization_id).end_val   := 0;
    htp.comment(OrgPerfData(org_rec.organization_id).end_val);
  end loop;


l_budget_metric := p_budget_metric;

l_error := '2';

  -- Look for the budget formula
  open c_get_bgt_formula (p_business_group_id, l_budget_metric);
  fetch c_get_bgt_formula into l_formula_id;

  if (c_get_bgt_formula%notfound)
  then
    close c_get_bgt_formula;

    -- if the budget formula does not exist, look for the template formula

    open c_get_tmplt_formula (l_budget_metric);
    fetch c_get_tmplt_formula into l_formula_id;

    if (c_get_tmplt_formula%notfound)
    then

      -- set to null so that we can calculate values differently later
      close c_get_tmplt_formula;
      l_formula_id := null;
    else
      close c_get_tmplt_formula;
    end if;
  else
    close c_get_bgt_formula;
  end if;

/****************************************
*  Modified code starts here            *
*  S.Bhattal, 08-JUL-99, version 110.7  *
****************************************/

l_error := '3';

    for ass_rec in get_assignment
      ( p_budget_id
      , p_report_date )
    loop

l_error := '3.1 check if fastformula exist and compiled';

 --hrfastanswers.checkfastformulacompiled(l_formula_id, l_budget_metric);

l_error := '3.1, l_budget_metric= '|| l_budget_metric || '  l_formula_id = ' || l_formula_id;

      l_manpower_start := HrFastAnswers.GetBudgetValue
      ( p_budget_metric_formula_id => l_formula_id
      , p_budget_metric            => l_budget_metric
      , p_assignment_id            => ass_rec.assignment_id
      , p_effective_date           => p_report_date
      , p_session_date             => sysdate );

l_error := '3.2, ass_rec.organization_id='|| ass_rec.organization_id;

       OrgPerfData(ass_rec.organization_id).start_val :=
         OrgPerfData(ass_rec.organization_id).start_val + nvl(l_manpower_start,0);

l_error := '3.3, ass_rec.organization_id='|| ass_rec.organization_id;

    end loop;

l_error := '4';

  -- Get the actuals

  for bgt_rec in get_budget_values
    ( p_budget_id
    , p_report_date )
  loop
    if p_budget_unit = 1 then
        OrgPerfData(bgt_rec.organization_id).end_val :=
                OrgPerfData(bgt_rec.organization_id).end_val + bgt_rec.budget_value1;
    elsif p_budget_unit = 2 then
        OrgPerfData(bgt_rec.organization_id).end_val :=
                OrgPerfData(bgt_rec.organization_id).end_val + bgt_rec.budget_value2;
    elsif p_budget_unit = 3 then
        OrgPerfData(bgt_rec.organization_id).end_val :=
                OrgPerfData(bgt_rec.organization_id).end_val + bgt_rec.budget_value3;
    else
        raise no_data_found;
    end if;

  end loop;

l_error := '5';

end populate_pqh_budget_table;


END HR_BIS_ORG_PERF;

/
