--------------------------------------------------------
--  DDL for Package Body GMS_BUDGET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BUDGET_UTILS" as
/* $Header: gmsbubub.pls 120.5 2006/04/11 23:00:34 cmishra ship $ */

  NO_DATA_FOUND_ERR number := 100;

  --Bug 2587078 :  To check on, whether to print debug messages in log file or not
  L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');


  procedure get_draft_version_id (x_project_id        in     number,
                                  x_award_id          in     number,
				  x_budget_type_code  in     varchar2,
				  x_budget_version_id in out NOCOPY number,
		    		  x_err_code          in out NOCOPY number,
		    		  x_err_stage	      in out NOCOPY varchar2,
		    		  x_err_stack         in out NOCOPY varchar2)
  is
     old_stack varchar2(630);
  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_draft_version_id';

     x_err_stage := 'get draft budget id <' || to_char(x_project_id)
		    || '><' || x_budget_type_code || '>' ;

     select budget_version_id
     into   x_budget_version_id
     from   gms_budget_versions
     where  project_id = x_project_id
     and    award_id   = x_award_id
     and    budget_type_code = x_budget_type_code
     and    budget_status_code in ('W', 'S');

     x_err_stack := old_stack;

  exception
     when NO_DATA_FOUND then
	gms_error_pkg.gms_message(x_err_name => 'GMS_BU_CORE_NO_VERSION_ID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

     when others then
	 gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
	 			x_token_name1 => 'SQLCODE',
	 			x_token_val1 => sqlcode,
	 			x_token_name2 => 'SQLERRM',
	 			x_token_val2 => sqlerrm,
	 			x_err_code => x_err_code,
	 			x_err_buff => x_err_stage);

  end get_draft_version_id;

-----------------------------------------------------------------------------

  procedure get_baselined_version_id (x_project_id    in     number,
                                  x_award_id          in     number,
				  x_budget_type_code  in     varchar2,
				  x_budget_version_id in out NOCOPY number,
		    		  x_err_code          in out NOCOPY number,
		    		  x_err_stage	      in out NOCOPY varchar2,
		    		  x_err_stack         in out NOCOPY varchar2)
  is
     old_stack varchar2(630);
  begin

     IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('*** Start of GMS_BUDGET_UTILS.GET_BASELINED_VERSION_ID ***','C');
     END IF;

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_baselined_version_id';

     x_err_stage := 'GMS_BUDGET_UTILS.GET_BASELINED_VERSION_ID- get baselined budget id <' || to_char(x_project_id)
                     || '><' || x_budget_type_code || '>' ;

     select budget_version_id
     into   x_budget_version_id
     from   gms_budget_versions
     where  project_id = x_project_id
     and    award_id   = x_award_id
     and    budget_type_code = x_budget_type_code
     and    current_flag = 'Y';

     x_err_stack := old_stack;

     IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('*** End of GMS_BUDGET_UTILS.GET_BASELINED_VERSION_ID ***','C');
     END IF;

  exception
     when NO_DATA_FOUND then
        x_err_stage:= 'GMS_BUDGET_UTILS.GET_BASELINED_VERSION_ID- In NO_DATA_FOUND exception';
	gms_error_pkg.gms_message(x_err_name => 'GMS_BU_CORE_NO_VERSION_ID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

     when others then
         x_err_stage:= 'GMS_BUDGET_UTILS.GET_BASELINED_VERSION_ID- In others exception';
	 gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
	 			x_token_name1 => 'SQLCODE',
	 			x_token_val1 => sqlcode,
	 			x_token_name2 => 'SQLERRM',
	 			x_token_val2 => sqlerrm,
	 			x_err_code => x_err_code,
	 			x_err_buff => x_err_stage);

  end get_baselined_version_id;

-----------------------------------------------------------------------------

  procedure get_original_version_id (x_project_id    in     number,
                                  x_award_id          in     number,
				  x_budget_type_code  in     varchar2,
				  x_budget_version_id in out NOCOPY number,
		    		  x_err_code          in out NOCOPY number,
		    		  x_err_stage	      in out NOCOPY varchar2,
		    		  x_err_stack         in out NOCOPY varchar2)
  is
     old_stack varchar2(630);
  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_original_version_id';

     x_err_stage := 'get original budget id <' || to_char(x_project_id)
		    || '><' || x_award_id || '>' ;

     select budget_version_id
     into   x_budget_version_id
     from   gms_budget_versions
     where  project_id = x_project_id
     and    award_id   = x_award_id
     and    budget_type_code = x_budget_type_code
     and    current_original_flag = 'Y';

     x_err_stack := old_stack;

  exception
     when NO_DATA_FOUND then
	gms_error_pkg.gms_message(x_err_name => 'GMS_BU_CORE_NO_VERSION_ID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

     when others then
	 gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
	 			x_token_name1 => 'SQLCODE',
	 			x_token_val1 => sqlcode,
	 			x_token_name2 => 'SQLERRM',
	 			x_token_val2 => sqlerrm,
	 			x_err_code => x_err_code,
	 			x_err_buff => x_err_stage);

  end get_original_version_id;

-----------------------------------------------------------------------------

  procedure get_default_resource_list_id (x_project_id    in     number,
                                  x_award_id          in     number,
				  x_budget_type_code  in     varchar2,
				  x_resource_list_id  in out NOCOPY number,
		    		  x_err_code          in out NOCOPY number,
		    		  x_err_stage	      in out NOCOPY varchar2,
		    		  x_err_stack         in out NOCOPY varchar2)
  is
     x_budget_amount_code  varchar2(2);
     x_allow_budget_entry_flag  varchar2(2);
     x_baselined_version_id number;
     old_stack varchar2(630);

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_default_resource_list_id';

