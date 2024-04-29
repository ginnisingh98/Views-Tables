--------------------------------------------------------
--  DDL for Package Body PA_IND_RATE_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IND_RATE_SCHEDULES_PKG" as
-- $Header: PAXCIRSB.pls 120.1 2005/08/23 19:20:11 spunathi noship $
-----------------------------------------------------------------------------
-- This procedure checks if ind_rate_sch_id has been referenced in a
-- Project_type, or a Project, or a Task.
-- Note that the check against revisions is done at the form level because
-- of the Master-Detail relationship.

procedure check_references(x_return_status    IN OUT NOCOPY number,
                           x_stage            IN OUT NOCOPY number,
                           x_ind_rate_sch_id  IN     number)
is
x_dummy number;

begin
  x_return_status := 0;
  x_stage := 0;

  -- check against PA_PROJECT_TYPES_ALL
  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_project_types_all pt
                     where  pt.cost_ind_rate_sch_id = x_ind_rate_sch_id
                     or     pt.rev_ind_rate_sch_id = x_ind_rate_sch_id
                     or     pt.inv_ind_rate_sch_id = x_ind_rate_sch_id
                     or     pt.cint_rate_sch_id = x_ind_rate_sch_id);/* added for  bug#3041364 */

   x_return_status := 0;    -- ie. value does not exist is child table
                            -- delete allowed.

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in child table
                            -- delete NOT allowed.
    x_return_status := 1;
    x_stage := 1;
    return;

  end;

  -- check against PA_PROJECTS_ALL
  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_projects_all p
                     where  p.cost_ind_rate_sch_id = x_ind_rate_sch_id
                     or     p.rev_ind_rate_sch_id = x_ind_rate_sch_id
                     or     p.inv_ind_rate_sch_id = x_ind_rate_sch_id
                     or     p.cint_rate_sch_id = x_ind_rate_sch_id); /* added for  bug#3041364 */

    x_return_status := 0;

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in child table
    x_return_status := 1;
    x_stage := 2;
    return;

  end;

  -- check against PA_TASKS
  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_tasks t
                     where  t.cost_ind_rate_sch_id = x_ind_rate_sch_id
                     or     t.rev_ind_rate_sch_id = x_ind_rate_sch_id
                     or     t.inv_ind_rate_sch_id = x_ind_rate_sch_id);

    x_return_status := 0;

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in child table
    x_return_status := 1;
    x_stage := 3;
    return;

  end;

  /* Bug 3594545: Check if check if the Burden Rate Schedule is being
     referenced by any Plan Type or not */
  begin
    if (pa_fin_plan_utils.check_delete_burd_sch_ok(
                      p_ind_rate_sch_id => x_ind_rate_sch_id) = 'N') then
        x_return_status := 1;
	x_stage := 4;
	return;
    else
        x_return_status := 0;
    end if;
  end;

  /* bug fix:3123484 Before deleting the schedule check for cap int txns */
  -- check against capitalized Interest transactions
  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  exists (select 1
                   from   pa_alloc_txn_details p
		    	,pa_ind_rate_sch_revisions prev
                   where  p.ind_rate_sch_revision_id = prev.ind_rate_sch_revision_id
                   and    prev.ind_rate_sch_id = x_ind_rate_sch_id );

    x_return_status := 1;
    x_stage := 2;

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in child table
     	x_return_status := 0;
  	x_stage := 0;
    	return;

  end;

EXCEPTION
  when OTHERS then
  x_return_status := SQLCODE;


end check_references;
----------------------------------------------------------------------------
-- This procedure gets the system default for the schedule type.

procedure get_defined_type(x_return_status            IN OUT NOCOPY number,
                           x_stage                    IN OUT NOCOPY number,
                           x_ind_rate_schedule_type   IN OUT NOCOPY varchar2)
is
begin
  x_return_status := 0;
  x_stage := 0;

  select pov.profile_option_value
  into   x_ind_rate_schedule_type
  from   fnd_profile_option_values pov,
         fnd_profile_options po
  where  pov.application_id = po.application_id
  and    pov.profile_option_id = po.profile_option_id
  and    pov.level_id = 10001
  and    po.application_id = 275
  and    po.profile_option_name = 'PA_IND_RATE_SCHEDULE_TYPE'
  and    trunc(SYSDATE) between
	 trunc(po.start_date_active)
         and trunc(nvl(po.end_date_active, SYSDATE));

  x_return_status := 0;

    EXCEPTION
      WHEN NO_DATA_FOUND then
      x_return_status := 1;
      x_stage := 1;
      return;

      WHEN OTHERS then
      x_return_status := SQLCODE;

end get_defined_type;
----------------------------------------------------------------------------
-- Checks if revisions exist for a schedule.

procedure check_revisions(x_return_status        IN OUT NOCOPY number,
                          x_stage                IN OUT NOCOPY number,
                          x_ind_rate_sch_id      IN     number)
is
x_dummy number;

begin
  x_return_status := 0;
  x_stage := 0;

  -- check against PA_IND_RATE_SCH_REVISIONS
  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_ind_rate_sch_revisions irsr
                     where  irsr.ind_rate_sch_id = x_ind_rate_sch_id);

    x_return_status := 0;

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in child table
    x_return_status := 1;
    x_stage := 1;
    return;

    when OTHERS then
    x_return_status := SQLCODE;
  end;



end check_revisions;
----------------------------------------------------------------------------
end PA_IND_RATE_SCHEDULES_PKG;

/
