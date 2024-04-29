--------------------------------------------------------
--  DDL for Package Body GMS_BUDGET_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BUDGET_CORE" AS
/* $Header: gmsbubcb.pls 120.2.12010000.2 2008/12/23 05:31:34 prabsing ship $ */

  -- To check on, whether to print debug messages in log file or not
  L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

  /***************** commenting this whole procedure for perf fix 4007119.
  procedure shift_periods(x_start_period_date in date,
			  x_periods      in  number,
			  x_period_name  in out NOCOPY varchar2,
			  x_period_type  in varchar2,
			  x_start_date   in out NOCOPY date,
			  x_end_date     in out NOCOPY date,
			  x_err_code     in out NOCOPY number,
			  x_err_stage    in out NOCOPY varchar2,
			  x_err_stack    in out NOCOPY varchar2)
  is
  cursor c is
  select period_name, period_start_date , period_end_date
  from pa_budget_periods_v
  where period_type_code= x_period_type
  and   period_start_date > x_start_period_date
  order by period_start_date ;

  cursor c1 is
  select period_name, period_start_date , period_end_date
  from PA_budget_periods_v
  where period_type_code= x_period_type
  and   period_start_date < x_start_period_date
  order by period_start_date  desc;

  old_stack			varchar2(630);
  number_period   number(10);

  begin
    x_err_code := 0;
    old_stack := x_err_stack;
    x_err_stack := x_err_stack || '->shift_periods';

    if x_periods > 0 then

      select count(*)
      into   number_period
      from pa_budget_periods_v
      where period_type_code= x_period_type
      and   period_start_date > x_start_period_date;

	if number_period < abs(x_periods) then
		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_INVALID_NEW_PERIOD',
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	 end if;

      open c;
      for i in 1..abs(x_periods)
      loop
      fetch c into x_period_name, x_start_date, x_end_date;
      exit when c%notfound;
      end loop;
      close c;
    elsif x_periods < 0 then

      select count(*)
      into   number_period
      from pa_budget_periods_v
      where period_type_code= x_period_type
      and   period_start_date < x_start_period_date;

      if number_period < abs(x_periods) then
 		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_INVALID_NEW_PERIOD',
					x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
       end if;

      open c1;
      for i in 1..abs(x_periods)
      loop
      fetch c1 into x_period_name, x_start_date, x_end_date;
      exit when c1%notfound;
      end loop;
      close c1;
    end if;

    ***********************/
    -- Bug 4007119 .. shift_periods re-written to use pl/sql tables.

  procedure shift_periods(x_start_period_date in date,
			  x_periods      in  number,
			  x_period_name  in out NOCOPY varchar2,
			  x_period_type  in varchar2,
			  x_start_date   in out NOCOPY date,
			  x_end_date     in out NOCOPY date,
			  x_err_code     in out NOCOPY number,
			  x_err_stage    in out NOCOPY varchar2,
			  x_err_stack    in out NOCOPY varchar2)
  is

    TYPE tt_date is table of date;
    TYPE tt_period_name is table of varchar2(30);

    t_start_date   tt_date;
    t_end_date     tt_date;
    t_period_name  tt_period_name;

    old_stack	         varchar2(630);
    number_period        number(10);
    current_period_index number;
    shift_by_index       number;

    begin

    x_err_code := 0;
    old_stack := x_err_stack;
    x_err_stack := x_err_stack || '->shift_periods';

    if x_period_type = 'P' then

      select  p.period_name, p.start_date, p.end_date
        bulk collect into t_period_name, t_start_date, t_end_date
        from pa_periods p
       order by p.start_date;

    elsif x_period_type = 'G' then

      select p.period_name, p.start_date, p.end_date
        bulk collect into t_period_name, t_start_date, t_end_date
        from gl_period_statuses p, pa_implementations i
       where i.set_of_books_id = p.set_of_books_id
         and p.application_id = pa_period_process_pkg.application_id
         and p.adjustment_period_flag = 'N'
       order by p.start_date;

    end if;

    number_period := 0;

    if x_periods > 0 then

      for i in t_start_date.first..t_start_date.last loop
          if t_start_date(i) = x_start_period_date then
             current_period_index := i;
          end if;
          if t_start_date(i) > x_start_period_date then
             number_period := number_period + 1;
          end if;
      end loop;

	if number_period < x_periods then
		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_INVALID_NEW_PERIOD',
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	 end if;

      -- the new budget starts later than the source budget.
      -- identify the period by advancing the index to the appropriate period.
      -- pl/sql table is order by start_date asc.

      shift_by_index := current_period_index + x_periods;

      x_period_name := t_period_name(shift_by_index);
      x_start_date  := t_start_date(shift_by_index);
      x_end_date    := t_end_date(shift_by_index);

    elsif x_periods < 0 then

      for i in t_start_date.first..t_start_date.last loop
          if t_start_date(i) = x_start_period_date then
             current_period_index := i;
          end if;
          if t_start_date(i) < x_start_period_date then
             number_period := number_period + 1;
          end if;
      end loop;

      if number_period < abs(x_periods) then
 		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_INVALID_NEW_PERIOD',
					x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
       end if;

      -- the new budget starts earlier than the source budget.
      -- identify the period by moving back the index to the appropriate period.
      -- pl/sql table is order by start_date asc.

      shift_by_index := current_period_index - abs(x_periods);

      x_period_name := t_period_name(shift_by_index);
      x_start_date  := t_start_date(shift_by_index);
      x_end_date    := t_end_date(shift_by_index);

    end if;

    t_period_name.delete;
    t_start_date.delete;
    t_end_date.delete;

    x_err_stack := old_stack;

 exception
   when NO_DATA_FOUND
   then
	gms_error_pkg.gms_message( x_err_name => 'GMS_BU_INVALID_NEW_PERIOD',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);


   when OTHERS then
	gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
 				x_token_name1 => 'SQLCODE',
 				x_token_val1 => sqlcode,
 				x_token_name2 => 'SQLERRM',
	 			x_token_val2 => sqlerrm,
	 			x_err_code => x_err_code,
 				x_err_buff => x_err_stage);

--      x_err_code := SQLCODE;
--      return;
 end;
-------------------------------------------------------------------------------
-- procedure get_periods identifies the number of periods between the start of
-- source budget and dest budget. this is used by shift_periods procedure to
-- identify the details of the new period.

 procedure get_periods(x_start_date1 in date,
                       x_start_date2 in date,
		       x_period_type  in varchar2,
                       x_periods   in out NOCOPY  number,
                       x_err_code          in out NOCOPY number,
                       x_err_stage         in out NOCOPY varchar2,
                       x_err_stack         in out NOCOPY varchar2)
 is
 x_period_start_date1 date;
 x_period_start_date2 date;

 /********** commented out for bug 4007119
 cursor c is
 select count(1) -1
 from pa_budget_periods_v
 where period_type_code= x_period_type
 and   period_start_date between least(x_period_start_date1,x_period_start_date2) and greatest(x_period_start_date1,x_period_start_date2);
 ********** commented out for bug 4007119 ****/

 old_stack			varchar2(630);
 begin
   x_err_code := 0;
   old_stack := x_err_stack;
   x_err_stack := x_err_stack || '->get_periods';

    -- Bug 4007119..changed the code to use base tables instead of pa_budget_periods_v view.

    if x_period_type = 'P' then

       select start_date
       into   x_period_start_date1
       from   pa_periods
       where  x_start_date1 between start_date and end_date;

      select start_date
      into   x_period_start_date2
      from   pa_periods
      where  x_start_date2 between start_date and end_date;

      select count(1) - 1
      into   x_periods
      from   pa_periods
      where  start_date between least(x_period_start_date1, x_period_start_date2)
             and greatest(x_period_start_date1, x_period_start_date2);

    elsif x_period_type = 'G' then

      select p.start_date
        into x_period_start_date1
        from gl_period_statuses p, pa_implementations i
       where i.set_of_books_id = p.set_of_books_id
         and p.application_id = pa_period_process_pkg.application_id
         and p.adjustment_period_flag = 'N'
         and x_start_date1 between p.start_date and p.end_date;

      select p.start_date
        into x_period_start_date2
        from gl_period_statuses p, pa_implementations i
       where i.set_of_books_id = p.set_of_books_id
         and p.application_id = pa_period_process_pkg.application_id
         and p.adjustment_period_flag = 'N'
         and x_start_date2 between p.start_date and p.end_date;

      select count(1) - 1
        into x_periods
        from gl_period_statuses p, pa_implementations i
       where i.set_of_books_id = p.set_of_books_id
         and p.application_id = pa_period_process_pkg.application_id
         and p.adjustment_period_flag = 'N'
         and p.start_date between least(x_period_start_date1,x_period_start_date2)
             and greatest(x_period_start_date1,x_period_start_date2);

    end if;

   /**** commented out for bug 4007119
   open c;
   fetch c into x_periods;
   close c;
   *********/

   if x_start_date1 > x_start_date2 then
     x_periods := -1* x_periods;
   end if;

   x_err_stack := old_stack;

 exception
   when NO_DATA_FOUND
   then
	gms_error_pkg.gms_message( x_err_name => 'GMS_BU_INVALID_NEW_PERIOD',
 	 			x_err_code => x_err_code,
 				x_err_buff => x_err_stage);

   when OTHERS
   then
	gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
 				x_token_name1 => 'SQLCODE',
 				x_token_val1 => sqlcode,
 				x_token_name2 => 'SQLERRM',
	 			x_token_val2 => sqlerrm,
	 			x_err_code => x_err_code,
 				x_err_buff => x_err_stage);

--      x_err_code := SQLCODE;
--      return;
 end;

------------------------------------------------------------------------------

  procedure baseline (x_draft_version_id  in     number,
		      x_mark_as_original  in     varchar2,
		      x_verify_budget_rules in	 varchar2 default 'Y',
		      x_err_code          in out NOCOPY number,
		      x_err_stage	  in out NOCOPY varchar2,
		      x_err_stack         in out NOCOPY varchar2)

  IS
    -- Standard who
    x_created_by                number(15);
    x_last_update_login         number(15);

    x_project_id		number(15);
    x_award_id			number(15);
    x_budget_type_code		varchar2(30);
    max_version			number(15);
    x_dest_version_id		number(15);
    x_entry_level_code		varchar2(30);
    x_project_type_class_code	varchar2(30);
    dummy			number;
    budget_total 		number default 0;
    old_stack			varchar2(630);
    x_resource_list_assgmt_id   number;
    x_resource_list_id 	        number;
    x_baselined_version_id      number;
    x_funding_level      	varchar2(2) default NULL;
    x_time_phased_type_code     varchar2(30);

    l_warnings_only_flag	VARCHAR2(1) 	:= 'Y';
    l_err_msg_count	NUMBER 	:= 0;
    v_project_start_date        date;
    v_project_completion_date   date;
    v_emp_id                    number;

    x_budget_start_date		date;
    x_budget_end_date		date;
    x_period_name 		varchar2(20);


  BEGIN

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('*** Start of GMS_BUDGET_CORE.BASELINE ***','C');
     END IF;

     savepoint before_baseline;

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->baseline';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

-- This call is repeated in  GMS_BUDGET_UTILS.Verify_Budget_Rules
-- as the APIs call that procedure. Using v_emp_id eliminates join
-- to fnd_user while inserting record in gms_budget_versions

     v_emp_id := PA_UTILS.GetEmpIdFromUser(x_created_by );

     if v_emp_id IS NULL then
        x_err_stage := 'GMS_BUDGET_CORE.BASELINE - Error occurred while validating employee information';
	gms_error_pkg.gms_message( x_err_name => 'GMS_ALL_WARN_NO_EMPL_REC',
	 			x_err_code => x_err_code,
 				x_err_buff => x_err_stage);

        fnd_msg_pub.add; --Bug 2587078

	APP_EXCEPTION.RAISE_EXCEPTION;
     end if;

     x_err_stage := 'get draft budget info <' || to_char(x_draft_version_id)
		    || '>';

     select v.project_id, v.award_id, v.budget_type_code, v.resource_list_id,
	    t.project_type_class_code,time_phased_type_code,
            entry_level_code
     into   x_project_id, x_award_id, x_budget_type_code, x_resource_list_id,
     	    x_project_type_class_code,x_time_phased_type_code,
            x_entry_level_code
     from   pa_project_types t,
	    pa_projects p,
	    gms_budget_versions v,
            pa_budget_entry_methods b
     where  v.budget_version_id = x_draft_version_id
     and    v.project_id = p.project_id
     and    b.budget_entry_method_code = v.budget_entry_method_code
     and    p.project_type = t.project_type;

---------------------------------------------------------------------------------------

