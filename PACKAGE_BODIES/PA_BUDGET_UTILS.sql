--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_UTILS" as
-- $Header: PAXBUBUB.pls 120.11 2007/11/27 06:59:01 vgovvala ship $

  NO_DATA_FOUND_ERR number := 100;

  -- Bug Fix: 4569365. Removed MRC code.
  -- g_mrc_exception EXCEPTION;
  Invalid_Arg_Exc  EXCEPTION; -- Added for FPM, Tracking Bug No - 3354518.

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
g_module_name VARCHAR2(100) := 'pa.plsql.PA_BUDGET_UTILS';

  procedure get_draft_version_id (x_project_id        in     number,
                  x_budget_type_code  in     varchar2,
                  x_budget_version_id in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     old_stack varchar2(630);
  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_draft_version_id';

     x_err_stage := 'get draft budget id <' || to_char(x_project_id)
            || '><' || x_budget_type_code || '>' ;




     select bv.budget_version_id
     into   x_budget_version_id
     from   pa_budget_versions bv , pa_budget_types bt
     where  bv.project_id = x_project_id
     and    bv.budget_type_code = x_budget_type_code
     and    bv.budget_status_code in ('W', 'S')
     and    bv.budget_type_code = bt.budget_type_code
     and    nvl(bt.plan_type,'BUDGET') = 'BUDGET';



     x_err_stack := old_stack;

  exception
     when NO_DATA_FOUND then
     x_err_code := 10;
     x_err_stage := 'PA_BU_CORE_NO_VERSION_ID';

     when others then
     x_err_code := SQLCODE;

  end get_draft_version_id;

-----------------------------------------------------------------------------

--Name:                 Get_Baselined_Version_Id
--Type:                 Procedure
--
--Description:      Gets the baselined budget or plan type identifier for
--                      the passed inputs.
--
--
--Called subprograms:   None.
--
--
--
--History:
--      XX-XXX-XX   who?    - Created
--


  procedure get_baselined_version_id (x_project_id    in     number,
                  x_budget_type_code  in     varchar2,
                  x_budget_version_id in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     old_stack varchar2(630);
  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_baselined_version_id';

     x_err_stage := 'get baselined budget id <' || to_char(x_project_id)
            || '><' || x_budget_type_code || '>' ;

     select bv.budget_version_id
     into   x_budget_version_id
     from   pa_budget_versions bv, pa_budget_types bt
     where  bv.project_id = x_project_id
     and    bv.budget_type_code = x_budget_type_code
     and    bv.current_flag = 'Y'
     and    bv.budget_type_code = bt.budget_type_code
     and    nvl(bt.plan_type,'BUDGET') = 'BUDGET';



     x_err_stack := old_stack;

  exception
     when NO_DATA_FOUND then
     x_err_code := 10;
     x_err_stage := 'PA_BU_CORE_NO_VERSION_ID';

     when others then
     x_err_code := SQLCODE;

  end get_baselined_version_id;

-----------------------------------------------------------------------------

  procedure get_original_version_id (x_project_id    in     number,
                  x_budget_type_code  in     varchar2,
                  x_budget_version_id in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     old_stack varchar2(630);
  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_original_version_id';

     x_err_stage := 'get original budget id <' || to_char(x_project_id)
            || '><' || x_budget_type_code || '>' ;

     select bv.budget_version_id
     into   x_budget_version_id
     from   pa_budget_versions bv, pa_budget_types bt
     where  bv.project_id = x_project_id
     and    bv.budget_type_code = x_budget_type_code
     and    bv.current_original_flag = 'Y'
     and    bv.budget_type_code = bt.budget_type_code
     and    nvl(bt.plan_type,'BUDGET') = 'BUDGET';

     x_err_stack := old_stack;

  exception
     when NO_DATA_FOUND then
     x_err_code := 10;
     x_err_stage := 'PA_BU_CORE_NO_VERSION_ID';

     when others then
     x_err_code := SQLCODE;

  end get_original_version_id;

-----------------------------------------------------------------------------

--Name:                 get_default_resource_list_id
--Type:                 Procedure
--
--Description:
--
--Notes:
--                      This procedure is only called from the budgets form.
--
--                      !!! This procedure does NOT support the FP model !!!
--
--
--
--Called subprograms:   pa_budget_utils.get_baselined_version_id
--
--
--
--History:
--      XX-XXX-XX   who?    - Created
--


  procedure get_default_resource_list_id (x_project_id    in     number,
                  x_budget_type_code  in     varchar2,
                  x_resource_list_id  in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     x_budget_amount_code  PA_BUDGET_TYPES.BUDGET_AMOUNT_CODE%TYPE;
     x_allow_budget_entry_flag  varchar2(2);
     x_baselined_version_id number;
     old_stack varchar2(630);

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->get_default_resource_list_id';

--           if a baselined budget exists
--           then get the resource_list_id from it else get it from
--           pa_project_types

     -- Get the baselined version
     x_err_stage := 'get baselined budget id <' || to_char(x_project_id)
            || '><' || x_budget_type_code || '>';




    pa_budget_utils.get_baselined_version_id(
                                  x_project_id        => x_project_id,
                  x_budget_type_code  => x_budget_type_code,
                  x_budget_version_id => x_baselined_version_id,
                      x_err_code          => x_err_code,
                      x_err_stage         => x_err_stage,
                      x_err_stack         => x_err_stack
                                  );



     if (x_err_code = 0) then
        -- baseliend budget exists, use it to get the resource list

    select resource_list_id
    into   x_resource_list_id
        from   pa_budget_versions
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
       x_err_code := 10;
       x_err_stage := 'PA_BU_ENTRY_NOT_ALLOWED';
       return;
    end if;

    if (x_resource_list_id is null) then
        x_err_code := NO_DATA_FOUND_ERR;
        x_err_stage := 'PA_BU_NO_DFLT_RESOURCE_LIST';
        return;
    end if;

    x_err_stack := old_stack;
     else
        -- x_err_code < 0
    return;
     end if;

   exception
       when others then
     x_err_code := SQLCODE;

  end get_default_resource_list_id;

-----------------------------------------------------------------------------

  procedure get_default_entry_method_code (x_project_id       in     number,
                  x_budget_type_code          in     varchar2,
                  x_budget_entry_method_code  in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_code                  in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage                 in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack                 in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     x_budget_amount_code  PA_BUDGET_TYPES.BUDGET_AMOUNT_CODE%TYPE;
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
    x_err_code := 10;
    x_err_stage := 'PA_BU_ENTRY_NOT_ALLOWED';
    return;
     end if;

     if (x_budget_entry_method_code is null) then
         x_err_code := NO_DATA_FOUND_ERR;
         x_err_stage := 'PA_BU_NO_DFLT_ENTRY_METHOD';
         return;
     end if;

     x_err_stack := old_stack;

  exception
     when others then
     x_err_code := SQLCODE;

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

--  =================================================

--Name:                 check_proj_budget_exists
--Type:                 Function
--
--Description:  This function is called primarily from Billing and Projects Maintenance packages
--
--              This function has been rewritten to fully support both the r11.5.7 and FP models.
--
--              New Rules for r11.5.7 and FP Models:
--
--              For x_budget_status_code = A(ny),
--              1.  If both the x_budget_type_code and the p_plan_type_id parameters are passed as NULL,
--                  then the logic must first query the r11.5.7 model and then the FP model for data.
--                  As soon as any data is detected, the logic returns control to the calling object.
--
--              2.  If one of the aforementioned IN-parameters is passed as NON-null and the other as NULL,
--                  then the logic should only query for NON-null parameter.
--
--              3.  If both the x_budget_type_code and the p_plan_type_id parameters are passed,
--                  then the logic must first query the r11.5.7 model and then the FP model for data.
--                  As soon as any data is detected, the logic returns control to the calling object.
--
--              4.  If both the p_plan_type_id and the p_version_type IN-parameters are passed with
--                  NON-null values, then the FP logic must check for the plan_type and version_type.
--
--              For x_budget_status_code = B(aseline)
--              1.  As per design doc, if 'AC' or 'AR' budget types passed as x_budget_type_code
--                  AND X_FIN_PLAN_TYPE_ID IS NULL,
--                    THEN
--                       Use the approved_cost/rev_plan_type_flags to determine if ANY AC/AR baselined budgets
--                       have been created for r11.5.7 and FP.
--
--
--
--
--
--
--
--Called subprograms: none
--
--
--
--History:
--      xx-xxx-xx       who?    - Created
--
--      20-AUG-02   jwhite  - Extensively rewrote this procedure to fully support both
--                                the r11.5.7 and FP models.
--
--
--      25-OCT-02      jwhite   - Bug 2582612
--                                check_proj_budget_exists procedure. Repositioned
--                                a RETURN statement.
--

  function check_proj_budget_exists (x_project_id             in number,
                                     x_budget_status_code     IN varchar2,
                     x_budget_type_code       IN varchar2 default NULL,
                                     x_fin_plan_type_id       IN NUMBER   default NULL,
                                     x_version_type           IN VARCHAR2 default NULL
                                    )
  return number

  is

     dummy number := 0;

  begin



     -- Check for Valid Budget_Status_Code ---------------------------

     IF (nvl(x_budget_status_code,'X') NOT IN ('A', 'B') )
        THEN
          dummy := 0;
          RETURN dummy;
     END IF;


     -- Find Any Budget/Plan Type  ---------------------------


     IF (x_budget_status_code = 'A')
       THEN


       IF (x_budget_type_code is NULL AND x_fin_plan_type_id is NULL)
          THEN

          -- r11.5.7 Model? --------------
          BEGIN

            select 1
            into   dummy
            from   dual
            where  exists
           (select 1
            from   pa_budget_versions bv, pa_budget_types bt
            where  bv.project_id = x_project_id
                and    bv.budget_type_code is NOT NULL  -- This must be specified for r11.5.7 Budgets Model
                and    bv.budget_type_code = bt.budget_type_code
                and    nvl(bt.plan_type,'BUDGET') = 'BUDGET');

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  dummy := 0;

          END;

          IF (dummy = 1)
            THEN
               RETURN dummy;
          END IF;

          -- FP Model? --------------
          BEGIN

           /* Changes for FP.M, Tracking Bug No - 3354518
           Adding conditon in the where clause below to
           check for new column use_for_workplan flag.
           Introducing this check will ensure that the budget
       version is used for FINPLAN and not WorkPlan.
       So adding a join to pa_fin_plan_types_b and
       checking status of use_for_workplan_flag */
            select 1
            into   dummy
            from   dual
            where  exists
           (select 1
            from   pa_budget_versions bv
                where  bv.project_id = x_project_id
                and    bv.fin_plan_type_id is NOT NULL  -- Specified for FP Model
                and    nvl(bv.wp_version_flag,'N') = 'N'  -- (Added for Patchset M,Tracking Bug No - 3354518)
                );

           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  dummy := 0;

          END;
          RETURN dummy;

      ELSIF (x_budget_type_code is NOT NULL
                   AND x_fin_plan_type_id IS NULL)
         THEN

          -- r11.5.7 Model?
          BEGIN

            select 1
            into   dummy
            from   dual
            where  exists
           (select 1
            from   pa_budget_versions bv, pa_budget_types bt
            where  bv.project_id = x_project_id
        and    bv.budget_type_code = x_budget_type_code
                and    bv.budget_type_code = bt.budget_type_code
                and    nvl(bt.plan_type,'BUDGET') = 'BUDGET');

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  dummy := 0;

          END;
          RETURN dummy;

      ELSIF (x_fin_plan_type_id is NOT NULL
                 AND x_budget_type_code is NULL)
         THEN

                 -- FP Model?
                 BEGIN

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                     where  bv.project_id = x_project_id
                     and    bv.fin_plan_type_id = x_fin_plan_type_id
                     and    bv.version_type = nvl(x_version_type, bv.version_type)
                    );

                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     dummy := 0;

                 END;
                 RETURN dummy;

         ELSIF (x_budget_type_code is NOT NULL
                   AND x_fin_plan_type_id IS NOT NULL)
           THEN

          -- r11.5.7 Model?
          BEGIN

            select 1
            into   dummy
            from   dual
            where  exists
           (select 1
            from   pa_budget_versions bv, pa_budget_types bt
            where  bv.project_id = x_project_id
        and    bv.budget_type_code = x_budget_type_code
                and    bv.budget_type_code = bt.budget_type_code
                and    nvl(bt.plan_type,'BUDGET') = 'BUDGET');

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  dummy := 0;

          END;

          IF (dummy = 1)
            THEN
               RETURN dummy;
          END IF;

           -- FP Model?
          BEGIN

            select 1
            into   dummy
            from   dual
            where  exists
        (select 1
         from   pa_budget_versions bv
             where  bv.project_id = x_project_id
             and    bv.fin_plan_type_id = x_fin_plan_type_id
             and    bv.version_type = nvl(x_version_type, bv.version_type)
            );

            EXCEPTION
             WHEN NO_DATA_FOUND THEN
               dummy := 0;

          END;
          RETURN dummy;


      END IF; -- IF (x_budget_type_code is NULL AND x_fin_plan_type_id is NULL)

    END IF; -- if (x_budget_status_code = 'A')



   -- Find BASELINED Budget/PLan Type  ---------------------------

    IF (x_budget_status_code = 'B')
       THEN

       -- Find a BASELINED r11.5.7 Budget or FP Plan Type  -----------

       -- As per design doc, if 'AC' or 'AR' budget types passed as x_budget_type_code
       -- and  x_fin_plan_type_id IS NULL,
       --   then
       --     use the approved_cost/rev_plan_type_flags to determine if ANY AC/AR baselined budgets
       --     have ever been created for either r11.5.7 and/or FP.



       IF (  NVL(x_budget_type_code,'X') IN ('AC','AR')  )
         THEN


            IF (x_fin_plan_type_id IS NULL)
              THEN

                 -- ANY BASELINED AC/AR r11.5.7 Budgets and/or FP Plan Types Exist?
                 BEGIN

                  IF (x_budget_type_code = 'AC')
                    THEN

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                     where  bv.project_id = x_project_id
                     and    bv.approved_cost_plan_type_flag = 'Y'
                     and    bv.current_flag = 'Y'
                    );


                   ELSE
                   -- Must be 'AR'


                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                     where  bv.project_id = x_project_id
                     and    bv.approved_rev_plan_type_flag = 'Y'
                     and    bv.current_flag = 'Y'
                    );


                   END IF; --x_budget_type_code = 'AC'

                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     dummy := 0;


                 END;
                RETURN dummy;

             ELSE
                 -- Any Baselined Approved Cost/Approved Revenue FP PLAN TYPES Exist?

                 BEGIN

                  IF (x_budget_type_code = 'AC')
                   THEN

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                     where  bv.project_id = x_project_id
                     and    bv.fin_plan_type_id = x_fin_plan_type_id
                     and    bv.version_type  = nvl(x_version_type, bv.version_type)
                     and    bv.approved_cost_plan_type_flag = 'Y'
                     and    bV.current_flag = 'Y'
                    );

                  ELSE
                    -- Must be 'AR'

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                     where  bv.project_id = x_project_id
                     and    bv.fin_plan_type_id = x_fin_plan_type_id
                     and    bv.version_type  = nvl(x_version_type, bv.version_type)
                     and    bv.approved_rev_plan_type_flag = 'Y'
                     and    bV.current_flag = 'Y'
                    );

                  END IF;

                  EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    dummy := 0;

                 END;
                 RETURN dummy;


             END IF; --x_fin_plan_type_id IS NULL

        ELSE
          -- Budget Type is Something Other Than AC/AR

             IF (x_budget_type_code IS NOT NULL)
                THEN
                -- FP usage NOT allowed here. Therefore, FP parameters are ignored.

                BEGIN

                  select 1
                  into   dummy
                  from   dual
                  where  exists
              (select 1
               from   pa_budget_versions bv, pa_budget_types bt
               where  bv.project_id = x_project_id
           and    bv.budget_type_code = x_budget_type_code
                   and    bv.budget_type_code = bt.budget_type_code
                   and    nvl(bt.plan_type,'BUDGET') = 'BUDGET'
                   and    bV.current_flag = 'Y'
                  );

                  EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    dummy := 0;

               END;
               RETURN dummy;

             ELSE
             -- x_budget_type_code IS NULL. Assume Get FP Model DAta


                 BEGIN

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                     where  bv.project_id = x_project_id
                     and    bv.fin_plan_type_id = x_fin_plan_type_id
                     and    bv.version_type = nvl(x_version_type, bv.version_type)
                     and    bV.current_flag = 'Y'
                    );


                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     dummy := 0;

                 END;
                 RETURN dummy;

           END IF; --x_budget_type_code IS NOT NULL, but NOT AC/AR

        END IF; --x_budget_type_code IN ('AC','AR') )


    END IF; -- x_budget_status_code = 'B'



    RETURN dummy;


  exception
     when others then
      return SQLCODE;

  end check_proj_budget_exists;