--           if a baselined budget exists
--           then get the resource_list_id from the baselined budget else get it from
--           pa_project_types

     -- Get the baselined version
     x_err_stage := 'get baselined budget id <' || to_char(x_project_id)
		    || '><' || x_award_id || '>';

     gms_budget_utils.get_baselined_version_id(x_project_id,
                                         x_award_id,
					 x_budget_type_code,
					 x_baselined_version_id,
					 x_err_code,
					 x_err_stage,
					 x_err_stack
					);

     if (x_err_code = 0) then
        -- baselined budget exists, use it to get the resource list

	select resource_list_id
	into   x_resource_list_id
        from   gms_budget_versions
        where  budget_version_id = x_baselined_version_id;

     elsif (x_err_code > 0) then

	-- baseline version does not exist. Get it from pa_project_type
	x_err_code := 0;
        x_err_stage := 'get budget amount code <' ||  x_budget_type_code || '>' ;

	select budget_amount_code
	into   x_budget_amount_code
	from   pa_budget_types
	where  budget_type_code = x_budget_type_code;

	x_err_stage := 'get default resource list id <' || to_char(x_project_id)
			|| '>' ;

	if (x_budget_amount_code = 'C') then

	   select t.allow_cost_budget_entry_flag,
		  t.cost_budget_resource_list_id
	   into   x_allow_budget_entry_flag,
		  x_resource_list_id
	   from   pa_project_types t,
		  pa_projects p
	   where  p.project_id = x_project_id
	   and    p.project_type = t.project_type;

	else

	   select t.allow_rev_budget_entry_flag,
		  t.rev_budget_resource_list_id
	   into   x_allow_budget_entry_flag,
		  x_resource_list_id
	   from   pa_project_types t,
		  pa_projects p
	   where  p.project_id = x_project_id
	   and    p.project_type = t.project_type;

	end if;

	if (x_allow_budget_entry_flag = 'N') then

		gms_error_pkg.gms_message(x_err_name => 'GMS_BU_ENTRY_NOT_ALLOWED',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

	end if;

	if (x_resource_list_id is null) then
		gms_error_pkg.gms_message(x_err_name => 'GMS_BU_NO_DFLT_RESOURCE_LIST',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

/** -- jjj - x_err_code = 100 ???
	    x_err_code := NO_DATA_FOUND_ERR;
	    x_err_stage := 'GMS_BU_NO_DFLT_RESOURCE_LIST';
	    return;
**/
	end if;

	x_err_stack := old_stack;
     else
        -- x_err_code < 0
	return;
     end if;

   exception
	when others
       	then
		gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
	 				x_token_name1 => 'SQLCODE',
	 				x_token_val1 => sqlcode,
	 				x_token_name2 => 'SQLERRM',
		 			x_token_val2 => sqlerrm,
		 			x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

  end get_default_resource_list_id;

-----------------------------------------------------------------------------

  procedure get_default_entry_method_code (x_project_id       in     number,
				  x_budget_type_code          in     varchar2,
				  x_budget_entry_method_code  in out NOCOPY varchar2,
		    		  x_err_code                  in out NOCOPY number,
		    		  x_err_stage	              in out NOCOPY varchar2,
		    		  x_err_stack                 in out NOCOPY varchar2)
  is
     x_budget_amount_code  varchar2(2);
     x_allow_budget_entry_flag  varchar2(2);
     old_stack varchar2(630);

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_default_entry_method_code';

     x_err_stage := 'get budget amount code <' ||  x_budget_type_code || '>' ;

     select budget_amount_code
     into   x_budget_amount_code
     from   pa_budget_types
     where  budget_type_code = x_budget_type_code;

     x_err_stage := 'get default budget entry method <'
		     || to_char(x_project_id) || '>' ;

     if (x_budget_amount_code = 'C') then

        select t.allow_cost_budget_entry_flag,
               t.cost_budget_entry_method_code
        into   x_allow_budget_entry_flag,
               x_budget_entry_method_code
        from   pa_project_types t,
	       pa_projects p
        where  p.project_id = x_project_id
        and    p.project_type = t.project_type;

     else

        select t.allow_rev_budget_entry_flag,
               t.rev_budget_entry_method_code
        into   x_allow_budget_entry_flag,
               x_budget_entry_method_code
        from   pa_project_types t,
	       pa_projects p
        where  p.project_id = x_project_id
        and    p.project_type = t.project_type;

     end if;

     if (x_allow_budget_entry_flag = 'N') then
	 gms_error_pkg.gms_message( x_err_name => 'GMS_BU_ENTRY_NOT_ALLOWED',
	 			x_err_code => x_err_code,
	 			x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
     end if;

     if (x_budget_entry_method_code is null) then
	 gms_error_pkg.gms_message( x_err_name => 'GMS_BU_NO_DFLT_ENTRY_METHOD',
	 			x_err_code => x_err_code,
	 			x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

/** - jjj - x_err_code = 100 ????
         x_err_code := NO_DATA_FOUND_ERR;
         x_err_stage := 'GMS_BU_NO_DFLT_ENTRY_METHOD';
         return;
**/

     end if;

     x_err_stack := old_stack;

  exception
     when others then
	gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
 				x_token_name1 => 'SQLCODE',
 				x_token_val1 => sqlcode,
 				x_token_name2 => 'SQLERRM',
	 			x_token_val2 => sqlerrm,
	 			x_err_code => x_err_code,
 				x_err_buff => x_err_stage);

  end get_default_entry_method_code;

-----------------------------------------------------------------------------

  function get_budget_type_code (x_budget_type in varchar2)
  return varchar2
  is
     x_budget_type_code varchar2(30);
  begin

     x_budget_type_code := NULL;

     select budget_type_code
     into   x_budget_type_code
     from   pa_budget_types
     where  budget_type = x_budget_type;

     return x_budget_type_code;

  exception
     when others then
	 return NULL;
  end get_budget_type_code;

-----------------------------------------------------------------------------

  function get_budget_entry_method_code (x_budget_entry_method in varchar2)
  return varchar2
  is
     x_budget_entry_method_code varchar2(30);
  begin

     x_budget_entry_method_code := NULL;

     select budget_entry_method_code
     into   x_budget_entry_method_code
     from   pa_budget_entry_methods
     where  budget_entry_method = x_budget_entry_method;

     return x_budget_entry_method_code;

  exception
     when others then
	 return NULL;
  end get_budget_entry_method_code;

-----------------------------------------------------------------------------

  function get_change_reason_code (x_meaning in varchar2)
  return varchar2
  is
     x_change_reason_code varchar2(30);
  begin

     x_change_reason_code := NULL;

     select lookup_code
     into   x_change_reason_code
     from   pa_lookups
     where  lookup_type = 'BUDGET CHANGE REASON'
     and    meaning = x_meaning;

     return x_change_reason_code;

  exception
     when others then
	 return NULL;
  end get_change_reason_code;


------------------------------------------------------------------------------

  function check_proj_budget_exists (x_project_id in number,
                                     x_award_id in number,
				     x_budget_status_code varchar2,
				     x_budget_type_code varchar2)
  return number
  is
     dummy number;
  begin

     if (x_budget_status_code = 'A') then
        select 1
        into   dummy
        from   sys.dual
        where  exists
   	       (select 1
	        from   gms_budget_versions
	        where  project_id = x_project_id
                and    award_id   = x_award_id
		and    budget_type_code =
                          nvl(x_budget_type_code, budget_type_code));
        return 1;

     elsif (x_budget_status_code = 'B') then
        select 1
        into   dummy
        from   sys.dual
        where  exists
   	       (select 1
	        from   gms_budget_versions
	        where  project_id = x_project_id
                and    award_id   = x_award_id
		and    budget_type_code =
			  nvl(x_budget_type_code, budget_type_code)
		and    budget_status_code = 'B');
        return 1;

     else
        return 0;
     end if;


  exception
     when NO_DATA_FOUND then
	  return 0;

     when others then
	  return SQLCODE;

  end check_proj_budget_exists;

------------------------------------------------------------------------------

  function check_task_budget_exists (x_task_id in number,
                                     x_award_id in number,
				     x_budget_status_code varchar2,
				     x_budget_type_code varchar2)
  return number
  is
     dummy number;
  begin

     if (x_budget_status_code = 'A') then
        select 1
        into   dummy
        from   sys.dual
        where  exists
   	       (select 1
	        from   gms_budget_versions v,
		       gms_resource_assignments a
	        where  a.task_id = x_task_id
                and    v.award_id = x_award_id
 		and    v.budget_version_id = a.budget_version_id
		and    v.budget_type_code =
                          nvl(x_budget_type_code, v.budget_type_code));
        return 1;

     elsif (x_budget_status_code = 'B') then
        select 1
        into   dummy
        from   sys.dual
        where  exists
   	       (select 1
	        from   gms_budget_versions v,
		       pa_tasks t,
		       gms_resource_assignments a
	        where  a.budget_version_id = v.budget_version_id
		and    v.budget_status_code = 'B'
                and    a.task_id = t.task_id
		and    t.top_task_id = x_task_id
		and    v.award_id = x_award_id
                and    v.budget_type_code =
                          nvl(x_budget_type_code, v.budget_type_code));
        return 1;

     else
        return 0;
     end if;


  exception
     when NO_DATA_FOUND then
	  return 0;

     when others then
	  return SQLCODE;

  end check_task_budget_exists;

---------------------------------------------------------------------------

  function check_resource_member_level (x_resource_list_member_id in number,
				        x_parent_member_id in number,
					x_budget_version_id in number,
					x_task_id in number)
  return number
  is
     dummy number;
  begin

     if (x_parent_member_id = 0) then

        select 1
        into   dummy
        from   sys.dual
        where  exists
   	       (select 1
	        from   pa_resource_list_members m,
		       gms_resource_assignments a
	        where  m.parent_member_id = x_resource_list_member_id
		and    m.resource_list_member_id = a.resource_list_member_id
		and    a.budget_version_id = x_budget_version_id
		and    a.task_id = x_task_id);

     else
        select 1
        into   dummy
        from   sys.dual
        where  exists
   	       (select 1
	        from   gms_resource_assignments a
	        where  a.budget_version_id = x_budget_version_id
		and    a.task_id = x_task_id
                and    a.resource_list_member_id = x_parent_member_id);

     end if;

     return 1;

  exception
     when NO_DATA_FOUND then
	  return 0;

     when others then
	  return SQLCODE;

  end check_resource_member_level;

---------------------------------------------------------------------------
/* commented out for Bug 2601648
Procedure check_overlapping_dates ( x_budget_version_id          NUMBER,
                                       x_resource_name    IN OUT NOCOPY VARCHAR2,
                                       x_err_code         IN OUT NOCOPY NUMBER) is
  v_temp       varchar2(1);
  cursor c is
  select a.resource_name
  from gms_budget_lines_v a, gms_budget_lines_v b
  where a.budget_version_id = x_budget_version_id
  and   b.budget_version_id = x_budget_version_id
  and   a.task_id||null     = b.task_id||null
--  and   a.resource_list_member_id = b.resource_list_member_id Bug 2601648
  and   a.row_id <> b.row_id
  and ((a.start_date
        between b.start_date + 1   -- Bug 2601648 Added + 1
        and nvl(b.end_date,a.start_date +1))
  or   (a.end_date
        between b.start_date
        and nvl(b.end_date - 1,b.end_date+1))  -- Bug 2601648 Added - 1
  or   (b.start_date
        between a.start_date + 1   -- Bug 2601648 Added + 1
        and nvl(a.end_date,b.start_date+1))
      );
BEGIN
  open c;
  fetch c into x_resource_name;
  if c%found then
    x_err_code :=1;
  else
    x_err_code :=0;
  end if;
  close c;
EXCEPTION
  when others then
    x_err_code :=sqlcode;
END check_overlapping_dates;
*/
---------------------------------------------------------------------------
-- select changed for Bug 2601648
Procedure check_overlapping_dates ( x_budget_version_id          NUMBER,
                                       x_resource_name    IN OUT NOCOPY VARCHAR2,
                                       x_err_code         IN OUT NOCOPY NUMBER) is
  v_temp       varchar2(1);
  l_resource_list_member_id   number;
  cursor c is
  select a1.resource_list_member_id
  from gms_resource_assignments a1,
       gms_budget_lines a2,
       gms_resource_assignments b1,
       gms_budget_lines b2
  where a1.resource_assignment_id = a2.resource_assignment_id
  and   b1.resource_assignment_id = b2.resource_assignment_id
  and   a1.budget_version_id = b1.budget_version_id
  and   a1.budget_version_id = x_budget_version_id
  and not (a1.rowid = b1.rowid and a2.rowid = b2.rowid)
  and   b2.end_date >= a2.start_date
  and   b2.start_date <= a2.end_date
  and not (a2.start_date = b2.start_date and a2.end_date = b2.end_date);

  BEGIN
  open c;
  fetch c into l_resource_list_member_id;

  if c%found then
  select alias
  into x_resource_name
  from pa_resource_list_members
  where resource_list_member_id = l_resource_list_member_id;
    x_err_code :=1;
  else
    x_err_code :=0;
  end if;
  close c;
  EXCEPTION
  when others then
    x_err_code :=sqlcode;
  END check_overlapping_dates;

---------------------------------------------------------------------------
  procedure get_proj_budget_amount(
                              x_project_id      in      number,
                              x_award_id        in      number,
                              x_budget_type     in      varchar2,
                              x_which_version   in      varchar2,
                              x_revenue_amount  out NOCOPY     real,
                              x_raw_cost        out NOCOPY     real,
                              x_burdened_cost   out NOCOPY     real,
                              x_labor_quantity  out NOCOPY     real) IS

  budget_status		varchar2(30) := NULL;
  current_flag		varchar2(30) := NULL;
  original_flag 	varchar2(30) := NULL;
  raw_cost 		REAL := 0;
  burdened_cost 	REAL := 0;
  labor_qty 		REAL := 0;
  revenue_amount 	REAL := 0;

  BEGIN

    if x_which_version = 'DRAFT' then

	budget_status := 'O';	-- Non-baselined.

    elsif x_which_version = 'CURRENT' then

	budget_status := 'B';
	current_flag := 'Y';

    else	-- 'ORIGINAL'

	budget_status := 'B';
	original_flag := 'Y';

    end if;

    SELECT nvl(SUM(nvl(b.raw_cost,0)), 0),
	   nvl(SUM(nvl(b.burdened_cost,0)), 0),
	   nvl(SUM(nvl(b.labor_quantity,0)), 0),
           nvl(SUM(nvl(b.revenue,0)), 0)
    INTO   raw_cost,
	   burdened_cost,
	   labor_qty,
           revenue_amount
    FROM   gms_budget_versions b
    WHERE  b.project_id = x_project_id
    AND    b.award_id = x_award_id
    AND    b.budget_type_code = x_budget_type
    AND    b.budget_status_code = decode(budget_status, 'B', 'B',
					b.budget_status_code)
    AND	  NOT (budget_status = 'O' and b.budget_status_code = 'B')
    AND    b.current_flag||'' = nvl(current_flag, b.current_flag)
    AND    b.current_original_flag =
		nvl(original_flag, b.current_original_flag);

    x_raw_cost := raw_cost;
    x_burdened_cost := burdened_cost;
    x_labor_quantity := labor_qty;
    x_revenue_amount := revenue_amount;

  END get_proj_budget_amount;

---------------------------------------------------------------------------

  -- This procedure is copied from pb_public.get_budget_amount and will
  -- be modified later for general use.
  procedure get_task_budget_amount(
                              x_project_id      in      number,
                              x_task_id      	in      number,
                              x_award_id        in      number,
                              x_budget_type     in      varchar2,
                              x_which_version   in      varchar2,
                              x_revenue_amount  out NOCOPY     real,
                              x_raw_cost        out NOCOPY     real,
                              x_burdened_cost   out NOCOPY     real,
                              x_labor_quantity  out NOCOPY     real) IS

  budget_status         varchar2(30) := NULL;
  current_flag          varchar2(30) := NULL;
  original_flag         varchar2(30) := NULL;
  raw_cost              REAL := 0;
  burdened_cost         REAL := 0;
  labor_qty             REAL := 0;
  revenue_amount        REAL := 0;

  BEGIN

    if x_which_version = 'DRAFT' then

        budget_status := 'O';   -- Non-baselined.

    elsif x_which_version = 'CURRENT' then

        budget_status := 'B';
        current_flag := 'Y';

    else        -- 'ORIGINAL'

        budget_status := 'B';
        original_flag := 'Y';

    end if;

    SELECT nvl(SUM(nvl(l.raw_cost,0)), 0),
	   nvl(SUM(nvl(l.burdened_cost,0)), 0),
	   nvl(SUM(decode(a.track_as_labor_flag,'Y',nvl(l.quantity,0),0)), 0),
           nvl(SUM(nvl(l.revenue,0)), 0)
    INTO   raw_cost,
	   burdened_cost,
	   labor_qty,
           revenue_amount
    FROM   gms_budget_lines l,
	   gms_resource_assignments a,
	   pa_tasks t,
	   gms_budget_versions v
    WHERE  v.project_id = x_project_id
    AND    v.award_id = x_award_id
    AND    v.budget_type_code = x_budget_type
    AND    v.budget_status_code = decode(budget_status, 'B', 'B',
                                                v.budget_status_code)
    and NOT (budget_status = 'O' and v.budget_status_code = 'B')
    and    v.current_flag||'' = nvl(current_flag, v.current_flag)
    and    a.budget_version_id = v.budget_version_id
    and    a.project_id = v.project_id
    and    t.project_id = x_project_id
    and    t.task_id = a.task_id
    and    x_task_id in (t.top_task_id, t.task_id)
    and    v.current_original_flag =
                        nvl(original_flag, v.current_original_flag)
    AND    l.resource_assignment_id = a.resource_assignment_id;

    x_raw_cost := raw_cost;
    x_burdened_cost := burdened_cost;
    x_labor_quantity := labor_qty;
    x_revenue_amount := revenue_amount;

  END get_task_budget_amount;

--------------------------------------------------------------------------

--Name:              	Verify_Budget_Rules
--Type:               	Procedure
--
--Description:	This procedure is called both from the Oracle Projects
--		Budgets form (GMSBUEBU.fmb) when the Submit
--		and Baseline buttons are pressed and the
--		public Baseline_Budget api.
--
--		This procedure does the following:
--		1)  It performs Oracle Project product specific
--		     validations.
--		2)  It calls a client extension for additional
--		     client specific validations.
--
--		The procedure also distinguishes between
--		submission edits ('SUBMIT') and
--		baseline edits ('BASELINE') as determined
--		by the value of the p_event parameter.
--
--		Most of the Oracle Project product specific code
--		was copied from the gms_budget_core.baseline
--		procedure. Now, the gms_budget_core.baseline
--		validation calls this procedure.
--
--
--Called subprograms: GMS_Client_Extn_Budget.Verify_Budget_Rulesc
--
--
--
--History:
--
--
PROCEDURE Verify_Budget_Rules
 (p_draft_version_id		IN 	NUMBER
  , p_mark_as_original  	IN	VARCHAR2
  , p_event			IN	VARCHAR2
  , p_project_id		IN	NUMBER
  , p_award_id  		IN	NUMBER
  , p_budget_type_code		IN	VARCHAR2
  , p_resource_list_id		IN	NUMBER
  , p_project_type_class_code	IN 	VARCHAR2
  , p_created_by 		IN	NUMBER
  , p_calling_module		IN	VARCHAR2
  , p_warnings_only_flag	OUT NOCOPY	VARCHAR2
  , p_err_msg_count		OUT NOCOPY	NUMBER
  , p_err_code             	IN OUT NOCOPY	NUMBER
  , p_err_stage			IN OUT NOCOPY	VARCHAR2
  , p_err_stack			IN OUT NOCOPY	VARCHAR2
)

IS
--
    l_entry_level_code		VARCHAR2(30);
    l_dummy			NUMBER;
    l_budget_total 			NUMBER DEFAULT 0;
    l_old_stack			VARCHAR2(630);
    l_funding_level      		VARCHAR2(2) DEFAULT NULL;

    l_ext_warnings_only_flag	VARCHAR2(1)	:= NULL;
    l_ext_err_msg_count		NUMBER	:= 0;


  BEGIN
-- dbms_output.put_line('GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES - Inside');
    IF L_DEBUG = 'Y' THEN
        gms_error_pkg.gms_debug('*** Start of GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES ***','C');
        gms_error_pkg.gms_debug('GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- p_event : '||p_event,'C');
    END IF;

-- Initialize OUT-parameters for multiple error messaging

     p_warnings_only_flag  := 'Y';
     p_err_msg_count 	:= 0;
----------------------------------------------------------------------

     p_err_code := 0;
     l_old_stack := p_err_stack;
     p_err_stack := p_err_stack || '->check_budget_rules';

     IF( PA_UTILS.GetEmpIdFromUser(p_created_by ) IS NULL) THEN
        p_err_stage := 'GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- Error occurred while validating employee info';
	gms_error_pkg.gms_message( x_err_name => 'GMS_ALL_WARN_NO_EMPL_REC',
	 			x_err_code => p_err_code,
 				x_err_buff => p_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

/*
	PA_UTILS.Add_Message
	( p_app_short_name	=> 'GMS'
	  , p_msg_name		=> p_err_stage
	);
*/
	p_warnings_only_flag  := 'N';

    END IF;

  IF (p_event = 'SUBMIT')
  THEN

-- GMS Standard SUBMIT validation - None currently
	NULL;
  ELSE

-- GMS Standard BASELINE validation.

     p_err_stage := 'GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- get draft budget info <' || to_char(p_draft_version_id)
		    || '>';


     -- check if there is at least one project or task draft budget exists

     p_err_stage := 'GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- check budget exists <' || to_char(p_draft_version_id)
		    || '>';

     BEGIN
	select 1
	into   l_dummy
	from   sys.dual
	where  exists
	       (select 1
		from   gms_resource_assignments
		where  budget_version_id = p_draft_version_id);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
        p_err_stage := 'GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- In NO_DATA_FOUND exception';
	gms_error_pkg.gms_message( x_err_name => 'GMS_NO_BUDGET_LINES', -- 'GMS_BU_NO_BUDGET', Bug 2587078
	 			x_err_code => p_err_code,
 				x_err_buff => p_err_stage);

/*	  PA_UTILS.Add_Message
	  ( p_app_short_name	=> 'GMS'
	    , p_msg_name		=> p_err_stage
	   );
*/

	   p_warnings_only_flag  := 'N';


	WHEN OTHERS
	THEN
               p_err_stage := 'GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- In OTHERS exception';
		gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
 					x_token_name1 => 'SQLCODE',
 					x_token_val1 => sqlcode,
 					x_token_name2 => 'SQLERRM',
	 				x_token_val2 => sqlerrm,
		 			x_err_code => p_err_code,
 					x_err_buff => p_err_stage);

		p_warnings_only_flag  := 'N';
		p_err_msg_count	:= FND_MSG_PUB.Count_Msg; -- jjj - ????

/*		   p_err_code := SQLCODE;
		   FND_MSG_PUB.Add_Exc_Msg
			(  p_pkg_name		=> 'GMS_BUDGET_UTILS'
			,  p_procedure_name	=> 'VERIFY_BUDGET_RULES'
			,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                          );
	   p_err_msg_count	:= FND_MSG_PUB.Count_Msg;

	   RETURN;
*/
     END;

END IF; -- OP Standard Validations

-- Client Specific Validations --------------------------------------------------

p_err_stage := 'GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- Check Client Extn Verify Budget Rules <' || to_char(p_project_id )
		    || '><'|| p_budget_type_code
		    || '>'|| to_char(p_draft_version_id)
		    || '>'|| p_mark_as_original
		    || '>';

-- dbms_output.put_line('Call Client Extn VERIFY_BUDGET_RULES');
GMS_CLIENT_EXTN_BUDGET.Verify_Budget_Rules
 (p_draft_version_id		=>	p_draft_version_id
  , p_mark_as_original  	=>	p_mark_as_original
  , p_event			=>	p_event
  , p_project_id        	=>	p_project_id
  , p_budget_type_code  	=>	p_budget_type_code
  , p_resource_list_id		=>	p_resource_list_id
  , p_project_type_class_code	=>	p_project_type_class_code
  , p_created_by 		=>	p_created_by
  , p_calling_module		=>	p_calling_module
  , p_warnings_only_flag	=>	l_ext_warnings_only_flag
  , p_err_msg_count		=>	l_ext_err_msg_count
  , p_error_code             	=>	p_err_code
  , p_error_message		=>	p_err_stage
 );

-- dbms_output.put_line('Return from Client Extn VERIFY_BUDGET_RULES');

-- PA_UTILS.Add_Message already addressed internally by client extn
-- Verify_Budget_Rules
-- Only RETURN if Oracle error. Otherwise, continue processing.

 IF (l_ext_err_msg_count > 0)
  THEN
        IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- GMS_CLIENT_EXTN_BUDGET.Verify_Budget_Rules returned failure status','C');
        END IF;

	IF (l_ext_warnings_only_flag = 'N') THEN
		p_warnings_only_flag  := 'N';
	END IF;
  END IF;

  p_err_msg_count	:= FND_MSG_PUB.Count_Msg;
  p_err_stack := l_old_stack;

  IF L_DEBUG = 'Y' THEN
     gms_error_pkg.gms_debug('*** End of GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES ***','C');
  END IF;

  EXCEPTION
	WHEN OTHERS
	THEN

                p_err_stage := 'GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES- In others exception';
		gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
 					x_token_name1 => 'SQLCODE',
 					x_token_val1 => sqlcode,
 					x_token_name2 => 'SQLERRM',
		 			x_token_val2 => sqlerrm,
		 			x_err_code => p_err_code,
 					x_err_buff => p_err_stage);

		p_warnings_only_flag  := 'N';
		p_err_msg_count	:= FND_MSG_PUB.Count_Msg;