-- Need to check if call is for verification purpose only

     IF ( x_verify_budget_rules = 'Y' )
     THEN

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling GMS_BUDGET_UTILS.Verify_Budget_Rules - Baseline','C');
     END IF;

       GMS_BUDGET_UTILS.Verify_Budget_Rules
         (p_draft_version_id		=>	x_draft_version_id
        , p_mark_as_original  		=>	x_mark_as_original
        , p_event			=>	'BASELINE'
        , p_project_id			=>	x_project_id
        , p_award_id			=>	x_award_id
        , p_budget_type_code		=>	x_budget_type_code
        , p_resource_list_id		=>	x_resource_list_id
        , p_project_type_class_code	=>	x_project_type_class_code
        , p_created_by 			=>	x_created_by
        , p_calling_module		=>	'GMSBUBCB'
        , p_warnings_only_flag		=>	l_warnings_only_flag
        , p_err_msg_count		=>	l_err_msg_count
        , p_err_code			=> 	x_err_code
        , p_err_stage			=> 	x_err_stage
        , p_err_stack			=> 	x_err_stack
          );

        -- Bug 2587078 : Replacing check from l_err_msg_count > 0 to x_err_code <> 0
        -- as the l_err_msg_count is not set in all the error cases .

        --IF (l_err_msg_count > 0)
        IF (x_err_code <> 0)
        THEN
	IF (l_warnings_only_flag = 'N') THEN
                x_err_stage := 'GMS_BUDGET_CORE.BASELINE - Error occurred while validating Budget';
		gms_error_pkg.gms_message(x_err_name => 'GMS_VERIFY_BUDGET_FAIL_B',
					x_err_code => x_err_code,
			 		x_err_buff => x_err_stage);
                fnd_msg_pub.add;
		RETURN;
	END IF;
        END IF;
    END IF;  -- x_verify_budget_rules = 'Y'

-- End R11 rewrite
-- ----------------------------------------------------------------------------------

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling GMS_BUDGET_UTILS.get_baselined_version_id','C');
     END IF;

     GMS_BUDGET_UTILS.get_baselined_version_id(x_project_id,
					   x_award_id,
					   x_budget_type_code,
					   x_baselined_version_id,
					   x_err_code,
					   x_err_stage,
					   x_err_stack);

     if (x_err_code < 0) then
         IF L_DEBUG = 'Y' THEN
             gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to GMS_BUDGET_UTILS.get_baselined_version_id returned x_err_code : '||x_err_code ,'C');
             gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to GMS_BUDGET_UTILS.get_baselined_version_id returned x_err_stage : '||x_err_stage ,'C');
         END IF;

	 rollback to before_baseline;
         return;

     elsif (x_err_code > 0) then

        -- baseline budget does not exist

         IF L_DEBUG = 'Y' THEN
             gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- First time baselining','C');
             gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling pa_res_list_assignments.create_rl_assgmt','C');
         END IF;

        x_err_stage := 'create resource list assignment <'
		       || to_char(x_project_id) || '><'
		       || to_char(x_resource_list_id) || '>';

        -- create resource list assignment if necessary
        pa_res_list_assignments.create_rl_assgmt(x_project_id,
                         x_resource_list_id,
                         x_resource_list_assgmt_id,
                         x_err_code,
                         x_err_stage,
                         x_err_stack);

        -- if oracle or application error, return
        if (x_err_code <> 0) then
                IF L_DEBUG = 'Y' THEN
                     gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to pa_res_list_assignments.create_rl_assgmt returned x_err_code : '||x_err_code ,'C');
                     gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to pa_res_list_assignments.create_rl_assgmt returned x_err_stage : '||x_err_stage ,'C');
                END IF;
		rollback    to before_baseline;
           	return;
        end if;

        x_err_stage := 'create resource list usage <'
		       || to_char(x_project_id) || '><'
		       || to_char(x_resource_list_assgmt_id) || '><'
		       || x_budget_type_code || '>';

        -- create resource list usage if necessary

         IF L_DEBUG = 'Y' THEN
             gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling pa_res_list_assignments.create_rl_uses','C');
         END IF;

        pa_res_list_assignments.create_rl_uses(x_project_id,
                         x_resource_list_assgmt_id,
                         x_budget_type_code,
                         x_err_code,
                         x_err_stage,
                         x_err_stack);

        -- if oracle or application error, return.

        if (x_err_code <> 0) then
                IF L_DEBUG = 'Y' THEN
                     gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to pa_res_list_assignments.create_rl_uses returned x_err_code :'||x_err_code ,'C');
                     gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to pa_res_list_assignments.create_rl_uses returned x_err_stage :'||x_err_stage ,'C');
                END IF;
     	        rollback    to before_baseline;
                return;
        end if;

     end if;

     x_err_stage := 'update current version <' || to_char(x_project_id) || '><'
		    || x_budget_type_code || '>';


     IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- x_mark_as_original : '||x_mark_as_original ,'C');
     END IF;

     if (x_mark_as_original = 'Y') then

	  -- reset current budget version to non-current
	  update gms_budget_versions
          set    original_flag = 'Y',
		 current_original_flag = 'N',
	         last_update_date = SYSDATE,
	         last_updated_by = x_created_by,
	         last_update_login = x_last_update_login
          where  project_id = x_project_id
          and    award_id = x_award_id
          and    budget_type_code = x_budget_type_code
          and    current_original_flag = 'Y';

     end if;

-------------------------------------------------------------------------------------------
-- 04-June-2000
-- Setting the current budget version's current_flag to an intermediate stage 'R',
-- which will be set to either 'N' (if Funds check passes) or 'Y' (if Funds check fails)
-- at the end of Baseline process.
-------------------------------------------------------------------------------------------

     IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Updating current_flag to an intermediate status R','C');
     END IF;

     update gms_budget_versions
     set    current_flag = 'R',
	    last_update_date = SYSDATE,
	    last_updated_by = x_created_by,
	    last_update_login = x_last_update_login
     where  project_id = x_project_id
     and    award_id = x_award_id
     and    budget_type_code = x_budget_type_code
     and    current_flag = 'Y';

     -- get the maximun number of existing versions
     x_err_stage := 'get maximum baseline number <' || to_char(x_project_id)
		    || '><' || x_budget_type_code || '>';

     select nvl(max(version_number), 0)
     into   max_version
     from   gms_budget_versions
     where  project_id = x_project_id
     and    award_id = x_award_id
     and    budget_type_code = x_budget_type_code
     and    budget_status_code = 'B';

     -- get the dest version id
     select gms_budget_versions_s.nextval
     into   x_dest_version_id
     from   sys.dual;

     -- populate gms_budget_versions
     x_err_stage := 'create baselined version <' || to_char(x_dest_version_id)
		    || '><' || to_char(max_version)
		    || '><' || to_char(x_created_by) || '>';

     IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Inserting records into gms_budget_versions','C');
     END IF;

     insert into gms_budget_versions(
            budget_version_id,
            project_id,
            award_id,
            budget_type_code,
            version_number,
            budget_status_code,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            current_flag,
            original_flag,
            current_original_flag,
	    resource_accumulated_flag,
            resource_list_id,
            version_name,
            budget_entry_method_code,
            baselined_by_person_id,
            baselined_date,
            change_reason_code,
            labor_quantity,
            labor_unit_of_measure,
            raw_cost,
            burdened_cost,
            revenue,
            description,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            first_budget_period,
            pm_product_code,
            pm_budget_reference,
		wf_status_code	)
         select
	    x_dest_version_id,
	    v.project_id,
	    v.award_id,
	    v.budget_type_code,
	    max_version + 1,
	    'B',
	    SYSDATE,
	    x_created_by,
	    SYSDATE,
	    x_created_by,
	    x_last_update_login,
--	    'Y',
	    'N', -- 29-May-2000
	    'N',
	    x_mark_as_original,
	    'N',
	    v.resource_list_id,
	    v.version_name,
	    v.budget_entry_method_code,
	    v_emp_id,
	    SYSDATE,
	    v.change_reason_code,
	    (v.labor_quantity),
	    v.labor_unit_of_measure,
	    v.raw_cost,
	    v.burdened_cost,
	    v.revenue,
 	    v.description,
            v.attribute_category,
            v.attribute1,
            v.attribute2,
            v.attribute3,
            v.attribute4,
            v.attribute5,
            v.attribute6,
            v.attribute7,
            v.attribute8,
            v.attribute9,
            v.attribute10,
            v.attribute11,
            v.attribute12,
            v.attribute13,
            v.attribute14,
            v.attribute15,
            first_budget_period,
            pm_product_code,
            pm_budget_reference,
	      NULL
         from   gms_budget_versions v
         where  budget_version_id = x_draft_version_id;

     x_err_stage := 'create budget lines <' || to_char(x_draft_version_id)
		    || '><' || to_char(x_dest_version_id)
		    || '>';

     IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling gms_budget_core.copy_draft_lines','C');
     END IF;

     gms_budget_core.copy_draft_lines(x_src_version_id        => x_draft_version_id,
                                      x_time_phased_type_code => x_time_phased_type_code,
                                      x_entry_level_code      => x_entry_level_code,
                                      x_dest_version_id       => x_dest_version_id,
                                      x_err_code              => x_err_code,
                                      x_err_stage             => x_err_stage,
                                      x_err_stack             => x_err_stack,
                                      x_pm_flag               => 'Y');


     if (x_err_code <> 0) then
        IF L_DEBUG = 'Y' THEN
            gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to gms_budget_core.copy_draft_lines returned x_err_code : '||x_err_code ,'C');
            gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to gms_budget_core.copy_draft_lines returned x_err_stage : '||x_err_stage ,'C');
        END IF;
	rollback to before_baseline;
	return;
     end if;

    -- If the effective dates on Project/Tasks
    -- has changed for Non Time phased budgets, then update the
    -- start and end dates on the budget lines.

   -- Begin Bug 2404567
   -- gp_msg('TIME:'||x_time_phased_type_code||':ENTRY:'||x_entry_level_code);

    IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- x_time_phased_type_code : '||x_time_phased_type_code,'C');
          gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- x_entry_level_code : '||x_entry_level_code,'C');
    END IF;

    if (x_time_phased_type_code = 'N')
       and (x_entry_level_code = 'P') then -- Project Level

-- Added call to GMS_BUDGET_UTILS.get_valid_period_dates() for Bug:2592747

      IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling gms_budget_utils.get_valid_period_dates','C');
      END IF;

            gms_budget_utils.get_valid_period_dates(
                    x_err_code => x_err_code,
                    x_err_stage => x_err_stage,
                    p_project_id => x_project_id,
                    p_task_id => NULL,
                    p_award_id => x_award_id,
                    p_time_phased_type_code => x_time_phased_type_code,
                    p_entry_level_code => x_entry_level_code,
                    p_period_name_in => null,
                    p_budget_start_date_in => null,
                    p_budget_end_date_in => null,
                    p_period_name_out => x_period_name,
                    p_budget_start_date_out	=> v_project_start_date,
                    p_budget_end_date_out => v_project_completion_date);


      IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Updating dates on gms_budget_lines','C');
      END IF;

      -- update for baselined version
      update gms_budget_lines
      set start_date= v_project_start_date,
          end_date = v_project_completion_date
      where resource_assignment_id in
          (select resource_assignment_id
           from gms_resource_assignments
           where budget_version_id = x_dest_version_id)
      and ((start_date <> v_project_start_date) OR (end_date <> v_project_completion_date));

      -- update for draft version
      update gms_budget_lines
      set start_date= v_project_start_date,
          end_date = v_project_completion_date
      where resource_assignment_id in
          (select resource_assignment_id
           from gms_resource_assignments
           where budget_version_id = x_draft_version_id)
      and ((start_date <> v_project_start_date) OR (end_date <> v_project_completion_date));

-- Added check that rows should be updated only if the project start or end
-- dates are different from the budget start and end dates

    elsif (x_time_phased_type_code = 'N') then -- Task Level

      select start_date,completion_date
      into v_project_start_date,
           v_project_completion_date
      from pa_projects_all
      where project_id = x_project_id;

      IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling gms_budget_utils.get_valid_period_dates','C');
      END IF;

        for b1_rec in (select t.task_id, resource_assignment_id
		     from pa_tasks t , gms_resource_assignments r
		     where t.task_id = r.task_id
             and  r.budget_version_id = x_dest_version_id) loop

       -- Added the call to gms_budget_utils.get_valid_period_dates() for Bug: 2592747

            gms_budget_utils.get_valid_period_dates(
                    x_err_code => x_err_code,
                    x_err_stage => x_err_stage,
                    p_project_id => x_project_id,
                    p_task_id => b1_rec.task_id,
                    p_award_id => x_award_id,
                    p_time_phased_type_code => x_time_phased_type_code,
                    p_entry_level_code => x_entry_level_code,
                    p_period_name_in => null,
                    p_budget_start_date_in => null,
                    p_budget_end_date_in => null,
                    p_period_name_out => x_period_name,
                    p_budget_start_date_out	=> x_budget_start_date,
                    p_budget_end_date_out => x_budget_end_date);

	    if x_err_code <> 0 then

		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_NO_TASK_PROJ_DATE',
	 			x_err_code => x_err_code,
 				x_err_buff => x_err_stage);
                fnd_msg_pub.add; --Bug 2587078
	    	APP_EXCEPTION.RAISE_EXCEPTION;

	    end if;

            update gms_budget_lines
            set start_date = x_budget_start_date,
                end_date   = x_budget_end_date
            where resource_assignment_id = b1_rec.resource_assignment_id
            and ((start_date <> x_budget_start_date) or (end_date <> x_budget_end_date));

        end loop;

        IF L_DEBUG = 'Y' THEN
            gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling gms_budget_utils.get_valid_period_dates for draft version','C');
        END IF;

      --following loop is for draft version
        for b2_rec in (select t.task_id, resource_assignment_id
		     from pa_tasks t , gms_resource_assignments r
		     where t.task_id = r.task_id
             and  r.budget_version_id = x_draft_version_id) loop

       -- Added the call to gms_budget_utils.get_valid_period_dates() for Bug: 2592747

            gms_budget_utils.get_valid_period_dates(
                    x_err_code => x_err_code,
                    x_err_stage => x_err_stage,
                    p_project_id => x_project_id,
                    p_task_id => b2_rec.task_id,
                    p_award_id => x_award_id,
                    p_time_phased_type_code => x_time_phased_type_code,
                    p_entry_level_code => x_entry_level_code,
                    p_period_name_in => null,
                    p_budget_start_date_in => null,
                    p_budget_end_date_in => null,
                    p_period_name_out => x_period_name,
                    p_budget_start_date_out	=> x_budget_start_date,
                    p_budget_end_date_out => x_budget_end_date);

	    if x_err_code <> 0 then

		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_NO_TASK_PROJ_DATE',
	 			x_err_code => x_err_code,
 				x_err_buff => x_err_stage);
	        fnd_msg_pub.add; --Bug 2587078
	    	APP_EXCEPTION.RAISE_EXCEPTION;

	    end if;

            update gms_budget_lines
            set start_date = x_budget_start_date,
                end_date   = x_budget_end_date
            where resource_assignment_id = b2_rec.resource_assignment_id
            and ((start_date <> x_budget_start_date) or (end_date <> x_budget_end_date));


        end loop;