------------------------------------------------------------------------------
--
--Name:                 check_task_budget_exists
--Type:                 Function
--
--Description:  This function is called primarily from Billing and Projects Maintenance packages
--
--              This function has been rewritten to fully support both the r11.5.7 and FP models.
--
--              New Rules for r11.5.7 and FP Models:
--
--              For x_budget_status_code = A(ny),
--              1.  If both the x_budget_type_code and the p_plan_type_id parameters are passed as NULL,
--                  then the logic must first query the r11.5.7 model and then the FP model for data.
--                  As soon as any data is detected, the logic returns control to the calling object.
--
--              2.  If one of the aforementioned IN-parameters is passed as NON-null and the other as NULL,
--                  then the logic should only query for NON-null parameter.
--
--              3.  If both the x_budget_type_code and the p_plan_type_id parameters are passed,
--                  then the logic must first query the r11.5.7 model and then the FP model for data.
--                  As soon as any data is detected, the logic returns control to the calling object.
--
--              4.  If both the p_plan_type_id and the p_version_type IN-parameters are passed with
--                  NON-null values, then the FP logic must check for the plan_type and version_type.
--
--              For x_budget_status_code = B(aseline)
--              1.  As per design doc, if 'AC' or 'AR' budget types passed as x_budget_type_code
--                  AND X_FIN_PLAN_TYPE_ID IS NULL,
--                    THEN
--                       Use the approved_cost/rev_plan_type_flags to determine if ANY AC/AR baselined budgets
--                       have been created for r11.5.7 and FP.
--
--
--
--
--
--
--
--Called subprograms: none
--
--
--
--History:
--      xx-xxx-xx       who?    - Created
--
--      20-AUG-02   jwhite  - Extensively rewrote this procedure to fully support both
--                                the r11.5.7 and FP models.
--
  function check_task_budget_exists (x_task_id            in number,
                     x_budget_status_code IN varchar2,
                     x_budget_type_code   IN varchar2 default NULL,
                                     x_fin_plan_type_id       IN NUMBER   default NULL,
                                     x_version_type           IN VARCHAR2 default NULL
                                     )
  return number
  is
     dummy number := 0;
  begin

    -- Check for Valid Budget_Status_Code ---------------------------

     IF (nvl(x_budget_status_code,'X') NOT IN ('A', 'B') )
        THEN
          dummy := 0;
          RETURN dummy;
     END IF;


     -- Find Any Budget/Plan Type  ---------------------------

     IF (x_budget_status_code = 'A')
       THEN


       IF (x_budget_type_code is NULL AND x_fin_plan_type_id is NULL)
          THEN

          -- r11.5.7 Model? --------------
          BEGIN

            select 1
            into   dummy
            from   dual
            where  exists
           (select 1
            from   pa_budget_versions bv
                       , pa_budget_types bt
                       , pa_resource_assignments a
            where  a.task_id = x_task_id
        and    bv.budget_version_id = a.budget_version_id
                and    bv.budget_type_code is NOT NULL  -- This must be specified for r11.5.7 Budgets Model
                and    bv.budget_type_code = bt.budget_type_code
                and    nvl(bt.plan_type,'BUDGET') = 'BUDGET'
               );

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  dummy := 0;

          END;

          IF (dummy = 1)
            THEN
               RETURN dummy;
          END IF;

          -- FP Model? --------------
          BEGIN
       /* Changes for FP.M, Tracking Bug No - 3354518
           Adding conditon in the where clause below to
           check for new column use_for_workplan flag.
           Introducing this check will ensure that the budget
       version is used for FINPLAN and not WorkPlan.
       So adding a join to pa_fin_plan_types_b and
       checking status of use_for_workplan_flag */

            select 1
            into   dummy
            from   dual
            where  exists
           (select 1
            from   pa_budget_versions bv
                       , pa_resource_assignments a
            where  a.task_id = x_task_id
        and    bv.budget_version_id = a.budget_version_id
                and    bv.fin_plan_type_id is NOT NULL  -- Specified for FP Model
                and    nvl(bv.wp_version_flag,'N') = 'N'  -- (Added for Patchset M,Tracking Bug No - 3354518)
                );

           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  dummy := 0;

          END;
          RETURN dummy;


      ELSIF (x_budget_type_code is NOT NULL
                   AND x_fin_plan_type_id IS NULL)
         THEN

          -- r11.5.7 Model?
          BEGIN

            select 1
            into   dummy
            from   dual
            where  exists
           (select 1
            from   pa_budget_versions bv
                       , pa_budget_types bt
                       , pa_resource_assignments a
            where  a.task_id = x_task_id
        and    bv.budget_version_id = a.budget_version_id
        and    bv.budget_type_code = x_budget_type_code
                and    bv.budget_type_code = bt.budget_type_code
                and    nvl(bt.plan_type,'BUDGET') = 'BUDGET'
                );

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  dummy := 0;

          END;
          RETURN dummy;

      ELSIF (x_fin_plan_type_id is NOT NULL
                 AND x_budget_type_code is NULL)
         THEN

                 -- FP Model?
                 BEGIN

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                            , pa_resource_assignments a
                 where  a.task_id = x_task_id
             and    bv.budget_version_id = a.budget_version_id
                     and    bv.fin_plan_type_id = x_fin_plan_type_id
                     and    bv.version_type = nvl(x_version_type, bv.version_type)
                    );

                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     dummy := 0;

                 END;
                 RETURN dummy;

          ELSIF (x_budget_type_code is NOT NULL
                   AND x_fin_plan_type_id IS NOT NULL)
           THEN

          -- r11.5.7 Model?
          BEGIN

            select 1
            into   dummy
            from   dual
            where  exists
           (select 1
            from   pa_budget_versions bv
                       , pa_budget_types bt
                       , pa_resource_assignments a
            where  a.task_id = x_task_id
        and    bv.budget_version_id = a.budget_version_id
        and    bv.budget_type_code = x_budget_type_code
                and    bv.budget_type_code = bt.budget_type_code
                and    nvl(bt.plan_type,'BUDGET') = 'BUDGET'
                );

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  dummy := 0;

          END;

          IF (dummy = 1)
            THEN
               RETURN dummy;
          END IF;

          -- FP Model?
          BEGIN

            select 1
            into   dummy
            from   dual
            where  exists
        (select 1
         from   pa_budget_versions bv
                    , pa_resource_assignments a
         where  a.task_id = x_task_id
         and    bv.budget_version_id = a.budget_version_id
             and    bv.fin_plan_type_id = x_fin_plan_type_id
             and    bv.version_type = nvl(x_version_type, bv.version_type)
            );

            EXCEPTION
             WHEN NO_DATA_FOUND THEN
               dummy := 0;

          END;
          RETURN dummy;


      END IF; -- IF (x_budget_type_code is NULL AND x_fin_plan_type_id is NULL)

    END IF; -- if (x_budget_status_code = 'A')

   -- Find BASELINED Budget/PLan Type  ---------------------------


   IF (x_budget_status_code = 'B')
       THEN

       -- Find a BASELINED r11.5.7 Budget or FP Plan Type  -----------

       -- As per design doc, if 'AC' or 'AR' budget types passed as x_budget_type_code
       -- and  x_fin_plan_type_id IS NULL,
       --   then
       --     use the approved_cost/rev_plan_type_flags to determine if ANY AC/AR baselined budgets
       --     have ever been created for either r11.5.7 and/or FP.


       IF (  NVL(x_budget_type_code,'X') IN ('AC','AR')  )
         THEN

            IF (x_fin_plan_type_id IS NULL)
              THEN

                 -- ANY BASELINED AC/AR r11.5.7 Budgets and/or FP Plan Types Exist?
                 BEGIN

                  IF (x_budget_type_code = 'AC')
                    THEN

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                    , pa_tasks t
                    , pa_resource_assignments a
                 where  a.budget_version_id = bv.budget_version_id
                     and    a.task_id = t.task_id
             and    t.top_task_id = x_task_id
                     and    bv.approved_cost_plan_type_flag = 'Y'
                     and    bv.current_flag = 'Y'
                    );

                   ELSE
                   -- Must be 'AR'

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                (select 1
                 from   pa_budget_versions bv
                    , pa_tasks t
                    , pa_resource_assignments a
                 where  a.budget_version_id = bv.budget_version_id
                     and    a.task_id = t.task_id
             and    t.top_task_id = x_task_id
                     and    bv.approved_rev_plan_type_flag = 'Y'
                     and    bv.current_flag = 'Y'
                    );


                   END IF; --x_budget_type_code = 'AC'

                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     dummy := 0;

                 END;
                 RETURN dummy;

               ELSE
                 -- Any Baselined Approved Cost/Approved Revenue FP PLAN TYPES Exist?

                 BEGIN

                  IF (x_budget_type_code = 'AC')
                   THEN
          /* Changes for FP.M, Tracking Bug No - 3354518.
             Changing  reference of pa_tasks to pa_struct_task_wbs_v below */

          /* Bug 4176059: Performance Fix: FP.M -B12: re-used pa_tasks in
           * the following select to avoid full index scan on PA_PROJ_ELEM_VER_SCHEDULE_N1
           */
                    select 1
                    into   dummy
                    from   dual
                    where  exists
                          (select 1
                           from   pa_budget_versions bv
                                 ,pa_tasks t      --Bug 4176059: Performance Fix: FP.M -B12: re-used pa_tasks
                           --     , pa_struct_task_wbs_v t -- Adding for FP.M, Tracking Bug No - 3354518.
                                 ,pa_resource_assignments a
                           where  a.budget_version_id = bv.budget_version_id
                           and    a.task_id = t.task_id
                           and    t.top_task_id = x_task_id
                           and    bv.fin_plan_type_id = x_fin_plan_type_id
                           and    bv.version_type  = nvl(x_version_type, bv.version_type)
                           and    bv.approved_cost_plan_type_flag = 'Y'
                           and    bV.current_flag = 'Y'
                    );


                  ELSE
                    -- Must be 'AR'
          /* Changes for FP.M, Tracking Bug No - 3354518.
             Changing  reference of pa_tasks to pa_struct_task_wbs_v below */

          /* Bug 4176059: Performance Fix: FP.M -B12: re-used pa_tasks in
           * the following select to avoid full index scan on PA_PROJ_ELEM_VER_SCHEDULE_N1
           */
                    select 1
                    into   dummy
                    from   dual
                    where  exists
                           (select 1
                            from   pa_budget_versions bv
                                  ,pa_tasks t   -- Bug 4176059: Performance Fix: FP.M -B12: re-used pa_tasks
                            --, pa_struct_task_wbs_v t -- Adding for FP.M, Tracking Bug No - 3354518.
                                  ,pa_resource_assignments a
                            where  a.budget_version_id = bv.budget_version_id
                            and    a.task_id = t.task_id
                            and    t.top_task_id = x_task_id
                            and    bv.fin_plan_type_id = x_fin_plan_type_id
                            and    bv.version_type  = nvl(x_version_type, bv.version_type)
                            and    bv.approved_rev_plan_type_flag = 'Y'
                            and    bV.current_flag = 'Y'
                    );

                  END IF;

                  EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    dummy := 0;

                 END;
                 RETURN dummy;


             END IF; --x_fin_plan_type_id IS NULL

          ELSE
          -- Budget Type is Something Other Than AC/AR

             IF (x_budget_type_code IS NOT NULL)
                THEN
                -- FP usage NOT allowed here. Therefore, FP parameters are ignored.

                BEGIN

                  select 1
                  into   dummy
                  from   dual
                  where  exists
              (select 1
               from   pa_budget_versions bv
                          , pa_budget_types bt
                  , pa_tasks t
                  , pa_resource_assignments a
               where  a.budget_version_id = bv.budget_version_id
                   and    a.task_id = t.task_id
           and    t.top_task_id = x_task_id
           and    bv.budget_type_code = x_budget_type_code
                   and    bv.budget_type_code = bt.budget_type_code
                   and    nvl(bt.plan_type,'BUDGET') = 'BUDGET'
                   and    bv.current_flag = 'Y'
                  );

                  EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    dummy := 0;

               END;
               RETURN dummy;


             ELSE
             -- x_budget_type_code IS NULL. Assume Get FP Model DAta

                 BEGIN
          /* Changes for FP.M, Tracking Bug No - 3354518.
             Changing  reference of pa_tasks to pa_struct_task_wbs_v below*/

          /* Bug 4176059: Performance Fix: FP.M -B12: re-used pa_tasks in
           * the following select to avoid full index scan on PA_PROJ_ELEM_VER_SCHEDULE_N1
           */

                    select 1
                    into   dummy
                    from   dual
                    where  exists
                          (select 1
                           from   pa_budget_versions bv
                                 ,pa_tasks t     -- Bug 4176059: Performance Fix: FP.M -B12: re-used pa_tasks
                                 --, pa_struct_task_wbs_v t -- Adding for FP.M, Tracking Bug No - 3354518.
                                 ,pa_resource_assignments a
                           where  a.budget_version_id = bv.budget_version_id
                           and    a.task_id = t.task_id
                           and    t.top_task_id = x_task_id
                           and    bv.fin_plan_type_id = x_fin_plan_type_id
                           and    bv.version_type = nvl(x_version_type, bv.version_type)
                           and    bv.current_flag = 'Y'
                    );


                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     dummy := 0;

                 END;
                 RETURN dummy;

           END IF; --x_budget_type_code IS NOT NULL, but NOT AC/AR

        END IF; --x_budget_type_code IN ('AC','AR') )


    END IF; -- x_budget_status_code = 'B'



    RETURN dummy;


  exception
     when others then
      return SQLCODE;





  end check_task_budget_exists;