/*	p_err_code := SQLCODE;
	FND_MSG_PUB.Add_Exc_Msg
			(  p_pkg_name		=> 'GMS_BUDGET_UTILS'
			,  p_procedure_name	=> 'VERIFY_BUDGET_RULES'
			,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
 	p_warnings_only_flag  := 'N';
	p_err_msg_count	:= FND_MSG_PUB.Count_Msg;
             RETURN;
*/

END Verify_Budget_Rules;

---------------------------------------------------------------------------

  procedure get_project_task_totals(x_budget_version_id   in     number,
                            x_task_id             in     number,
                            x_quantity_total      in out NOCOPY number,
                            x_raw_cost_total      in out NOCOPY number,
                            x_burdened_cost_total in out NOCOPY number,
                            x_revenue_total       in out NOCOPY number,
			    x_err_code            in out NOCOPY number,
			    x_err_stage	          in out NOCOPY varchar2,
			    x_err_stack           in out NOCOPY varchar2) is
  /****************************************************************
   How to use this API:
   This API can be used to get the totals at the Project Level
   or at the task level. If x_task_id is passed as a null value then
   project level totals are fetched. Otherwise task level totals are
   fetched. For task level totals, first the task level is determined.
   If the task level is top or intermediate level , then the amounts
   are rolled from the child tasks.
  ******************************************************************/

  v_rollup_flag           varchar2(1);
  old_stack                varchar2(630);

   cursor get_rollup_level is
   select 'P'
   from dual
   where x_task_id is null
     union
   select 'T'
   from pa_tasks
   where x_task_id is not null
   and   task_id = x_task_id
   and   parent_task_id is null
      union
   select 'M'
   from pa_tasks
   where x_task_id is not null
   and   task_id = x_task_id
   and   parent_task_id is not null
   and   exists (select 'X'
               from pa_tasks
               where parent_task_id = x_task_id)
      union
   select 'L'
   from dual
   where x_task_id is not null
   and   not exists (select 'X'
                     from pa_tasks
                     where parent_task_id = x_task_id);

   cursor get_totals is
   select labor_quantity,
          raw_cost,
          burdened_cost,
          revenue
   from   gms_budget_versions
   where  v_rollup_flag = 'P'                    -- Project Level
   and    budget_version_id = x_budget_version_id
       union
   select SUM(DECODE(a.TRACK_AS_LABOR_FLAG,'Y',NVL(l.QUANTITY,0),0)),
          SUM(NVL(l.RAW_COST,0)),
          SUM(NVL(l.BURDENED_COST,0)),
          SUM(NVL(l.REVENUE,0))
   from pa_tasks t,
        gms_budget_lines l ,
        gms_resource_assignments a
   where v_rollup_flag = 'T'                      -- Top Task Level
   and   a.budget_version_id = x_budget_version_id
   and   a.task_id = t.task_id
   and   t.top_task_id  = x_task_id
   and   a.resource_assignment_id = l.resource_assignment_id
       union
   select SUM(DECODE(a.TRACK_AS_LABOR_FLAG,'Y',NVL(l.QUANTITY,0),0)),
          SUM(NVL(l.RAW_COST,0)),
          SUM(NVL(l.BURDENED_COST,0)),
          SUM(NVL(l.REVENUE,0))
   from gms_budget_lines l,
        gms_resource_assignments a
   where v_rollup_flag = 'M'                      -- Middle Task Level
   and   a.budget_version_id = x_budget_version_id
   and   a.task_id in (select task_id
                      from pa_tasks
                      start with task_id = x_task_id
                      connect by prior task_id = parent_task_id)
   and   a.resource_assignment_id = l.resource_assignment_id
       union
   select SUM(DECODE(a.TRACK_AS_LABOR_FLAG,'Y',NVL(l.QUANTITY,0),0)),
          SUM(NVL(l.RAW_COST,0)),
          SUM(NVL(l.BURDENED_COST,0)),
          SUM(NVL(l.REVENUE,0))
   from gms_budget_lines l,
        gms_resource_assignments a
   where v_rollup_flag = 'L'                      -- Lowest Task Level
   and   a.budget_version_id = x_budget_version_id
   and   a.task_id = x_task_id
   and   a.resource_assignment_id = l.resource_assignment_id;

  begin
    x_err_code := 0;
    old_stack := x_err_stack;
    x_err_stack := x_err_stack || '->GMS_BUDGET_UTILS.get_project_task_totals';

    open get_rollup_level;
    fetch get_rollup_level into v_rollup_flag;
    close get_rollup_level;
    x_err_stage := x_raw_cost_total;
    open get_totals;
    fetch get_totals into
	  x_quantity_total,
	  x_raw_cost_total,
	  x_burdened_cost_total,
	  x_revenue_total;
    close get_totals;
    x_err_stack := old_stack;

  exception
     when others then
	gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
 				x_token_name1 => 'SQLCODE',
 				x_token_val1 => sqlcode,
 				x_token_name2 => 'SQLERRM',
	 			x_token_val2 => sqlerrm,
	 			x_err_code => x_err_code,
 				x_err_buff => x_err_stage);

