--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CORE" as
-- $Header: PAXPCORB.pls 120.6.12010000.7 2010/01/18 08:19:43 nkapling ship $


--
-- FUNCTION
--
--          Get_Message_from_stack
--          This function returns message from the stack and if does not
--          find one then returns whatever message passed to it.
-- HISTORY
--     12-DEC-01      MAansari    -Created

FUNCTION Get_Message_from_stack( p_err_stage IN VARCHAR2 ) RETURN VARCHAR2 IS
   x_msg_count  NUMBER;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(2000);
   l_data       VARCHAR2(2000);
   l_msg_index_out NUMBER;
   l_app_name   VARCHAR2(2000) := 'PA';
   l_temp_name  VARCHAR2(2000);
BEGIN
      x_msg_count := FND_MSG_PUB.count_msg;

      FND_MSG_PUB.get (
      p_msg_index      => 1,
      p_encoded        => FND_API.G_TRUE,
      p_data           => l_data,
      p_msg_index_out  => l_msg_index_out );

     if l_data is not null then
        FND_MESSAGE.PARSE_ENCODED(ENCODED_MESSAGE => l_data,
                                  APP_SHORT_NAME  => l_app_name,
                                  MESSAGE_NAME    => l_msg_data);

        FND_MSG_PUB.DELETE_MSG(p_msg_index => 1);
     else
        l_msg_data := p_err_stage;
     end if;

     return l_msg_data;

END Get_Message_from_stack;

--
--  PROCEDURE
--              delete_project
--  PURPOSE
--      This objective of this API is to delete projects from
--              the PA system.  All project detail information will be
--              deleted.  This procedure can be used by Enter Project
--              form and other external systems.
--
--              In order to delete a project, a project must NOT
--              have any of the following:
--
--                     * Event
--                     * Expenditure item
--                     * Puchase order line
--                     * Requisition line
--                     * Supplier invoice (ap invoice)
--                     * Funding
--                     * Budget
--             * Committed transactions
--             * Compensation rule sets
--             * Project is referenced by others
--
--  HISTORY
--   24-OCT-95      R. Chiu       Created
-- 17-JUL-2000 Mohnish
--             added code for ROLE BASED SECURITY:
--             added the call to PA_PROJECT_PARTIES_PUB.DELETE_PROJECT_PARTY
--  19-JUL-2000 Mohnish incorporated PA_PROJECT_PARTIES_PUB API changes
--  18-NOV-2002 Added call to PA_EGO_WRAPPER_PUB.check_delete_project_ok and delete_all_item_assocs for PLM
procedure delete_project ( x_project_id       IN number
                          , x_validation_mode     IN  VARCHAR2  DEFAULT 'U'   --bug 2947492
              , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
              , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
              , x_err_stack         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
			  , x_commit            IN        VARCHAR2 := FND_API.G_FALSE)
is

    old_stack      varchar2(630);
    status_code    number;
    temp_stack      varchar2(630);
-- begin NEW code for ROLE BASED SECURITY
v_null_number NUMBER;
v_null_char   VARCHAR2(255);
v_null_date   DATE;
x_return_status VARCHAR2(255);
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(2000);

-- end NEW code for ROLE BASED SECURITY
temp_flag        VARCHAR2(1);

--new code for adding call to PA_LIFECYCLES_PUB.check_delete_project_ok
l_delete_ok                   VARCHAR2(1);

-- Bug 2898598
x_status   VARCHAR2(30);
x_result   VARCHAR2(30);

cursor l_project_csr (t_project_id NUMBER) is
select '1'
  from dual
 where exists (select object_id
                from pa_project_parties
               where object_id   = t_project_id
                 and object_type = 'PA_PROJECTS');

CURSOR get_template_flag IS
SELECT template_flag
FROM PA_PROJECTS_ALL
WHERE project_id = x_project_id;

-- added for bug#3693197
CURSOR get_all_tasks IS
SELECT task_id
FROM PA_TASKS
WHERE project_id = x_project_id;

-- added for bug#3693197
l_tasks_tbl PA_PLSQL_DATATYPES.IdTabTyp;



l_template_flag VARCHAR2(1);
l_wp_enabled    VARCHAR2(1);
begin
        SAVEPOINT delete_project;
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->delete_project';

        OPEN get_template_flag;
        FETCH get_template_flag INTO l_template_flag;
        CLOSE get_template_flag;

        --Bug 3610949 : Check for workplan enabled before deleting the data from the tables
        --in delete_project_structure
        l_wp_enabled := PA_PROJECT_STRUCTURE_UTILS.check_workplan_enabled(x_project_id);

-- mrajput added.
-- 18 Nov 2002. For Product Lifecycle Management.

    PA_EGO_WRAPPER_PUB.check_delete_project_ok(
        p_api_version       => 1.0          ,
        p_project_id        => x_project_id ,
        p_init_msg_list => NULL         ,
        x_delete_ok     => l_delete_ok      ,
        x_return_status => x_return_status  ,
        x_errorcode     => x_err_code       ,
        x_msg_count     => x_msg_count      ,
        x_msg_data      => x_msg_data );

    if((x_err_code <> 0) OR (l_delete_ok <> FND_API.G_TRUE)) then
                x_err_code := 10;
                x_err_stack := x_err_stack || '->check PA_EGO_WRAPPER_PUB.check_delete_project_ok '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
        return;
    end if;

-- anlee
-- Added for ENG integration

    PA_EGO_WRAPPER_PUB.check_delete_project_ok_eng(
        p_api_version       => 1.0          ,
        p_project_id        => x_project_id     ,
        p_init_msg_list     => NULL         ,
        x_delete_ok     => l_delete_ok      ,
        x_return_status     => x_return_status  ,
        x_errorcode     => x_err_code       ,
        x_msg_count     => x_msg_count      ,
        x_msg_data      => x_msg_data );

    if((x_err_code <> 0) OR (l_delete_ok <> FND_API.G_TRUE)) then
                x_err_code := 20;
                x_err_stack := x_err_stack || '->check PA_EGO_WRAPPER_PUB.check_delete_project_ok_eng '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
        return;
    end if;

    pa_project_utils.check_delete_project_ok(
                          x_project_id      => x_project_id,
                          x_validation_mode  => x_validation_mode,  --bug 2947492
                          x_err_code        => x_err_code,
                          x_err_stage       => x_err_stage,
                          x_err_stack       => x_err_stack);

    if (x_err_code <> 0) then
          --Added for bug 3617393
          rollback to delete_project;
          --End bug 3617393
        return;
    end if;

    -- Delete project options
    delete from pa_project_options
    where project_id = x_project_id;

    -- Delete project copy overides
    delete from pa_project_copy_overrides
    where project_id = x_project_id;

-- sacgupta
-- Bug 2898598 changes Start

-- Delete Resource Assignments
     PA_ASSIGNMENTS_PUB.DELETE_PJR_TXNS
            (p_project_id                => x_project_id
            ,p_calling_module            => FND_API.G_MISS_CHAR
            ,p_api_version               => 1.0
            ,p_init_msg_list             => FND_API.G_FALSE
            ,p_commit                    => FND_API.G_FALSE
            ,p_validate_only             => FND_API.G_FALSE
            ,p_max_msg_count             => FND_API.G_MISS_NUM
            ,x_return_status             => x_return_status
            ,x_msg_count                 => x_msg_count
            ,x_msg_data                  => x_msg_data );

          IF    (x_return_status <> 'S') THEN
                x_err_code := 30;
                x_err_stack := x_err_stack || '->Delete_PJR_Txns: '|| x_project_id;
                x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                ROLLBACK TO delete_project;
                RETURN;
          END IF;

-- Delete project subteams
    FOR i IN (SELECT rowid row_id
                    ,project_subteam_id
                FROM pa_project_subteams
               WHERE object_type = 'PA_PROJECTS'
                 AND object_id = x_project_id)
    LOOP

     PA_PROJECT_SUBTEAMS_PVT.Delete_Subteam
           ( p_api_version               =>  1.0
            ,p_init_msg_list             => FND_API.G_FALSE
            ,p_commit                    => FND_API.G_FALSE
            ,p_validate_only             => FND_API.G_FALSE
            ,p_validation_level          => FND_API.g_valid_level_full
         -- ,p_calling_module            => NULL
            ,p_debug_mode                => 'N'
            ,p_max_msg_count             => FND_API.G_MISS_NUM
            ,p_subteam_row_id            => i.row_id
            ,p_subteam_id                => i.project_subteam_id
            ,p_record_version_number     => FND_API.G_MISS_NUM
            ,x_return_status             => x_return_status
            ,x_msg_count                 => x_msg_count
            ,x_msg_data                  => x_msg_data );

          IF    (x_return_status <> 'S') THEN
                x_err_code := 30;
                x_err_stack := x_err_stack || '->Delete_Subteam: '|| x_project_id;
                x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                ROLLBACK TO delete_project;
                RETURN;
          END IF;
    END LOOP;