---------------------------------------------------------------------------
/* Changes for FP.M, Tracking Bug No - 3354518
   This API shall only be called for the old resource model so we have to
   introduce check in the API such that for the in parameter
   resource_list_member_id passed, the migration code should be null.
   Other permissible values of migration code is 'N' for New resource model,
   and 'M' for migrated.
   We include check such that if the migrated_code is not null for the
   resource_list_member_id then we raise an Invalid argument exception
   (Invalid_Arg_Exc  EXCEPTION;).
   The exception is handled in the exception block below.

   Bug 3586773 Raja May 04 2004
           Migrated resource lists can continue to be used via FORMS. So,
           modified the validation such that raise error if migration code
           is 'N'

 */

  function check_resource_member_level (x_resource_list_member_id in number,
                        x_parent_member_id in number,
                    x_budget_version_id in number,
                    x_task_id in number)
  return number
  is
     dummy number;
     l_migration_code     VARCHAR2(1) := NULL;
  begin

/* Changes for FPM, Tracking Bug No - 3354518  :  Begins */

    Select migration_code
      into l_migration_code
      from pa_resource_list_members
     where resource_list_member_id = x_resource_list_member_id;

     if nvl(l_migration_code,'-99') = 'N' then
     -- Bug 3586773 if l_migration_code  is not null then
         RAISE Invalid_Arg_Exc;
     end if;
/* Changes for FPM, Tracking Bug No - 3354518  :  Ends */


     if (x_parent_member_id = 0) then

        select 1
        into   dummy
        from   sys.dual
        where  exists
           (select 1
            from   pa_resource_list_members m,
               pa_resource_assignments a
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
            from   pa_resource_assignments a
            where  a.budget_version_id = x_budget_version_id
        and    a.task_id = x_task_id
                and    a.resource_list_member_id = x_parent_member_id);

     end if;

     return 1;

  exception
     when NO_DATA_FOUND then
      return 0;
     /* Changes for FPM, Tracking Bug No - 3354518 : Adding
        Exception Handling Block for Invalid_Arg_Exc below */
     when Invalid_Arg_Exc then
          RAISE;
     when others then
      return SQLCODE;

  end check_resource_member_level;

---------------------------------------------------------------------------

  procedure get_proj_budget_amount(
                              x_project_id      in      number,
                              x_budget_type     in      varchar2,
                              x_which_version   in      varchar2,
                              x_revenue_amount  out     NOCOPY real, --File.Sql.39 bug 4440895
                              x_raw_cost        out     NOCOPY real, --File.Sql.39 bug 4440895
                              x_burdened_cost   out     NOCOPY real, --File.Sql.39 bug 4440895
                              x_labor_quantity  out     NOCOPY real) IS --File.Sql.39 bug 4440895

  budget_status     varchar2(30) := NULL;
  current_flag      varchar2(30) := NULL;
  original_flag     varchar2(30) := NULL;
  raw_cost      REAL := 0;
  burdened_cost     REAL := 0;
  labor_qty         REAL := 0;
  revenue_amount    REAL := 0;

  BEGIN

    if x_which_version = 'DRAFT' then

    budget_status := 'O';   -- Non-baselined.

    elsif x_which_version = 'CURRENT' then

    budget_status := 'B';
    current_flag := 'Y';

    else    -- 'ORIGINAL'

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
    FROM   pa_budget_versions b
    WHERE  b.project_id = x_project_id
    AND    b.budget_type_code = x_budget_type
    AND    b.budget_status_code = decode(budget_status, 'B', 'B',
                    b.budget_status_code)
    AND   NOT (budget_status = 'O' and b.budget_status_code = 'B')
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
                              x_task_id         in      number,
                              x_budget_type     in      varchar2,
                              x_which_version   in      varchar2,
                              x_revenue_amount  out     NOCOPY real, --File.Sql.39 bug 4440895
                              x_raw_cost        out     NOCOPY real, --File.Sql.39 bug 4440895
                              x_burdened_cost   out     NOCOPY real, --File.Sql.39 bug 4440895
                              x_labor_quantity  out     NOCOPY real) IS --File.Sql.39 bug 4440895

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
    FROM   pa_budget_lines l,
       pa_resource_assignments a,
       pa_tasks t,
       pa_budget_versions v
    WHERE  v.project_id = x_project_id
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

---------------------------------------------------------------------------

  procedure delete_draft (x_budget_version_id   in     number,
                  x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                  x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                  x_err_stack           in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     old_stack varchar2(630);
     x_project_id number;
     x_resource_list_assgmt_id number;
     x_baselined_version_id number;
     x_budget_type_code varchar2(30);
  begin


     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->delete_draft';

     x_err_stage := 'get budget type <' || to_char(x_budget_version_id)
            || '>';
--- This select is unnecessary, therefore commented
/********
     select v.project_id,
        v.budget_type_code,
        la.resource_list_assignment_id
     into   x_project_id,
        x_budget_type_code,
        x_resource_list_assgmt_id
     from   pa_resource_list_assignments la,
        pa_budget_versions v
     where  v.budget_version_id = x_budget_version_id
     and    v.project_id = la.project_id
     and    v.resource_list_id = la.resource_list_id;
********/
/* Never delete resource list assignment if it is baselined
     -- if there is a baselined version, then do not delete resource assignment

     pa_budget_utils.get_baselined_version_id(x_project_id,
                          x_budget_type_code,
                          x_baselined_version_id,
                          x_err_code,
                          x_err_stage,
                          x_err_stack);

     if (x_err_code < 0) then
        return;
     end if;

     if (x_err_code > 0) then
    -- can not find a baselined version, delete the resource assignment
    x_err_code := 0;  -- reset value

        x_err_stage := 'delete resource assignment <'
               || to_char(x_resource_list_assgmt_id) || '><'
               || x_budget_type_code || '>';

        -- delete resource list assignment
        pa_res_list_assignments.delete_rl_uses(x_resource_list_assgmt_id,
               x_budget_type_code,
               x_err_code,
               x_err_stage,
               x_err_stack);

        if (x_err_code <> 0) then
        return;
        end if;

     end if;
*/


     -- Delete all budget lines of this budget version
     x_err_stage := 'delete budget lines <' || to_char(x_budget_version_id)
            || '>';

     for bl_rec in (select rowid
            from   pa_budget_lines
                where  resource_assignment_id in
                   (select resource_assignment_id
                    from   pa_resource_assignments
                    where  budget_version_id = x_budget_version_id))
     loop
         pa_budget_lines_v_pkg.delete_row(x_rowid    => bl_rec.rowid);
                                          -- Bug Fix: 4569365. Removed MRC code.
                                          -- x_mrc_flag => 'Y');  /* FPB2: Added x_mrc_flag for MRC changes */

     end loop;


     -- Delete version
     x_err_stage := 'delete budget version <' || to_char(x_budget_version_id)
            || '>';

     delete pa_budget_versions
     where  budget_version_id = x_budget_version_id;

     fnd_attached_documents2_pkg.delete_attachments('PA_BUDGET_VERSIONS',
                                                     x_budget_version_id,
                                                     null, null, null, null,
                                                     'Y') ;
     x_err_stack := old_stack;
  exception
      when others then
     x_err_code := SQLCODE;
     return;

  end delete_draft;