--	x_err_code := SQLCODE;
--	return;
  end;

---------------------------------------------------------------------------
--
-- This function returns a value 'Y' if the UOM passed
-- is a currency UOM. Otherwise it returns 'N'.
--
  Function Check_Currency_Uom (x_uom_code in varchar2)
         return varchar2 is
   cursor check_uom is
   select currency_uom_flag
   from pa_currency_uom_v
   where uom_code = x_uom_code;

   v_currency_uom_flag varchar2(1);

  Begin
   open check_uom;
   fetch check_uom into v_currency_uom_flag;
   if check_uom%notfound then
     return 'Y';
   else
     return nvl(v_currency_uom_flag,'Y');
   end if;
   close check_uom;

  End;

---------------------------------------------------------------------------
--
-- This function returns the value of budget amount code
-- associated with the budget type. Budget Amount Code
-- determines whethere its a cost or a revenue budget.
--
  Function get_budget_amount_code (x_budget_type_code in varchar2)
           return varchar2 is
   cursor get_budget_amount_code is
   select budget_amount_code
   from pa_budget_types
   where budget_type_code = x_budget_type_code;

   v_budget_amount_code varchar2(1);

  Begin
    open get_budget_amount_code ;
    fetch get_budget_amount_code into v_budget_amount_code;
    close get_budget_amount_code;

    return v_budget_amount_code;
  End;