--            x_err_stage :='GMS_BU_NO_TASK_PROJ_DATE';

      if x_err_code <> 0 then
        return;
      end if;

--
    end if;

   -- End Bug 2404567

     IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling fnd_attached_documents2_pkg.copy_attachments','C');
     END IF;

     -- Copy attachments for every draft budget copied

     fnd_attached_documents2_pkg.copy_attachments('GMS_BUDGET_VERSIONS',
                                                   x_draft_version_id,
                                                   null,null,null,null,
                                                   'GMS_BUDGET_VERSIONS',
                                                   x_dest_version_id,
                                                   null,null,null,null,
                                                   FND_GLOBAL.USER_ID,
                                                   FND_GLOBAL.LOGIN_ID,
                                                   275, null, null) ;
     -- End copying attachments

     IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Calling gms_budget_pub.summerize_project_totals','C');
     END IF;

     gms_budget_pub.summerize_project_totals(x_dest_version_id,
                                             x_err_code,
                                             x_err_stage,
                                             x_err_stack);
     if (x_err_code <> 0) then
        IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Call to gms_budget_pub.summerize_project_totals returned failed status','C');
           gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Value of x_err_code '||x_err_code,'C');
           gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- Value of x_err_stage '||x_err_stage,'C');
        END IF;
        rollback to before_baseline;
        return;
     end if;

     x_err_stack := old_stack;

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('*** End of GMS_BUDGET_CORE.BASELINE ***','C');
     END IF;

  exception
      when OTHERS
      then
         IF L_DEBUG = 'Y' THEN
            gms_error_pkg.gms_debug('GMS_BUDGET_CORE.BASELINE- In when others exception','C');
         END IF;
	 rollback to before_baseline;

--	 x_err_code := SQLCODE;
--	 rollback to before_baseline;
--	 return;

  end baseline;

-----------------------------------------------------------------------------
-- This procedure is called from the Award Budgets form.

  procedure copy (x_src_version_id      in     number,
		  x_amount_change_pct   in     number,
		  x_rounding_precision  in     number,
		  x_shift_days          in     number,
		  x_dest_project_id     in     number,
		  x_dest_award_id     	in     number,
		  x_dest_budget_type_code    in     varchar2,
		  x_err_code            in out NOCOPY number,
		  x_err_stage	        in out NOCOPY varchar2,
		  x_err_stack           in out NOCOPY varchar2)
  is
     old_stack 			varchar2(630);
     x_dest_version_id 		number;
     x_created_by  		number;
     x_last_update_login 	number;
     x_baselined_version_id 	number;
     x_baselined_resource_list_id number;
     x_src_resource_list_id 	number;
     x_resource_list_assgmt_id 	number;
     x_baselined_exists 	boolean;
     x_first_budget_period   	varchar2(30);
     x_time_phased_type_code 	varchar2(30);
     x_entry_level_code 	varchar2(30);
     x_fbp_start_date   	date;
     x_periods   		number;
     x_start_date 		date;
     x_end_date   		date;

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     x_err_stage := 'get project start date <'
		    ||  to_char(x_src_version_id) || '>';

     select start_date
     into g_project_start_date
     from pa_projects a, gms_budget_versions b
     where b.budget_version_id = x_src_version_id
     and   a.project_id = b.project_id;

     savepoint before_copy;

     x_err_stage := 'get source resource list id <'
		    ||  to_char(x_src_version_id) || '>';

     select resource_list_id,first_budget_period
     into   x_src_resource_list_id, x_first_budget_period
     from   gms_budget_versions
     where  budget_version_id = x_src_version_id;

     x_err_stage := 'get baselined budget <' ||  to_char(x_dest_project_id)
		    || '><' ||  x_dest_budget_type_code || '>' ;

     -- check if baseline budget already exist
     GMS_BUDGET_UTILS.get_baselined_version_id(x_dest_project_id,
					 x_dest_award_id,
					 x_dest_budget_type_code,
					 x_baselined_version_id,
					 x_err_code,
					 x_err_stage,
					 x_err_stack);

     if (x_err_code > 0) then
         x_baselined_exists := FALSE;

     elsif (x_err_code = 0) then
	-- baseliend budget exists, verify if resource lists are the same
	-- resource list used in accumulation

        select resource_list_id
        into   x_baselined_resource_list_id
        from   gms_budget_versions
        where  budget_version_id = x_baselined_version_id;

	if (x_src_resource_list_id <> x_baselined_resource_list_id) then

		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_BASE_RES_LIST_EXISTS',
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

        end if;

        x_baselined_exists := TRUE;

     else
	-- x_err_code < 0
	rollback to before_copy;
	return;
     end if;

     x_err_stage := 'delete old draft budget <' ||  to_char(x_dest_project_id)
		    || '><' ||  x_dest_budget_type_code || '>' ;

     -- check if destination draft budget exists
     GMS_BUDGET_UTILS.get_draft_version_id(x_dest_project_id,
					 x_dest_award_id,
					 x_dest_budget_type_code,
					 x_dest_version_id,
					 x_err_code,
					 x_err_stage,
					 x_err_stack);

     if (x_err_code = 0) then
	-- draft budget exists, delete it