------------------------------------------------------------------------------
--Name:                 Create_Draft
--Type:                 Procedure
--
--Description:
--
--Notes:
--                      For the FP dev effort, the decision was made to provide
--                      very limited FP support. Just enough to keep new FP
--                      queries from breaking.
--
--                      This procedure does NOT create FP plan drafts!
--
--                      You must use a PA_FIN_PLAN_PUB api to create_draft plans.
--
--
--
--
--Called subprograms:   pa_budget_utils.get_baselined_version_id
--
--
--
--History:
--      XX-XXX-XX   who?    - Created
--
--      12-AUG-02   jwhite  - Minor modifications for the new FP model:
--                                1) Added new FP columns, approved_cost/rev_plan_type_flags.
--





  procedure create_draft (x_project_id            in      number,
              x_budget_type_code          in      varchar2,
                          x_version_name              in      varchar2,
                          x_description               in      varchar2,
                          x_resource_list_id          in      number,
                          x_change_reason_code        in      varchar2,
                          x_budget_entry_method_code  in      varchar2,
                          x_attribute_category        in      varchar2,
                          x_attribute1                in      varchar2,
                          x_attribute2                in      varchar2,
                          x_attribute3                in      varchar2,
                          x_attribute4                in      varchar2,
                          x_attribute5                in      varchar2,
                          x_attribute6                in      varchar2,
                          x_attribute7                in      varchar2,
                          x_attribute8                in      varchar2,
                          x_attribute9                in      varchar2,
                          x_attribute10               in      varchar2,
                          x_attribute11               in      varchar2,
                          x_attribute12               in      varchar2,
                          x_attribute13               in      varchar2,
                          x_attribute14               in      varchar2,
                          x_attribute15               in      varchar2,
              x_budget_version_id         in out  NOCOPY number, --File.Sql.39 bug 4440895
                  x_err_code                  in out  NOCOPY number, --File.Sql.39 bug 4440895
                  x_err_stage                 in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                  x_err_stack                 in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
              x_pm_product_code           in      varchar2 default null,
              x_pm_budget_reference       in      varchar2 default null )
  is
  --
  old_draft_version_id  number;
  old_stack  varchar2(630);
  x_created_by number;
  x_last_update_login number;
  x_resource_assignment_id number;
  x_baselined_version_id number;
  x_baselined_resource_list_id number;
  x_resource_list_assgmt_id number;
  x_baselined_exists boolean;

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->create_draft';

     IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_err_stack('PA_BUDGET_UTILS.CREATE_DRAFT');
        pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
     END IF;

     x_created_by := to_number(fnd_profile.value('USER_ID'));
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     -- Get the baselined version
     x_err_stage := 'get baselined budget id <' || to_char(x_project_id)
            || '><' || x_budget_type_code || '>';

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:= 'Calling get baselined version id';
    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;

     pa_budget_utils.get_baselined_version_id(
                                  x_project_id        => x_project_id,
                  x_budget_type_code  => x_budget_type_code,
                  x_budget_version_id => x_baselined_version_id,
                      x_err_code          => x_err_code,
                      x_err_stage         => x_err_stage,
                      x_err_stack         => x_err_stack
                                  );

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:= 'After get baselined version id';
    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        pa_debug.g_err_stage:= 'error code - '||x_err_code;
    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        pa_debug.g_err_stage:= 'error stage - '||x_err_stage;
    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;
     if (x_err_code > 0) then

    -- baseline version does not exist
        x_baselined_exists := FALSE;
    x_err_code := 0;

     elsif (x_err_code = 0) then
        -- baseliend budget exists, verify if resource lists are the same
        -- resource list used in accumulation

    select resource_list_id
    into   x_baselined_resource_list_id
        from   pa_budget_versions
        where  budget_version_id = x_baselined_version_id;

        if (x_resource_list_id <> x_baselined_resource_list_id) then
        x_err_code := 10;
        x_err_stage := 'PA_BU_BASE_RES_LIST_EXISTS';
           -- PA_UTILS added for bug 2796670.
            PA_UTILS.Add_Message
              ( p_app_short_name => 'PA'
                , p_msg_name     => x_err_stage );
        return;
        end if;

        x_baselined_exists := TRUE;

     else
        -- x_err_code < 0
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:= 'Returning';
       pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;
    return;
     end if;

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:= 'Calling get_draft_version_id';
    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;

     pa_budget_utils.get_draft_version_id(
                                  x_project_id        => x_project_id,
                  x_budget_type_code  => x_budget_type_code,
                  x_budget_version_id => old_draft_version_id,
                      x_err_code          => x_err_code,
                      x_err_stage         => x_err_stage,
                      x_err_stack         => x_err_stack
                                  );
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:= 'After call to get_draft_version_id';
    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        pa_debug.g_err_stage:= 'error code - '||x_err_code;
    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        pa_debug.g_err_stage:= 'error stage - '||x_err_stage;
    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;

     -- if draft exist, delete it
     if (x_err_code = 0) then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:= 'Calling delete_draft';
           pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;
    pa_budget_utils.delete_draft(old_draft_version_id,
                    x_err_code,
                    x_err_stage,
                    x_err_stack);
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:= 'After call to delete_draft';
           pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           pa_debug.g_err_stage:= 'error code - '||x_err_code;
           pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           pa_debug.g_err_stage:= 'error stage - '||x_err_stage;
           pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;
     elsif (x_err_code > 0) then
    -- reset x_err_code
    x_err_code := 0;

     else
     -- if oracle error, return
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:= 'Returning - 1';
           pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;
    return;
     end if;

/* Only create resource list assignment at baseline
     if (x_baselined_exists = FALSE) then
        -- create resource list assignment
        pa_res_list_assignments.create_rl_assgmt(x_project_id,
                 x_resource_list_id,
                 x_resource_list_assgmt_id,
                 x_err_code,
                 x_err_stage,
                 x_err_stack);

        -- if oracle or application error, return
        if (x_err_code <> 0) then
    return;
        end if;

        -- create resource list usage
        pa_res_list_assignments.create_rl_uses(x_project_id,
                 x_resource_list_assgmt_id,
                 x_budget_type_code,
                 x_err_code,
                 x_err_stage,
                 x_err_stack);

        -- if oracle or application error, return
        if (x_err_code <> 0) then
    return;
        end if;

     end if;
*/

     -- Included this select to return the newly create budget version id
     SELECT pa_budget_versions_s.nextval
     INTO   x_budget_version_id
     FROM   dual;
     insert into pa_budget_versions(
            budget_version_id,
            project_id,
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
        pm_product_code,
        pm_budget_reference,
        wf_status_code,
            approved_cost_plan_type_flag,
            approved_rev_plan_type_flag
     )
         select
            x_budget_version_id,
            x_project_id,
            x_budget_type_code,
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
            x_resource_list_id,
            x_version_name,
            x_budget_entry_method_code,
            NULL,
            NULL,
            x_change_reason_code,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            x_description,
            x_attribute_category,
            x_attribute1,
            x_attribute2,
            x_attribute3,
            x_attribute4,
            x_attribute5,
            x_attribute6,
            x_attribute7,
            x_attribute8,
            x_attribute9,
            x_attribute10,
            x_attribute11,
            x_attribute12,
            x_attribute13,
            x_attribute14,
            x_attribute15,
        x_pm_product_code,
        x_pm_budget_reference,
        NULL,
            decode(x_budget_type_code,'AC','Y','N'),
            decode(x_budget_type_code,'AR','Y','N')
    from sys.dual;

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:= 'End of pa_budget create_draft';
        pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;

     x_err_stack := old_stack;
     pa_debug.reset_err_stack;

  exception
      when others then
     x_err_code := SQLCODE;
       x_budget_version_id := NULL;
     return;

  end create_draft;

------------------------------------------------------------------------------

--Name:                 Create_Line
--Type:                 Procedure
--
--Description:
--
--Notes:
--                      For the FP dev effort, the decision was made to provide
--                      very limited FP support. Just enough to keep new FP
--                      queries from breaking.
--
--                      This procedure does NOT create FP plan lines!
--
--                      You must use a PA_FIN_PLAN_PUB api to create FP plan lines.
--
--
--
--
--Called subprograms:
--
--
--
--History:
--      XX-XXX-XX   who?    - Created
--
--      12-AUG-02   jwhite  - Modifications for compliance with the new FP model:
--                                1) Added call to Get_Project_Currency_Info. For the first call
--                                   for a project, this API stores the OUT-parameters in globals
--                                   to optimize subsequent calls.
--                                2) Added RESOURCE_ASSIGNMENT_TYPE column and defualt value to
--                                   pa_resource_assignments insert.
--                                3) Added new currency columns to insert SQL.
--                                4) Added exception handing and exception paragraphs for
--                                   Get_Project_Currency_Info.
--
--                                Also, rearranged parameter list as per coding standards.
--
--

  procedure create_line (x_budget_version_id   in     number,
             x_project_id          in     number,
             x_task_id             in     number,
             x_resource_list_member_id in number,
             x_description         in     varchar2,
             x_start_date          in     date,
             x_end_date        in     date,
             x_period_name         in     varchar2,
             x_quantity            in out NOCOPY number, --File.Sql.39 bug 4440895
             x_unit_of_measure     in     varchar2,
             x_track_as_labor_flag in     varchar2,
             x_raw_cost            in out NOCOPY number, --File.Sql.39 bug 4440895
             x_burdened_cost       in out NOCOPY number, --File.Sql.39 bug 4440895
             x_revenue             in out NOCOPY number, --File.Sql.39 bug 4440895
             x_change_reason_code  in     varchar2,
             x_attribute_category  in     varchar2,
             x_attribute1          in     varchar2,
             x_attribute2          in     varchar2,
             x_attribute3          in     varchar2,
             x_attribute4          in     varchar2,
             x_attribute5          in     varchar2,
             x_attribute6          in     varchar2,
             x_attribute7          in     varchar2,
             x_attribute8          in     varchar2,
             x_attribute9          in     varchar2,
             x_attribute10         in     varchar2,
             x_attribute11         in     varchar2,
             x_attribute12         in     varchar2,
             x_attribute13         in     varchar2,
             x_attribute14         in     varchar2,
             x_attribute15         in     varchar2,
             -- Bug Fix: 4569365. Removed MRC code.
             -- x_mrc_flag            in     varchar2, /* FPB2: MRC */
             x_pm_product_code     in      varchar2 default null,
             x_pm_budget_line_reference in varchar2 default null,
             x_quantity_source             varchar2 default 'M',
             x_raw_cost_source             varchar2 default 'M',
             x_burdened_cost_source        varchar2 default 'M',
             x_revenue_source              varchar2 default 'M',
             x_resource_assignment_id   in out NOCOPY number, --File.Sql.39 bug 4440895
                 x_err_code                 in out NOCOPY number, --File.Sql.39 bug 4440895
                 x_err_stage                in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                 x_err_stack                in out NOCOPY varchar2 --File.Sql.39 bug 4440895
            )
  is
    old_stack  varchar2(630);
    x_created_by  number;
    x_last_update_login  number;
    v_budget_type_code varchar2(30);

    cursor get_budget_type_code is
    select budget_type_code
    from pa_budget_versions
    where budget_version_id = x_budget_version_id;


    l_Projfunc_Currency_Code    pa_projects_all.projfunc_currency_code%TYPE := NULL;
    l_Project_Currency_Code pa_projects_all.project_currency_code%TYPE := NULL;
    l_Txn_Currency_Code         pa_projects_all.projfunc_currency_code%TYPE := NULL;

    l_Return_Status                       VARCHAR2(1)    :=NULL;
    l_Msg_Data                            VARCHAR2(2000) :=NULL;
    l_Msg_Count                           NUMBER         := 0;

    l_budget_line_id           pa_budget_lines.budget_line_id%TYPE;     /* FPB2 */



  begin


     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->create_line';

     IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_err_stack('PA_BUDGET_UTILS.CREATE_LINE');
        pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
     END IF;
     -- Bug Fix: 4569365. Removed MRC code.
     /* FPB2: MRC */
     /*
     IF x_mrc_flag IS NULL THEN
      l_msg_data := 'x_mrc_flag cannot be null to table handler';
      RAISE FND_API.G_EXC_ERROR;
     END IF;
     */

     open get_budget_type_code;
     fetch get_budget_type_code into v_budget_type_code;
     close get_budget_type_code;

     x_created_by := to_number(fnd_profile.value('USER_ID'));
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     -- Get the project_totals
     x_err_stage := 'verify if resource assignment exists <'
            || to_char(x_budget_version_id) || '><'
            || to_char(x_project_id) || '><'
            || to_char(x_task_id) || '><'
            || to_char(x_resource_list_member_id)
            || '>';

     begin

    select resource_assignment_id
    into   x_resource_assignment_id
    from   pa_resource_assignments
    where  budget_version_id = x_budget_version_id
    and    project_id = x_project_id
    and    NVL(task_id, 0) = NVL(x_task_id, 0)
    and    resource_list_member_id = x_resource_list_member_id;

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:= 'Resource assignment id - '||x_resource_assignment_id;
           pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

    exception
       when NO_DATA_FOUND then
              x_err_stage := 'create new resource assignment <'
            || to_char(x_budget_version_id) || '><'
            || to_char(x_project_id) || '><'
            || to_char(x_task_id) || '><'
            || to_char(x_resource_list_member_id)
            || '>';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage:= 'No data found';
                   pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

          select pa_resource_assignments_s.nextval
          into   x_resource_assignment_id
          from   sys.dual;

              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:= 'Resource assignment id - '||x_resource_assignment_id;
                 pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;

          -- create a new resource assignment
              insert into pa_resource_assignments
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
                  track_as_labor_flag,
              project_assignment_id, --added the cloumn for bug 2446041
                      RESOURCE_ASSIGNMENT_TYPE)
                 values ( x_resource_assignment_id,
                    x_budget_version_id,
                    x_project_id,
                    x_task_id,
                    x_resource_list_member_id,
                    SYSDATE,
                    x_created_by,
                    SYSDATE,
                    x_created_by,
                    x_last_update_login,
                    x_unit_of_measure,
                    x_track_as_labor_flag,
            -1,                       --added the cloumn for bug 2446041
                        'USER_ENTERED');

       when others then
          x_err_code := SQLCODE;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:= 'When others'||substr(SQLERRM,1,100);
                 pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;
          return;
    end ;

     -- insert into pa_budget_lines
     x_err_stage := 'create new budget line <'
            || to_char(x_resource_assignment_id) || '><'
            || to_char(x_start_date, 'DD-MON-YYYY')
            || '>';

    -- Fix for Bugs # 475852 and 503183
    -- Copy raw cost into burdened cost if budrened cost is null.
    -- If the resource UOM is currency and raw cost is null then
    -- copy value of quantity amt into raw cost and also set quantity
    -- amt to null.

     if pa_budget_utils.get_budget_amount_code(v_budget_type_code) = 'C' then
        -- Cost Budget

       if pa_budget_utils.check_currency_uom(x_unit_of_measure) = 'Y' then
         if x_raw_cost is null then
           x_raw_cost := x_quantity;
          end if;
          if x_unit_of_measure is not null then --Bug 4432032
            x_quantity := null;
          end if ;
       end if;

       if  x_burdened_cost is null then
          x_burdened_cost := x_raw_cost;
       end if;

     else -- Revenue Budget
       if pa_budget_utils.check_currency_uom(x_unit_of_measure) = 'Y' then
         if x_revenue is null then
           x_revenue := x_quantity;
          end if;
          if x_unit_of_measure is not null then --Bug 4432032
            x_quantity := null;
          end if ;
       end if;
     end if;


     -- Get Project Currency Information for INSERT
        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:= 'Calling Get_Project_Currency_Info';
             pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;
        PA_BUDGET_UTILS.Get_Project_Currency_Info
             (
              p_project_id          => x_project_id
              , x_projfunc_currency_code    => l_projfunc_currency_code
              , x_project_currency_code         => l_project_currency_code
              , x_txn_currency_code         => l_txn_currency_code
              , x_msg_count                 => l_msg_count
              , x_msg_data                      => l_msg_data
              , x_return_status                 => l_return_status
             );

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
           THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSIF (l_return_status = FND_API.G_RET_STS_ERROR)
            THEN
        RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:= 'l_return_status is - '||l_return_status;
             pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

       /* FPB2 */
       SELECT pa_budget_lines_s.nextval
         INTO l_budget_line_id
         FROM DUAL;

        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:= 'l_budget_line_id is - '||l_budget_line_id;
             pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

     insert into pa_budget_lines
           (budget_line_id,                 /* FPB2 */
                budget_version_id,              /* FPB2 */
                resource_assignment_id,
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
        quantity_source,
        raw_cost_source,
        burdened_cost_source,
        revenue_source,
                projfunc_currency_code,
                project_currency_code,
                txn_currency_code
                )
             values (
                l_budget_line_id,      /* FPB2 */
                x_budget_version_id,   /* FPB2 */
        x_resource_assignment_id,
            x_start_date,
        SYSDATE,
                x_created_by,
                SYSDATE,
                x_created_by,
                x_last_update_login,
            x_end_date,
            x_period_name,
            x_quantity,
            pa_currency.round_currency_amt(x_raw_cost),
            pa_currency.round_currency_amt(x_burdened_cost),
            pa_currency.round_currency_amt(x_revenue),
                x_change_reason_code,
            x_description,
                x_attribute_category,
                x_attribute1,
                x_attribute2,
                x_attribute3,
                x_attribute4,
                x_attribute5,
                x_attribute6,
                x_attribute7,
                x_attribute8,
                x_attribute9,
                x_attribute10,
                x_attribute11,
                x_attribute12,
                x_attribute13,
                x_attribute14,
                x_attribute15,
        x_pm_product_code,
        x_pm_budget_line_reference,
        x_quantity_source,
        x_raw_cost_source,
        x_burdened_cost_source,
        x_revenue_source,
                l_Projfunc_currency_code,
                l_Project_currency_code,
                l_txn_currency_code
                 );
         -- Bug Fix: 4569365. Removed MRC code.
        /* FPB2: MRC */
        /*
             IF x_mrc_flag = 'Y' THEN

                IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN

                        IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage:= 'Calling check_mrc_install';
                             pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                        END IF;
                       PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                                 (x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data);
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage:= 'l_return_status is -'||l_return_status;
                             pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                             pa_debug.g_err_stage:= 'l_msg_count - '||l_msg_count;
                             pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                             pa_debug.g_err_stage:= 'l_msg_data - '||l_msg_data;
                             pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                        END IF;
                END IF;

                IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                   PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:= 'Calling MAINTAIN_ONE_MC_BUDGET_LINE';
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                   END IF;
                   PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                                         (p_budget_line_id => l_budget_line_id,
                                          p_budget_version_id => x_budget_version_id,
                                          p_action         => PA_MRC_FINPLAN.G_ACTION_INSERT,
                                          x_return_status  => l_return_status,
                                          x_msg_count      => l_msg_count,
                                          x_msg_data       => l_msg_data);
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage:= 'l_return_status is -'||l_return_status;
                         pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                         pa_debug.g_err_stage:= 'l_msg_count - '||l_msg_count;
                         pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                         pa_debug.g_err_stage:= 'l_msg_data - '||l_msg_data;
                         pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                    END IF;
                END IF;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage:= 'Raising g_mrc_exception';
                         pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                    END IF;
                  RAISE g_mrc_exception;
                END IF;

             END IF;
             */

     x_err_stack := old_stack;
     pa_debug.reset_err_stack;

  exception
     WHEN FND_API.G_EXC_ERROR
      THEN
    x_err_code := SQLCODE;
    FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'CREATE_LINE'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
       IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'In exception of create_line -1 '||substr(SQLERRM,1,100);
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL4);
       END IF;
        RETURN;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN
    x_err_code := SQLCODE;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'In exception of create_line -2 '||substr(SQLERRM,1,100);
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
    FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'CREATE_LINE'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
        RETURN;
     when others then
    x_err_code := SQLCODE;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'In exception of create_line -3 '||substr(SQLERRM,1,100);
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
    return;

  end create_line;