---------------------------------------------------------------------------

-- Assigning the value of Budget Entry Level Code to a global
-- variable.
  Procedure set_entry_level_code(x_entry_level_code in varchar2) is
  Begin
    g_entry_level_code := x_entry_level_code;
  End;

---------------------------------------------------------------------------
-- Returning the value of global variable for Budget Entry Level Code
  Function get_entry_level_code return varchar2 is
  Begin
    return g_entry_level_code;
  End;
----------------------------------------------------------------------------------------
--Name:               get_valid_period_dates
--Type:               Procedure
--Description:        This procedure can be used to get the valid begin and end date
--		      for a budget line
--
--
--Called subprograms:
--
--
--History:
--

PROCEDURE get_valid_period_dates
( x_err_code			OUT NOCOPY	NUMBER
 ,x_err_stage			OUT NOCOPY	VARCHAR2
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_award_id			IN	NUMBER	-- Added For bug 2200867
 ,p_time_phased_type_code	IN	VARCHAR2
 ,p_entry_level_code		IN	VARCHAR2
 ,p_period_name_in		IN	VARCHAR2
 ,p_budget_start_date_in	IN	DATE
 ,p_budget_end_date_in		IN	DATE
 ,p_period_name_out		OUT NOCOPY	VARCHAR2
 ,p_budget_start_date_out	OUT NOCOPY	DATE
 ,p_budget_end_date_out		OUT NOCOPY	DATE	)