-- Bug  2898598 changes End

   Open l_project_csr (x_project_id);
   Fetch l_project_csr into temp_flag;
   Close l_project_csr;


if nvl(temp_flag, 'N') = '1' then

    -- Delete project players
-- begin OLD code before changes for ROLE BASED SECURITY
--  delete from a_project_players
--  where project_id = x_project_id;
-- end OLD code before changes for ROLE BASED SECURITY
-- begin NEW code for ROLE BASED SECURITY
          v_null_number := to_number(NULL);
          v_null_char   := to_char(NULL);
          v_null_date   := to_date(NULL);
   PA_PROJECT_PARTIES_PUB.DELETE_PROJECT_PARTY(
          p_api_version => 1.0                  -- p_api_version
          , p_init_msg_list => FND_API.G_FALSE  -- p_init_msg_list
          , p_commit => FND_API.G_FALSE         -- p_commit      --before it was passed TRUE.
          , p_validate_only => FND_API.G_FALSE  -- p_validate_only
          , p_validation_level => FND_API.G_VALID_LEVEL_FULL -- p_validation_level
          , p_debug_mode => 'N'                 -- p_debug_mode
          , p_record_version_number => v_null_number  -- p_record_version_number
          , p_calling_module => 'FORM'          -- p_calling_module
          , p_project_id => x_project_id        -- p_project_id
          , p_project_party_id => v_null_number -- p_project_party_id
          , p_scheduled_flag => 'N'             -- p_scheduled_flag
          , x_return_status => x_return_status  -- x_return_status
          , x_msg_count => x_msg_count          -- x_msg_count
          , x_msg_data => x_msg_data            -- x_msg_data
          );

          IF    (x_return_status <> 'S') Then
                x_err_code := 30;
                x_err_stack := x_err_stack || '->delete_project_party: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
          END IF;

-- end NEW code for ROLE BASED SECURITY

end if;

    -- Delete project classes
    delete from pa_project_classes
    where project_id = x_project_id;

    -- Delete project customers
    delete from pa_project_customers
    where project_id = x_project_id;

    -- Delete project contacts
    delete from pa_project_contacts
    where project_id = x_project_id;

    -- Delete cost distribution overrides
    delete from pa_cost_dist_overrides
    where project_id = x_project_id;

    -- Delete credit receivers
    delete from pa_credit_receivers
    where project_id = x_project_id;

    -- Delete transaction controls
    delete from pa_transaction_controls
    where project_id = x_project_id;

    -- Delete billing assignments
    delete from pa_billing_assignments
    where project_id = x_project_id;

-- anlee
-- Commented out for performance bug 2800018
    -- Delete labor multipliers
--  delete from pa_labor_multipliers
--  where (project_id = x_project_id
--     or task_id in (select task_id from pa_tasks
--            where project_id = x_project_id));

     -- added for bug#3693197
     open get_all_tasks ;
     fetch get_all_tasks bulk collect into l_tasks_tbl;
     close get_all_tasks ;

         DELETE FROM PA_LABOR_MULTIPLIERS
         WHERE  PROJECT_ID = x_project_id;

     -- commented for bug#3693197 and replaced with bulk delete
     --    DELETE FROM PA_LABOR_MULTIPLIERS
     --    WHERE ( TASK_ID IN (SELECT TASK_ID
     --                   FROM PA_TASKS
     --                   WHERE PROJECT_ID = x_project_id ));

     if nvl(l_tasks_tbl.last,0) > 0 then
         forall i in l_tasks_tbl.first..l_tasks_tbl.last
              DELETE FROM PA_LABOR_MULTIPLIERS
              WHERE  task_id = l_tasks_tbl(i);
     end if ;

-- anlee
-- Commented out for performance bug 2800074
    -- Delete job bill rate overrides
--  delete from pa_job_bill_rate_overrides
--  where (project_id = x_project_id
--     or task_id in (select task_id from pa_tasks
--            where project_id = x_project_id));

        DELETE FROM PA_JOB_BILL_RATE_OVERRIDES
        WHERE  PROJECT_ID = x_project_id ;

     -- commented for bug#3693197 and replaced with bulk delete
     --   DELETE FROM PA_JOB_BILL_RATE_OVERRIDES
     --   WHERE ( TASK_ID IN (SELECT TASK_ID
     --                   FROM PA_TASKS
     --                   WHERE PROJECT_ID = x_project_id ));

     if nvl(l_tasks_tbl.last,0) > 0 then
         forall i in l_tasks_tbl.first..l_tasks_tbl.last
              DELETE FROM PA_JOB_BILL_RATE_OVERRIDES
              WHERE  task_id = l_tasks_tbl(i);
     end if ;

-- anlee
-- Commented out for performance
    -- Delete job bill title overrides
--  delete from pa_job_bill_title_overrides
--  where (project_id = x_project_id
--     or task_id in (select task_id from pa_tasks
--            where project_id = x_project_id));

        DELETE FROM pa_job_bill_title_overrides
        WHERE  PROJECT_ID = x_project_id ;

     -- commented for bug#3693197 and replaced with bulk delete
     --   DELETE FROM pa_job_bill_title_overrides
     --   WHERE ( TASK_ID IN (SELECT TASK_ID
     --                   FROM PA_TASKS
     --                   WHERE PROJECT_ID = x_project_id ));

     if nvl(l_tasks_tbl.last,0) > 0 then
         forall i in l_tasks_tbl.first..l_tasks_tbl.last
              DELETE FROM pa_job_bill_title_overrides
              WHERE  task_id = l_tasks_tbl(i);
     end if ;

-- anlee
-- Commented out for performance
    -- Delete job assignment overrides
--  delete from pa_job_assignment_overrides
--  where (project_id = x_project_id
--     or task_id in (select task_id from pa_tasks
--            where project_id = x_project_id));

        DELETE FROM pa_job_assignment_overrides
        WHERE  PROJECT_ID = x_project_id ;

     -- commented for bug#3693197 and replaced with bulk delete
     --   DELETE FROM pa_job_assignment_overrides
     --   WHERE ( TASK_ID IN (SELECT TASK_ID
     --                   FROM PA_TASKS
     --                   WHERE PROJECT_ID = x_project_id ));

     if nvl(l_tasks_tbl.last,0) > 0 then
         forall i in l_tasks_tbl.first..l_tasks_tbl.last
              DELETE FROM pa_job_assignment_overrides
              WHERE  task_id = l_tasks_tbl(i);
     end if ;

-- anlee
-- Commented out for performance
    -- Delete emp bill rate overrides
--  delete from pa_emp_bill_rate_overrides
--  where (project_id = x_project_id
--     or task_id in (select task_id from pa_tasks
--            where project_id = x_project_id));

        DELETE FROM pa_emp_bill_rate_overrides
        WHERE  PROJECT_ID = x_project_id ;

     -- commented for bug#3693197 and replaced with bulk delete
     --   DELETE FROM pa_emp_bill_rate_overrides
     --   WHERE ( TASK_ID IN (SELECT TASK_ID
     --                   FROM PA_TASKS
     --                   WHERE PROJECT_ID = x_project_id ));

     if nvl(l_tasks_tbl.last,0) > 0 then
         forall i in l_tasks_tbl.first..l_tasks_tbl.last
              DELETE FROM pa_emp_bill_rate_overrides
              WHERE  task_id = l_tasks_tbl(i);
     end if ;

-- anlee
-- Commented out for performance bug 2800083
    -- Delete non-labor bill rate overrides