------------------------------------------------------------------------------

  procedure summerize_project_totals (x_budget_version_id   in     number,
                          x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                          x_err_stage       in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_err_stack           in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     x_created_by number;
     x_last_update_login number;
    old_stack  varchar2(630);
  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->summerize_project_totals';

     IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_err_stack('PA_BUDGET_UTILS.SUMMERIZE_PROJECT_TOTALS');
        pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
     END IF;

    x_created_by := to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id));
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     -- Get the project_totals
     x_err_stage := 'get project totals <' || to_char(x_budget_version_id)
            || '>';

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:= 'In summerize_project_amounts';
         pa_debug.write('summerize_project_totals: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;

     update pa_budget_versions v
     set    (labor_quantity,
             labor_unit_of_measure,
             raw_cost,
             burdened_cost,
             revenue,
             last_update_date,
             last_updated_by,
             last_update_login
            )
     =
    (select sum(nvl(to_number(decode(a.track_as_labor_flag,
                              'Y', l.quantity, NULL)),0)),
--             decode(a.track_as_labor_flag, 'Y', a.unit_of_measure, NULL),
            'HOURS',       -- V4 uses HOURS as the only labor unit
            pa_currency.round_currency_amt(sum(nvl(l.raw_cost, 0))),
            pa_currency.round_currency_amt(sum(nvl(l.burdened_cost, 0))),
            pa_currency.round_currency_amt(sum(nvl(l.revenue, 0))),
            SYSDATE,
            x_created_by,
            x_last_update_login
     from   pa_resource_assignments a,
            pa_budget_lines l
     where  a.budget_version_id = x_budget_version_id /*Bug 4198840: Perf:Included this join*/
     and    a.budget_version_id = v.budget_version_id
     and    a.resource_assignment_id = l.resource_assignment_id
    )
    where  budget_version_id = x_budget_version_id;

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:= 'After update';
         pa_debug.write('summerize_project_totals: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;

     x_err_stack := old_stack;
     pa_debug.reset_err_stack;

  exception
      when others then
     x_err_code := SQLCODE;
         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:= 'In exception of summerize_project_totals';
             pa_debug.write('summerize_project_totals: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
         END IF;
     return;

  end summerize_project_totals;
-- =================================================

--Name:                 Verify_Budget_Rules
--Type:                 Procedure
--
--Description:  This procedure is called both from the Oracle Projects
--      Budgets form (PAXBUEBU.fmb) when the Submit
--      and Baseline buttons are pressed and the
--      public Baseline_Budget api.
--
--      This procedure does the following:
--      1)  It performs Oracle Project product specific
--           validations.
--      2)  It calls a client extension for additional
--           client specific validations.
--
--      The procedure also distinguishes between
--      submission edits ('SUBMIT') and
--      baseline edits ('BASELINE') as determined
--      by the value of the p_event parameter.
--
--      Most of the Oracle Project product specific code
--      was copied from the pa_budget_core.baseline
--      procedure. Now, the pa_budget_core.baseline
--      validation calls this procedure.
--
--
--Called subprograms: PA_Client_Extn_Budget.Verify_Budget_Rulesc
--
--
--
--History:
--      29-JUL-97   jwhite  - Created
--  20-AUG-97   jwhite  Added p_calling_module
--  10-SEP-97   jwhite  As per latest specs, added p_warnings_only_flag
--              and p_err_msg_count
--              to Verify_Budget_Rules, and code
--              to support multiple messaging.
--      15-JUL-99       risingh entry level code for rev budgets should be
--                              determined only if it is not P or T already
--                              bug 876456 - performance improvement of baseline procedure
--
--  07-AUG-02   jwhite  Adapted logic to suport the r11.5.7 model and new FP model.
--
--     10-DEC-2003      bvarnasi  Bug 3142016 : Selecting 0 if the amount in budget versions
--                                is null otherwise, the comparision fails in billing_core.
--
PROCEDURE Verify_Budget_Rules
 (p_draft_version_id        IN  NUMBER
  , p_mark_as_original      IN  VARCHAR2
  , p_event         IN  VARCHAR2
  , p_project_id        IN  NUMBER
  , p_budget_type_code      IN  VARCHAR2
  , p_resource_list_id      IN  NUMBER
  , p_project_type_class_code   IN  VARCHAR2
  , p_created_by        IN  NUMBER
  , p_calling_module        IN  VARCHAR2
  , p_fin_plan_type_id          IN      NUMBER DEFAULT NULL
  , p_version_type              IN      VARCHAR2 DEFAULT NULL
  , p_warnings_only_flag    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_err_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_err_code              IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_err_stage         IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_err_stack         IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

    l_entry_level_code      VARCHAR2(30);
    l_dummy         NUMBER;
    l_budget_total      NUMBER DEFAULT 0;
    l_old_stack         VARCHAR2(630);
    l_funding_level         VARCHAR2(2) DEFAULT NULL;

    l_ext_warnings_only_flag    VARCHAR2(1) := NULL;
    l_ext_err_msg_count     NUMBER  := 0;


    -- For FP Model
    l_approved_code             pa_budget_types.budget_type_code%TYPE := NULL;
    l_Return_Status                       VARCHAR2(1)  :=NULL;
    l_Msg_Data                            VARCHAR2(2000) :=NULL;
    l_Msg_Count                           NUMBER := 0;



  BEGIN



    -- Initialize OUT-parameters for Multiple Error Messaging

     p_warnings_only_flag  := 'Y';
     p_err_msg_count    := 0;


     p_err_code := 0;
     l_old_stack := p_err_stack;
     p_err_stack := p_err_stack || '->check_budget_rules';

     IF( PA_UTILS.GetEmpIdFromUser(p_created_by ) IS NULL) THEN
    p_err_code := 10;
    p_err_stage := 'PA_ALL_WARN_NO_EMPL_REC';

    PA_UTILS.Add_Message
    ( p_app_short_name  => 'PA'
      , p_msg_name      => p_err_stage
    );
    p_warnings_only_flag  := 'N';

    END IF;

    -- FP Model Processing, if Any  -----------------------

    IF (p_budget_type_code IS NULL)
       THEN
       -- A FP Plan is being processed. Get the l_approved_code for Subsequent Processing

      PA_BUDGET_UTILS.Get_Version_Approved_Code
      (
       p_budget_version_id  => p_draft_version_id
       , x_approved_code    => l_approved_code
       , x_msg_count        => l_msg_count
       , x_msg_data     => l_msg_data
       , x_return_status    => l_return_status
       );


       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
        THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR)
         THEN

        RAISE FND_API.G_EXC_ERROR;
       END IF;


    ELSE
       -- A r11.5.7 Budget is being processed.
       l_approved_code := p_budget_type_code;

    END IF;


    -- -----------------------------------------------------

  IF (p_event = 'SUBMIT')
  THEN
   -- Oracle Projects Standard Submission Validation
   -- None currently.

    NULL;

  ELSE

   -- Oracle Projects Standard Baseline Validation

     p_err_stage := 'get draft budget info <' || to_char(p_draft_version_id)
            || '>';


     -- check if there is at least one project or task draft budget exists
     p_err_stage := 'check budget exists <' || to_char(p_draft_version_id)
            || '>';

     BEGIN
    select 1
    into   l_dummy
    from   sys.dual
    where  exists
           (select 1
        from   pa_resource_assignments
        where  budget_version_id = p_draft_version_id);

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       p_err_code := 10;
       p_err_stage := 'PA_BU_NO_BUDGET';
      PA_UTILS.Add_Message
      ( p_app_short_name    => 'PA'
        , p_msg_name        => p_err_stage
       );
       p_warnings_only_flag  := 'N';


    WHEN OTHERS THEN
       p_err_code := SQLCODE;
       FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'VERIFY_BUDGET_RULES'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                          );
               p_warnings_only_flag  := 'N';
       p_err_msg_count  := FND_MSG_PUB.Count_Msg;
       RETURN;
     END;

     -- do extra check for revenue budget
     if (   (l_approved_code IN ('AR','ALL') )
         and (p_project_type_class_code = 'CONTRACT')
        )
           then

        -- check the level of budgeting.
        -- Note:  import budget does not have budget entry method