IS

   CURSOR l_budget_periods_csr
   	  (p_period_name 	VARCHAR2
   	  ,p_period_type_code	VARCHAR2	)
   IS
   SELECT period_start_date
   ,      period_end_date
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND 	  period_type_code = p_period_type_code;

   CURSOR l_period_name_csr
          (p_start_date		DATE
          ,p_end_date		DATE
          ,p_period_type_code   VARCHAR2 )
   IS
   SELECT period_name
   FROM   pa_budget_periods_v
   WHERE  period_type_code = p_period_type_code
   AND    period_start_date = p_start_date
   AND    period_end_date = p_end_date;


   CURSOR l_project_dates_csr
   	  ( p_project_id NUMBER )
   IS
   SELECT start_date
   ,      completion_date
   FROM   pa_projects
   WHERE  project_id = p_project_id;

   CURSOR l_task_dates_csr
   	  ( p_task_id NUMBER )
   IS
   SELECT start_date
   ,      completion_date
   FROM   pa_tasks
   WHERE  task_id = p_task_id;

--Added For Bug 2200867
  CURSOR l_award_dates_csr
	 (p_award_id NUMBER)
  IS
  SELECT nvl(preaward_date,start_date_active), -- Added preaward_date for Bug:2266731
	 end_date_active
  FROM   gms_awards
  WHERE  award_id = p_award_id;

   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'get_valid_period_dates';
   l_task_start_date				DATE;
   l_task_end_date				DATE;
   l_project_start_date				DATE;
   l_project_end_date				DATE;
   l_budget_start_date				DATE;
   l_budget_end_date				DATE;
   l_period_name				VARCHAR2(20);

BEGIN
	x_err_code := 0;

      IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('*** Start of GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES ***','C');
      END IF;

--  Standard begin of API savepoint

    SAVEPOINT get_valid_period_dates_pvt;