--	GMS_BUDGET_UTILS.delete_draft(x_dest_version_id,

	GMS_BUDGET_PUB.delete_draft_budget(
		p_api_version_number => 1.0,
		x_err_code => x_err_code,
		x_err_stage => x_err_stage,
		x_err_stack => x_err_stack,
		p_pm_product_code => 'GMS',
		p_project_id => x_dest_project_id,
		p_award_id => x_dest_award_id,
		p_budget_type_code => x_dest_budget_type_code);

     end if;

     if (x_err_code < 0) then
		gms_error_pkg.gms_message( x_err_name => 'GMS_DELETE_DRAFT_FAILED',
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
     end if;

/* Only check at baseline
     if (x_baselined_exists = FALSE) then

        -- create resource list assignment if necessary
        x_err_stage := 'create resource list assignment <'
		       || to_char(x_dest_project_id) || '><'
		       || to_char(x_src_resource_list_id) || '>';

        pa_res_list_assignments.create_rl_assgmt(x_dest_project_id,
                         x_src_resource_list_id,
                         x_resource_list_assgmt_id,
                         x_err_code,
                         x_err_stage,
                         x_err_stack);

        -- if oracle or application error, return
        if (x_err_code <> 0) then
	      rollback to before_copy;
           return;
        end if;

        x_err_stage := 'create resource list usage <'
		       || to_char(x_dest_project_id) || '><'
		       || to_char(x_resource_list_assgmt_id) || '><'
		       || x_dest_budget_type_code || '>';

        -- create resource list usage if necessary
        pa_res_list_assignments.create_rl_uses(x_dest_project_id,
                         x_resource_list_assgmt_id,
                         x_dest_budget_type_code,
                         x_err_code,
                         x_err_stage,
                         x_err_stack);

        -- if oracle or application error, return.

        if (x_err_code <> 0) then
	   rollback to before_copy;
           return;
        end if;

     end if;
*/



    x_err_stage := 'Getting Budget Entry Method Parameters <'||  to_char(x_src_version_id);
    select m.time_phased_type_code,
	   m.entry_level_code
    into   x_time_phased_type_code,
	   x_entry_level_code
    from   pa_budget_entry_methods m,
	   gms_budget_versions v
    where  v.budget_version_id = x_src_version_id
    and    v.budget_entry_method_code = m.budget_entry_method_code;

-- Shifting the First Budget Period
    if ( (nvl(x_shift_days,0) <> 0) and (x_first_budget_period is not null) and (
       x_time_phased_type_code not in ('R','N') )  ) then

        x_err_stage := 'Getting First Budget Period Start Date <'||  to_char(x_src_version_id);

        /****** commented for bug 4007119..
        select period_start_date
        into x_fbp_start_date
	from pa_budget_periods_v
	where period_type_code= x_time_phased_type_code
        and   period_name = x_first_budget_period;
        **********/

	-- Bug 4007119..changed code to use base tables instead of pa_budget_periods_v view.

        if x_time_phased_type_code = 'P' then

           select start_date
             into x_fbp_start_date
             from pa_periods
            where period_name = x_first_budget_period;

        elsif x_time_phased_type_code = 'G' then

           select start_date
             into x_fbp_start_date
             from gl_period_statuses p, pa_implementations i
            where i.set_of_books_id = p.set_of_books_id
              and p.application_id = pa_period_process_pkg.application_id
              and p.adjustment_period_flag = 'N'
              and p.period_name = x_first_budget_period;

        end if;

        x_err_stage := 'Getting no of periods by which first budget period needs to be shifted<'||  to_char(x_src_version_id);
        get_periods(nvl(g_project_start_date,x_fbp_start_date),
                  nvl(g_project_start_date, x_fbp_start_date)+ x_shift_days,
                  x_time_phased_type_code  ,
                  x_periods  ,
                  x_err_code ,
                  x_err_stage,
                  x_err_stack );

        if (x_err_code <> 0) then
		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_GET_PERIOD_FAIL',
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
        end if;



        x_err_stage := 'Shifting first budget period <'||  to_char(x_src_version_id);
        shift_periods(x_fbp_start_date,
		      x_periods ,
		      x_first_budget_period ,
		      x_time_phased_type_code,
		      x_start_date ,
		      x_end_date,
		      x_err_code,
		      x_err_stage ,
                      x_err_stack );

         if (x_err_code <> 0) then
		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_SHIFT_PERIOD_FAIL',
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
         end if;

      end if;


     x_err_stage := 'create budget version <' ||  to_char(x_dest_project_id)
		    || '><' ||  x_dest_budget_type_code || '>' ;

     select gms_budget_versions_s.nextval
     into   x_dest_version_id
     from   sys.dual;

     insert into gms_budget_versions(
            budget_version_id,
            project_id,
            award_id,
            budget_type_code,
            version_number,
            budget_status_code,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            current_flag,
            original_flag,
            current_original_flag,
            resource_accumulated_flag,
            resource_list_id,
            version_name,
            budget_entry_method_code,
            baselined_by_person_id,
            baselined_date,
            change_reason_code,
            labor_quantity,
            labor_unit_of_measure,
            raw_cost,
            burdened_cost,
            revenue,
            description,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            first_budget_period,
		wf_status_code
		)
         select
            x_dest_version_id,
            x_dest_project_id,
            x_dest_award_id,
            x_dest_budget_type_code,
            1,
            'W',
            SYSDATE,
            x_created_by,
            SYSDATE,
            x_created_by,
            x_last_update_login,
            'N',
            'N',
            'N',
            'N',
            v.resource_list_id,
            v.version_name,
            v.budget_entry_method_code,
            NULL,
            NULL,
            v.change_reason_code,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            v.description,
            v.attribute_category,
            v.attribute1,
            v.attribute2,
            v.attribute3,
            v.attribute4,
            v.attribute5,
            v.attribute6,
            v.attribute7,
            v.attribute8,
            v.attribute9,
            v.attribute10,
            v.attribute11,
            v.attribute12,
            v.attribute13,
            v.attribute14,
            v.attribute15,
            x_first_budget_period,
		NULL
	 from   gms_budget_versions v
	 where  v.budget_version_id = x_src_version_id;

     gms_budget_core.copy_lines(x_src_version_id,
			       x_amount_change_pct,
			       x_rounding_precision,
			       x_shift_days,
			       x_dest_version_id,
			       x_err_code,
			       x_err_stage,
			       x_err_stack);

	if (x_err_code <> 0) then
		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_COPY_LINES_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);

                APP_EXCEPTION.RAISE_EXCEPTION;
	end if;

     -- Copy attachments for every draft budget copied

     fnd_attached_documents2_pkg.copy_attachments('GMS_BUDGET_VERSIONS',
                                                   x_src_version_id,
                                                   null,null,null,null,
                                                   'GMS_BUDGET_VERSIONS',
                                                   x_dest_version_id,
                                                   null,null,null,null,
                                                   FND_GLOBAL.USER_ID,
                                                   FND_GLOBAL.LOGIN_ID,
                                                   275, null, null) ;

     -- End copying attachments

      gms_budget_pub.summerize_project_totals(x_dest_version_id,
					     x_err_code,
					     x_err_stage,
					     x_err_stack);

	if (x_err_code <> 0) then
		gms_error_pkg.gms_message( x_err_name => 'GMS_SUMMERIZE_TOTALS_FAILED',
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

	end if;

     x_err_stack := old_stack;

  exception
      when OTHERS
      then
	 rollback to before_copy;

  end copy;

-----------------------------------------------------------------------------

  procedure verify (x_budget_version_id   in     number,
		    x_err_code            in out NOCOPY number,
		    x_err_stage	          in out NOCOPY varchar2,
		    x_err_stack           in out NOCOPY varchar2)
  is
  begin
     null;
  exception
      when others then
	 x_err_code := SQLCODE;
  end verify;


-----------------------------------------------------------------------------

  procedure copy_lines (x_src_version_id      in     number,
		        x_amount_change_pct   in     number,
		        x_rounding_precision  in     number,
		        x_shift_days          in     number,
		        x_dest_version_id     in     number,
		        x_err_code            in out NOCOPY    number,
		        x_err_stage           in out NOCOPY varchar2,
		        x_err_stack           in out NOCOPY varchar2,
                        x_pm_flag             in varchar2 default 'N')
  is
    -- Standard who
    x_created_by                 NUMBER(15);
    x_last_update_login          NUMBER(15);

    old_stack  varchar2(630);
    x_start_date date;
    x_end_date date;
    x_period_name varchar2(30);
    amount_change_pct number;
    rounding_precision number;
    x_time_phased_type_code varchar2(30);
    x_entry_level_code varchar2(30);
    x_task_start_date date;
    x_periods   number;

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy_lines';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     if (x_amount_change_pct is not null) then
	 amount_change_pct := x_amount_change_pct;
     else
	 amount_change_pct := 1;
     end if;

     if (x_rounding_precision is not null) then
	 rounding_precision := x_rounding_precision;
     else
	 rounding_precision := 5;
     end if;

     x_err_stage := 'get time phased type <' ||  to_char(x_src_version_id)
		    || '>' ;
     select m.time_phased_type_code,
	    m.entry_level_code
     into   x_time_phased_type_code,
	    x_entry_level_code
     from   pa_budget_entry_methods m,
	    gms_budget_versions v
     where  v.budget_version_id = x_src_version_id
     and    v.budget_entry_method_code = m.budget_entry_method_code;

     x_err_stage := 'copy resource assignment <' ||  to_char(x_src_version_id)
		    || '>' ;

     if (x_entry_level_code <> 'P') then

        insert into gms_resource_assignments
	    (resource_assignment_id,
	     budget_version_id,
	     project_id,
	     task_id,
	     resource_list_member_id,
	     last_update_date,
	     last_updated_by,
	     creation_date,
	     created_by,
	     last_update_login,
	     unit_of_measure,
	     track_as_labor_flag)
           select gms_resource_assignments_s.nextval,
	       x_dest_version_id,
	       dt.project_id,
	       dt.task_id,
	       sa.resource_list_member_id,
	       SYSDATE,
	       x_created_by,
	       SYSDATE,
	       x_created_by,
	       x_last_update_login,
	       sa.unit_of_measure,
	       sa.track_as_labor_flag
           from
	       gms_resource_assignments sa,
	       pa_tasks st,
	       pa_tasks dt,
	       gms_budget_versions dv
           where  sa.budget_version_id = x_src_version_id
           and    sa.project_id = st.project_id
           and    sa.task_id = st.task_id
           and    st.task_number = dt.task_number
           and    dt.project_id = dv.project_id
           and    dv.budget_version_id = x_dest_version_id;

     else

        insert into gms_resource_assignments
	    (resource_assignment_id,
	     budget_version_id,
	     project_id,
	     task_id,
	     resource_list_member_id,
	     last_update_date,
	     last_updated_by,
	     creation_date,
	     created_by,
	     last_update_login,
	     unit_of_measure,
	     track_as_labor_flag)
           select gms_resource_assignments_s.nextval,
	       x_dest_version_id,
	       dv.project_id,
	       0,
	       sa.resource_list_member_id,
	       SYSDATE,
	       x_created_by,
	       SYSDATE,
	       x_created_by,
	       x_last_update_login,
	       sa.unit_of_measure,
	       sa.track_as_labor_flag
           from
	       gms_resource_assignments sa,
	       gms_budget_versions dv
           where  sa.budget_version_id = x_src_version_id
           and    sa.task_id = 0
           and    dv.budget_version_id = x_dest_version_id;

     end if;

        x_err_stage := 'copy budget lines <' ||to_char(x_src_version_id)
		    || '>' ;

        for budget_line_row in
       	  (select l.resource_assignment_id, l.start_date, l.end_date,a.task_id
           from   gms_budget_lines l,
                  gms_resource_assignments a
           where  a.budget_version_id = x_src_version_id
	   and    a.resource_assignment_id = l.resource_assignment_id
	  ) loop

	    x_period_name := NULL;
	    x_start_date := NULL;
	    x_end_date := NULL;

-- Shifting Periods for Budget Lines

            if (nvl(x_shift_days,0) <> 0) then
	      if (   (x_time_phased_type_code = 'R')
		  or (x_time_phased_type_code = 'N')) then
		 -- time-phased by date range or non-time-phased
		 x_start_date :=  budget_line_row.start_date + x_shift_days;
		 x_end_date :=  budget_line_row.end_date + x_shift_days;
              else
	        if (x_entry_level_code <> 'P') then
		  x_err_stage := 'Getting Task Start Date <'|| to_char(x_src_version_id);
		  select start_date
		  into x_task_start_date
		  from pa_tasks
		  where task_id =  budget_line_row.task_id;
                end if;

		x_err_stage := 'Getting no of periods by which line budget period needs to be shifted<'||
                                to_char(x_src_version_id);
		get_periods(nvl(x_task_start_date, nvl(g_project_start_date, budget_line_row.start_date) ),
		          nvl(x_task_start_date, nvl(g_project_start_date, budget_line_row.start_date) )
			       + x_shift_days,
			  x_time_phased_type_code  ,
			  x_periods  ,
			  x_err_code ,
			  x_err_stage,
			  x_err_stack );

		  if (x_err_code <> 0) then
			gms_error_pkg.gms_message( x_err_name => 'GMS_BU_GET_PERIOD_FAIL',
		 				x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		 end if;

		x_err_stage := 'Shifting line budget period <'||  to_char(x_src_version_id);
		shift_periods(budget_line_row.start_date,
			      x_periods ,
			      x_period_name ,
			      x_time_phased_type_code,
			      x_start_date ,
			      x_end_date,
			      x_err_code,
			      x_err_stage,
			      x_err_stack );

		 if (x_err_code <> 0) then
			gms_error_pkg.gms_message( x_err_name => 'GMS_BU_SHIFT_PERIOD_FAIL',
		 				x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		 end if;

               end if;

             end if;


	    if (x_entry_level_code <> 'P') then

             insert into gms_budget_lines
	       (resource_assignment_id,
	        start_date,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
	        end_date,
	        period_name,
	        quantity,
	        raw_cost,
	        burdened_cost,
	        revenue,
                change_reason_code,
                description,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
		pm_product_code,
		pm_budget_line_reference,
		raw_cost_source,
		burdened_cost_source,
		quantity_source,
		revenue_source
                )
              select
		da.resource_assignment_id,
	        decode(x_start_date, NULL, l.start_date, x_start_date),
		SYSDATE,
                x_created_by,
                SYSDATE,
                x_created_by,
                x_last_update_login,
	        decode(x_end_date, NULL, l.end_date, x_end_date),
	        decode(x_period_name, NULL, l.period_name, x_period_name),
	        l.quantity,
	        round(l.raw_cost * amount_change_pct, rounding_precision),
	        round(l.burdened_cost * amount_change_pct, rounding_precision),
	        round(l.revenue * amount_change_pct, rounding_precision),
                l.change_reason_code,
	        l.description,
                l.attribute_category,
                l.attribute1,
                l.attribute2,
                l.attribute3,
                l.attribute4,
                l.attribute5,
                l.attribute6,
                l.attribute7,
                l.attribute8,
                l.attribute9,
                l.attribute10,
                l.attribute11,
                l.attribute12,
                l.attribute13,
                l.attribute14,
                l.attribute15,
		decode(x_pm_flag,'Y',l.pm_product_code,NULL),
		decode(x_pm_flag,'Y',l.pm_budget_line_reference,NULL),
                'B',
                'B',
                'B',
                'B'
	      from  gms_budget_lines l,
		    gms_resource_assignments sa,
		    pa_tasks st,
		    pa_tasks dt,
		    gms_resource_assignments da
	     where  l.resource_assignment_id =
				budget_line_row.resource_assignment_id
	     and    l.start_date = budget_line_row.start_date
	     and    l.resource_assignment_id = sa.resource_assignment_id
             and    sa.budget_version_id = x_src_version_id
	     and    sa.task_id = st.task_id
	     and    sa.project_id = st.project_id
             and    sa.resource_list_member_id = da.resource_list_member_id
             and    st.task_number = dt.task_number
	     and    dt.task_id = da.task_id
	     and    dt.project_id = da.project_id
	     and    da.budget_version_id = x_dest_version_id;

	  else

             insert into gms_budget_lines
	       (resource_assignment_id,
	        start_date,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
	        end_date,
	        period_name,
	        quantity,
	        raw_cost,
	        burdened_cost,
	        revenue,
                change_reason_code,
                description,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
		pm_product_code,
		pm_budget_line_reference,
		raw_cost_source,
		burdened_cost_source,
		quantity_source,
		revenue_source
                )
              select
		da.resource_assignment_id,
	        decode(x_start_date, NULL, l.start_date, x_start_date),
		SYSDATE,
                x_created_by,
                SYSDATE,
                x_created_by,
                x_last_update_login,
	        decode(x_end_date, NULL, l.end_date, x_end_date),
	        decode(x_period_name, NULL, l.period_name, x_period_name),
	        l.quantity,
	        round(l.raw_cost * amount_change_pct, rounding_precision),
	        round(l.burdened_cost * amount_change_pct, rounding_precision),
	        round(l.revenue * amount_change_pct, rounding_precision),
                l.change_reason_code,
	        l.description,
                l.attribute_category,
                l.attribute1,
                l.attribute2,
                l.attribute3,
                l.attribute4,
                l.attribute5,
                l.attribute6,
                l.attribute7,
                l.attribute8,
                l.attribute9,
                l.attribute10,
                l.attribute11,
                l.attribute12,
                l.attribute13,
                l.attribute14,
                l.attribute15,
		decode(x_pm_flag,'Y',l.pm_product_code,NULL),
		decode(x_pm_flag,'Y',l.pm_budget_line_reference,NULL),
                'B',
                'B',
                'B',
                'B'
	      from  gms_budget_lines l,
		    gms_resource_assignments sa,
		    gms_resource_assignments da
	      where l.resource_assignment_id =
				budget_line_row.resource_assignment_id
	      and   l.start_date = budget_line_row.start_date
	      and   l.resource_assignment_id = sa.resource_assignment_id
              and   sa.budget_version_id = x_src_version_id
	      and   sa.task_id = 0
              and   sa.resource_list_member_id = da.resource_list_member_id
	      and   da.task_id = 0
	      and   da.budget_version_id = x_dest_version_id;

	  end if;

        end loop;

  exception
      when others then
	 x_err_code := SQLCODE;
	 return;
  end copy_lines;
-------------------------------------------------------------------------------------
 --  Added for bug 1831151
 --  This function checks for budget entry levels among Draft budget and baselined budget
 --  the function will return false in following conditions
 --         1.  If budget Entry Method or Resource lists are different in baselined budget
 --             and draft budget
 --         2.  If the Draft Budget is at Top Task or Resource Group level and  the copy actual
 --	           start period and end period are not covering all the budgeted periods of draft Budget.

   FUNCTION p_validate (
      x_project_id          NUMBER,
	  draft_bvid            NUMBER,
      bal_bvid              NUMBER,
      p_start_period_date   DATE,
      p_end_period_date     DATE
   )
      RETURN BOOLEAN IS


       CURSOR c_draft_details IS
       SELECT task_id,resource_list_member_id
       FROM gms_resource_assignments gra, gms_budget_lines gbl
       WHERE gra.resource_assignment_id = gbl.resource_assignment_id
       AND gra.budget_version_id = draft_bvid;


       CURSOR c_budget_details (p_budget_version NUMBER) IS
        SELECT gbv.budget_entry_method_code, resource_list_id,
                entry_level_code
           FROM gms_budget_versions gbv, pa_budget_entry_methods pbem
          WHERE gbv.budget_version_id = p_budget_version
            AND gbv.budget_entry_method_code = pbem.budget_entry_method_code;

      CURSOR c_period_dates_draft IS
         SELECT MIN (start_date), MAX (end_date)
           FROM gms_resource_assignments gra, gms_budget_lines gbl
          WHERE gra.resource_assignment_id = gbl.resource_assignment_id
            AND gra.budget_version_id = draft_bvid;

      CURSOR c_period_dates_baselined IS
         SELECT MIN (start_date), MAX (end_date)
           FROM gms_balances
          WHERE budget_version_id = bal_bvid;


      x_task_id                 NUMBER;
      x_rlmid                   NUMBER;
	  x_c_resource_list_id      NUMBER;
	  x_d_resource_list_id      NUMBER;
      dummy                     NUMBER        := 0;
      x_c_budget_entry_method   VARCHAR2 (30);
      x_c_entry_level_code      VARCHAR2 (10);
      x_d_budget_entry_method   VARCHAR2 (30);
      budget_method_changed     BOOLEAN       := FALSE;
      x_draft_start_date        DATE;
      x_draft_end_date          DATE;
      x_baselined_start_date    DATE;
      x_baselined_end_date      DATE;
      result_code               VARCHAR(2);
   BEGIN
      OPEN c_budget_details (bal_bvid);
      FETCH c_budget_details INTO x_c_budget_entry_method,
                                  x_c_resource_list_id,
                                  x_c_entry_level_code;
      CLOSE c_budget_details;


      OPEN c_budget_details (draft_bvid);
      FETCH c_budget_details INTO x_d_budget_entry_method,
                                  x_d_resource_list_id,
                                  x_c_entry_level_code;
      CLOSE c_budget_details;

      IF  ( x_c_budget_entry_method <> x_d_budget_entry_method
         OR x_c_resource_list_id <> x_d_resource_list_id
		  ) THEN
	     budget_method_changed := TRUE;
         fnd_message.set_name ('GMS', 'GMS_BUDG_ENTRY_CHANGED');
         RETURN FALSE;
      END IF;
     IF NOT budget_method_changed THEN

         OPEN c_period_dates_draft;
         FETCH c_period_dates_draft INTO x_draft_start_date, x_draft_end_date;
         CLOSE c_period_dates_draft;

         IF    (x_draft_start_date NOT BETWEEN p_start_period_date
                                           AND p_end_period_date
               )
            OR (x_draft_end_date NOT BETWEEN p_start_period_date
                                         AND p_end_period_date
               ) THEN

			    result_code := 'P';
			    OPEN c_draft_details;
				LOOP
				   FETCH c_draft_details INTO x_task_id,x_rlmid ;
				   EXIT WHEN c_draft_details%NOTFOUND
                         OR result_code in ('FT','FR');
				   dummy := 0;
				   -- Bug 4908109 : Performance Fix
				   begin
				   SELECT 1
                   INTO dummy
                   FROM DUAL
                   WHERE EXISTS (
                                 SELECT 1
                                 FROM  pa_tasks
                                 WHERE project_id = x_project_id
								  AND task_id = x_task_id
                                  AND task_id = top_task_id
								  AND  EXISTS (select 1
								               FROM  pa_tasks
											   where nvl(parent_task_id,0) = x_task_id
											   and project_id = x_project_id));
		                   exception
				      	 when NO_DATA_FOUND then
		                         dummy := 0;
				   end;
				   IF dummy <> 0 THEN
                     result_code := 'FT';
				   ELSE
				   -- Bug 4908109 : Performance Fix
				    begin
				    SELECT 1
                    INTO dummy
                    FROM DUAL
                    WHERE EXISTS (
                                 SELECT 1
                                 FROM  pa_resource_list_members prl
                                 WHERE   prl.resource_list_member_id = x_rlmid
                                 AND    prl.parent_member_id IS NULL );
				    exception
				    	 when NO_DATA_FOUND then
		                         dummy := 0;
				     end;
					 IF dummy <> 0 THEN
                     result_code := 'FR';
					 END IF;

                   END IF;
                END LOOP;
               CLOSE c_draft_details;

               IF result_code = 'FT' THEN
                  fnd_message.set_name ('GMS', 'GMS_DRAFT_BUD_AT_TOP_TASK');
                  RETURN FALSE;
			   ELSIF result_code = 'FR' THEN
	                 fnd_message.set_name ('GMS', 'GMS_DRAFT_BUD_AT_RES_GRP');
                     RETURN FALSE;
               END IF;



		END IF; -- x_draft_start_date
      END IF; -- NOT budget_method_changed
      RETURN TRUE;
   END;
-----------------------------------------------------------------------------------

-- Added for bug 1831151
--  This Procedure Returns Min Start Period and Max end Period to the Award Budget form ,
--  these periods will be used to populate default values of for copy actual periods
--  when copy actual button is pressed.


   PROCEDURE start_end_period (
      x_project_id                  IN       NUMBER,
      x_award_id                    IN       NUMBER,
      x_version_id                  IN       NUMBER,
      x_current_budget_version_id   IN       NUMBER,
      x_budget_entry_method_code    IN       VARCHAR2,
      x_time_phase_type_code        IN       VARCHAR2,
      x_resource_list_id            IN       NUMBER,
	  x_resource_list_name			IN		 VARCHAR2,
      x_start_period_name           OUT NOCOPY      VARCHAR2,
      x_start_date                  IN OUT NOCOPY   DATE,
      x_end_period_name             OUT NOCOPY      VARCHAR2,
      x_end_date                    IN OUT NOCOPY   DATE,
      x_err_code                    IN OUT NOCOPY   NUMBER,
      x_err_stage                   IN OUT NOCOPY   VARCHAR2,
      x_err_stack                   IN OUT NOCOPY   VARCHAR2
   ) IS

      x_gbal_start_date   DATE;
      x_pdb_start_date    DATE;
      x_gbal_end_date     DATE;
      x_pdb_end_date      DATE;

      /********* commented for bug 4007119
      CURSOR c_period_name (p_period_date DATE, p_time_phase_type_code VARCHAR2) IS
         SELECT period_name
           FROM pa_budget_periods_v
          WHERE period_type_code = p_time_phase_type_code
            AND p_period_date BETWEEN period_start_date AND period_end_date;
      ********/

   BEGIN
      --Added the following select statements to fetch period name based
      --on the basis of time_phased_type_code
     BEGIN

	     SELECT MIN (start_date), MAX (end_date)
          INTO x_gbal_start_date, x_gbal_end_date
          FROM gms_balances gb, gms_budget_versions gbv
         WHERE gb.budget_version_id = gbv.budget_version_id
           AND gb.project_id = x_project_id
           AND gb.award_id = x_award_id
           AND gbv.award_id = gb.award_id
	       AND gbv.project_id = gb.project_id
           AND gbv.current_flag = 'Y'
		   AND gb.actual_period_to_date IS NOT NULL
		   AND gb.encumb_period_to_date IS NOT NULL
      GROUP BY gb.budget_version_id;

	 EXCEPTION
       WHEN NO_DATA_FOUND THEN
         fnd_message.set_name ('GMS', 'GMS_BU_ACCUMS_NOT_EXIST');
         fnd_message.set_token('RES_LIST',x_resource_list_name);
         app_exception.raise_exception;
     END;

	 BEGIN

      SELECT   MIN (start_date), MAX (end_date)
          INTO x_pdb_start_date, x_pdb_end_date
          FROM gms_resource_assignments gra,
               gms_budget_versions gbv,
               gms_budget_lines gbl
         WHERE gbv.budget_version_id = gra.budget_version_id
           AND gbv.budget_version_id = x_version_id
           AND gra.resource_assignment_id = gbl.resource_assignment_id
      GROUP BY gbv.budget_version_id;
	 EXCEPTION
	        WHEN NO_DATA_FOUND THEN
			NULL;
	 END;

      x_start_date := LEAST (x_gbal_start_date, nvl(x_pdb_start_date,x_gbal_start_date));
      x_end_date := GREATEST (x_gbal_end_date, nvl(x_pdb_end_date,x_gbal_end_date));

      /******* commented for bug 4007119
      IF x_time_phase_type_code = 'P' THEN
         OPEN c_period_name (x_start_date, 'P');
      ELSIF x_time_phase_type_code = 'G' THEN
         OPEN c_period_name (x_start_date, 'G');
      END IF;

      IF c_period_name%ISOPEN THEN
         FETCH c_period_name INTO x_start_period_name;
         CLOSE c_period_name;
      END IF;

      IF x_time_phase_type_code = 'P' THEN
         OPEN c_period_name (x_end_date, 'P');
      ELSIF x_time_phase_type_code = 'G' THEN
         OPEN c_period_name (x_end_date, 'G');
      END IF;

      IF c_period_name%ISOPEN THEN
         FETCH c_period_name INTO x_end_period_name;
         CLOSE c_period_name;
      END IF;
      ***************/

      -- Bug 4007119..changed code to use base tables instead of pa_budget_periods_v view.

      IF x_time_phase_type_code = 'P' THEN

         select period_name
           into x_start_period_name
           from pa_periods
          where x_start_date between start_date and end_date;

         select period_name
           into x_end_period_name
           from pa_periods
          where x_end_date between start_date and end_date;

      ELSIF x_time_phase_type_code = 'G' THEN

         select p.period_name
           into x_start_period_name
           from gl_period_statuses p, pa_implementations i
          where i.set_of_books_id = p.set_of_books_id
            and p.application_id = pa_period_process_pkg.application_id
            and p.adjustment_period_flag = 'N'
            and x_start_date between p.start_date and p.end_date;

         select p.period_name
           into x_end_period_name
           from gl_period_statuses p, pa_implementations i
          where i.set_of_books_id = p.set_of_books_id
            and p.application_id = pa_period_process_pkg.application_id
            and p.adjustment_period_flag = 'N'
            and x_end_date between p.start_date and p.end_date;

      END IF;

   END;
------------------------------------------------------------------------------------
--Modified the code to make the copy actual pick data from Gms_balances


procedure copy_actual (x_project_id		          in     number,
			 		  x_award_id                  in     number,
			 		  x_version_id                in     number,
			 		  x_budget_entry_method_code  in     varchar2,
			 		  x_resource_list_id          in     number,
			 		  x_start_period		      in     varchar2,
			 		  x_end_period		     	  in     varchar2,
		         	  x_err_code                  in out NOCOPY number,
		         	  x_err_stage	  	     	  in out NOCOPY varchar2,
		         	  x_err_stack         	      in out NOCOPY varchar2,
                      x_funding_status            out NOCOPY number) -- Added for bug 1831151
  is
    -- Standard who
    x_created_by                number(15);
    x_last_update_login         number(15);

    x_entry_level_code		   varchar2(30);
    x_categorization_code	   varchar2(30);
    x_time_phased_type_code	   varchar2(30);
    x_start_period_start_date   date;
    x_end_period_end_date       date;
    x_task_id                   number;
    x_uncat_res_list_member_id  number;
    x_uncat_unit_of_measure     varchar2(30);
    x_uncat_track_as_labor_flag varchar2(2);
    x_raw_cost                  number;
    x_burdened_cost             number;
    x_revenue                   number;
    x_quantity                  number;
    x_labor_hours               number;
    x_unit_of_measure           varchar2(30);
    x_resource_assignment_id    number;
    x_raw_cost_total            number;
    x_burdened_cost_total       number;
    x_revenue_total             number;
    x_quantity_total            number;
    x_labor_hours_total         number;
    x_dummy1                    number;
    x_dummy2                    number;
    x_dummy3                    number;
    x_dummy4                    number;
    x_dummy5                    number;
    x_dummy6                    number;
    x_rowid						rowid;
    old_stack					varchar2(630);
    x_budget_amount_code        varchar2(1);

    x_current_budget_version_id NUMBER;

    -- record definition
    type period_type is
    record (period_name varchar2(30),
	    start_date  date,
	    end_date    date);

    period_rec period_type;

    -- cursor definition

    cursor pa_cursor is
      select period_name,
	     start_date,
	     end_date
      from   pa_periods
      where  start_date between x_start_period_start_date
			and x_end_period_end_date;

    cursor gl_cursor is
      select p.period_name,
	     p.start_date,
	     p.end_date
      from   gl_period_statuses p,
             pa_implementations i
      where  p.application_id = 101
      and    p.set_of_books_id = i.set_of_books_id
      and    p.start_date between x_start_period_start_date
                          and x_end_period_end_date
      and    p.adjustment_period_flag = 'N';  -- 7653209 ;

-- Added for bug 1831151

     CURSOR get_current_budget_version_id IS
         SELECT budget_version_id
         FROM gms_budget_versions
         WHERE award_id = x_award_id
         AND project_id = x_project_id
         AND current_flag = 'Y';

-- end of modifications for bug 1831151

     cursor get_budget_amount_code is
	select budget_amount_code
	from gms_budget_versions b, pa_budget_types t
	where b.budget_version_id = x_version_id
	and   b.budget_type_code = t.budget_type_code;

-- required to fetch the budget line details reqd. to delete a budget line.

     cursor budget_lines_csr (p_budget_version_id NUMBER
			,p_start_date DATE
			,p_end_date DATE) is
	select 	gra.task_id,
		gra.resource_list_member_id,
		gbl.period_name,
		gbl.start_date
	from 	gms_resource_assignments gra,
		    gms_budget_lines gbl
	where	gbl.resource_assignment_id = gra.resource_assignment_id
	and	gra.budget_version_id = p_budget_version_id
	and	gbl.start_date between p_start_date and p_end_date;

  begin

     open get_budget_amount_code;
     fetch get_budget_amount_code into x_budget_amount_code;
     close get_budget_amount_code;

-- For bug 1831151

     open get_current_budget_version_id;
     fetch get_current_budget_version_id into x_current_budget_version_id;
     close get_current_budget_version_id;

-- end of the code added for bug 1831151


     x_err_code := 0;
     x_funding_status := -1; -- bug 1831151
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy_actual';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     savepoint before_copy_actual;

     x_err_stage := 'get budget entry method <' || x_budget_entry_method_code
		    || '>';

     select entry_level_code, categorization_code,
            time_phased_type_code
     into   x_entry_level_code, x_categorization_code,
	    	x_time_phased_type_code
     from   pa_budget_entry_methods
     where  budget_entry_method_code = x_budget_entry_method_code;

     if (   (x_time_phased_type_code = 'N')
	 	or (x_time_phased_type_code = 'R')) then
		gms_error_pkg.gms_message( x_err_name => 'GMS_BU_INVALID_TIME_PHASED', -- cannot copy-actual for a non-time phased/date range budgets
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
     end if;

     x_err_stage := 'get uncategorized resource list member id';

     select m.resource_list_member_id,
	       m.track_as_labor_flag,
	       r.unit_of_measure
     into   x_uncat_res_list_member_id,
	        x_uncat_track_as_labor_flag,
	        x_uncat_unit_of_measure
     from   pa_resources r,
	        pa_resource_list_members m,
		    --gms_implementations gia,  -- Commented out NOCOPY for Bug:2113499
		    pa_implementations pi,
	        pa_resource_lists l
     where  l.uncategorized_flag = 'Y'
     and    l.resource_list_id = m.resource_list_id
	 --and    gia.org_id = l.business_group_id  -- Commented out NOCOPY for Bug:2113499
	 and    pi.business_group_id = l.business_group_id
     and    m.resource_id =  r.resource_id
     AND    NVL(m.migration_code,'M') ='M'  -- Bug 3626671
     AND    NVL(l.migration_code,'M') ='M'; -- Bug 3626671


     x_err_stage := 'get start date of periods <' || x_start_period
		    || '><' || x_end_period
		    || '>';
    if (x_time_phased_type_code = 'P') then

     select start_date
	 into   x_start_period_start_date
  	 from   pa_periods
	 where  period_name = x_start_period;

         select end_date
	 into   x_end_period_end_date
  	 from   pa_periods
	 where  period_name = x_end_period;

     else
         select start_date
	 into   x_start_period_start_date
  	 from   gl_period_statuses p,
	        pa_implementations i
	 where  p.period_name = x_start_period
	 and    p.application_id = 101
	 and    p.set_of_books_id = i.set_of_books_id;

         select end_date
	 into   x_end_period_end_date
  	 from   gl_period_statuses p,
	        pa_implementations i
	 where  p.period_name = x_end_period
	 and    p.application_id = 101
	 and    p.set_of_books_id = i.set_of_books_id;

     end if;
	 -- Added for bug 1831151
       IF NOT p_validate (
	            x_project_id,
                x_version_id,
                x_current_budget_version_id,
                x_start_period_start_date,
                x_end_period_end_date
             ) THEN
         app_exception.raise_exception;
	 -- end of code added for bug 1831151

      END IF;
     x_err_stage := 'delete budget lines <' || to_char(x_version_id)
		    || '><' || x_start_period
		    || '><' || x_end_period
		    || '>';

/*     for bl_rec in (
           select rowid
           from   gms_budget_lines l
           where  l.resource_assignment_id in
                  (select a.resource_assignment_id
	           from   gms_resource_assignments a
	           where  a.budget_version_id = x_version_id)
           and    l.start_date between x_start_period_start_date and
				       x_end_period_end_date) loop
*/

	for budget_lines_rec in budget_lines_csr(x_version_id
						,x_start_period_start_date
						,x_end_period_end_date)
	loop
	 gms_budget_pub.delete_budget_line(
	 	p_api_version_number => 1.0,
	 	x_err_code => x_err_code,
	 	x_err_stage => x_err_stage,
	 	x_err_stack=> x_err_stack,
	 	p_pm_product_code => 'GMS',
	 	p_project_id => x_project_id,
	 	p_award_id => x_award_id,
	 	p_budget_type_code => 'AC', -- changed from C to AC
	 	p_task_id => budget_lines_rec.task_id,
	 	p_resource_list_member_id => budget_lines_rec.resource_list_member_id,
	 	p_start_date => budget_lines_rec.start_date,
	 	p_period_name => budget_lines_rec.period_name
	 );

	 IF x_err_code <> 0
	 THEN
		gms_error_pkg.gms_message( x_err_name => 'GMS_DELETE_BUDGET_LINE_FAIL',
	 				x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

   end loop;
     -- process every period between the starting period and ending period

     if (x_time_phased_type_code = 'P') then
        open pa_cursor;
     else
        open gl_cursor;
     end if;

     loop  -- period

       if (x_time_phased_type_code = 'P') then
       fetch pa_cursor into period_rec ;
	   exit when pa_cursor%NOTFOUND;
        else
       fetch gl_cursor into period_rec;
	   exit when gl_cursor%NOTFOUND;
        end if;

        x_err_stage := 'process period <' || period_rec.period_name
		        || '><' || x_time_phased_type_code
		        || '>';

       if (x_entry_level_code = 'P') then
	      if (x_categorization_code = 'N') then
		 -- project level, uncategorized

		 x_burdened_cost := 0;
		 x_unit_of_measure := NULL;

		 get_proj_accum_actuals(x_project_id,
					 NULL,
                     x_current_budget_version_id,
					 NULL,
					 x_time_phased_type_code,
					 period_rec.period_name,
					 period_rec.start_date,
					 period_rec.end_date,
					 x_burdened_cost,
					 x_dummy1,
					 x_unit_of_measure,
					 x_err_stage,
					 x_err_code
					 );

		 if (x_err_code <> 0) then
			 gms_error_pkg.gms_message( x_err_name => 'GMS_BU_GET_ACCUM_ACTUALS_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
                 end if;


		 if (nvl(x_burdened_cost,0) <> 0) then

		    gms_budget_pub.add_budget_line(
		    	 p_api_version_number => 1.0
			 ,x_err_code => x_err_code
			 ,x_err_stage => x_err_stage
			 ,x_err_stack => x_err_stack
			 ,p_pm_product_code => 'GMS'
			 ,p_project_id => x_project_id
			 ,p_award_id => x_award_id
			 ,p_budget_type_code => 'AC' -- Approved Cost Budget
			 ,p_task_id => 0
			 ,p_resource_list_member_id => x_uncat_res_list_member_id
			 ,p_budget_start_date => period_rec.start_date
			 ,p_budget_end_date => period_rec.end_date
			 ,p_period_name => period_rec.period_name
			 ,p_description => NULL
			 ,p_raw_cost => x_raw_cost
			 ,p_burdened_cost => x_burdened_cost
			 ,p_quantity =>	x_quantity
			 ,p_pm_budget_line_reference => NULL ); -- jjj - identifies external system


		    if (x_err_code <> 0) then
			 gms_error_pkg.gms_message( x_err_name => 'GMS_ADD_BUDGET_LINE_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);
                        x_funding_status := 0;
			 APP_EXCEPTION.RAISE_EXCEPTION;
                    end if;
		 end if;

	      else
		 -- project level, categorized
		 for res_rec in (select m.resource_list_member_id,
					m.resource_id,
					m.track_as_labor_flag
				 from   pa_resource_list_members m
				 where  m.resource_list_id = x_resource_list_id
				 and    not exists
					(select 1
					 from   pa_resource_list_members m1
					 where  m1.parent_member_id =
						  m.resource_list_member_id
					 AND    NVL(m1.migration_code,'M') ='M') -- Bug 3626671
			         and  exists (select 1 -- Bug 1831151
                                                from gms_balances gb
                                                where budget_version_id = x_current_budget_version_id
                                                and  gb.resource_list_member_id=m.resource_list_member_id)
				AND    NVL(m.migration_code,'M') ='M') -- Bug 3626671
		 loop
                    x_err_stage := 'process period and resource <'
			|| period_rec.period_name
		        || '><' || to_char(res_rec.resource_list_member_id)
		        || '>';

		    x_burdened_cost := 0;
		    x_unit_of_measure := NULL;

			-- Diverted the call to local procedure for Bug 1831151 instead of PA

		    get_proj_accum_actuals(x_project_id,
					    NULL,
                        x_current_budget_version_id,
					    res_rec.resource_list_member_id,
					    x_time_phased_type_code,
					    period_rec.period_name,
					    period_rec.start_date,
					    period_rec.end_date,
					    x_burdened_cost,
					    x_dummy1,
					    x_unit_of_measure,
					    x_err_stage,
					    x_err_code
					    );

		    if (x_err_code <> 0) then
			 gms_error_pkg.gms_message( x_err_name => 'GMS_BU_GET_ACCUM_ACTUALS_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
                    end if;

			if( nvl(x_burdened_cost,0) <> 0) then

		    gms_budget_pub.add_budget_line(
		    	 p_api_version_number => 1.0
			 ,x_err_code => x_err_code
			 ,x_err_stage => x_err_stage
			 ,x_err_stack => x_err_stack
			 ,p_pm_product_code => 'GMS'
			 ,p_project_id => x_project_id
			 ,p_award_id => x_award_id
			 ,p_budget_type_code => 'AC'
			 ,p_task_id => 0
			 ,p_resource_list_member_id => res_rec.resource_list_member_id
			 ,p_budget_start_date => period_rec.start_date
			 ,p_budget_end_date => period_rec.end_date
			 ,p_period_name => period_rec.period_name
			 ,p_description => NULL
			 ,p_raw_cost => x_raw_cost
			 ,p_burdened_cost => x_burdened_cost
			 ,p_quantity =>	x_quantity
			 ,p_pm_budget_line_reference => NULL ); -- jjj - identifies external system


		       if (x_err_code <> 0) then
			 gms_error_pkg.gms_message( x_err_name => 'GMS_ADD_BUDGET_LINE_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);
                        x_funding_status := 0;
			APP_EXCEPTION.RAISE_EXCEPTION;
                       end if;

		    end if;

		 end loop;  -- resource

	      end if;

           elsif (x_entry_level_code = 'T') then

	      -- go through every top level task
	      for top_task_rec in (select t.task_id
			       from   pa_tasks t
			       where  t.project_id = x_project_id
			       and    t.task_id = t.top_task_id
                               and  EXISTS ( SELECT 1    -- added for bug 1831151
                                   FROM gms_balances gb
                                   WHERE gb.budget_version_id =
                                                  x_current_budget_version_id
                                   AND gb.top_task_id = t.task_id )) loop
		 x_burdened_cost:= 0;

	         if (x_categorization_code = 'N') then
		       x_burdened_cost := 0;
		       x_unit_of_measure := NULL;

               -- Diverted the call to local procedure for Bug 1831151 instead of PA
		       get_proj_accum_actuals(x_project_id,
					       top_task_rec.task_id,
                            x_current_budget_version_id,
					       NULL,
					       x_time_phased_type_code,
					       period_rec.period_name,
					       period_rec.start_date,
					       period_rec.end_date,
					       x_burdened_cost,
					       x_dummy1,
					       x_unit_of_measure,
					       x_err_stage,
					       x_err_code
					       );

		       if (x_err_code <> 0) then
 		 gms_error_pkg.gms_message( x_err_name => 'GMS_BU_GET_ACCUM_ACTUALS_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
                       end if;
           -- commented for bug 1831151
		   /* if x_budget_amount_code = 'C' then
		       x_revenue := null;
		    else
		       x_raw_cost := null;
		       x_burdened_cost := null;
		    end if;

		    if (   (nvl(x_quantity,0) <> 0)
		        or (nvl(x_raw_cost,0) <> 0)
		       or (nvl(x_revenue,0) <> 0)) then */

			if (nvl(x_burdened_cost,0) <> 0) then

		    gms_budget_pub.add_budget_line(
		    	 p_api_version_number => 1.0
			 ,x_err_code => x_err_code
			 ,x_err_stage => x_err_stage
			 ,x_err_stack => x_err_stack
			 ,p_pm_product_code => 'GMS'
			 ,p_project_id => x_project_id
			 ,p_award_id => x_award_id
			 ,p_budget_type_code => 'AC'
			 ,p_task_id => top_task_rec.task_id
			 ,p_resource_list_member_id => x_uncat_res_list_member_id
			 ,p_budget_start_date => period_rec.start_date
			 ,p_budget_end_date => period_rec.end_date
			 ,p_period_name => period_rec.period_name
			 ,p_description => NULL
			 ,p_raw_cost => x_raw_cost
			 ,p_burdened_cost => x_burdened_cost
			 ,p_quantity =>	x_quantity
			 ,p_pm_budget_line_reference => NULL ); -- jjj - identifies external system


		          if (x_err_code <> 0) then
 		 	gms_error_pkg.gms_message( x_err_name => 'GMS_ADD_BUDGET_LINE_FAIL',
	 						x_err_code => x_err_code,
	 						x_err_buff => x_err_stage);
                                x_funding_status := 0;
				APP_EXCEPTION.RAISE_EXCEPTION;
                          end if;
		    end if;

	         else
	    -- top level task, categorized
		    for res_rec in (select m.resource_list_member_id,
					   m.resource_id,
					   m.track_as_labor_flag
				    from   pa_resource_list_members m
				    where  m.resource_list_id =
							x_resource_list_id
				    and    not exists
					   (select 1
					    from   pa_resource_list_members m1
					    where  m1.parent_member_id =
						     m.resource_list_member_id
				              AND  NVL(m1.migration_code,'M') ='M') -- Bug 3626671
				    AND EXISTS ( SELECT 1-- added for bug 1831151
                                         FROM gms_balances gb
                                        WHERE budget_version_id =
                                                  x_current_budget_version_id
                                          AND gb.resource_list_member_id =
                                                    m.resource_list_member_id)
			            AND    NVL(m.migration_code,'M') ='M')  loop -- Bug 3626671
		       x_burdened_cost:= 0;
		       x_unit_of_measure := NULL;

                          x_err_stage := 'process period/task/resource <'
			      || period_rec.period_name
		              || '><' || to_char(top_task_rec.task_id)
		              || '><'
			      || to_char(res_rec.resource_list_member_id)
		              || '>';
                 -- Diverted the call to local procedure for Bug 1831151 instead of PA
		         get_proj_accum_actuals(x_project_id,
					        top_task_rec.task_id,
                                                x_current_budget_version_id,
					        res_rec.resource_list_member_id,
					        x_time_phased_type_code,
					        period_rec.period_name,
					        period_rec.start_date,
					        period_rec.end_date,
					         x_burdened_cost,
					        x_dummy1,
					        x_unit_of_measure,
					        x_err_stage,
					        x_err_code
					        );

		             if (x_err_code <> 0) then
 			 gms_error_pkg.gms_message( x_err_name => 'GMS_BU_GET_ACCUM_ACTUALS_FAIL',
		 					x_err_code => x_err_code,
	 						x_err_buff => x_err_stage);

				APP_EXCEPTION.RAISE_EXCEPTION;
                             end if;
			if (nvl(x_burdened_cost,0) <> 0) then
		    gms_budget_pub.add_budget_line(
		    	 p_api_version_number => 1.0
			 ,x_err_code => x_err_code
			 ,x_err_stage => x_err_stage
			 ,x_err_stack => x_err_stack
			 ,p_pm_product_code => 'GMS'
			 ,p_project_id => x_project_id
			 ,p_award_id => x_award_id
			 ,p_budget_type_code => 'AC'
			 ,p_task_id => top_task_rec.task_id
			 ,p_resource_list_member_id => res_rec.resource_list_member_id
			 ,p_budget_start_date => period_rec.start_date
			 ,p_budget_end_date => period_rec.end_date
			 ,p_period_name => period_rec.period_name
			 ,p_description => NULL
			 ,p_raw_cost => x_raw_cost
			 ,p_burdened_cost => x_burdened_cost
			 ,p_quantity =>	x_quantity
			 ,p_pm_budget_line_reference => NULL ); -- jjj - identifies external system


		             if (x_err_code <> 0) then
			 gms_error_pkg.gms_message( x_err_name => 'GMS_ADD_BUDGET_LINE_FAIL',
		 					x_err_code => x_err_code,
	 						x_err_buff => x_err_stage);
                                x_funding_status := 0;
				APP_EXCEPTION.RAISE_EXCEPTION;
                             end if;

                         end if;

		       end loop; -- resource

	            end if;  -- categorized

	      end loop;  -- top task

	   else  -- 'L' or 'M'
	      -- go through every lowest level task
	      for task_rec in (select t.task_id
			       from   pa_tasks t
			       where  t.project_id = x_project_id
			       and    not exists
				      (select 1
				       from   pa_tasks t1
				       where  t1.parent_task_id = t.task_id)
                               AND EXISTS ( SELECT 1 --bug 1831151
                                   FROM gms_balances
                                  WHERE budget_version_id =
                                                  x_current_budget_version_id
                                    AND task_id = t.task_id)

	         ) loop

	         if (x_categorization_code = 'N') then
		    x_burdened_cost := 0;
		    x_unit_of_measure := NULL;
            -- Diverted the call to local procedure for Bug 1831151 instead of PA
		    get_proj_accum_actuals(x_project_id,
					    task_rec.task_id,
                        x_current_budget_version_id,
					    NULL,
					    x_time_phased_type_code,
					    period_rec.period_name,
					    period_rec.start_date,
					    period_rec.end_date,
					    x_burdened_cost,
					    x_dummy1,
					    x_unit_of_measure,
					    x_err_stage,
					    x_err_code
					    );

		    if (x_err_code <> 0) then
			 gms_error_pkg.gms_message( x_err_name => 'GMS_BU_GET_ACCUM_ACTUALS_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
                    end if;
			if (nvl(x_burdened_cost,0) <> 0) then
		    gms_budget_pub.add_budget_line(
		    	 p_api_version_number => 1.0
			 ,x_err_code => x_err_code
			 ,x_err_stage => x_err_stage
			 ,x_err_stack => x_err_stack
			 ,p_pm_product_code => 'GMS'
			 ,p_project_id => x_project_id
			 ,p_award_id => x_award_id
			 ,p_budget_type_code => 'AC'
			 ,p_task_id => task_rec.task_id
			 ,p_resource_list_member_id => x_uncat_res_list_member_id
			 ,p_budget_start_date => period_rec.start_date
			 ,p_budget_end_date => period_rec.end_date
			 ,p_period_name => period_rec.period_name
			 ,p_description => NULL
			 ,p_raw_cost => x_raw_cost
			 ,p_burdened_cost => x_burdened_cost
			 ,p_quantity =>	x_quantity
			 ,p_pm_budget_line_reference => NULL ); -- jjj - identifies external system

		       if (x_err_code <> 0) then
			 gms_error_pkg.gms_message( x_err_name => 'GMS_ADD_BUDGET_LINE_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);
                        x_funding_status := 0;
			APP_EXCEPTION.RAISE_EXCEPTION;
                       end if;

		    end if;

	    else
 	    -- lowest level task, categorized
		    for res_rec in (select m.resource_list_member_id,
					   m.resource_id,
					   m.track_as_labor_flag
				    from   pa_resource_list_members m
				    where  m.resource_list_id =
							x_resource_list_id
				    and    not exists
					   (select 1
					    from   pa_resource_list_members m1
					    where  m1.parent_member_id =
						     m.resource_list_member_id
					      AND  NVL(m1.migration_code,'M') ='M')  -- Bug 3626671
			            AND EXISTS ( SELECT 1 -- Bug 1831151
                                         FROM gms_balances gb
                                        WHERE budget_version_id =
                                                  x_current_budget_version_id
                                          AND gb.resource_list_member_id =
                                                    m.resource_list_member_id )
				    AND NVL(m.migration_code,'M') ='M') loop -- Bug 3626671

               x_err_stage := 'process period/task/resource <'
			   || period_rec.period_name
		           || '><' || to_char(task_rec.task_id)
		           || '><' || to_char(res_rec.resource_list_member_id)
		           || '>';
		       x_burdened_cost := 0;
		       x_unit_of_measure := NULL;
               -- Diverted the call to local procedure for Bug 1831151 instead of PA
		       get_proj_accum_actuals(x_project_id,
					       task_rec.task_id,
                                               x_current_budget_version_id,
					       res_rec.resource_list_member_id,
					       x_time_phased_type_code,
					       period_rec.period_name,
					       period_rec.start_date,
					       period_rec.end_date,
					       x_burdened_cost,
					       x_dummy1,
					       x_unit_of_measure,
					       x_err_stage,
					       x_err_code
					       );

		       if (x_err_code <> 0) then
			            gms_error_pkg.gms_message( x_err_name => 'GMS_BU_GET_ACCUM_ACTUALS_FAIL',
	 					x_err_code => x_err_code,
	 					x_err_buff => x_err_stage);

						APP_EXCEPTION.RAISE_EXCEPTION;
                       end if;
			  if  (nvl(x_burdened_cost,0) <> 0) then

		    gms_budget_pub.add_budget_line(
		    	 p_api_version_number => 1.0
			 ,x_err_code => x_err_code
			 ,x_err_stage => x_err_stage
			 ,x_err_stack => x_err_stack
			 ,p_pm_product_code => 'GMS'
			 ,p_project_id => x_project_id
			 ,p_award_id => x_award_id
			 ,p_budget_type_code => 'AC'
			 ,p_task_id => task_rec.task_id
			 ,p_resource_list_member_id => res_rec.resource_list_member_id
			 ,p_budget_start_date => period_rec.start_date
			 ,p_budget_end_date => period_rec.end_date
			 ,p_period_name => period_rec.period_name
			 ,p_description => NULL
			 ,p_raw_cost => x_raw_cost
			 ,p_burdened_cost => x_burdened_cost
			 ,p_quantity =>	x_quantity
			 ,p_pm_budget_line_reference => NULL ); -- jjj - identifies external system

 		          if (x_err_code <> 0) then
					 gms_error_pkg.gms_message( x_err_name => 'GMS_ADD_BUDGET_LINE_FAIL',
		 					x_err_code => x_err_code,
		 					x_err_buff => x_err_stage);
                                x_funding_status := 0;
				APP_EXCEPTION.RAISE_EXCEPTION;
                          end if;

                      end if;

		    end loop; -- resource

	         end if;

	      end loop;  -- task

	   end if;

        end loop; -- period


     if (x_time_phased_type_code = 'P') then
        close pa_cursor;
     else
        close gl_cursor;
     end if;


     x_err_stack := old_stack;


  end copy_actual;
------------------------------------------------------------------------------------
   -- added for bug 1831151
   -- Actuals accumulation API

   -- Following procedure are used to fetch actual amounts from gms_balances
   -- based on the parameters passed.

   PROCEDURE get_proj_txn_accum (
      x_project_id                  IN       NUMBER,
      x_task_id                     IN       NUMBER DEFAULT NULL,
      x_current_budget_version_id   IN       NUMBER,
      x_period_type                 IN       VARCHAR2 DEFAULT 'P',
      x_from_period_name            IN       VARCHAR2 DEFAULT NULL,
      x_prd_start_date              IN       DATE DEFAULT NULL,
      x_prd_end_date                IN       DATE DEFAULT NULL,
      x_burdened_cost               IN OUT NOCOPY   NUMBER,
      x_billable_burdened_cost      IN OUT NOCOPY   NUMBER,
      x_unit_of_measure             IN OUT NOCOPY   VARCHAR2,
      x_err_stage                   IN OUT NOCOPY   VARCHAR2,
      x_err_code                    IN OUT NOCOPY   NUMBER
   ) IS
      CURSOR seltxnaccums_p (x_prd_start_date IN DATE, x_prd_end_date IN DATE) IS
         SELECT gmsb.actual_period_to_date tot_burdened_cost,
                gmsb.actual_period_to_date tot_billable_burdened_cost
           FROM gms_balances gmsb, pa_periods pp
          WHERE gmsb.project_id = x_project_id
            AND gmsb.budget_version_id = x_current_budget_version_id
            AND gmsb.task_id = DECODE (
                                  x_task_id,
                                  NULL, gmsb.task_id,
                                  0, gmsb.task_id,
								  gmsb.top_task_id,gmsb.task_id,
                                  x_task_id
                               )
            AND x_period_type = 'P'
            AND pp.start_date >= gmsb.start_date
            AND pp.end_date <= gmsb.end_date
			AND gmsb.balance_type = 'EXP'
            AND pp.start_date BETWEEN NVL (x_prd_start_date, pp.start_date)
                                  AND NVL (x_prd_end_date, pp.end_date);

      CURSOR seltxnaccums_g (x_prd_start_date IN DATE, x_prd_end_date IN DATE) IS
         SELECT gmsb.actual_period_to_date tot_burdened_cost,
                gmsb.actual_period_to_date tot_billable_burdened_cost
           FROM pa_implementations imp,
                gl_period_statuses glp,
                gms_balances gmsb
          WHERE gmsb.project_id = x_project_id
            AND gmsb.budget_version_id = x_current_budget_version_id
            AND gmsb.task_id = DECODE (
                                  x_task_id,
                                  NULL, gmsb.task_id,
                                  0, gmsb.task_id,
								  gmsb.top_task_id,gmsb.task_id ,
                                  x_task_id
                               )
            AND x_period_type = 'G'
			AND gmsb.balance_type = 'EXP'
            AND glp.set_of_books_id = imp.set_of_books_id
            AND glp.application_id = 101
            AND glp.start_date >= gmsb.start_date
            AND glp.end_date <= gmsb.end_date
            AND glp.adjustment_period_flag = 'N'
            AND glp.start_date BETWEEN NVL (x_prd_start_date, glp.start_date)
                                   AND NVL (x_prd_end_date, glp.end_date);

      txnaccumrec_p   seltxnaccums_p%ROWTYPE;
      txnaccumrec_g   seltxnaccums_g%ROWTYPE;
   BEGIN
      x_err_code := 0;
      x_err_stage := 'Getting the Project Txn Accumlation';

      -- all of the accumlation numbers are initialized in the calling
      -- procedure


      IF x_period_type = 'G' THEN
         FOR txnaccumrec_g IN seltxnaccums_g (
                                 x_prd_start_date,
                                 x_prd_end_date
                              )
         LOOP
            x_burdened_cost :=
                    x_burdened_cost
                  + NVL (txnaccumrec_g.tot_burdened_cost, 0);
            x_billable_burdened_cost :=
                    x_billable_burdened_cost
                  + NVL (txnaccumrec_g.tot_billable_burdened_cost, 0);
         END LOOP;

         x_unit_of_measure := NULL;
      END IF;                                  /* End of x_period_type = 'G' */

      IF x_period_type = 'P' THEN
         FOR txnaccumrec_p IN seltxnaccums_p (
                                 x_prd_start_date,
                                 x_prd_end_date
                              )
         LOOP
            x_burdened_cost :=
                    x_burdened_cost
                  + NVL (txnaccumrec_p.tot_burdened_cost, 0);
            x_billable_burdened_cost :=
                    x_billable_burdened_cost
                  + NVL (txnaccumrec_p.tot_billable_burdened_cost, 0);
         END LOOP;

         x_unit_of_measure := NULL;
      END IF;                                  /* End of x_period_type = 'P' */
   END get_proj_txn_accum;
-----------------------------------------------------------------------------------------
   -- Added for bug 1831151
   -- Actuals accumulation API

   -- Following procedure are used to fetch actual amounts from gms_balances
   -- based on the parameters passed.


   PROCEDURE get_proj_res_accum (
      x_project_id                  IN       NUMBER,
      x_task_id                     IN       NUMBER DEFAULT NULL,
      x_current_budget_version_id   IN       NUMBER,
      x_resource_list_member_id     IN       NUMBER DEFAULT NULL,
      x_period_type                 IN       VARCHAR2 DEFAULT 'P',
      x_from_period_name            IN       VARCHAR2 DEFAULT NULL,
      x_prd_start_date              IN       DATE DEFAULT NULL,
      x_prd_end_date                IN       DATE DEFAULT NULL,
      x_burdened_cost               IN OUT NOCOPY   NUMBER,
      x_billable_burdened_cost      IN OUT NOCOPY   NUMBER,
      x_unit_of_measure             IN OUT NOCOPY   VARCHAR2,
      x_err_stage                   IN OUT NOCOPY   VARCHAR2,
      x_err_code                    IN OUT NOCOPY   NUMBER
   ) IS
      CURSOR selresaccums_p (x_prd_start_date IN DATE, x_prd_end_date IN DATE) IS
         SELECT gmsb.actual_period_to_date tot_burdened_cost,
                gmsb.actual_period_to_date tot_billable_burdened_cost
           FROM gms_balances gmsb, pa_periods pp
          WHERE gmsb.project_id = x_project_id
            AND gmsb.budget_version_id = x_current_budget_version_id
            AND gmsb.task_id = DECODE (
                                  x_task_id,
                                  NULL, gmsb.task_id,
                                  0, gmsb.task_id,
								  gmsb.top_task_id,gmsb.task_id ,
                                  x_task_id
                               )
            AND gmsb.resource_list_member_id = x_resource_list_member_id
            AND x_period_type = 'P'
			AND gmsb.balance_type = 'EXP'
            AND pp.start_date >= gmsb.start_date
            AND pp.end_date <= gmsb.end_date
            AND pp.start_date BETWEEN NVL (x_prd_start_date, pp.start_date)
                                  AND NVL (x_prd_end_date, pp.end_date)
            AND NVL (gmsb.actual_period_to_date, 0) <> 0;

      CURSOR selresaccums_g (x_prd_start_date IN DATE, x_prd_end_date IN DATE) IS
         SELECT gmsb.actual_period_to_date tot_burdened_cost,
                gmsb.actual_period_to_date tot_billable_burdened_cost
           FROM pa_implementations imp,
                gl_period_statuses glp,
                gms_balances gmsb
          WHERE gmsb.project_id = x_project_id
            AND gmsb.budget_version_id = x_current_budget_version_id
            AND gmsb.task_id = DECODE (
                                  x_task_id,
                                  NULL, gmsb.task_id,
                                  0, gmsb.task_id,
								  gmsb.top_task_id,gmsb.task_id ,
                                  x_task_id
                               )
            AND gmsb.resource_list_member_id = x_resource_list_member_id
            AND x_period_type = 'G'
			AND gmsb.balance_type = 'EXP'
            AND glp.set_of_books_id = imp.set_of_books_id
            AND glp.application_id = 101
            AND glp.start_date >= gmsb.start_date
            AND glp.end_date <= gmsb.end_date
            AND glp.adjustment_period_flag = 'N'
            AND glp.start_date BETWEEN NVL (x_prd_start_date, glp.start_date)
                                   AND NVL (x_prd_end_date, glp.end_date)
            AND NVL (gmsb.actual_period_to_date, 0) <> 0;


      resaccumrec_p   selresaccums_p%ROWTYPE;
      resaccumrec_g   selresaccums_g%ROWTYPE;
   BEGIN
      x_err_code := 0;
      x_err_stage := 'Getting the Project Res Accumlation';

      -- all of the accumlation numbers are initialized in the calling
      -- procedure

      IF x_period_type = 'G' THEN
         FOR resaccumrec_g IN selresaccums_g (
                                 x_prd_start_date,
                                 x_prd_end_date
                              )
         LOOP
	        x_burdened_cost :=
                    x_burdened_cost
                  + NVL (resaccumrec_g.tot_burdened_cost, 0);
            x_billable_burdened_cost :=
                    x_billable_burdened_cost
                  + NVL (resaccumrec_g.tot_billable_burdened_cost, 0);
            x_unit_of_measure := NULL;
         END LOOP;
      END IF;                                  /* End of x_period_type = 'G' */

      IF x_period_type = 'P' THEN
         FOR resaccumrec_p IN selresaccums_p (
                                 x_prd_start_date,
                                 x_prd_end_date
                              )
         LOOP

            x_burdened_cost :=
                    x_burdened_cost
                  + NVL (resaccumrec_p.tot_burdened_cost, 0);
            x_billable_burdened_cost :=
                    x_billable_burdened_cost
                  + NVL (resaccumrec_p.tot_billable_burdened_cost, 0);
            x_unit_of_measure := NULL;
         END LOOP;
      END IF;                                  /* End of x_period_type = 'P' */
   END get_proj_res_accum;
--------------------------------------------------------------------------------------
-- added for bug 1831151
   PROCEDURE get_proj_accum_actuals (
      x_project_id                  IN       NUMBER,
      x_task_id                     IN       NUMBER DEFAULT NULL,
      x_current_budget_version_id   IN       NUMBER,
      x_resource_list_member_id     IN       NUMBER DEFAULT NULL,
      x_period_type                 IN       VARCHAR2 DEFAULT 'P',
      x_from_period_name            IN       VARCHAR2 DEFAULT NULL,
      x_prd_start_date              IN       DATE DEFAULT NULL,
      x_prd_end_date                IN       DATE DEFAULT NULL,
      x_burdened_cost               IN OUT NOCOPY   NUMBER,
      x_billable_burdened_cost      IN OUT NOCOPY   NUMBER,
      x_unit_of_measure             IN OUT NOCOPY   VARCHAR2,
      x_err_stage                   IN OUT NOCOPY   VARCHAR2,
      x_err_code                    IN OUT NOCOPY   NUMBER
   ) IS
   BEGIN
      x_err_code := 0;
      x_err_stage := 'Getting the Project Accumlation';
      x_burdened_cost := 0;
      x_billable_burdened_cost := 0;
      x_unit_of_measure := NULL;

      IF (x_resource_list_member_id IS NULL) THEN
         -- Call the txn accum
         get_proj_txn_accum (
            x_project_id,
            x_task_id,
            x_current_budget_version_id,
            x_period_type,
            x_from_period_name,
            x_prd_start_date,
            x_prd_end_date,
            x_burdened_cost,
            x_billable_burdened_cost,
            x_unit_of_measure,
            x_err_stage,
            x_err_code
         );
      ELSE
         -- Call the resource accum
         get_proj_res_accum (
            x_project_id,
            x_task_id,
            x_current_budget_version_id,
            x_resource_list_member_id,
            x_period_type,
            x_from_period_name,
            x_prd_start_date,
            x_prd_end_date,
            x_burdened_cost,
            x_billable_burdened_cost,
            x_unit_of_measure,
            x_err_stage,
            x_err_code
         );
      END IF;
   END get_proj_accum_actuals;

-------------------------------------------------------------------------------------
-- This procedure is used by the baseline procedure to copy budget lines and
-- resource assignments from a source (draft) budget version to the destination
-- (baselined) budget version for a single project
--

  procedure copy_draft_lines  (x_src_version_id        in     number,
                               x_time_phased_type_code in     varchar2,
                               x_entry_level_code      in     varchar2,
                               x_dest_version_id       in     number,
                               x_err_code              in out NOCOPY number,
                               x_err_stage             in out NOCOPY varchar2,
                               x_err_stack             in out NOCOPY varchar2,
                               x_pm_flag               in     varchar2 )
  is
    -- Standard who
    x_created_by                 NUMBER(15);
    x_last_update_login          NUMBER(15);

    old_stack  varchar2(630);

  begin

     IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('*** Start of GMS_BUDGET_CORE.COPY_DRAFT_LINES ***','C');
     END IF;

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy_draft_lines';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     savepoint before_copy_draft_lines;

     x_err_stage := 'copy resource assignment <' ||  to_char(x_src_version_id)
		    || '>' ;

     IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('GMS_BUDGET_CORE.COPY_DRAFT_LINES- Inserting records into gms_resource_assignments','C');
     END IF;


        insert into gms_resource_assignments
	    (resource_assignment_id,
	     budget_version_id,
	     project_id,
	     task_id,
	     resource_list_member_id,
	     last_update_date,
	     last_updated_by,
	     creation_date,
	     created_by,
	     last_update_login,
	     unit_of_measure,
	     track_as_labor_flag)
           select gms_resource_assignments_s.nextval,
	       x_dest_version_id,
	       s.project_id,
	       s.task_id,
	       s.resource_list_member_id,
	       SYSDATE,
	       x_created_by,
	       SYSDATE,
	       x_created_by,
	       x_last_update_login,
	       s.unit_of_measure,
	       s.track_as_labor_flag
           from
	       gms_resource_assignments s
           where  s.budget_version_id = x_src_version_id;


        x_err_stage := 'copy budget lines <' ||to_char(x_src_version_id)
		    || '>' ;

     IF L_DEBUG = 'Y' THEN
        gms_error_pkg.gms_debug('GMS_BUDGET_CORE.COPY_DRAFT_LINES- Inserting records into gms_budget_lines','C');
     END IF;

             insert into gms_budget_lines
	       (resource_assignment_id,
	        start_date,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
	        end_date,
	        period_name,
	        quantity,
	        raw_cost,
	        burdened_cost,
	        revenue,
                change_reason_code,
                description,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
		pm_product_code,
		pm_budget_line_reference,
		raw_cost_source,
		burdened_cost_source,
		quantity_source,
		revenue_source
                )
              select
		da.resource_assignment_id,
	        l.start_date,
		SYSDATE,
                x_created_by,
                SYSDATE,
                x_created_by,
                x_last_update_login,
	        l.end_date,
	        l.period_name,
	        l.quantity,
	        l.raw_cost,
	        l.burdened_cost,
	        l.revenue,
                l.change_reason_code,
	        l.description,
                l.attribute_category,
                l.attribute1,
                l.attribute2,
                l.attribute3,
                l.attribute4,
                l.attribute5,
                l.attribute6,
                l.attribute7,
                l.attribute8,
                l.attribute9,
                l.attribute10,
                l.attribute11,
                l.attribute12,
                l.attribute13,
                l.attribute14,
                l.attribute15,
		decode(x_pm_flag,'Y',l.pm_product_code,NULL),
		decode(x_pm_flag,'Y',l.pm_budget_line_reference,NULL),
                'B',
                'B',
                'B',
                'B'
	      from  gms_budget_lines l,
		    gms_resource_assignments sa,
		    gms_resource_assignments da
	     where  l.resource_assignment_id = sa.resource_assignment_id
             and    sa.budget_version_id = x_src_version_id
	     and    sa.task_id = da.task_id
	     and    sa.project_id = da.project_id
             and    sa.resource_list_member_id = da.resource_list_member_id
             and    da.budget_version_id = x_dest_version_id;

     if(x_err_code <> 0) then
        rollback to before_copy_draft_lines;
        return;
     end if;

     x_err_stack := old_stack;

     IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('*** End of GMS_BUDGET_CORE.COPY_DRAFT_LINES ***','C');
     END IF;

  exception
      when others then
         -- Bug 2587078 : Modified the below code to set proper error message
	   -- x_err_code := SQLCODE;
        x_err_stage := 'GMS_BUDGET_CORE.COPY_DRAFT_LINES - In others exception';
        gms_error_pkg.gms_message(x_err_name => 'GMS_BU_COPY_BUDG_LINES_FAIL',
          		                x_err_code => x_err_code,
			                x_err_buff => x_err_stage);
         fnd_msg_pub.add;
         rollback to before_copy_draft_lines;
	 return;

 end copy_draft_lines;

END gms_budget_core;

/