-- Fix 876456

       if( l_entry_level_code not in ('P','T')) then

        BEGIN

           p_err_stage := 'check budgeting level <'
                 || to_char(p_draft_version_id) || '>';

           select 'T'
           into   l_entry_level_code
           from   sys.dual
       where  exists
             (select 1
              from   pa_resource_assignments
              where  budget_version_id = p_draft_version_id
           -- and    task_id is not null);
           -- this has been changed since pa_resource_assignments
           -- stores 0 if a task_id does not exist rather than null
              and task_id <> 0);

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
           -- budget at project level
           l_entry_level_code    := 'P';
        WHEN OTHERS THEN
           p_err_code := SQLCODE;
           FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'VERIFY_BUDGET_RULES'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
             );
                   p_warnings_only_flag  := 'N';
           p_err_msg_count  := FND_MSG_PUB.Count_Msg;
           RETURN;
        END;

        end if;

    -- get the sum of revenue budget for this p_draft_version_id
    select nvl(revenue,0)  -- Bug 3142016
    into   l_budget_total
    from   pa_budget_versions
    where  budget_version_id = p_draft_version_id;

    -- call pa_billing_core.verify_baseline_funding to check the funding revenue
    pa_billing_core.verify_baseline_funding(
        p_project_id,
        p_draft_version_id,
        l_entry_level_code,
                l_budget_total, -- Removing this temporary fix. /* This is just a temporary fix for FPM testing to proceed. The real fix is being discussed */
                p_err_code,
                p_err_stage,
                p_err_stack);

       -- PA_UTILS.Add_Message already addressed internally by Verify_Baseline_Funding
       -- Only RETURN if Oracle error. Otherwise, continue processing.

       IF (p_err_code <> 0)
         THEN
        p_warnings_only_flag  := 'N';
       END IF;
       IF (p_err_code < 0) THEN
    p_err_msg_count := FND_MSG_PUB.Count_Msg;
            RETURN;
       END IF;

     elsif (    (l_approved_code IN ('AC','ALL') )
              and (p_project_type_class_code <> 'CONTRACT')
           )
            then

          NULL;


     END IF;  -- of AR revenue budget
  END IF; -- OP Standard Validations

  -- Client Specific Validations --------------------------------------------------

  p_err_stage := 'Check Client Extn Verify Budget Rules <' || to_char(p_project_id )
            || '><'|| p_budget_type_code
            || '>'|| to_char(p_draft_version_id)
            || '>'|| p_mark_as_original
            || '>';



PA_CLIENT_EXTN_BUDGET.Verify_Budget_Rules
 (p_draft_version_id        =>  p_draft_version_id
  , p_mark_as_original           => p_mark_as_original
  , p_event         =>  p_event
  , p_project_id                =>  p_project_id
  , p_budget_type_code          =>  p_budget_type_code
  , p_resource_list_id      =>  p_resource_list_id
  , p_project_type_class_code   =>  p_project_type_class_code
  , p_created_by                =>  p_created_by
  , p_calling_module            =>  p_calling_module
  , p_fin_plan_type_id          =>      p_fin_plan_type_id
  , p_version_type              =>      p_version_type
  , p_warnings_only_flag        =>  l_ext_warnings_only_flag
  , p_err_msg_count             =>  l_ext_err_msg_count
  , p_error_code                =>  p_err_code
  , p_error_message             =>  p_err_stage
 );



   -- PA_UTILS.Add_Message already addressed internally by client extn
   -- Verify_Budget_Rules
   -- Only RETURN if Oracle error. Otherwise, continue processing.

  IF (l_ext_err_msg_count > 0)
    THEN
    IF (l_ext_warnings_only_flag = 'N') THEN
        p_warnings_only_flag  := 'N';
    END IF;
  END IF;

  p_err_msg_count   := FND_MSG_PUB.Count_Msg;
  p_err_stack := l_old_stack;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
      THEN
    p_err_code := SQLCODE;
    FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'VERIFY_BUDGET_RULES'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
        p_warnings_only_flag  := 'N';
    p_err_msg_count := FND_MSG_PUB.Count_Msg;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN
    p_err_code := SQLCODE;
    FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'VERIFY_BUDGET_RULES'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
        p_warnings_only_flag  := 'N';
    p_err_msg_count := FND_MSG_PUB.Count_Msg;
    WHEN OTHERS THEN
    p_err_code := SQLCODE;
    FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'VERIFY_BUDGET_RULES'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
    p_warnings_only_flag  := 'N';
    p_err_msg_count := FND_MSG_PUB.Count_Msg;
        RETURN;

END Verify_Budget_Rules;



-- =================================================
-- =================================================
--Name:                 Baseline_Budget
--Type:                 Procedure
--
--Description:  This wrapper procedure is called from the Oracle Projects
--      Budgets form, the Budget Approval and Budget Integration
--              workflows and the AMG Baseline_Budget API.
--
--      This procedure does the following:
--      1) For Integration budgets,
--         a. performs funds checking and reserves funds if
--                    applicable.
--                 b. baselines the integration budget
--                 c. baselines a corresponding Commitment control
--                    budget.
--                 d. If successful for both baselines, ties back
--                    to the new baselined budget version id.
--                 e. If not unsuccessful, rolls back the reserved funds, if any.
--              2) For other budgets, baselines the budget
--
--
--
--
--Called subprograms: PA_BUDGET_CORE.Baseline
--
--
--
--History:
--  30-APR-2001  jwhite   - Created
--
--
--  25-JUL-2005  jwhite   - R12 SLA Effort
--                          Largely rewrote this procedure with regard
--                          to Budgetary Control functionality.
--
--                          Please see the previous version for obsolete budgetary contol code.
--
--  23-AUG-2005  jwhite   - R12 SLA Effort, Phase II
--                          When Budget Integration is sucessful, add Success message
--                          to message stack.
--  29-Aug-2006  nkumbi   - Federal Uptake Bug 5522880
--                          If federal profile option is enabled, BEM/Third party client extension is called to
--                          populate the interface tables after all the baseline and funds check processing is done.
--                           The baseline process is also rolled back if the BEM interface fails.
--
--
--