-- The following IF statement is added for Bug:2362968 (GMS_BUDGET_PUB.ADD_BUDGET_LINE ACCEPTING INVALID DATES)

	IF p_budget_start_date_in > p_budget_end_date_in THEN
		x_err_stage := 'GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- Error occured while validating the dates';
		gms_error_pkg.gms_message(x_err_name => 'GMS_SU_INVALID_DATES',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

	-- check business rules related to timephasing
	-- P = PA period, G = GL period, R = Date Range

    	IF p_time_phased_type_code = 'P'
    	OR p_time_phased_type_code = 'G'
    	THEN

-- dbms_output.put_line('Time phased code: '||p_time_phased_type_code);
-- dbms_output.put_line('Period name     : '||p_period_name_in);

	    IF p_period_name_in IS NULL
	    OR p_period_name_in = GMS_BUDGET_PUB.G_PA_MISS_CHAR
	    THEN

		IF p_budget_start_date_in IS NULL
		OR p_budget_start_date_in = GMS_BUDGET_PUB.G_PA_MISS_DATE
		OR p_budget_end_date_in IS NULL
		OR p_budget_end_date_in = GMS_BUDGET_PUB.G_PA_MISS_DATE
		THEN
                        x_err_stage := 'GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- error occurred while calculating dates for Time phase = PA/GL';
	 		gms_error_pkg.gms_message( x_err_name => 'GMS_BUDGET_DATES_MISSING',
	 				x_err_code => x_err_code,
		 			x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		ELSE

		--try to get the period name related to those dates

			OPEN l_period_name_csr(  p_budget_start_date_in
						,p_budget_end_date_in
						,p_time_phased_type_code  );

			FETCH l_period_name_csr INTO l_period_name;

-- dbms_output.put_line('Period name: '||l_period_name);

			IF l_period_name_csr%NOTFOUND
			THEN
				CLOSE l_period_name_csr;
                                x_err_stage := 'GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- Error occurred while calculating dates for Time phase = PA/GL';
		 		gms_error_pkg.gms_message( x_err_name => 'GMS_BUDGET_DATES_INVALID',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

				APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;

			CLOSE l_period_name_csr;

			p_budget_start_date_out := p_budget_start_date_in;
			p_budget_end_date_out := p_budget_end_date_in;
			p_period_name_out := l_period_name;
		END IF;

	    ELSE

    		--get the related start and end dates
		OPEN l_budget_periods_csr
      			( p_period_name_in
                	, p_time_phased_type_code	);


		FETCH l_budget_periods_csr
		INTO l_budget_start_date, l_budget_end_date;

		IF l_budget_periods_csr%NOTFOUND
		THEN
			CLOSE l_budget_periods_csr;
                        x_err_stage := 'GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- Error occurred while calculating dates for Time phase = PA/GL';
	 		gms_error_pkg.gms_message( x_err_name => 'GMS_BUDGET_PERIOD_IS_INVALID',
			x_err_code => x_err_code,
			x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

		CLOSE l_budget_periods_csr;

		p_budget_start_date_out := l_budget_start_date;
		p_budget_end_date_out := l_budget_end_date;
		p_period_name_out := p_period_name_in;

	    END IF; --is period_name_in missing

    	ELSIF	p_time_phased_type_code = 'R'
    	THEN

    		--validation of incoming dates

		IF p_budget_start_date_in = GMS_BUDGET_PUB.G_PA_MISS_DATE
		OR p_budget_start_date_in IS NULL
		THEN
                        x_err_stage :=  'GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- Error occurred while calculating dates for Time phase = R';
	 		gms_error_pkg.gms_message( x_err_name => 'GMS_BUDGET_DATES_MISSING' ,-- 'GMS_START_DATE_IS_MISSING', Bug 2587078
			x_err_code => x_err_code,
			x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

		IF p_budget_end_date_in = GMS_BUDGET_PUB.G_PA_MISS_DATE
		OR p_budget_end_date_in IS NULL
		THEN
                        x_err_stage :=  'GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- Error occurred while calculating dates for Time phase = R';
	 		gms_error_pkg.gms_message( x_err_name => 'GMS_BUDGET_DATES_MISSING', -- 'GMS_END_DATE_IS_MISSING', Bug 2587078
			x_err_code => x_err_code,
			x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;


-- For entry methods specified as 'date range',  start and end dates were not being returned.
--
		p_budget_start_date_out := p_budget_start_date_in;
		p_budget_end_date_out   := p_budget_end_date_in;
		p_period_name_out := p_period_name_in;
-- -------------------------------------------------------------------------------------------------------------


    	ELSE   --time_phased_type_code = 'N'

		--Modifications for Bug 2200867
		OPEN l_award_dates_csr(p_award_id);
		FETCH l_award_dates_csr INTO l_budget_start_date, l_budget_end_date;
		CLOSE l_award_dates_csr;

    		IF p_entry_level_code = 'P'
    		THEN

    			OPEN l_project_dates_csr(p_project_id);
    			FETCH l_project_dates_csr INTO l_project_start_date, l_project_end_date;
    			CLOSE l_project_dates_csr;

    			IF l_project_start_date IS NULL
    			THEN
                                x_err_stage :=  'GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- Error occurred while calculating dates for Time phase = N and entry level code ='||p_entry_level_code;
		 		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_NO_TASK_PROJ_DATE' , --'GMS_PROJ_START_DATE_MISS1', 2587078
							x_err_code => x_err_code,
							x_err_buff => x_err_stage);

				APP_EXCEPTION.RAISE_EXCEPTION;
	--Modifications for Bug 2200867
			END IF;
/************Commenting the code for Bug 2200867
			ELSIF l_project_end_date IS NULL
			THEN

		 		gms_error_pkg.gms_message( x_err_name => 'GMS_PROJ_END_DATE_MISS1',
							x_err_code => x_err_code,
							x_err_buff => x_err_stage);

				APP_EXCEPTION.RAISE_EXCEPTION;

			ELSE
************************/
			-------Modiifed the p_budget_start_date_out and p_budget_end_date For bug 2200867-----------
    				p_budget_start_date_out := greatest(l_budget_start_date,l_project_start_date);
    				p_budget_end_date_out   := least(l_budget_end_date,nvl(l_project_end_date,l_budget_end_date));
			-----End of Changes----------
    				p_period_name_out := p_period_name_in;

    		--	END IF;   Moved the END IF up

    		ELSIF p_entry_level_code IN ('T','M','L')
    		THEN

			OPEN l_task_dates_csr(p_task_id);
    			FETCH l_task_dates_csr INTO l_task_start_date, l_task_end_date;
    			CLOSE l_task_dates_csr;

    			IF l_task_start_date IS NULL
    			OR l_task_end_date IS NULL
     			THEN
   				OPEN l_project_dates_csr(p_project_id);
    				FETCH l_project_dates_csr INTO l_project_start_date, l_project_end_date;
    				CLOSE l_project_dates_csr;
			END IF;  -- Moved the End If Up as part of Bug 2200867

				IF l_task_start_date IS NULL  --implies that task_end_date is null too!!
				THEN

    					IF l_project_start_date IS NULL  --implies that project end date is null too
    					THEN
                                                x_err_stage :=  'GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- Error occurred while calculating dates for Time phase = N and entry level code ='||p_entry_level_code;
				 		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_NO_TASK_PROJ_DATE' , -- 'GMS_PROJ_START_DATE_MISS2', 2587078
									x_err_code => x_err_code,
									x_err_buff => x_err_stage);

						APP_EXCEPTION.RAISE_EXCEPTION;

					---------Modifications for Bug 2200867-------------------
    					ELSE
						l_budget_start_date := greatest(l_budget_start_date,l_project_start_date);
						l_budget_end_date := least(l_budget_end_date,nvl(l_project_end_date,l_budget_end_date));
					END IF;
	         		ELSE --Task start date is not null
						l_budget_start_date:= greatest(l_budget_start_date,l_task_start_date);

						IF l_task_end_date IS NULL THEN
						 l_budget_end_date:=least(l_budget_end_date,nvl(l_project_end_date,l_budget_end_date));
						ELSE
						 l_budget_end_date:=least(l_budget_end_date,l_task_end_date);
						END IF;
	    			END IF;
 				p_budget_start_date_out  := l_budget_start_date;
                  	 	p_budget_end_date_out    := l_budget_end_date;
	                    	p_period_name_out	 := p_period_name_in;
/*****************Commenting for Bug 2200867
					ELSIF l_project_end_date IS NULL
					THEN
				 		gms_error_pkg.gms_message( x_err_name => 'GMS_PROJ_END_DATE_MISS2',
									x_err_code => x_err_code,
									x_err_buff => x_err_stage);

						APP_EXCEPTION.RAISE_EXCEPTION;

					ELSE

						p_budget_start_date_out := l_project_start_date;
						p_budget_end_date_out := l_project_end_date;
						p_period_name_out := p_period_name_in;

					END IF;

				ELSIF l_task_start_date IS NOT NULL
				AND   l_task_end_date IS NULL
				THEN

    					IF l_project_end_date IS NULL
    					THEN

				 		gms_error_pkg.gms_message( x_err_name => 'GMS_PROJ_END_DATE_MISS3',
									x_err_code => x_err_code,
									x_err_buff => x_err_stage);

						APP_EXCEPTION.RAISE_EXCEPTION;

					ELSE
						p_budget_start_date_out := l_task_start_date;
						p_budget_end_date_out := l_project_end_date;
						p_period_name_out := p_period_name_in;

					END IF;

				END IF;

			ELSE
				p_budget_start_date_out  := l_task_start_date;
				p_budget_end_date_out 	:= l_task_end_date;
				p_period_name_out := p_period_name_in;

			END IF;
********************************/

		END IF;  --entry level code

    	END IF;  --time phased type code

/**
-- Commented out NOCOPY the Exception section as a part of Bug:2362968 (GMS_BUDGET_PUB.ADD_BUDGET_LINE ACCEPTING INVALID DATES)
-- since there is no necessity to rollback anything here and also commenting this out NOCOPY will cause the actual error message
-- to show up during any error condition.

EXCEPTION
	WHEN OTHERS
	THEN
                IF L_DEBUG = 'Y' THEN
                    gms_error_pkg.gms_debug('GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES- In OTHERS exception','C');
                END IF;

		ROLLBACK TO get_valid_period_dates_pvt;

		x_err_code := 10;
		x_err_stage := 'GMS_GET_PERIOD_DATE_FAIL';
**/

IF L_DEBUG = 'Y' THEN
   gms_error_pkg.gms_debug('*** End of GMS_BUDGET_UTILS.GET_VALID_PERIOD_DATES ***','C');
END IF;

END get_valid_period_dates;


----------------------------------------------------------------------------------------
--Name:               check_entry_method_flags
--Type:               Procedure
--Description:        This procedure can be used to check whether it is allowed to pass
--		      cost quantity, raw_cost, burdened_cost, revenue and revenue quantity.
--
--
--Called subprograms:
--
--
--
--History:
--

PROCEDURE check_entry_method_flags
( x_err_code			OUT NOCOPY	NUMBER
 ,x_err_stage			OUT NOCOPY	VARCHAR2
 ,p_budget_amount_code		IN	VARCHAR2
 ,p_budget_entry_method_code	IN	VARCHAR2
 ,p_quantity			IN	VARCHAR2
 ,p_raw_cost			IN	VARCHAR2
 ,p_burdened_cost		IN 	VARCHAR2)
IS

   CURSOR	l_budget_entry_method_csr
   		(p_budget_entry_method_code pa_budget_entry_methods.budget_entry_method_code%type )
   IS
   SELECT cost_quantity_flag
   ,	  raw_cost_flag
   ,	  burdened_cost_flag
   ,	  rev_quantity_flag
   FROM   pa_budget_entry_methods
   WHERE  budget_entry_method_code = p_budget_entry_method_code
   AND 	  trunc(sysdate) BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));

   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'check_entry_method_flags';

   l_cost_quantity_flag		VARCHAR2(1);
   l_raw_cost_flag		VARCHAR2(1);
   l_burdened_cost_flag		VARCHAR2(1);
   l_rev_quantity_flag		VARCHAR2(1);


BEGIN

	x_err_code := 0;

--  Standard begin of API savepoint

    SAVEPOINT check_entry_method_flags_pvt;

-- dbms_output.put_line('In check_entry_method_flags');

    OPEN l_budget_entry_method_csr(p_budget_entry_method_code);
    FETCH l_budget_entry_method_csr INTO l_cost_quantity_flag
   					,l_raw_cost_flag
   					,l_burdened_cost_flag
   					,l_rev_quantity_flag;

    CLOSE l_budget_entry_method_csr;

    	-- checking on mandatory flags

	IF p_budget_amount_code = 'C'   --COST BUDGET
	THEN
		IF l_cost_quantity_flag = 'N'
		AND (    p_quantity <> GMS_BUDGET_PUB.G_PA_MISS_NUM
		      AND p_quantity IS NOT NULL )
		THEN
	 		gms_error_pkg.gms_message( x_err_name => 'GMS_COST_QTY_NOT_ALLOWED',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		ELSIF l_raw_cost_flag = 'N'
		AND (    p_raw_cost <> GMS_BUDGET_PUB.G_PA_MISS_NUM
		      AND p_raw_cost IS NOT NULL )
		THEN
	 		gms_error_pkg.gms_message( x_err_name => 'GMS_RAW_COST_NOT_ALLOWED',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;

		ELSIF l_burdened_cost_flag = 'N'
		AND (    p_burdened_cost <> GMS_BUDGET_PUB.G_PA_MISS_NUM
		      AND p_burdened_cost IS NOT NULL )
		THEN
	 		gms_error_pkg.gms_message( x_err_name => 'GMS_BURD_COST_NOT_ALLOWED',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

	END IF;

EXCEPTION
	WHEN OTHERS
	THEN

		ROLLBACK TO check_entry_method_flags_pvt;
/**
	x_err_code := 10;
	x_err_stage := 'GMS_CHK_ENTRY_METHOD_FLG_FAIL';
	return;
**/

END check_entry_method_flags;

Procedure set_cross_bg_profile is
begin
  fnd_profile.put('HR_CROSS_BUSINESS_GROUP', 'N');
end set_cross_bg_profile;

-- --------------------------------------------------------------------------------

--Name:         Set_Award_Policy_Context
--Type:         Procedure
--
--Description:  This procedure is called primarily from the following Budget Workflow packages
--              related procedures:
--              a) Budget Approval Workflow
--              b) Budget Integration workflow
--
--              This procedure does the following:
--              a) Derives org_id from project_id
--              b) Passes org_id to mo_global.set_policy_context
--
--Other Notes:
--
--
--
--
--
--Called subprograms: none
--
--

   Procedure Set_Award_Policy_Context
             (
              p_award_id                      IN            NUMBER
              , x_msg_count                     OUT NOCOPY    NUMBER
              , x_msg_data                      OUT NOCOPY    VARCHAR2
              , x_return_status                 OUT NOCOPY    VARCHAR2
              , x_err_code                      OUT NOCOPY    NUMBER
             )
   IS

       l_org_id          gms_awards_all.org_id%TYPE := NULL;

   Begin
        -- Assume Success
        x_return_status      := FND_API.G_RET_STS_SUCCESS;
        x_msg_count          := 0;
        x_msg_data           := NULL;
        x_err_code           := 0;


        -- Fetch Award Org_Id
        -- This should NOT fail since it should have been fully validated
        -- by the calling object.

        SELECT org_id
        INTO   l_org_id
        FROM   gms_awards_all
	WHERE award_id = p_award_id;

        -- Set the Operating Unit Context
        mo_global.set_policy_context(p_access_mode => 'S'
                                      ,   p_org_id      =>  l_org_id );



        EXCEPTION
          WHEN OTHERS THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 x_err_code      := SQLCODE;
                 FND_MSG_PUB.Add_Exc_Msg
                 (  p_pkg_name       => 'GMS_BUDGET_UTILS'
                    ,  p_procedure_name => 'SET_AWARD_POLICY_cONTEXT'
                    ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
                 FND_MSG_PUB.Count_And_Get
                 (p_count       =>  x_msg_count ,
                  p_data        =>  x_msg_data  );
                 RETURN;


   END Set_Award_Policy_Context;

   -- Bug 5045636 : Created the procedure get_task_number to fetch the task_name for a particular task_id.

   FUNCTION get_task_number(P_task_Id  IN NUMBER) RETURN VARCHAR2 IS

	CURSOR c_task_name IS
	SELECT task_name
	  FROM pa_tasks
	 WHERE task_id = P_task_Id;

	Begin
             If p_task_id = g_task_id then
	          RETURN g_task_number ;
             Else
	          g_task_id := p_task_id;
		  OPEN c_task_name;
		  FETCH c_task_name INTO g_task_number;
		  CLOSE c_task_name;
	    	  RETURN g_task_number;
             end if;

   End GET_TASK_NUMBER;


END gms_budget_utils;

/