--  delete from pa_nl_bill_rate_overrides
--  where (project_id = x_project_id
--     or task_id in (select task_id from pa_tasks
--            where project_id = x_project_id));

        DELETE FROM PA_NL_BILL_RATE_OVERRIDES
        WHERE  PROJECT_ID = x_project_id ;

     -- commented for bug#3693197 and replaced with bulk delete
     --   DELETE FROM PA_NL_BILL_RATE_OVERRIDES
     --   WHERE ( TASK_ID IN (SELECT TASK_ID
     --                    FROM PA_TASKS
     --                    WHERE PROJECT_ID = x_project_id ));

     if nvl(l_tasks_tbl.last,0) > 0 then
         forall i in l_tasks_tbl.first..l_tasks_tbl.last
              DELETE FROM PA_NL_BILL_RATE_OVERRIDES
              WHERE  task_id = l_tasks_tbl(i);
     end if ;


    -- Delete compiled multipliers, details of compiled set id
    delete from pa_compiled_multipliers
    where ind_compiled_set_id in
        (select ics.ind_compiled_set_id
         from   pa_ind_compiled_sets ics,
                pa_ind_rate_sch_revisions rev,
                pa_ind_rate_schedules sch
         where  ics.ind_rate_sch_revision_id =
                    rev.ind_rate_sch_revision_id
         and    rev.ind_rate_sch_id = sch.ind_rate_sch_id
         and    sch.project_id = x_project_id);

    -- Delete compiled compiled set
    delete from pa_ind_compiled_sets
    where ind_rate_sch_revision_id  in
        (select rev.ind_rate_sch_revision_id
         from   pa_ind_rate_sch_revisions rev,
                pa_ind_rate_schedules sch
         where  rev.ind_rate_sch_id = sch.ind_rate_sch_id
         and    sch.project_id = x_project_id);

    -- Delete ind cost multipliers, details of ind rate sch revisions
    delete from pa_ind_cost_multipliers
    where ind_rate_sch_revision_id in
        (select rev.ind_rate_sch_revision_id
         from pa_ind_rate_sch_revisions rev, pa_ind_rate_schedules sch
         where rev.ind_rate_sch_id = sch.ind_rate_sch_id
         and sch.project_id = x_project_id);

    -- Delete ind rate sch revisions, details of ind rate schedules
    delete from pa_ind_rate_sch_revisions
    where ind_rate_sch_id in
        (select ind_rate_sch_id
         from pa_ind_rate_schedules
         where project_id = x_project_id );

    -- Delete ind rate schedules
    delete from pa_ind_rate_schedules
        where project_id = x_project_id;

    -- Delete project asset assigments
    delete from pa_project_asset_assignments
        where project_id = x_project_id;

    -- Delete project asset
    delete from pa_project_assets
        where project_id = x_project_id;

    -- Delete resource list uses, details of resource list assignments
    delete from pa_resource_list_uses
    where resource_list_assignment_id in
        (select resource_list_assignment_id
         from pa_resource_list_assignments
         where project_id = x_project_id );

    -- Delete resource list assignments
    delete from pa_resource_list_assignments
    where project_id = x_project_id ;

   /* Bug#3480409 : FP.M Changes: Added code for deleting object exceptions, starts here  */
        BEGIN
             PA_PERF_EXCP_UTILS.delete_object_exceptions
                         ( p_object_type    => 'PA_PROJECTS'
                          ,p_object_id      => x_project_id
                          ,x_return_status  => x_return_status
                          ,x_msg_count      => x_msg_count
                          ,x_msg_data       => x_msg_data   );

              IF (x_return_status <> 'S') Then
                  x_err_code := 35;
                  x_err_stack := x_err_stack || '->delete_object_exception: '|| x_project_id;
                  if l_template_flag = 'Y' then
                     x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                  else
                     x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                  end if;
                  rollback to delete_project;
                  return;
              END IF;
        EXCEPTION WHEN OTHERS THEN
             x_err_code  := 35;
             x_err_stage := 'delete_object_exception: '||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
             rollback to delete_project;
             return;
        END;
   /* Bug#3480409 : FP.M Changes: Added code for copying Perf/Score rules, ends here  */