PROCEDURE Baseline_Budget
(p_draft_version_id          IN NUMBER
, p_project_id               IN     NUMBER
, p_mark_as_original             IN     VARCHAR2
, p_fck_req_flag                 IN     VARCHAR2  DEFAULT NULL
, p_verify_budget_rules          IN     VARCHAR2  DEFAULT 'N'
, x_msg_count                   OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
, x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

--
-- Local Variable Declaration

   l_err_code                            NUMBER := 0;
   l_err_stage                           VARCHAR2(120) :=NULL;
   l_err_stack                           VARCHAR2(630) :=NULL;
   l_old_stack                           VARCHAR2(630) :=NULL;

   l_Dual_Bdgt_Cntrl_Flag                VARCHAR2(1)  :=NULL;
   l_CC_Budget_Version_id                NUMBER := 0;
   l_gl_new_base_ver_id                  NUMBER := 0;
   l_cc_new_base_ver_id                  NUMBER := 0;
   l_gl_budget_type_code                 pa_budget_types.budget_type_code%TYPE :=NULL;
   l_cc_budget_type_code                 pa_budget_types.budget_type_code%TYPE :=NULL;

   l_Return_Status                       VARCHAR2(1)  :=NULL;
   l_Msg_Data                            VARCHAR2(2000) :=NULL;
   l_Msg_Count                           NUMBER := 0;

   l_Return_Status2                      VARCHAR2(1)  :=NULL;
   l_Msg_Data2                           VARCHAR2(2000) :=NULL;
   l_Msg_Count2                          NUMBER := 0;

   l_msg_index_out                       NUMBER := 0;
   l_data                                VARCHAR2(2000) :=NULL;

   --R12 SLA Effort
   l_baseline_version_id                 pa_budget_versions.budget_version_id%TYPE :=NULL;
   l_budget_type_code                    pa_budget_versions.budget_type_code%TYPE :=NULL;

   --Federal Uptake Bug 5522880
   l_federal_enabled                     VARCHAR2(1) := NULL;
   l_bem_failed                          EXCEPTION;
   l_pre_baseline_version_id             NUMBER := NULL;
   l_rejection_code                      VARCHAR2(250) := NULL;
   l_interface_status                    VARCHAR2(10) := NULL;
   l_baseline_version_number             NUMBER := NULL;
   l_rejection_reason                    VARCHAR2(250) := NULL;


Begin
--  Setup Environment ---------------------------------------------------

    -- Assume Success
    x_return_status         := FND_API.G_RET_STS_SUCCESS;
    x_msg_count             := 0;
    x_msg_data              := NULL;

    --  Standard begin of API savepoint

    SAVEPOINT baseline_budget_wrappper;



-- Integration Processing and Baseline ----------------------------------


  IF (nvl(p_fck_req_flag,'N') ) = 'Y'
     THEN

    -- !!! REQUIRED: Funds Check Processing  !!! -------------------

  -- BASELINE  DRAFT  C-O-M-M-I-T-M-E-N-T  Version ---------------------------------------

  -- R12 SLA Effort: COMMITMENT Budget Baseline DESUPPORTED Until Further Notice

  -- When commitment budget support is reinstated, then either a SQL or a procedure
  -- call will be required to populate the following parameters:
  --
  -- 1) l_Dual_Bdgt_Cntrl_Flag
  -- 2) l_CC_Budget_Version_id

     --Bug 6524116
     begin
       select 'Y'
       into l_dual_bdgt_cntrl_flag
       from dual
       where exists
             (select 1
              from pa_budgetary_control_options a
              where project_id = p_project_id
                and external_budget_code = 'CC'
                and bdgt_cntrl_flag = 'Y')
         and exists
             (select 1
              from pa_budgetary_control_options b
              where project_id = p_project_id
                and external_budget_code = 'GL'
                and bdgt_cntrl_flag = 'Y');
     exception
       when no_data_found then
         l_Dual_Bdgt_Cntrl_Flag := 'N';
     end;

     begin
       SELECT budget_version_id
       INTO l_CC_Budget_Version_id
       FROM pa_budget_versions bv
       WHERE project_id = p_project_id
         AND BUDGET_STATUS_CODE = 'S'
         AND budget_type_code =
                (SELECT budget_type_code
                 FROM pa_budgetary_control_options pbco
                 WHERE pbco.budget_type_code = bv.budget_type_code
                   AND pbco.project_id = bv.project_id
                   AND pbco.bdgt_cntrl_flag = 'Y'
                   AND pbco.external_budget_code = 'CC');
     exception
       when no_data_found then
         l_CC_Budget_Version_id := 0;
     end;
     --END Bug 6524116

     IF (nvl(l_Dual_Bdgt_Cntrl_Flag,'N') = 'Y'
           AND nvl(l_CC_Budget_Version_id,0) > 0 )
        THEN
        --dbms_output.put_line('-- Baseline Commitment Control draft budget: '||to_char(l_CC_Budget_Version_id) );

          PA_BUDGET_CORE.Baseline(x_draft_version_id     => l_CC_Budget_Version_id
                                  ,x_mark_as_original    => p_mark_as_original
                                  ,x_verify_budget_rules => p_verify_budget_rules
                                  ,x_err_code            => l_err_code
                                  ,x_err_stage           => l_err_stage
                                  ,x_err_stack           => l_err_stack
                                  );

          IF (l_err_code <> 0)
             THEN

             -- Process Baseline Error. Rollback ANY Error
           IF (l_err_code < 0)
            THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                    THEN
                     FND_MSG_PUB.add_exc_msg
                     (  p_pkg_name       => 'PA_BUDGET_UTILS'
                        ,  p_procedure_name => 'BASELINE_BUDGET'
                        ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0')
                     );
                END IF;
                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ELSE
            -- l_err_code > 0
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                    FND_MESSAGE.SET_NAME('PA','PA_BASELINE_FAILED');
                    FND_MSG_PUB.add;
               END IF;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF; -- (l_err_code < 0)

           IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
              THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF (l_return_status = FND_API.G_RET_STS_ERROR)
              THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

          END IF;  --(nvl(l_Dual_Bdgt_Cntrl_Flag,'N') ) = 'Y'

  --R12 SLA Effort: Desupported Until Futher Notice
     END IF;--IF (nvl(l_Dual_Bdgt_Cntrl_Flag,'N') = 'Y'

    -- BASELINE  D-R-A-F-T C-O-S-T  Version ---------------------------------------

    PA_BUDGET_CORE.Baseline(x_draft_version_id     => p_draft_version_id
                            ,x_mark_as_original    => p_mark_as_original
                            ,x_verify_budget_rules => p_verify_budget_rules
                            ,x_err_code            => l_err_code
                            ,x_err_stage           => l_err_stage
                            ,x_err_stack           => l_err_stack
                             );


    IF (l_err_code <> 0)
       THEN

         -- Process Baseline Error. Rollback ANY Error
         IF (l_err_code < 0)
            THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
               THEN
                 FND_MSG_PUB.add_exc_msg
                 (  p_pkg_name       => 'PA_BUDGET_UTILS'
                    ,  p_procedure_name => 'BASELINE_BUDGET'
                    ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0')
                 );
            END IF;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         ELSE
            -- l_err_code > 0
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                    FND_MESSAGE.SET_NAME('PA','PA_BASELINE_FAILED');
                    FND_MSG_PUB.add;
            END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;
         END IF; -- (l_err_code < 0)

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
           THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_ERROR)
           THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;


     END IF; -- l_err_code <> 0

     -- ------------------------------------------------------------------------


     -- RESERVE_BASELINE Budget Funds for NEW B-A-S-E-L-I-N-E  Version --------------

     -- Get the baselined budget version for the draft

     SELECT budget_type_code
     INTO   l_budget_type_code
     FROM   pa_budget_versions
     WHERE  budget_version_id = p_draft_version_id
     AND    budget_status_code = 'S';

     SELECT budget_version_id, version_number
     INTo   l_baseline_version_id, l_baseline_version_number
     FROM   pa_budget_versions
     WHERE  budget_type_code = l_budget_type_code
     AND    project_id = p_project_id
     AND    budget_status_code = 'B'
     AND    current_flag = 'Y';


     PA_BUDGET_FUND_PKG.Check_OR_Reserve_Funds
     (P_Project_ID                 => p_project_id
     ,P_Budget_Version_Id          => l_baseline_version_id
     ,P_calling_Mode               => 'RESERVE_BASELINE'
     ,X_Dual_Bdgt_Cntrl_Flag       => l_Dual_Bdgt_Cntrl_Flag
     ,X_CC_Budget_Version_id       => l_CC_Budget_Version_id
     ,X_Return_Status              => l_Return_Status
     ,X_Msg_Data                   => l_Msg_Data
     ,X_Msg_Count                  => l_Msg_Count
     );

     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR)
        THEN
           RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS)
        THEN
        -- R12 SLA Effort, Phase II
        -- Add Success message to message stack.
        FND_MESSAGE.SET_NAME('PA','PA_NFSUBJ_BU_INTG_SUCCESS');
        FND_MSG_PUB.add;
     END IF;

     /*Start - Changes for Federal Uptake - I */ -- Bug 5522880

     l_federal_enabled := NVL(FND_PROFILE.value('FV_ENABLED'), 'N');

     If(l_federal_enabled = 'Y' AND l_budget_type_code is NOT NULL) then

            Begin
                 SELECT budget_version_id
                 INTo   l_pre_baseline_version_id
                 FROM   pa_budget_versions pb
                 WHERE  pb.budget_type_code = l_budget_type_code
                 AND    pb.project_id = p_project_id
                 AND    pb.budget_status_code='B'
                 AND    pb.version_number = (l_baseline_version_number - 1);
            Exception
                When no_data_found then
                    l_pre_baseline_version_id := NULL;
            End;

     PA_CLIENT_EXT_FV_BUDGET_INT.INSERT_BUDGET_LINES
     (p_project_id                    => p_project_id
     ,p_pre_baselined_version_id      => l_pre_baseline_version_id
     ,p_baselined_budget_version_id   => l_baseline_version_id
     ,x_rejection_code                => l_rejection_code
     ,x_interface_status              => l_interface_status);

     If ((l_interface_status = 'True' or l_interface_status is NULL)  and l_rejection_code is NULL) THEN
        NULL; --BEM/Third Party Client Extension Successful
     Else
        RAISE l_bem_failed;
     End if;

     End if;
     /*End - Changes for Federal Uptake - I */
     -- ----------------------------------------------------------------------


  ELSE
     -- --------------------------------------------------------------------
     --                    !!!   NO funds check  !!!
     --
     -- Perform Vanilla Baseline.
     -- --------------------------------------------------------------------
      --dbms_output.put_line('NO Funds Check. Call PA_BUDGET_CORE.BASELINE');


    PA_BUDGET_CORE.Baseline (x_draft_version_id     => p_draft_version_id
                               ,x_mark_as_original    => p_mark_as_original
                               ,x_verify_budget_rules => p_verify_budget_rules
                               ,x_err_code            => l_err_code
                               ,x_err_stage           => l_err_stage
                               ,x_err_stack           => l_err_stack
                               );


    IF (l_err_code <> 0)
       THEN
       -- Process Baseline Error. Rollback ANY Error

        IF (l_err_code < 0)
            THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                 FND_MSG_PUB.add_exc_msg
                 (  p_pkg_name       => 'PA_BUDGET_UTILS'
                    ,  p_procedure_name => 'BASELINE_BUDGET'
                    ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0')
                 );
            END IF;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         ELSE
            -- l_err_code > 0
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                    FND_MESSAGE.SET_NAME('PA','PA_BASELINE_FAILED');
                    FND_MSG_PUB.add;
            END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;
         END IF; -- (l_err_code < 0)

         IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
             THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR)
             THEN
               RAISE FND_API.G_EXC_ERROR;
         END IF;

    END IF; --(l_err_code <> 0)

    /*Start - Changes for Federal Uptake - II */

     l_federal_enabled := NVL(FND_PROFILE.value('FV_ENABLED'), 'N');

            Select budget_type_code
            into   l_budget_type_code
            from pa_budget_versions
            where budget_version_id = p_draft_version_id;


     If(l_federal_enabled = 'Y' AND l_budget_type_code is NOT NULL) then

          SELECT budget_version_id, version_number
          INTo   l_baseline_version_id, l_baseline_version_number
          FROM   pa_budget_versions
          WHERE  budget_type_code = l_budget_type_code
          AND    project_id = p_project_id
          AND    budget_status_code='B'
          AND    current_flag = 'Y';

            Begin
                 SELECT budget_version_id
                 INTo   l_pre_baseline_version_id
                 FROM   pa_budget_versions pb
                 WHERE  pb.budget_type_code = l_budget_type_code
                 AND    pb.project_id = p_project_id
                 AND    pb.budget_status_code = 'B'
                 AND    pb.version_number = (l_baseline_version_number - 1);
            Exception
                When no_data_found then
                    l_pre_baseline_version_id := NULL;
            End;


          PA_CLIENT_EXT_FV_BUDGET_INT.INSERT_BUDGET_LINES
          (p_project_id                    => p_project_id
          ,p_pre_baselined_version_id      => l_pre_baseline_version_id
          ,p_baselined_budget_version_id   => l_baseline_version_id
          ,x_rejection_code                => l_rejection_code
          ,x_interface_status              => l_interface_status) ;

          If ((l_interface_status = 'True' or l_interface_status is NULL) and l_rejection_code is NULL) THEN
             NULL; --BEM/Third Party Client Extension Successful
          Else
             RAISE l_bem_failed;
          End if;

     End if;

     /*End - Changes for Federal Uptake - II */

  END IF; --(nvl(p_fck_req_flag,'N')) = 'Y'



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
      THEN
        ROLLBACK TO baseline_budget_wrappper;
        x_return_status := FND_API.G_RET_STS_ERROR;
         --fix done for Bug 6408021
         FND_MSG_PUB.Count_And_Get
         (p_count       =>  x_msg_count ,
          p_data        =>  x_msg_data  );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN
          ROLLBACK TO baseline_budget_wrappper;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            --fix done for Bug 6408021
         FND_MSG_PUB.Count_And_Get
         (p_count       =>  x_msg_count ,
          p_data        =>  x_msg_data  );

    WHEN L_BEM_FAILED
      THEN
          ROLLBACK TO baseline_budget_wrappper;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'PA_FV_BUDGET_INT_FAILED';
          Begin
              Select meaning
              into l_rejection_reason
              from pa_lookups
              where lookup_code = l_rejection_code
              and lookup_type = 'PA_BUD_INTERFACE_REJ_CODE';
             Exception
               When no_data_found then
                 l_rejection_reason := Null;
           End;
          PA_UTILS.Add_Message('PA',x_msg_data, 'Rejection Reason', l_rejection_reason);

    WHEN OTHERS
      THEN
          ROLLBACK TO baseline_budget_wrappper;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'BASELINE_BUDGET'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
          FND_MSG_PUB.Count_And_Get
          (p_count       =>  x_msg_count
           , p_data      =>  x_msg_data  );




END Baseline_Budget;
-- =================================================

---------------------------------------------------------------------------
--

--History:
--  xx-xxx-xx   who?    - Created
--
--  13-AUG-02   jwhite  - Modified for FP model:
--                                Added filter to pa_resource_assignments,
--                                RESOURCE_ASSIGNMENT_TYPE = USER_ENTERED
--
--  10-Feb-05   dbora     Bug 4176059: Performance Fix: FP.M-B12
--                        Split cursor get_totals in to four separate
--                        cursors for each separate planning levels

  procedure get_project_task_totals(x_budget_version_id   in     number,
                                    x_task_id             in     number,
                                    x_quantity_total      in out NOCOPY number, --File.Sql.39 bug 4440895
                                    x_raw_cost_total      in out NOCOPY number, --File.Sql.39 bug 4440895
                                    x_burdened_cost_total in out NOCOPY number, --File.Sql.39 bug 4440895
                                    x_revenue_total       in out NOCOPY number, --File.Sql.39 bug 4440895
                                    x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                                    x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    x_err_stack           in out NOCOPY varchar2)  --File.Sql.39 bug 4440895
is

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

   --Bug 4176059: Performance Fix: FP.M-B12
   cursor get_project_totals is
   select labor_quantity,
          raw_cost,
          burdened_cost,
          revenue
   from   pa_budget_versions
   where  v_rollup_flag = 'P'                    -- Project Level
   and    budget_version_id = x_budget_version_id;

   --Bug 4176059: Performance Fix: FP.M-B12
   cursor get_top_task_totals is
   select SUM(DECODE(a.TRACK_AS_LABOR_FLAG,'Y',NVL(l.QUANTITY,0),0)),
          SUM(NVL(l.RAW_COST,0)),
          SUM(NVL(l.BURDENED_COST,0)),
          SUM(NVL(l.REVENUE,0))
   from pa_tasks t,
        pa_budget_lines l ,
        pa_resource_assignments a
   where v_rollup_flag = 'T'                      -- Top Task Level
   and   a.budget_version_id = x_budget_version_id
   and   a.task_id = t.task_id
   and   t.top_task_id  = x_task_id
   and   a.resource_assignment_id = l.resource_assignment_id
   and   NVL(a.RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED';

   --Bug 4176059: Performance Fix: FP.M-B12
   cursor get_mid_task_totals is
   select SUM(DECODE(a.TRACK_AS_LABOR_FLAG,'Y',NVL(l.QUANTITY,0),0)),
          SUM(NVL(l.RAW_COST,0)),
          SUM(NVL(l.BURDENED_COST,0)),
          SUM(NVL(l.REVENUE,0))
   from pa_budget_lines l,
        pa_resource_assignments a
   where v_rollup_flag = 'M'                      -- Middle Task Level
   and   a.budget_version_id = x_budget_version_id
   and   a.task_id in (select task_id
                      from pa_tasks
                      start with task_id = x_task_id
                      connect by prior task_id = parent_task_id)
   and   a.resource_assignment_id = l.resource_assignment_id
   and   NVL(a.RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED';

   --Bug 4176059: Performance Fix: FP.M-B12
   cursor get_lowest_task_totals is
   select SUM(DECODE(a.TRACK_AS_LABOR_FLAG,'Y',NVL(l.QUANTITY,0),0)),
          SUM(NVL(l.RAW_COST,0)),
          SUM(NVL(l.BURDENED_COST,0)),
          SUM(NVL(l.REVENUE,0))
   from pa_budget_lines l,
        pa_resource_assignments a
   where v_rollup_flag = 'L'                      -- Lowest Task Level
   and   a.budget_version_id = x_budget_version_id
   and   a.task_id = x_task_id
   and   a.resource_assignment_id = l.resource_assignment_id
   and   NVL(a.RESOURCE_ASSIGNMENT_TYPE, 'USER_ENTERED') = 'USER_ENTERED';

  begin
    x_err_code := 0;
    old_stack := x_err_stack;
    x_err_stack := x_err_stack || '->PA_BUDGET_UTILS.get_project_task_totals';

    open get_rollup_level;
    fetch get_rollup_level into v_rollup_flag;
    close get_rollup_level;

    x_err_stage := x_raw_cost_total;

    /* Bug 4176059: Performance Fix: FP.M-B12--- restructured the following code block
     * to open any appropriate cursor to get the totals depending upon the planning level
     */

    -- if x_task_id is not passed, open the project level cursor
    if x_task_id is null then
        -- opening the project level cursor
            open  get_project_totals;

            fetch get_project_totals
            into  x_quantity_total,
                  x_raw_cost_total,
                  x_burdened_cost_total,
                  x_revenue_total;

           close get_project_totals;
    else -- task id is passed
        if v_rollup_flag = 'T' then
            -- top task level planning
            open  get_top_task_totals;

            fetch get_top_task_totals
            into  x_quantity_total,
                  x_raw_cost_total,
                  x_burdened_cost_total,
                  x_revenue_total;

           close get_top_task_totals;
        elsif v_rollup_flag = 'M' then
            -- middle task level planning
            open  get_mid_task_totals;

            fetch get_mid_task_totals
            into  x_quantity_total,
                  x_raw_cost_total,
                  x_burdened_cost_total,
                  x_revenue_total;

           close get_mid_task_totals;
        elsif v_rollup_flag = 'L' then
            -- lowest task level planning
            open  get_lowest_task_totals;

            fetch get_lowest_task_totals
            into  x_quantity_total,
                  x_raw_cost_total,
                  x_burdened_cost_total,
                  x_revenue_total;

           close get_lowest_task_totals;
        end if; -- v_rollup_flag
    end if; -- x_task_id null

    x_err_stack := old_stack;

  exception
     when others then
    x_err_code := SQLCODE;
    return;
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
   close check_uom;  --Bug 5350429
     return 'Y';
   else
   close check_uom;  --Bug 5350429
     return nvl(v_currency_uom_flag,'Y');
   end if;

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

   v_budget_amount_code PA_BUDGET_TYPES.BUDGET_AMOUNT_CODE%TYPE;

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


-- =================================================

--Name:                 Get_Version_Approved_Code
--Type:                 Procedure
--
--Description:  This procedure is called both from this package and other
--              packages.
--
--      This procedure returns the following:
--              1) For the r11.5.7 model:
--                  AC (Approved Cost)
--                  AR (Approved Revenue)
--                  NONE  (Neither Approved Cost nor Approved Revenue)
--              2) For FP versions,
--                  AC (Approved Cost)
--                  AR (Approved Revenue)
--                  ALL (both Approved Cost and Revenue)
--                  NONE  (Neither Approved Cost nor Approved Revenue)
--
--
--Called subprograms: none
--
--
--
--History:
--      07-AUG-02   jwhite  - Created
--

PROCEDURE Get_Version_Approved_Code
              (
               p_budget_version_id  IN      NUMBER
               , x_approved_code    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               , x_msg_count        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
               , x_msg_data     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               , x_return_status    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              )
   IS

     l_cost_flag  pa_budget_versions.approved_cost_plan_type_flag%TYPE := NULL;
     l_rev_flag   pa_budget_versions.approved_rev_plan_type_flag%TYPE := NULL;


   BEGIN

      -- Assume Success
      x_return_status       := FND_API.G_RET_STS_SUCCESS;
      x_msg_count       := 0;
      x_msg_data                := NULL;


      SELECT b.approved_cost_plan_type_flag, b.approved_rev_plan_type_flag
      INTO   l_cost_flag, l_rev_flag
      FROM   pa_budget_versions b
      WHERE  b.budget_version_id  = p_budget_version_id;


      IF (    nvl(l_cost_flag,'N') = 'Y'
                  AND nvl(l_rev_flag,'N') = 'Y'
         )
         THEN
            x_approved_code := 'ALL';

         ELSIF  (    nvl(l_cost_flag,'N') = 'Y'
                 AND nvl(l_rev_flag,'N') = 'N'
                )
             THEN
                x_approved_code := 'AC';

         ELSIF   (    nvl(l_cost_flag,'N') = 'N'
                 AND nvl(l_rev_flag,'N') = 'Y'
                 )
             THEN
                x_approved_code := 'AR';
         ELSE
                x_approved_code := 'NONE';

      END IF;


  EXCEPTION
    WHEN OTHERS
        THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'GET_VERSION_APPROVED_CODE'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
     FND_MSG_PUB.Count_And_Get
     (p_count       =>  x_msg_count ,
      p_data        =>  x_msg_data  );
        RETURN;


   END  Get_Version_Approved_Code;


-- =================================================

--Name:                 Get_Project_Currency_Info
--Type:                 Procedure
--
--Description:  This procedure is called both from this package and other
--              packages.
--
--              This procedure may be called multiple times for a given
--              project. For optimal performance, this procedure stores the
--              selected values into package globals. When the G_Project_Id global
--              differs from the p_project_id IN-parameter, this API does a fetch for
--              the new project_id.
--
--              The G_Project_Id global is defaulted to "-1" in the package specification.
--
--
--
--
--Called subprograms: none
--
--
--
--History:
--      14-AUG-02   jwhite  - Created
--

   PROCEDURE Get_Project_Currency_Info
             (
              p_project_id          IN      NUMBER
              , x_projfunc_currency_code    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_project_currency_code         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_txn_currency_code     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_msg_count         OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_msg_data          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_return_status                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             )

   IS


   BEGIN


    -- Assume Success
    x_return_status      := FND_API.G_RET_STS_SUCCESS;
    x_msg_count      := 0;
    x_msg_data           := NULL;


    -- Fetch Currency Info for New Project

    IF (pa_budget_utils.G_project_id <> p_project_id)
      THEN

          SELECT projfunc_currency_code
                 , project_currency_code
                 , projfunc_currency_code
          INTO pa_budget_utils.G_projfunc_currency_code
               , pa_budget_utils.G_project_currency_code
               , pa_budget_utils.G_txn_currency_code
          FROM    pa_projects_all
          WHERE project_id = p_project_id;

          -- Save P_project_id to Skip this Fetch for Subsequent Calls
          pa_budget_utils.G_project_id  := p_project_id;

    END IF;

    x_projfunc_currency_code := pa_budget_utils.G_projfunc_currency_code;
    x_project_currency_code  := pa_budget_utils.G_project_currency_code;
    x_txn_currency_code      := pa_budget_utils.G_txn_currency_code;


    EXCEPTION
      WHEN OTHERS
        THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'GET_PROJECT_CURRENCY_INFO'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
     FND_MSG_PUB.Count_And_Get
     (p_count       =>  x_msg_count ,
      p_data        =>  x_msg_data  );
        RETURN;



   END  Get_Project_Currency_Info;


-- =================================================

--Name:                 Get_Approved_FP_Info
--Type:                 Procedure
--
--Description:  This procedure is called primarily from Billing packages.
--
--              This procedure is used to determine whether the project is
--              using the new FP model or using the r11.5.7 Budgets model.
--
--              If using the r11.5.7 Budgets model, the functional OUT-parameters
--              are returned as NULL.
--
--
--
--
--
--Called subprograms: none
--
--
--
--History:
--      19-AUG-02   jwhite  - Created
--

    Procedure Get_Approved_FP_Info
             (
              p_project_id          IN      NUMBER
              , x_ac_plan_type_id               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_ar_plan_type_id               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_ac_version_type               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_ar_version_type               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_msg_count         OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_msg_data          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_return_status                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             )

   IS


    l_ac_plan_type_id        pa_proj_fp_options.fin_plan_type_id%TYPE := NULL;
    l_ar_plan_type_id        pa_proj_fp_options.fin_plan_type_id%TYPE := NULL;
    l_ac_version_type        pa_budget_versions.version_type%TYPE     := NULL;
    l_ar_version_type        pa_budget_versions.version_type%TYPE     := NULL;

    l_dummy                  VARCHAR2(1)  := 'N';



   BEGIN


    -- Assume Success
    x_return_status      := FND_API.G_RET_STS_SUCCESS;
    x_msg_count      := 0;
    x_msg_data           := NULL;



          -- Check if r11.5.7 AC/AR Budget Versions Still Exist. If yes, then
          -- default r11.5.7 Budgets model.

          BEGIN

            SELECT 'Y'
            INTO   l_dummy
            FROM   dual
            WHERE  EXISTS (select '1'
                         from pa_budget_versions v
                         where v.project_id = p_project_id
                         and   v.budget_type_code IN ('AC','AR')
                         );

            EXCEPTION
             WHEN NO_DATA_FOUND THEN
                l_dummy := 'N';

          END;


          IF (l_dummy = 'Y')
             THEN
               -- Default r11.5.7 Budgets Model

               x_ac_plan_type_id      := NULL;
               x_ar_plan_type_id      := NULL;
               x_ac_version_type      := NULL;
               x_ar_version_type      := NULL;
               RETURN;

          ELSE

               -- Find FP AC and AR Plan Type Ids, If Any  --------------


            BEGIN
               -- AC
               SELECT o.fin_plan_type_id, v.version_type
               INTO   l_ac_plan_type_id, l_ac_version_type
               FROM   pa_proj_fp_options o
                      , pa_budget_versions v
               WHERE  o.fin_plan_version_id = v.budget_version_id
               AND    v.approved_cost_plan_type_flag = 'Y'
               AND    v.current_flag = 'Y'
               AND    v.project_id = p_project_id;


               EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_ac_plan_type_id := NULL;

            END;


            BEGIN

               -- AR
               SELECT o.fin_plan_type_id, v.version_type
               INTO   l_ar_plan_type_id, l_ar_version_type
               FROM   pa_proj_fp_options o
               , pa_budget_versions v
               WHERE  o.fin_plan_version_id = v.budget_version_id
               AND    v.approved_rev_plan_type_flag = 'Y'
               AND    v.current_flag = 'Y'
               AND    v.project_id = p_project_id;


               EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_ar_plan_type_id := NULL;

            END;


               IF (l_ac_plan_type_id IS NULL AND l_ar_plan_type_id IS NULL)
                  THEN
                  -- If Both AC and AR Plan Type ids are NULL, then Default the r11.5.7 Model

                  x_ac_plan_type_id      := NULL;
                  x_ar_plan_type_id      := NULL;
                  x_ac_version_type      := NULL;
                  x_ar_version_type      := NULL;
                  RETURN;

               ELSE
                  -- Assume FP Model

                  x_ac_plan_type_id      := l_ac_plan_type_id;
                  x_ar_plan_type_id      := l_ar_plan_type_id;
                  x_ac_version_type      := l_ac_version_type;
                  x_ar_version_type      := l_ar_version_type;
                  RETURN;

               END IF; -- l_ac_plan_type_id IS NULL

          END IF;  -- l_dummy = 'Y'


   EXCEPTION
      WHEN OTHERS
        THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg
            (  p_pkg_name       => 'PA_BUDGET_UTILS'
            ,  p_procedure_name => 'GET_APPROVED_FP_INFO'
            ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
     FND_MSG_PUB.Count_And_Get
     (p_count       =>  x_msg_count ,
      p_data        =>  x_msg_data  );
        RETURN;



   END  Get_Approved_FP_Info;

-----------------------------------------------------------------------------

--Name:               check_baseline_funding
--Type:               Function
--
--Description:  This function is called from Oracle Projects, Project form
--              (PAXPREPR.fmb).
--
--              This function returns either 0 or 1 based on the following
--              1. Returns 1 if the Project has Approved Revenue Budget(AR)
--                 (working/submitted/baselined) has budgets that use
--                 categorized resource lists either in new or old budgets model.
--              2. Returns 0 in all other cases.
--
--
--
--Called subprograms:   None
--
--
--
--History:
--      08-JUL-2004         rravipat   Created
--

FUNCTION check_baseline_funding( x_project_id   IN  NUMBER )
  RETURN NUMBER IS

  dummy  NUMBER := 0;

BEGIN
        SELECT 1
          INTO dummy
          FROM dual
         WHERE EXISTS( SELECT 1
                         FROM pa_budget_versions pbv,
                              pa_resource_lists  prl
                        WHERE (pbv.budget_type_code = 'AR' OR -- old model
                               pbv.budget_type_code IS NULL AND
                               approved_rev_plan_type_flag = 'Y') -- new model
                          AND pbv.ci_id is null -- filter change order versions
                          AND pbv.resource_list_id = prl.resource_list_id
                          AND prl.uncategorized_flag <> 'Y'
                          AND pbv.project_id = x_project_id );

  RETURN dummy;
EXCEPTION

  WHEN NO_DATA_FOUND THEN
      dummy := 0;
      RETURN dummy;

END;

-- --------------------------------------------------------------------------------

--Name:         Set_Prj_Policy_Context
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
--              This procedure assumes that the project_id had been fully validated
--              by the calling object. Error checking is limited to any
--              WHEN OTHERS ORA error.
--Other Notes:
--
--              I had to add x_err_code to list to accomodate historical procedure standard
--              used by the Budget Approval workflow.
--
--
--
--
--Called subprograms: none
--
--
--
--History:
--      19-JUL-05   jwhite  - Created
--

   Procedure Set_Prj_Policy_Context
             (
              p_project_id			IN            NUMBER
              , x_msg_count			OUT NOCOPY    NUMBER
              , x_msg_data			OUT NOCOPY    VARCHAR2
              , x_return_status                 OUT NOCOPY    VARCHAR2
              , x_err_code                      OUT NOCOPY    NUMBER
             )
   IS

       l_org_id          pa_projects_all.org_id%TYPE := NULL;

   Begin



        -- Assume Success
        x_return_status      := FND_API.G_RET_STS_SUCCESS;
        x_msg_count          := 0;
        x_msg_data           := NULL;
        x_err_code           := 0;


        -- Fetch Project Org_Id
        -- This should NOT fail since it should have been fully validated
        -- by the calling object.

        SELECT org_id
        INTO   l_org_id
        FROM   pa_projects_all
        WHERE  project_id = p_project_id;


        -- Set the Operating Unit Context
        mo_global.set_policy_context(p_access_mode => 'S'
                                      ,   p_org_id      =>  l_org_id );



        EXCEPTION
          WHEN OTHERS THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 x_err_code      := SQLCODE;
                 FND_MSG_PUB.Add_Exc_Msg
                 (  p_pkg_name       => 'PA_BUDGET_UTILS'
                    ,  p_procedure_name => 'SET_PRJ_POLICY_cONTEXT'
                    ,  p_error_text     => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
                 FND_MSG_PUB.Count_And_Get
                 (p_count       =>  x_msg_count ,
                  p_data        =>  x_msg_data  );
                 RETURN;


   END Set_Prj_Policy_Context;



END pa_budget_utils;

/