--Ansari
         -- Delete opportunity value
         PA_OPPORTUNITY_MGT_PVT.delete_project_attributes
                       (  p_project_id         => x_project_id,
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 40;
                x_err_stack := x_err_stack || '->delete_project_attributes: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
        END IF;
--Ansari

--Retention Changes --Ansari bug 2362168
        PA_RETENTION_UTIL.delete_retention_rules(
                    p_project_id    =>  x_project_id,
                    p_task_id       =>  null,
                    x_return_status =>  x_return_status,
                    x_msg_count     =>  x_msg_count,
                    x_msg_data      =>  x_msg_data );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 50;
                x_err_stack := x_err_stack || '->delete_retention_rules: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
        END IF;

--Retention Changes --Ansari

        -- Delete percent complete .We shall be deleting all rows for the
        -- project including the task rows.

        delete from pa_percent_completes
        where project_id = x_project_id;

--Bug 3617393
--Moved the delete_task code before delete_project_structure as PA_PROJ_STRUCTURE_PUB.DELETE_RELATIONSHIP
--call in delete_task requires data in pa_proj_elements and pa_proj_element_versions
    -- Delete task

        temp_stack  := x_err_stack;

        for task_rec in (select t.task_id
                         from   pa_tasks t
                         where  t.project_id = x_project_id
                         and    t.task_id = t.top_task_id) loop

            x_err_stack := NULL;

            pa_project_core.delete_task(
                                        x_task_id             => task_rec.task_id,
                                        x_validation_mode      => x_validation_mode,    --bug 2947492
                                        x_err_code             => x_err_code,
                                        x_err_stage            => x_err_stage,
                                        x_err_stack            => x_err_stack);


            if (x_err_code <> 0) then
                --Added for bug 3617393
                rollback to delete_project;
                --End bug 3617393
                return;
            end if;
        end loop;

        x_err_stack := temp_stack;
--End bug 3617393 move
--Ansari integration of project structtures with Forms, Slef Service and AMG
        PA_PROJ_TASK_STRUC_PUB.delete_project_structure(
                 p_calling_module           => 'FORMS'
                ,p_project_id               => x_project_id
                ,x_msg_count                => x_msg_count
                ,x_msg_data                 => x_msg_data
                ,x_return_status            => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 60;
                x_err_stack := x_err_stack || '->delete_project_structure: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
        END IF;
--Ansari integration of project structtures with Forms, Slef Service and AMG

--PA K Build 3 Changes maansari

        PA_CONTROL_ITEMS_PVT.DELETE_ALL_CONTROL_ITEMS(
                 p_project_id               => x_project_id
                ,x_msg_count                => x_msg_count
                ,x_msg_data                 => x_msg_data
                ,x_return_status            => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 70;
                x_err_stack := x_err_stack || '->delete_all_control_items: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
        END IF;
--PA K Build 3 Changes maansari

--Bug 3617393 : Moved delete_task code up from here

  -- hsiu added.
  -- 30 Mar 2001. For Project Contracts.
    -- Delete project structure relationship
    PA_PROJ_STRUCTURE_PUB.DELETE_RELATIONSHIP(
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_commit => FND_API.G_TRUE,
        p_validate_only => FND_API.G_FALSE,
        p_debug_mode => 'N',
        p_task_id => null,
        p_project_id => x_project_id,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 80;
                x_err_stack := x_err_stack || '->delete_relationship: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
    END IF;

 -- mrajput added.
  -- 18 Nov 2002. For Product Lifecycle Management.
    -- Delete Item Associations

    PA_EGO_WRAPPER_PUB.delete_all_item_assocs(
        p_api_version       => 1.0          ,
        p_project_id        => x_project_id     ,
        p_init_msg_list     => NULL         ,
        p_commit        => FND_API.G_TRUE   ,
        x_errorcode     => x_err_code       ,
        x_return_status     => x_return_status  ,
        x_msg_count     => x_msg_count      ,
        x_msg_data      => x_msg_data );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 90;
                x_err_stack := x_err_stack || '->delete_all_item_assocs: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
    END IF;


        -- anlee
        -- Added for intermedia search

        PA_PROJECT_CTX_SEARCH_PVT.DELETE_ROW (
         p_project_id           => x_project_id
        ,p_template_flag        => l_template_flag
        ,x_return_status        => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 100;
                x_err_stack := x_err_stack || '->pa_project_ctx_search_pvt.delete_row: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
        END IF;
        -- anlee end of changes

        -- anlee
        -- Ext Attribute changes
        -- Bug 2904327

        PA_USER_ATTR_PUB.DELETE_ALL_USER_ATTRS_DATA (
             p_validate_only             => FND_API.G_FALSE
            ,p_project_id                => x_project_id
            ,x_return_status             => x_return_status
            ,x_msg_count                 => x_msg_count
            ,x_msg_data                  => x_msg_data );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 105;
                x_err_stack := x_err_stack || '->delete_all_user_attrs_data: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
    END IF;
        -- anlee end of changes


        /* bug 2723705 */
        PA_PROJECT_SETS_PVT.delete_proj_from_proj_set(
         p_project_id => x_project_id
        ,x_return_status => x_return_status);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 110;
                x_err_stack := x_err_stack || '->delete_proj_from_proj_set: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
        END IF;

        /* bug 2723705 end of changes */

--bug 3055766
        PA_TASK_PUB1.Delete_Proj_To_Task_Assoc(
             p_project_id                => x_project_id
            ,x_return_status             => x_return_status
            ,x_msg_count                 => x_msg_count
            ,x_msg_data                  => x_msg_data );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_err_code := 115;
                x_err_stack := x_err_stack || '->Delete_Proj_To_Task_Assoc: '|| x_project_id;
                if l_template_flag = 'Y' then
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
                else
                  x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
                end if;
                rollback to delete_project;
                return;
        END IF;
--End bug 3055766

  -- Bug#3491609
  -- Earlier the call to DELETE_DELIVERABLE_STRUCTURE was placed
  -- after aborting the WF process. Placed this call before aborting
  -- WF.

  -- Changes added by skannoji
  -- Added code for doosan customer
  IF ( PA_PROJECT_STRUCTURE_UTILS.check_Deliverable_enabled(x_project_id) = 'Y' ) THEN
         PA_DELIVERABLE_PUB.delete_deliverable_structure
           (p_project_id           => x_project_id
           ,x_return_status        => x_return_status
           ,x_msg_count            => x_msg_count
           ,x_Msg_data             => x_msg_data
           );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
       END IF;
  -- till here by skannoji

     --Bug 3613601
     Pa_Rbs_Utils.Delete_Proj_Specific_RBS( p_project_id    => x_project_id
                                           ,x_return_status => x_return_status
                                           ,x_msg_count     => x_msg_count
                                           );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           x_err_code := 120;
           x_err_stack := x_err_stack || '->Delete_Proj_Specific_RBS: '|| x_project_id;
           IF l_template_flag = 'Y' THEN
               x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
           ELSE
               x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
           END IF;
           ROLLBACK TO delete_project;
           RETURN;
     END IF;
     --Bug 3613601

     --Bug 3594162
     Pa_Planning_Resource_Utils.Delete_Proj_Specific_Resource( p_project_id    => x_project_id
                                                              ,x_return_status => x_return_status
                                                              ,x_msg_count     => x_msg_count
                                                              );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           x_err_code := 125;
           x_err_stack := x_err_stack || '->Delete_Proj_Specific_Resource: '|| x_project_id;
           IF l_template_flag = 'Y' THEN
               x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
           ELSE
               x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
           END IF;
           ROLLBACK TO delete_project;
           RETURN;
     END IF;
     --Bug 3594162pl
/*  --SMukka Added this plsql block of code
  BEGIN
      PA_PERF_EXCP_UTILS.delete_object_exceptions
       (
           p_object_type   =>'PA_PROJECTS'
          ,p_object_id     =>x_project_id
          ,x_msg_count     =>x_msg_count
          ,x_msg_data      =>x_msg_data
          ,x_return_status =>x_return_status
        );
        IF x_return_status <> 'S' THEN
            x_err_code := 905;
            x_err_stack := x_err_stack||'->PA_PERF_EXCP_UTILS.delete_object_exceptions';
            ROLLBACK TO copy_project;
            RETURN;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
             x_err_code  := SQLCODE;
             x_err_stage := 'PA_PERF_EXCP_UTILS.delete_object_exceptions: '||SUBSTRB(SQLERRM,1,240);
             ROLLBACK TO copy_project;
  END;*/

   /****Note added by sdebroy : 12-MAR-2004
   FP M : 3491609 : FP-M : TRACKING BUG FOR AMG CHANGES FOR DELIVERABLES

   Note :
   No changes is required for cancelling Project Execution Workflow
   and Task Execution Workflow which are introduced as part of
   pathset M . For Project Execution Workflow and Task Execution Workflow
   we'll maintian records in PA_WF_PROCESS table with entity_key1 = project_id
   ,hence the existing code should work.

   Note added by sdebroy : 12-MAR-2004 ****/

-- Start of changes for Bug 2898598

delete from pa_wf_processes where
entity_key1 = TO_CHAR(x_project_id)
and item_type <> 'PABUDWF'
and (item_key,item_type) not in
(select item_key,item_type from wf_items);/*Bug 9276888 Delete those records from
                                           pa_wf_processes for which WF Purge has been run. */

        FOR i IN ( SELECT item_type,item_key
                    FROM pa_wf_processes
                   WHERE entity_key1 = TO_CHAR(x_project_id)
		   and item_type <> 'PABUDWF') --Bug 9040747

         LOOP

             wf_engine.itemstatus ( itemtype  => i.item_type,
                                    itemkey   => i.item_key,
                                    status    => x_status,
                                    result    => x_result );
            IF x_status = 'ACTIVE' THEN

             wf_engine.abortprocess ( itemtype  => i.item_type,
                                      itemkey   => i.item_key );
            END IF;

             wf_purge.total( itemtype  => i.item_type,
                             itemkey   => i.item_key );

        END LOOP;

         DELETE FROM pa_wf_processes
          WHERE entity_key1 = TO_CHAR(x_project_id)
	  and item_type <> 'PABUDWF'; --Bug 9040747;

-- End of changes for bug 2898598

     --Bug 3610949 : Delete budget versions
     IF ( l_wp_enabled = 'Y' ) THEN
          PA_FIN_PLAN_PUB.Delete_Version( p_project_id            => x_project_id
                                         ,p_budget_version_id     => null
                                         ,p_record_version_number => null
                                         ,p_context               => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
                                         ,x_return_status         => x_return_status
                                         ,x_msg_count             => x_msg_count
                                         ,x_msg_data              => x_msg_data
                                        );
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               x_err_code := 130;
               x_err_stack := x_err_stack || '->Delete_Version: '|| x_project_id;
               IF l_template_flag = 'Y' THEN
                    x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
               ELSE
                    x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
               END IF;
               ROLLBACK TO delete_project;
               RETURN;
          END IF;
     END IF;
     --End : Bug 3610949

     --Bug 3610949 : The following code used to be in KEY-DELREC trigger of project_folder block.
     --Moved the call here, after delete_version api call
     pa_fin_plan_utils.Delete_Fp_Options( p_project_id =>  x_project_id,
                                          x_err_code   =>  x_err_code );
     if x_err_code <> 0 Then
               x_err_code  := 140;
               x_err_stack := x_err_stack ||'->Delete_Fp_Options: '|| x_project_id;
               IF l_template_flag = 'Y' THEN
                    x_err_stage := pa_project_core.get_message_from_stack('PA_CANT_DELETE_TEMPLATE');
               ELSE
                    x_err_stage := pa_project_core.get_message_from_stack('PA_CANT_DELETE_PROJECT');
               END IF;
               ROLLBACK TO delete_project;
               RETURN;
     end if;
 -- Start of Bug 4705154
 -- Bug No 4705154:The Following API call is being added to delete entries of project from PA_OBJ_STATUS_CHANGES Table.
     PA_CONTROL_ITEMS_UTILS.DELETE_OBJ_STATUS_CHANGES
	(
	   p_object_type =>'PA_PROJECTS'
	  ,p_object_id   => x_project_id
	  ,x_msg_count     =>x_msg_count
          ,x_msg_data      =>x_msg_data
          ,x_return_status =>x_return_status);
      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           x_err_code := 150;
           x_err_stack := x_err_stack || '->Delete_Obj_Status_Changes: '|| x_project_id;
	      IF l_template_flag = 'Y' THEN
                    x_err_stage := pa_project_core.get_message_from_stack('PA_CANT_DELETE_TEMPLATE');
              ELSE
                    x_err_stage := pa_project_core.get_message_from_stack('PA_CANT_DELETE_PROJECT');
              END IF;
      ROLLBACK TO delete_project;
      return;
      END IF;
 -- End of Bug no 4705154
    -- Delete project
    delete pa_projects
    where  project_id = x_project_id;

        x_err_stack := old_stack;

     --Bug 3617393
     x_err_code := 0;
	 if x_commit = FND_API.G_TRUE then
 	         commit;
 	 end if;

exception
        when others then
                x_err_code := SQLCODE;
                x_err_stage := 'DELETE PROJECT: '||SUBSTR( SQLERRM,1,1900);
                rollback to delete_project;
                return;
end delete_project;


--
--  PROCEDURE
--              import_task
--  PURPOSE
--              This objective of this API is to import tasks into
--              PA system.  This API can be called by task import system
--              and other external systems.  Other task related information
--              can be entered by using Enter Project form or calling table
--              handlers.
--
--
--  HISTORY
--   24-OCT-95      R. Chiu       Created
--
procedure import_task (   x_project_id          IN      number
                        , x_task_name           IN      varchar2
                        , x_task_number         IN      varchar2
                        , x_service_type_code   IN      varchar2
                        , x_organization_id     IN      number
                        , x_description         IN      varchar2
                        , x_task_start_date     IN      date
                        , x_task_end_date       IN      date
                        , x_parent_task_id      IN      number
                        , x_pm_project_id       IN      number
                        , x_pm_task_id          IN      number
                        , x_manager_id          IN      number
                        , x_new_task_id         OUT     NOCOPY number --File.Sql.39 bug 4440895
                        , x_err_code            IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_err_stage           IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_err_stack           IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is

    x_rowid             varchar2(18);
    x_wbs_level         number;
    x_task_id           number;
    x_top_task_id           number;
    x_address_id            number;
    x_org_id            number;
    x_labor_bill_rate_org_id    number;
    x_labor_std_bill_rate_schd  varchar2(20);
    x_proj_start_date       date;
    x_proj_end_date         date;
    x_labor_schedule_discount   number;
    x_labor_schedule_fixed_date date;
    x_nl_bill_rate_org_id       number;
    x_nl_std_bill_rate_schd     varchar2(30);
    x_nl_schedule_discount      number;
    x_nl_schedule_fixed_date    date;
    x_labor_sch_type        varchar2(1);
    x_non_labor_sch_type        varchar2(1);
    x_cost_ind_rate_sch_id      number;
    x_cost_ind_sch_fixed_date   date;
    x_rev_ind_rate_sch_id       number;
    x_rev_ind_sch_fixed_date    date;
    x_inv_ind_rate_sch_id       number;
    x_inv_ind_sch_fixed_date    date;
    x_serv_type_code        varchar2(30);
    x_project_type_class_code   varchar2(30);
    x_billable_flag         varchar2(1);
    status_code         number;
    old_stack           varchar2(630);
begin

       Savepoint import_task;
        -- Check project id
        if (x_project_id is null ) then
                x_err_code := 10;
                x_err_stage := 'PA_NO_PROJ_ID';
                return;
        end if ;

        -- Check task name
        if (x_task_name is null ) then
                x_err_code := 20;
                x_err_stage := 'PA_NO_TASK_NAME';
                return;
        end if ;

        -- Check task number
        if (x_task_number is null ) then
                x_err_code := 30;
                x_err_stage := 'PA_NO_TASK_NUMBER';
                return;
        end if ;

        -- Uniqueness check for task number
        x_err_stage := 'check uniqueness for task number '|| x_task_number;
        status_code :=
             pa_task_utils.check_unique_task_number(x_project_id,
                            x_task_number,
                            null);
        if ( status_code = 0 ) then
            x_err_code := 40;
            x_err_stage := 'PA_TASK_NUM_NOT_UNIQUE';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

    if (x_parent_task_id is null) then  -- creating top task
                x_wbs_level := 1;
        x_top_task_id := NULL;
        else                                -- creating subtask

            -- check create subtask ok
        x_err_stage :=
            'check create subtask for parent task '|| x_parent_task_id;

                --Bug 2947492 The following call is modified to pass params by notation.
                pa_task_utils.check_create_subtask_ok(x_task_id        => x_parent_task_id,
                                                        x_err_code  =>    x_err_code,
                                                          x_err_stage    => x_err_stage,
                                                          x_err_stack    => x_err_stack);

        -- if application error or oracle error then discontinue.
            if ( x_err_code <> 0 ) then
            return;
        end if;

        -- get wbs level for parent task id
        x_err_stage :=
            'get wbs level for parent task '|| x_parent_task_id;
        x_wbs_level := pa_task_utils.get_wbs_level(x_parent_task_id);
        if (x_wbs_level is null) then
                x_err_code := 50;
                x_err_stage := 'PA_WBS_LEVEL_NOT_FOUND';
                return;
            elsif ( x_wbs_level < 0 ) then      -- Oracle error
                x_err_code := x_wbs_level;
                return;
            end if;
        x_wbs_level := x_wbs_level + 1;
                -- increase level by 1 for child task

        -- get top task id for parent task id
        x_err_stage :=
            'get top task id for parent task '|| x_parent_task_id;
        x_top_task_id := pa_task_utils.get_top_task_id(x_parent_task_id);
        if (x_top_task_id is null) then
                x_err_code := 60;
                x_err_stage := 'PA_TASK_ID_NOT_FOUND';
                return;
            elsif ( x_top_task_id < 0 ) then    -- Oracle error
                x_err_code := x_top_task_id;
                return;
            end if;
    end if;

    -- Get default task information.

    x_err_stage := 'get default task information ';

    declare
        cursor c1 is
            SELECT
                  P.start_date,
                  P.completion_date,
                P.carrying_out_organization_id,
                  P.labor_bill_rate_org_id,
                  P.labor_std_bill_rate_schdl,
                  P.labor_schedule_discount,
                  P.labor_schedule_fixed_date,
                  P.non_labor_bill_rate_org_id,
                  P.non_labor_std_bill_rate_schdl,
                  P.non_labor_schedule_discount,
                  P.non_labor_schedule_fixed_date,
                  P.labor_sch_type,
                  P.non_labor_sch_type,
                  P.cost_ind_rate_sch_id,
                  P.cost_ind_sch_fixed_date,
                  P.rev_ind_rate_sch_id,
                  P.rev_ind_sch_fixed_date,
                  P.inv_ind_rate_sch_id,
                  P.inv_ind_sch_fixed_date,
                  PT.service_type_code,
                  PT.project_type_class_code
                FROM   pa_projects P, pa_project_types PT
                WHERE  P.project_id = x_project_id
                AND    P.project_type = PT.project_type;

    begin
        open c1;
        fetch c1 into
          x_proj_start_date,
          x_proj_end_date,
          x_org_id,
          x_labor_bill_rate_org_id,
          x_labor_std_bill_rate_schd,
          x_labor_schedule_discount,
          x_labor_schedule_fixed_date,
          x_nl_bill_rate_org_id,
          x_nl_std_bill_rate_schd,
          x_nl_schedule_discount,
          x_nl_schedule_fixed_date,
          x_labor_sch_type,
          x_non_labor_sch_type,
          x_cost_ind_rate_sch_id,
          x_cost_ind_sch_fixed_date,
          x_rev_ind_rate_sch_id,
          x_rev_ind_sch_fixed_date,
          x_inv_ind_rate_sch_id,
          x_inv_ind_sch_fixed_date,
          x_serv_type_code,
          x_project_type_class_code;

        if c1%notfound then
           close c1;
           x_err_code := 70;
           x_err_stage := 'PA_NO_ROW_FOUND';
           return;
        end if;
        close c1;

    exception
        when others then
           close c1;
           x_err_code := SQLCODE;
           return;
    end ;

        -- Get default address id
        begin
                x_err_stage := 'get default address id ';

            -- 4363092 TCA changes, replaced RA views with HZ tables
            /*
                SELECT
          DISTINCT A.address_id
          INTO   x_address_id
            FROM   ra_addresses A, ra_site_uses SU
            WHERE  A.address_id = SU.address_id
            AND    A.customer_id IN
            (SELECT customer_id
            FROM   pa_project_customers
                    WHERE  project_id = x_project_id)
            AND    NVL(SU.STATUS,'A') = 'A'
            AND    SU.site_use_code = 'SHIP_TO';
            */

            SELECT
            DISTINCT acct_site.cust_acct_site_id
            INTO   x_address_id
            FROM
                   hz_cust_acct_sites_all acct_site,
                   hz_cust_site_uses su
            WHERE
              acct_site.cust_acct_site_id  = su.cust_acct_site_id
              AND  acct_site.cust_account_id IN
            (SELECT customer_id FROM   pa_project_customers WHERE  project_id = x_project_id)
            AND    NVL(SU.STATUS,'A') = 'A'
            AND    SU.site_use_code = 'SHIP_TO';

            -- 4363092 end

    exception
        when NO_DATA_FOUND then
           x_address_id := NULL;
        when TOO_MANY_ROWS then
           x_address_id := NULL;
        when others then
                   x_err_code := SQLCODE;
                   return;
        end ;


    -- verify date range
        if (x_task_start_date is not null AND x_task_end_date is not null
                AND x_task_start_date > x_task_end_date ) then
                                -- invaid task date range
                x_err_code := 80;
                x_err_stage := 'PA_SU_INVALID_DATES';
                                -- existing message name from PAXTKETK
                return;
    else
        if (   (x_task_start_date is null OR
             x_proj_start_date is null OR
                 x_task_start_date >= x_proj_start_date)
                AND (x_task_end_date is null OR
             x_proj_end_date is null OR
                 x_task_end_date <= x_proj_end_date) ) then
            null;   -- task dates are within project dates range
        else
            x_err_code := 90;
            x_err_stage := 'PA_TK_OUTSIDE_PROJECT_RANGE';
                 -- existing message name from PAXTKETK
            return;
        end if;
    end if;

    -- set task billable flag
        if (x_project_type_class_code =  'INDIRECT') then
                x_billable_flag := 'N';
        else
                x_billable_flag := 'Y';
        end if;


    -- Update parent task chargeable flag to 'N'.
    -- Only lowest tasks are chargeable.

    if (x_parent_task_id is not null) then
        x_err_stage := 'update parent task chargeable flag';

        update pa_tasks
        set chargeable_flag = 'N'
        where task_id = x_parent_task_id;
    end if;

    -- call table handler to insert task
        begin
                x_err_stage := 'Insert task for project '|| x_project_id;

                pa_tasks_pkg.insert_row(
                x_rowid,
                x_task_id,
                x_project_id,
                x_task_number,
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                x_task_name,
                x_task_name,       -- long name
                x_top_task_id,
                x_wbs_level,
                'N',
                'N',
                x_parent_task_id,
                x_description,
                nvl(x_organization_id, x_org_id),
                nvl(x_service_type_code, x_serv_type_code),
                x_manager_id,
                'Y',
                x_billable_flag,
                'N',
                nvl(x_task_start_date, x_proj_start_date),
                nvl(x_task_end_date, x_proj_end_date),
                x_address_id,
                X_Labor_Bill_Rate_Org_Id,
                X_Labor_Std_Bill_Rate_Schd,
                X_Labor_Schedule_Fixed_Date,
                X_Labor_Schedule_Discount,
                X_NL_Bill_Rate_Org_Id,
                X_NL_Std_Bill_Rate_Schd,
                X_NL_Schedule_Fixed_Date,
                X_NL_Schedule_Discount,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                X_Cost_Ind_Rate_Sch_Id,
                X_Rev_Ind_Rate_Sch_Id,
                    X_Inv_Ind_Rate_Sch_Id,
                X_Cost_Ind_Sch_Fixed_Date,
                X_Rev_Ind_Sch_Fixed_Date,
                X_Inv_Ind_Sch_Fixed_Date,
                X_Labor_Sch_Type,
                X_Non_Labor_Sch_Type,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
-- 01-APR-2001
-- hsiu Added for forecasting changes
            NULL,
            NULL,
--MCA Sakthi for MultiAgreementCurreny Project
            NULL,
            NULL,
            NULL,
--MCA Sakthi for MultiAgreementCurreny Project
            NULL,
            NULL,
--PA L Changes 2872708
            'N',
            'Y',
            null,

--End PA L Changes 2872708
/*FPM Dev -Project setup changes */
           null,
           null,
           null
);
        exception
                when NO_DATA_FOUND then
                        x_err_code := 100;
                        x_err_stage := 'PA_NO_ROW_INSERTED';
                        rollback to import_task;
            return;
        when others then
            x_err_code := SQLCODE;
                        rollback to import_task;
            return;
        end;

    x_new_task_id := x_task_id;
        x_err_stack := old_stack;

exception
    when others then
       x_err_code := SQLCODE;
           rollback to import_task;
       return;
end import_task;

--
--  PROCEDURE
--              delete_task
--  PURPOSE
--              This objective of this API is to delete tasks from
--              the PA system.  All task detail information along
--              with the specified task will be deleted if there's
--              no transaction charged to the task.  This API can
--              be used by Enter Project form and other external systems.
--
--              To delete a top task and its subtasks, the following
--              requirements must be met:
--                   * No event at top level task
--                   * No funding at top level tasks
--                   * No baseline budget at top level task
--                   * Meet the following requirements for its children
--
--              To delete a mid level task, it involves checking its
--              children and meeting the following requirements for
--              its lowest level task.
--
--              To delete a lowest level task, the following requirements
--              must be met:
--                   * No expenditure item at lowest level task
--                   * No puchase order line at lowest level task
--                   * No requisition line at lowest level task
--                   * No supplier invoice (ap invoice) at lowest level task
--                   * No baseline budget at lowest level task
--
--  HISTORY
--   25-OCT-95      R. Chiu       Created
--
procedure delete_task (   x_task_id             IN        number
                        , x_validation_mode     IN        VARCHAR2    DEFAULT 'U' --bug 2947492
                        , x_validate_flag       IN        varchar2    DEFAULT 'Y' -- Adding paramater x_validate_flag
                        , x_bulk_flag           IN        VARCHAR2  DEFAULT 'N'  -- 4201927
                        , x_err_code            IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_err_stage           IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_err_stack           IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is

    old_stack       varchar2(630);
    status_code     number;
    x_parent_task_id    number;
    l_project_id        number;
    x_return_status varchar2(1);
        x_msg_count         number;
        x_msg_data          varchar2(2000);
        l_cc_tax_task_id    number;   ---- Bug 6629057

cursor l_project_csr is
select project_id from
pa_tasks where
task_id = x_task_id;

--Added for bug 3617393
CURSOR get_template_flag(c_project_id IN NUMBER) IS
SELECT template_flag
FROM   pa_projects_all
WHERE  project_id = c_project_id;

cursor cc_task_id_csr(x_taskid number)  ---- Bug 6629057
is select cc_tax_task_id from pa_projects_all pj
where pj.project_id = l_project_id;

l_template_flag VARCHAR2(1) := 'N';
--Added for bug 3617393

begin

        SAVEPOINT delete_task;

    old_stack := x_err_stack; -- Fix for Bug # 4513291. It should initialize old_stack before appending values
        x_err_stack := x_err_stack || '->delete_task';

        x_err_code := 0;

        x_err_stage := 'Fetching project id for task '|| x_task_id;

        Open l_project_csr;
        Fetch l_project_csr into l_project_id;
        If l_project_csr%NOTFOUND THEN
           close l_project_csr;
           RAISE NO_DATA_FOUND;
        Else
           close l_project_csr;
        End if;

        --Added for bug 3617393
        OPEN  get_template_flag ( l_project_id );
        FETCH get_template_flag INTO l_template_flag;
        CLOSE get_template_flag;
        --Added for bug 3617393

        -- Fix for Bug # 4513291. Moved this up before appending x_err_stack -- old_stack := x_err_stack;

        -- 4201927
        IF x_bulk_flag = 'N' THEN
            pa_task_utils.check_delete_task_ok(
                                               x_task_id           => x_task_id,
                                               x_validation_mode   => x_validation_mode,   -- bug 2947492
                                               x_err_code          => x_err_code,
                                               x_err_stage         => x_err_stage,
                                               x_err_stack         => x_err_stack);

            if (x_err_code <> 0) then
              --Added for bug 3617393
              rollback to delete_task;
              --End bug 3617393
              return;
            end if;
        END IF;

        ---- start 6629057
        Open  cc_task_id_csr(x_task_id);
	    fetch cc_task_id_csr into l_cc_tax_task_id;
        if cc_task_id_csr%notfound then
            close cc_task_id_csr;
	    end if;
	    if(l_cc_tax_task_id = x_task_id) then
	        update pa_projects_all
	        set cc_tax_task_id = null
	        where project_id = l_project_id;
	        close cc_task_id_csr;
	    end if;
	---- end 6629057

        -- 4201927 end

        delete from pa_billing_assignments
        where top_task_id = x_task_id
        AND project_id = l_project_id;

        -- 3693197
        -- Commented the whole code and moved the code
        -- inside the anonymous block and used bulk approach.
        -- In all the below mentioned deletes following select
        -- query :
        -- SELECT TASK_ID
       -- FROM   PA_TASKS
       -- CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
       -- START WITH TASK_ID = x_TASK_ID
        -- was getting called repeatedly. Instead used the existing
        -- cursor task_cur to fetch all the tasks into PLSQL table
        -- and used bulk delete.

       -- Delete transaction controls
       --x_err_stage := 'Delete txn controls for task '|| x_task_id;
       --delete from pa_transaction_controls
       --where task_id in
      --(SELECT TASK_ID
      -- FROM   PA_TASKS
      -- CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
      -- START WITH TASK_ID = x_TASK_ID)
      -- Added to fix Bug # 1190003
      --AND project_id = l_project_id;

       -- Delete billing assignments
       --x_err_stage := 'Delete billing assignmts for task '|| x_task_id;
       -- Delete labor multipliers
       -- x_err_stage := 'Delete labor multipliers for task '|| x_task_id;
       -- delete from pa_labor_multipliers
       -- where task_id in
      -- (select task_id
      --  from pa_tasks
       --     CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
       --     START WITH TASK_ID = x_TASK_ID);
       --
       -- -- Delete job bill rate overrides
       -- x_err_stage := 'Delete job bill rate overrides for task '|| x_task_id;
       -- delete from pa_job_bill_rate_overrides
       -- where task_id in
      -- (select task_id
      --  from pa_tasks
       --     CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
       --     START WITH TASK_ID = x_TASK_ID);
       --
       -- -- Delete job bill title overrides
       -- x_err_stage := 'Delete job bill title overrides for task '|| x_task_id;
       -- delete from pa_job_bill_rate_overrides
       -- where task_id in
       --    (select task_id
       --     from pa_tasks
       --     CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
       --     START WITH TASK_ID = x_TASK_ID);
       --
       -- -- Delete job assignment overrides
       -- x_err_stage := 'Delete job assignmt overrides for task '|| x_task_id;
       -- delete from pa_job_assignment_overrides
       -- where task_id in
       --    (select task_id
       --     from pa_tasks
       --     CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
       --     START WITH TASK_ID = x_TASK_ID);
       --
       -- -- Delete emp bill rate overrides
       -- x_err_stage := 'Delete emp bill rate overrides for task '|| x_task_id;
       -- delete from pa_emp_bill_rate_overrides
       -- where task_id in
       --    (select task_id
       --     from pa_tasks
       --     CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
       --     START WITH TASK_ID = x_TASK_ID);
       --
       -- -- Delete non-labor bill rate overrides
       -- x_err_stage := 'Delete nl bill rate overrides for task '|| x_task_id;
       -- delete from pa_nl_bill_rate_overrides
       -- where task_id in
       --    (select task_id
       --     from pa_tasks
       --     CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
       --     START WITH TASK_ID = x_TASK_ID);

-- anlee
-- Commenting out for performance bug 2800129
    -- Delete compiled multipliers, details of compiled set id
--  x_err_stage := 'Delete compiled multiplier for task '|| x_task_id;
--  delete from pa_compiled_multipliers
--  where ind_compiled_set_id in
--      (select ics.ind_compiled_set_id
--       from   pa_ind_compiled_sets ics,
--              pa_ind_rate_sch_revisions rev,
--              pa_ind_rate_schedules sch
--       where  ics.ind_rate_sch_revision_id =
--                  rev.ind_rate_sch_revision_id
--       and    rev.ind_rate_sch_id = sch.ind_rate_sch_id
--       and    sch.task_id in
--             (select task_id
--              from   pa_tasks
--              connect by prior task_id = parent_task_id
--              start with task_id = x_task_id));

-- anlee
-- Commenting out for performance bug 2800129
    -- Delete compiled compiled set
--  x_err_stage := 'Delete compiled sets for task '|| x_task_id;
--  delete from pa_ind_compiled_sets
--  where ind_rate_sch_revision_id  in
--      (select rev.ind_rate_sch_revision_id
--       from   pa_ind_rate_sch_revisions rev,
--              pa_ind_rate_schedules sch
--       where  rev.ind_rate_sch_id = sch.ind_rate_sch_id
--       and    sch.task_id in
--             (select task_id
--              from   pa_tasks
--              connect by prior task_id = parent_task_id
--              start with task_id = x_task_id));

-- anlee
-- Commenting out for performance bug 2800129
        -- Delete ind cost multipliers, details of ind rate sch revisions
--        x_err_stage := 'Delete ind cost multiplier for task '|| x_task_id;
--        delete from pa_ind_cost_multipliers
--        where ind_rate_sch_revision_id in
--                (select rev.ind_rate_sch_revision_id
--                 from pa_ind_rate_sch_revisions rev, pa_ind_rate_schedules sch
--                 where rev.ind_rate_sch_id = sch.ind_rate_sch_id
--                 and sch.task_id in
--                 (select task_id
--                  from pa_tasks
--                  CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
--                  START WITH TASK_ID = x_TASK_ID));

-- anlee
-- Commenting out for performance bug 2800129
        -- Delete ind rate sch revisions, details of ind rate schedules
--        x_err_stage := 'Delete ind rate sch revision for task '|| x_task_id;
--        delete from pa_ind_rate_sch_revisions
--        where ind_rate_sch_id in
--                (select ind_rate_sch_id
--                 from pa_ind_rate_schedules
--                 where task_id in
--                           (select task_id
--                            from pa_tasks
--                            CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
--                            START WITH TASK_ID = x_TASK_ID));

    /*
     *  Anonymous Block to delete burdening setup starts.
     */
     declare
         cursor task_cur ( l_start_task_id pa_tasks.task_id%TYPE )
             is
                 select task_id
                   from pa_tasks
                            connect by prior task_id = parent_task_id
                              start with task_id = l_start_task_id
                 ;
         cursor sch_cur ( l_task_id IN pa_tasks.task_id%TYPE )
             is
                 select sch.ind_rate_sch_id
                   from pa_ind_rate_schedules sch
                  where sch.task_id = l_task_id
                 ;
         cursor rev_cur ( l_ind_rate_sch_id IN pa_ind_rate_schedules_all_bg.ind_rate_sch_id%TYPE )
             is
                 select rev.ind_rate_sch_revision_id
                   from pa_ind_rate_sch_revisions rev
                  where rev.ind_rate_sch_id = l_ind_rate_sch_id
                 ;
         cursor ics_cur ( l_ind_rate_sch_revision_id IN pa_ind_rate_sch_revisions.ind_rate_sch_revision_id%TYPE )
             is
                select ics.ind_compiled_set_id
                  from pa_ind_compiled_sets ics
                 where ics.ind_rate_sch_revision_id = l_ind_rate_sch_revision_id
                ;
     l_task_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
     l_ind_rate_sch_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
     l_ind_rate_sch_rev_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;
     l_ind_comp_set_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
     begin

         open task_cur ( x_task_id );
                  fetch task_cur
                   bulk collect
                   into l_task_id_tab;
         close task_cur;

         -- added for bug#3693197
         if nvl(l_task_id_tab.LAST,0) >0 then

        -- Delete transaction controls
        x_err_stage := 'Delete txn controls for task '|| x_task_id;
             forall i in l_task_id_tab.FIRST..l_task_id_tab.LAST
               delete from pa_transaction_controls
                      where task_id =l_task_id_tab(i)
                        and project_id = l_project_id;


        -- Delete labor multipliers
        x_err_stage := 'Delete labor multipliers for task '|| x_task_id;
             forall i in l_task_id_tab.FIRST..l_task_id_tab.LAST
               delete from pa_labor_multipliers
                      where task_id =l_task_id_tab(i) ;

        -- Delete job bill rate overrides
        x_err_stage := 'Delete job bill rate overrides for task '|| x_task_id;
             forall i in l_task_id_tab.FIRST..l_task_id_tab.LAST
               delete from pa_job_bill_rate_overrides
                      where task_id =l_task_id_tab(i) ;

        -- Delete job assignment overrides
        x_err_stage := 'Delete job assignment overrides for task '|| x_task_id;
             forall i in l_task_id_tab.FIRST..l_task_id_tab.LAST
               delete from pa_job_assignment_overrides
                      where task_id =l_task_id_tab(i) ;

        -- Delete emp bill rate overrides
        x_err_stage := 'Delete emp bill rate overrides for task '|| x_task_id;
             forall i in l_task_id_tab.FIRST..l_task_id_tab.LAST
               delete from pa_emp_bill_rate_overrides
                      where task_id =l_task_id_tab(i) ;

        -- Delete nl bill rate overrides
        x_err_stage := 'Delete nl bill rate overrides for task '|| x_task_id;
             forall i in l_task_id_tab.FIRST..l_task_id_tab.LAST
               delete from pa_nl_bill_rate_overrides
                      where task_id =l_task_id_tab(i) ;

        -- Delete project asset assignments
        x_err_stage := 'Delete project asset assignments for task '|| x_task_id;
             forall i in l_task_id_tab.FIRST..l_task_id_tab.LAST
               delete from pa_project_asset_assignments
                      where task_id =l_task_id_tab(i) ;

         end if ;


         for i in 1 .. l_task_id_tab.count
         loop
                  open sch_cur ( l_task_id_tab (i) );
                         fetch sch_cur
                          bulk collect
                          into l_ind_rate_sch_id_tab;
                  close sch_cur;

                  for i in 1 .. l_ind_rate_sch_id_tab.count
                  loop
                         open rev_cur ( l_ind_rate_sch_id_tab (i) );
                                   fetch rev_cur
                                    bulk collect
                                     into l_ind_rate_sch_rev_id_tab;
                         close rev_cur;

                         for i in 1 .. l_ind_rate_sch_rev_id_tab.count
                         loop
                                      open ics_cur ( l_ind_rate_sch_rev_id_tab (i) );
                                             fetch ics_cur
                                              bulk collect
                                              into l_ind_comp_set_id_tab;
                                      close ics_cur;

                                      if ( l_ind_comp_set_id_tab.count > 0 )
                                      then
                                          forall i in l_ind_comp_set_id_tab.first .. l_ind_comp_set_id_tab.last
                                               delete
                                                 from pa_compiled_multipliers comp_mult
                                                where ind_compiled_set_id = l_ind_comp_set_id_tab(i)
                                               ;
                                          forall i in l_ind_comp_set_id_tab.first .. l_ind_comp_set_id_tab.last
                                               delete
                                                 from pa_ind_compiled_sets ics
                                                where ind_compiled_set_id = l_ind_comp_set_id_tab(i)
                                               ;
                                      end if;
                         end loop;

                         if ( l_ind_rate_sch_rev_id_tab.count > 0 )
                         then
                             forall i in l_ind_rate_sch_rev_id_tab.first .. l_ind_rate_sch_rev_id_tab.last
                                      delete
                                        from pa_ind_cost_multipliers icm
                                       where icm.ind_rate_sch_revision_id = l_ind_rate_sch_rev_id_tab(i)
                                      ;
                             forall i in l_ind_rate_sch_rev_id_tab.first .. l_ind_rate_sch_rev_id_tab.last
                                      delete
                                        from pa_ind_rate_sch_revisions rev
                                       where rev.ind_rate_sch_revision_id = l_ind_rate_sch_rev_id_tab(i)
                                      ;
                         end if;

                  end loop; -- schedule

                  if ( l_ind_rate_sch_id_tab.count > 0 )
                  then
                      forall i in l_ind_rate_sch_id_tab.first .. l_ind_rate_sch_id_tab.last
                           delete
                             from pa_ind_rate_schedules sch
                            where sch.ind_rate_sch_id = l_ind_rate_sch_id_tab(i)
                           ;
                  end if;

         end loop; -- task
     exception
     when others
        then
            x_err_code := SQLCODE;
            rollback to delete_task;
            return;
     end; -- end of anonymous block to delete burdening setup.
/* New code to delete burdening setup ends **/

        -- Delete project asset assigments
        -- 3693197 : Commented and moved above in the anonymous block

        --x_err_stage := 'Delete proj asset assignmt for task '|| x_task_id;
        -- delete from pa_project_asset_assignments
        -- where task_id in
        --        (select task_id
        --        from pa_tasks
        --        CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
        --        START WITH TASK_ID = x_TASK_ID);

--Retention Changes --Ansari bug 2362168
        PA_RETENTION_UTIL.delete_retention_rules(
                    p_project_id    =>  l_project_id,
                    p_task_id       =>  x_TASK_ID,
                    x_return_status =>  x_return_status,
                    x_msg_count     =>  x_msg_count,
                    x_msg_data      =>  x_msg_data );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               --Added for bug 3617393
               x_err_code := 150;
               x_err_stack := x_err_stack || '->delete_retention_rules: '|| l_project_id;
               IF l_template_flag = 'Y' THEN
                    x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
               ELSE
                    x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
               END IF;
               ROLLBACK TO delete_task ;
               --End bug 3617393
              RETURN;
        END IF;

--Retention Changes --Ansari


        -- Delete percent complete .Need to pass project id
        -- since that is the leading key in the index

        x_err_stage := 'Delete task percent complete ';
        delete from pa_percent_completes
        where project_id = l_project_id
        and task_id in
                (select task_id
                from pa_tasks
                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                START WITH TASK_ID = x_TASK_ID);

        -- hsiu added.
        -- 30 Mar 2001. For Project Contracts.
        -- Delete project structure relationship
        x_err_stage := 'Delete project structure relationship for task ';
        PA_PROJ_STRUCTURE_PUB.DELETE_RELATIONSHIP(
          p_api_version => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => FND_API.G_TRUE,
          p_validate_only => FND_API.G_FALSE,
          p_debug_mode => 'N',
          p_task_id => x_TASK_ID,
          p_project_id => null,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               --Added for bug 3617393
               x_err_code := 160;
               x_err_stack := x_err_stack || '->DELETE_RELATIONSHIP: '|| l_project_id;
               IF l_template_flag = 'Y' THEN
                    x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_TEMPLATE');
               ELSE
                    x_err_stage := pa_project_core.get_message_from_stack( 'PA_CANT_DELETE_PROJECT');
               END IF;
               ROLLBACK TO delete_task ;
               --End bug 3617393
               return;
        END IF;
        -- end delete project structure relationship

        -- Delete task
        x_err_stage := 'Delete any task in the subtree of task '|| x_task_id;
        delete from pa_tasks
        where task_id in
                (select task_id
                from pa_tasks
                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                START WITH TASK_ID = x_TASK_ID);

        -- get parent task id
        x_err_stage := 'get parent task id for task '|| x_task_id;
        x_parent_task_id := pa_task_utils.get_parent_task_id(x_task_id);

        if ( x_parent_task_id < 0 ) then        -- Oracle error
                x_err_code := x_parent_task_id;
                return;
        end if;

        if (x_parent_task_id is not null ) then
                -- Check if task is last child
                x_err_stage := 'check last child for '|| x_task_id;
                status_code := pa_task_utils.check_last_child(x_task_id);

                if ( status_code = 1 ) then
                    -- set parent task's chargeable_flag to 'Y
                    x_err_stage := 'update parent task chargeable flag';

                    update pa_tasks
                    set chargeable_flag = 'Y'
                    where task_id = x_parent_task_id;

                elsif ( status_code < 0 ) then
                    x_err_code := status_code;
                    return;
                end if;
        end if;

        x_err_stack := old_stack;

exception
        when others then
                x_err_code := SQLCODE;
                rollback to delete_task;
                return;
end delete_task;

--
--  PROCEDURE
--              delete_project_type
--
--  HISTORY
--   01-NOV-02      Mansari       Created
--
procedure delete_project_type (
                          x_project_type_id      IN     number
                        , x_msg_count            OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_msg_data             OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_return_status        OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
)
is

    l_return_status                 varchar2(1);
begin

     SAVEPOINT delete_project_type;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

--No need to call this API here
/*     PA_PROJECT_UTILS.check_delete_project_type_ok(
                    p_project_type_id    => x_project_type_id
                   ,x_return_status      => x_return_status
                   ,x_error_message_code => x_msg_data
                  );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
            RETURN;
        END IF;
*/

        -- Delete project type
        delete pa_project_types_all --bug 4584792
        where  project_type_id = x_project_type_id;

exception
        when others then
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                rollback to delete_project;
                return;
end delete_project_type;

--
--  PROCEDURE
--              delete_class_category
--
--  HISTORY
--   01-NOV-02      Mansari       Created
--
procedure delete_class_category (
                          x_class_category      IN     VARCHAR2
                        , x_msg_count            OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_msg_data             OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_return_status        OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
)
is

    l_return_status                 varchar2(1);
begin

     SAVEPOINT delete_class_category;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Delete class_category
     delete pa_class_categories
     where  class_category = x_class_category
     ;

exception
        when others then
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                rollback to delete_class_category;
                return;
end delete_class_category;

--
--  PROCEDURE
--              delete_class_code
--
--  HISTORY
--   01-NOV-02      Mansari       Created
--
procedure delete_class_code (
                          x_class_category      IN     VARCHAR2
                        , x_class_code          IN     VARCHAR2
                        , x_msg_count            OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_msg_data             OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_return_status        OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
)
is

    l_return_status                 varchar2(1);
begin

     SAVEPOINT delete_class_code;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Delete class_category
     delete pa_class_codes
     where  class_category = x_class_category
       and class_code = x_class_code
     ;

exception
        when others then
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                rollback to delete_class_code;
                return;
end delete_class_code;

end PA_PROJECT_CORE;

/
