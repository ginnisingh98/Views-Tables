--------------------------------------------------------
--  DDL for Package Body PA_PROGRESS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROGRESS_UTILS" as
/* $Header: PAPCUTLB.pls 120.31.12010000.11 2009/07/09 12:25:18 spasala ship $ */
/* Addition for bug 6156686 */

l_bcws_project_id            NUMBER  ;
l_bcws_object_id             NUMBER  ;
l_bcws_proj_element_id       NUMBER  ;
l_bcws_as_of_date            DATE    ;
l_bcws_structure_version_id  NUMBER  ;
l_bcws_rollup_method         VARCHAR2(30);
l_bcws_scheduled_start_date  DATE ;
l_bcws_scheduled_end_date    DATE  ;
l_bcws_prj_currency_code     VARCHAR2(30);
l_bcws_structure_type        VARCHAR2(30);
l_bcws_value                 NUMBER;

-- Start Changes for bug 6664716
TYPE bcws_rec_type IS RECORD
(labor_hrs          number,   --Stores the sum of prorated and before as of date amounts
 equip_hrs          number,
 prj_brdn_cost      number,
 sch_start_date     date,
 sch_end_date       date,
 pstart_date        date,
 pend_date          date,
 as_of_date         date,
 parent_task_id     number,
 tlbr_hrs_baod      number,     -- Stores the sum of lbr hours prior to as of date period
 teqp_hrs_baod      number,
 tpbc_hrs_baod      number,
 cur_lbr_hrs        number,     -- Stores the current period amount.
 cur_eqp_hrs        number,
 cur_pbc            number
 );

TYPE bcws_hash_tbl IS TABLE OF bcws_rec_type
      INDEX BY varchar2(17);

l_bcws_hash_tbl bcws_hash_tbl;

l_prv_bcws_project_id             NUMBER := -1;
l_prv_bcws_struc_ver_id           NUMBER := -1;
l_ovr_task_id                         NUMBER := -1;
-- End Changes for bug 6664716


FUNCTION GET_LATEST_TASK_VER_ID (p_project_id      IN  NUMBER,
                                 p_task_id         IN  NUMBER) return NUMBER IS
    x_task_version_id    NUMBER;
BEGIN
    select ppev1.element_version_id
      into x_task_version_id
      from pa_proj_element_versions ppev1,
           pa_proj_element_versions ppev2,
           pa_proj_elem_ver_structure ppevs,
           pa_structure_types pst,
           pa_proj_structure_types ppst
     where ppevs.project_id = p_project_id
       and ppevs.latest_eff_published_flag = 'Y'
       and ppevs.element_version_id = ppev1.parent_structure_version_id
       and ppevs.element_version_id = ppev2.element_version_id
       and ppev2.proj_element_id = ppst.proj_element_id
       and ppst.structure_type_id = pst.structure_type_id
       and pst.structure_type_class_code = 'WORKPLAN'
       and ppev1.proj_element_id = p_task_id
       and ppev1.object_type = 'PA_TASKS';
    return x_task_version_id;
exception when others then
     return -999;
END;

FUNCTION PROGRESS_RECORD_EXISTS(p_element_version_id IN  NUMBER,
                                p_object_type        IN  VARCHAR2
                ,p_project_id        IN  NUMBER -- Fixed bug # 3688901.
                ) return VARCHAR2 IS
    x_record_exists  VARCHAR2(1);
BEGIN
    select 'Y'
      into x_record_exists
      from pa_percent_completes
     where object_version_id = p_element_version_id
       and object_type = p_object_type
       and published_flag = 'Y'
       and project_id = p_project_id; -- Fixed bug # 3688901

    return x_record_exists;
exception when no_data_found then
     return 'N';
when others then
     return 'Y';
END;

FUNCTION GET_LATEST_STRUCTURE_VER_ID (p_project_id      IN  NUMBER) return NUMBER IS
    x_structure_version_id    NUMBER;
BEGIN
    select ppevs.element_version_id
      into x_structure_version_id
      from pa_proj_elem_ver_structure ppevs,
           pa_proj_element_versions ppev,
           pa_structure_types pst,
           pa_proj_structure_types ppst
     where ppevs.project_id = p_project_id
       and ppevs.latest_eff_published_flag = 'Y'
       and ppevs.element_version_id = ppev.element_version_id
       and ppev.proj_element_id = ppst.proj_element_id
       and ppst.structure_type_id = pst.structure_type_id
       and pst.structure_type_class_code = 'WORKPLAN';
    return x_structure_version_id;
exception when others then
     return -999;
END;

FUNCTION isUserProjectManager(p_user_id       IN   NUMBER,
                              p_project_id    IN   NUMBER) return VARCHAR2 is
    l_person_id  number;
    x_val        varchar2(1) := 'N';
BEGIN
    l_person_id := pa_utils.getempidfromuser(p_user_id);

    select 'Y'
      into x_val
     from pa_project_parties
    where project_id = p_project_id
      and resource_source_id = l_person_id
      and project_role_id = 1
      and trunc(sysdate) between trunc(start_date_active) and trunc(nvl(end_date_active,sysdate)); ----- Project Manager

    return x_val;

exception when others then
    return 'N';

END;

-- FPM Dev CR 3 : Not used
FUNCTION Get_Working_Progress_Id(p_project_id    IN   NUMBER,
                                 p_task_id       IN   NUMBER) return NUMBER is
    l_percent_complete_id  number;
BEGIN

    select percent_complete_id
      into l_percent_complete_id
     from pa_percent_completes
    where project_id = p_project_id
      and task_id = p_task_id
      and current_flag = 'N'
      and published_flag = 'N';

    return l_percent_complete_id;

exception when others then
    return -999;

END;

PROCEDURE UPDATE_TASK_PROG_REQ_DATE(p_commit        in varchar2 := FND_API.G_TRUE,
                                  p_object_id      in number,
                                  p_object_type    in varchar2,
                                  x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                  x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_msg_data       out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
  CURSOR get_setup_info
  IS SELECT
         object_id, object_type,  reporting_cycle_id,
         next_reporting_date, record_version_number,
         initial_progress_status, final_progress_status,
         rollup_progress_status, object_page_layout_id
     FROM pa_object_page_layouts popl
     WHERE
         page_type_code = 'TPR'
     AND page_id = -99
     AND object_id = p_object_id
     AND object_type = p_object_type;

 l_object_id                  number;
 l_object_type                varchar2(30);
 l_report_cycle_id            number;
 l_next_reporting_date        date;
 l_record_version_number      number;
 l_initial_progress_status    varchar2(30);
 l_final_progress_status      varchar2(30);
 l_rollup_progress_status     varchar2(1);
 l_object_page_layout_id      number;
 x_next_reporting_date        date;
 x_report_end_date            date;
BEGIN
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           OPEN get_setup_info;
           FETCH get_setup_info INTO l_object_id, l_object_type, l_report_cycle_id,l_next_reporting_date, l_record_version_number, l_initial_progress_status, l_final_progress_status, l_rollup_progress_status, l_object_page_layout_id;
           CLOSE get_setup_info;

           IF (l_report_cycle_id IS NOT null) then
            if (l_next_reporting_date is null) then
                l_next_reporting_date := trunc(sysdate);
            end if;

            x_next_reporting_date := PA_Billing_Cycles_Pkg.Get_Billing_Date(l_Object_Id
                                                        ,l_next_reporting_date+1
                                                        ,l_Report_Cycle_Id
                                                        ,sysdate
                                                        ,l_next_reporting_date);

             pa_progress_report_pkg.update_object_page_layout_row
             (
              p_object_id                 => l_OBJECT_ID ,
              p_object_Type               => l_OBJECT_TYPE ,
              p_page_id                   => -99 ,
              p_page_type_code            => 'TPR' ,
              p_approval_required         => null ,
              p_reporting_cycle_id        => l_report_cycle_id ,
              p_reporting_offset_days     => null,
              p_next_reporting_date       => x_next_reporting_date ,
              p_reminder_days             => null ,
              p_reminder_days_type        => null ,
              p_initial_progress_status   => l_initial_progress_status,
              p_final_progress_status     => l_final_progress_status,
              p_rollup_progress_status    => l_rollup_progress_status,
              P_REPORT_TYPE_ID            => null,
              P_APPROVER_SOURCE_ID        => null,
              P_APPROVER_SOURCE_TYPE      => null,
              P_EFFECTIVE_FROM            => null,
              P_EFFECTIVE_TO              => null,
              p_object_page_layout_id     => l_object_page_layout_id,
              p_record_version_number     => l_record_version_number,
              x_return_status             => x_return_status ,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data
              );
           END IF;

  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;
-- Introduced Exception Block : 4537865
EXCEPTION
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_PROGRESS_UTILS'
                     ,p_procedure_name  => 'UPDATE_TASK_PROG_REQ_DATE'
             ,p_error_text => x_msg_data );

     RAISE;
END UPDATE_TASK_PROG_REQ_DATE;

PROCEDURE adjust_reminder_date(
        p_commit                         in varchar2 := FND_API.G_TRUE
       ,p_project_id                     IN  NUMBER
       ,x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count                      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data                       OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_reporting_date DATE;
  l_offset_days NUMBER;
  l_cycle_id NUMBER;
  l_sysdate DATE := TRUNC(sysdate);
BEGIN
  -- 4537865 Should x_return_status be initialized to Success here  ?
  -- If it is initialized Commit will happen here in this API,which might
  -- wash-out all previously established savepoints. Not sure,whether to do this fix or not

  SELECT next_reporting_date, reporting_cycle_id, report_offset_days
  INTO l_reporting_date, l_cycle_id, l_offset_days
  FROM pa_object_page_layouts
  WHERE object_id = p_project_id
    AND object_type = 'PA_PROJECTS'
    AND page_type_code = 'TPR';

    if ( l_reporting_date is not null and l_reporting_date < l_sysdate
            and l_cycle_id is not null ) then
        while (l_reporting_date < l_sysdate) Loop
            l_reporting_date := PA_Billing_Cycles_Pkg.Get_Next_Billing_Date(
                            p_project_id
                            ,l_reporting_date
                            ,l_cycle_id
                            ,l_offset_days
                            ,l_reporting_date
                            ,l_reporting_date-1);

        End Loop;

        UPDATE pa_object_page_layouts
            SET next_reporting_date = l_reporting_date
            WHERE object_id = p_project_id
            AND object_type = 'PA_PROJECTS'
            AND page_type_code = 'TPR';
        IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
            COMMIT;
        end if;
    End If;

EXCEPTION
    When OTHERS then

     -- 4537865
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := 1 ;
     x_msg_data := SUBSTRB(SQLERRM,1,240);
         Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_PROGRESS_UTILS'
                    , p_procedure_name  => 'adjust_reminder_date'
                    , p_error_text      => x_msg_data);
    -- 4537865
    RAISE;
END adjust_reminder_date;

FUNCTION PROJ_TASK_PROG_EXISTS(p_project_id IN  NUMBER,
                          p_task_id    IN  NUMBER) return VARCHAR2 IS
    x_record_exists  VARCHAR2(1);
BEGIN
    select 'Y'
      into x_record_exists
      from pa_percent_completes
     where project_id = p_project_id
       and task_id = decode(p_task_id,0,task_id,p_task_id)
       and published_flag = 'Y';

    return x_record_exists;
exception when no_data_found then
     return 'N';
when others then
     return 'Y';
END;

FUNCTION GET_PRIOR_PERCENT_COMPLETE(p_project_id IN  NUMBER,
                                    p_task_id    IN  NUMBER,
                                    p_as_of_date IN  DATE) return NUMBER IS
    prior_pc  NUMBER;
    /*--Added by rtarway, bug 4324504
    CURSOR c_get_prior_percent_complete(l_task_id NUMBER, l_project_id NUMBER, l_as_of_date DATE) IS
        select  completed_percentage
    from    pa_percent_completes
    where   project_id = l_project_id
    and task_id = l_task_id
    and published_flag = 'Y'
    and structure_type = 'WORKPLAN'
    and date_computed  < l_as_of_date
    and object_type = 'PA_TASKS'
    order by date_computed desc;*/

    ---- bug 5042445
   CURSOR c_get_prior_percent_complete(l_task_id NUMBER, l_project_id NUMBER, l_as_of_date DATE) IS
   select nvl(completed_percentage,eff_rollup_percent_comp)
     from pa_progress_rollup
    where project_id = l_project_id
    and object_id = l_task_id
    and object_type in ('PA_STRUCTURES', 'PA_TASKS')
    and structure_Type = 'WORKPLAN'
    and structure_version_id is null
    and as_of_date < l_as_of_date
    order by as_of_date desc;
BEGIN
    --Commented by rtarway, bug 4324504
    /*select completed_percentage
      into prior_pc
      from pa_percent_completes
     where project_id = p_project_id
       and task_id = p_task_id
       and published_flag = 'Y'
       and structure_type = 'WORKPLAN' -- FPM Dev CR 3
       and date_computed <= p_as_of_date;*/

     OPEN  c_get_prior_percent_complete(p_task_id, p_project_id, trunc(p_as_of_date));
     FETCH c_get_prior_percent_complete  INTO prior_pc;

     IF (c_get_prior_percent_complete%NOTFOUND) THEN
        prior_pc := 0 ;
     END IF;

     CLOSE c_get_prior_percent_complete;

     return prior_pc;

exception when others then
     return 0;
END;


FUNCTION GET_LATEST_AS_OF_DATE(
    p_task_id      NUMBER
    ,p_project_id   NUMBER := null -- FPM Development Bug 3420093
    ,p_object_id   NUMBER := null -- FPM Development Bug 3420093
    , p_object_type VARCHAR2 := 'PA_TASKS'-- FPM Development Bug 3420093
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
    ) RETURN DATE IS

--Added for performance improvements bug 2679612
  CURSOR cur_proj_elem
  IS
    SELECT project_id
     FROM pa_proj_elements
    WHERE proj_element_id = p_task_id;
    l_project_id          NUMBER;
--Added for performance improvements bug 2679612

  CURSOR cur_ppc(c_project_id NUMBER )
  IS
    SELECT date_computed
      FROM pa_percent_completes
     WHERE object_id = decode(p_object_id, null, p_task_id, p_object_id)
       AND project_id = c_project_id
       and object_type = p_object_type
       AND current_flag = 'Y'
       AND published_flag = 'Y'
       AND structure_type = p_structure_type
       AND NVL(task_id, -1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id, NVL(task_id, -1)), NVL(p_task_id,p_object_id)) /* Amit : Modified for IB4 Progress CR. */
       ;
  l_as_of_date  DATE;
BEGIN

     IF p_project_id is NULL THEN
--Added for performance improvements bug 2679612
        OPEN cur_proj_elem;
        FETCH cur_proj_elem INTO l_project_id;
        CLOSE cur_proj_elem;
     ELSE
        l_project_id := p_project_id;
     END IF;

--Added for performance improvements bug 2679612

     OPEN cur_ppc(l_project_id);
     FETCH cur_ppc INTO l_as_of_date;
     CLOSE cur_ppc;
     RETURN l_as_of_date ;

exception when others then
     return null;

END GET_LATEST_AS_OF_DATE;

function    Get_AS_OF_DATE (
                X_Project_ID            IN  Number,
                X_Project_Start_Date    IN  Date    default NULL,
                X_Billing_Cycle_ID      IN  Number  default NULL,
                X_Billing_Offset_Days   IN  Number  default NULL,
                X_Bill_Thru_Date        IN  Date    default NULL,
                X_Last_Bill_Thru_Date   IN  Date    default NULL
                                )   RETURN DATE
IS

return_number            NUMBER;
previous_return_date     DATE;
next_return_date         DATE;
return_date              DATE;

date_count         NUMBER := 0;
temp_index         NUMBER := 0;

future_date_record NUMBER := 0;
prev_return_date Date;

BEGIN

if PA_PROGRESS_UTILS.x_bill_thru_date is null then
    PA_PROGRESS_UTILS.x_bill_thru_date := x_project_start_date;
end if;

if PA_PROGRESS_UTILS.project_id <> X_Project_ID OR
   i >= 10 then

  --Initializing variables
  PA_PROGRESS_UTILS.l_return_date.delete;
  PA_PROGRESS_UTILS.project_id            := X_Project_ID;
  PA_PROGRESS_UTILS.previous_record_count := 0;
  PA_PROGRESS_UTILS.next_record_count     := 0;
  PA_PROGRESS_UTILS.previous_record_index := 0;
  PA_PROGRESS_UTILS.current_index         := 0;
  PA_PROGRESS_UTILS.x_bill_thru_date      := X_Last_Bill_Thru_Date;
  PA_PROGRESS_UTILS.i                     := 0;

--------my_error_msg( 'X_Billing_Cycle_ID ' || X_Billing_Cycle_ID );

 while TRUE loop

 prev_return_date := return_date;

  IF X_Billing_Cycle_ID IS NOT NULL THEN
   return_date := PA_Billing_Cycles_Pkg.Get_Next_Billing_Date
                    (X_Project_ID          => X_Project_ID,
                     X_Project_Start_Date  => X_Project_Start_Date,
                     X_Billing_Cycle_ID    => X_Billing_Cycle_ID,
                     X_Billing_Offset_Days => X_Billing_Offset_Days,
                     X_Bill_Thru_Date      => X_Bill_Thru_Date,
                     X_Last_Bill_Thru_Date => PA_PROGRESS_UTILS.x_bill_thru_date);
  ELSE
   return_date := PA_PROGRESS_UTILS.x_bill_thru_date + 1;
  END IF;

  PA_PROGRESS_UTILS.x_bill_thru_date := return_date;

  IF  ((trunc(sysdate) - trunc(return_date) <= 5) OR (trunc(return_date) >= trunc(sysdate))) then

   date_count := date_count + 1;


   PA_PROGRESS_UTILS.l_return_date.extend(1);
   PA_PROGRESS_UTILS.l_return_date(date_count) := to_char(return_date, 'MM-DD-RR');

  END IF;



   if trunc(return_date) >= trunc(sysdate) then

      if PA_PROGRESS_UTILS.current_index = 0 then
         PA_PROGRESS_UTILS.current_index := date_count;
         PA_PROGRESS_UTILS.previous_record_index := PA_PROGRESS_UTILS.current_index - 5;
         IF PA_PROGRESS_UTILS.previous_record_index <= 0
         THEN
            PA_PROGRESS_UTILS.previous_record_index := 1;
         END IF;
      end if;

      future_date_record := future_date_record + 1;

   end if;

   if future_date_record = 5 then
      exit;
   end if;

   if prev_return_date = return_date then
      exit;
   end if;

end loop;

end if;


if  PA_PROGRESS_UTILS.previous_record_count < 5 AND
    PA_PROGRESS_UTILS.previous_record_index > 0 AND
    PA_PROGRESS_UTILS.previous_record_index < PA_PROGRESS_UTILS.current_index
then
     if (PA_PROGRESS_UTILS.l_return_date.exists(PA_PROGRESS_UTILS.previous_record_index)) then--If Condition Added by rtarway for BUG4111124
          return_date := to_date(PA_PROGRESS_UTILS.l_return_date(PA_PROGRESS_UTILS.previous_record_index), 'MM-DD-RR');

          PA_PROGRESS_UTILS.previous_record_count :=  PA_PROGRESS_UTILS.previous_record_count + 1;
          PA_PROGRESS_UTILS.previous_record_index :=  PA_PROGRESS_UTILS.previous_record_index + 1;
     end if;

elsif  PA_PROGRESS_UTILS.next_record_count < 5 then

    temp_index := PA_PROGRESS_UTILS.current_index+PA_PROGRESS_UTILS.next_record_count;

    if (PA_PROGRESS_UTILS.l_return_date.exists(temp_index)) then --If Condition Added by rtarway for BUG4111124
         return_date := to_date(PA_PROGRESS_UTILS.l_return_date(temp_index), 'MM-DD-RR');

         PA_PROGRESS_UTILS.next_record_count := PA_PROGRESS_UTILS.next_record_count + 1;
    end if;

end if;

RETURN (return_date);

EXCEPTION
    When OTHERS then
    RAISE;
END Get_AS_OF_DATE;


FUNCTION as_of_date(
        X_Project_ID                    IN      NUMBER                          ,
        X_Object_id                     IN      NUMBER                          ,
        X_Billing_Cycle_ID              IN      NUMBER  DEFAULT NULL            ,
        X_Object_type                   IN      VARCHAR2  DEFAULT 'PA_TASKS'    ,-- FPM Development Bug 3420093
        X_structure_type                IN      VARCHAR2  DEFAULT 'WORKPLAN'    ,-- FPM Development Bug 3420093
    X_proj_element_id               IN      NUMBER    := null   /* Amit : Modified for IB4 Progress CR. */
          ) RETURN DATE IS

-- Bug  3974627 : Commented
/*
   CURSOR cur_pa_ppc
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = X_Project_ID
        AND object_id = x_object_id
        AND object_type = x_object_type
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND structure_type = x_structure_type
    AND NVL(task_id,-1) = DECODE(X_Object_type, 'PA_DELIVERABLES', NVL(X_proj_element_id, NVL(task_id,-1)), NVL(X_proj_element_id, X_Object_id))
    ;
*/

-- Bug  3974627 : Added Cursors cur_pa_ppc_str_task, cur_pa_ppc_asgn, cur_pa_ppc_dlv
   CURSOR cur_pa_ppc_str_task
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = X_Project_ID
        AND object_id = x_object_id
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND object_type = x_object_type
        AND structure_type = X_structure_type
    AND task_id = NVL(X_proj_element_id,x_object_id)
    ;

   CURSOR cur_pa_ppc_asgn
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = X_Project_ID
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND ((object_type = 'PA_ASSIGNMENTS' and object_id = x_object_id)
             or (object_type = 'PA_TASKS' and object_id = X_proj_element_id))
        AND structure_type = X_structure_type
    AND task_id = X_proj_element_id
    ;



   CURSOR cur_dlv_get_asso_task(c_del_elem_id NUMBER)
   IS
          SELECT por.object_id_from2
          FROM pa_object_relationships por
          WHERE
          por.object_type_to = 'PA_DELIVERABLES'
      AND por.relationship_subtype IN  ('STRUCTURE_TO_DELIVERABLE', 'TASK_TO_DELIVERABLE')
      AND por.relationship_type = 'A'
      AND por.object_id_to2 = c_del_elem_id
      ;
   l_del_task_id NUMBER;

   CURSOR cur_pa_ppc_dlv_notask
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = X_Project_ID
        AND object_id = x_object_id
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND object_type = 'PA_DELIVERABLES'
        AND structure_type = X_structure_type
    AND NVL(task_id, -1) = NVL(X_proj_element_id, NVL(task_id, -1))
    ;

   CURSOR cur_pa_ppc_dlv_task(c_task_id NUMBER)
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = X_Project_ID
        AND ((object_id = x_object_id and object_type = 'PA_DELIVERABLES') or
            (object_id = c_task_id and object_type = 'PA_TASKS'))
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND structure_type = X_structure_type
        ;



   CURSOR cur_pa_proj
   IS
     SELECT start_date, completion_date
       from pa_projects_all
      where project_id = x_project_id;

   l_return_date DATE;

   CURSOR c_get_max_rollup_dt IS
   SELECT max(as_of_date)
   FROM pa_progress_rollup
   where project_id = X_Project_ID
   and object_type IN ('PA_TASKS', 'PA_STRUCTURES')
   and object_id = x_object_id
   and structure_type = 'WORKPLAN'
   and structure_version_id is null;

   l_cycle_type     varchar2(30);
   l_value1         number;
   cursor get_cycle_info is
   Select Billing_Cycle_Type, Billing_Value1
   From    PA_Billing_Cycles
   Where   Billing_Cycle_ID = X_Billing_Cycle_ID;

begin


     IF PA_PROGRESS_UTILS.project_id <> X_Project_ID OR i >= 10 then

        -- Bug  3974627 Commented
        --OPEN cur_pa_ppc;
        --FETCH cur_pa_ppc INTO PA_PROGRESS_UTILS.l_last_progress_date;
        --CLOSE cur_pa_ppc;
     -- 4535784 Begin
     -- To Show 30 dates in case rollup records exists after 5 cycle dates
     -- Note that j_task is checked against 6 because each run is for 10 in which we get 5 future date and 5 null date(previous date implementaion, obsoleted now)
     -- So we need to get 60 rows for 30 dates
     IF ((x_object_type IN ('PA_TASKS', 'PA_STRUCTURES') and X_structure_type = 'WORKPLAN') and (j_task >=6 OR g_task_id <> x_object_id or PA_PROGRESS_UTILS.project_id <> X_Project_ID)) THEN
    j_task := 0;
    g_task_id := x_object_id;
    OPEN c_get_max_rollup_dt;
    FETCH c_get_max_rollup_dt INTO g_max_rollup_dt;
    CLOSE c_get_max_rollup_dt;
     END IF;
     -- 4535784 End
        -- Bug  3974627 Begin
    IF x_object_type IN ('PA_TASKS', 'PA_STRUCTURES') THEN
            -- 4535784 Begin
        j_task := j_task+1;
        IF j_task > 1 AND X_structure_type = 'WORKPLAN' and g_task_id = x_object_id AND trunc(nvl(g_max_rollup_dt,sysdate)) > trunc(PA_PROGRESS_UTILS.x_bill_thru_date) THEN
            PA_PROGRESS_UTILS.l_last_progress_date := PA_PROGRESS_UTILS.x_bill_thru_date;
        ELSE
            IF j_task =1 THEN
                OPEN cur_pa_ppc_str_task;
                FETCH cur_pa_ppc_str_task INTO PA_PROGRESS_UTILS.l_last_progress_date;
                CLOSE cur_pa_ppc_str_task;
            ELSE
                return null; -- This make sure that no extra processing is done when max date is reached
            END IF;
        END IF;
            -- 4535784 End
    ELSIF x_object_type = 'PA_ASSIGNMENTS' THEN
        OPEN cur_pa_ppc_asgn;
        FETCH cur_pa_ppc_asgn INTO PA_PROGRESS_UTILS.l_last_progress_date;
        CLOSE cur_pa_ppc_asgn;
    ELSIF x_object_type = 'PA_DELIVERABLES' THEN
            OPEN cur_dlv_get_asso_task(x_object_id);
        FETCH cur_dlv_get_asso_task INTO l_del_task_id;
        CLOSE cur_dlv_get_asso_task;

                if l_del_task_id is not null then
                   OPEN cur_pa_ppc_dlv_task(l_del_task_id);
           FETCH cur_pa_ppc_dlv_task INTO PA_PROGRESS_UTILS.l_last_progress_date;
           CLOSE cur_pa_ppc_dlv_task;
                else
                   OPEN cur_pa_ppc_dlv_notask;
                   FETCH cur_pa_ppc_dlv_notask INTO PA_PROGRESS_UTILS.l_last_progress_date;
                   CLOSE cur_pa_ppc_dlv_notask;
                end if;
    END IF;
    -- Bug  3974627 End


        OPEN cur_pa_proj;
        FETCH cur_pa_proj INTO X_project_start_date,X_project_finish_date;
        CLOSE cur_pa_proj;

        IF PA_PROGRESS_UTILS.l_last_progress_date IS NULL
        THEN
--           PA_PROGRESS_UTILS.l_last_progress_date :=  NVL( X_project_start_date,TRUNC(SYSDATE));
             PA_PROGRESS_UTILS.l_last_progress_date := TRUNC(SYSDATE)-1;  --bug 2641630
        END IF;

        --- as of date to remain same if in future 5226910(5212999)
        if (PA_PROGRESS_UTILS.l_last_progress_date >= trunc(sysdate)) then
           open get_cycle_info;
           fetch get_cycle_info into l_cycle_type, l_value1;
           close get_cycle_info;
           If l_Cycle_Type = 'BILLING CYCLE DAYS' Then
              PA_PROGRESS_UTILS.l_Last_Bill_Thru_Date := PA_PROGRESS_UTILS.l_last_progress_date -l_value1;
           else
              PA_PROGRESS_UTILS.l_Last_Bill_Thru_Date := PA_PROGRESS_UTILS.l_last_progress_date -1;
           End if;
        else
           PA_PROGRESS_UTILS.l_Last_Bill_Thru_Date := PA_PROGRESS_UTILS.l_last_progress_date;
        end if;
     END IF;
---     IF X_Billing_Cycle_ID IS NOT NULL
---     THEN

         l_return_date := Get_AS_OF_DATE (
                 X_Project_ID            => x_project_id
                ,X_Project_Start_Date    => PA_PROGRESS_UTILS.l_last_progress_date
                ,X_Billing_Cycle_ID      => X_Billing_Cycle_ID
                ,X_Billing_Offset_Days   => 0
                ,X_Bill_Thru_Date        => X_project_finish_date
                ,X_Last_Bill_Thru_Date   => PA_PROGRESS_UTILS.l_Last_Bill_Thru_Date
             );
---     END IF;
     i := i + 1;

     RETURN ( l_return_date );

end as_of_date;

FUNCTION get_next_ppc_id RETURN NUMBER IS
   l_return_ppc_id NUMBER;
BEGIN
        select PA_PERCENT_COMPLETES_S.nextval
        into l_return_ppc_id
        from dual;

        RETURN l_return_ppc_id;
END get_next_ppc_id;


-- FPM Development Bug 3420093 : Added p_object_type

FUNCTION CHECK_VALID_AS_OF_DATE(p_as_of_date IN DATE
    , p_project_id IN NUMBER
    , p_object_id NUMBER
    , p_object_type VARCHAR2 := 'PA_TASKS'
    , p_proj_element_id  IN      NUMBER    := null  /* Amit : Modified for IB4 Progress CR. */)
RETURN VARCHAR2 IS


--  CURSOR as_of_dates_csr
--  IS
--  SELECT 'Y'
--  FROM DUAL
--  WHERE trunc(p_as_of_date) IN
--    (SELECT trunc(as_of_date)
--     FROM PA_PROG_AS_OF_DATES
--     WHERE project_id = p_project_id
--       AND proj_element_id = p_object_id
--       AND object_id = p_object_id
--       AND object_type = p_object_type
--       AND rownum < 11);

--  l_dummy    VARCHAR2(1);
  l_dummy    Date ; -- For performance improvement used Minus operator

/* -- FPM Dev CR 3
CURSOR as_of_dates_csr
  IS
  SELECT trunc(p_as_of_date) FROM DUAL
  MINUS
  SELECT
    trunc(as_of_date)
     FROM PA_PROG_AS_OF_DATES
     WHERE project_id = p_project_id
--       AND proj_element_id = p_object_id
       AND object_id = p_object_id
       AND object_type = p_object_type
       AND rownum < 11;*/

-- FPM Dev CR 3 : Added two new cursors. Now we are not relying on pa_prog_as_of_dates view.
  CURSOR as_of_dates_task_dlvr_csr
  IS
  SELECT trunc(p_as_of_date) FROM DUAL
  MINUS
  SELECT PA_PROGRESS_UTILS.AS_OF_DATE(ppe.project_id,  ppe.proj_element_id, ppp.progress_cycle_id, ppe.object_type, 'WORKPLAN', p_proj_element_id/* Amit : Modified for IB4 Progress CR. */) as_of_date
  from  pa_project_statuses po, pa_proj_progress_attr ppp, pa_proj_elements ppe -- Bug 4535784 Changed from pa_resource_types to pa_project_statuses
  where ppe.project_id = ppp.project_id(+)
  AND ppp.structure_type (+) = 'WORKPLAN'
  and ppe.project_id= p_project_id
  and ppe.proj_element_id = p_object_id
  and ppe.object_type = p_object_type
  and ((ppe.object_type in ('PA_TASKS', 'PA_STRUCTURES') and rownum <61) or (ppe.object_type = 'PA_DELIVERABLES' and rownum <11)) -- Bug 4535784
  --and rownum <11
  ;


  /* Modified for IB4 Progress CR. */

  CURSOR as_of_dates_assgn_csr
  IS
  SELECT trunc(p_as_of_date) FROM DUAL
  MINUS
  SELECT PA_PROGRESS_UTILS.AS_OF_DATE(ppe.project_id,  ppe.resource_list_member_id, ppp.progress_cycle_id, 'PA_ASSIGNMENTS', 'WORKPLAN', p_proj_element_id/* Amit : Modified for IB4 Progress CR. */) as_of_date
  from  pa_resource_types po, pa_proj_progress_attr ppp, PA_TASK_ASSIGNMENTS_V ppe
  where ppe.project_id = ppp.project_id(+)
  AND ppp.structure_type (+) = 'WORKPLAN'
  and ppe.project_id= p_project_id
  and ppe.resource_list_member_id = p_object_id /* Modified for IB4 Progress CR. */
  and ppe.task_id = p_proj_element_id /* Amit : Modified for IB4 Progress CR. */
  and rownum <11;

BEGIN
  /* FPM Dev CR 3
  OPEN as_of_dates_csr;
  FETCH as_of_dates_csr INTO l_dummy;
--  if as_of_dates_csr%NOTFOUND then
  ----my_error_msg( 'Project '||p_project_id);
  ----my_error_msg( 'Invalid ');
  --  return 'N';
  --end if;
  ------my_error_msg( 'Project '||p_project_id);
  ------my_error_msg( 'valid ');
  --return 'Y';
  CLOSE as_of_dates_csr;
  */
  -- FPM Dev CR 3
  IF p_object_type = 'PA_ASSIGNMENTS' THEN
    OPEN as_of_dates_assgn_csr;
    FETCH as_of_dates_assgn_csr INTO l_dummy;
    CLOSE as_of_dates_assgn_csr;
  ELSE
    OPEN as_of_dates_task_dlvr_csr;
    FETCH as_of_dates_task_dlvr_csr INTO l_dummy;
    CLOSE as_of_dates_task_dlvr_csr;
  END IF;

  if l_dummy is null then
        return 'Y';
  else
        return 'N';
  end if;
END CHECK_VALID_AS_OF_DATE;

FUNCTION Calc_base_percent(
 p_task_id     NUMBER,
 p_incr_work_qty NUMBER,
 p_cuml_work_qty NUMBER,
 p_est_remaining_effort NUMBER
) RETURN NUMBER IS

/* Replacing this sql with the following sqls: for bug 2679612
 CURSOR cur_pa_task_prg
 IS
   SELECT PLANNED_WORK_QUANTITY,
          WQ_ACTUAL_ENTRY_CODE
     FROM pa_latest_proj_task_prog_v
    WHERE task_id = p_task_id;
*/

--Bug fix 2679612
  CURSOR cur_pa_task_prg1
  IS
    SELECT WQ_PLANNED_QUANTITY
      FROM pa_proj_elements ppe,
           pa_proj_element_versions ppev,
           pa_proj_elem_ver_schedule ppevsh
     WHERE ppe.project_id = ppev.project_id
       AND ppe.proj_element_id = p_task_id
       AND ppev.proj_element_id = ppe.proj_element_id
       AND ppev.element_version_id = ppevsh.element_version_id
       AND ppev.project_id = ppevsh.project_id
       AND ppev.parent_structure_version_id = PA_PROJ_ELEMENTS_UTILS.latest_published_ver_id(ppe.project_id, 'WORKPLAN');

  CURSOR cur_pa_task_prg2
  IS
    SELECT nvl(ppe.WQ_ACTUAL_ENTRY_CODE,ptt.ACTUAL_WQ_ENTRY_CODE)
     FROM pa_proj_elements ppe, pa_task_types ptt
    WHERE ppe.type_id = ptt.task_type_id(+)
      AND ptt.object_type = 'PA_TASKS' /* bug 3279978 FP M Enhancement */
      AND ppe.proj_element_id = p_task_id ;

--Bug fix 2679612


 l_return_value   NUMBER := 0;
 l_WQ_ACTUAL_ENTRY_CODE        VARCHAR2(30);
 l_planned_work_quantity       NUMBER;
 l_last_cumulative_wrk_qty     NUMBER;
BEGIN

    OPEN cur_pa_task_prg1;
    FETCH cur_pa_task_prg1 INTO l_planned_work_quantity;
    CLOSE cur_pa_task_prg1;

-- Bug fix 2740446  cannot divide by 0
    if (nvl(l_planned_work_quantity,0) = 0) then
        return 0;
    end if;

--Bug fix 2679612
    OPEN cur_pa_task_prg2;
    FETCH cur_pa_task_prg2 INTO l_WQ_ACTUAL_ENTRY_CODE;
    CLOSE cur_pa_task_prg2;
--Bug fix 2679612


    IF l_WQ_ACTUAL_ENTRY_CODE = 'CUMULATIVE'
    THEN
       l_return_value := ( ( NVL(p_cuml_work_qty,0)/l_planned_work_quantity ) * 100 );
    ELSE

--bugfix :2670679
/*       OPEN cur_cumltv;
       FETCH cur_cumltv INTO l_last_cumulative_wrk_qty;
       if cur_cumltv%notfound then
           l_last_cumulative_wrk_qty := 0;
       end if;
       CLOSE cur_cumltv;
       l_return_value := ( ( ( l_last_cumulative_wrk_qty + p_incr_work_qty ) /l_planned_work_quantity) * 100 );
*/
       l_return_value := ( ( ( NVL(p_cuml_work_qty,0) + NVL(p_incr_work_qty,0) ) /l_planned_work_quantity) * 100 );
    END IF;
    if l_return_value > 100 then
       return 100;
    else
       return nvl(l_return_value,0);
    end if;
END Calc_base_percent;

-- 4392189 Phase 2: This method is not used anywhere
/*
PROCEDURE get_rollup_attrs(
 p_task_id                           NUMBER,
 p_as_of_date                        DATE,
 x_EFF_ROLLUP_PROG_STAT_CODE         OUT VARCHAR2,
 x_EFF_ROLLUP_PROG_STAT_NAME         OUT VARCHAR2,
 x_ESTIMATED_REMAINING_EFFORT        OUT NUMBER,
 x_BASE_PERCENT_COMPLETE             OUT NUMBER,
 x_EFF_ROLLUP_PERCENT_COMP           OUT NUMBER,
 x_ESTIMATED_START_DATE              OUT DATE,
 x_ESTIMATED_FINISH_DATE             OUT DATE,
 x_ACTUAL_START_DATE                 OUT DATE,
 x_ACTUAL_FINISH_DATE                OUT DATE,
 x_status_icon_ind                   OUT VARCHAR2,
 x_status_icon_active_ind            OUT VARCHAR2
) IS


--Added for performance improvements bug 2679612
  CURSOR cur_proj_elem
  IS
    SELECT project_id
     FROM pa_proj_elements
    WHERE proj_element_id = p_task_id;
    l_project_id          NUMBER;
--Added for performance improvements bug 2679612

  CURSOR cur_pa_prg_rollup( c_project_id NUMBER )
  IS
    SELECT EFF_ROLLUP_PROG_STAT_CODE,
           pps.project_status_name,
           ESTIMATED_REMAINING_EFFORT,
           BASE_PERCENT_COMPLETE, EFF_ROLLUP_PERCENT_COMP,
           ESTIMATED_START_DATE, ESTIMATED_FINISH_DATE,
           ACTUAL_START_DATE, ACTUAL_FINISH_DATE,
           pps.status_icon_ind, pps.status_icon_active_ind
      FROM pa_progress_rollup ppr, pa_project_statuses pps
     WHERE object_id = p_task_id
       AND project_id = l_project_id
       AND ppr.eff_rollup_prog_stat_code = pps.project_status_code(+)
       AND as_of_date = ( SELECT max( as_of_date ) from pa_progress_rollup
                            WHERE object_id = p_task_id and as_of_date <= p_as_of_date
                             AND project_id = l_project_id );
BEGIN
--Added for performance improvements bug 2679612
     OPEN cur_proj_elem;
     FETCH cur_proj_elem INTO l_project_id;
     CLOSE cur_proj_elem;
--Added for performance improvements bug 2679612

     OPEN cur_pa_prg_rollup(l_project_id);
     FETCH cur_pa_prg_rollup INTO x_EFF_ROLLUP_PROG_STAT_CODE, x_EFF_ROLLUP_PROG_STAT_NAME,
           x_ESTIMATED_REMAINING_EFFORT,
           x_BASE_PERCENT_COMPLETE, x_EFF_ROLLUP_PERCENT_COMP,
           x_ESTIMATED_START_DATE, x_ESTIMATED_FINISH_DATE,
           x_ACTUAL_START_DATE, x_ACTUAL_FINISH_DATE,
           x_status_icon_ind, x_status_icon_active_ind;
           ----my_error_msg( 'x_BASE_PERCENT_COMPLETE '|| x_BASE_PERCENT_COMPLETE );
           ----my_error_msg( 'x_EFF_ROLLUP_PERCENT_COMP '||x_EFF_ROLLUP_PERCENT_COMP );

     CLOSE cur_pa_prg_rollup;

END get_rollup_attrs;
*/
FUNCTION get_next_progress_cycle(
 p_project_id NUMBER,
 p_task_id NUMBER,
 p_object_id NUMBER := null, -- FPM Development Bug 3420093
 p_object_type VARCHAR2 := 'PA_TASKS', -- FPM Development Bug 3420093
 p_structure_type VARCHAR2 := 'WORKPLAN', -- FPM Development Bug 3420093
 p_start_date  DATE := to_date(null)  -- FPM Development Bug 3420093
)  RETURN DATE IS

/* Bug 3974627 : Commnted and added new cusrosrs
   CURSOR cur_pa_ppc
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
        AND object_id = decode(p_object_id, null, p_task_id, p_object_id) -- This is done to avoid any impact of parameter additions
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND object_type = p_object_type
        AND structure_type = p_structure_type
    AND NVL(task_id, -1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id, NVL(task_id, -1)), NVL(p_task_id,p_object_id))
    ;
*/

-- Bug  3974627 : Added Cursors cur_pa_ppc_str_task, cur_pa_ppc_asgn, cur_pa_ppc_dlv
   CURSOR cur_pa_ppc_str_task
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
        AND object_id = decode(p_object_id, null, p_task_id, p_object_id)
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND object_type = p_object_type
        AND structure_type = p_structure_type
    AND task_id = NVL(p_task_id,p_object_id)
    ;

   CURSOR cur_pa_ppc_asgn
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND object_type IN ('PA_ASSIGNMENTS' ,'PA_TASKS')
        AND structure_type = p_structure_type
    AND task_id = p_task_id
    ;

   CURSOR cur_dlv_get_asso_task(c_del_elem_id NUMBER)
   IS
          SELECT por.object_id_from2
          FROM pa_object_relationships por
          WHERE
          por.object_type_to = 'PA_DELIVERABLES'
      AND por.relationship_subtype IN  ('STRUCTURE_TO_DELIVERABLE', 'TASK_TO_DELIVERABLE')
      AND por.relationship_type = 'A'
      AND por.object_id_to2 = c_del_elem_id
      ;
   l_del_task_id NUMBER;

   CURSOR cur_pa_ppc_dlv(c_task_id NUMBER)
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
        AND ((c_task_id IS NULL AND object_id =p_object_id) OR (c_task_id IS NOT NULL AND object_id IN (c_task_id, p_object_id)))
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND object_type IN ('PA_DELIVERABLES' ,'PA_TASKS')
        AND structure_type = p_structure_type
    AND NVL(task_id, -1) = NVL(p_task_id, NVL(task_id, -1))
    ;


   CURSOR cur_pa_proj_prg_attr
   IS
     SELECT progress_cycle_id
       FROM pa_proj_progress_attr
      WHERE project_id = p_project_id
      AND structure_type = p_structure_type;

   CURSOR cur_pa_proj
   IS
   SELECT start_date, completion_date
     FROM pa_projects_all
    WHERE project_id = p_project_id;


   l_last_progress_date  DATE;
   l_progress_cycle_id   NUMBER;
   l_return_date         DATE;

  l_proj_finish_date    DATE;
  l_proj_start_date     DATE;

  l_cycle_type     varchar2(30);
  l_value1         number;
  cursor get_cycle_info is
  Select Billing_Cycle_Type, Billing_Value1
  From    PA_Billing_Cycles
  Where   Billing_Cycle_ID = l_progress_cycle_id;

BEGIN
   ---5226910(5212999)
   OPEN cur_pa_proj_prg_attr;
   FETCH cur_pa_proj_prg_attr INTO l_progress_cycle_id;
   CLOSE cur_pa_proj_prg_attr;

   if (p_start_date is null) then
     OPEN cur_pa_proj;
     FETCH cur_pa_proj INTO l_proj_start_date, l_proj_finish_date;
     CLOSE cur_pa_proj;

     -- Bug  3974627 Commented
     --OPEN cur_pa_ppc;
     --FETCH cur_pa_ppc INTO l_last_progress_date;
     --CLOSE cur_pa_ppc;

     -- Bug  3974627 Begin
     IF p_object_type IN ('PA_TASKS', 'PA_STRUCTURES') THEN
    OPEN cur_pa_ppc_str_task;
    FETCH cur_pa_ppc_str_task INTO l_last_progress_date;
    CLOSE cur_pa_ppc_str_task;
     ELSIF p_object_type = 'PA_ASSIGNMENTS' THEN
    OPEN cur_pa_ppc_asgn;
    FETCH cur_pa_ppc_asgn INTO l_last_progress_date;
    CLOSE cur_pa_ppc_asgn;
     ELSIF p_object_type = 'PA_DELIVERABLES' THEN
        OPEN cur_dlv_get_asso_task(p_object_id);
    FETCH cur_dlv_get_asso_task INTO l_del_task_id;
    CLOSE cur_dlv_get_asso_task;

    OPEN cur_pa_ppc_dlv(l_del_task_id);
    FETCH cur_pa_ppc_dlv INTO l_last_progress_date;
    CLOSE cur_pa_ppc_dlv;
     END IF;
     -- Bug  3974627 End

     IF l_last_progress_date IS NULL
     THEN
        ----l_last_progress_date := NVL( l_proj_start_date, TRUNC(SYSDATE) );
        l_last_progress_date := TRUNC(SYSDATE)-1;
     END IF;

     --- as of date to remain same if in future  5226910 (5212999)
     if (l_last_progress_date >= trunc(sysdate)) then
         open get_cycle_info;
         fetch get_cycle_info into l_cycle_type, l_value1;
         close get_cycle_info;
         If l_Cycle_Type = 'BILLING CYCLE DAYS' Then
            l_last_progress_date := l_last_progress_date -l_value1;
         else
            l_last_progress_date := l_last_progress_date -1;
         end if;
     else
         l_last_progress_date := l_last_progress_date;
     end if;
   else
     l_last_progress_date := p_start_date;
   end if;

     OPEN cur_pa_proj_prg_attr;
     FETCH cur_pa_proj_prg_attr INTO l_progress_cycle_id;
     CLOSE cur_pa_proj_prg_attr;

     if (l_progress_cycle_id is not null) then
        l_return_date := PA_Billing_Cycles_Pkg.Get_Next_Billing_Date
                    (X_Project_ID          => p_Project_ID,
                     X_Project_Start_Date  => l_last_progress_date,
                     X_Billing_Cycle_ID    => l_progress_cycle_id,
                     X_Billing_Offset_Days => 0,
                     X_Bill_Thru_Date      => l_proj_finish_date,
                     X_Last_Bill_Thru_Date => l_last_progress_date );
     else
        l_return_date := l_last_progress_date + 1;
     end if;

     RETURN ( l_return_date );
END get_next_progress_cycle;



FUNCTION get_prog_dt_closest_to_sys_dt(
 p_project_id NUMBER,
 p_task_id NUMBER, -- From deliverables it will be passed as null
 p_object_id NUMBER := null, -- FPM Development Bug 3420093
 p_object_type VARCHAR2 := 'PA_TASKS', -- FPM Development Bug 3420093
 p_structure_type VARCHAR2 := 'WORKPLAN'
) RETURN DATE IS
   l_last_progress_date  DATE;
   l_progress_cycle_id   NUMBER;
   l_return_date         DATE;
   l_next_progress_date  DATE;
   l_dates_array         PA_VC_2000_10 := pa_vc_2000_10(2000);  --Bug 6627846
   l_previous_date_index NUMBER;
   l_next_date_index     NUMBER;
   l_prev_diff           NUMBER;
   l_next_diff           NUMBER;
   l_closest_date        DATE;
   l_date_index          NUMBER;


   CURSOR cur_pa_proj
   IS
   SELECT start_date, completion_date
     FROM pa_projects_all
    WHERE project_id = p_project_id;

-- Bug  3974627 : Commented this cursor and added new ones
/*
   CURSOR cur_pa_ppc
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
--        AND object_id    = p_task_id
        AND object_id    = decode(p_object_id, null, p_task_id, p_object_id) -- This is Done to avoid the impact
        AND object_type = p_object_type
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND structure_type = p_structure_type
    AND NVL(task_id, -1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id, NVL(task_id, -1)), NVL(p_task_id,p_object_id))
    --and task_id = p_task_id
    ;
*/

-- Bug  3974627 : Added Cursors cur_pa_ppc_str_task, cur_pa_ppc_asgn, cur_pa_ppc_dlv
   CURSOR cur_pa_ppc_str_task
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
        AND object_id = decode(p_object_id, null, p_task_id, p_object_id)
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND object_type = p_object_type
        AND structure_type = p_structure_type
    AND task_id = NVL(p_task_id,p_object_id)
    ;

   CURSOR cur_pa_ppc_asgn
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND ((object_type = 'PA_ASSIGNMENTS' and object_id = p_object_id)
             or (object_type = 'PA_TASKS' and object_id = p_task_id))
        AND structure_type = p_structure_type
        AND task_id = p_task_id
        ;

   CURSOR cur_dlv_get_asso_task(c_del_elem_id NUMBER)
   IS
          SELECT por.object_id_from2
          FROM pa_object_relationships por
          WHERE
          por.object_type_to = 'PA_DELIVERABLES'
      AND por.relationship_subtype IN  ('STRUCTURE_TO_DELIVERABLE', 'TASK_TO_DELIVERABLE')
      AND por.relationship_type = 'A'
      AND por.object_id_to2 = c_del_elem_id
      ;
   l_del_task_id NUMBER;

   CURSOR cur_pa_ppc_dlv_notask
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
        AND object_id = p_object_id
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND object_type = 'PA_DELIVERABLES'
        AND structure_type = p_structure_type
        AND NVL(task_id, -1) = NVL(p_task_id, NVL(task_id, -1))
        ;

   CURSOR cur_pa_ppc_dlv_task(c_task_id NUMBER)
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
        AND ((object_id = p_object_id and object_type = 'PA_DELIVERABLES') or
            (object_id = p_task_id and object_type = 'PA_TASKS'))
        AND current_flag = 'Y'
        AND published_flag = 'Y'
        AND structure_type = p_structure_type
        ;
  CURSOR cur_pa_ppc_w
   IS
     SELECT max( date_computed )
       FROM pa_percent_completes
      WHERE project_id = p_Project_ID
--        AND object_id    = p_task_id
        AND object_id    = decode(p_object_id, null, p_task_id, p_object_id) -- This is Done to avoid the impact
        AND object_type = p_object_type
        AND current_flag = 'N'
        AND published_flag = 'N'
        AND structure_type = p_structure_type
        AND NVL(task_id, -1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id, NVL(task_id, -1)), NVL(p_task_id,p_object_id)) /* Amit : Modified for IB4 Progress CR. */
    --and task_id = p_task_id /* Modified for IB4 Progress CR. */;
    ;

   CURSOR cur_pa_proj_prg_attr
   IS
     SELECT progress_cycle_id
       FROM pa_proj_progress_attr
      WHERE project_id = p_project_id
      AND structure_type = p_structure_type;

  l_proj_finish_date    DATE;
  l_proj_start_date     DATE;
  l_valid_as_of_date varchar2(1);

  l_cycle_type     varchar2(30);
  l_value1         number;
  cursor get_cycle_info is
  Select Billing_Cycle_Type, Billing_Value1
  From    PA_Billing_Cycles
  Where   Billing_Cycle_ID = l_progress_cycle_id;

BEGIN
     OPEN cur_pa_proj;
     FETCH cur_pa_proj INTO l_proj_start_date, l_proj_finish_date;
     CLOSE cur_pa_proj;

     OPEN cur_pa_ppc_w;
     FETCH cur_pa_ppc_w INTO l_last_progress_date;
     CLOSE cur_pa_ppc_w;

     IF p_object_type = 'PA_TASKS' THEN -- This is Done to avoid the impact
        l_valid_as_of_date := CHECK_VALID_AS_OF_DATE ( l_last_progress_date, p_project_id, p_task_id);
     ELSE
        l_valid_as_of_date := CHECK_VALID_AS_OF_DATE ( l_last_progress_date, p_project_id, p_object_id, p_object_type,p_task_id/* Amit : Modified for IB4 Progress CR. */ );
     END IF;



     if (l_last_progress_date is not null) then
         IF l_valid_as_of_date = 'Y'
         THEN
             return l_last_progress_date;
         --if the there is working version and the progress cycle id is cahnegd then return the next valid date.
         --we do not need to write any else here.
         END IF;
     end if;

     -- Bug  3974627 : Commented
     --OPEN cur_pa_ppc;
     --FETCH cur_pa_ppc INTO l_last_progress_date;
     --CLOSE cur_pa_ppc;

     -- Bug  3974627 Begin
     IF p_object_type IN ('PA_TASKS', 'PA_STRUCTURES') THEN
    OPEN cur_pa_ppc_str_task;
    FETCH cur_pa_ppc_str_task INTO l_last_progress_date;
    CLOSE cur_pa_ppc_str_task;
     ELSIF p_object_type = 'PA_ASSIGNMENTS' THEN
    OPEN cur_pa_ppc_asgn;
    FETCH cur_pa_ppc_asgn INTO l_last_progress_date;
    CLOSE cur_pa_ppc_asgn;
     ELSIF p_object_type = 'PA_DELIVERABLES' THEN
    OPEN cur_dlv_get_asso_task(p_object_id);
    FETCH cur_dlv_get_asso_task INTO l_del_task_id;
    CLOSE cur_dlv_get_asso_task;

        if l_del_task_id is not null then
            OPEN cur_pa_ppc_dlv_task(l_del_task_id);
            FETCH cur_pa_ppc_dlv_task INTO l_last_progress_date;
            CLOSE cur_pa_ppc_dlv_task;
        else
            OPEN cur_pa_ppc_dlv_notask;
            FETCH cur_pa_ppc_dlv_notask INTO l_last_progress_date;
            CLOSE cur_pa_ppc_dlv_notask;
        end if;
     END IF;
     -- Bug  3974627 End

     IF l_last_progress_date IS NULL
     THEN
        l_last_progress_date := trunc(sysdate)-1; -----NVL( l_proj_start_date, TRUNC(SYSDATE) );
     END IF;

--------my_error_msg( 'l_last_progress_date '|| l_last_progress_date );

     OPEN cur_pa_proj_prg_attr;
     FETCH cur_pa_proj_prg_attr INTO l_progress_cycle_id;
     CLOSE cur_pa_proj_prg_attr;

     --- as of date to remain same if in future 5212999
     if (l_last_progress_date >= trunc(sysdate)) then
        open get_cycle_info;
         fetch get_cycle_info into l_cycle_type, l_value1;
         close get_cycle_info;
         If l_Cycle_Type = 'BILLING CYCLE DAYS' Then
            l_last_progress_date := l_last_progress_date -l_value1;
         else
            l_next_progress_date := l_last_progress_date -1;
         end if;
     else
         l_next_progress_date := l_last_progress_date;
     end if;
     IF l_progress_cycle_id IS NULL
     THEN
         RETURN l_last_progress_date + 1;
     END IF;

  WHILE NVL( l_return_date, SYSDATE ) <= SYSDATE
  LOOP
     l_return_date := PA_Billing_Cycles_Pkg.Get_Next_Billing_Date
                    (X_Project_ID          => p_Project_ID,
                     X_Project_Start_Date  => l_last_progress_date,
                     X_Billing_Cycle_ID    => l_progress_cycle_id,
                     X_Billing_Offset_Days => 0,
                     X_Bill_Thru_Date      => l_proj_finish_date,
                     X_Last_Bill_Thru_Date => l_next_progress_date );

     l_date_index := NVL( l_date_index, 0 ) + 1;

     l_dates_array.extend(1);
     l_dates_array(l_date_index) := to_char(l_return_date, 'MM-DD-RR');

     l_next_progress_date := l_return_date;

--Bug 6627846: Below code restricts number of entries in l_return_date.Refer bug for more details
     IF l_date_index >= 1999  -- Bug 6627846, changed from 999 to 1999
     THEN
        exit;
     END IF;

  END LOOP;

--  FOR i in 1..1000 LOOP Modified for bug 3795916
  FOR i in l_dates_array.FIRST..l_dates_array.LAST LOOP
      IF  to_date( l_dates_array(i), 'MM-DD-RR' ) >= TRUNC(SYSDATE)  -- Added trunc for bug 3795916
      THEN
         IF i > 1
         THEN
             l_previous_date_index := i - 1;
         ELSE
             l_previous_date_index := i;
         END IF;
         l_next_date_index := i;
         exit;
      END IF;
  END LOOP;

  l_prev_diff := SYSDATE - to_date( l_dates_array(l_previous_date_index), 'MM-DD-RR' );
  l_next_diff := to_date( l_dates_array(l_next_date_index), 'MM-DD-RR' ) - SYSDATE;

  IF l_prev_diff < l_next_diff
  THEN
    l_closest_date := to_date( l_dates_array(l_previous_date_index), 'MM-DD-RR' );
  ELSE
    l_closest_date := to_date( l_dates_array(l_next_date_index), 'MM-DD-RR' );
  END IF;

  RETURN ( l_closest_date );

END get_prog_dt_closest_to_sys_dt;

--aod --as of date
--This function returns 'N' if there does not exists any progress
--on passed as_of_date otherwise it
--will return 'WORKING' or 'PUBLISHED' progress depending on the
--publish flag.
FUNCTION check_prog_exists_on_aod(
 p_project_id       NUMBER,
 p_object_type      VARCHAR2,
 p_object_version_id NUMBER,
 p_task_id NUMBER := null/* Amit : Modified for IB4 Progress CR. */     ,
 p_as_of_date DATE,
 p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
 ,p_object_id   NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN VARCHAR2 IS

  CURSOR cur_ppc
  IS
    SELECT decode( published_flag, 'Y', 'PUBLISHED', 'N', 'WORKING' )
      FROM pa_percent_completes
     WHERE object_id = nvl(p_object_id, p_task_id) /* Modified for IB4 Progress CR. */
       AND object_type = p_object_type
       AND project_id  = p_project_id
       AND date_computed = p_as_of_date
       AND structure_type = p_structure_type
       and NVL(task_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id,NVL(task_id,-1)),NVL(p_task_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
       order by published_flag;  --bug 4185364
  l_return_value   VARCHAR2(15);
BEGIN
    OPEN cur_ppc;
    FETCH cur_ppc INTO l_return_value;
    CLOSE cur_ppc;
    RETURN NVL( l_return_value, 'N' );
END check_prog_exists_on_aod;

FUNCTION get_ppc_id(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_type   VARCHAR2
,p_object_version_id  NUMBER
,p_as_of_date    DATE
,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
,p_task_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER IS

   CURSOR cur_ppc_id
   IS
     SELECT percent_complete_id
       FROM pa_percent_completes
      WHERE object_type = p_object_type
        AND object_id = p_object_id
        AND project_id = p_project_id
--        AND object_version_id = p_object_version_id
        AND date_computed = p_as_of_date
        AND structure_type = p_structure_type
        and NVL(task_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id,NVL(task_id,-1)),NVL(p_task_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
    --and task_id = nvl(p_task_id, p_object_id)  /* Modified for IB4 Progress CR. */
       order by published_flag  --bug 4185364
       ;

   l_ppc_id NUMBER;

BEGIN

   OPEN cur_ppc_id;
   FETCH cur_ppc_id INTO l_ppc_id;
   CLOSE cur_ppc_id;

   RETURN l_ppc_id;

END get_ppc_id;

FUNCTION get_prog_rollup_id(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_type   VARCHAR2
,p_object_version_id NUMBER
,p_as_of_date    DATE
,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
,p_structure_version_id NUMBER := null -- FPM Development Bug 3420093
,x_record_version_number OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
,p_action          VARCHAR2 := 'PUBLISH' -- Bug 3879461
 ) RETURN NUMBER
IS

   CURSOR cur_prog_rollup_id_pub_wp
   IS
     SELECT progress_rollup_id, record_version_number
       FROM pa_progress_rollup
      WHERE object_type = p_object_type
        AND object_id = p_object_id
        AND project_id = p_project_id
--        AND object_version_id = p_object_version_id
        AND as_of_date = p_as_of_date
        AND structure_type = p_structure_type
        AND structure_version_id is null
    and ((p_action = 'SAVE' AND current_flag = 'W') OR (p_action = 'PUBLISH' AND current_flag IN ('Y', 'N'))) -- Bug 3879461
        and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */;
    --and proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;


   CURSOR cur_prog_rollup_id_work_wp
   IS
     SELECT progress_rollup_id, record_version_number
       FROM pa_progress_rollup
      WHERE object_type = p_object_type
        AND object_id = p_object_id
        AND project_id = p_project_id
        AND structure_type = p_structure_type
        AND structure_version_id = p_structure_version_id
        and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */;
    --and proj_element_id = nvl(p_proj_element_id,p_object_id) /* Modified for IB4 Progress CR. */;

   l_prog_rollup_id NUMBER;

BEGIN

IF p_structure_version_id is NULL THEN
   OPEN cur_prog_rollup_id_pub_wp;
   FETCH cur_prog_rollup_id_pub_wp INTO l_prog_rollup_id, x_record_version_number;
   CLOSE cur_prog_rollup_id_pub_wp;
ELSE
   OPEN cur_prog_rollup_id_work_wp;
   FETCH cur_prog_rollup_id_work_wp INTO l_prog_rollup_id, x_record_version_number;
   CLOSE cur_prog_rollup_id_work_wp;
END IF;

   RETURN l_prog_rollup_id;

END get_prog_rollup_id;

FUNCTION check_task_has_progress(
p_task_id    NUMBER ) RETURN VARCHAR2 IS

--Added for performance improvements bug 2679612
  CURSOR cur_proj_elem
  IS
    SELECT project_id
     FROM pa_proj_elements
    WHERE proj_element_id = p_task_id;
    l_project_id          NUMBER;
--Added for performance improvements bug 2679612

    CURSOR cur_pa_prog_exists(c_project_id NUMBER )
    IS
      SELECT 'X'
        FROM pa_percent_completes
       WHERE object_id = p_task_id
         AND project_id = c_project_id;
    l_dummy_char    VARCHAR2(1);
BEGIN

--Added for performance improvements bug 2679612
   OPEN cur_proj_elem;
   FETCH cur_proj_elem INTO l_project_id;
   CLOSE cur_proj_elem;
--Added for performance improvements bug 2679612

    OPEN cur_pa_prog_exists( l_project_id );
    FETCH cur_pa_prog_exists INTO l_dummy_char;
    IF cur_pa_prog_exists%FOUND
    THEN
       CLOSE cur_pa_prog_exists;
       RETURN 'Y';
    ELSE
       CLOSE cur_pa_prog_exists;
       RETURN 'N';
    END IF;

END check_task_has_progress;

-- FPM Dev CR 3 : This function is not used.
FUNCTION get_last_cumulative(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_type   VARCHAR2
,p_as_of_date    DATE )
RETURN NUMBER IS
 -- 4348710 : Added structure_type and structure_version_id joins
   CURSOR cur_cumla
   IS
     SELECT cumulative_work_quantity
       FROM pa_progress_rollup
      WHERE project_id = p_project_id
        AND object_id = p_object_id
        AND object_type = p_object_type
    AND structure_type = 'WORKPLAN'
    AND structure_version_id is null
        AND as_of_date = ( SELECT max( as_of_date )
                             FROM pa_progress_rollup
                            WHERE project_id = p_project_id
                              AND object_id = p_object_id
                              AND object_type = p_object_type
                              AND as_of_date < p_as_of_date
                  AND structure_type = 'WORKPLAN'
                  AND structure_version_id is null
                  );

   l_cumulative_work_qty NUMBER;
BEGIN
     OPEN cur_cumla;
     FETCH cur_cumla INTO l_cumulative_work_qty;
     CLOSE cur_cumla;
     RETURN NVL( l_cumulative_work_qty, 0 );
END get_last_cumulative;

FUNCTION get_planned_wq(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_version_id NUMBER ) RETURN NUMBER IS

 CURSOR cur_prj_sch
 IS
    SELECT NVL( wq_planned_quantity, 0 )
      FROM pa_proj_elem_ver_schedule
     WHERE project_id = p_project_id
       AND proj_element_id = p_object_id
       AND element_version_id = p_object_version_id;
 l_planned_qty   NUMBER;
BEGIN
     OPEN cur_prj_sch;
     FETCH cur_prj_sch INTO l_planned_qty;
     CLOSE cur_prj_sch;
     ----my_error_msg( 'p_object_version_id '|| p_object_version_id );
     ----my_error_msg( 'l_planned_qty '|| l_planned_qty );
     RETURN NVL( l_planned_qty, 0 );
END get_planned_wq;

PROCEDURE clear_prog_outdated_flag(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_type   VARCHAR2
,p_structure_version_id   NUMBER   default null    --bug 3851528
,x_return_status              OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count          OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                 OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  l_proj_element_id     NUMBER;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_structure_version_id IS NULL
  THEN
     IF p_object_type = 'PA_TASKS'
     THEN
         l_proj_element_id := p_object_id;
         UPDATE pa_proj_elements
            SET progress_outdated_flag = 'N'
           WHERE proj_element_id = l_proj_element_id;
     ELSIF p_object_type = 'PA_STRUCTURES'
     THEN
         UPDATE pa_proj_elements ppe
            SET progress_outdated_flag = 'N'
          WHERE proj_element_id = ( SELECT proj_element_id
                                      FROM pa_proj_structure_types ppst
                                     WHERE ppst.structure_type_id = 1      --WORKPLAN
                                       AND ppst.proj_element_id = ppe.proj_element_id )
            AND project_id = p_project_id;
     END IF;
  ELSIF p_structure_version_id IS NOT NULL
  THEN
        UPDATE pa_proj_elements
           SET progress_outdated_flag = 'N'
        WHERE proj_element_id in ( SELECT proj_element_id
                                     FROM pa_proj_element_versions
                                     WHERE project_id = p_project_id
                                       AND parent_structure_version_id = p_structure_version_id
                                       AND object_type in ( 'PA_STRUCTURES', 'PA_TASKS' )  )
        AND object_type in ( 'PA_STRUCTURES', 'PA_TASKS' )
        AND project_id = p_project_id
        ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'clear_prog_outdated_flag',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
      x_msg_count := FND_MSG_PUB.count_msg;
      x_msg_data := SUBSTRB(SQLERRM,1,120) ; -- 4537865
      RAISE;
END clear_prog_outdated_flag;


-- FPM Development Bug 3420093
PROCEDURE get_project_progress_defaults(
 p_project_id                   NUMBER
,p_structure_type               IN VARCHAR2
,x_WQ_ENABLED_FLAG              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_EFFORT_ENABLED_FLAG          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_PERCENT_COMP_ENABLED_FLAG    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_task_weight_basis_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_ALLOW_COLLAB_PROG_ENTRY      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
,X_ALLW_PHY_PRCNT_CMP_OVERRIDES OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) IS

  CURSOR cur_prg_deflts
    IS
      SELECT
        WQ_ENABLE_FLAG,
        REMAIN_EFFORT_ENABLE_FLAG,
        PERCENT_COMP_ENABLE_FLAG,
        task_weight_basis_code,
        ALLOW_COLLAB_PROG_ENTRY,
        ALLOW_PHY_PRCNT_CMP_OVERRIDES
       FROM pa_proj_progress_attr
       WHERE project_id = p_project_id
         AND structure_type = p_structure_type;

BEGIN
     OPEN cur_prg_deflts;
     FETCH cur_prg_deflts INTO x_WQ_ENABLED_FLAG
                              ,x_EFFORT_ENABLED_FLAG
                              ,x_PERCENT_COMP_ENABLED_FLAG
                              ,x_task_weight_basis_code
                              ,X_ALLOW_COLLAB_PROG_ENTRY
                              ,X_ALLW_PHY_PRCNT_CMP_OVERRIDES;
     CLOSE cur_prg_deflts;

-- 4537865
EXCEPTION
WHEN OTHERS THEN

    x_WQ_ENABLED_FLAG              := NULL ;
    x_EFFORT_ENABLED_FLAG          := NULL ;
    x_PERCENT_COMP_ENABLED_FLAG    := NULL ;
    x_task_weight_basis_code       := NULL ;
    x_ALLOW_COLLAB_PROG_ENTRY      := NULL ;
    x_ALLW_PHY_PRCNT_CMP_OVERRIDES := NULL ;

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'get_project_progress_defaults',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;

END get_project_progress_defaults;


-- This API should be used to get the progress setup values at the project and task type level.
-- This will not be used for deliverable type values
PROCEDURE get_progress_defaults(
 p_project_id                   NUMBER
,p_object_version_id            NUMBER
,p_object_type                  VARCHAR2
,p_object_id                    NUMBER
,p_as_of_date                   DATE
,p_structure_type               VARCHAR2 := 'WORKPLAN'  -- FPM Development Bug 3420093
,x_WQ_ACTUAL_ENTRY_CODE         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_WQ_ENABLED_FLAG              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_EFFORT_ENABLED_FLAG          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_BASE_PERCENT_COMP_DERIV_CODE OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_PERCENT_COMP_ENABLED_FLAG    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_PROGRESS_ENTRY_ENABLE_FLAG    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_ALLOW_COLLAB_PROG_ENTRY      OUT NOCOPY VARCHAR2 -- FPM Development Bug 3420093 --File.Sql.39 bug 4440895
,X_ALLW_PHY_PRCNT_CMP_OVERRIDES OUT NOCOPY VARCHAR2 -- FPM Development Bug 3420093 --File.Sql.39 bug 4440895
,x_task_weight_basis_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   /*  replacing this sql with the following for bug 2679612
    CURSOR cur_prg_deflts
    IS
      SELECT WQ_ACTUAL_ENTRY_CODE, WQ_ENABLED_FLAG,
             EFFORT_ENABLED_FLAG, BASE_PERCENT_COMP_DERIV_CODE,
             PERCENT_COMP_ENABLED_FLAG, PROG_ENTRY_ENABLE_FLAG
        FROM PA_LATEST_proj_TASK_PROG_V
       WHERE project_id = p_project_id
         AND task_id = p_object_id
         AND object_type = p_object_type
         ;
         --AND element_version_id = p_object_version_id
         --AND as_of_date = p_as_of_date;
*/

  CURSOR cur_prg_deflts
    IS
      SELECT
        nvl(ppe.WQ_ACTUAL_ENTRY_CODE,ptt.ACTUAL_WQ_ENTRY_CODE),
        decode(ppe.object_type,'PA_STRUCTURES',pppa.WQ_ENABLE_FLAG,
               decode(ptt.WQ_ENABLE_FLAG, 'Y', decode(pppa.WQ_ENABLE_FLAG, 'Y', 'Y', 'N'), 'N')),
        decode(ppe.object_type,'PA_STRUCTURES',pppa.REMAIN_EFFORT_ENABLE_FLAG,
               decode(ptt.REMAIN_EFFORT_ENABLE_FLAG, 'Y', decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', 'Y', 'N'), 'N')),
        NVL( ppe.base_percent_comp_deriv_code, ptt.base_percent_comp_deriv_code),
        decode(ppe.object_type,'PA_STRUCTURES',pppa.PERCENT_COMP_ENABLE_FLAG,
               decode(ptt.PERCENT_COMP_ENABLE_FLAG, 'Y', decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', 'Y','N'), 'N')),
        decode(ppe.object_type,'PA_TASKS',ptt.PROG_ENTRY_ENABLE_FLAG,'Y'),
        pppa.ALLOW_COLLAB_PROG_ENTRY,
        pppa.ALLOW_PHY_PRCNT_CMP_OVERRIDES,
        pppa.TASK_WEIGHT_BASIS_CODE
       FROM pa_proj_elements ppe, pa_task_types ptt, pa_proj_progress_attr pppa, pa_proj_elem_ver_structure ppvs, pa_proj_structure_types ppst
       WHERE ppe.project_id = p_project_id
         AND ppe.proj_element_id = p_object_id
         AND ppe.object_type = p_object_type
         AND ppe.type_id = ptt.task_type_id(+)
         AND ppvs.project_id = pppa.project_id(+)
         AND pppa.structure_type = p_structure_type
         AND ppe.project_id = ppvs.project_id
         AND ppvs.latest_eff_published_flag = 'Y'
         AND ppvs.proj_element_id = pppa.object_id(+)
         AND ppvs.proj_element_id = ppst.proj_element_id
         AND ptt.object_type(+) = 'PA_TASKS'  /* bug 3279978 FP M Enhancement */ --bug 4330450 added outer join
         AND ppst.structure_type_id =1;

BEGIN
     OPEN cur_prg_deflts;
     FETCH cur_prg_deflts INTO x_WQ_ACTUAL_ENTRY_CODE
                              ,x_WQ_ENABLED_FLAG
                              ,x_EFFORT_ENABLED_FLAG
                              ,x_BASE_PERCENT_COMP_DERIV_CODE
                              ,x_PERCENT_COMP_ENABLED_FLAG
                              ,X_PROGRESS_ENTRY_ENABLE_FLAG
                              ,X_ALLOW_COLLAB_PROG_ENTRY
                              ,X_ALLW_PHY_PRCNT_CMP_OVERRIDES
                              ,x_task_weight_basis_code
                               ;
     CLOSE cur_prg_deflts;

     /*x_WQ_ACTUAL_ENTRY_CODE := 'INCREMENTAL';
     x_WQ_ENABLED_FLAG := 'Y';
     x_EFFORT_ENABLED_FLAG := 'Y';
--     x_BASE_PERCENT_COMP_DERIV_CODE
     x_PERCENT_COMP_ENABLED_FLAG := 'Y';*/
--  4537865
EXCEPTION
WHEN OTHERS THEN
    x_WQ_ENABLED_FLAG              := NULL ;
    x_EFFORT_ENABLED_FLAG          := NULL ;
    x_BASE_PERCENT_COMP_DERIV_CODE := NULL ;
    x_PERCENT_COMP_ENABLED_FLAG    := NULL ;
    X_PROGRESS_ENTRY_ENABLE_FLAG   := NULL ;
    X_ALLOW_COLLAB_PROG_ENTRY      := NULL ;
    X_ALLW_PHY_PRCNT_CMP_OVERRIDES := NULL ;
    x_task_weight_basis_code       := NULL ;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'get_progress_defaults',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END get_progress_defaults;

FUNCTION chk_prg_since_last_prg(
 p_project_id                   NUMBER
,p_percent_complete_id          NUMBER
,p_object_type                  VARCHAR2
,p_object_id                    NUMBER
,p_task_id          NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN VARCHAR2 IS
BEGIN

  IF Working_version_exist(
       p_task_id          => p_task_id --nvl(p_task_id, p_object_id) /* Amit : Modified for IB4 Progress CR. */
      ,p_project_id       => p_project_id
      ,p_object_type      => p_object_type
      ,p_object_id    => p_object_id /* Modified for IB4 Progress CR. */
      )  IS NOT NULL
  THEN
     RETURN 'Y';
  ELSE
     RETURN 'N';
  END IF;

END chk_prg_since_last_prg;

/*
FUNCTION check_project_has_progress(
p_project_id    NUMBER ,
p_object_id     NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_pa_prog_exists
    IS
      SELECT 'X'
        FROM pa_percent_completes
       WHERE project_id = p_project_id
         AND object_id = decode(nvl(p_object_id,0),0,object_id,p_object_id)
         AND object_type = 'PA_STRUCTURES'
         AND task_id = 0;
    l_dummy_char    VARCHAR2(1);
BEGIN
    OPEN cur_pa_prog_exists;
    FETCH cur_pa_prog_exists INTO l_dummy_char;
    IF cur_pa_prog_exists%FOUND
    THEN
       CLOSE cur_pa_prog_exists;
       RETURN 'Y';
    ELSE
       CLOSE cur_pa_prog_exists;
       RETURN 'N';
    END IF;
END check_project_has_progress;
*/

FUNCTION check_project_has_progress(
 	 p_project_id    NUMBER ,
 	 p_object_id     NUMBER,
 	 p_structure_type VARCHAR2 := null) RETURN VARCHAR2 IS     -- added a new parameter for the BUG 6903050
CURSOR cur_pa_prog_exists
IS
 SELECT 'X'
   FROM pa_percent_completes
  WHERE project_id = p_project_id
    AND object_id = decode(nvl(p_object_id,0),0,object_id,p_object_id)
    AND object_type = 'PA_STRUCTURES'
    AND task_id = 0;

CURSOR cur_pa_prog_exists_wp          -- added a new cursor for the BUG 6903050
    IS
     SELECT 'X'
       FROM pa_percent_completes
      WHERE project_id = p_project_id
        AND object_id = decode(nvl(p_object_id,0),0,object_id,p_object_id)
        AND object_type = 'PA_STRUCTURES'
        AND task_id = 0
        AND STRUCTURE_TYPE = p_structure_type;

l_dummy_char    VARCHAR2(1);
BEGIN

    IF (p_structure_type = 'WORKPLAN')    -- added a new check for WORKPLAN for the BUG 6903050
    THEN
      OPEN  cur_pa_prog_exists_wp;
      FETCH cur_pa_prog_exists_wp INTO l_dummy_char;
      IF cur_pa_prog_exists_wp%FOUND
      THEN
        CLOSE cur_pa_prog_exists_wp;
        RETURN 'Y';
      ELSE
        CLOSE cur_pa_prog_exists_wp;
        RETURN 'N';
      END IF;

    ELSE
      OPEN cur_pa_prog_exists;
      FETCH cur_pa_prog_exists INTO l_dummy_char;
      IF cur_pa_prog_exists%FOUND
      THEN
        CLOSE cur_pa_prog_exists;
        RETURN 'Y';
      ELSE
        CLOSE cur_pa_prog_exists;
        RETURN 'N';
      END IF;
    END IF;
END check_project_has_progress;

FUNCTION get_task_prog_profile(
p_profile_name    VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
    RETURN ( fnd_profile.value_specific(p_profile_name, fnd_global.user_id ) );
END get_task_prog_profile;

-- this function is modified to return working record only upto the passed as of date
FUNCTION Working_version_exist(
     p_task_id          NUMBER := null /* Amit : Modified for IB4 Progress CR. */
    ,p_project_id       NUMBER
    ,p_object_type      VARCHAR2
    ,p_object_id    NUMBER := null /* Modified for IB4 Progress CR. */
    ,p_as_of_date       DATE := null  -- bug 4185364
    ) RETURN DATE IS

    CURSOR cur_pa_pcc
    IS
      SELECT date_computed
        FROM pa_percent_completes
       WHERE project_id = p_project_id
         AND object_id = nvl(p_object_id, p_task_id)  /* Modified for IB4 Progress CR. */
         AND object_type = p_object_type
     AND structure_type = 'WORKPLAN' -- FPM Dev CR 3
         AND published_flag = 'N'
         AND current_flag = 'N'
         and NVL(task_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id,NVL(task_id,-1)),NVL(p_task_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
     and trunc(date_computed) <= trunc(p_as_of_date); --bug 4185364
     --and task_id = p_task_id /* Modified for IB4 Progress CR. */;

     l_return_date  DATE := null;
BEGIN

     OPEN cur_pa_pcc;
     FETCH cur_pa_pcc INTO l_return_date;
     CLOSE  cur_pa_pcc;
     RETURN l_return_date;
END Working_version_exist;

FUNCTION check_status_referenced(
p_status_code    VARCHAR2 ) RETURN BOOLEAN
is
 Cursor c_percent_complete
 is
  select 'X' from pa_percent_completes
  where ( progress_status_code = p_status_code
  or status_code = p_status_code)
  AND rownum <= 1;

 Cursor c_prog_rollup
 is
   select 'X' from pa_progress_rollup
   where ( progress_status_code = p_status_code
   or base_progress_status_code = p_status_code
   or eff_rollup_prog_stat_code = p_status_code)
   AND rownum <= 1;

 Cursor c_proj_elements
 is
 select 'X' from pa_proj_elements
 where status_code = p_status_code
   AND rownum <= 1;

 Cursor c_proj_elem_ver_structure
 is
 select 'X' from pa_proj_elem_ver_structure
 where status_code = p_status_code
  AND rownum <= 1;

 Cursor c_task_types
 is
 select 'X' from pa_task_types
 where ( initial_status_code = p_status_code
 or initial_progress_status_code = p_status_code)
 AND object_type = 'PA_TASKS' /* bug 3279978 FP M Enhancement */
 AND rownum <= 1;

 l_return_value boolean := FALSE;
 l_dummy  varchar2(1);

 Begin
   open c_percent_complete;
   fetch c_percent_complete into l_dummy;
   if (c_percent_complete%FOUND) then
     l_return_value := TRUE;
   end if;
   close c_percent_complete;

   -- Check referense in pa_progress_rollup
   if(NOT l_return_value) then
     open c_prog_rollup;
     fetch c_prog_rollup into l_dummy;
     if(c_prog_rollup%FOUND) then
       l_return_value := TRUE;
     end if;
     close c_prog_rollup;
   end if;
   -- Check referense in pa_proj_elements
   if(NOT l_return_value) then
     open c_proj_elements;
     fetch c_proj_elements into l_dummy;
     if(c_proj_elements%FOUND) then
       l_return_value := TRUE;
     end if;
     close c_proj_elements;
   end if;

   -- Check referense in pa_proj_elem_ver_structure
   if(NOT l_return_value) then
     open c_proj_elem_ver_structure;
     fetch c_proj_elem_ver_structure into l_dummy;
     if(c_proj_elem_ver_structure%FOUND) then
       l_return_value := TRUE;
     end if;
     close c_proj_elem_ver_structure;
   end if;
   -- Check referense in pa_task_types
   if(NOT l_return_value) then
     open c_task_types;
     fetch c_task_types into l_dummy;
     if(c_task_types%FOUND) then
       l_return_value := TRUE;
     end if;
     close c_task_types;
   end if;

   return l_return_value;

 End check_status_referenced;

-- FPM Dev CR 3 : Not Used
FUNCTION GET_LATEST_AS_OF_DATE2(
    p_task_id      NUMBER
    ,p_as_of_date  DATE ) RETURN DATE IS

--Added for performance improvements bug 2679612
  CURSOR cur_proj_elem
  IS
    SELECT project_id
     FROM pa_proj_elements
    WHERE proj_element_id = p_task_id;
    l_project_id          NUMBER;
--Added for performance improvements bug 2679612

  CURSOR cur_ppc(c_project_id NUMBER )
  IS
    SELECT MAX( date_computed )
      FROM pa_percent_completes
     WHERE object_id = p_task_id
       AND project_id = c_project_id
       AND date_computed < p_as_of_Date
    ;
  l_as_of_date  DATE;
BEGIN

     OPEN cur_proj_elem;
     FETCH cur_proj_elem INTO l_project_id;
     CLOSE cur_proj_elem;

     OPEN cur_ppc( l_project_id );
     FETCH cur_ppc INTO l_as_of_date;
     CLOSE cur_ppc;
     RETURN l_as_of_date ;

exception when others then
     return null;

END GET_LATEST_AS_OF_DATE2;

FUNCTION is_parent_on_hold(
   p_object_version_id     NUMBER
) RETURN VARCHAR2 IS
    CURSOR cur_pa_proj
    IS
      SELECT ppe.status_code
        FROM pa_object_relationships por,
             pa_proj_element_versions ppev,
             pa_proj_elements ppe,
             pa_project_statuses pps
       WHERE object_id_to1 = p_object_version_id
         AND ppev.element_version_id = por.object_id_from1
         AND ppev.proj_element_id = ppe.proj_element_id
         AND ppev.object_type = ppe.object_type
         AND ppe.object_type = 'PA_TASKS'
         AND ppe.status_code = pps.project_status_code
         AND pps.project_system_status_code = 'ON_HOLD';

   l_status_code   VARCHAR2(150);
BEGIN
     OPEN cur_pa_proj;
     FETCH cur_pa_proj INTO l_status_code;
     IF cur_pa_proj%FOUND
     THEN
         CLOSE cur_pa_proj;
         RETURN 'Y';
     ELSE
         CLOSE cur_pa_proj;
         RETURN 'N';
     END IF;
END is_parent_on_hold;

FUNCTION get_task_status(
  p_project_id     NUMBER
 ,p_object_id     NUMBER
 , p_object_type  VARCHAR2 := 'PA_TASKS' -- FPM Development Bug 3420093
 ) RETURN VARCHAR2 IS

   CURSOR cur_pa_proj_elems
   IS
     SELECT status_code
       FROM pa_proj_elements
      WHERE proj_element_id = p_object_id
        AND project_id      = p_project_id
        AND object_type = p_object_type;

    l_status_code VARCHAR2(150);
BEGIN
    OPEN cur_pa_proj_elems;
    FETCH cur_pa_proj_elems INTO l_status_code;
    CLOSE cur_pa_proj_elems;
    RETURN l_status_code;
END get_task_status;


FUNCTION get_system_task_status(
 p_status_code   VARCHAR2
,p_object_type   VARCHAR2 := 'PA_TASKS' -- FPM Development Bug 3420093
 ) RETURN VARCHAR2 IS

   CURSOR cur_sys_status
   IS
     SELECT project_system_status_code
       FROM pa_project_statuses pps   -----, fnd_lookup_values flv
      WHERE project_status_code = p_status_code
        AND status_type = decode(p_object_type, 'PA_TASKS', 'TASK', 'PA_DELIVERABLES', 'DELIVERABLE');
    /*  bug 4699567 flv was not used in the query anyways
        AND lookup_type = decode(p_object_type, 'PA_TASKS', 'TASK_SYSTEM_STATUS', 'PA_DELIVERABLES', 'DELIVERABLE_SYSTEM_STATUS')
        AND language = 'US'; */

    l_status_code VARCHAR2(150);
BEGIN
    OPEN cur_sys_status;
    FETCH cur_sys_status INTO l_status_code;
    CLOSE cur_sys_status;
    RETURN l_status_code;
END get_system_task_status;

Function is_cycle_ok_to_delete(p_progress_cycle_id  IN  NUMBER) return
varchar2
IS
   cursor prog_cycle is
   select 'N'
    from pa_proj_progress_attr
   where progress_cycle_id = p_progress_cycle_id
   and structure_type = 'WORKPLAN';-- FPM Dev CR 3

   retval   varchar2(1);
   l_prog_cycle  prog_cycle%rowtype;

Begin
  open prog_cycle;
  fetch prog_cycle into l_prog_cycle;
  if prog_cycle%found then
      close prog_cycle;
      return 'N';
  else
      close prog_cycle;
      return 'Y';
  end if;
End is_cycle_ok_to_delete;

-- FPM Dev CR 3 : Not Used
function get_max_ppc_id(p_project_id   IN  NUMBER,
                        p_object_id    IN  NUMBER,
                        p_object_type  IN  VARCHAR2,
                        p_as_of_date   IN  DATE) return number is

l_ppc_id      number;
begin
select nvl(max(percent_complete_id),-99)
            into l_ppc_id
            from pa_percent_completes
           where project_id = p_project_id
             and object_id = p_object_id
             and object_type = p_object_type
             and date_computed <= p_as_of_date;
return l_ppc_id;

exception when others then
  return -99;
end get_max_ppc_id;

function get_max_rollup_asofdate(p_project_id   IN  NUMBER,
                                 p_object_id    IN  NUMBER,
                                 p_object_type  IN  VARCHAR2,
                                 p_as_of_date   IN  DATE,
                                 p_object_version_id  IN  NUMBER,
                 p_structure_type IN VARCHAR2 := 'WORKPLAN', -- FPM Dev CR 3
                 p_structure_version_id NUMBER := NULL -- FPM Dev CR 4
                 ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
                 ) return date is
l_rollup_date   date;
begin

/*     -- FPM Dev CR 4 : Added condition for PA_TASKS and structure_version_id
   if (((p_object_type = 'PA_TASKS') AND (nvl(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_object_version_id ),'N') = 'N')) OR p_structure_version_id is not null) then

           select max(as_of_date)
             into l_rollup_date
             from pa_progress_rollup
            where project_id = p_project_id
              and object_id = p_object_id
              and object_type = p_object_type
          and structure_type = p_structure_type -- FPM Dev CR 3
              and as_of_date <= p_as_of_date
          and ((p_structure_version_id is null AND structure_version_id is null) OR (p_structure_version_id is not null AND structure_version_id = p_structure_version_id)) -- FPM Dev CR 4
          ;
    else
           select max(as_of_date)
             into l_rollup_date
             from pa_progress_rollup
            where project_id = p_project_id
              and object_id = p_object_id
              and object_type = p_object_type
              and structure_type = p_structure_type -- FPM Dev CR 3
              and trunc(as_of_date) = (select max(trunc(date_computed))
                                       from pa_percent_completes
                                      where project_id = p_project_id
                                        and object_id = p_object_id
                                        and object_type = p_object_type
                        and structure_type = p_structure_type -- FPM Dev CR 3
                                        and published_flag = 'Y'
                                        and date_computed <= p_as_of_date);
    end if;
*/

-- FPM Dev CR 6 : Commented the above code and added this new code to get the date.
           select max(as_of_date)
             into l_rollup_date
             from pa_progress_rollup
            where project_id = p_project_id
              and object_id = p_object_id
              and object_type = p_object_type
          and structure_type = p_structure_type
              and as_of_date <= p_as_of_date
          and ((p_structure_version_id is null AND structure_version_id is null) OR (p_structure_version_id is not null AND structure_version_id = p_structure_version_id))
              AND current_flag <> 'W'   -- Bug 3879461
--        and as_of_date not in (select trunc(date_computed)
--                       from pa_percent_completes
--                                      where project_id = p_project_id
--                                        and object_id = p_object_id
--                                        and object_type = p_object_type
--                      and structure_type = p_structure_type
--                                        and published_flag = 'N'
--                                        and date_computed <= p_as_of_date
--                  and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES'
-- , NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */

-- Begin fix for Bug # 4243074.

and NVL(proj_element_id,-1) = DECODE(p_structure_type, 'FINANCIAL'
                             , DECODE(p_object_type, 'PA_STRUCTURES'
                                           , 0
                                       --bug 4250623, for deliverable dont compare with p_proj_element_id as it may not be associated with task
                                       --, (DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id))))
                                       , (DECODE(p_object_type, 'PA_DELIVERABLES', NVL(proj_element_id,-1),NVL(p_proj_element_id, p_object_id))))
                             --bug 4250623, for deliverable dont compare with p_proj_element_id as it may not be associated with task
                             --,(DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id))))
                             ,(DECODE(p_object_type, 'PA_DELIVERABLES', NVL(proj_element_id,-1),NVL(p_proj_element_id, p_object_id))))

-- End fix for Bug # 4243074.

                    --and task_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
--                                     )

--              and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
-- Commented out to fix Bug # 4243074.

          --and proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
          ;

return l_rollup_date;

exception when others then
  return null;
end get_max_rollup_asofdate;

function get_project_wq_flag(p_project_id  IN  NUMBER) return varchar2 is
  l_wq_enable_flag   varchar2(1);
begin
   select wq_enable_flag
     into l_wq_enable_flag
     from pa_proj_progress_attr
    where project_id = p_project_id
      and object_Type = 'PA_STRUCTURES'
      and structure_type = 'WORKPLAN' -- FPM Dev CR 3
      ;

    return l_wq_enable_flag;
exception when others then
    return 'N';
end get_project_wq_flag;

PROCEDURE copy_attachments (
  p_project_id                  IN NUMBER,
  p_object_id                   IN NUMBER,
  p_object_type                 IN VARCHAR2,
  p_from_pc_id                  IN NUMBER,
  p_to_pc_id                    IN NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
cursor get_ppc_id is
  select percent_complete_id
    from pa_percent_completes
   where project_id = p_project_id
     and object_id = p_object_id
     and object_type = p_object_type
     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
     and published_flag = 'Y'
     and current_flag = 'Y';

 l_from_pc_id  NUMBER;
BEGIN

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  if (p_from_pc_id is null) then
      open get_ppc_id;
      fetch get_ppc_id into l_from_pc_id;
      close get_ppc_id;
  else
      l_from_pc_id := p_from_pc_id;
  end if;

  if (l_from_pc_id is not null) then
    fnd_attached_documents2_pkg.copy_attachments(
      X_from_entity_name => 'PA_PERCENT_COMPLETES',
      X_from_pk1_value => l_from_pc_id,
      X_to_entity_name => 'PA_PERCENT_COMPLETES',
      X_to_pk1_value => p_to_pc_id,
      X_created_by => fnd_global.user_id,
      X_last_update_login => fnd_global.login_id);
  end if;


  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                            p_procedure_name => 'COPY_ATTACHMENTS',
                            p_error_text     => SUBSTRB(SQLERRM,1,120));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END copy_attachments;


function is_task_manager (p_task_id           IN  NUMBER,
                          p_project_id        IN  NUMBER,
                          p_user_id           IN  NUMBER) return varchar2 IS

  CURSOR l_get_task_manager(c_element_version_id NUMBER)
  IS
  SELECT ppe.manager_person_id
  FROM pa_proj_elements PPE,
       pa_proj_element_versions PPEV
  WHERE ppev.element_version_id = c_element_version_id
  AND ppev.proj_element_id = ppe.proj_element_id;

  CURSOR l_get_parent_task(c_element_version_id NUMBER)
  IS
  SELECT rel.object_id_from1
  FROM pa_object_relationships rel
  WHERE rel.object_id_to1 = c_element_version_id
  AND rel.object_type_to = 'PA_TASKS'
  AND rel.relationship_type = 'S'
  AND rel.object_type_from = 'PA_TASKS';

  CURSOR l_get_element_version_id(c_proj_element_id NUMBER, c_parent_structure_version_id NUMBER)
  IS
  SELECT ppev.element_version_id
  FROM pa_proj_element_versions ppev
  WHERE ppev.proj_element_id = c_proj_element_id
  AND ppev.parent_structure_version_id = c_parent_structure_version_id;

  CURSOR l_get_latest_pub_structure_ver
  IS
  SELECT ppevs.element_version_id
  FROM pa_proj_elem_ver_structure ppevs
  WHERE ppevs.project_id = p_project_id
  AND ppevs.latest_eff_published_flag = 'Y';

  l_person_id NUMBER;
  l_temp_person_id NUMBER;
  l_is_task_manager VARCHAR2(1);
  l_latest_pub_structure_ver_id NUMBER;
  l_element_version_id NUMBER;
BEGIN
  l_is_task_manager := 'N';
  l_person_id := PA_UTILS.GetEmpIdFromUser(p_user_id);

/*
  OPEN l_get_latest_pub_structure_ver;
  FETCH l_get_latest_pub_structure_ver INTO l_latest_pub_structure_ver_id;
  CLOSE l_get_latest_pub_structure_ver;
*/

  --Added the following line instead of the above cursor.
  l_latest_pub_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(p_project_id); --maansari7/22

  OPEN l_get_element_version_id(p_task_id, l_latest_pub_structure_ver_id);
  FETCH l_get_element_version_id INTO l_element_version_id;
  CLOSE l_get_element_version_id;

  WHILE((l_element_version_id is not NULL) AND (l_is_task_manager = 'N')) LOOP
    OPEN l_get_task_manager(l_element_version_id);
    FETCH l_get_task_manager INTO l_temp_person_id;
    CLOSE l_get_task_manager;

    if(l_person_id = l_temp_person_id) then
      l_is_task_manager := 'Y';
    end if;

    OPEN l_get_parent_task(l_element_version_id);
    FETCH l_get_parent_task INTO l_element_version_id;
    if l_get_parent_task%NOTFOUND then
      l_element_version_id := NULL;
    end if;
    CLOSE l_get_parent_task;
  END LOOP;

  return l_is_task_manager;

EXCEPTION
  WHEN OTHERS THEN
    return 'N';
END is_task_manager;

-- Bug 3010538 : New API for the Task Weighting Enhancement.
-- This is a function that returns the task weighting basis code given the project id.
FUNCTION GET_TASK_WEIGHTING_BASIS(
    p_project_id  IN  pa_projects_all.project_id%TYPE
    , p_structure_type IN VARCHAR2 := 'WORKPLAN' -- FPM Dev CR 3
)
RETURN VARCHAR2 IS
     -- This cursor obtains the task weight basis code for the project id.
     Cursor cur_weight_basis_code (c_project_id pa_projects_all.project_id%TYPE)
     Is
     Select ppa.task_weight_basis_code
     From   pa_proj_progress_attr ppa,pa_proj_structure_types pst,pa_structure_types st
     Where  ppa.project_id  = c_project_id
     And    ppa.object_type = 'PA_STRUCTURES'
     And ppa.structure_type = p_structure_type -- FPM Dev CR 3
     And    ppa.object_id   = pst.proj_element_id
        And    st.structure_type = 'WORKPLAN'
     And    st.structure_type_id = pst.structure_type_id;

     l_weight_basis_code PA_PROJ_PROGRESS_ATTR.task_weight_basis_code%TYPE;
BEGIN
     open cur_weight_basis_code(p_project_id);
     fetch cur_weight_basis_code into l_weight_basis_code;
     close cur_weight_basis_code;

     return l_weight_basis_code;

END GET_TASK_WEIGHTING_BASIS;

FUNCTION is_object_progressable(p_project_id            IN              NUMBER
                                ,p_proj_element_id      IN              NUMBER
                                ,p_object_id            IN              NUMBER
                                ,p_object_type          IN              VARCHAR2) return VARCHAR2
IS
    l_return_value      VARCHAR2(1) := 'N';
    l_status_code       VARCHAR2(150);
    l_system_status_code    VARCHAR2(30);
BEGIN
    if (p_object_type = 'PA_STRUCTURES' or p_object_type = 'PA_ASSIGNMENTS') then
        l_return_value := 'Y';
    elsif (p_object_type = 'PA_TASKS') then

        select status_code
        into l_status_code
        from pa_proj_elements
        where project_id = p_project_id
        and proj_element_id = p_proj_element_id
        and object_type = p_object_type;

        l_system_status_code := pa_progress_utils.get_system_task_status(l_status_code);

--Commented by rtarway for BUG 3762650
--      if (l_system_status_code = 'CANCELLED' or l_system_status_code = 'ON_HOLD') then
            if (l_system_status_code = 'CANCELLED' ) then

            l_return_value := 'N';
        else

            select ptt.prog_entry_enable_flag
            into l_return_value
            from pa_proj_elements ppe, pa_task_types ptt
            where ppe.type_id = ptt.task_type_id(+)
            and ppe.project_id = p_project_id
            and ppe.proj_element_id = p_proj_element_id;
        end if;
    elsif (p_object_type = 'PA_DELIVERABLES') then
        l_return_value := PA_DELIVERABLE_UTILS.IS_DLV_PROGRESSABLE(p_project_id,p_proj_element_id);
    end if;
    return(l_return_value);
END is_object_progressable;


FUNCTION check_wp_working_prog_exists(p_project_id            IN              NUMBER
                                ,p_structure_version_id      IN              NUMBER
                ) return VARCHAR2
IS
   l_return_value    VARCHAR2(1) := 'Y';
BEGIN
   RETURN l_return_value;
END check_wp_working_prog_exists;


FUNCTION is_pc_override_allowed(p_project_id            IN              NUMBER
                                ,p_structure_type        IN              VARCHAR2 := 'WORKPLAN'
                ) return VARCHAR2
IS
   l_return_value    VARCHAR2(1) := 'N';
   l_percent_comp_enable_flag VARCHAR2(1) := NULL;
   l_allow_phy_prcnt_cmp_overrds VARCHAR2(1) := NULL;

    cursor c1(p_project_id NUMBER, p_structure_type VARCHAR2) is
        select percent_comp_enable_flag,allow_phy_prcnt_cmp_overrides
        from pa_proj_progress_attr
        where project_id = p_project_id
        and structure_type = p_structure_type;

    l_c1rec c1%rowtype;

BEGIN
    open c1(p_project_id, p_structure_type);
    fetch c1 into l_c1rec;
    close c1;

    if (l_c1rec.percent_comp_enable_flag = 'N') then
        l_return_value := l_c1rec.percent_comp_enable_flag;
    else
        l_return_value := l_c1rec.allow_phy_prcnt_cmp_overrides;
    end if;

    RETURN l_return_value;

END is_pc_override_allowed;

FUNCTION calculate_percentage( p_actual_value   NUMBER
                               ,p_planned_value  NUMBER ) return NUMBER
IS
BEGIN
   RETURN ((p_actual_value/p_planned_value)*100);
END calculate_percentage;

FUNCTION GET_EARLIEST_AS_OF_DATE(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
    ,p_task_id     NUMBER := null /* Modified for IB4 Progress CR. */
    ) RETURN DATE IS

  CURSOR cur_ppc
  IS
    SELECT min(date_computed)
      FROM pa_percent_completes
     WHERE object_id = p_object_id
       AND project_id = p_project_id
       and object_type = p_object_type
       AND structure_type = p_structure_type
       and NVL(task_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id,NVL(task_id,-1)),NVL(p_task_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
       --and task_id = nvl(p_task_id, p_object_id) /* Modified for IB4 Progress CR. */;
       ;
  l_as_of_date  DATE;
BEGIN

     OPEN cur_ppc;
     FETCH cur_ppc INTO l_as_of_date;
     CLOSE cur_ppc;
     RETURN l_as_of_date ;

exception when others then
     return null;

END GET_EARLIEST_AS_OF_DATE;

FUNCTION check_assignment_exists(
     p_project_id   NUMBER
    ,p_object_version_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
 ) RETURN VARCHAR2
IS

l_return_value VARCHAR2(1) := 'Y';

BEGIN

    l_return_value := pa_task_assignment_utils.check_asgmt_exists_in_task(p_object_version_id);

    RETURN (l_return_value);
END check_assignment_exists;

-- Bug 3633293 : Added check_deliverable_exists
FUNCTION check_deliverable_exists(
     p_project_id   NUMBER
    ,p_object_id    NUMBER
 ) RETURN VARCHAR2
IS
l_return_value VARCHAR2(1) := 'Y';
l_dummy VARCHAR2(1);
CURSOR c_get_del_associated_task IS
   SELECT 'x'
   FROM pa_proj_elements ppe,
    pa_object_relationships por,
    pa_task_types ttype
   WHERE
              ppe.object_type = 'PA_TASKS'
          and ppe.proj_element_id = por.object_id_from2
          and por.object_type_from = 'PA_TASKS'
          and por.object_type_to = 'PA_DELIVERABLES'
          and por.relationship_type = 'A'
          and por.relationship_subtype = 'TASK_TO_DELIVERABLE'
          and nvl(ppe.base_percent_comp_deriv_code,ttype.base_percent_comp_deriv_code)='DELIVERABLE'
      and ppe.proj_element_id = p_object_id
      and ppe.type_id = ttype.task_type_id;

BEGIN
    OPEN c_get_del_associated_task;
    FETCH c_get_del_associated_task INTO l_dummy;
    IF c_get_del_associated_task%NOTFOUND THEN
        l_return_value := 'N';
    ELSE
        l_return_value := 'Y';
    END IF;
    CLOSE c_get_del_associated_task;
    RETURN (l_return_value);
END check_deliverable_exists;

FUNCTION get_last_effort(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_as_of_date  DATE
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
    ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER IS

  CURSOR cur_task_effort
  IS
    SELECT NVL( EQPMT_ACT_EFFORT_TO_DATE, 0 ) + NVL( PPL_ACT_EFFORT_TO_DATE, 0 ) + nvl(oth_quantity_to_date,0)
     FROM pa_progress_rollup
    WHERE  project_id = p_project_id
     AND   object_id  = p_object_id
     --Commented by rtarway for BUG 3835474
     /*AND   as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup
                          WHERE as_of_date < p_as_of_date
                           AND  project_id = p_project_id
                           AND object_id  = p_object_id
                           AND object_type = p_object_type
                           AND structure_type = p_structure_type
                           and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR.
                   --and proj_element_id = nvl(p_proj_element_id, p_object_id)  Modified for IB4 Progress CR.
                       )*/
     --Added by rtarway for BUG 3835474
     AND   as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date <= p_as_of_date
                           AND  ppr2.project_id = p_project_id
                           AND ppr2.object_id  = p_object_id
                           AND ppr2.object_type = p_object_type
                           AND ppr2.structure_type = p_structure_type
               AND ppr2.current_flag <> 'W'   -- Bug 3879461
               AND ppr2.structure_version_id is null   -- Bug 3879461
                           and NVL(ppr2.proj_element_id,-1)
                           = DECODE(p_object_type, 'PA_DELIVERABLES',
                                    NVL(p_proj_element_id,
                                        NVL(ppr2.proj_element_id,-1)),
                                    NVL(p_proj_element_id, p_object_id)
                                   ) /* Amit : Modified for IB4 Progress CR. */
--                           AND NOT EXISTS
--                           (
--                      SELECT 'X' FROM pa_percent_completes ppc
--                      WHERE ppc.date_computed = ppr2.as_of_date
--                      AND   ppc.project_id = p_project_id
--                      AND   ppc.object_id  = p_object_id
--                      AND   ppc.object_type = p_object_type
--                      AND   ppc.structure_type = p_structure_type
--                      AND   ppc.published_flag = 'N'
--                           )
                      )
     AND   object_type = p_object_type
     AND structure_type = p_structure_type
     AND current_flag <> 'W'   -- Bug 3879461
     AND structure_version_id is null   -- Bug 3879461
     and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
     --and proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
    ;
    l_last_submitted_effort    NUMBER;
BEGIN

    OPEN cur_task_effort;
    FETCH cur_task_effort INTO l_last_submitted_effort;
    CLOSE cur_task_effort;

    RETURN l_last_submitted_effort;
END get_last_effort;

FUNCTION get_last_cost(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_as_of_date  DATE
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
    ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER IS

  CURSOR cur_task_cost
  IS
    SELECT (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)+nvl(ppr.eqpmt_act_cost_to_date_tc,0))
     FROM pa_progress_rollup ppr
    WHERE  ppr.project_id = p_project_id
     AND   ppr.object_id  = p_object_id
     AND   ppr.as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date < p_as_of_date
                           AND  ppr2.project_id = p_project_id
                           AND ppr2.object_id  = p_object_id
                           AND ppr2.object_type = p_object_type
                           AND ppr2.structure_type = p_structure_type
               AND ppr2.current_flag <> 'W'   -- Bug 3879461
               AND ppr2.structure_version_id is null   -- Bug 3879461
                       and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
                       --and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                       )
     AND   ppr.object_type = p_object_type
     AND ppr.structure_type = p_structure_type
     AND ppr.current_flag <> 'W'   -- Bug 3879461
     AND ppr.structure_version_id is null   -- Bug 3879461
     and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
     --and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
     ;

  l_last_submitted_cost    NUMBER;

BEGIN

    OPEN cur_task_cost;
    FETCH cur_task_cost INTO l_last_submitted_cost;
    CLOSE cur_task_cost;

    RETURN l_last_submitted_cost;
END get_last_cost;


-- Bug 4372462 : Rewritten this API again...

PROCEDURE convert_currency_amounts(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
 ,p_task_id                     IN      NUMBER
 ,p_as_of_date                  IN      DATE
 ,P_txn_cost                    IN      NUMBER
 ,P_txn_curr_code               IN      VARCHAR2
 ,p_structure_version_id        IN      NUMBER      -- Bug 3627787
 ,p_calling_mode        IN  VARCHAR2        := 'ACTUAL_RATES' -- Bug 4372462
 ,p_budget_version_id           IN      NUMBER          := null -- Bug 4372462
 ,p_res_assignment_id           IN      NUMBER          := null -- Bug 4372462
 ,p_init_inout_vars             IN      VARCHAR2        := 'Y' -- Bug 4372462
 ,P_project_curr_code           IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_project_rate_type           IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_project_rate_date           IN OUT  NOCOPY DATE --File.Sql.39 bug 4440895
 ,P_project_exch_rate           IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,P_project_raw_cost            IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,P_projfunc_curr_code          IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_projfunc_cost_rate_type     IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_projfunc_cost_rate_date     IN OUT  NOCOPY DATE --File.Sql.39 bug 4440895
 ,P_projfunc_cost_exch_rate     IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,P_projfunc_raw_cost           IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

l_api_name           CONSTANT   VARCHAR2(30)    := 'CONVERT_CURRENCY_AMOUNTS';
l_api_version        CONSTANT   NUMBER          := p_api_version;
l_user_id                       NUMBER          := FND_GLOBAL.USER_ID;
l_login_id                      NUMBER          := FND_GLOBAL.LOGIN_ID;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;

--bug 3828542
l_status               VARCHAR2(30);

CURSOR ou_exp_org_id IS
SELECT org_id from pa_implementations;

-- Bug 4372462 : written new cursor proj_all
--CURSOR proj_all IS
--SELECT project_currency_code, projfunc_currency_code
--FROM pa_projects_all
--WHERE project_id = p_project_id;

CURSOR proj_all IS
SELECT ppa.project_currency_code,
    ppfo.project_cost_rate_type,
    ppfo.project_cost_rate_date_type,
    ppfo.project_cost_rate_date,
    ppa.projfunc_currency_code,
    ppfo.projfunc_cost_rate_type,
    ppfo.projfunc_cost_rate_date_type,
    ppfo.projfunc_cost_rate_date,
    ppfo.proj_fp_options_id
FROM pa_projects_all ppa,
    pa_proj_fp_options ppfo
WHERE ppa.project_id = p_project_id
and ppfo.fin_plan_type_id = (select fin_plan_type_id
            from pa_fin_plan_types_b
               where use_for_workplan_flag = 'Y')
and ppfo.project_id = p_project_id
and ppfo.fin_plan_option_level_code = 'PLAN_TYPE';

-- Bug 4372462 Begin
--- get the override conversion rates for PC and PFC
CURSOR bgt_line_rates(c_budget_version_id NUMBER, c_res_assignment_id NUMBER, c_txn_curr_code VARCHAR2, c_as_of_date Date) IS
SELECT resource_assignment_id,
       start_date,
       end_date,
       project_cost_rate_type,
       project_cost_rate_date_type,
       project_cost_rate_date,
       project_cost_exchange_rate,
       projfunc_cost_rate_type,
       projfunc_cost_rate_date_type,
       projfunc_cost_rate_date,
       projfunc_cost_exchange_rate
FROM pa_budget_lines
where budget_version_id = c_budget_version_id
and resource_assignment_id = c_res_assignment_id
and c_as_of_date between start_date and end_date
and txn_currency_code = c_txn_curr_code;

--- get the user rates if rate tyep is User
CURSOR user_cur_details(c_proj_fp_options_id NUMBER, c_txn_curr_code VARCHAR2) IS
SELECT c.projfunc_cost_exchange_rate
  ,c.project_cost_exchange_rate
FROM pa_fp_txn_currencies c
WHERE c.proj_fp_options_id = c_proj_fp_options_id
AND   c.txn_currency_code = c_txn_curr_code ;

--- this cursor gets period set name and time phasing for project for use
--- by next cursor defined
CURSOR get_name_and_type_csr(c_budget_version_id NUMBER) IS
SELECT gsb.period_set_name
    ,gsb.accounted_period_type
    ,pia.pa_period_type
    ,decode(pbv.version_type,
        'COST',ppfo.cost_time_phased_code,
        'REVENUE',ppfo.revenue_time_phased_code,
         ppfo.all_time_phased_code) time_phase_code
FROM gl_sets_of_books           gsb
    ,pa_implementations_all pia
    ,pa_projects_all        ppa
    ,pa_budget_versions     pbv
    ,pa_proj_fp_options     ppfo
WHERE ppa.project_id        = pbv.project_id
AND pbv.budget_version_id = ppfo.fin_plan_version_id
--AND nvl(ppa.org_id,-99)   = nvl(pia.org_id,-99)  R12: Bug 4363092:
AND ppa.org_id   = pia.org_id
AND gsb.set_of_books_id   = pia.set_of_books_id
AND pbv.budget_version_id = c_budget_version_id;

--- this cursor is used to get start_date and end_Date for periods
--- need this for rate_date_type
CURSOR get_gl_periods_csr(c_period_set_name VARCHAR2, c_accounted_period_type VARCHAR2, c_pa_period_type VARCHAR2, c_time_phase_code VARCHAR2, c_as_of_date Date ) IS
SELECT START_DATE, END_DATE, PERIOD_NAME
FROM gl_periods gp
WHERE gp.period_set_name  = c_period_set_name
AND gp.period_type      = decode(c_time_phase_code,'G',c_accounted_period_type,'P',c_pa_period_type)
AND gp.adjustment_period_flag = 'N'
AND gp.start_date  <= c_as_of_date
AND gp.end_date   >= c_as_of_date
ORDER BY gp.start_date;

l_proj_all          proj_all%rowtype;
l_bgt_line_rates        bgt_line_rates%rowtype;
l_user_cur_details      user_cur_details%rowtype;
l_pc_conv           VARCHAR2(1) := 'N';
l_pfc_conv          VARCHAR2(1) := 'N';
l_time_phase_code       VARCHAR2(1);
l_period_set_name       VARCHAR2(15);
l_accounted_period_type     VARCHAR2(15);
l_pa_period_type        VARCHAR2(15);

l_start_date            DATE;
l_end_date          DATE;

l_period_name           VARCHAR2(15);
l_projfunc_cost_exchange_rate   NUMBER;
l_project_cost_exchange_rate    NUMBER;
tmp_project_rate_type       VARCHAR2(30);
tmp_project_rate_date       DATE;
tmp_project_exch_rate       NUMBER;
tmp_project_raw_cost        NUMBER;
tmp_projfunc_rate_type      VARCHAR2(30);
tmp_projfunc_rate_date      DATE;
tmp_projfunc_exch_rate      NUMBER;
tmp_projfunc_raw_cost       NUMBER;

g1_debug_mode           VARCHAR2(1);
-- Bug 4372462 End

l_org_id            NUMBER;
l_acct_rate_date        DATE;
l_acct_rate_type        VARCHAR2(30);
l_acct_exch_rate        NUMBER;
l_acct_raw_cost         NUMBER;
l_project_curr_code     VARCHAR2(30);
l_projfunc_curr_code        VARCHAR2(30);
l_project_curr_code2        VARCHAR2(30);
l_projfunc_curr_code2       VARCHAR2(30);
--bug# 3627315
--l_stage                   VARCHAR2(2000);
l_stage             NUMBER;


BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'Starts', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'p_task_id='||p_task_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_txn_cost='||P_txn_cost, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_txn_curr_code='||P_txn_curr_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'p_calling_mode='||p_calling_mode, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'p_budget_version_id='||p_budget_version_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'p_res_assignment_id='||p_res_assignment_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_project_curr_code='||P_project_curr_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_projfunc_curr_code='||P_projfunc_curr_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'p_init_inout_vars='||p_init_inout_vars, x_Log_Level=> 3);
    END IF;

    IF p_init_inout_vars = 'Y' THEN
            -- This is being done so that if calling API's have two consecutive calls of
        -- this API with same local variables. Then they will get wrong data.
        -- instead of changing all of the calling API's, we are changing it here
        P_project_rate_type           := null;
        P_project_rate_date           := null;
        P_project_exch_rate           := null;
        P_project_raw_cost            := null;
        P_projfunc_cost_rate_type     := null;
        P_projfunc_cost_rate_date     := null;
        P_projfunc_cost_exch_rate     := null;
        P_projfunc_raw_cost           := null;
    END IF;


        OPEN ou_exp_org_id;
        FETCH ou_exp_org_id INTO l_org_id;
        CLOSE ou_exp_org_id;

    -- Bug 4372462 : New call below
        --OPEN proj_all;
        --FETCH proj_all INTO l_project_curr_code2, l_projfunc_curr_code2;
        --CLOSE proj_all;

        OPEN proj_all;
        FETCH proj_all INTO l_proj_all;
        CLOSE proj_all;


        IF p_project_curr_code IS NULL
        THEN
            l_project_curr_code := l_proj_all.project_currency_code;
        ELSE
            l_project_curr_code := p_project_curr_code;
        END IF;

        IF p_projfunc_curr_code  IS NULL
        THEN
            l_projfunc_curr_code := l_proj_all.projfunc_currency_code;
        ELSE
            l_projfunc_curr_code := p_projfunc_curr_code;
        END IF;

        IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_org_id='||l_org_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.project_currency_code='||l_proj_all.project_currency_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.project_cost_rate_type='||l_proj_all.project_cost_rate_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.project_cost_rate_date_type='||l_proj_all.project_cost_rate_date_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.project_cost_rate_date='||l_proj_all.project_cost_rate_date, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.projfunc_currency_code='||l_proj_all.projfunc_currency_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.projfunc_cost_rate_type='||l_proj_all.projfunc_cost_rate_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.projfunc_cost_rate_date_type='||l_proj_all.projfunc_cost_rate_date_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.projfunc_cost_rate_date='||l_proj_all.projfunc_cost_rate_date, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_proj_all.proj_fp_options_id='||l_proj_all.proj_fp_options_id, x_Log_Level=> 3);
    END IF;

    IF P_txn_curr_code = l_project_curr_code THEN
        P_project_raw_cost := P_txn_cost;
        l_pc_conv := 'Y';
    END IF;
    IF P_txn_curr_code = l_projfunc_curr_code THEN
        P_projfunc_raw_cost := P_txn_cost;
        l_pfc_conv := 'Y';
    END IF;

    IF p_calling_mode = 'PLAN_RATES' AND (l_pc_conv = 'N' OR l_pfc_conv = 'N') THEN
        IF p_budget_version_id IS NULL OR p_res_assignment_id IS NULL THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_INV_PARAM_PASSED');
            x_msg_data := 'PA_INV_PARAM_PASSED';
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

        OPEN bgt_line_rates(p_budget_version_id, p_res_assignment_id, p_txn_curr_code, p_as_of_date);
        FETCH bgt_line_rates INTO l_bgt_line_rates;
        CLOSE bgt_line_rates;

        OPEN user_cur_details(l_proj_all.proj_fp_options_id, p_txn_curr_code);
        FETCH user_cur_details INTO l_projfunc_cost_exchange_rate, l_project_cost_exchange_rate;
        CLOSE user_cur_details;

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.resource_assignment_id='||l_bgt_line_rates.resource_assignment_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.project_cost_exchange_rate='||l_bgt_line_rates.project_cost_exchange_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.project_cost_rate_type='||l_bgt_line_rates.project_cost_rate_type, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.project_cost_rate_date='||l_bgt_line_rates.project_cost_rate_date, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.project_cost_rate_date_type='||l_bgt_line_rates.project_cost_rate_date_type, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.projfunc_cost_exchange_rate='||l_bgt_line_rates.projfunc_cost_exchange_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.projfunc_cost_rate_type='||l_bgt_line_rates.projfunc_cost_rate_type, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.projfunc_cost_rate_date='||l_bgt_line_rates.projfunc_cost_rate_date, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_bgt_line_rates.projfunc_cost_rate_date_type='||l_bgt_line_rates.projfunc_cost_rate_date_type, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_projfunc_cost_exchange_rate='||l_projfunc_cost_exchange_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'l_project_cost_exchange_rate='||l_project_cost_exchange_rate, x_Log_Level=> 3);
        END IF;


        IF l_bgt_line_rates.resource_assignment_id IS NOT NULL THEN
            -- Data is there in budget lines table

            --- PC Conv
            IF l_pc_conv = 'N' THEN
                IF l_bgt_line_rates.project_cost_exchange_rate is not null THEN
                    --- calc cost
                    l_pc_conv := 'Y';
                    P_project_curr_code     := l_project_curr_code;
                    P_project_rate_type     := l_bgt_line_rates.project_cost_rate_type;
                    P_project_rate_date     := l_bgt_line_rates.project_cost_rate_date;
                    P_project_exch_rate     := l_bgt_line_rates.project_cost_exchange_rate;
                    P_project_raw_cost      := P_txn_cost * P_project_exch_rate;
                ELSIF NVL(l_bgt_line_rates.project_cost_rate_type,l_proj_all.project_cost_rate_type) is not null THEN
                    --- use this rate type
                    IF NVL(l_bgt_line_rates.project_cost_rate_type,l_proj_all.project_cost_rate_type) = 'User' THEN
                        --- calc cost
                        l_pc_conv := 'Y';
                        P_project_curr_code   := l_project_curr_code;
                        P_project_rate_type   := nvl(l_bgt_line_rates.project_cost_rate_type,l_proj_all.project_cost_rate_type);
                        P_project_rate_date   := nvl(l_bgt_line_rates.project_cost_rate_date, l_proj_all.project_cost_rate_date);
                        P_project_exch_rate   := l_project_cost_exchange_rate;
                        P_project_raw_cost    := P_txn_cost * P_project_exch_rate;

                        IF l_project_cost_exchange_rate IS NULL THEN
                            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_FP_USER_EXCH_RATE_REQ');
                            x_msg_data := 'PA_FP_USER_EXCH_RATE_REQ';
                            x_return_status := FND_API.G_RET_STS_ERROR;
                            RAISE  FND_API.G_EXC_ERROR;
                        END IF;
                    ELSE
                        P_project_curr_code     := l_project_curr_code;
                        P_project_rate_type     := nvl(l_bgt_line_rates.project_cost_rate_Type,l_proj_all.project_cost_rate_type);
                        IF NVL(l_bgt_line_rates.project_cost_rate_date, l_proj_all.project_cost_rate_date) IS NOT NULL THEN
                            P_project_rate_date := NVL(l_bgt_line_rates.project_cost_rate_date, l_proj_all.project_cost_rate_date);
                        ELSE
                            IF NVL(l_bgt_line_rates.project_cost_rate_date_type, l_proj_all.project_cost_rate_date_type) = 'START_DATE' THEN
                                P_project_rate_date := l_bgt_line_rates.start_date;
                            ELSIF NVL(l_bgt_line_rates.project_cost_rate_date_type, l_proj_all.project_cost_rate_date_type) = 'END_DATE' THEN
                                P_project_rate_date := l_bgt_line_rates.end_date;
                            ELSIF NVL(l_bgt_line_rates.project_cost_rate_date_type, l_proj_all.project_cost_rate_date_type) = 'FIXED_DATE' THEN
                                P_project_rate_date := NVL(l_bgt_line_rates.project_cost_rate_date, l_proj_all.project_cost_rate_date);
                                -- This case should never come...This is an error
                            ELSE
                                P_project_rate_date := null; -- Costing API will derive using implmentation option setup
                            END IF;
                        END IF;
                    END IF; -- NVL(l_bgt_line_rates.project_cost_rate_type,l_proj_all.project_cost_rate_type) = 'User'
                END IF;   -- l_bgt_line_rates.project_cost_exchange_rate is not null
            END IF ; -- IF l_pc_conv = 'N'

            --- PFC Conv
            IF l_pfc_conv = 'N' THEN
                IF l_bgt_line_rates.projfunc_cost_exchange_rate is not null THEN
                    --- calc cost
                    l_pfc_conv := 'Y';
                    P_projfunc_curr_code        := l_projfunc_curr_code;
                    P_projfunc_cost_rate_type   := l_bgt_line_rates.projfunc_cost_rate_type;
                    P_projfunc_cost_rate_date   := l_bgt_line_rates.projfunc_cost_rate_date;
                    P_projfunc_cost_exch_rate   := l_bgt_line_rates.projfunc_cost_exchange_rate;
                    P_projfunc_raw_cost     := P_txn_cost * P_projfunc_cost_exch_rate;
                ELSIF NVL(l_bgt_line_rates.projfunc_cost_rate_type,l_proj_all.projfunc_cost_rate_type) is not null THEN
                    --- use this rate type
                    IF NVL(l_bgt_line_rates.projfunc_cost_rate_type,l_proj_all.projfunc_cost_rate_type) = 'User' THEN
                        --- calc cost
                        l_pfc_conv := 'Y';
                        P_projfunc_curr_code        := l_projfunc_curr_code;
                        P_projfunc_cost_rate_type   := nvl(l_bgt_line_rates.projfunc_cost_rate_type,l_proj_all.projfunc_cost_rate_type);
                        P_projfunc_cost_rate_date   := nvl(l_bgt_line_rates.projfunc_cost_rate_date, l_proj_all.projfunc_cost_rate_date);
                        P_projfunc_cost_exch_rate   := l_projfunc_cost_exchange_rate;
                        P_projfunc_raw_cost     := P_txn_cost * P_projfunc_cost_exch_rate;

                        IF l_projfunc_cost_exchange_rate IS NULL THEN
                            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_FP_USER_EXCH_RATE_REQ');
                            x_msg_data := 'PA_FP_USER_EXCH_RATE_REQ';
                            x_return_status := FND_API.G_RET_STS_ERROR;
                            RAISE  FND_API.G_EXC_ERROR;
                        END IF;
                    ELSE
                        P_projfunc_curr_code     := l_projfunc_curr_code;
                        P_projfunc_cost_rate_type     := nvl(l_bgt_line_rates.projfunc_cost_rate_type,l_proj_all.projfunc_cost_rate_type);
                        IF NVL(l_bgt_line_rates.projfunc_cost_rate_date, l_proj_all.projfunc_cost_rate_date) IS NOT NULL THEN
                            P_projfunc_cost_rate_date := NVL(l_bgt_line_rates.projfunc_cost_rate_date, l_proj_all.projfunc_cost_rate_date);
                        ELSE
                            IF NVL(l_bgt_line_rates.projfunc_cost_rate_date_type, l_proj_all.projfunc_cost_rate_date_type) = 'START_DATE' THEN
                                P_projfunc_cost_rate_date := l_bgt_line_rates.start_date;
                            ELSIF NVL(l_bgt_line_rates.projfunc_cost_rate_date_type, l_proj_all.projfunc_cost_rate_date_type) = 'END_DATE' THEN
                                P_projfunc_cost_rate_date := l_bgt_line_rates.end_date;
                            ELSIF NVL(l_bgt_line_rates.projfunc_cost_rate_date_type, l_proj_all.projfunc_cost_rate_date_type) = 'FIXED_DATE' THEN
                                P_projfunc_cost_rate_date := NVL(l_bgt_line_rates.project_cost_rate_date, l_proj_all.project_cost_rate_date);
                                -- This case should never come...This is an error
                            ELSE
                                P_projfunc_cost_rate_date := null; -- Costing API will derive using implmentation option setup
                            END IF;
                        END IF;
                    END IF; -- NVL(l_bgt_line_rates.projfunc_cost_rate_type,l_proj_all.projfunc_cost_rate_type) = 'User'
                END IF;   -- l_bgt_line_rates.projfunc_cost_exchange_rate is not null THEN
            END IF; -- IF l_pfc_conv = 'N'
        ELSE -- l_bgt_line_rates.resource_assignment_id IS NOT NULL
            OPEN get_name_and_type_csr(p_budget_version_id);
            FETCH get_name_and_type_csr INTO l_period_set_name, l_accounted_period_type, l_pa_period_type, l_time_phase_code;
            CLOSE get_name_and_type_csr;

            OPEN get_gl_periods_csr(l_period_set_name, l_accounted_period_type, l_pa_period_type, l_time_phase_code, p_as_of_date);
            FETCH get_gl_periods_csr INTO l_start_date, l_end_date, l_period_name;
            CLOSE get_gl_periods_csr;

            -- PC Conversion
            IF l_pc_conv = 'N' THEN
                IF (l_proj_all.project_cost_rate_type is null) THEN
                    null; -- means no currency rates override at WP level
                ELSE
                    --- use this rate type
                    IF l_proj_all.project_cost_rate_type = 'User' THEN
                        --- calc cost
                        l_pc_conv := 'Y';
                        P_project_curr_code   := l_project_curr_code;
                        P_project_rate_type   := l_proj_all.project_cost_rate_type;
                        P_project_rate_date   := l_proj_all.project_cost_rate_date;
                        P_project_exch_rate   := l_project_cost_exchange_rate;
                        P_project_raw_cost    := P_txn_cost * P_project_exch_rate;

                        IF l_project_cost_exchange_rate IS NULL THEN
                            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_FP_USER_EXCH_RATE_REQ');
                            x_msg_data := 'PA_FP_USER_EXCH_RATE_REQ';
                            x_return_status := FND_API.G_RET_STS_ERROR;
                            RAISE  FND_API.G_EXC_ERROR;
                        END IF;
                    ELSE
                        P_project_curr_code     := l_project_curr_code;
                        P_project_rate_type     := l_proj_all.project_cost_rate_type;
                        IF l_proj_all.project_cost_rate_date IS NOT NULL THEN
                            P_project_rate_date := l_proj_all.project_cost_rate_date;
                        ELSE
                            IF l_proj_all.project_cost_rate_date_type = 'START_DATE' THEN
                                P_project_rate_date := l_start_date;
                            ELSIF l_proj_all.project_cost_rate_date_type = 'END_DATE' THEN
                                P_project_rate_date := l_end_date;
                            ELSIF l_proj_all.project_cost_rate_date_type = 'FIXED_DATE' THEN
                                P_project_rate_date :=  l_proj_all.project_cost_rate_date;
                                -- This case should never come...This is an error
                            ELSE
                                P_project_rate_date := null; -- Costing API will derive using implmentation option setup
                            END IF;
                        END IF;
                    END IF; -- l_proj_all.project_cost_rate_type = 'User'
                END IF;   -- l_proj_all.project_cost_rate_type is null
            END IF ; -- IF l_pc_conv = 'N' THEN

            -- PFC Conversion
            IF l_pfc_conv = 'N' THEN
                IF (l_proj_all.projfunc_cost_rate_type is null) THEN
                    null; -- means no currency rates override at proj level
                ELSE
                    --- use this rate type
                    IF l_proj_all.projfunc_cost_rate_type = 'User' THEN
                        --- calc cost
                        l_pfc_conv := 'Y';
                        P_projfunc_curr_code        := l_projfunc_curr_code;
                        P_projfunc_cost_rate_type   := l_proj_all.projfunc_cost_rate_type;
                        P_projfunc_cost_rate_date   := l_proj_all.projfunc_cost_rate_date;
                        P_projfunc_cost_exch_rate   := l_projfunc_cost_exchange_rate;
                        P_projfunc_raw_cost     := P_txn_cost * P_projfunc_cost_exch_rate;

                        IF l_projfunc_cost_exchange_rate IS NULL THEN
                            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_FP_USER_EXCH_RATE_REQ');
                            x_msg_data := 'PA_FP_USER_EXCH_RATE_REQ';
                            x_return_status := FND_API.G_RET_STS_ERROR;
                            RAISE  FND_API.G_EXC_ERROR;
                        END IF;
                    ELSE
                        P_projfunc_curr_code        := l_projfunc_curr_code;
                        P_projfunc_cost_rate_type   := l_proj_all.projfunc_cost_rate_type;
                        IF l_proj_all.projfunc_cost_rate_date IS NOT NULL THEN
                            P_projfunc_cost_rate_date := l_proj_all.projfunc_cost_rate_date;
                        ELSE
                            IF l_proj_all.projfunc_cost_rate_date_type = 'START_DATE' THEN
                                P_projfunc_cost_rate_date := l_start_date;
                            ELSIF l_proj_all.projfunc_cost_rate_date_type = 'END_DATE' THEN
                                P_projfunc_cost_rate_date := l_end_date;
                            ELSIF l_proj_all.projfunc_cost_rate_date_type = 'FIXED_DATE' THEN
                                P_projfunc_cost_rate_date :=  l_proj_all.project_cost_rate_date;
                                -- This case should never come...This is an error
                            ELSE
                                P_projfunc_cost_rate_date := null; -- Costing API will derive using implmentation option setup
                            END IF;
                        END IF;
                    END IF; -- l_proj_all.projfunc_cost_rate_type = 'User'
                END IF;   -- l_proj_all.projfunc_cost_rate_type is null
            END IF;--IF l_pfc_conv = 'N' THEN

        END IF; -- l_bgt_line_rates.resource_assignment_id IS NOT NULL
    END IF; -- p_calling_mode = 'PLAN_RATES'

    IF (l_pc_conv = 'N' OR l_pfc_conv = 'N') THEN
        tmp_project_rate_type := P_project_rate_type;
        tmp_project_rate_date := P_project_rate_date;
        tmp_project_exch_rate := P_project_exch_rate;
        tmp_project_raw_cost  := P_project_raw_cost;

        tmp_projfunc_rate_type := P_projfunc_cost_rate_type;
        tmp_projfunc_rate_date := P_projfunc_cost_rate_date;
        tmp_projfunc_exch_rate := P_projfunc_cost_exch_rate;
        tmp_projfunc_raw_cost  := P_projfunc_raw_cost;

        IF l_pc_conv = 'Y' THEN
            -- This is possible when TXN to PC is User and rate is found
            -- So if we pass this rate type to Costing API
            -- It will error out..
            tmp_project_rate_type := P_projfunc_cost_rate_type;
            tmp_project_rate_date := P_projfunc_cost_rate_date;
            tmp_project_exch_rate := P_projfunc_cost_exch_rate;
            tmp_project_raw_cost := P_projfunc_raw_cost;
        END IF;
        IF l_pfc_conv = 'Y' THEN
            tmp_projfunc_rate_type := P_project_rate_type;
            tmp_projfunc_rate_date := P_project_rate_date;
            tmp_projfunc_exch_rate := P_project_exch_rate;
            tmp_projfunc_raw_cost  := P_project_raw_cost;
        END IF;

        BEGIN
            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'Calling pa_multi_currency_txn.get_currency_amounts', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'tmp_project_rate_type='||tmp_project_rate_type, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'tmp_project_rate_date='||tmp_project_rate_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'tmp_project_exch_rate='||tmp_project_exch_rate, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'tmp_project_raw_cost='||tmp_project_raw_cost, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'tmp_projfunc_rate_type='||tmp_projfunc_rate_type, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'tmp_projfunc_rate_date='||tmp_projfunc_rate_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'tmp_projfunc_exch_rate='||tmp_projfunc_exch_rate, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'tmp_projfunc_raw_cost='||tmp_projfunc_raw_cost, x_Log_Level=> 3);
            END IF;

            pa_multi_currency_txn.get_currency_amounts (
                p_calling_module        => 'WORKPLAN', -- FPM Dev CR 3
                P_project_id            => p_project_id,
                P_exp_org_id            => l_org_id,
                P_task_id               => p_task_id,
                P_EI_date               => p_as_of_date,
                P_denom_raw_cost        => p_txn_cost,
                P_denom_curr_code       => P_txn_curr_code,
                P_acct_curr_code        => P_txn_curr_code,
                P_acct_rate_date        => l_acct_rate_date,
                P_acct_rate_type        => l_acct_rate_type,
                P_acct_exch_rate        => l_acct_exch_rate,
                P_acct_raw_cost         => l_acct_raw_cost,
                P_project_curr_code     => l_project_curr_code,
                P_project_rate_type     => tmp_project_rate_type ,
                P_project_rate_date     => tmp_project_rate_date,
                P_project_exch_rate     => tmp_project_exch_rate,
                P_project_raw_cost      => tmp_project_raw_cost,
                P_projfunc_curr_code    => l_projfunc_curr_code,
                p_projfunc_cost_rate_type  => tmp_projfunc_rate_type,
                P_projfunc_cost_rate_date  => tmp_projfunc_rate_date,
                P_projfunc_cost_exch_rate  => tmp_projfunc_exch_rate,
                P_projfunc_raw_cost        => tmp_projfunc_raw_cost,
                --P_status                   => l_return_status, --bug 3828542
                P_status                   => l_status,
                P_stage                    => l_stage,
                p_structure_version_id     => p_structure_version_id -- 3627787
                   );

            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'After Call l_status='||l_status, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'After Call l_stage='||l_stage, x_Log_Level=> 3);
            END IF;


        EXCEPTION
            WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                    p_procedure_name => 'CONVERT_CURRENCY_AMOUNTS',
                    p_error_text     => SUBSTRB('pa_multi_currency_txn.get_currency_amounts:'||SQLERRM,1,120));
                RAISE FND_API.G_EXC_ERROR;

        END;
        --bug 3828542 start
        IF ( l_status IS NOT NULL ) THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                     ,p_msg_name       => l_status);
            x_msg_data := l_status;
            l_return_status := 'E';
        END IF;
        --bug 3828542 end

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;


        IF l_pc_conv = 'N' THEN
            P_project_rate_type := tmp_project_rate_type;
            P_project_rate_date := tmp_project_rate_date;
            P_project_exch_rate := tmp_project_exch_rate;
            P_project_raw_cost := tmp_project_raw_cost;
        END IF;
        IF l_pfc_conv = 'N' THEN
            P_projfunc_cost_rate_type := tmp_projfunc_rate_type;
            P_projfunc_cost_rate_date := tmp_projfunc_rate_date;
            P_projfunc_cost_exch_rate := tmp_projfunc_exch_rate;
            P_projfunc_raw_cost := tmp_projfunc_raw_cost;
        END IF;
    END IF; --  IF (l_pc_conv = 'N' or l_pfc_conv = 'N') THEN

        IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'Ends', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_project_curr_code='||P_project_curr_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_project_rate_type='||P_project_rate_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_project_rate_date='||P_project_rate_date, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_project_exch_rate='||P_project_exch_rate, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_project_raw_cost='||P_project_raw_cost, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_projfunc_curr_code='||P_projfunc_curr_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_projfunc_cost_rate_type='||P_projfunc_cost_rate_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_projfunc_cost_rate_date='||P_projfunc_cost_rate_date, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_projfunc_cost_exch_rate='||P_projfunc_cost_exch_rate, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS', x_Msg => 'P_projfunc_raw_cost='||P_projfunc_raw_cost, x_Log_Level=> 3);

    END IF;

EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;

        -- 4537865 : Start
    ----    p_project_curr_code         := NULL ;  5081809
        P_project_rate_type         := NULL ;
        P_project_rate_date         := NULL ;
        P_project_exch_rate         := NULL ;
        P_project_raw_cost          := NULL ;
    ----    P_projfunc_curr_code        := NULL ;  5081809
        P_projfunc_cost_rate_type   := NULL ;
        P_projfunc_cost_rate_date   := NULL ;
        P_projfunc_cost_exch_rate   := NULL ;
        P_projfunc_raw_cost         := NULL ;
        -- 4537865 : End

    when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'convert_currency_amounts',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
        -- 4537865 : Start
    ----    p_project_curr_code         := NULL ;  5081809
        P_project_rate_type         := NULL ;
        P_project_rate_date         := NULL ;
        P_project_exch_rate         := NULL ;
        P_project_raw_cost          := NULL ;
    ----    P_projfunc_curr_code        := NULL ;  5081809
        P_projfunc_cost_rate_type   := NULL ;
        P_projfunc_cost_rate_date   := NULL ;
        P_projfunc_cost_exch_rate   := NULL ;
        P_projfunc_raw_cost         := NULL ;
        -- 4537865 : End

    when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'convert_currency_amounts',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));

    -- 4537865 : Start
    ---- p_project_curr_code         := NULL ;  5081809
    P_project_rate_type         := NULL ;
    P_project_rate_date         := NULL ;
    P_project_exch_rate         := NULL ;
    P_project_raw_cost          := NULL ;
    ---- P_projfunc_curr_code        := NULL ;  5081809
    P_projfunc_cost_rate_type   := NULL ;
    P_projfunc_cost_rate_date   := NULL ;
    P_projfunc_cost_exch_rate   := NULL ;
    P_projfunc_raw_cost         := NULL ;
    -- 4537865 : End
      raise;

END convert_currency_amounts;

FUNCTION get_time_phase_period(p_structure_version_id   IN  NUMBER
                   ,p_project_id        IN      NUMBER := NULL) return VARCHAR2
IS
    l_time_phase_code   VARCHAR2(30);
    l_structure_version_id  NUMBER;
BEGIN
    if p_structure_version_id is null then
        l_structure_version_id := PA_PROJ_ELEMENTS_UTILS.latest_published_ver_id(p_project_id, 'WORKPLAN');
    else
        l_structure_version_id := p_structure_version_id;
    end if;
    BEGIN
        l_time_phase_code := PA_FIN_PLAN_UTILS.Get_wp_bv_time_phase(l_structure_version_id);
     EXCEPTION
                WHEN OTHERS THEN
                        fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROGRESS_UTILS',
                                        p_procedure_name => 'get_time_phase_period',
                                        p_error_text     => SUBSTRB('PA_FIN_PLAN_UTILS.Get_wp_bv_time_phase:'||SQLERRM,1,120));
                        RAISE FND_API.G_EXC_ERROR;
         END;

    RETURN(l_time_phase_code);
END get_time_phase_period;

-- Bug 3879461 : Get_incremental functions are not used anymore
-- Moreover getting the previous period amount logic is wrong...
-- Now things are directly derived in pa_progress_pub.POPULATE_PRG_ACT_TEMP_TBL
FUNCTION get_incremental_actual_cost(p_as_of_date           IN              DATE
                                    ,p_period_name          IN              VARCHAR2
                                    ,pgn_flag               IN              VARCHAR2
                                    ,p_project_id           IN              NUMBER
                                    ,p_object_id            IN              NUMBER
                                    ,p_object_version_id    IN              NUMBER
                                    ,currency_flag          IN              VARCHAR2 := 'T'
                                    ,p_structure_version_id IN              NUMBER := null  --3694031
               ,p_proj_element_id       IN  NUMBER := null /* Modified for IB4 Progress CR. */
                            ) return NUMBER
IS
    l_actual_cost   NUMBER := NULL;
    l_prev_period_actual_cost NUMBER;
BEGIN

    if (currency_flag = 'P') then

       if p_structure_version_id IS NULL
       THEN

    if (pgn_flag = 'P') then

          begin
            select (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_pc,0)+nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0))
            into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_pa_period_name = p_period_name
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id IS NULL   --bug 3802177
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_pa_period_name = ppr.prog_pa_period_name
                     and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
             );

           exception when no_data_found then
                l_actual_cost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_pc,0)+nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0))
                  into l_prev_period_actual_cost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
               and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
                   and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                                     and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_pa_period_name = p_period_name
                             and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_cost := 0;
           end;
    elsif (pgn_flag ='G') then
          begin
            select (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_pc,0)+nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0))
            into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_gl_period_name = p_period_name
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
                and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_gl_period_name = ppr.prog_gl_period_name
                     and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_cost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_pc,0)+nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0))
                  into l_prev_period_actual_cost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_gl_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_cost := 0;
           end;
    elsif (pgn_flag = 'N') then
                select (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_pc,0)+nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0))
                into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                --and ppr.object_version_id = p_object_version_id
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
                and ppr.as_of_date = p_as_of_date
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    end if; -- pgn flag.
      ELSIF p_structure_version_id IS NOT NULL
      THEN
           select (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)
                    +nvl(ppr.eqpmt_act_cost_to_date_pc,0)+nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
                    +nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0))
           into l_actual_cost
           from pa_progress_rollup ppr
          where ppr.project_id = p_project_id
            and ppr.object_id = p_object_id
            and ppr.structure_version_id = p_structure_version_id
            and structure_type = 'WORKPLAN'
        and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;

      END IF;

    elsif (currency_flag) = 'T' then

      IF p_structure_version_id IS NULL
      THEN

    if (pgn_flag = 'P') then
          begin
            select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0))
            into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_pa_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_pa_period_name = ppr.prog_pa_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_cost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0))
                  into l_prev_period_actual_cost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_pa_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_cost := 0;
           end;
    elsif (pgn_flag ='G') then

          begin
            select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0))
            into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_gl_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_gl_period_name = ppr.prog_gl_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_cost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0))
                  into l_prev_period_actual_cost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_gl_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_cost := 0;
           end;
    elsif (pgn_flag = 'N') then
                select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0))
                into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
                and ppr.as_of_date = p_as_of_date
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    end if; -- pgn flag.
    ELSIF p_structure_version_id IS NOT NULL
    THEN
               select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
                        +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
                        +nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0))
                into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id = p_structure_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    END IF;

  elsif (currency_flag = 'F') then

     IF p_structure_version_id IS NULL
     THEN
    if (pgn_flag = 'P') then
          begin
            select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0))
            into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_pa_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_pa_period_name = ppr.prog_pa_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_cost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0))
                  into l_prev_period_actual_cost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_pa_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_cost := 0;
           end;
    elsif (pgn_flag ='G') then
          begin
            select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0))
            into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_gl_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_gl_period_name = ppr.prog_gl_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_cost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0))
                  into l_prev_period_actual_cost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_gl_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_cost := 0;
           end;
    elsif (pgn_flag = 'N') then
                select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0))
                into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
                and ppr.as_of_date = p_as_of_date
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    end if; -- pgn flag.

    ELSIF p_structure_version_id IS NOT NULL
    THEN
                select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)
                        +nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)
                        +nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0))
                into l_actual_cost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
                and structure_type = 'WORKPLAN'
                and ppr.structure_version_id = p_structure_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    END IF;

   end if; -- currency_flag.

    return(NVL(l_actual_cost,0) - nvl(l_prev_period_actual_cost,0));

END get_incremental_actual_cost;

FUNCTION get_incremental_actual_rawcost(p_as_of_date           IN              DATE
                                    ,p_period_name          IN              VARCHAR2
                                    ,pgn_flag               IN              VARCHAR2
                                    ,p_project_id           IN              NUMBER
                                    ,p_object_id            IN              NUMBER
                                    ,p_object_version_id    IN              NUMBER
                                    ,currency_flag          IN              VARCHAR2 := 'T'
                                    ,p_structure_version_id IN              NUMBER := null  --3694031
                ,p_proj_element_id      IN  NUMBER := null /* Modified for IB4 Progress CR. */
                        ) return NUMBER
IS
    l_actual_rawcost    NUMBER := NULL;
    l_prev_period_actual_rawcost NUMBER;
BEGIN

  if (currency_flag = 'P') then

     IF p_structure_version_id IS NULL
     THEN

    if (pgn_flag = 'P') then

          begin
            select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
            into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_pa_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_pa_period_name = ppr.prog_pa_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_rawcost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
                  into l_prev_period_actual_rawcost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_pa_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_rawcost := 0;
           end;
    elsif (pgn_flag ='G') then
          begin
            select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
            into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_gl_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_gl_period_name = ppr.prog_gl_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_rawcost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
                  into l_prev_period_actual_rawcost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_gl_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_rawcost := 0;
           end;
    elsif (pgn_flag = 'N') then
                select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
                into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                --and ppr.object_version_id = p_object_version_id
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
                and ppr.as_of_date = p_as_of_date
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    end if; -- pgn flag.
     ELSIF p_structure_version_id IS NOT NULL
     THEN
                select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
                        +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
                        +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
                into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id = p_structure_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
     END IF;

   elsif (currency_flag) = 'T' then

     IF p_structure_version_id IS NULL
     THEN
    if (pgn_flag = 'P') then
          begin
            select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0))
            into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_pa_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_pa_period_name = ppr.prog_pa_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_rawcost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0))
                  into l_prev_period_actual_rawcost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_pa_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_rawcost := 0;
           end;
    elsif (pgn_flag ='G') then

          begin
            select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0))
            into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_gl_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_gl_period_name = ppr.prog_gl_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_rawcost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0))
                  into l_prev_period_actual_rawcost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_gl_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_rawcost := 0;
           end;
    elsif (pgn_flag = 'N') then
                select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0))
                into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
                and ppr.as_of_date = p_as_of_date
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    end if; -- pgn flag.
      ELSIF p_structure_version_id IS NOT NULL
      THEN
                select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
                        +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
                        +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0))
                into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id = p_structure_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
      END IF;

   elsif (currency_flag = 'F') then

      IF p_structure_version_id IS NULL
      THEN
    if (pgn_flag = 'P') then
          begin
            select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0))
            into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_pa_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                  and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_pa_period_name = ppr.prog_pa_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_rawcost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0))
                  into l_prev_period_actual_rawcost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
                            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                                     and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_pa_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_rawcost := 0;
           end;
    elsif (pgn_flag ='G') then
          begin
            select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0))
            into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_gl_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_gl_period_name = ppr.prog_gl_period_name
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_rawcost := 0;
           end;

           begin
            select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0))
                  into l_prev_period_actual_rawcost
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
       and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                                     and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_gl_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_rawcost := 0;
           end;
    elsif (pgn_flag = 'N') then
                select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0))
                into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id IS NULL   --bug 3802177
                and ppr.as_of_date = p_as_of_date
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    end if; -- pgn flag.
     ELSIF p_structure_version_id IS NOT NULL
     THEN
               select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
                        +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
                        +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0))
                into l_actual_rawcost
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
                and structure_type = 'WORKPLAN'
                and ppr.structure_version_id = p_structure_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
     END IF;

    end if; -- currency_flag.

    return(NVL(l_actual_rawcost,0) - nvl(l_prev_period_actual_rawcost,0));

END get_incremental_actual_rawcost;

FUNCTION get_incremental_actual_effort(p_as_of_date           IN              DATE
                                      ,p_period_name          IN              VARCHAR2
                                      ,pgn_flag               IN              VARCHAR2
                                      ,p_project_id           IN              NUMBER
                                      ,p_object_id            IN              NUMBER
                                      ,p_object_version_id    IN              NUMBER
                                      ,p_structure_version_id IN              NUMBER := null  --3694031
                  ,p_proj_element_id      IN   NUMBER := null /* Modified for IB4 Progress CR. */
                                      ) return NUMBER
IS
    l_actual_effort NUMBER := NULL;
    l_prev_period_actual_effort  NUMBER;  --maansari6/15 bug 3694031
BEGIN

    IF p_structure_version_id IS NULL
    THEN
    if (pgn_flag = 'P') then
--maansari6/15  3694031
          begin
                select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0))
                into l_actual_effort
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_pa_period_name = p_period_name
                and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id IS NULL   --bug 3802177
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.structure_version_id IS NULL   --bug 3802177
                                     and ppr2.prog_pa_period_name = ppr.prog_pa_period_name
                         and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_effort := 0;
           end;

           begin
                select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0))
                  into l_prev_period_actual_effort
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
               and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
                          and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                                     and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_pa_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_effort := 0;
           end;
    elsif (pgn_flag ='G') then

--maansari6/15  3694031
          begin
                select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0))
                into l_actual_effort
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and prog_gl_period_name = p_period_name
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id IS NULL   --bug 3802177
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                and ppr.as_of_date = (select max(as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = ppr.project_id
                                     and ppr2.object_id = ppr.object_id
                                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr2.structure_version_id IS NULL   --bug 3802177
                             and ppr2.prog_gl_period_name = ppr.prog_gl_period_name --maansari6/15 bug 3694031
            and ppr2.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */);

           exception when no_data_found then
                l_actual_effort := 0;
           end;

           begin
                select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0))
                  into l_prev_period_actual_effort
                  from pa_progress_rollup ppr
                 where ppr.project_id = p_project_id
                   and ppr.object_id = p_object_id
                   and ppr.structure_type = 'WORKPLAN'
                   and ppr.structure_version_id IS NULL
               and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                   and ppr.as_of_date = ( select max(ppr1.as_of_date)
                                 from pa_progress_rollup ppr1
                                where ppr1.project_id = ppr.project_id
                                  and ppr1.object_id = ppr.object_id
                                  and ppr1.structure_type = 'WORKPLAN'
                                  and ppr1.structure_version_id IS NULL   --bug 3802177
                            and ppr1.proj_element_id = ppr.proj_element_id /* Modified for IB4 Progress CR. */
                                  and as_of_date < ( select min(as_of_date)
                                                   from pa_progress_rollup ppr2
                                                   where ppr2.project_id = ppr1.project_id
                                                     and ppr2.object_id = ppr1.object_id
                                                     and structure_type = 'WORKPLAN'
                                                     and ppr2.structure_version_id IS NULL   --bug 3802177
                                                     and ppr2.prog_gl_period_name = p_period_name
            and ppr2.proj_element_id = ppr1.proj_element_id /* Modified for IB4 Progress CR. */
                                                ));
           exception when no_data_found then
                l_prev_period_actual_effort := 0;
           end;
    --maansari6/15

    elsif (pgn_flag = 'N') then
                select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0))
                into l_actual_effort
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
            and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id IS NULL   --bug 3802177
                and ppr.as_of_date = p_as_of_date
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
    end if;

   ELSIF p_structure_version_id IS NOT NULL
   THEN
               select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0))
                into l_actual_effort
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.object_version_id = p_object_version_id
             and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id = p_structure_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;
   END IF;

    return(nvl(l_actual_effort,0) - nvl(l_prev_period_actual_effort,0)); --maansari6/15
END get_incremental_actual_effort;

-- Bug 3879461 : This function is not used anywhere except AMG view PA_TASK_ASSIGNMENTS_AMG_V
-- there it needs to be replaced with get_act_txn_cost_this_period
-- THIS FUNCTION IS NOW USED IN ASSIGNMENT VIEWS patvw009.sql and patvw021.sql. Please refer bug 3910193
FUNCTION get_act_cost_this_period (
                                     p_as_of_date      IN     DATE
                                    ,p_project_id        IN     NUMBER
                                    ,p_object_id         IN     NUMBER
                                    ,p_object_version_id IN     NUMBER
                                    ,p_proj_element_id   IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER
IS
    l_act_cost_period   NUMBER := NULL;
    l_act_cost_date     NUMBER := NULL;
    l_act_cost_pub      NUMBER := NULL;

        cursor c_prev_prog_rec is
                 select (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)
                     +nvl(ppr.eqpmt_act_cost_to_date_pc,0)+nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
                     +nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                        and ppr.structure_version_id is null -- Bug 3764224
                and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and current_flag = 'Y'
                ;

                cursor c_this_prog_rec is
                 select (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)
                     +nvl(ppr.eqpmt_act_cost_to_date_pc,0)+nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
                     +nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id is null -- Bug 3764224
                and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.current_flag= 'W'
                ;

BEGIN

    open c_prev_prog_rec;
    fetch c_prev_prog_rec into l_act_cost_pub;
    close c_prev_prog_rec;

    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_cost_date;
    close c_this_prog_rec;

    l_act_cost_period := (nvl(l_act_cost_date,0) - nvl(l_act_cost_pub,0));

        if (l_act_cost_period < 0) then
                l_act_cost_period := 0;
    end if;

    return(l_act_cost_period);
END get_act_cost_this_period;

FUNCTION get_act_txn_cost_this_period (p_as_of_date      IN     DATE
                                    ,p_project_id        IN     NUMBER
                                    ,p_object_id         IN     NUMBER
                                    ,p_object_version_id IN     NUMBER
        ,p_proj_element_id   IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER
IS
    l_act_cost_period   NUMBER := NULL;
    l_act_cost_date     NUMBER := NULL;
    l_act_cost_pub      NUMBER := NULL;

/*
    cursor c1 is
         select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)+nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)+nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
         and structure_type = 'WORKPLAN' -- FPM Dev CR 3
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                                     -- and ppr2.object_version_id = p_object_version_id
                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.as_of_date > p_as_of_date
    and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR. );
    l_c1rec     c1%rowtype;
*/

/* BEGIN: Commenting code for Bug # 3808127.
    cursor c_prev_prog_rec is
         select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)+nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)+nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date < p_as_of_date);

    cursor c_this_prog_rec is
        select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)+nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)+nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date >= p_as_of_date);

 END: Commenting code for Bug # 3808127. */

-- BEGIN: Adding code for Bug # 3808127.

        cursor c_prev_prog_rec is
                 select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
                     +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
                     +nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                        and ppr.structure_version_id is null -- Bug 3764224
                and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and current_flag = 'Y'
                ;

                cursor c_this_prog_rec is
                 select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
                     +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
                     +nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) act_cost_to_date
                from pa_progress_rollup ppr
        -- Bug 3879461 : No need to have percent complete table join now we can directly check current_flag as W
--                    ,pa_percent_completes ppc
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id is null -- Bug 3764224
                and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
--                and ppr.object_id = ppc.object_id
--                and ppr.as_of_date = ppc.date_computed
--                and ppr.percent_complete_id = ppc.percent_complete_id
--                and ppr.project_id = ppc.project_id
--                and ppr.proj_element_id=ppc.task_id
--                and ppr.structure_type = ppc.structure_type
--                and ppc.current_flag= 'N'
--                and ppc.published_flag = 'N'
                  and ppr.current_flag= 'W'
                ;

-- END: Adding code for Bug # 3808127.

BEGIN
-- Bug 3764224 : This function(_this_peiord) are used only in assignment cases. So it is safe to select from rollup table itself
-- no need to go in percent complete table
-- Bug 3764224 : RLM Changes : Commented the below code. This was not calculating the actual this period
/*
    open c1;
    fetch c1 into l_c1rec;
    if c1%found then
        select (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)+nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)+nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0))
                into l_act_cost_pub
                from pa_progress_rollup ppr,pa_percent_completes ppc
                where ppr.project_id = ppc.project_id
            and ppr.object_id = ppc.object_id
            and ppr.object_version_id = ppc.object_version_id
            and ppr.as_of_date = ppc.date_computed (+)
        and ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
            and ppr.percent_complete_id = ppc.percent_complete_id
         and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
         and ppr.structure_type = ppc.structure_type(+) -- FPM Dev CR 3
        and ppr.proj_element_id = ppc.task_id (+) -- Modified for IB4 Progress CR.
                and ppr.as_of_date = (select max(ppc2.date_computed)
                                     from pa_percent_completes ppc2
                                     where ppc2.project_id = p_project_id
                                     and ppc2.object_id = p_object_id
                                     -- and ppc2.object_version_id = p_object_version_id
                     and ppc2.published_flag = 'Y'
                     and ppc2.current_flag = 'Y'
                         and ppc2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppc2.task_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
                     );
                l_act_cost_period := (nvl(l_c1rec.act_cost_to_date,0) - nvl(l_act_cost_pub,0));

    end if;
    close c1;
*/

    open c_prev_prog_rec;
    fetch c_prev_prog_rec into l_act_cost_pub;
    close c_prev_prog_rec;

    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_cost_date;
    close c_this_prog_rec;

    l_act_cost_period := (nvl(l_act_cost_date,0) - nvl(l_act_cost_pub,0));

        if (l_act_cost_period < 0) then
                l_act_cost_period := 0;
    end if;

    return(l_act_cost_period);
END get_act_txn_cost_this_period;

-- Bug 3621404 : Raw Cost Changes, Added this procedure
PROCEDURE get_all_amounts_cumulative
    (p_project_id       IN     NUMBER
    ,p_object_id        IN     NUMBER
    ,p_object_type          IN     VARCHAR2
        ,p_structure_version_id IN     NUMBER := NULL -- Do not pass if published structure version
    ,p_as_of_date           IN     DATE   := NULL -- Must pass if published structure version
    ,x_act_bur_cost_tc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_bur_cost_pc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_bur_cost_fc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_raw_cost_tc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_raw_cost_pc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_raw_cost_fc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_bur_cost_tc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_bur_cost_pc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_bur_cost_fc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_raw_cost_tc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_raw_cost_pc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_raw_cost_fc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_effort       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_effort       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_return_status        OUT    NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
        ,x_msg_count            OUT    NOCOPY NUMBER         --File.Sql.39 bug 4440895
        ,x_msg_data             OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,p_proj_element_id  IN     NUMBER   /* Modified for IB4 Progress CR. */
    )
IS
    -- Bug 3627315 Issue 8 :Ccolumns were wrongly selected. Corrected it.

    CURSOR C_GET_WORKING_AMOUNT IS
     SELECT  (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)+nvl(ppr.eqpmt_act_cost_to_date_tc,0)
                     +nvl(ppr.subprj_oth_act_cost_to_date_tc,0)+nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) act_bur_cost_tc,
         (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)+nvl(ppr.eqpmt_act_cost_to_date_pc,0)
                     +nvl(ppr.subprj_oth_act_cost_to_date_pc,0)+nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0)) act_bur_cost_pc,
         (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)+nvl(ppr.eqpmt_act_cost_to_date_fc,0)
                     +nvl(ppr.subprj_oth_act_cost_to_date_fc,0)+nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0)) act_bur_cost_fc,
         (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)+nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)
                     +nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)+nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_raw_cost_tc,
         (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)+nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)
                     +nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)+nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0)) act_raw_cost_pc,
         (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)+nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)
                     +nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)+nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0)) act_raw_cost_fc,
         (nvl(ppr.oth_etc_cost_tc,0)+nvl(ppr.ppl_etc_cost_tc,0)+nvl(ppr.eqpmt_etc_cost_tc,0)
                     +nvl(ppr.subprj_oth_etc_cost_tc,0)+nvl(ppr.subprj_ppl_etc_cost_tc,0)+nvl(ppr.subprj_eqpmt_etc_cost_tc,0)) etc_bur_cost_tc,
         (nvl(ppr.oth_etc_cost_pc,0)+nvl(ppr.ppl_etc_cost_pc,0)+nvl(ppr.eqpmt_etc_cost_pc,0)
                     +nvl(ppr.subprj_oth_etc_cost_pc,0)+nvl(ppr.subprj_ppl_etc_cost_pc,0)+nvl(ppr.subprj_eqpmt_etc_cost_pc,0)) etc_bur_cost_pc,
         (nvl(ppr.oth_etc_cost_fc,0)+nvl(ppr.ppl_etc_cost_fc,0)+nvl(ppr.eqpmt_etc_cost_fc,0)
                     +nvl(ppr.subprj_oth_etc_cost_fc,0)+nvl(ppr.subprj_ppl_etc_cost_fc,0)+nvl(ppr.subprj_eqpmt_etc_cost_fc,0)) etc_bur_cost_fc,
         (nvl(ppr.oth_etc_rawcost_tc,0)+nvl(ppr.ppl_etc_rawcost_tc,0)+nvl(ppr.eqpmt_etc_rawcost_tc,0)
                     +nvl(ppr.subprj_oth_etc_rawcost_tc,0)+nvl(ppr.subprj_ppl_etc_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_etc_rawcost_tc,0)) etc_raw_cost_tc,
         (nvl(ppr.oth_etc_rawcost_pc,0)+nvl(ppr.ppl_etc_rawcost_pc,0)+nvl(ppr.eqpmt_etc_rawcost_pc,0)
                     +nvl(ppr.subprj_oth_etc_rawcost_pc,0)+nvl(ppr.subprj_ppl_etc_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_etc_rawcost_pc,0)) etc_raw_cost_pc,
         (nvl(ppr.oth_etc_rawcost_fc,0)+nvl(ppr.ppl_etc_rawcost_fc,0)+nvl(ppr.eqpmt_etc_rawcost_fc,0)
                     +nvl(ppr.subprj_oth_etc_rawcost_fc,0)+nvl(ppr.subprj_ppl_etc_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_etc_rawcost_fc,0)) etc_raw_cost_fc,
         (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0))--+nvl(ppr.oth_quantity_to_date,0))Oth quantity is not required as it can be in diffrent UOM
                     +nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0) act_effort,
         (nvl(ppr.estimated_remaining_effort,0)+nvl(ppr.eqpmt_etc_effort,0))--+nvl(ppr.oth_etc_quantity,0))Oth quantity is not required as it can be in diffrent UOM
                     +nvl(ppr.subprj_ppl_etc_effort,0)+nvl(ppr.subprj_eqpmt_etc_effort,0) etc_effort
                FROM pa_progress_rollup ppr
                WHERE ppr.project_id = p_project_id
                AND ppr.object_id = p_object_id
        AND ppr.object_type = p_object_type
                AND ppr.structure_version_id = p_structure_version_id
            AND ppr.structure_type = 'WORKPLAN'
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */;

    CURSOR C_GET_PUBLISHED_AMOUNT IS
     SELECT  (nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)+nvl(ppr.eqpmt_act_cost_to_date_tc,0)
                     +nvl(ppr.subprj_oth_act_cost_to_date_tc,0)+nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) act_bur_cost_tc,
         (nvl(ppr.oth_act_cost_to_date_pc,0)+nvl(ppr.ppl_act_cost_to_date_pc,0)+nvl(ppr.eqpmt_act_cost_to_date_pc,0)
                     +nvl(ppr.subprj_oth_act_cost_to_date_pc,0)+nvl(ppr.subprj_ppl_act_cost_pc,0)+nvl(ppr.subprj_eqpmt_act_cost_pc,0)) act_bur_cost_pc,
         (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)+nvl(ppr.eqpmt_act_cost_to_date_fc,0)
                     +nvl(ppr.subprj_oth_act_cost_to_date_fc,0)+nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0)) act_bur_cost_fc,
         (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)+nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)
                     +nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)+nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_raw_cost_tc,
         (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)+nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)
                     +nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)+nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0)) act_raw_cost_pc,
         (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)+nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)
                     +nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)+nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0)) act_raw_cost_fc,
         (nvl(ppr.oth_etc_cost_tc,0)+nvl(ppr.ppl_etc_cost_tc,0)+nvl(ppr.eqpmt_etc_cost_tc,0)
                     +nvl(ppr.subprj_oth_etc_cost_tc,0)+nvl(ppr.subprj_ppl_etc_cost_tc,0)+nvl(ppr.subprj_eqpmt_etc_cost_tc,0)) etc_bur_cost_tc,
         (nvl(ppr.oth_etc_cost_pc,0)+nvl(ppr.ppl_etc_cost_pc,0)+nvl(ppr.eqpmt_etc_cost_pc,0)
                     +nvl(ppr.subprj_oth_etc_cost_pc,0)+nvl(ppr.subprj_ppl_etc_cost_pc,0)+nvl(ppr.subprj_eqpmt_etc_cost_pc,0)) etc_bur_cost_pc,
         (nvl(ppr.oth_etc_cost_fc,0)+nvl(ppr.ppl_etc_cost_fc,0)+nvl(ppr.eqpmt_etc_cost_fc,0)
                     +nvl(ppr.subprj_oth_etc_cost_fc,0)+nvl(ppr.subprj_ppl_etc_cost_fc,0)+nvl(ppr.subprj_eqpmt_etc_cost_fc,0)) etc_bur_cost_fc,
         (nvl(ppr.oth_etc_rawcost_tc,0)+nvl(ppr.ppl_etc_rawcost_tc,0)+nvl(ppr.eqpmt_etc_rawcost_tc,0)
                     +nvl(ppr.subprj_oth_etc_rawcost_tc,0)+nvl(ppr.subprj_ppl_etc_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_etc_rawcost_tc,0)) etc_raw_cost_tc,
         (nvl(ppr.oth_etc_rawcost_pc,0)+nvl(ppr.ppl_etc_rawcost_pc,0)+nvl(ppr.eqpmt_etc_rawcost_pc,0)
                     +nvl(ppr.subprj_oth_etc_rawcost_pc,0)+nvl(ppr.subprj_ppl_etc_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_etc_rawcost_pc,0)) etc_raw_cost_pc,
         (nvl(ppr.oth_etc_rawcost_fc,0)+nvl(ppr.ppl_etc_rawcost_fc,0)+nvl(ppr.eqpmt_etc_rawcost_fc,0)
                     +nvl(ppr.subprj_oth_etc_rawcost_fc,0)+nvl(ppr.subprj_ppl_etc_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_etc_rawcost_fc,0)) etc_raw_cost_fc,
         (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0))--+nvl(ppr.oth_quantity_to_date,0))Oth quantity is not required as it can be in diffrent UOM
                     +nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0) act_effort,
         (nvl(ppr.estimated_remaining_effort,0)+nvl(ppr.eqpmt_etc_effort,0))--+nvl(ppr.oth_etc_quantity,0))Oth quantity is not required as it can be in diffrent UOM
                     +nvl(ppr.subprj_ppl_etc_effort,0)+nvl(ppr.subprj_eqpmt_etc_effort,0) etc_effort
                FROM pa_progress_rollup ppr
                WHERE ppr.project_id = p_project_id
                AND ppr.object_id = p_object_id
        AND ppr.object_type = p_object_type
                AND ppr.structure_version_id is null
            AND ppr.structure_type = 'WORKPLAN'
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
            AND ppr.current_flag <> 'W'   -- Bug 3879461
        AND trunc(as_of_date) = (
                SELECT trunc(max(as_of_date))
                FROM pa_progress_rollup ppr2
                        WHERE ppr2.project_id = p_project_id
                AND ppr2.object_id = p_object_id
                AND ppr2.object_type = p_object_type
                AND ppr2.structure_version_id is null
                AND ppr2.structure_type = 'WORKPLAN'
                AND as_of_date <= p_as_of_date
                    AND ppr2.current_flag <> 'W'   -- Bug 3879461
                            and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
            );

BEGIN
    x_return_status := 'S';

    IF p_structure_version_id IS NOT NULL THEN
        OPEN C_GET_WORKING_AMOUNT;
        FETCH C_GET_WORKING_AMOUNT INTO x_act_bur_cost_tc, x_act_bur_cost_pc,
                        x_act_bur_cost_fc, x_act_raw_cost_tc,
                        x_act_raw_cost_pc, x_act_raw_cost_fc,
                        x_etc_bur_cost_tc, x_etc_bur_cost_pc,
                        x_etc_bur_cost_fc, x_etc_raw_cost_tc,
                        x_etc_raw_cost_pc, x_etc_raw_cost_fc,
                        x_act_effort, x_etc_effort;

        IF C_GET_WORKING_AMOUNT%NOTFOUND THEN
            x_act_bur_cost_tc := 0;
            x_act_bur_cost_pc := 0;
            x_act_bur_cost_fc := 0;
            x_act_raw_cost_tc := 0;
            x_act_raw_cost_pc := 0;
            x_act_raw_cost_fc := 0;
            x_etc_bur_cost_tc := 0;
            x_etc_bur_cost_pc := 0;
            x_etc_bur_cost_fc := 0;
            x_etc_raw_cost_tc := 0;
            x_etc_raw_cost_pc := 0;
            x_etc_raw_cost_fc := 0;
            x_act_effort := 0;
            x_etc_effort := 0;
        END IF;
        CLOSE C_GET_WORKING_AMOUNT;
    ELSE
        OPEN C_GET_PUBLISHED_AMOUNT;
        FETCH C_GET_PUBLISHED_AMOUNT INTO x_act_bur_cost_tc, x_act_bur_cost_pc,
                        x_act_bur_cost_fc, x_act_raw_cost_tc,
                        x_act_raw_cost_pc, x_act_raw_cost_fc,
                        x_etc_bur_cost_tc, x_etc_bur_cost_pc,
                        x_etc_bur_cost_fc, x_etc_raw_cost_tc,
                        x_etc_raw_cost_pc, x_etc_raw_cost_fc,
                        x_act_effort, x_etc_effort;

        IF C_GET_PUBLISHED_AMOUNT%NOTFOUND THEN
            x_act_bur_cost_tc := 0;
            x_act_bur_cost_pc := 0;
            x_act_bur_cost_fc := 0;
            x_act_raw_cost_tc := 0;
            x_act_raw_cost_pc := 0;
            x_act_raw_cost_fc := 0;
            x_etc_bur_cost_tc := 0;
            x_etc_bur_cost_pc := 0;
            x_etc_bur_cost_fc := 0;
            x_etc_raw_cost_tc := 0;
            x_etc_raw_cost_pc := 0;
            x_etc_raw_cost_fc := 0;
            x_act_effort := 0;
            x_etc_effort := 0;
        END IF;
        CLOSE C_GET_PUBLISHED_AMOUNT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,120);

     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'GET_ALL_AMOUNTS_CUMULATIVE',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));

     -- 4537865
     x_act_bur_cost_tc := 0;
     x_act_bur_cost_pc := 0;
     x_act_bur_cost_fc := 0;
     x_act_raw_cost_tc := 0;
     x_act_raw_cost_pc := 0;
     x_act_raw_cost_fc := 0;
     x_etc_bur_cost_tc := 0;
     x_etc_bur_cost_pc := 0;
     x_etc_bur_cost_fc := 0;
     x_etc_raw_cost_tc := 0;
     x_etc_raw_cost_pc := 0;
     x_etc_raw_cost_fc := 0;
     x_act_effort := 0;
     x_etc_effort := 0;
     -- 4537865

     raise;
END get_all_amounts_cumulative;

-- Bug 3879461 : This function is not used.
FUNCTION get_act_pfn_cost_this_period (p_as_of_date      IN     DATE
                                    ,p_project_id        IN     NUMBER
                                    ,p_object_id         IN     NUMBER
                                    ,p_object_version_id IN     NUMBER
                          ,p_proj_element_id   IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER
IS
    l_act_cost_period   NUMBER := NULL;
    l_act_cost_date     NUMBER := NULL;
    l_act_cost_pub      NUMBER := NULL;

/*
        cursor c1 is
         select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)+nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)+nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
         and structure_type = 'WORKPLAN' -- FPM Dev CR 3
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id)  --Modified for IB4 Progress CR.
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                                     -- and ppr2.object_version_id = p_object_version_id
                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.as_of_date > p_as_of_date
        and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR. );
    l_c1rec     c1%rowtype;
*/

    cursor c_prev_prog_rec is
         select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)+nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)+nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date < p_as_of_date);

    cursor c_this_prog_rec is
         select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)+nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)+nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0)) act_cost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date >= p_as_of_date);


BEGIN
-- Bug 3764224 : This function(_this_peiord) are used only in assignment cases. So it is safe to select from rollup table itself
-- no need to go in percent complete table
-- Bug 3764224 : RLM Changes : Commented the below code. This was not calculating the actual this period

/*  open c1;
    fetch c1 into l_c1rec;
    if c1%found then
        select (nvl(ppr.oth_act_cost_to_date_fc,0)+nvl(ppr.ppl_act_cost_to_date_fc,0)+nvl(ppr.eqpmt_act_cost_to_date_fc,0)+nvl(ppr.subprj_oth_act_cost_to_date_fc,0)+nvl(ppr.subprj_ppl_act_cost_fc,0)+nvl(ppr.subprj_eqpmt_act_cost_fc,0))
                into l_act_cost_pub
                from pa_progress_rollup ppr,pa_percent_completes ppc
                where ppr.project_id = ppc.project_id
            and ppr.object_id = ppc.object_id
            and ppr.object_version_id = ppc.object_version_id
            and ppr.as_of_date = ppc.date_computed (+)
        and ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
            and ppr.percent_complete_id = ppc.percent_complete_id
         and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
         and ppr.structure_type = ppc.structure_type(+) -- FPM Dev CR 3
        and ppr.proj_element_id = ppc.task_id (+) -- Modified for IB4 Progress CR.
                and ppr.as_of_date = (select max(ppc2.date_computed)
                                     from pa_percent_completes ppc2
                                     where ppc2.project_id = p_project_id
                                     and ppc2.object_id = p_object_id
                                     -- and ppc2.object_version_id = p_object_version_id
                     and ppc2.published_flag = 'Y'
                     and ppc2.current_flag = 'Y'
                         and ppc2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppc2.task_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
                     );
                l_act_cost_period := (nvl(l_c1rec.act_cost_to_date,0) - nvl(l_act_cost_pub,0));
    end if;
    close c1;
*/

    open c_prev_prog_rec;
    fetch c_prev_prog_rec into l_act_cost_pub;
    close c_prev_prog_rec;

    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_cost_date;
    close c_this_prog_rec;

    l_act_cost_period := (nvl(l_act_cost_date,0) - nvl(l_act_cost_pub,0));


        if (l_act_cost_period < 0) then
                l_act_cost_period := 0;
        end if;

    return(l_act_cost_period);

END get_act_pfn_cost_this_period;


FUNCTION get_act_effort_this_period (p_as_of_date        IN     DATE
                                    ,p_project_id        IN     NUMBER
                                    ,p_object_id         IN     NUMBER
                                    ,p_object_version_id IN     NUMBER
                    ,p_proj_element_id   IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER
IS
    l_act_effort_period     NUMBER := NULL;
    l_act_effort_date       NUMBER := NULL;
    l_act_effort_pub        NUMBER := NULL;


/*
    cursor c1 is
         select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0)) act_effort_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
         and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                                     -- and ppr2.object_version_id = p_object_version_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.as_of_date > p_as_of_date);
*/

    cursor c_prev_prog_rec is
         select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0)) act_effort_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id is null -- Bug 3764224
                and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and current_flag = 'Y'
                ;
            /* commented by maansari7/25
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date <= p_as_of_date);
            */

    cursor c_this_prog_rec is
         select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0)) act_effort_to_date
                from pa_progress_rollup ppr
              -- Bug 3879461 : Now percent complete join is not required. current_flag = W can be used
--                    ,pa_percent_completes ppc
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
            and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
--                and ppr.object_id = ppc.object_id
--                and ppr.as_of_date = ppc.date_computed
--                and ppr.percent_complete_id = ppc.percent_complete_id
--                and ppr.project_id = ppc.project_id
--                and ppr.proj_element_id=ppc.task_id
--                and ppr.structure_type = ppc.structure_type
--                and ppc.current_flag= 'N'
--                and ppc.published_flag = 'N'
                and ppr.current_flag= 'W'
                ;
                /* commented by maansari7/25
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.structure_version_id is null -- Bug 3764224
                                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date > p_as_of_date);
                                     */

    --l_c1rec       c1%rowtype;

--bug 3738651
-- Bug 3764224 : RLM Changes : This code is commented, the earlier cusrsor code c1 was fine expept instead of greater than it should have been less than sign
--  cursor cur_effort_this_period
--      is
--      select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0))
--                from pa_progress_rollup ppr,pa_percent_completes ppc
--                where ppr.project_id = ppc.project_id
--          and ppr.object_id = ppc.object_id
--          and ppr.as_of_date = ppc.date_computed
--          and ppr.project_id = p_project_id
--            and ppr.object_id = p_object_id
--      and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
--            and ppr.percent_complete_id = ppc.percent_complete_id
--          and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
--            and ppr.structure_type = ppc.structure_type (+) -- FPM Dev CR 3
--       and ppr.proj_element_id = ppc.task_id (+) /* Modified for IB4 Progress CR. */
--            and ppc.current_flag = 'N'
--            and ppc.published_flag = 'N'
--            ;

BEGIN
-- Bug 3764224 : This function(_this_peiord) are used only in assignment cases. So it is safe to select from rollup table itself
-- no need to go in percent complete table
-- Bug 3764224 : RLM Changes : Commented the below code. This was not calculating the actual this period

/*
    open c1;
    fetch c1 into l_c1rec;
    if c1%found then
        select (nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)+nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)+nvl(ppr.oth_quantity_to_date,0))
                into l_act_effort_pub
                from pa_progress_rollup ppr,pa_percent_completes ppc
                where ppr.project_id = ppc.project_id
            and ppr.object_id = ppc.object_id
            and ppr.object_version_id = ppc.object_version_id
            and ppr.as_of_date = ppc.date_computed (+)
        and ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.percent_complete_id = ppc.percent_complete_id
         and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
         and ppr.structure_type = ppc.structure_type (+) -- FPM Dev CR 3
                and ppr.as_of_date = (select max(ppc2.date_computed)
                                     from pa_percent_completes ppc2
                                     where ppc2.project_id = p_project_id
                                     and ppc2.object_id = p_object_id
                                     -- and ppc2.object_version_id = p_object_version_id
                     and ppc2.published_flag = 'Y'
                     and ppc2.current_flag = 'Y'
                     and ppc2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     );
        l_act_effort_period := (nvl(l_c1rec.act_effort_to_date,0) - nvl(l_act_effort_pub,0));
    end if;
    close c1;
*/

    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_effort_date;
    if c_this_prog_rec%notfound
    then
        close c_this_prog_rec;
        return 0;
    end if;
    close c_this_prog_rec;

    open c_prev_prog_rec;
    fetch c_prev_prog_rec into l_act_effort_pub;
    close c_prev_prog_rec;

/*  commneted by maansari7/25
    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_effort_date;
    close c_this_prog_rec;
*/

    l_act_effort_period := (nvl(l_act_effort_date,0) - nvl(l_act_effort_pub,0));

    if (l_act_effort_period < 0 ) then
        l_act_effort_period := 0;
    end if;

    return(l_act_effort_period);



--  OPEN cur_effort_this_period;
--  FETCH cur_effort_this_period INTO l_act_effort_period;
--  IF cur_effort_this_period%FOUND
--  THEN
--          CLOSE cur_effort_this_period;
--          RETURN l_act_effort_period;
--        ELSE
--          CLOSE cur_effort_this_period;
--          RETURN null;
--  END IF;
END get_act_effort_this_period;

FUNCTION check_wwp_prog_publishing_ok(
    p_project_id              IN NUMBER
   ,p_structure_version_id    IN NUMBER
) RETURN VARCHAR2
IS
/* Commented for bug 5665310
        CURSOR C1 is
        select 'N'
        from pa_proj_elem_ver_structure ppevs
        where ppevs.project_id = p_project_id
        and ppevs.element_version_id = p_structure_version_id
        and ppevs.date_prog_applied_on_wver < (select max(l_update_date)
                                              from (
                                              select max(last_update_date) l_update_date
                                              from pa_progress_rollup ppr
                                              where ppr.project_id = p_project_id
                                              and object_type in ('PA_ASSIGNMENTS','PA_DELIVERABLES')
                                              and structure_type = 'WORKPLAN'
                                              and current_flag = 'Y'
                                              and ppr.structure_version_id is null
                                              union
                                              select max(last_update_date) l_update_date
                                              from pa_percent_completes
                                              where project_id = p_project_id
                                              and structure_type = 'WORKPLAN'
                                              and published_flag = 'Y'));

        CURSOR C2 is
        select 'N'
        from pa_proj_elem_ver_structure ppevs
        where ppevs.project_id = p_project_id
        and ppevs.element_version_id = p_structure_version_id
        and ppevs.date_prog_applied_on_wver is null
        and exists (select '1'
                      from pa_progress_rollup ppr
                     where ppr.project_id = p_project_id
                      and object_type in ('PA_ASSIGNMENTS','PA_DELIVERABLES')
                      and structure_type = 'WORKPLAN'
                      and current_flag = 'Y'
                      and ppr.structure_version_id is null
                    union
                    select '1'
                      from pa_percent_completes
                     where project_id = p_project_id
                      and structure_type = 'WORKPLAN'
                      and published_flag = 'Y');     */

        l_return_value    VARCHAR2(1) := null;
        -- Added for Bug 5665310
        l_date_prog_applied_on_wver            DATE;
        l_last_update_date                     DATE;
	l_program_flag                         VARCHAR2(1) := null;

BEGIN
        /* Commented for bug 5665310
	OPEN c1;
                fetch c1 INTO l_return_value;
        CLOSE c1;

        if l_return_value is null then
           open c2;
           fetch c2 INTO l_return_value;
           close c2;
        end if;   */

--Start of Addition for bug 5665310

	SELECT date_prog_applied_on_wver
        INTO   l_date_prog_applied_on_wver
        FROM   pa_proj_elem_ver_structure ppevs
        WHERE  ppevs.project_id = p_project_id
        AND    ppevs.element_version_id = p_structure_version_id;

	l_program_flag := PA_PROJECT_STRUCTURE_UTILS.check_program_flag_enable(p_project_id);

        IF l_date_prog_applied_on_wver IS NOT NULL THEN

	    If nvl(l_program_flag,'N') = 'Y' then
		SELECT
			MAX(ppr.last_update_date)
			INTO   l_last_update_date
			FROM   pa_progress_rollup ppr
			WHERE  ppr.project_id = p_project_id
			AND    ppr.object_type in ('PA_ASSIGNMENTS','PA_DELIVERABLES')
			AND    ppr.structure_type = 'WORKPLAN'
			AND    ppr.current_flag = 'Y'
			AND    ppr.structure_version_id is null;
	    else
	          SELECT
			MAX(ppr.last_update_date)
			INTO   l_last_update_date
			FROM   pa_progress_rollup ppr, pa_proj_elem_ver_structure ppevs
			WHERE  ppr.project_id = p_project_id
			AND    ppr.object_id = ppevs.PROJ_ELEMENT_ID
			AND    ppr.object_type ='PA_STRUCTURES'
			AND    ppr.structure_type = 'WORKPLAN'
			AND    ppr.PROJ_ELEMENT_ID = ppevs.PROJ_ELEMENT_ID
			AND    ppr.current_flag = 'Y'
			AND    ppr.structure_version_id is null
			AND    ppevs.project_id = ppr.project_id
			AND    ppevs.element_version_id = p_structure_version_id;

	    end if;

            IF l_date_prog_applied_on_wver >= NVL(l_last_update_date,l_date_prog_applied_on_wver) THEN
		If nvl(l_program_flag,'N') = 'Y' then
			SELECT MAX(last_update_date)
			INTO   l_last_update_date
			FROM   pa_percent_completes ppr
			WHERE  project_id = p_project_id
			AND    structure_type = 'WORKPLAN'
			AND    published_flag = 'Y'
			AND    current_flag = 'Y';
		end if;

                IF l_date_prog_applied_on_wver < NVL(l_last_update_date,l_date_prog_applied_on_wver) THEN

                    l_return_value := 'N';

                END IF;

            ELSE

                l_return_value := 'N';

            END IF;

        ELSE

            BEGIN
                SELECT 'N'
                INTO   l_return_value
                FROM   DUAL
                WHERE  EXISTS (  SELECT '1'
                                 FROM   pa_progress_rollup ppr
                                 WHERE  ppr.project_id = p_project_id
                                 AND    object_type in ('PA_ASSIGNMENTS','PA_DELIVERABLES')
                                 AND    structure_type = 'WORKPLAN'
                                 AND    current_flag = 'Y'
                                 AND    ppr.structure_version_id IS NULL);

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            END;

            IF l_return_value IS NULL THEN

                BEGIN

                    SELECT 'N'
                    INTO   l_return_value
                    FROM   DUAL
                    WHERE  EXISTS (  SELECT '1'
                                     FROM   pa_percent_completes
                                     WHERE  project_id = p_project_id
                                     AND    structure_type = 'WORKPLAN'
                                     AND    published_flag = 'Y');

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
                END;

            END IF;

        END IF;
-- End of addition for bug 5665310

        return (NVL(l_return_value,'Y'));

END check_wwp_prog_publishing_ok;

FUNCTION Get_BAC_Value(
    p_project_id                IN NUMBER
   ,p_task_weight_method        IN VARCHAR2
   ,p_proj_element_id           IN NUMBER
   ,p_structure_version_id      IN NUMBER
   ,p_structure_type            IN VARCHAR2
   ,p_working_wp_prog_flag      IN VARCHAR2 default 'N' --maansari7/18. To get the planned in case of apply lp flow
   ,p_program_flag              IN VARCHAR2 default 'Y' -- Bug 4493105
) RETURN NUMBER
IS
l_msg_code                      VARCHAR2(30);
l_return_status                 VARCHAR2(1);
l_value                         NUMBER;
l_plan_version_id               NUMBER;
BEGIN
-- FPM Dev CR 3 : Changes done to not call PJI Api for Workplan.

-- Bug 3627315 : Now this function will not call populate_workplan_data. It shd be called from calling environment
IF p_structure_type = 'FINANCIAL' THEN

    /* Begin Fix for Bug # 4115607. */

        -- l_plan_version_id := PA_FIN_PLAN_UTILS.Get_app_budget_cost_cb_ver(p_project_id);

    l_plan_version_id := pa_progress_utils.get_app_cost_budget_cb_wor_ver(p_project_id);

    /* End fix for Bug # 4115607. */

        BEGIN

--  IF   p_project_id <> G_bac_value_project_id THEN

--      PJI_FM_XBS_ACCUM_UTILS.populate_workplan_data(
--              p_project_id        => p_project_id,
--              p_struct_ver_id     => p_structure_version_id,
    --                  p_base_struct_ver_id   IN   NUMBER DEFAULT NULL,
--              p_plan_version_id   => l_plan_version_id,
--  --                  p_progress_actuals_flag IN  VARCHAR2 DEFAULT 'N',
--              x_return_status     => l_return_status,
--              x_msg_code          => l_msg_code
--              );
--      G_bac_value_project_id := p_project_id;
--  END IF;

-- Bug 3627315 : In case of Financial Structure, it should select normal(without BASE)  columns from PJI table
-- Anyhow it is baselined plan version
--                SELECT decode(p_task_weight_method, 'EFFORT',nvl(BASE_LABOR_HOURS,0)+nvl(BASE_EQUIP_HOURS,0), PRJ_BASE_BRDN_COST)
                SELECT
        /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    decode(p_task_weight_method, 'EFFORT',nvl(LABOR_HOURS,0)+nvl(EQUIPMENT_HOURS,0), PRJ_BRDN_COST)
                INTO  l_value
                FROM PJI_FM_XBS_ACCUM_TMP1
                WHERE project_id = p_project_id
                AND project_element_id = p_proj_element_id
                AND PLAN_VERSION_ID = l_plan_version_id
        AND txn_currency_code is null    --bug no. 3646988
                AND res_list_member_id is null;
        EXCEPTION
         WHEN OTHERS THEN
                l_value := null;
        END;
ELSE
    --No Need to call PJI APi to populate its temp table. From Workplan pages, we are calling this API.
    -- We are calling this From AMG pa_status_pub too.
    -- As of now we are not calling it from Financial Forms and pages, hence it needs to be called for Financial Structure
    BEGIN

        if p_working_wp_prog_flag = 'N' then

        --bug 3896273, CR, latest published changes
        /*SELECT decode(p_task_weight_method, 'EFFORT',nvl(BASE_LABOR_HOURS,nvl(LABOR_HOURS,0))+
                                                             nvl(BASE_EQUIP_HOURS,nvl(EQUIPMENT_HOURS,0)),
                                                     NVL(PRJ_BASE_BRDN_COST,nvl(PRJ_BRDN_COST,0)))  --if base is not avilable then select the published planned. bug 3781922*/
                -- Bug 4493105 : Added p_program_flag decode
        SELECT
        /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
               decode(p_task_weight_method, 'EFFORT', decode(p_program_flag, 'N',    nvl(P_BASE_LBR_HOURS, nvl(P_LPB_LBR_HOURS, nvl(P_LBR_HOURS,0)))+
                                                                                     nvl(P_BASE_EQP_HOURS, nvl(P_LPB_EQP_HOURS, nvl(P_EQP_HOURS,0))),
                                                     nvl(BASE_LABOR_HOURS, nvl(LPB_LABOR_HOURS, nvl(LABOR_HOURS,0)))+
                                                                                 nvl(BASE_EQUIP_HOURS, nvl(LPB_EQUIP_HOURS, nvl(EQUIPMENT_HOURS,0)))
                                 ),
                                                     decode(p_program_flag, 'N',NVL(P_BASE_BRDN_COST, nvl(P_LPB_BRDN_COST, nvl(P_BRDN_COST,0)))
                                                       ,NVL(PRJ_BASE_BRDN_COST, nvl(PRJ_LPB_BRDN_COST, nvl(PRJ_BRDN_COST,0)))
                                   )
             )  --if base is not avilable then select the published planned. bug 3781922
                INTO  l_value
                FROM PJI_FM_XBS_ACCUM_TMP1
                WHERE project_id = p_project_id
                AND struct_version_id = p_structure_version_id
                AND project_element_id = p_proj_element_id
                AND txn_currency_code is null    --bug no. 3646988
                AND res_list_member_id is null;

             else
                -- Bug 4493105 : Added p_program_flag decode
                SELECT
        /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    decode(p_task_weight_method, 'EFFORT',decode(p_program_flag,'N',nvl(P_LBR_HOURS,0)+nvl(P_EQP_HOURS,0)
                                                                  ,nvl(LABOR_HOURS,0)+nvl(EQUIPMENT_HOURS,0))
                               , decode(p_program_flag,'N',P_BRDN_COST,PRJ_BRDN_COST))
                INTO  l_value
                FROM PJI_FM_XBS_ACCUM_TMP1
                WHERE project_id = p_project_id
                AND struct_version_id = p_structure_version_id
                AND project_element_id = p_proj_element_id
        AND txn_currency_code is null    --bug no. 3646988
                AND res_list_member_id is null;

        end if;

        EXCEPTION
         WHEN OTHERS THEN
                l_value := null;
        END;
END IF;

return l_value;
EXCEPTION
WHEN OTHERS THEN
        return null;
END Get_BAC_Value;

FUNCTION Get_EARLY_PROGRESS_ENTRY_DATE(
     p_project_id  NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2 := 'PA_TASKS'
    ,p_structure_type VARCHAR2 := 'WORKPLAN'
    ,p_task_id  NUMBER := null /* Modified for IB4 Progress CR. */
    ) RETURN DATE
IS
l_first_date Date;
CURSOR cur_ppc
  IS
    SELECT min(trunc(last_update_date))
      FROM pa_percent_completes
     WHERE object_id = p_object_id
       AND project_id = p_project_id
       and object_type = p_object_type
       AND published_flag = 'Y'
       AND structure_type = p_structure_type
       and NVL(task_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id,NVL(task_id,-1)),NVL(p_task_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
       --and task_id = nvl(p_task_id, p_object_id) /* Modified for IB4 Progress CR. */;
       ;
BEGIN

OPEN cur_ppc;
FETCH cur_ppc INTO l_first_date;
CLOSE cur_ppc;

return l_first_date;

EXCEPTION
WHEN OTHERS THEN
        return null;
END Get_EARLY_PROGRESS_ENTRY_DATE;

FUNCTION Get_LATEST_PROGRESS_ENTRY_DATE(
     p_project_id  NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2 := 'PA_TASKS'
    ,p_structure_type VARCHAR2 := 'WORKPLAN'
    ,p_task_id  NUMBER := null /* Amit : Modified for IB4 Progress CR. */
    ) RETURN DATE
IS
l_first_date Date;
CURSOR cur_ppc
  IS
    SELECT max(trunc(last_update_date))
      FROM pa_percent_completes
     WHERE object_id = p_object_id
       AND project_id = p_project_id
       and object_type = p_object_type
       AND published_flag = 'Y'
       AND structure_type = p_structure_type
       and NVL(task_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_task_id,NVL(task_id,-1)),NVL(p_task_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
       ;
BEGIN

OPEN cur_ppc;
FETCH cur_ppc INTO l_first_date;
CLOSE cur_ppc;

return l_first_date;

EXCEPTION
WHEN OTHERS THEN
        return null;
END Get_LATEST_PROGRESS_ENTRY_DATE;

FUNCTION latest_published_progress_date(p_project_id      IN    NUMBER
                    ,p_structure_type IN    VARCHAR2 ) RETURN DATE
IS
    l_return_date   DATE;
  CURSOR cur_latest_date
  IS
    select max(date_computed)
    from pa_percent_completes ppc
    where ppc.project_id = p_project_id
    and ppc.structure_type = p_structure_type;

BEGIN
     OPEN cur_latest_date;
     FETCH cur_latest_date INTO l_return_date;
     CLOSE cur_latest_date;

     return(l_return_date);
END latest_published_progress_date;

FUNCTION check_object_has_prog(
         p_project_id                           IN      NUMBER -- FPM Dev CR 7 : Removed defaulting
        ,p_proj_element_id                      IN      NUMBER := null /* Modified for IB4 Progress CR. */
        ,p_object_id                            IN      NUMBER -- FPM Dev CR 7 : Removed defaulting
        ,p_object_type                          IN      VARCHAR2:='PA_TASKS'
        ,p_structure_type                       IN      VARCHAR2:='WORKPLAN'
        ,p_progress_status                      IN      VARCHAR2:='ANY'
        )       RETURN VARCHAR2
IS
    l_return_status VARCHAR2(1) := 'N';
    -- FPM Dev CR 7 : Note that p_proj_element_id is not needed, but keeping it to avoid impacts to other code
CURSOR myCursor is
    select 'Y'
    from pa_progress_rollup ppr
    where ppr.project_id = p_project_id
    and ppr.object_id = p_object_id
    and ppr.object_type = p_object_type
    and ppr.structure_type = p_structure_type
    and ppr.structure_version_id is null -- FPM Dev CR 7
        and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
    --and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
    ;

CURSOR myCursor_pub is
        select 'Y'
        from pa_progress_rollup ppr
        where ppr.project_id = p_project_id
        and ppr.object_id = p_object_id
        and ppr.object_type = p_object_type
        and ppr.structure_type = p_structure_type
        and ppr.structure_version_id is null -- FPM Dev CR 7
        and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
        and current_flag in ('Y','N');
result myCursor%rowtype;

BEGIN

    if (p_progress_status = 'PUBLISHED') then
       OPEN myCursor_pub;
       FETCH myCursor_pub INTO result;
       if myCursor_pub%FOUND THEN
            close myCursor_pub;
            return 'Y';
       ELSE
            close myCursor_pub;
            return 'N';
       END IF;
    else
       OPEN myCursor;
       FETCH myCursor INTO result;
       if myCursor%FOUND THEN
            close myCursor;
        return 'Y';
       ELSE
            close myCursor;
            return 'N';
       END IF;
    end if;
END check_object_has_prog;

--- Following APIs added by Bhumesh

Function Prog_Get_Pa_Period_Name (p_Date  IN Date
, p_org_id IN NUMBER :=null -- 4746476
)
RETURN VARCHAR2
IS
  l_Org_ID pa_implementations_all.org_id%TYPE;
  l_Period_Name  varchar2(100);
BEGIN
-- 4746476 : Added IF
IF p_org_id IS NULL THEN
  SELECT org_id INTO l_Org_ID FROM PA_Implementations;
ELSE
  l_Org_ID := p_org_id;
END IF;

  l_Period_Name := PA_UTILS2.get_pa_period_name (p_txn_date => p_Date,
                         p_org_id   => l_Org_ID );

  Return l_Period_Name;
END Prog_Get_Pa_Period_Name;

Function Prog_Get_GL_Period_Name (P_Date  IN Date
, p_org_id IN NUMBER :=null -- 4746476
)
RETURN VARCHAR2
IS
  l_Org_ID pa_implementations_all.org_id%TYPE;
  l_Period_Name  varchar2(100);
BEGIN
-- 4746476 : Added IF
IF p_org_id IS NULL THEN
  SELECT org_id INTO l_Org_ID FROM PA_Implementations;
ELSE
  l_Org_ID := p_org_id;
END IF;

  l_Period_Name := PA_UTILS2.get_GL_period_name (p_gl_date  => p_Date,
                         p_org_id   => l_Org_ID );

  Return l_Period_Name;

END Prog_Get_GL_Period_Name;

-- History
-- 02-aug-04
-- Added two params p_structure_version_id and p_structure_status to return base percent complete
-- from a working version also.
-- This change is done for B and F
Procedure REDEFAULT_BASE_PC    (
    p_Project_ID                IN NUMBER
   ,p_Proj_element_id           IN NUMBER
   ,p_Structure_type            IN VARCHAR2 DEFAULT 'WORKPLAN'
   ,p_object_type               IN VARCHAR2 DEFAULT 'PA_TASKS'
   ,p_As_Of_Date                IN DATE
   ,p_structure_version_id      IN NUMBER    DEFAULT null
   ,p_structure_status          IN VARCHAR2  DEFAULT null
   ,p_calling_context           IN VARCHAR2  DEFAULT 'PROGRESS'
   ,X_base_percent_complete     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_msg_code        VARCHAR2(30);
  l_return_status   VARCHAR2(1);
  l_value       NUMBER;

-- 4392189 : Program Reporting Changes - Phase 2
-- If p_calling_context is PROGRESS, then it will work as it is
-- If it is FINANCIAL_PLANNING then it will return project % complete for Workplan

  Cursor CUR_Base_Perc_Complete_task
    IS
-- 4392189
--      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
--                                        'FINANCIAL_PLANNING', NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP))
      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
                                        'FINANCIAL_PLANNING',
                          decode(p_structure_type, 'FINANCIAL',  NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP)
                                                              ,  NVL(completed_percentage,BASE_PERCENT_COMPLETE)))
      From   PA_Progress_Rollup
      Where  Project_ID     = P_Project_ID
      AND    Object_ID      = P_Proj_Element_ID
      AND    Object_Type        = p_object_type
      AND    current_flag       <> 'W'     --bug 3879461
      AND    As_Of_Date     = ( select max(As_Of_Date) from pa_progress_rollup
                                    where  Project_ID         = P_Project_ID
                                      AND    Object_ID          = P_Proj_Element_ID
                                      AND    Object_Type        = p_object_type
                                      AND    structure_version_id IS NULL
                                      AND    current_flag       <> 'W'     --bug 3879461
                                      AND    Structure_type     = p_structure_type
                                      AND   as_of_date <= p_as_of_date
                                   )
      AND    structure_version_id IS NULL
      AND    Structure_type = p_structure_type;

  Cursor CUR_Base_Perc_Complete_proj
    IS
-- 4392189
--      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
--                                        'FINANCIAL_PLANNING', NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP))
      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
                                        'FINANCIAL_PLANNING',
                          decode(p_structure_type, 'FINANCIAL',  NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP)
                                                              ,  NVL(completed_percentage,BASE_PERCENT_COMPLETE)))
      From   PA_Progress_Rollup
      Where  Project_ID         = P_Project_ID
      AND    Object_Type        = p_object_type
      AND    current_flag       <> 'W'     --bug 3879461
      AND    As_Of_Date         = ( select max(As_Of_Date) from pa_progress_rollup
                                    where  Project_ID         = P_Project_ID
                                      AND    Object_Type        = p_object_type
                                      AND    structure_version_id IS NULL
                                      AND    current_flag       <> 'W'     --bug 3879461
                                      AND    Structure_type     = p_structure_type
                                      AND   as_of_date <= p_as_of_date
                                   )

      AND    structure_version_id IS NULL
      AND    Structure_type     = p_structure_type;

--bug 3879461 selects percent complete from working progress record.
  Cursor CUR_Base_Perc_Complete_task_2
    IS
-- 4392189
--      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
--                                        'FINANCIAL_PLANNING', NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP))
      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
                                        'FINANCIAL_PLANNING',
                          decode(p_structure_type, 'FINANCIAL',  NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP)
                                                              ,  NVL(completed_percentage,BASE_PERCENT_COMPLETE)))
      From   PA_Progress_Rollup
      Where  Project_ID         = P_Project_ID
      AND    Object_ID          = P_Proj_Element_ID
      AND    Object_Type        = p_object_type
      AND    current_flag       = 'W'     --bug 3879461
      AND    As_Of_Date         = ( select max(As_Of_Date) from pa_progress_rollup
                                    where  Project_ID         = P_Project_ID
                                      AND    Object_ID          = P_Proj_Element_ID
                                      AND    Object_Type        = p_object_type
                                      AND    structure_version_id IS NULL
                                      AND    current_flag       = 'W'     --bug 3879461
                                      AND    Structure_type     = p_structure_type
                                      AND   as_of_date <= p_as_of_date
                                   )
      AND    structure_version_id IS NULL
      AND    Structure_type     = p_structure_type;

  Cursor CUR_Base_Perc_Complete_proj_2
    IS
-- 4392189
--      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
--                                        'FINANCIAL_PLANNING', NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP))
      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
                                        'FINANCIAL_PLANNING',
                          decode(p_structure_type, 'FINANCIAL',  NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP)
                                                              ,  NVL(completed_percentage,BASE_PERCENT_COMPLETE)))
      From   PA_Progress_Rollup
      Where  Project_ID         = P_Project_ID
      AND    Object_Type        = p_object_type
      AND    current_flag       = 'W'     --bug 3879461
      AND    As_Of_Date         = ( select max(As_Of_Date) from pa_progress_rollup
                                    where  Project_ID         = P_Project_ID
                                      AND    Object_Type        = p_object_type
                                      AND    structure_version_id IS NULL
                                      AND    current_flag       = 'W'     --bug 3879461
                                      AND    Structure_type     = p_structure_type
                                      AND   as_of_date <= p_as_of_date
                                   )

      AND    structure_version_id IS NULL
      AND    Structure_type     = p_structure_type;
--end bug 3879461 selects percent complete from working progress record.



  Cursor CUR_Base_Perc_Complete_task_w
    IS
-- 4392189
--      Select NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage)
--      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
--                                        'FINANCIAL_PLANNING', NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP))
      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
                                        'FINANCIAL_PLANNING',
                          decode(p_structure_type, 'FINANCIAL',  NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP)
                                                          ,  NVL(completed_percentage,BASE_PERCENT_COMPLETE)))
      From   PA_Progress_Rollup
      Where  Project_ID         = P_Project_ID
      AND    Object_ID          = P_Proj_Element_ID
      AND    Object_Type        = p_object_type
      --AND    As_Of_Date         = p_As_Of_Date
      AND    structure_version_id = p_structure_version_id
      AND    Structure_type     = p_structure_type;

  Cursor CUR_Base_Perc_Complete_proj_w
    IS
-- 4392189
--      Select NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage)
--      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
--                                        'FINANCIAL_PLANNING', NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP))
      Select decode( p_calling_context, 'PROGRESS', NVL(EFF_ROLLUP_PERCENT_COMP,completed_percentage),
                                        'FINANCIAL_PLANNING',
                          decode(p_structure_type, 'FINANCIAL',  NVL(completed_percentage,EFF_ROLLUP_PERCENT_COMP)
                                                              ,  NVL(completed_percentage,BASE_PERCENT_COMPLETE)))
      From   PA_Progress_Rollup
      Where  Project_ID         = P_Project_ID
      AND    Object_Type        = p_object_type
      --AND    As_Of_Date         = p_As_Of_Date
      AND    structure_version_id = p_structure_version_id
      AND    Structure_type     = p_structure_type;


BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    X_base_percent_complete := null;   --bug 3879461

    IF ( p_structure_version_id IS NULL AND p_structure_status IS NULL ) OR
       ( p_structure_status = 'PUBLISHED')
    THEN

--bug 3879461 selects percent complete from working progress record.
     if p_calling_context = 'PROGRESS'
     then
    if p_proj_element_id is null then
            Open CUR_Base_Perc_Complete_proj_2;
        Fetch CUR_Base_Perc_Complete_proj_2 INTO X_base_percent_complete;
        Close CUR_Base_Perc_Complete_proj_2;
    else
                Open CUR_Base_Perc_Complete_task_2;
                Fetch CUR_Base_Perc_Complete_task_2 INTO X_base_percent_complete;
                Close CUR_Base_Perc_Complete_task_2;
    end if;
      end if;
--bug 3879461 selects percent complete from working progress record.

      if X_base_percent_complete IS NULL    --bug 3879461
      then
        if p_proj_element_id is null then
                Open CUR_Base_Perc_Complete_proj;
                Fetch CUR_Base_Perc_Complete_proj INTO X_base_percent_complete;
                Close CUR_Base_Perc_Complete_proj;
        else
                Open CUR_Base_Perc_Complete_task;
                Fetch CUR_Base_Perc_Complete_task INTO X_base_percent_complete;
                Close CUR_Base_Perc_Complete_task;
        end if;
      end if;

    ELSIF ( p_structure_version_id IS NOT NULL AND p_structure_status IS NOT NULL ) OR
          ( p_structure_status = 'WORKING')
    THEN

        if p_proj_element_id is null then
                Open CUR_Base_Perc_Complete_proj_w;
                Fetch CUR_Base_Perc_Complete_proj_w INTO X_base_percent_complete;
                Close CUR_Base_Perc_Complete_proj_w;
        else
                Open CUR_Base_Perc_Complete_task_w;
                Fetch CUR_Base_Perc_Complete_task_w INTO X_base_percent_complete;
                Close CUR_Base_Perc_Complete_task_w;
        end if;

    END IF;

-- Progress Management Changes. Bug # 3420093.

    X_base_percent_complete := round(X_base_percent_complete,8); --Bug 6854114

-- Progress Management Changes. Bug # 3420093.

EXCEPTION WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_Msg_Count     := 0;
      x_Msg_Data      := '';
      fnd_msg_pub.add_exc_msg( p_pkg_name       => 'PA_PROGRESS_UTILS'
                  ,p_procedure_name => 'REDEFAULT_BASE_PC'
                  ,p_error_text     => SUBSTRB(SQLERRM,1,120));
    RAISE FND_API.G_EXC_ERROR;
END REDEFAULT_BASE_PC;

Procedure RECALCULATE_PROG_STATS (
    p_project_id        IN NUMBER
   ,p_proj_element_id       IN NUMBER
   ,p_task_version_id       IN NUMBER
   ,p_structure_type        IN VARCHAR2 DEFAULT 'WORKPLAN'
   ,p_As_Of_Date        IN DATE
   ,P_Overide_Percent_Complete  IN NUMBER
   ,p_Actual_Effort     IN NUMBER
   ,p_Actual_Cost       IN NUMBER
   ,p_Planned_Effort        IN NUMBER
   ,p_Planned_Cost      IN NUMBER
   ,p_baselined_Effort      IN NUMBER
   ,p_baselined_Cost        IN NUMBER
   ,x_BCWS          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,X_BCWP          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,X_SCH_Performance_Index OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,X_COST_Performance_Index    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_Sch_At_Completion     OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_Complete_Performance_Index OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_TASK_WEIGHT_BASIS_CODE  VARCHAR2(30);
  l_Planned_Amount      NUMBER ;
  l_Actual_Amount       NUMBER ;
  l_Baseline_Amount     NUMBER ;
  l_BCWS                NUMBER;
  l_SCH_Performance_Index NUMBER;
  l_tcpi_denom            NUMBER;

    CURSOR cur_sch_dates
    IS
      SELECT scheduled_start_date, scheduled_finish_date
      from pa_proj_elem_ver_schedule ppevs
      where project_id=p_project_id
       and element_version_id=p_task_version_id
       ;

       l_sch_start_date DATE;
       l_sch_finish_date DATE;

    CURSOR cur_str_ver_id
      is
      select parent_structure_version_id
      from pa_proj_element_versions
      where project_id = p_project_id
      and proj_element_id =     p_proj_element_id
      and element_version_id = p_task_version_id
      ;

      l_str_ver_id  NUMBER;

    /* Bug # 3861344: Modified API: recalculate_prog_stats(). */

    -- Cursor to get baselined dates.

    cursor cur_baselined_dates is
    select baseline_start_date, baseline_finish_date
    from pa_proj_elements
    where project_id = p_project_id
    and proj_element_id = p_proj_element_id;

    l_base_start_date DATE := NULL;
    l_base_finish_date DATE := NULL;

        --bug 4308359, start
    CURSOR cur_proj_curr
    IS
      SELECT project_currency_code from pa_projects_all where project_id=p_project_id;

        l_prj_currency_code      VARCHAR2(120);
        --bug 4308359, end


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  Select TASK_WEIGHT_BASIS_CODE
  INTO   l_TASK_WEIGHT_BASIS_CODE
  From   pa_proj_progress_attr
  Where  Project_ID     = p_project_id
  AND    Structure_type = p_structure_type;

    If l_TASK_WEIGHT_BASIS_CODE = 'EFFORT' then
       l_Planned_Amount    := p_Planned_Effort;
       l_Actual_Amount     := p_Actual_Effort;
       l_Baseline_Amount   := p_baselined_Effort;

    ELSE
       l_Planned_Amount    := p_Planned_Cost;
       l_Actual_Amount     := p_Actual_Cost;
       l_Baseline_Amount   := p_baselined_Cost;

       OPEN cur_proj_curr;
       FETCH  cur_proj_curr INTO l_prj_currency_code;
       CLOSE cur_proj_curr;

    End if;

    -- Progress Management Changes. Bug # 3420093.

    /* Begin fix for Bug # 4050324. */

    -- x_BCWP := trunc((l_Planned_Amount*P_Overide_Percent_Complete)/100,2);

    --bug 4308359
    --x_BCWP := trunc((l_Baseline_Amount*P_Overide_Percent_Complete)/100,2);
     If l_TASK_WEIGHT_BASIS_CODE = 'EFFORT' then
        x_BCWP := round((l_Baseline_Amount*P_Overide_Percent_Complete)/100,5);
     else
        --x_BCWP := pa_currency.round_trans_currency_amt((l_Baseline_Amount*P_Overide_Percent_Complete)/100, l_prj_currency_code);
        x_BCWP := pa_currency.round_trans_currency_amt1((l_Baseline_Amount*P_Overide_Percent_Complete)/100, l_prj_currency_code);
     end if;

    /* End fix for Bug # 4050324. */

    -- Progress Management Changes. Bug # 3420093.

    --Select (l_Planned_Amount*P_Overide_Percent_Complete)/100
    /*
    INTO   x_BCWP  -- Earned Value
    From   PA_Progress_Rollup
    Where  Project_ID       = P_Project_ID
    AND    Proj_Element_ID  = P_Proj_Element_ID
    AND    object_id = P_Proj_Element_ID
    --AND    Object_Type        = 'PA_ASSIGNMENTS'
    AND    As_Of_Date       = p_As_Of_Date
    AND    Structure_type   = p_structure_type;*/


    /* 3793758 */
    OPEN cur_sch_dates;
    FETCH cur_sch_dates INTO l_sch_start_date, l_sch_finish_date;
    CLOSE cur_sch_dates;

    OPEN cur_str_ver_id;
    FETCH cur_str_ver_id into l_str_ver_id;
    CLOSE cur_str_ver_id;

    -- Begin: Fix for Bug # 3926529.

    /* Begin commenting out the following code.
    l_bcws := pa_progress_utils.get_bcws(p_project_id => p_project_id
                            ,p_object_id => p_proj_element_id
                            ,p_proj_element_id => p_proj_element_id
                            ,p_as_of_date => p_as_of_date
                            ,p_structure_version_id => l_str_ver_id
                            ,p_structure_type => p_structure_type
                            ,p_scheduled_start_date =>l_sch_start_date
                            ,p_scheduled_end_date => l_sch_finish_date
                              );
    End commenting out the above code. */

     -- Get baselined dates.

        OPEN cur_baselined_dates;
        FETCH cur_baselined_dates INTO l_base_start_date, l_base_finish_date;
        CLOSE cur_baselined_dates;


     -- Call API: pa_progress_utils.get_bcws() with baselined dates.

    l_bcws := pa_progress_utils.get_bcws(p_project_id => p_project_id
                                        ,p_object_id => p_proj_element_id
                                        ,p_proj_element_id => p_proj_element_id
                                        ,p_as_of_date => p_as_of_date
                                        ,p_structure_version_id => l_str_ver_id
                                        ,p_structure_type => p_structure_type
                                        ,p_scheduled_start_date =>l_base_start_date
                                        ,p_scheduled_end_date => l_base_finish_date);

     -- End: Fix for Bug # 3926529.

    --bug 4308359
        --x_bcws := trunc(nvl(l_bcws,0),2);
        x_bcws := nvl(l_bcws,0);

    if l_BCWS is null or l_BCWS = 0
    then
       l_bcws := 1;
    else
       l_bcws := l_BCWS;
    end if;

    -- Progress Management Changes. Bug # 3420093.
    --bug 4308359
    --X_SCH_Performance_Index    := trunc((x_BCWP / l_BCWS),2);
    X_SCH_Performance_Index      := round((x_BCWP / l_BCWS),2);

   -- Progress Management Changes. Bug # 3420093.

    if X_SCH_Performance_Index = 0 or X_SCH_Performance_Index = null
    then
       l_SCH_Performance_Index := 1;
    else
       l_SCH_Performance_Index := X_SCH_Performance_Index;
    end if;

    if l_Actual_Amount is null or l_Actual_Amount = 0
    then
        l_Actual_Amount := 1;
    else
        l_Actual_Amount := l_Actual_Amount;
    end if;

    -- Progress Management Changes. Bug # 3420093.
    --bug 4308359
    --X_COST_Performance_Index   := trunc((x_BCWP/l_Actual_Amount),2);
    X_COST_Performance_Index     := round((x_BCWP/l_Actual_Amount),2);

    -- Progress Management Changes. Bug # 3420093.

    if p_task_version_id is not null
    then
      /*select
      scheduled_start_date+((scheduled_finish_date-scheduled_start_date)/l_SCH_Performance_Index)
      into x_Sch_At_Completion
      from pa_proj_elem_ver_schedule
       where project_id = p_project_id
      and proj_element_id = p_proj_element_id
      and element_version_id = p_task_version_id;
      */

    /* Bug # 3861344: Modified API: recalculate_prog_stats(). */

    -- x_Sch_At_Completion := l_sch_start_date+((l_sch_finish_date-l_sch_start_date)/l_SCH_Performance_Index);

    -- Get baselined dates.

    OPEN cur_baselined_dates;
    FETCH cur_baselined_dates INTO l_base_start_date, l_base_finish_date;
    CLOSE cur_baselined_dates;

    -- Calculate schedule at completion.

    x_Sch_At_Completion := pa_progress_utils.return_start_end_date(l_sch_start_date,l_base_start_date,p_project_id,p_proj_element_id,'PA_TASKS','S')
                +((pa_progress_utils.return_start_end_date(l_sch_finish_date,l_base_finish_date,p_project_id,p_proj_element_id,'PA_TASKS','E')
                -pa_progress_utils.return_start_end_date(l_sch_start_date,l_base_start_date,p_project_id,p_proj_element_id,'PA_TASKS','S'))
                /l_SCH_Performance_Index);

    end if;

    l_tcpi_denom := l_Baseline_Amount-l_Actual_Amount;

    if l_tcpi_denom is null or l_tcpi_denom = 0
    then
        l_tcpi_denom := 1;
    end if;

    -- Progress Management Changes. Bug # 3420093.
    --bug 4308359
    --x_Complete_Performance_Index := trunc(((l_Baseline_Amount- x_BCWP)/l_tcpi_denom),2);
    x_Complete_Performance_Index := round(((l_Baseline_Amount- x_BCWP)/l_tcpi_denom),2);

    -- Progress Management Changes. Bug # 3420093.

  EXCEPTION WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_Msg_Count     := 1;  -- 4537865 Corrected as '1' .Earlier it was defined as '0'
      x_Msg_Data      :=  SUBSTRB(SQLERRM,1,120) ; -- 4537865 : Corrected as err message stack .Earlier it was ''
      fnd_msg_pub.add_exc_msg( p_pkg_name       => 'PA_PROGRESS_UTILS'
                  ,p_procedure_name => 'RECALCULATE_PROG_STATS'
                  ,p_error_text     => SUBSTRB(SQLERRM,1,120));

      -- 4537865
      x_BCWS                       := 0 ;
      X_BCWP                       := 0 ;
      X_SCH_Performance_Index      := 0 ;
      X_COST_Performance_Index     := 0 ;
      x_Sch_At_Completion          := NULL ;
      x_Complete_Performance_Index := 0 ;
     -- 4537865

    RAISE FND_API.G_EXC_ERROR;
END RECALCULATE_PROG_STATS;

-- Bug 3879461 : This function is not used
Procedure DEF_DATES_FROM_RESOURCES (
    p_project_id        IN NUMBER
   ,p_proj_element_id       IN NUMBER
   ,p_structure_type        IN VARCHAR2 DEFAULT 'WORKPLAN'
   ,p_As_Of_Date        IN DATE
   ,x_Actual_Start_Date     OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_Actual_Finish_Date    OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_Estimated_Start_Date  OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_Estimated_Finish_Date OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  Cursor CUR_Est_Sch_Dates
    IS
    Select MIN(Estimated_Start_Date), MAX(Estimated_Finish_Date), MIN(Actual_Start_Date), MAX(Actual_Finish_Date)
    FROM   PA_Progress_Rollup
    Where  Project_ID       = P_Project_ID
    AND    Proj_Element_ID  = P_Proj_Element_ID
    AND    Object_Type      = 'PA_ASSIGNMENTS'
    AND    As_Of_Date       = p_As_Of_Date
    AND    Structure_type   = p_structure_type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  Open CUR_Est_Sch_Dates;
  FETCH CUR_Est_Sch_Dates Into
    x_Estimated_Start_Date, x_Estimated_Finish_Date, x_Actual_Start_Date, x_Actual_Finish_Date;
  Close CUR_Est_Sch_Dates;

  EXCEPTION WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_Msg_Count     := 1; -- 4537865 Changed from 0 to 1.
      x_Msg_Data      :=  SUBSTRB(SQLERRM,1,120); -- 4537865 Changed from '' to   SUBSTRB(SQLERRM,1,120)

   -- 4537865
   x_Actual_Start_Date         := NULL ;
   x_Actual_Finish_Date        := NULL ;
   x_Estimated_Start_Date      := NULL ;
   x_Estimated_Finish_Date     := NULL ;
  -- 4537865

      fnd_msg_pub.add_exc_msg( p_pkg_name       => 'PA_PROGRESS_UTILS'
                  ,p_procedure_name => 'DEF_DATES_FROM_RESOURCES'
                  ,p_error_text     => x_msg_data);
    RAISE FND_API.G_EXC_ERROR;
END DEF_DATES_FROM_RESOURCES;

--- End of addding new APIs

FUNCTION check_actuals_allowed (p_project_id     IN NUMBER
                               ,p_structure_type IN VARCHAR2 := 'WORKPLAN') RETURN VARCHAR2
IS
    l_return_value VARCHAR2(1) := null;
BEGIN

    select remain_effort_enable_flag
    into l_return_value
    from pa_proj_progress_attr
    where project_id = p_project_id
    and structure_type = p_structure_type;

    return(l_return_value);

END check_actuals_allowed;

-- Progress Management Changes. Bug # 3420093.

FUNCTION get_bcws (p_project_id                 IN NUMBER
                  ,p_object_id                  IN NUMBER
                  ,p_proj_element_id            IN NUMBER
                  ,p_as_of_date                 IN DATE
                  ,p_structure_version_id       IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                  ,p_rollup_method              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                  ,p_scheduled_start_date       IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                  ,p_scheduled_end_date         IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          ,p_prj_currency_code          IN VARCHAR2 := null           --bug 3824042
          ,p_structure_type             IN VARCHAR2 := 'WORKPLAN'   --maansari4/10
          ) RETURN NUMBER
IS
    l_return_bcws NUMBER := null;
    l_multiplier  NUMBER := 0;
    l_rollup_method VARCHAR2(15) := null;

-- Progress Management Changes. Bug # 3420093.

    cursor c1 (p_project_id NUMBER, p_object_id NUMBER) is
    select pppa.task_weight_basis_code
    from pa_proj_progress_attr pppa
    where pppa.project_id = p_project_id
    and pppa.structure_type = p_structure_type;

    cursor c2 (p_project_id NUMBER, p_proj_element_id NUMBER, p_structure_version_id NUMBER) is
    select
        /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
        nvl(pfxat.BASE_LABOR_HOURS,pfxat.labor_hours) labor_hours
           ,nvl(pfxat.BASE_EQUIP_HOURS,pfxat.equipment_hours) equipment_hours
           ,nvl(pfxat.PRJ_BASE_BRDN_COST,pfxat.prj_brdn_cost) prj_brdn_cost
    from pji_fm_xbs_accum_tmp1 pfxat
    where pfxat.struct_version_id = p_structure_version_id
    and pfxat.project_id = p_project_id
    and pfxat.project_element_id = p_proj_element_id
    and pfxat.plan_version_id > 0
    AND pfxat.txn_currency_code is null    --bug no. 3646988
    and pfxat.calendar_type  = 'A';

    c1rec c1%rowtype;
    c2rec c2%rowtype;

        --bug 3908112
    CURSOR cur_proj_curr
    IS
      SELECT project_currency_code from pa_projects_all where project_id=p_project_id;

        l_prj_currency_code      VARCHAR2(120);
        --end bug 3908112

        -- Begin: Fix for Bug # 3926529.

        cursor cur_baselined_dates is
        select ppe.baseline_start_date, ppe.baseline_finish_date
        from pa_proj_elements ppe
        where ppe.project_id = p_project_id
        and ppe.proj_element_id = p_proj_element_id;

        cursor cur_scheduled_dates is
        select ppevs.scheduled_start_date, ppevs.scheduled_finish_date
        from pa_proj_elem_ver_schedule ppevs
        where ppevs.project_id = p_project_id
        and ppevs.proj_element_id = p_proj_element_id
        and ppevs.element_version_id = (select ppev.element_version_id
                                        from pa_proj_element_versions ppev
                                        where ppev.project_id = p_project_id
                                        and ppev.proj_element_id = p_proj_element_id
                                        and ppev.parent_structure_version_id = p_structure_version_id);
        l_start_date    DATE;

        l_end_date      DATE;

        -- End: Fix for Bug # 3926529.

BEGIN
/* Addition for bug 6156686 */
/* Commeted for bug 6664716
    IF NVL(l_bcws_project_id,-1)               =  NVL(p_project_id,-1)                AND
     NVL(l_bcws_object_id,-1)                  =  NVL(p_object_id,-1)                 AND
     NVL(l_bcws_proj_element_id,-1)            =  NVL(p_proj_element_id,-1)           AND
     NVL(l_bcws_as_of_date,sysdate)            =  NVL(p_as_of_date,sysdate)           AND
     NVL(l_bcws_structure_version_id,-1)       =  NVL(p_structure_version_id,-1)      AND
     NVL(l_bcws_rollup_method,'-99')           =  NVL(p_rollup_method,'-99')          AND
     NVL(l_bcws_scheduled_start_date,sysdate)  =  NVL(p_scheduled_start_date,sysdate) AND
     NVL(l_bcws_scheduled_end_date,sysdate)    =  NVL(p_scheduled_end_date,sysdate)   AND
     NVL(l_bcws_prj_currency_code,'-99')       =  NVL(p_prj_currency_code,'-99')      AND
     NVL(l_bcws_structure_type,'-99')          =  NVL(p_structure_type,'-99') THEN

        RETURN l_bcws_value;

    ELSE

        l_bcws_project_id            := p_project_id          ;
        l_bcws_object_id             := p_object_id           ;
        l_bcws_proj_element_id       := p_proj_element_id     ;
        l_bcws_as_of_date            := p_as_of_date          ;
        l_bcws_structure_version_id  := p_structure_version_id;
        l_bcws_rollup_method         := p_rollup_method       ;
        l_bcws_scheduled_start_date  := p_scheduled_start_date;
        l_bcws_scheduled_end_date    := p_scheduled_end_date  ;
        l_bcws_prj_currency_code     := p_prj_currency_code   ;
        l_bcws_structure_type        := p_structure_type      ;

    END IF;
*/

    open c2(p_project_id,p_proj_element_id,p_structure_version_id);
    fetch c2 into c2rec;
    close c2;

    --bug  6664716
    IF p_project_id <> l_prv_bcws_project_id OR
       p_structure_version_id <> l_prv_bcws_struc_ver_id
    THEN
       get_plan_value(p_project_id,p_structure_version_id,p_proj_element_id,p_as_of_date );
    END IF;
    --bug  6664716

    if (p_rollup_method IS NOT NULL and p_rollup_method <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) then

        if p_rollup_method = 'EFFORT' then
                --bug 3824042
                    --l_return_bcws := trunc((nvl(c2rec.labor_hours,0)+nvl(c2rec.equipment_hours,0)),2);

      --Start Changes for Bug 6664716
      IF l_bcws_hash_tbl.exists('PA'||p_proj_element_id) THEN
        l_return_bcws := nvl(l_bcws_hash_tbl('PA'||p_proj_element_id).labor_hrs,0)
                    +nvl(l_bcws_hash_tbl('PA'||p_proj_element_id).equip_hrs,0);
      ELSE
        l_return_bcws := nvl(c2rec.labor_hours,0)+nvl(c2rec.equipment_hours,0);
      END IF;
      l_rollup_method := 'EFFORT';
      --End Changes for Bug 6664716

                else
                --bug 3824042
                        --l_return_bcws := trunc(nvl(c2rec.prj_brdn_cost,0),2);

      --Start Changes for Bug 6664716
      IF l_bcws_hash_tbl.exists('PA'||p_proj_element_id) THEN
        l_return_bcws := nvl(l_bcws_hash_tbl('PA'||p_proj_element_id).prj_brdn_cost,0);
      ELSE
        l_return_bcws := nvl(c2rec.prj_brdn_cost,0);
      END IF;
      --End Changes for Bug 6664716

                end if;
    else
        open c1(p_project_id,p_object_id);
            fetch c1 into c1rec;
        close c1;

                if c1rec.task_weight_basis_code = 'EFFORT' then
                --bug 3824042
                    --l_return_bcws := trunc((nvl(c2rec.labor_hours,0)+nvl(c2rec.equipment_hours,0)),2);

        --Start Changes for Bug 6664716
        IF l_bcws_hash_tbl.exists('PA'||p_proj_element_id) THEN
          l_return_bcws := nvl(l_bcws_hash_tbl('PA'||p_proj_element_id).labor_hrs,0)
                        +nvl(l_bcws_hash_tbl('PA'||p_proj_element_id).equip_hrs,0);
        ELSE
          l_return_bcws := nvl(c2rec.labor_hours,0)+nvl(c2rec.equipment_hours,0);
        END IF;
        --End Changes for Bug 6664716

            l_rollup_method := 'EFFORT';
                else
                --bug 3824042
                        --l_return_bcws := trunc(nvl(c2rec.prj_brdn_cost,0),2);
              --Start Changes for Bug 6664716
              IF l_bcws_hash_tbl.exists('PA'||p_proj_element_id) THEN
                l_return_bcws := nvl(l_bcws_hash_tbl('PA'||p_proj_element_id).prj_brdn_cost,0);
              ELSE
                l_return_bcws := nvl(c2rec.prj_brdn_cost,0);
              END IF;
              --End Changes for Bug 6664716
                end if;
    end if;

        -- This if condition will be used when period typd is non timephased then the calcualtion of planned value is done
        -- in the same way as done previosly.
        IF l_bcws_hash_tbl.exists('PA'||p_proj_element_id) THEN
          NULL;
  ELSE

        -- Begin: Fix for Bug # 3926529.

        -- If input dates are not null use the input dates.

        if (p_scheduled_start_date is not null) and (p_scheduled_end_date is not null) then

                l_start_date := p_scheduled_start_date;

                l_end_date := p_scheduled_end_date;
        else

         -- If input dates are null use the baselined dates.

                open cur_baselined_dates;

                fetch cur_baselined_dates into l_start_date, l_end_date;

                -- If baselined dates do not exist then use the scheduled dates.

                if cur_baselined_dates%notfound OR (l_start_date is null and l_end_date is null) then  ----5478084

                        open cur_scheduled_dates;

                        fetch cur_scheduled_dates into l_start_date, l_end_date;

                        close cur_scheduled_dates;

                end if;

                close cur_baselined_dates;
        end if;

        -- Determine the multiplier using the above dates.
    -- Bug 4587056 : if l_start_date - p_as_of_date is 0 then multiplier should be 1 instead of 0
    /* bug 5478084 if l_start_date - p_as_of_date is 0 then multiplier should be 1/duration
        if ((l_start_date - p_as_of_date) = 0) then

                l_multiplier := 1; */

        if ((l_start_date - p_as_of_date) > 0) then

                l_multiplier := 0;

        elsif ((p_as_of_date - l_end_date) >= 0) then

                l_multiplier := 1;

        elsif (nvl((l_end_date - l_start_date),0) > 0) then

                --bug# 3825683, Satish
                --l_multiplier := trunc((nvl((p_as_of_date - l_start_date),0)/
                --              nvl((l_end_date - l_start_date),0)),2);
                l_multiplier := nvl((trunc(p_as_of_date) - trunc(l_start_date)+1),0)/
                                nvl((trunc(l_end_date) - trunc(l_start_date)+1),1); --bug 6058342
        end if;

        /* Begin commenting out the following code

    if ((p_scheduled_start_date - p_as_of_date) >= 0) then

        l_multiplier := 0;

    elsif ((p_as_of_date - p_scheduled_end_date) >= 0) then

        l_multiplier := 1;

    elsif (nvl((p_scheduled_end_date - p_scheduled_start_date),0) > 0) then

        --bug# 3825683, Satish
        --l_multiplier := trunc((nvl((p_as_of_date - p_scheduled_start_date),0)/
        --      nvl((p_scheduled_end_date - p_scheduled_start_date),0)),2);
        l_multiplier := nvl((trunc(p_as_of_date) - trunc(p_scheduled_start_date)+1),0)/
                nvl((trunc(p_scheduled_end_date) - trunc(p_scheduled_start_date)+1),0);
    end if;

        End commenting out the above code. */

        -- End: Fix for Bug # 3926529.

-- Progress Management Changes. Bug # 3420093.

    l_return_bcws := l_return_bcws * l_multiplier;

        END IF; -- _bcws_hash_tbl.exists('PA'||p_proj_element_id)

    --bug 3824042, start
    if (l_rollup_method = 'EFFORT')
    THEN
        l_return_bcws := round(l_return_bcws, 5);
    ELSE

            --bug 3908112
            if p_prj_currency_code is null
            then
               OPEN cur_proj_curr;
               FETCH  cur_proj_curr INTO l_prj_currency_code;
               CLOSE cur_proj_curr;
            else
               l_prj_currency_code := p_prj_currency_code;
            end if;
              l_return_bcws := pa_currency.round_trans_currency_amt1(l_return_bcws, l_prj_currency_code);
            --l_return_bcws := pa_currency.round_trans_currency_amt(l_return_bcws, l_prj_currency_code);
        --l_return_bcws := pa_currency.round_trans_currency_amt(l_return_bcws, p_prj_currency_code);
            --end bug 3908112

    END IF;
    --bug 3824042, end
    l_bcws_value := l_return_bcws; -- Added for bug 6339381
    return(l_return_bcws);

END get_bcws;

FUNCTION get_latest_ass_prog_date(p_project_id          IN      NUMBER
                                 ,p_structure_type      IN      VARCHAR2
                                 ,p_object_id           IN      NUMBER
                                 ,p_object_type         IN      VARCHAR2
         ,p_task_id IN  NUMBER := null /* Modified for IB4 Progress CR. */) RETURN DATE
IS
    l_return_date   DATE;
BEGIN

    select max(date_computed)
    into l_return_date
    from pa_percent_completes ppc
    where ppc.project_id = p_project_id
    and ppc.structure_type = p_structure_type
    and ppc.object_id = p_object_id
    and ppc.object_type = p_object_type
    and ppc.task_id = nvl(p_task_id, p_object_id) /* Modified for IB4 Progress CR. */;

    return(l_return_date);

END get_latest_ass_prog_date;

FUNCTION get_resource_list_id ( p_resource_list_member_id NUMBER) RETURN NUMBER IS
     CURSOR cur_res_list_id
     IS
      SELECT resource_list_id
        FROM pa_resource_list_members
       WHERE resource_list_member_id = p_resource_list_member_id ;

    l_resource_list_id    NUMBER;
BEGIN
     OPEN cur_res_list_id;
     FETCH cur_res_list_id INTO l_resource_list_id;
     CLOSE cur_res_list_id;
     RETURN l_resource_list_id;
END get_resource_list_id;

function get_max_rollup_asofdate2(p_project_id   IN  NUMBER,
                                 p_object_id    IN  NUMBER,
                                 p_object_type  IN  VARCHAR2,
                 p_structure_type IN VARCHAR2 := 'WORKPLAN', -- FPM Dev CR 3
                 p_structure_version_id IN NUMBER := NULL -- FPM Dev CR 4
                 ,p_proj_element_id IN NUMBER  := null /* Modified for IB4 Progress CR. */
                                 ) return date is
l_rollup_date   date;
CURSOR cur_rollupdate
IS
           select max(as_of_date)
             from pa_progress_rollup
            where project_id = p_project_id
              and object_id = p_object_id
              and object_type = p_object_type
          and structure_type = p_structure_type -- FPM Dev CR 4
          and ((p_structure_version_id is null AND structure_version_id is null) OR (p_structure_version_id is not null AND structure_version_id = p_structure_version_id)) -- FPM Dev CR 4

--              and NVL(proj_element_id,-1) = DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id)) /* Amit : Modified for IB4 Progress CR. */
--  Commented out to fix Bug # 4243074.

-- Begin fix for Bug # 4243074.

and NVL(proj_element_id,-1) = DECODE(p_structure_type, 'FINANCIAL'
                                                     , DECODE(p_object_type, 'PA_STRUCTURES'
                                                                           , 0
                                                                           , (DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id))))
                                                     ,(DECODE(p_object_type, 'PA_DELIVERABLES', NVL(p_proj_element_id,NVL(proj_element_id,-1)),NVL(p_proj_element_id, p_object_id))))

-- End fix for Bug # 4243074.

          and current_flag <> 'W' -- Bug 3879461
         -- and proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
          ;
begin

   OPEN cur_rollupdate;
   FETCH cur_rollupdate INTO l_rollup_date;
   CLOSE cur_rollupdate;

return l_rollup_date;

exception when others then
  return null;
end get_max_rollup_asofdate2;

procedure set_prog_as_of_Date(p_project_id   IN NUMBER,
                              p_task_id      IN NUMBER,
                              p_as_of_date   IN DATE default to_date(null),
                  p_object_id    IN NUMBER := null, -- Bug 3974627
                  p_object_type  IN VARCHAR2 := 'PA_TASKS' -- Bug 3974627
                  ) IS
BEGIN
    if p_as_of_date is null then
    IF p_object_type = 'PA_TASKS' THEN
           G_prog_as_of_date := get_prog_dt_closest_to_sys_dt(p_project_id => p_project_id,
                         p_task_id    => p_task_id);
    ELSE  -- Bug 3974627 : Added ELSE and call of get_prog_dt_closest_to_sys_dt
           G_prog_as_of_date := get_prog_dt_closest_to_sys_dt(p_project_id => p_project_id,
                         p_task_id    => p_task_id,
                         p_object_id => p_object_id,
                         p_object_type => p_object_type);
    END IF;
    else
       G_prog_as_of_date := p_as_of_date;
    end if;

exception when others then
    null;
END set_prog_as_of_Date;

function get_prog_asofdate return date is
begin
  return pa_progress_utils.g_prog_as_of_date;
end get_prog_asofdate;


--The following api is used to render cost region on Task progress Details -summary page
--bug  4085786, start
/*function check_workplan_cost ( p_project_id   NUMBER)  RETURN VARCHAR2 IS

  l_workplan_cost   VARCHAR2(1) := 'Y';
  l_labor_cost_flag VARCHAR2(1) := 'Y';
BEGIN

  l_labor_cost_flag := PA_SECURITY.view_labor_costs(p_project_id);
  l_workplan_cost := Pa_Fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id);

  --return 'N' if any of the cost is allowed.

  IF l_labor_cost_flag <> 'Y' OR l_workplan_cost <> 'Y'
  THEN
     return 'N';
  ELSE
     return 'Y';
  END IF;
END check_workplan_cost;*/

function check_workplan_cost ( p_project_id IN NUMBER,
                   p_task_id    IN NUMBER   := NULL,
                   p_object_id  IN NUMBER   := NULL,
                   p_object_type    IN VARCHAR2 := 'PA_TASKS',
                   p_structure_version_id IN NUMBER := NULL
                 )  RETURN VARCHAR2 IS

  l_workplan_cost   VARCHAR2(1) := 'Y';
  l_labor_cost_flag VARCHAR2(1) := 'Y';
  l_person_id       NUMBER;             -- Added for Bug 3964394

  CURSOR c_assgmt_count IS
  SELECT count(*) FROM pa_task_asgmts_v
  WHERE project_id = p_project_id
  AND   task_id  = p_task_id
  AND   structure_version_id = p_structure_version_id
  AND   ta_display_flag = 'Y';

  CURSOR c_get_task_res_class_code IS
  SELECT resource_class_code FROM pa_task_asgmts_v
  WHERE project_id = p_project_id
  AND   task_id  = p_task_id
  AND   structure_version_id = p_structure_version_id
  AND   ta_display_flag = 'Y';

  CURSOR c_get_res_class_code IS
  SELECT resource_class_code, ta_display_flag FROM pa_task_asgmts_v
  WHERE project_id = p_project_id
  AND   task_id  = p_task_id
  AND   resource_list_member_id = p_object_id
  AND   structure_version_id = p_structure_version_id;

  l_tot_assgmts  NUMBER;
  l_res_class_code VARCHAR2(20);
  l_ta_display_flag VARCHAR2(1);
BEGIN


  --l_labor_cost_flag := PA_SECURITY.view_labor_costs(p_project_id);   /* Commented for Bug 3964394 */

  /* Start Bug 3964394 - Changed the function call from view_labor_costs to check_labor_cost_access */
  IF ( FND_GLOBAL.USER_ID IS NOT NULL ) THEN
     l_person_id := pa_utils.GetEmpIdFromUser( FND_GLOBAL.USER_ID );
     l_labor_cost_flag := PA_SECURITY.check_labor_cost_access(l_person_id, p_project_id);
  ELSE
     l_labor_cost_flag := 'N';       -- In case the user_id is null then don't show the region.
  END IF;
  /* End Bug 3964394 */

  l_workplan_cost := Pa_Fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id);

  IF l_workplan_cost <> 'Y'
  THEN
    return 'N';
  END IF;

  IF p_task_id IS NULL
  THEN
    return l_labor_cost_flag;
  END IF;

  IF p_object_type = 'PA_TASKS'
  THEN
    OPEN c_assgmt_count;
    FETCH c_assgmt_count INTO l_tot_assgmts;
    CLOSE c_assgmt_count;
    IF l_tot_assgmts = 1
    THEN
        OPEN c_get_task_res_class_code;
        FETCH c_get_task_res_class_code INTO l_res_class_code;
        CLOSE c_get_task_res_class_code;
        IF l_res_class_code = 'PEOPLE'
        THEN
            return l_labor_cost_flag;
        ELSE
            return 'Y';
        END IF;
    ELSE
        return 'Y';
    END IF;
  ELSIF p_object_type = 'PA_ASSIGNMENTS'
  THEN
    OPEN c_get_res_class_code;
    FETCH c_get_res_class_code INTO l_res_class_code, l_ta_display_flag;
    CLOSE c_get_res_class_code;

    IF l_res_class_code = 'PEOPLE' AND l_ta_display_flag = 'Y'
    THEN
        return l_labor_cost_flag;
    ELSE
        return 'Y';
    END IF;
  END IF;

END check_workplan_cost;
--bug  4085786, end

-- Progress Management Changes. Bug # 3420093.

procedure get_actuals_for_task(p_project_id             IN      NUMBER
                              ,p_wp_task_id             IN      NUMBER
                  ,p_res_list_mem_id        IN      NUMBER
                              ,p_as_of_date             IN      DATE
                              ,x_planned_work_qty       OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_actual_work_qty        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_cost_pc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_cost_pc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_cost_pc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_cost_fc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_cost_fc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_cost_fc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_act_labor_effort   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_act_eqpmt_effort   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_unit_of_measure        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_txn_currency_code      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_ppl_act_cost_tc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_cost_tc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_cost_tc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_rawcost_pc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_rawcost_pc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_rawcost_pc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_rawcost_fc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_rawcost_fc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_rawcost_fc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_rawcost_tc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_rawcost_tc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_rawcost_tc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_oth_quantity          OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_return_status          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_msg_count              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_msg_data               OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS

l_wp_task_id        NUMBER := NULL;
l_wp_task_ver_id    NUMBER := NULL;

l_wp_str_ver_id         NUMBER := NULL;

l_return_status         VARCHAR2(1) := null;
l_msg_count             NUMBER := null;
l_msg_data              VARCHAR2(250) := null;

cursor c1_task (p_project_id number, p_object_id number, p_as_of_date date) is
select cumulative_work_quantity, ppl_act_cost_to_date_pc, eqpmt_act_cost_to_date_pc, oth_act_cost_to_date_pc,
ppl_act_cost_to_date_fc, eqpmt_act_cost_to_date_fc, oth_act_cost_to_date_fc, ppl_act_effort_to_date,
eqpmt_act_effort_to_date, ppl_act_cost_to_date_tc, eqpmt_act_cost_to_date_tc, oth_act_cost_to_date_tc,
txn_currency_code, ppl_act_rawcost_to_date_pc, eqpmt_act_rawcost_to_date_pc, oth_act_rawcost_to_date_pc,
ppl_act_rawcost_to_date_fc, eqpmt_act_rawcost_to_date_fc, oth_act_rawcost_to_date_fc,
ppl_act_rawcost_to_date_tc, eqpmt_act_rawcost_to_date_tc, oth_act_rawcost_to_date_tc, oth_quantity_to_date
from pa_progress_rollup ppr1
where ppr1.project_id = p_project_id
and ppr1.object_id = p_object_id
and ppr1.structure_version_id is null
AND ppr1.current_flag <> 'W'   -- Bug 3879461
and ppr1.as_of_date = ( SELECT max(ppr2.as_of_date)
                     from pa_progress_rollup ppr2
                    WHERE ppr2.as_of_date <= p_as_of_date
                      AND ppr2.object_id = p_object_id
                      AND ppr2.project_id = p_project_id
                      and ppr2.structure_type = 'WORKPLAN'
                      AND ppr2.current_flag <> 'W'   -- Bug 3879461
                      and ppr2.structure_version_id is null
                   )
and ppr1.structure_type = 'WORKPLAN'
;

cursor c1_assgn (p_project_id number, p_object_id number, p_proj_element_id number, p_as_of_date date) is
select cumulative_work_quantity, ppl_act_cost_to_date_pc, eqpmt_act_cost_to_date_pc, oth_act_cost_to_date_pc,
ppl_act_cost_to_date_fc, eqpmt_act_cost_to_date_fc, oth_act_cost_to_date_fc, ppl_act_effort_to_date,
eqpmt_act_effort_to_date, ppl_act_cost_to_date_tc, eqpmt_act_cost_to_date_tc, oth_act_cost_to_date_tc,
txn_currency_code, ppl_act_rawcost_to_date_pc, eqpmt_act_rawcost_to_date_pc, oth_act_rawcost_to_date_pc,
ppl_act_rawcost_to_date_fc, eqpmt_act_rawcost_to_date_fc, oth_act_rawcost_to_date_fc,
ppl_act_rawcost_to_date_tc, eqpmt_act_rawcost_to_date_tc, oth_act_rawcost_to_date_tc, oth_quantity_to_date
from pa_progress_rollup ppr1
where ppr1.project_id = p_project_id
and ppr1.object_id = p_object_id
and ppr1.proj_element_id = p_proj_element_id
and ppr1.structure_version_id is null
AND ppr1.current_flag <> 'W'   -- Bug 3879461
and ppr1.as_of_date = ( SELECT max(ppr2.as_of_date)
                     from pa_progress_rollup ppr2
                    WHERE ppr2.as_of_date <= p_as_of_date
                      AND ppr2.object_id = p_object_id
              AND ppr2.proj_element_id = p_proj_element_id
                      AND ppr2.project_id = p_project_id
                      and ppr2.structure_type = 'WORKPLAN'
                      AND ppr2.current_flag <> 'W'   -- Bug 3879461
                      and ppr2.structure_version_id is null
                   )
and ppr1.structure_type = 'WORKPLAN'
;

c1rec c1_task%rowtype;

cursor c4(p_project_id number, p_proj_element_id number) is
select wq_uom_code
from pa_proj_elements
where project_id = p_project_id
and proj_element_id = p_proj_element_id;

cursor c2(p_element_version_id NUMBER) is
select proj_element_id
from pa_proj_element_versions
where element_version_id = p_element_version_id;

cursor c3(p_project_id NUMBER, p_element_version_id NUMBER) is
select wq_planned_quantity
from pa_proj_elem_ver_schedule
where project_id = p_project_id
and element_version_id = p_element_version_id;


cursor c1_proj_level IS
select cumulative_work_quantity, ppl_act_cost_to_date_pc, eqpmt_act_cost_to_date_pc, oth_act_cost_to_date_pc,
ppl_act_cost_to_date_fc, eqpmt_act_cost_to_date_fc, oth_act_cost_to_date_fc, ppl_act_effort_to_date,
eqpmt_act_effort_to_date
from pa_progress_rollup ppr1
where ppr1.project_id = p_project_id
and ppr1.object_type = 'PA_STRUCTURES'
and ppr1.structure_version_id is null
AND ppr1.current_flag <> 'W'   -- Bug 3879461
and ppr1.as_of_date = ( SELECT max(ppr2.as_of_date)
                     from pa_progress_rollup ppr2
                    WHERE ppr2.as_of_date <= p_as_of_date
                      AND ppr2.object_type = 'PA_STRUCTURES'
                      AND ppr2.project_id = p_project_id
                      and ppr2.structure_type = 'WORKPLAN'
                      and ppr2.structure_version_id is null
                      AND ppr2.current_flag <> 'W'   -- Bug 3879461
                   )
and ppr1.structure_type = 'WORKPLAN'
;

/* Begin code to fix Bug # 4172372. */

cursor cur_task_version(c_project_id NUMBER, c_wp_task_id NUMBER, c_wp_str_ver_id NUMBER) is
select ppev.element_version_id
from pa_proj_element_versions ppev
where ppev.project_id = c_project_id
and ppev.proj_element_id = c_wp_task_id
and ppev.parent_structure_version_id = c_wp_str_ver_id;

/* End code to fix Bug # 4172372. */

BEGIN
    savepoint get_actuals_for_task;

    l_return_status := FND_API.G_RET_STS_SUCCESS;


    /* Begin commenting the following code as we are now accepting workplan task id's in the API.

    -- Get workplan task version id for finacial task id.

    IF p_fin_task_id IS NOT NULL THEN   --bug 3753042

    l_wp_task_ver_id := pa_progress_utils.wp_task_ver_id_for_fin_task_id(p_project_id,p_fin_task_id);

    -- Get workplan task id for workplan task version id.

    open c2(l_wp_task_ver_id);
    fetch c2 into l_wp_task_id;
    close c2;

    -- Get planned work quantity.

    open c3(p_project_id,l_wp_task_ver_id);
        fetch c3 into x_planned_work_qty;
        close c3;

    -- Get actuals for the workplan task.

    open c1(p_project_id,l_wp_task_id,l_wp_task_ver_id,p_as_of_date);
    fetch c1 into c1rec;
    close c1;

    ELSE  --get the project level data if financial task id is null  bug 3753042

        l_wp_task_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(p_project_id);

        open c3(p_project_id,l_wp_task_ver_id);
        fetch c3 into x_planned_work_qty;
        close c3;

       -- Get actuals for the workplan task.

        open c1_proj_level;
        fetch c1_proj_level into c1rec;
        close c1_proj_level;


    END IF;
    End commenting the following code as we are now accepting workplan task id's in the API. */


        l_wp_task_id := p_wp_task_id;
        l_wp_str_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(p_project_id);

        -- If task level information is requested.

        if (p_res_list_mem_id is null) then

           -- Get actuals and txn currency code for the workplan task.

           open c1_task(p_project_id,l_wp_task_id,p_as_of_date);
           fetch c1_task into c1rec;
           close c1_task;

    -- If assignment level information is requested.

    else

       open c1_assgn(p_project_id,p_res_list_mem_id,l_wp_task_id,p_as_of_date);
           fetch c1_assgn into c1rec;
           close c1_assgn;

    end if;

    -- Get actuals and txn currency code for the workplan task.

        x_actual_work_qty := c1rec.cumulative_work_quantity;
        x_ppl_act_cost_pc := c1rec.ppl_act_cost_to_date_pc;
        x_eqpmt_act_cost_pc := c1rec.eqpmt_act_cost_to_date_pc;
        x_oth_act_cost_pc := c1rec.oth_act_cost_to_date_pc;
        x_ppl_act_cost_fc := c1rec.ppl_act_cost_to_date_fc;
        x_eqpmt_act_cost_fc := c1rec.eqpmt_act_cost_to_date_fc;
        x_oth_act_cost_fc := c1rec.oth_act_cost_to_date_fc;
        x_act_labor_effort := c1rec.ppl_act_effort_to_date;
        x_act_eqpmt_effort := c1rec.eqpmt_act_effort_to_date;
        x_ppl_act_cost_tc := c1rec.ppl_act_cost_to_date_tc;
        x_eqpmt_act_cost_tc := c1rec.eqpmt_act_cost_to_date_tc;
        x_oth_act_cost_tc := c1rec.oth_act_cost_to_date_tc;
        x_txn_currency_code := c1rec.txn_currency_code;


    -- Get actuals in rawcost and other_quantity_to_date.

    x_ppl_act_rawcost_pc     := c1rec.ppl_act_rawcost_to_date_pc;
    x_eqpmt_act_rawcost_pc   := c1rec.eqpmt_act_rawcost_to_date_pc;
    x_oth_act_rawcost_pc     := c1rec.oth_act_rawcost_to_date_pc;
    x_ppl_act_rawcost_fc     := c1rec.ppl_act_rawcost_to_date_fc;
    x_eqpmt_act_rawcost_fc   := c1rec.eqpmt_act_rawcost_to_date_fc;
    x_oth_act_rawcost_fc     := c1rec.oth_act_rawcost_to_date_fc;
    x_ppl_act_rawcost_tc     := c1rec.ppl_act_rawcost_to_date_tc;
    x_eqpmt_act_rawcost_tc   := c1rec.eqpmt_act_rawcost_to_date_tc;
    x_oth_act_rawcost_tc     := c1rec.oth_act_rawcost_to_date_tc;
    x_oth_quantity       := c1rec.oth_quantity_to_date;


    /* Begin code to fix Bug # 4172372. */

    -- Get the task_version_id for the workplan task.

    open cur_task_version(p_project_id, l_wp_task_id, l_wp_str_ver_id);
    fetch cur_task_version into l_wp_task_ver_id;
    close cur_task_version;

        /* End code to fix Bug # 4172372. */

    -- Get planned work quantity for worplan task.

    open c3(p_project_id, l_wp_task_ver_id); -- Fix for Bug # 4172372.
        fetch c3 into x_planned_work_qty;
        close c3;

    -- Get unit of measure for the workplan task

        open c4(p_project_id,l_wp_task_id);
        fetch c4 into x_unit_of_measure;
        close c4;

    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => l_msg_data);
                x_msg_data := l_msg_data;
                x_return_status := 'E';
                x_msg_count := l_msg_count;
                RAISE  FND_API.G_EXC_ERROR;
        END IF;

EXCEPTION

    when FND_API.G_EXC_ERROR then
      rollback to get_actuals_for_task;
      x_return_status := FND_API.G_RET_STS_ERROR;

    when FND_API.G_EXC_UNEXPECTED_ERROR then
      rollback to get_actuals_for_task;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'get_actuals_for_task',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
    when OTHERS then
      rollback to get_actuals_fortask;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'get_actuals_for_task',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
      raise;

END get_actuals_for_task;

-- Progress Management Changes. Bug # 3420093.

FUNCTION wp_task_ver_id_for_fin_task_id(p_project_id NUMBER, p_fin_task_id NUMBER) return NUMBER
IS
    l_fin_str_ver_id        NUMBER := NULL;
    l_fin_task_ver_id       NUMBER := NULL;
    l_wp_task_ver_id        NUMBER := NULL;
    l_structure_sharing_code    VARCHAR2(30) := NULL;

    cursor c1(p_proj_element_id NUMBER, p_structure_version_id NUMBER) is
    select element_version_id
    from pa_proj_element_versions
    where project_id = p_project_id
    and proj_element_id = p_proj_element_id
    and parent_structure_version_id = p_structure_version_id;

    cursor c2(p_fin_task_ver_id NUMBER) is
    select object_id_from1
        from pa_object_relationships
        where relationship_type='M'
        and object_type_from='PA_TASKS'
        and object_type_to='PA_TASKS'
        and object_id_to1 = p_fin_task_ver_id;

    cursor c3(p_project_id NUMBER) is
    select structure_sharing_code
    from pa_projects_all
    where project_id = p_project_id;

BEGIN

    open c3(p_project_id);
    fetch c3 into l_structure_sharing_code;
    close c3;

    -- Get financial structure version id.

    l_fin_str_ver_id :=  PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id);

    -- Get financial task version id.

    open c1(p_fin_task_id,l_fin_str_ver_id);
    fetch c1 into l_fin_task_ver_id;
    close c1;

    -- Get workplan task version id.

    if l_structure_sharing_code = 'SPLIT_MAPPING' then

        open c2(l_fin_task_ver_id);
        fetch c2 into l_wp_task_ver_id;
        close c2;

    else

        l_wp_task_ver_id := l_fin_task_ver_id;

    end if;

    return(l_wp_task_ver_id);

END wp_task_ver_id_for_fin_task_id;

/* Bug 3595585 : Added the following procedure */
FUNCTION get_last_etc_effort(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_as_of_date  DATE
    ,p_structure_type VARCHAR2 := 'WORKPLAN'
    ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER IS

  CURSOR cur_task_etc_effort
  IS
    SELECT NVL( ESTIMATED_REMAINING_EFFORT, 0 ) + NVL( EQPMT_ETC_EFFORT, 0 )
     FROM pa_progress_rollup
    WHERE  project_id = p_project_id
     AND   object_id  = p_object_id
     and proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
     --Commented by rtarway for BUG 3835474
     /*AND   as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup
                          WHERE as_of_date < p_as_of_date
                           AND  project_id = p_project_id
                           AND object_id  = p_object_id
                           AND object_type = p_object_type
                           AND structure_type = p_structure_type
        and proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR.
                       )*/
     --Added by rtarway for BUG 3835474
     AND   as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date <= p_as_of_date
                           AND  ppr2.project_id = p_project_id
                           AND ppr2.object_id  = p_object_id
                           AND ppr2.object_type = p_object_type
                           AND ppr2.structure_type = p_structure_type
                           AND ppr2.structure_version_id is null -- Bug 3879461
                   and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR.*/
                           AND ppr2.current_flag <> 'W'   -- Bug 3879461
--                           AND NOT EXISTS (
--                      SELECT 'X' FROM pa_percent_completes ppc
--                      WHERE ppc.date_computed = ppr2.as_of_date
--                      AND   ppc.project_id = p_project_id
--                      AND   ppc.object_id  = p_object_id
--                      AND   ppc.object_type = p_object_type
--                      AND   ppc.structure_type = p_structure_type
--                      AND   ppc.published_flag = 'N'
--                    )
                       )
     AND   object_type = p_object_type
     AND structure_type = p_structure_type
     AND structure_version_id is null -- Bug 3879461
     AND current_flag <> 'W'   -- Bug 3879461
    ;
    l_last_submitted_etc_effort    NUMBER;
BEGIN

    OPEN cur_task_etc_effort;
    FETCH cur_task_etc_effort INTO l_last_submitted_etc_effort;
    CLOSE cur_task_etc_effort;

    RETURN l_last_submitted_etc_effort;
END get_last_etc_effort;

/* Bug 3595585 : Added the following procedure */
FUNCTION get_last_etc_cost(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_as_of_date  DATE
    ,p_structure_type VARCHAR2 := 'WORKPLAN'
    ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER IS

  CURSOR cur_task_etc_cost
  IS
    SELECT (nvl(ppr.oth_etc_cost_tc,0)+nvl(ppr.ppl_etc_cost_tc,0)+nvl(ppr.eqpmt_etc_cost_tc,0))
     FROM pa_progress_rollup ppr
    WHERE  ppr.project_id = p_project_id
     AND   ppr.object_id  = p_object_id
     and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
     AND   ppr.as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date < p_as_of_date
                           AND  ppr2.project_id = p_project_id
                           AND ppr2.object_id  = p_object_id
                           AND ppr2.object_type = p_object_type
                           AND ppr2.structure_type = p_structure_type
               AND ppr2.structure_version_id is null -- Bug 3879461
                          AND ppr2.current_flag <> 'W'   -- Bug 3879461
                        and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                       )
     AND   ppr.object_type = p_object_type
     AND ppr.structure_type = p_structure_type
     AND ppr.structure_version_id is null -- Bug 3879461
     AND ppr.current_flag <> 'W'   -- Bug 3879461

     ;

  l_last_submitted_etc_cost    NUMBER;

BEGIN

    OPEN cur_task_etc_cost;
    FETCH cur_task_etc_cost INTO l_last_submitted_etc_cost;
    CLOSE cur_task_etc_cost;

    RETURN l_last_submitted_etc_cost;
END get_last_etc_cost;

--Commented the following API for BUG 4091457, by rtarway
--
/*
 --Bug 3595585 : Added the following procedure
 --Bug 3621404 : Added burden parameters
PROCEDURE get_last_etc_all(p_project_id             IN      NUMBER
                              ,p_object_id      IN      NUMBER
                              ,p_object_type            IN      VARCHAR2
                              ,p_as_of_date     IN  DATE
                              ,p_structure_type     IN  VARCHAR2    := 'WORKPLAN'
                              ,x_etc_txn_raw_cost_last_subm OUT     NUMBER
                              ,x_etc_prj_raw_cost_last_subm OUT     NUMBER
                              ,x_etc_pfc_raw_cost_last_subm OUT     NUMBER
                              ,x_etc_txn_bur_cost_last_subm OUT     NUMBER
                              ,x_etc_prj_bur_cost_last_subm OUT     NUMBER
                              ,x_etc_pfc_bur_cost_last_subm OUT     NUMBER
                              ,x_etc_effort_last_subm   OUT     NUMBER
                              ,x_return_status          OUT     VARCHAR2
                              ,x_msg_count              OUT     NUMBER
                              ,x_msg_data               OUT     VARCHAR2
              ,p_proj_element_id    IN  NUMBER := null )
IS
  CURSOR cur_task_etc_all
  IS
    SELECT (nvl(ppr.oth_etc_rawcost_tc,0)+nvl(ppr.ppl_etc_rawcost_tc,0)+nvl(ppr.eqpmt_etc_rawcost_tc,0)) etc_txn_raw_rawcost_last_subm
    ,(nvl(ppr.oth_etc_rawcost_pc,0)+nvl(ppr.ppl_etc_rawcost_pc,0)+nvl(ppr.eqpmt_etc_rawcost_pc,0)) etc_prj_raw_rawcost_last_subm
    ,(nvl(ppr.oth_etc_rawcost_fc,0)+nvl(ppr.ppl_etc_rawcost_fc,0)+nvl(ppr.eqpmt_etc_rawcost_fc,0)) etc_pfc_raw_rawcost_last_subm
        ,(nvl(ppr.oth_etc_cost_tc,0)+nvl(ppr.ppl_etc_cost_tc,0)+nvl(ppr.eqpmt_etc_cost_tc,0)) etc_txn_bur_cost_last_subm
    ,(nvl(ppr.oth_etc_cost_pc,0)+nvl(ppr.ppl_etc_cost_pc,0)+nvl(ppr.eqpmt_etc_cost_pc,0)) etc_prj_bur_cost_last_subm
    ,(nvl(ppr.oth_etc_cost_fc,0)+nvl(ppr.ppl_etc_cost_fc,0)+nvl(ppr.eqpmt_etc_cost_fc,0)) etc_pfc_bur_cost_last_subm
    , (NVL( ESTIMATED_REMAINING_EFFORT, 0 ) + NVL( EQPMT_ETC_EFFORT, 0 )) etc_effort_last_subm
     FROM pa_progress_rollup ppr
    WHERE  ppr.project_id = p_project_id
     AND   ppr.object_id  = p_object_id
     and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id)
     --Commented by rtarway for BUG 3835474
     --AND   ppr.as_of_date = ( SELECT max(as_of_date)
     --                      from pa_progress_rollup ppr2
     --                     WHERE ppr2.as_of_date < p_as_of_date
     --                      AND  ppr2.project_id = p_project_id
     --                      AND ppr2.object_id  = p_object_id
     --                      AND ppr2.object_type = p_object_type
     --                      AND ppr2.structure_type = p_structure_type
    --and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
     --                  )
     --Added by rtarway for BUG 3835474
     AND   ppr.as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date <= p_as_of_date
                           AND  ppr2.project_id = p_project_id
                           AND ppr2.object_id  = p_object_id
                           AND ppr2.object_type = p_object_type
                           AND ppr2.structure_type = p_structure_type
                           AND ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id)
               AND ppr2.structure_version_id is null -- Bug 3879461
                           AND ppr2.current_flag <> 'W'   -- Bug 3879461
--                            AND NOT EXISTS
--                                (
--                                  SELECT 'X' FROM pa_percent_completes ppc
--                                  WHERE ppc.date_computed = ppr2.as_of_date
--                                  AND   ppc.project_id = p_project_id
--                                  AND   ppc.object_id  = p_object_id
--                                  AND   ppc.object_type = p_object_type
--                                  AND   ppc.structure_type = p_structure_type
--                                  AND   ppc.published_flag = 'N'
--                                )
                           )
     AND ppr.object_type = p_object_type
     AND ppr.structure_type = p_structure_type
     AND ppr.structure_version_id is null -- Bug 3879461
     AND ppr.current_flag <> 'W'   -- Bug 3879461

     ;
BEGIN

    x_return_status := 'S';

    OPEN cur_task_etc_all;
    FETCH cur_task_etc_all INTO x_etc_txn_raw_cost_last_subm, x_etc_prj_raw_cost_last_subm, x_etc_pfc_raw_cost_last_subm, x_etc_txn_bur_cost_last_subm, x_etc_prj_bur_cost_last_subm, x_etc_pfc_bur_cost_last_subm, x_etc_effort_last_subm;
    CLOSE cur_task_etc_all;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    null;
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'get_last_etc_all',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
      raise;
END get_last_etc_all;*/


PROCEDURE get_last_etc_all(    p_project_id             IN      NUMBER
                              ,p_object_id      IN      NUMBER
                              ,p_object_type            IN      VARCHAR2
                              ,p_as_of_date     IN    DATE
                              ,p_structure_type     IN    VARCHAR2   := 'WORKPLAN'
                              ,x_etc_txn_raw_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_prj_raw_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_pfc_raw_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_txn_bur_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_prj_bur_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_pfc_bur_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_effort_last_subm    OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_return_status          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_msg_count              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_msg_data               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  ,p_proj_element_id    IN    NUMBER := null /* Modified for IB4 Progress CR. */
                  ,p_resource_class_code IN VARCHAR2    := 'PEOPLE' -- Bug 3836485
                    )
IS
  CURSOR cur_task_etc_all
  IS
    SELECT
     decode( p_resource_class_code, 'PEOPLE', ppr.ppl_etc_rawcost_tc
                                   ,'EQUIPMENT', ppr.eqpmt_etc_rawcost_tc
                                   ,ppr.oth_etc_rawcost_tc )  etc_txn_raw_rawcost_last_subm
    ,decode(p_resource_class_code, 'PEOPLE', ppr.ppl_etc_rawcost_pc
                                  ,'EQUIPMENT', ppr.eqpmt_etc_rawcost_pc
                                  , ppr.oth_etc_rawcost_pc ) etc_prj_raw_rawcost_last_subm
    ,decode(p_resource_class_code, 'PEOPLE', ppr.ppl_etc_rawcost_fc
                                  ,'EQUIPMENT', ppr.eqpmt_etc_rawcost_fc
                                  ,ppr.oth_etc_rawcost_fc) etc_pfc_raw_rawcost_last_subm
    ,decode(p_resource_class_code, 'PEOPLE', ppr.ppl_etc_cost_tc
                                  ,'EQUIPMENT', ppr.eqpmt_etc_cost_tc
                                  ,ppr.oth_etc_cost_tc ) etc_txn_bur_cost_last_subm
    ,decode(p_resource_class_code, 'PEOPLE', ppr.ppl_etc_cost_pc
                                  ,'EQUIPMENT', ppr.eqpmt_etc_cost_pc
                  ,ppr.oth_etc_cost_pc ) etc_prj_bur_cost_last_subm
    ,decode(p_resource_class_code, 'PEOPLE', ppr.ppl_etc_cost_fc
                                  ,'EQUIPMENT', ppr.eqpmt_etc_cost_fc
                                  ,ppr.oth_etc_cost_fc ) etc_pfc_bur_cost_last_subm
    ,decode(p_resource_class_code, 'PEOPLE', ESTIMATED_REMAINING_EFFORT
                                  ,'EQUIPMENT', EQPMT_ETC_EFFORT
                  , ppr.OTH_ETC_QUANTITY) etc_effort_last_subm
     FROM pa_progress_rollup ppr
    WHERE  ppr.project_id = p_project_id
     AND   ppr.object_id  = p_object_id
     and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
     AND   ppr.as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date <= p_as_of_date--Added eqaulity condition, 4091457, rtarway
                           AND  ppr2.project_id = p_project_id
                           AND ppr2.object_id  = p_object_id
                           AND ppr2.object_type = p_object_type
                           AND ppr2.structure_type = p_structure_type
                           AND ppr2.structure_version_id is null -- Bug 3879461
                           AND ppr2.current_flag <> 'W'   -- Bug 3879461
                           and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) /* Modified for IB4 Progress CR. */
                       )
     AND ppr.object_type = p_object_type
     AND ppr.structure_type = p_structure_type
     AND ppr.structure_version_id is null -- Bug 3879461
     AND ppr.current_flag <> 'W'   -- Bug 3879461
     ;
BEGIN

    x_return_status := 'S';

    OPEN cur_task_etc_all;
    FETCH cur_task_etc_all INTO x_etc_txn_raw_cost_last_subm,
    x_etc_prj_raw_cost_last_subm, x_etc_pfc_raw_cost_last_subm,
    x_etc_txn_bur_cost_last_subm, x_etc_prj_bur_cost_last_subm,
    x_etc_pfc_bur_cost_last_subm, x_etc_effort_last_subm;
    CLOSE cur_task_etc_all;


EXCEPTION
WHEN NO_DATA_FOUND THEN
    null;
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'get_last_etc_all',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));

      -- 4537865
      x_etc_txn_raw_cost_last_subm := NULL ;
      x_etc_prj_raw_cost_last_subm := NULL ;
      x_etc_pfc_raw_cost_last_subm := NULL ;
      x_etc_txn_bur_cost_last_subm := NULL ;
      x_etc_prj_bur_cost_last_subm := NULL ;
      x_etc_pfc_bur_cost_last_subm := NULL ;
      x_etc_effort_last_subm        := NULL ;
      -- 4537865
      raise;
END get_last_etc_all;

-- Progress Management Changes. Bug # 3420093.

function sum_etc_values(
     p_planned_value            NUMBER := null
     ,p_ppl_etc_value           NUMBER := null
     ,p_eqpmt_etc_value         NUMBER := null
     ,p_oth_etc_value           NUMBER := null
     ,p_subprj_ppl_etc_value    NUMBER := null
     ,p_subprj_eqpmt_etc_value  NUMBER := null
     ,p_subprj_oth_etc_value    NUMBER := null
     ,p_oth_etc_quantity        NUMBER := null
     ,p_actual_value            NUMBER := null
     ,p_mode                    VARCHAR2 := 'PUBLISH'
)return number
is
    l_sum_etc_values    NUMBER;
begin
if p_mode = 'PUBLISH'   --commenting out IF-THNE-ELSE clause for bug 3927404 issue #2  --again uncommenting 5726773
  then
    if ((p_ppl_etc_value is null) and (p_eqpmt_etc_value is null)
         and (p_oth_etc_value is null) and (p_subprj_ppl_etc_value is null)
         and (p_subprj_eqpmt_etc_value is null) and (p_subprj_oth_etc_value is null)
         and (p_oth_etc_quantity is null)) then

        ---5726773 l_sum_etc_values := nvl(p_planned_value,0) - nvl(p_actual_value,0);
 	l_sum_etc_values := PA_FP_FCST_GEN_AMT_UTILS.get_etc_from_plan_act(nvl(p_planned_value,0), nvl(p_actual_value,0));

    else

        l_sum_etc_values := (nvl(p_ppl_etc_value,0)+nvl(p_eqpmt_etc_value,0)
                    +nvl(p_oth_etc_value,0)+nvl(p_subprj_ppl_etc_value,0)
                            +nvl(p_subprj_eqpmt_etc_value,0)+nvl(p_subprj_oth_etc_value,0)
                    +nvl(p_oth_etc_quantity,0));

    end if;
  else
      -- Start Changes for bug 6714865
      -- l_sum_etc_values := nvl(p_planned_value,0) - nvl(p_actual_value,0);
      l_sum_etc_values := PA_FP_FCST_GEN_AMT_UTILS.get_etc_from_plan_act(nvl(p_planned_value,0),
nvl(p_actual_value,0));
      -- End Changes for bug 6714865
  end if;

    -- if l_sum_etc_values is negative return 0.
   /*5726773
    if (nvl(l_sum_etc_values,0) < 0) then
        l_sum_etc_values := 0;
    end if;
    */
    return(l_sum_etc_values);

end sum_etc_values;

-- Progress Management Changes. Bug # 3420093.
-- Bug 3879461 : This function is not used.
FUNCTION get_act_rawcost_this_period (p_as_of_date        IN     DATE
                                     ,p_project_id        IN     NUMBER
                                     ,p_object_id         IN     NUMBER
                                     ,p_object_version_id IN     NUMBER
      ,p_proj_element_id      IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER
IS
    l_act_rawcost_period        NUMBER := NULL;
    l_act_rawcost_date      NUMBER := NULL;
    l_act_rawcost_pub       NUMBER := NULL;

/*
cursor c1 is
         select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
            act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
         and structure_type = 'WORKPLAN' -- FPM Dev CR 3
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id)-- Modified for IB4 Progress CR.
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                                     -- and ppr2.object_version_id = p_object_version_id
                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.as_of_date > p_as_of_date
    and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id)); --Modified for IB4 Progress CR. );
    l_c1rec     c1%rowtype;
*/

    cursor c_prev_prog_rec is
         select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
            act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date < p_as_of_date);

    cursor c_this_prog_rec is
         select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
            act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date >= p_as_of_date);


BEGIN
-- Bug 3764224 : This function(_this_peiord) are used only in assignment cases. So it is safe to select from rollup table itself
-- no need to go in percent complete table
-- Bug 3764224 : RLM Changes : Commented the below code. This was not calculating the actual this period
/*
    open c1;
    fetch c1 into l_c1rec;
    if c1%found then
        select (nvl(ppr.oth_act_rawcost_to_date_pc,0)+nvl(ppr.ppl_act_rawcost_to_date_pc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_pc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_pc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_pc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_pc,0))
                into l_act_rawcost_pub
                from pa_progress_rollup ppr,pa_percent_completes ppc
                where ppr.project_id = ppc.project_id
            and ppr.object_id = ppc.object_id
            and ppr.object_version_id = ppc.object_version_id
            and ppr.as_of_date = ppc.date_computed (+)
        and ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
            and ppr.percent_complete_id = ppc.percent_complete_id
         and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
         and ppr.structure_type = ppc.structure_type(+) -- FPM Dev CR 3
        and ppr.proj_element_id = ppc.task_id (+) -- Modified for IB4 Progress CR.
                and ppr.as_of_date = (select max(ppc2.date_computed)
                                     from pa_percent_completes ppc2
                                     where ppc2.project_id = p_project_id
                                     and ppc2.object_id = p_object_id
                                     -- and ppc2.object_version_id = p_object_version_id
                     and ppc2.published_flag = 'Y'
                     and ppc2.current_flag = 'Y'
                         and ppc2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppc2.task_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
                     );

        l_act_rawcost_period := (nvl(l_c1rec.act_rawcost_to_date,0) - nvl(l_act_rawcost_pub,0));

    end if;
    close c1;
*/

    open c_prev_prog_rec;
    fetch c_prev_prog_rec into l_act_rawcost_pub;
    close c_prev_prog_rec;

    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_rawcost_date;
    close c_this_prog_rec;

    l_act_rawcost_period := (nvl(l_act_rawcost_date,0) - nvl(l_act_rawcost_pub,0));

    if (l_act_rawcost_period < 0) then
        l_act_rawcost_period := 0;
    end if;

    return(l_act_rawcost_period);

END get_act_rawcost_this_period;

-- Progress Management Changes. Bug # 3621404.

FUNCTION get_act_txn_rawcost_thisperiod (p_as_of_date        IN     DATE
                                        ,p_project_id        IN     NUMBER
                                        ,p_object_id         IN     NUMBER
                                        ,p_object_version_id IN     NUMBER
    ,p_proj_element_id      IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER
IS
    l_act_rawcost_period        NUMBER := NULL;
    l_act_rawcost_date      NUMBER := NULL;
    l_act_rawcost_pub       NUMBER := NULL;
/*

    cursor c1 is
         select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
         and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                                     -- and ppr2.object_version_id = p_object_version_id
                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.as_of_date > p_as_of_date);
    l_c1rec     c1%rowtype;
*/

--bug 3738651
/*        cursor cur_rawcost_tc_this_period
            is
              select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
                     +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
                     +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr,pa_percent_completes ppc
                where ppr.project_id = ppc.project_id
                and ppr.object_id = ppc.object_id
                and ppr.as_of_date = ppc.date_computed
                and ppr.project_id = p_project_id
            and ppr.object_id = p_object_id
        and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
            and ppr.percent_complete_id = ppc.percent_complete_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
            and ppr.structure_type = ppc.structure_type (+) -- FPM Dev CR 3
        and ppr.proj_element_id = ppc.task_id (+) -- Modified for IB4 Progress CR.
            and ppc.current_flag = 'N'
            and ppc.published_flag = 'N'
            ;
*/

/* added by maansari7/25 */
    cursor c_prev_prog_rec is
         select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
                     +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
                     +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.structure_version_id is null -- Bug 3764224
                and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and current_flag = 'Y'
                ;

/* commented by maansari 7/25
  cursor c_prev_prog_rec is
         select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
                     +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
                     +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date < p_as_of_date);
   */

   /* commented by maansari 7/25
    cursor c_this_prog_rec is
         select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
                     +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
                     +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date >= p_as_of_date);
        */
/* added by maansari7/25 */
            cursor c_this_prog_rec is
         select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
                     +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
                     +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr
             -- Bug 3879461 : percemnt compete join is not required. current_flag = W is sufficient
--                    ,pa_percent_completes ppc
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
                and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
            and ppr.structure_version_id is null -- Bug 3764224
                and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
--               and ppr.object_id = ppc.object_id
--               and ppr.as_of_date = ppc.date_computed
--                and ppr.percent_complete_id = ppc.percent_complete_id
--                and ppr.project_id = ppc.project_id
--                and ppr.proj_element_id=ppc.task_id
--                and ppr.structure_type = ppc.structure_type
--                and ppc.current_flag= 'N'
--                and ppc.published_flag = 'N'
                and ppr.current_flag= 'W'
                ;


BEGIN

-- Bug 3764224 : This function(_this_peiord) are used only in assignment cases. So it is safe to select from rollup table itself
-- no need to go in percent complete table
-- Bug 3764224 : RLM Changes : Commented the below code. This was not calculating the actual this period

/*
    open c1;
    fetch c1 into l_c1rec;
    if c1%found then
        select (nvl(ppr.oth_act_rawcost_to_date_tc,0)+nvl(ppr.ppl_act_rawcost_to_date_tc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_tc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_tc,0))
                into l_act_rawcost_pub
                from pa_progress_rollup ppr,pa_percent_completes ppc
                where ppr.project_id = ppc.project_id
            and ppr.object_id = ppc.object_id
            and ppr.object_version_id = ppc.object_version_id
            and ppr.as_of_date = ppc.date_computed (+)
        and ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.percent_complete_id = ppc.percent_complete_id
         and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
         and ppr.structure_type = ppc.structure_type(+) -- FPM Dev CR 3
                and ppr.as_of_date = (select max(ppc2.date_computed)
                                     from pa_percent_completes ppc2
                                     where ppc2.project_id = p_project_id
                                     and ppc2.object_id = p_object_id
                                      -- and ppc2.object_version_id = p_object_version_id
                     and ppc2.published_flag = 'Y'
                     and ppc2.current_flag = 'Y'
                         and ppc2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     );
        l_act_rawcost_period := (nvl(l_c1rec.act_rawcost_to_date,0) - nvl(l_act_rawcost_pub,0));
    end if;
    close c1;

    if (l_act_rawcost_period < 0) then
        l_act_rawcost_period := 0;
    end if;

    return(l_act_rawcost_period);
*/

/*        OPEN cur_rawcost_tc_this_period;
        FETCH cur_rawcost_tc_this_period INTO l_act_rawcost_period;
        IF cur_rawcost_tc_this_period%FOUND
        THEN
                CLOSE cur_rawcost_tc_this_period;
                RETURN l_act_rawcost_period;
        ELSE
                CLOSE cur_rawcost_tc_this_period;
                RETURN null;
        END IF;
*/

    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_rawcost_date;
    if c_this_prog_rec%notfound
    then
        close c_this_prog_rec;
        return 0;
    end if;
    close c_this_prog_rec;

    open c_prev_prog_rec;
    fetch c_prev_prog_rec into l_act_rawcost_pub;
    close c_prev_prog_rec;

/*  commneted by maansari7/25
    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_rawcost_date;
    close c_this_prog_rec;
*/
    l_act_rawcost_period := (nvl(l_act_rawcost_date,0) - nvl(l_act_rawcost_pub,0));

    if (l_act_rawcost_period < 0) then
        l_act_rawcost_period := 0;
    end if;

    return(l_act_rawcost_period);

END get_act_txn_rawcost_thisperiod;

-- Progress Management Changes. Bug # 3621404.
-- Bug 3879461 : This function is not used now.
FUNCTION get_act_pfn_rawcost_thisperiod (p_as_of_date        IN     DATE
                                        ,p_project_id        IN     NUMBER
                                        ,p_object_id         IN     NUMBER
                                        ,p_object_version_id IN     NUMBER
    ,p_proj_element_id      IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER
IS
    l_act_rawcost_period        NUMBER := NULL;
    l_act_rawcost_date      NUMBER := NULL;
    l_act_rawcost_pub       NUMBER := NULL;

/*
    cursor c1 is
         select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
         and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                                     -- and ppr2.object_version_id = p_object_version_id
                     and structure_type = 'WORKPLAN' -- FPM Dev CR 3
                                     and ppr2.as_of_date > p_as_of_date
    and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR. );
    l_c1rec     c1%rowtype;
*/

    cursor c_prev_prog_rec is
         select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date < p_as_of_date);

    cursor c_this_prog_rec is
         select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0)) act_rawcost_to_date
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
            and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppr.structure_version_id is null -- Bug 3764224
            and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                     from pa_progress_rollup ppr2
                                     where ppr2.project_id = p_project_id
                                     and ppr2.object_id = p_object_id
                     and ppr2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
                     and ppr2.structure_version_id is null -- Bug 3764224
                     and ppr2.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Bug 3764224
                                     and ppr2.as_of_date >= p_as_of_date);


BEGIN

-- Bug 3764224 : This function(_this_peiord) are used only in assignment cases. So it is safe to select from rollup table itself
-- no need to go in percent complete table
-- Bug 3764224 : RLM Changes : Commented the below code. This was not calculating the actual this period

/*
    open c1;
    fetch c1 into l_c1rec;
    if c1%found then
        select (nvl(ppr.oth_act_rawcost_to_date_fc,0)+nvl(ppr.ppl_act_rawcost_to_date_fc,0)
            +nvl(ppr.eqpmt_act_rawcost_to_date_fc,0)+nvl(ppr.spj_oth_act_rawcost_to_date_fc,0)
            +nvl(ppr.subprj_ppl_act_rawcost_fc,0)+nvl(ppr.subprj_eqpmt_act_rawcost_fc,0))
                into l_act_rawcost_pub
                from pa_progress_rollup ppr,pa_percent_completes ppc
                where ppr.project_id = ppc.project_id
            and ppr.object_id = ppc.object_id
            and ppr.object_version_id = ppc.object_version_id
            and ppr.as_of_date = ppc.date_computed (+)
        and ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                -- and ppr.object_version_id = p_object_version_id
    and ppr.proj_element_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
            and ppr.percent_complete_id = ppc.percent_complete_id
         and ppr.structure_type = 'WORKPLAN' -- FPM Dev CR 3
         and ppr.structure_type = ppc.structure_type(+) -- FPM Dev CR 3
        and ppr.proj_element_id = ppc.task_id (+) -- Modified for IB4 Progress CR.
                and ppr.as_of_date = (select max(ppc2.date_computed)
                                     from pa_percent_completes ppc2
                                     where ppc2.project_id = p_project_id
                                     and ppc2.object_id = p_object_id
                                     -- and ppc2.object_version_id = p_object_version_id
                     and ppc2.published_flag = 'Y'
                     and ppc2.current_flag = 'Y'
                         and ppc2.structure_type = 'WORKPLAN' -- FPM Dev CR 3
        and ppc2.task_id = nvl(p_proj_element_id, p_object_id) -- Modified for IB4 Progress CR.
                     );
        l_act_rawcost_period := (nvl(l_c1rec.act_rawcost_to_date,0) - nvl(l_act_rawcost_pub,0));
    end if;
    close c1;
*/

    open c_prev_prog_rec;
    fetch c_prev_prog_rec into l_act_rawcost_pub;
    close c_prev_prog_rec;

    open c_this_prog_rec;
    fetch c_this_prog_rec into l_act_rawcost_date;
    close c_this_prog_rec;

    l_act_rawcost_period := (nvl(l_act_rawcost_date,0) - nvl(l_act_rawcost_pub,0));

    if (l_act_rawcost_period < 0) then
        l_act_rawcost_period := 0;
    end if;

    return(l_act_rawcost_period);
END get_act_pfn_rawcost_thisperiod;

-- Bug 3621404 : Added Get_Res_Rate_Burden_Multiplier
Procedure Get_Res_Rate_Burden_Multiplier(P_res_list_mem_id           IN  NUMBER
                                ,P_project_id                        IN  NUMBER
                ,P_task_id                      IN  NUMBER := null     --bug 3860575
                                ,p_as_of_Date                   IN  DATE   := null     --bug 3901289
                                --maansari6/14 bug 3686920
                                ,p_structure_version_id              IN NUMBER   default null
                                ,p_currency_code                     IN  VARCHAR2 default null
                                --maansari6/14 bug 3686920
                                ,p_init_msg_list                     IN  VARCHAR2        := FND_API.G_FALSE
                        ,p_calling_mode                      IN  VARCHAR2        := 'ACTUAL_RATES' -- Bug 3627315
                --,P_dummy_override_raw_cost         IN  NUMBER Bug 3632946
                        --,P_override_txn_currency_code      IN  VARCHAR2 Bug 3632946
                        ,x_resource_curr_code                OUT NOCOPY VARCHAR2
                                ,x_resource_raw_rate                 OUT NOCOPY NUMBER
                                ,x_resource_burden_rate              OUT NOCOPY NUMBER
                        -- ,X_dummy_burden_cost              OUT NOCOPY NUMBER Bug 3632946
                        ,X_burden_multiplier                 OUT NOCOPY NUMBER
                                ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                                ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       )
AS

   l_msg_count                      NUMBER :=0;
   l_data                           VARCHAR2(2000);
   l_msg_data                       VARCHAR2(2000);
   l_error_msg_code                 VARCHAR2(30);
   l_msg_index_out                  NUMBER;
   l_return_status                  VARCHAR2(2000);
   l_debug_mode                     VARCHAR2(30);
   -- added for Bug: 4537865
   l_new_msg_data           VARCHAR2(2000);
   -- added for Bug: 4537865
   l_resource_class_flag_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_resource_class_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_resource_class_id_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_res_type_code_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_job_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_person_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_person_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_named_role_tbl                  SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
   l_bom_resource_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_non_labor_resource_tbl          SYSTEM.PA_VARCHAR2_20_TBL_TYPE    := SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
   l_inventory_item_id_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_item_category_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_project_role_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_organization_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_fc_res_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_expenditure_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_expenditure_category_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_event_type_tbl                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_revenue_category_code_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_supplier_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_unit_of_measure_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_spread_curve_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_etc_method_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_mfc_cost_type_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_procure_resource_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_incurred_by_res_flag_tbl        SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_Incur_by_res_class_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_Incur_by_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_org_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_rate_based_flag_tbl             SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_rate_expenditure_type_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_rate_func_curr_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_rate_incurred_by_org_id_tbl     SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_resource_assignment_id_tbl      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_assignment_description_tbl      SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
   l_planning_resource_alias_tbl     SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
   l_resource_name_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_project_role_name_tbl           SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_organization_name_tbl           SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
   l_financial_category_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_project_assignment_id_tbl       SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_use_task_schedule_flag_tbl      SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_planning_start_date_tbl         SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
   l_planning_end_date_tbl           SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
   l_total_quantity_tbl              SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_override_currency_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_billable_percent_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_cost_rate_override_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_burdened_rate_override_tbl      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_sp_fixed_date_tbl               SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
   l_financial_category_name_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_supplier_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
   l_ATTRIBUTE_CATEGORY_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_ATTRIBUTE1_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE2_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE3_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE4_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE5_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE6_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE7_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE8_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE9_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE10_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE11_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE12_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE13_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE14_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE15_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE16_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE17_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE18_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE19_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE20_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE21_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE22_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE23_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE24_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE25_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE26_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE27_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE28_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE29_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_ATTRIBUTE30_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
  --End of variables for Variable for Resource Attributes

  l_task_id                          pa_tasks.task_id%TYPE := P_task_id;   --bug 3860575, Satish
  l_top_task_id                      pa_tasks.task_id%TYPE;
  l_bill_job_group_id                pa_projects_all.bill_job_group_id%TYPE;
  l_project_type                     pa_projects_all.project_type%TYPE;
  l_expenditure_type                 pa_resource_assignments.expenditure_type%TYPE;
  l_org_id                           pa_projects_all.org_id%TYPE;
  l_expenditure_OU                   pa_projects_all.org_id%TYPE;
  l_resource_class_code              pa_resource_assignments.resource_class_code%TYPE;
  l_non_labor_resource               pa_resource_assignments.non_labor_resource%TYPE;
  l_nlr_organization_id              pa_resource_assignments.organization_id%TYPE;
  l_rate_override_to_organz_id       pa_resource_assignments.organization_id%TYPE;
  l_rate_incurred_by_organz_id       pa_resource_assignments.organization_id%TYPE;
  l_inventory_item_id                pa_resource_assignments.inventory_item_id%TYPE;
  l_bom_resource_id                  pa_resource_assignments.bom_resource_id%TYPE;
  l_txn_currency_code_override       pa_fp_res_assignments_tmp.txn_currency_code_override%TYPE;
  l_cost_rate_multiplier             CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
--  l_burden_override_multiplier       pa_fp_res_assignments_tmp.b_multiplier_override%TYPE;
  l_burden_override_multiplier       Number;
  l_cost_override_rate               pa_fp_res_assignments_tmp.rw_cost_rate_override%TYPE;
  l_raw_cost                         pa_fp_res_assignments_tmp.txn_raw_cost%TYPE;
  -- added for Bug: 4537865
  l_new_raw_cost             pa_fp_res_assignments_tmp.txn_raw_cost%TYPE;
  -- added for Bug: 4537865
  l_raw_cost_rate                    pa_fp_res_assignments_tmp.raw_cost_rate%TYPE;
  l_burden_cost                      pa_fp_res_assignments_tmp.txn_burdened_cost%TYPE;
  l_mfc_cost_type_id                 pa_resource_assignments.mfc_cost_type_id%TYPE;
  l_mfc_cost_source                  CONSTANT NUMBER := 2;
  l_item_category_id                 pa_resource_assignments.item_category_id%TYPE;
  l_job_id                           pa_resource_assignments.job_id%TYPE;
  l_person_id                        pa_resource_list_members.person_id%TYPE;

 --Out variables
  l_trxn_curr_code                   varchar2(100);
  l_txn_raw_cost                     number;
  l_txn_cost_rate                    number;
  l_txn_burden_cost                  number;
  l_txn_burden_cost_rate             number;
  l_burden_multiplier                number;
  l_cost_ind_compiled_set_id         number;
  l_raw_cost_rejection_code          varchar2(1000);
  l_burden_cost_rejection_code       varchar2(1000);
  l_insufficient_paramters           EXCEPTION; -- Added to raised exception if any required paramter is missing for PA_COST1 api
  l_resource_alias                   pa_task_assignments_v.resource_alias%TYPE; -- Added if any required paramter is missing for PA_COST1 api

  l_null_above                       VARCHAR2(1) := 'N';  -- Added if any required paramter is miss ing for PA_COST1 api

  l_incur_by_res_type                SYSTEM.PA_VARCHAR2_30_TBL_TYPE; -- Bug # 3473324.
  g1_debug_mode                      VARCHAR2(1);
  l_res_list_memb_id_tbl             SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()         ;

  l_plan_cost_burden_sch_id          NUMBER; -- Bug 3632946


  --maansari6/14 bug 3686920
  l_plan_cost_job_rate_sch_id        NUMBER;
  l_plan_cost_emp_rate_sch_id        NUMBER;
  l_plan_cost_nlr_rate_sch_id        NUMBER;
  l_fp_cols_rec                      PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
  l_plan_version_id                  NUMBER;
  l_res_class_sch_id                 NUMBER;
  --maansari6/14

  --amksingh 3686920
  l_calling_mode                     VARCHAR2(15);
  l_use_planning_rates_flag          VARCHAR2(1);
  --amksingh 3686920

--bug 3733606
  l_unit_of_measure                  VARCHAR2(150);
  l_carrying_out_org_id              NUMBER;
  l_cost_res_class_rate_sch_id       NUMBER;
  l_revenue_rejection_code           VARCHAR2(30);

  l_bill_rate                        NUMBER;
  l_raw_revenue                      NUMBER;
  l_bill_markup_percentage           NUMBER;
  l_cost_markup_percentage           NUMBER;
  l_rev_txn_curr_code                VARCHAR2(120);
  -- Bug 3691289 : Added following two variables
  l_pl_res_class_raw_cost_sch_id        NUMBER;
  l_pl_cost_res_class_rate_sc_id       NUMBER;

  --bug# 3801523  Satish  start
  l_rate_based_flag                  VARCHAR2(1);
  l_burd_sch_cp_structure        VARCHAR2(1000);
  l_burd_sch_cost_base           VARCHAR2(1000);
  l_burd_sch_fixed_date          DATE;
  l_burd_sch_id                      NUMBER;
  l_burd_sch_rev_id          NUMBER;
  --bug# 3801523  Satish  end

/*
  --bug 3821299
  CURSOR get_assignment_id( c_structure_version_id NUMBER, c_task_id NUMBER, c_resource_list_member_id NUMBER )
  IS
    SELECT resource_assignment_id
     FROM pa_task_assignments_v
    WHERE structure_version_id = c_structure_version_id
      AND task_id              = c_task_id
      AND resource_list_member_id = c_resource_list_member_id
     ;
*/

  CURSOR get_override_rate ( c_budget_version_id NUMBER, c_resource_assignment_id NUMBER )
  IS
   SELECT NVL(TXN_COST_RATE_OVERRIDE,TXN_STANDARD_COST_RATE) -- Bug 3951555, Added nvl and TXN_STANDARD_COST_RATE
      , nvl(BURDEN_COST_RATE_OVERRIDE, BURDEN_COST_RATE) -- Bug 3951555, Added nvl and BURDEN_COST_RATE
     FROM pa_budget_lines
    WHERE budget_version_id = c_budget_version_id
      AND resource_assignment_id = c_resource_assignment_id
      AND TXN_CURRENCY_CODE = p_currency_code
      AND p_as_of_date BETWEEN start_date and end_date
  ;

  ---- check override rates in pa_resource_assgn_rate (IPM changes)
  CURSOR get_asgn_override_rate ( c_budget_version_id NUMBER, c_resource_assignment_id NUMBER )
  IS                                                                                  SELECT TXN_RAW_COST_RATE_OVERRIDE, TXN_BURDEN_COST_RATE_OVERRIDE
     FROM pa_resource_asgn_curr                                                        WHERE budget_version_id = c_budget_version_id
      AND resource_assignment_id = c_resource_assignment_id                              AND TXN_CURRENCY_CODE = p_currency_code;

  l_resource_assignment_id     NUMBER;
  l_raw_override_rate          NUMBER := null;
  l_burden_override_rate       NUMBER := null;
  l_asgn_raw_override_rate     NUMBER := null;  ---IPM changes
  l_asgn_burden_override_rate  NUMBER := null;  ---IPM changes
  l_etc_flag                   VARCHAR2(1) := 'N';
  --bug 3821299

  -- Bug 3965584 Begin
  CURSOR c_get_assgn_details(c_project_id NUMBER, c_task_id NUMBER, c_structure_version_id NUMBER, c_resource_list_member_id NUMBER)
  IS
  SELECT pra.person_id,
        pra.resource_class_code,
        pra.expenditure_type,
        pra.rate_expenditure_type,
        pra.RATE_EXPENDITURE_ORG_ID,
        pra.non_labor_resource,
        pra.organization_id,
        pra.bom_resource_id,
        pra.inventory_item_id,
        pra.mfc_cost_type_id,
        pra.item_category_id,
        pra.job_id,
        pra.unit_of_measure,
        pra.rate_based_flag,
        pra.resource_assignment_id,
        rlm.alias
  FROM pa_resource_assignments pra,  ----pa_task_assignments_v  4871809
       pa_budget_versions pbv,
       pa_resource_list_members rlm
  WHERE pbv.project_structure_version_id  = c_structure_version_id
  AND pbv.budget_version_id = pra.budget_version_id
  AND pra.task_id           = c_task_id
  AND pra.resource_list_member_id   = c_resource_list_member_id
  AND pra.project_id        = c_project_id
  AND pra.resource_list_member_id = rlm.resource_list_member_id
    ;
  l_assgn_rec   c_get_assgn_details%ROWTYPE;
  -- Bug 3965584 End



Begin

    l_return_status := FND_API.G_RET_STS_SUCCESS ;
    -- FPM Dev CR 8 : Added debug messages
    g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

        IF FND_API.TO_BOOLEAN(NVL(p_init_msg_list,FND_API.G_FALSE)) THEN -- Added for required prarameter validation
             FND_MSG_PUB.initialize;
        END IF;


    -- Bug 3691289 Added condtion to return if no res list mem id
    IF P_res_list_mem_id IS NULL THEN
        -- As per Clint Effort to Cost Conversion should not happen if planned effort is not entered at task(which means
        -- hiden assignment does not exists)
        return;
    END IF;



    -- Bug 3965584 Begin
    -- Get the values from Task assignment.

    OPEN c_get_assgn_details(p_project_id, p_task_id, p_structure_version_id, P_res_list_mem_id);
    FETCH c_get_assgn_details INTO l_assgn_rec;
    CLOSE c_get_assgn_details;

    l_person_id             := l_assgn_rec.person_id;
    l_resource_class_code           := l_assgn_rec.resource_class_code;
    l_expenditure_type          := nvl(l_assgn_rec.expenditure_type, l_assgn_rec.rate_expenditure_type);
    l_expenditure_ou            := l_assgn_rec.RATE_EXPENDITURE_ORG_ID;
    l_org_id                := null;
    l_non_labor_resource            := l_assgn_rec.non_labor_resource;
    l_nlr_organization_id           := l_assgn_rec.organization_id;
    l_rate_incurred_by_organz_id        := l_assgn_rec.organization_id;
    l_bom_resource_id           := l_assgn_rec.bom_resource_id;
    l_inventory_item_id         := l_assgn_rec.inventory_item_id;
    l_txn_currency_code_override        := null;
    l_cost_override_rate            := null;
    l_mfc_cost_type_id          := l_assgn_rec.mfc_cost_type_id;
    l_item_category_id          := l_assgn_rec.item_category_id;
    l_job_id                := l_assgn_rec.job_id;
    l_unit_of_measure           := l_assgn_rec.unit_of_measure;
    l_rate_based_flag           := l_assgn_rec.rate_based_flag;
    l_resource_assignment_id        := l_assgn_rec.resource_assignment_id;
        l_resource_alias                        := l_assgn_rec.alias;

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'Values retrived from pa_task_assignments_v', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_person_id='||l_person_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_resource_class_code='||l_resource_class_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_expenditure_type='||l_expenditure_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_expenditure_ou='||l_expenditure_ou, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_org_id='||l_org_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_non_labor_resource='||l_non_labor_resource, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_nlr_organization_id='||l_nlr_organization_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_rate_incurred_by_organz_id='||l_rate_incurred_by_organz_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_bom_resource_id='||l_bom_resource_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_inventory_item_id='||l_inventory_item_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_txn_currency_code_override='||l_txn_currency_code_override, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_cost_override_rate='||l_cost_override_rate, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_mfc_cost_type_id='||l_mfc_cost_type_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_item_category_id='||l_item_category_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_job_id='||l_job_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_unit_of_measure='||l_unit_of_measure, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_rate_based_flag='||l_rate_based_flag, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_unit_of_measure='||l_unit_of_measure, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_resource_assignment_id='||l_resource_assignment_id, x_Log_Level=> 3);
    END IF;


    -- Bug 3965584 End



    -- If any values are not there at assignment level, then get it using resourse defaults

    l_res_list_memb_id_tbl.extend(1);
    l_res_list_memb_id_tbl(1)       := P_res_list_mem_id;
    l_calling_mode := p_calling_mode;

    BEGIN
            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'Calling get_resource_defaults', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_task_id '||l_task_id, x_Log_Level=> 3);
            END IF;
        PA_PLANNING_RESOURCE_UTILS.get_resource_defaults(
          p_resource_list_members        =>  l_res_list_memb_id_tbl,
          p_project_id                   =>  p_project_id,
          x_resource_class_flag          =>  l_resource_class_flag_tbl,
          x_resource_class_code          =>  l_resource_class_code_tbl,
          x_resource_class_id            =>  l_resource_class_id_tbl,
          x_res_type_code                =>  l_res_type_code_tbl,
          x_person_id                    =>  l_person_id_tbl,
          x_job_id                       =>  l_job_id_tbl,
          x_person_type_code             =>  l_person_type_code_tbl,
          x_named_role                   =>  l_named_role_tbl,
          x_bom_resource_id              =>  l_bom_resource_id_tbl,
          x_non_labor_resource           =>  l_non_labor_resource_tbl,
          x_inventory_item_id            =>  l_inventory_item_id_tbl,
          x_item_category_id             =>  l_item_category_id_tbl,
          x_project_role_id              =>  l_project_role_id_tbl,
          x_organization_id              =>  l_organization_id_tbl,
          x_fc_res_type_code             =>  l_fc_res_type_code_tbl,
          x_expenditure_type             =>  l_expenditure_type_tbl,
          x_expenditure_category         =>  l_expenditure_category_tbl,
          x_event_type                   =>  l_event_type_tbl,
          x_revenue_category_code        =>  l_revenue_category_code_tbl,
          x_supplier_id                  =>  l_supplier_id_tbl,
          x_unit_of_measure              =>  l_unit_of_measure_tbl,
          x_spread_curve_id              =>  l_spread_curve_id_tbl,
          x_etc_method_code              =>  l_etc_method_code_tbl,
          x_mfc_cost_type_id             =>  l_mfc_cost_type_id_tbl,
          x_incurred_by_res_flag         =>  l_incurred_by_res_flag_tbl,
          x_incur_by_res_class_code      =>  l_incur_by_res_class_code_tbl,
          x_Incur_by_role_id             =>  l_Incur_by_role_id_tbl,
          x_org_id                       =>  l_org_id_tbl,
          X_rate_based_flag              =>  l_rate_based_flag_tbl,
          x_rate_expenditure_type        =>  l_rate_expenditure_type_tbl,
          x_rate_func_curr_code          =>  l_rate_func_curr_code_tbl,
          X_incur_by_res_type        =>  l_incur_by_res_type, -- Bug # 3473324 changes.
          x_msg_data                     =>  l_msg_data,
          x_msg_count                    =>  l_msg_count,
          x_return_status                =>  l_return_status);

    EXCEPTION
          WHEN OTHERS THEN
           fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_progress_utils',
                                   p_procedure_name => 'Get_Res_Rate_Burden_Multiplier',
                                   p_error_text     => SUBSTRB('pa_planning_resource_utils.get_resource_defaults:'||SQLERRM,1,120));
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_error_text='||SUBSTRB('pa_planning_resource_utils.get_resource_defaults:'||SQLERRM,1,120), x_Log_Level=> 3);
            raise fnd_api.g_exc_error;
    END;

    -- IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN  --------------------------------{
    FOR i IN l_res_list_memb_id_tbl.FIRST .. l_res_list_memb_id_tbl.LAST LOOP

        -- Bug 3965584 : Values will be taken only if they are not presnt already
        IF l_person_id IS NULL THEN
            IF l_person_id_tbl.EXISTS(i) AND l_person_id_tbl(i) is not null THEN
             l_person_id := l_person_id_tbl(i);
            ELSE
             l_person_id := null;
            END IF;
        END IF;

        IF l_resource_class_code IS NULL THEN
            IF l_resource_class_code_tbl.EXISTS(i) AND l_resource_class_code_tbl(i) is not null THEN
             l_resource_class_code := l_resource_class_code_tbl(i);
            ELSE
             l_resource_class_code := null;
            END IF;
            END IF;

            IF l_expenditure_type IS NULL THEN
        IF l_expenditure_type_tbl.EXISTS(i) and l_expenditure_type_tbl(i) is not null THEN
            l_expenditure_type := l_expenditure_type_tbl(i);
        ELSE
            IF l_rate_expenditure_type_tbl.EXISTS(i) THEN
                l_expenditure_type := l_rate_expenditure_type_tbl(i);
            ELSE
                l_expenditure_type := null;
            END IF;
        END IF;
        END IF;

        --bug# 3819400 Satish start
            /*IF l_rate_incurred_by_org_id_tbl.EXISTS(i) and l_rate_incurred_by_org_id_tbl(i) is not null THEN
                l_expenditure_OU := l_rate_incurred_by_org_id_tbl(i);
            ELSE
                l_expenditure_OU := null;
            END IF;*/

        /* bug 3823945
            IF l_organization_id_tbl.EXISTS(i) and l_organization_id_tbl(i) is not null THEN
                l_expenditure_OU := l_organization_id_tbl(i);
            ELSE
                l_expenditure_OU := null;
            END IF;
        */
        --bug# 3819400 Satish end

        -- bug 3823945
        IF l_expenditure_OU  IS NULL THEN
            IF l_org_id_tbl.EXISTS(i) and l_org_id_tbl(i) is not null THEN
            l_expenditure_OU := l_org_id_tbl(i);
            ELSE
            l_expenditure_OU := null;
            END IF;
        END IF;
        -- bug 3823945

        IF l_org_id  IS NULL THEN
            IF l_org_id_tbl.EXISTS(i) and l_org_id_tbl(i) is not null THEN
            l_org_id := l_org_id_tbl(i);
            ELSE
            l_org_id := null;
            END IF;
        END IF;

        IF l_non_labor_resource  IS NULL THEN
            IF l_non_labor_resource_tbl.EXISTS(i) and l_non_labor_resource_tbl(i) is not null THEN
            l_non_labor_resource := l_non_labor_resource_tbl(i);
            ELSE
            l_non_labor_resource := null;
            END IF;
        END IF;

        IF l_nlr_organization_id  IS NULL THEN
            IF l_organization_id_tbl.EXISTS(i) and l_organization_id_tbl(i) is not null THEN
             l_nlr_organization_id := l_organization_id_tbl(i);
            ELSE
             l_nlr_organization_id := null;
            END IF;
            END IF;

        IF l_rate_incurred_by_organz_id  IS NULL THEN
            IF l_rate_incurred_by_org_id_tbl.EXISTS(i) and l_rate_incurred_by_org_id_tbl(i) is not null THEN
             --l_rate_incurred_by_organz_id := l_rate_incurred_by_org_id_tbl(i);
             l_rate_incurred_by_organz_id := l_organization_id_tbl(i);  --bug 3901289
            ELSE
             l_rate_incurred_by_organz_id := null;
            END IF;
            END IF;

        IF l_bom_resource_id  IS NULL THEN
            IF l_bom_resource_id_tbl.EXISTS(i) and l_bom_resource_id_tbl(i) is not null THEN
              l_bom_resource_id := l_bom_resource_id_tbl(i);
            ELSE
              l_bom_resource_id := null;
            END IF;
            END IF;

        IF l_inventory_item_id  IS NULL THEN
            IF l_inventory_item_id_tbl.EXISTS(i) and l_inventory_item_id_tbl(i) is not null THEN
            l_inventory_item_id := l_inventory_item_id_tbl(i);
            ELSE
            l_inventory_item_id := null;
            END IF;
            END IF;

        -- Bug 3965584 : Not required
            --IF l_override_currency_code_tbl.EXISTS(i) and l_override_currency_code_tbl(i) is not null THEN
            --    l_txn_currency_code_override := l_override_currency_code_tbl(i);
            --ELSE
            --    l_txn_currency_code_override := null;
            --END IF;

        -- Bug 3965584 : Not required
            --IF l_cost_rate_override_tbl.EXISTS(i) and l_cost_rate_override_tbl(i) is not null THEN
            --    l_cost_override_rate := l_cost_rate_override_tbl(i);
            --ELSE
            --    l_cost_override_rate := null;
            --END IF;

        IF l_mfc_cost_type_id  IS NULL THEN
            IF l_mfc_cost_type_id_tbl.EXISTS(i) and l_mfc_cost_type_id_tbl(i) is not null THEN
            l_mfc_cost_type_id := l_mfc_cost_type_id_tbl(i);
            ELSE
            l_mfc_cost_type_id := null;
            END IF;
            END IF;

        IF l_item_category_id  IS NULL THEN
            IF l_item_category_id_tbl.EXISTS(i) and l_item_category_id_tbl(i) is not null THEN
            l_item_category_id := l_item_category_id_tbl(i);
            ELSE
            l_item_category_id := null;
            END IF;
            END IF;

        IF l_job_id  IS NULL THEN
            IF l_job_id_tbl.EXISTS(i) and l_job_id_tbl(i) is not null THEN
            l_job_id := l_job_id_tbl(i);
            ELSE
            l_job_id := null;
            END IF;
            END IF;

        IF l_rate_based_flag  IS NULL THEN
            IF l_rate_based_flag_tbl.EXISTS(i) and l_rate_based_flag_tbl(i) is not null THEN
            l_rate_based_flag := l_rate_based_flag_tbl(i);
            ELSE
            l_rate_based_flag := null;
            END IF;
            END IF;
        --bug 3733606

        IF l_unit_of_measure  IS NULL THEN
            IF l_unit_of_measure_tbl.EXISTS(i) and l_unit_of_measure_tbl(i) is not null THEN
            l_unit_of_measure := l_unit_of_measure_tbl(i);
            ELSE
            l_unit_of_measure := null;
            END IF;
            END IF;
    END LOOP; -- Bug 3965584 : Reduced the scope of FOR LOOP

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'Values retrived from get_res_defaults', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_person_id='||l_person_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_resource_class_code='||l_resource_class_code, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_expenditure_type='||l_expenditure_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_expenditure_ou='||l_expenditure_ou, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_org_id='||l_org_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_non_labor_resource='||l_non_labor_resource, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_nlr_organization_id='||l_nlr_organization_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_rate_incurred_by_organz_id='||l_rate_incurred_by_organz_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_bom_resource_id='||l_bom_resource_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_inventory_item_id='||l_inventory_item_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_txn_currency_code_override='||l_txn_currency_code_override, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_cost_override_rate='||l_cost_override_rate, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_mfc_cost_type_id='||l_mfc_cost_type_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_item_category_id='||l_item_category_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_job_id='||l_job_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_unit_of_measure='||l_unit_of_measure, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_rate_based_flag='||l_rate_based_flag, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_unit_of_measure='||l_unit_of_measure, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_resource_assignment_id='||l_resource_assignment_id, x_Log_Level=> 3);
    END IF;

    --bug 3821299
    IF p_calling_mode = 'PLAN_RATES' THEN
        l_etc_flag := 'Y';
    END IF;
    --bug 3821299



        /* Select the project Type */
        SELECT project_type, carrying_out_organization_id
        INTO   l_project_type, l_carrying_out_org_id
        FROM   pa_projects_all
        WHERE  project_id = p_project_id;


    /* Select the resource name  TO BE CHECKED
    BEGIN
        SELECT resource_alias
        INTO   l_resource_alias
        FROM   pa_task_assignments_v
        WHERE  resource_list_member_id = l_BOM_resource_id
        AND project_id = p_project_id; -- Modifications for Bug # 3688902.
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            NULL;
    END;
        */
    --bug 3860575 start
    /*-- FPM Dev CR 5 Begin
     BEGIN
         SELECT task_id
         INTO   l_task_id
         FROM   pa_task_assignments_v
         WHERE  resource_list_member_id = l_res_list_memb_id_tbl(i)
         AND project_id = p_project_id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            NULL;
    END;
    -- FPM Dev CR 5 End*/

    --bug 3860575 end

    -- FPM Dev CR 5
    IF upper(l_resource_class_code) = 'PEOPLE' AND l_rate_override_to_organz_id IS NULL AND l_person_id is NOT NULL THEN
        --l_rate_override_to_organz_id := l_nlr_organization_id;
        l_rate_override_to_organz_id := null;  --bug 3901289
    END IF;

    /* Calling the  Api to get the Burden/Raw Rate */
    --bug# 3801523  moved this begin below.
    --Begin

    --maansari6/14   bug 3686920
    -- amksingh
    -- 3686920 : using l_use_planning_rates_flag to call the API GET_PLAN_VERSION_DTLS
    -- also when l_use_planning_rates_flag is N then we should be using ACTUAL RATES so passing ACTUAL_RATES
    -- to costing API
    -- We should not be calling Get_Default_Sch_Ids as it will not retun actual values
    -- If at all we need this, then we should get this value from pa_tasks and then from pa_projects
    --bug 3733606 moved from below

    BEGIN
        l_plan_version_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id(
                    p_project_id => p_project_id,
                    p_plan_type_id => -1,
                        p_proj_str_ver_id => p_structure_version_id);

        -- Selecting res_class_raw_cost_sch_id here as it is not available in FP rec type
        SELECT use_planning_rates_flag,res_class_raw_cost_sch_id INTO l_use_planning_rates_flag, l_pl_res_class_raw_cost_sch_id
        FROM pa_proj_fp_options
        WHERE fin_plan_version_id = l_plan_version_id
        AND project_id = p_project_id;

    EXCEPTION
        WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_progress_utils',
                               p_procedure_name => 'Get_Res_Rate_Burden_Multiplier',
                               p_error_text     => SUBSTRB('Pa_Fp_wp_gen_amt_utils.get_wp_version_id:'||SQLERRM,1,120));
            pa_debug.write(x_Module=>'Pa_Fp_wp_gen_amt_utils.get_wp_version_id', x_Msg => 'p_error_text='||SUBSTRB('PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS:'||SQLERRM,1,120), x_Log_Level=> 3);
            raise fnd_api.g_exc_error;
    END;

    -- Bug 3691289 , rates from pa_proj_fp_options shd be selected always as we need them further even in actual rate mode
    --   IF p_calling_mode = 'PLAN_RATES'
    --   THEN
    -- Bug 4233420 : Moved the logic of getting rates from budget_lines up in the code here.
    IF l_etc_flag = 'Y' THEN
        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_etc_flag is Y' , x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_plan_version_id='||l_plan_version_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_resource_assignment_id='||l_resource_assignment_id, x_Log_Level=> 3);
        END IF;

        OPEN get_override_rate(l_plan_version_id, l_resource_assignment_id);
        FETCH get_override_rate INTO l_raw_override_rate, l_burden_override_rate;
        CLOSE get_override_rate;

        --- IPM changes
        OPEN get_asgn_override_rate(l_plan_version_id, l_resource_assignment_id);
        FETCH get_asgn_override_rate INTO l_asgn_raw_override_rate, l_asgn_burden_override_rate;
        CLOSE get_asgn_override_rate;

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_raw_override_rate='||l_raw_override_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_burden_override_rate='||l_burden_override_rate, x_Log_Level=> 3);
        END IF;

        --- IPM changes
        IF l_raw_override_rate IS NOT NULL THEN
              x_resource_raw_rate := l_raw_override_rate;
        ELSIF l_asgn_raw_override_rate IS NOT NULL THEN
              x_resource_raw_rate := l_asgn_raw_override_rate;
        END IF;

        IF l_burden_override_rate IS NOT NULL THEN
               x_resource_burden_rate := l_burden_override_rate;
               x_burden_multiplier := (l_burden_override_rate - 1); -- only for non rate based assignments.
        ELSIF l_asgn_burden_override_rate IS NOT NULL THEN
               x_resource_burden_rate := l_asgn_burden_override_rate;
               x_burden_multiplier := (l_asgn_burden_override_rate -1);---only for non rate based assignments.
        END IF;

        x_resource_curr_code := p_currency_code;

        -- NOTE: The reason that we are setting: x_burden_multiplier := (l_burden_multiplier - 1) and passing this
        -- value to the calling API, when a non-rate based resource has an override burden rate is because of the
        -- following:
        -- The calling API uses the formula: etc burden cost = etc raw cost * (x_burden_multiplier + 1) to calculate
        -- the value of etc burden cost.
        -- For a non-rate based resource without any override burden rate the burden multiplier is derived from the
        -- burden schedule and the above formula holds good.
        -- However, when a non-rate based resource has an override burden rate we should calculate the the value of
        -- etc burden cost as: etc burden cost = etc raw cost * override burden rate. Hence, we pass back:
        -- x_burden_multiplier = (override burden rate - 1) through our above code to the calling API so that the
        -- formula: etc raw cost * (x_burden_multiplier + 1) in the calling API equates to:
        -- etc raw cost * override burden rate.
    END IF;  -- l_etc_flag = 'Y'

    IF l_rate_based_flag = 'Y' THEN
        IF x_resource_raw_rate IS NOT NULL AND x_resource_burden_rate IS NOT NULL THEN
            return;
        END IF;
    ELSE
        IF x_burden_multiplier IS NOT NULL THEN
            return;
        END IF;
    END IF;


    BEGIN
        --     IF l_use_planning_rates_flag = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS(
              P_PROJECT_ID                     => p_project_id,
              P_BUDGET_VERSION_ID              => l_plan_version_id,
              X_FP_COLS_REC                    => l_fp_cols_rec,
              X_RETURN_STATUS                  => l_return_status,
              X_MSG_COUNT                      => l_msg_count,
              X_MSG_DATA                       => l_msg_data);


        l_plan_cost_burden_sch_id       := l_fp_cols_rec.X_BURDEN_RATE_SCH_ID;
        l_plan_cost_job_rate_sch_id     := l_fp_cols_rec.X_COST_JOB_RATE_SCH_ID;
        l_plan_cost_emp_rate_sch_id     := l_fp_cols_rec.X_COST_EMP_RATE_SCH_ID;
        l_plan_cost_nlr_rate_sch_id     := l_fp_cols_rec.X_CNON_LABOR_RES_RATE_SCH_ID;
        --    l_pl_res_class_raw_cost_sch_id  := l_fp_cols_rec.x_fp_res_cl_raw_cost_sch_id;
        l_pl_cost_res_class_rate_sc_id := l_fp_cols_rec.X_cost_res_class_rate_sch_id;

        IF l_use_planning_rates_flag = 'Y' THEN
            l_cost_res_class_rate_sch_id := l_pl_cost_res_class_rate_sc_id;
        ELSE
            l_cost_res_class_rate_sch_id := l_pl_res_class_raw_cost_sch_id;
        END IF;

    EXCEPTION when others then
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_progress_utils',
                               p_procedure_name => 'Get_Res_Rate_Burden_Multiplier',
                               p_error_text     => SUBSTRB('PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS:'||SQLERRM,1,120));
        pa_debug.write(x_Module=>'PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS', x_Msg => 'p_error_text='||SUBSTRB('PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS:'||SQLERRM,1,120), x_Log_Level=> 3);
        raise fnd_api.g_exc_error;
    END;

    IF  l_return_status <> 'S' AND l_msg_data IS NOT NULL   THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_msg_data);
            x_msg_data := l_msg_data;
            x_return_status := 'E';
            x_msg_count := fnd_msg_pub.count_msg;
            RAISE  FND_API.G_EXC_ERROR;
    END IF;


    --   END IF;   --<< p_calling_modfe = 'PLAN_RATES'


    IF NVL(l_use_planning_rates_flag,'N') = 'N' THEN
        l_calling_mode := 'ACTUAL_RATES';
    ELSE
        l_calling_mode := p_calling_mode;
    END IF;

    -- Bug 3691289 : Added below condition so that planning rates are not passed to the API if mode is actual rates
    IF l_calling_mode = 'ACTUAL_RATES' THEN
          l_plan_cost_burden_sch_id      := null;
          l_plan_cost_job_rate_sch_id    := null;
          l_plan_cost_emp_rate_sch_id    := null;
          l_plan_cost_nlr_rate_sch_id    := null;
    END IF;

    --bug# 3801523 If cost based assignments then call Get_burden_sch_details  Satish start

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_rate_based_flag :'||l_rate_based_flag, x_Log_Level=> 3);
    END IF;

    IF l_rate_based_flag = 'Y' THEN
    --maansari6/14
            IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'Calling Get_Plan_Actual_Cost_Rates', x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_calling_mode='||l_calling_mode, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_project_type='||l_project_type, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_task_id='||to_number(null), x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_top_task_id='||l_top_task_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_Exp_item_date='||sysdate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);   --
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_expenditure_type='||l_expenditure_type, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_expenditure_OU='||l_expenditure_OU, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_project_OU='||l_org_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_Quantity='||1, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_resource_class='||l_resource_class_code, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_person_id='||l_person_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_non_labor_resource='||l_non_labor_resource, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_NLR_organization_id='||l_nlr_organization_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_override_organization_id='||l_rate_override_to_organz_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_incurred_by_organization_id='||l_rate_incurred_by_organz_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_inventory_item_id='||l_inventory_item_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_BOM_resource_id='||l_BOM_resource_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_override_trxn_curr_code='||l_txn_currency_code_override, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_override_burden_cost_rate='||l_burden_override_multiplier, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_override_trxn_cost_rate='||l_cost_override_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_override_trxn_raw_cost='||l_raw_cost, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_override_trxn_burden_cost='||l_burden_cost, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_mfc_cost_type_id='||l_mfc_cost_type_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_mfc_cost_source='||l_mfc_cost_source, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_item_category_id='||l_item_category_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_plan_cost_burden_sch_id='||l_plan_cost_burden_sch_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_plan_cost_job_rate_sch_id='||l_plan_cost_job_rate_sch_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_plan_cost_emp_rate_sch_id='||l_plan_cost_emp_rate_sch_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_plan_cost_nlr_rate_sch_id='||l_plan_cost_nlr_rate_sch_id, x_Log_Level=> 3);
            END IF;

        BEGIN

             PA_COST1.Get_Plan_Actual_Cost_Rates
            (p_calling_mode                 =>l_calling_mode --'ACTUAL_RATES' Bug 3627315
            ,p_project_type                 =>l_project_type
            ,p_project_id                   =>p_project_id
            --,p_task_id                      => null ---- TILL THE ISSUE IS FIXED l_task_id
            ,p_task_id                      => l_task_id --bug 3860575
            ,p_top_task_id                  =>l_top_task_id
            ,p_Exp_item_date                => p_as_of_date   --bug 3901289
            ,p_expenditure_type             =>l_expenditure_type
            ,p_expenditure_OU               =>l_expenditure_OU
            ,p_project_OU                   =>l_org_id
            ,p_Quantity                     =>1
            ,p_resource_class               =>l_resource_class_code    /* resource_class_code for Resource Class */
            ,p_person_id                    =>l_person_id
            ,p_non_labor_resource           =>l_non_labor_resource
            ,p_NLR_organization_id          =>l_nlr_organization_id
            ,p_override_organization_id     =>l_rate_override_to_organz_id
            ,p_incurred_by_organization_id  =>l_rate_incurred_by_organz_id
            ,p_inventory_item_id            =>l_inventory_item_id
            ,p_BOM_resource_id              =>l_BOM_resource_id
            ,p_override_trxn_curr_code      =>l_txn_currency_code_override -- P_override_txn_currency_code Bug 3632946
            ,p_override_burden_cost_rate    =>l_burden_override_multiplier
            ,p_override_trxn_cost_rate      =>l_cost_override_rate
            ,p_override_trxn_raw_cost       =>l_raw_cost --P_dummy_override_raw_cost Bug 3632946
            ,p_override_trxn_burden_cost    =>l_burden_cost
            ,p_mfc_cost_type_id             =>l_mfc_cost_type_id
            ,p_mfc_cost_source              =>l_mfc_cost_source
            ,p_item_category_id             =>l_item_category_id
            ,p_job_id                       =>l_job_id
            --bug 3686920
            --maansari6/14      ,p_plan_cost_burden_sch_id      => l_plan_cost_burden_sch_id -- Bug 3632946 : Added this parameter
            --maansari6/14
            ,p_plan_cost_burden_sch_id      => l_plan_cost_burden_sch_id
            ,p_plan_cost_job_rate_sch_id    => l_plan_cost_job_rate_sch_id
            ,p_plan_cost_emp_rate_sch_id    => l_plan_cost_emp_rate_sch_id
            ,p_plan_cost_nlr_rate_sch_id    => l_plan_cost_nlr_rate_sch_id
            --maansari6/14   bug 3686920
            ,x_trxn_curr_code               =>l_trxn_curr_code
            ,x_trxn_raw_cost                =>l_txn_raw_cost
            ,x_trxn_raw_cost_rate           =>l_txn_cost_rate
            ,x_trxn_burden_cost             =>l_txn_burden_cost
            ,x_trxn_burden_cost_rate        =>l_txn_burden_cost_rate
            ,x_burden_multiplier            =>l_burden_multiplier
            ,x_cost_ind_compiled_set_id     =>l_cost_ind_compiled_set_id
            ,x_raw_cost_rejection_code      =>l_raw_cost_rejection_code
            ,x_burden_cost_rejection_code   =>l_burden_cost_rejection_code
            ,x_return_status                =>l_return_status
            ,x_error_msg_code               =>l_msg_data );

                IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'After call PA_COST1.Get_Plan_Actual_Cost_Rates', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_return_status='||l_return_status, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_msg_data='||l_msg_data, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_trxn_curr_code='||l_trxn_curr_code, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_txn_raw_cost='||l_txn_raw_cost, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_txn_cost_rate='||l_txn_cost_rate, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_txn_burden_cost='||l_txn_burden_cost, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_txn_burden_cost_rate='||l_txn_burden_cost_rate, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_burden_multiplier='||l_burden_multiplier, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_cost_ind_compiled_set_id='||l_cost_ind_compiled_set_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_raw_cost_rejection_code='||l_raw_cost_rejection_code, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_burden_cost_rejection_code='||l_burden_cost_rejection_code, x_Log_Level=> 3);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN

             -- FPM Dev CR 5 : If the above API does not retun then populate it with 0
                x_resource_raw_rate := 0;
            x_resource_burden_rate := 0;
            x_resource_curr_code :=  l_trxn_curr_code;
            --  X_dummy_burden_cost := 0;
                X_burden_multiplier := 0;
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_error_text='||SUBSTRB('PA_COST1.Get_Plan_Actual_Cost_Rates:'||SQLERRM,1,120), x_Log_Level=> 3);
        END;

        --bug 3733606
        IF l_return_status <> 'S' THEN
            -- Bug 3691289 : l_cost_res_class_rate_sch_id is derived above
            -- IF l_resource_class_code <> 'PEOPLE'
            -- THEN
            --    l_cost_res_class_rate_sch_id := l_plan_cost_nlr_rate_sch_id;
            -- ELSE
            --    IF l_plan_cost_emp_rate_sch_id IS NOT NULL
            --    THEN
            --        l_cost_res_class_rate_sch_id := l_plan_cost_emp_rate_sch_id;
            --    ELSE
            --        l_cost_res_class_rate_sch_id := l_plan_cost_job_rate_sch_id;
            --    END IF;
            -- END IF;

            BEGIN
                    IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'Calling PA_PLAN_REVENUE.Get_plan_res_class_rates', x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_project_type='||l_project_type, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_resource_class='||l_resource_class_code, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_use_planning_rates_flag='||l_use_planning_rates_flag, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_rate_based_flag='||'Y', x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_uom='||l_unit_of_measure, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_project_organz_id='||l_carrying_out_org_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_cost_res_class_rate_sch_id='||l_cost_res_class_rate_sch_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_plan_burden_cost_sch_id='||l_plan_cost_burden_sch_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_project_org_id='||l_org_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_incurred_by_organz_id='||l_rate_incurred_by_organz_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_override_to_organz_id='||l_rate_override_to_organz_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_expenditure_org_id='||l_expenditure_OU, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_nlr_organization_id='||l_nlr_organization_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_txn_currency_code='||p_currency_code, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_expenditure_type='||l_expenditure_type, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_raw_cost='||l_raw_cost, x_Log_Level=> 3);
                END IF;

                PA_PLAN_REVENUE.Get_plan_res_class_rates  (
                       p_project_type                   => l_project_type
                      ,p_project_id                     => p_project_id
                      --,p_task_id                        => null
                      ,p_task_id                      => l_task_id --bug 3860575
                      ,p_resource_class                 => l_resource_class_code
                      ,p_use_planning_rates_flag        => l_use_planning_rates_flag
                      ,p_rate_based_flag                => 'Y'
                      ,p_uom                            => l_unit_of_measure
                      ,p_project_organz_id              => l_carrying_out_org_id
                      ,p_cost_res_class_rate_sch_id     => l_cost_res_class_rate_sch_id
                      ,p_plan_burden_cost_sch_id        => l_plan_cost_burden_sch_id
                      ,p_quantity                       => 1
                      ,p_item_date                      => p_as_of_date  --SYSDATE
              --bug 3954250
                      ,p_schedule_type                  => 'COST'
                      ,p_project_org_id                 => l_org_id
                      ,p_incurred_by_organz_id          => l_rate_incurred_by_organz_id
                      ,p_override_to_organz_id          => l_rate_override_to_organz_id
                      ,p_expenditure_org_id             => l_expenditure_OU
                      ,p_nlr_organization_id            => l_nlr_organization_id
                      ,p_txn_currency_code              => p_currency_code
                      ,p_expenditure_type               => l_expenditure_type
                      ,p_raw_cost                       => l_raw_cost
                      ,p_system_linkage                 => null
                      ,p_person_id                      => l_person_id -- Bug 3861970, 3879461
                      ,p_job_id                         => l_job_id -- Bug 3861970, 3879461
                      ,x_bill_rate                      => l_bill_rate
                      ,x_cost_rate                      => l_txn_cost_rate
                      ,x_burden_cost_rate               => l_txn_burden_cost_rate
                      ,x_burden_multiplier              => l_burden_multiplier
                   -- ,x_raw_cost                       => l_raw_cost   * commented for Bug: 4537865
                      ,x_raw_cost           => l_new_raw_cost  --added for Bug 4537865
                      ,x_burden_cost                    => l_burden_cost
                      ,x_raw_revenue                    => l_raw_revenue
                      ,x_bill_markup_percentage         => l_bill_markup_percentage
                      ,x_cost_markup_percentage         => l_cost_markup_percentage
                      ,x_cost_txn_curr_code             => l_trxn_curr_code
                      ,x_rev_txn_curr_code              => l_rev_txn_curr_code
                      ,x_raw_cost_rejection_code        => l_raw_cost_rejection_code
                      ,x_burden_cost_rejection_code     => l_burden_cost_rejection_code
                      ,x_revenue_rejection_code         => l_revenue_rejection_code
                      ,x_cost_ind_compiled_set_id       => l_cost_ind_compiled_set_id
                      ,x_return_status                  => l_return_status
                      ,x_msg_count                      => l_msg_count
                      ,x_msg_data                       => l_msg_data
                     );
                --added for Bug 4537865
                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    l_raw_cost := l_new_raw_cost;
                    END IF;
                 --added for Bug 4537865
                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'After Call PA_PLAN_REVENUE.Get_plan_res_class_rates', x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_return_status='||l_return_status, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_msg_count='||l_msg_count, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_msg_data='||l_msg_data, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_bill_rate='||l_bill_rate, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_txn_cost_rate='||l_txn_cost_rate, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_txn_burden_cost_rate='||l_txn_burden_cost_rate, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_burden_multiplier='||l_burden_multiplier, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_raw_cost='||l_raw_cost, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_burden_cost='||l_burden_cost, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_raw_revenue='||l_raw_revenue, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_bill_markup_percentage='||l_bill_markup_percentage, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_cost_markup_percentage='||l_cost_markup_percentage, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_trxn_curr_code='||l_trxn_curr_code, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_rev_txn_curr_code='||l_rev_txn_curr_code, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_raw_cost_rejection_code='||l_raw_cost_rejection_code, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_burden_cost_rejection_code='||l_burden_cost_rejection_code, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_revenue_rejection_code='||l_revenue_rejection_code, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_cost_ind_compiled_set_id='||l_cost_ind_compiled_set_id, x_Log_Level=> 3);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_progress_utils',
                                   p_procedure_name => 'Get_Res_Rate_Burden_Multiplier',
                                   p_error_text     => SUBSTRB('PA_PLAN_REVENUE.Get_plan_res_class_rates:'||SQLERRM,1,120));
                    pa_debug.write(x_Module=>'PA_PLAN_REVENUE.Get_plan_res_class_rates', x_Msg => 'p_error_text='||SUBSTRB('PA_PLAN_REVENUE.Get_plan_res_class_rates:'||SQLERRM,1,120), x_Log_Level=> 3);
                raise fnd_api.g_exc_error;
            END;
        END IF;   --< l_return_status <> 'S'>
        --bug 3733606

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'After Call Get_Plan_Actual_Cost_Rates', x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_return_status='||l_return_status, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'fnd_msg_count='||fnd_msg_pub.count_msg, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_trxn_curr_code='||l_trxn_curr_code, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_trxn_raw_cost='||l_txn_raw_cost, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_trxn_raw_cost_rate='||l_txn_cost_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_trxn_burden_cost='||l_txn_burden_cost, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_trxn_burden_cost_rate='||l_txn_burden_cost_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_burden_multiplier='||l_burden_multiplier, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_cost_ind_compiled_set_id='||l_cost_ind_compiled_set_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_raw_cost_rejection_code='||l_raw_cost_rejection_code, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'x_burden_cost_rejection_code='||l_burden_cost_rejection_code, x_Log_Level=> 3);
        END IF;

        x_resource_raw_rate := nvl(l_txn_cost_rate,0);
        x_resource_burden_rate := nvl(l_txn_burden_cost_rate,0);
        x_resource_curr_code :=  l_trxn_curr_code;
        --X_dummy_burden_cost := nvl(l_txn_burden_cost,0); Bug 3632946
        X_burden_multiplier := nvl(l_burden_multiplier,0);

        -- FPM Dev CR 8 : Added error stack population
        -- It is subjected to change if values are coming from lookups.
        IF  l_raw_cost_rejection_code IS NOT NULL AND l_raw_override_rate IS NULL     --bug 3821299 do not throw error if there is override.
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                         p_msg_name       => l_raw_cost_rejection_code);
            x_msg_data := l_raw_cost_rejection_code;
            x_return_status := 'E';
            x_msg_count := fnd_msg_pub.count_msg;
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF  l_burden_cost_rejection_code IS NOT NULL AND l_burden_override_rate IS NULL --bug 3821299 do not throw error if there is override.
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                         p_msg_name       => l_burden_cost_rejection_code);
            x_msg_data := l_burden_cost_rejection_code;
            x_return_status := 'E';
            x_msg_count := fnd_msg_pub.count_msg;
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    ELSE -- l_rate_based_flag = 'N' bug# 3801523
        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'Before Calling Get_burden_sch_details ', x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_project_type '||l_project_type, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_expenditure_OU '||l_expenditure_OU, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_expenditure_type '||l_expenditure_type, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_currency_code '||p_currency_code, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_plan_cost_burden_sch_id '||l_plan_cost_burden_sch_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_rate_override_to_organz_id '||l_rate_override_to_organz_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_rate_incurred_by_organz_id '||l_rate_incurred_by_organz_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_nlr_organization_id '||l_nlr_organization_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'p_currency_code '||p_currency_code, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_calling_mode '||l_calling_mode, x_Log_Level=> 3);
        END IF;

        pa_cost1.Get_burden_sch_details
                (
         p_calling_mode                 =>l_calling_mode
                ,p_exp_item_id                  => NULL
                ,p_trxn_type                    => NULL
                ,p_project_type                 => l_project_type
                ,p_project_id                   => p_project_id
                --,p_task_id                      => null
                ,p_task_id                      => l_task_id --bug 3860575
        -- Bug  3837292 ,p_exp_organization_id          => l_expenditure_OU Bug 3837292
                ,p_exp_organization_id          => NVL(l_rate_override_to_organz_id,NVl(l_rate_incurred_by_organz_id,l_nlr_organization_id))
        ,p_expenditure_type             => l_expenditure_type
                ,p_schedule_type                => 'COST'
                ,p_exp_item_date                => p_as_of_date   --bug 3901289
                ,p_trxn_curr_code               => p_currency_code
                ,p_burden_schedule_id           => l_plan_cost_burden_sch_id
                ,x_schedule_id                  => l_burd_sch_id
                ,x_sch_revision_id              => l_burd_sch_rev_id
                ,x_sch_fixed_date               => l_burd_sch_fixed_date
                ,x_cost_base                    => l_burd_sch_cost_base
                ,x_cost_plus_structure          => l_burd_sch_cp_structure
                ,x_compiled_set_id              => l_cost_ind_compiled_set_id
                ,x_burden_multiplier            => l_burden_multiplier
                ,x_return_status                => l_return_status
                ,x_error_msg_code               => l_msg_data
        );

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'After Calling Get_burden_sch_details l_return_status '||l_return_status, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier', x_Msg => 'l_burden_multiplier '||l_burden_multiplier, x_Log_Level=> 3);
        END IF;
        X_burden_multiplier := nvl(l_burden_multiplier,0);

-- Begin fix for Bug # 4065674.
-- For non-rate based resources also we need to use the override burden rate to convert the etc raw cost to
-- etc burden cost. Hence we replace the default burden multiplier obtained from the burden schedule
-- with the override burden rate.


-- End fix for Bug # 4065674.


    END IF; -- l_rate_based_flag = 'Y'
    --bug# 3801523 Satish end.

    --maansari6/5
    IF  l_return_status <> 'S' AND l_msg_data IS NOT NULL
    THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_msg_data);
                x_msg_data := l_msg_data;
                x_return_status := 'E';
                x_msg_count := fnd_msg_pub.count_msg;
                RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --maansari6/5
    --  END LOOP; Bug 3965584 : Reduced the scope of FOR LOOP
    -- END IF;   ---------------------------------------------------------------------------}
        x_return_status := l_return_status;
        x_msg_count     := fnd_msg_pub.count_msg; -- FPM Dev CR 8

EXCEPTION
     -- FPM Dev CR 5
     WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_count := FND_MSG_PUB.Count_Msg;
                 If x_msg_count = 1 THEN
                                pa_interface_utils_pub.get_messages
                                        (p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => x_msg_count,
                                        p_msg_data       => x_msg_data,
                                  --    p_data           => x_msg_data,     * commented for Bug: 4537865
                    p_data       => l_new_msg_data,     --added for Bug: 4537865
                                        p_msg_index_out  => l_msg_index_out );
                 --added for Bug: 4537865
                    x_msg_data := l_new_msg_data;
                 --added for Bug: 4537865
                 End If;

        -- 4537865
         x_resource_curr_code       := NULL ;
         x_resource_raw_rate        := NULL ;
         x_resource_burden_rate     := NULL ;
         X_burden_multiplier        := NULL ;

     WHEN l_insufficient_paramters THEN
                 PA_UTILS.add_message('PA','PA_PROG_INSUFFICIENT_PARA',
                 'RES_NAME', l_resource_alias);
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_data      := 'PA_PROG_INSUFFICIENT_PARA';
                 x_msg_count := FND_MSG_PUB.Count_Msg;
                 If x_msg_count = 1 THEN
                                pa_interface_utils_pub.get_messages
                                        (p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => x_msg_count,
                                        p_msg_data       => x_msg_data,
                                  --    p_data           => x_msg_data,     * commented for Bug: 4537865
                    p_data       => l_new_msg_data,      -- added for Bug: 4537865
                                        p_msg_index_out  => l_msg_index_out );
                  --added for Bug: 4537865
                    x_msg_data := l_new_msg_data;
                  --added for Bug: 4537865
                 End If;

                -- 4537865
                 x_resource_curr_code       := NULL ;
                 x_resource_raw_rate        := NULL ;
                 x_resource_burden_rate     := NULL ;
                 X_burden_multiplier        := NULL ;

         WHEN OTHERS THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 x_msg_count     := 1;
                 x_msg_data      := SUBSTR(SQLERRM,1,120);
                 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROGRESS_UTILS',
                         p_procedure_name   => 'Get_Res_Rate_Burden_Multiplier');
                 If x_msg_count = 1 THEN
                                pa_interface_utils_pub.get_messages
                                        (p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => x_msg_count,
                                        p_msg_data       => x_msg_data,
                                     -- p_data           => x_msg_data,     * commented for Bug: 4537865
                    p_data           => l_new_msg_data,      -- added for Bug: 4537865
                                        p_msg_index_out  => l_msg_index_out );
                   --added for Bug: 4537865
                                        x_msg_data := l_new_msg_data;
                    --added for Bug: 4537865
                 End If;

                -- 4537865
                 x_resource_curr_code       := NULL ;
                 x_resource_raw_rate        := NULL ;
                 x_resource_burden_rate     := NULL ;
                 X_burden_multiplier        := NULL ;

                 RAISE;

end Get_Res_Rate_Burden_Multiplier;
-- Progress Management Changes. Bug # 3621404.

function derive_etc_values(
     p_planned_value            NUMBER := null
     ,p_ppl_act_value           NUMBER := null
     ,p_eqpmt_act_value         NUMBER := null
     ,p_oth_act_value           NUMBER := null
     ,p_subprj_ppl_act_value    NUMBER := null
     ,p_subprj_eqpmt_act_value  NUMBER := null
     ,p_subprj_oth_act_value    NUMBER := null
     ,p_oth_quantity_to_date    NUMBER := null
)return number
is
    l_derived_etc_value NUMBER;
begin

    l_derived_etc_value :=  nvl(p_planned_value,0) - (nvl(p_ppl_act_value,0)+nvl(p_eqpmt_act_value,0)
                    +nvl(p_oth_act_value,0)+nvl(p_subprj_ppl_act_value,0)
                            +nvl(p_subprj_eqpmt_act_value,0)+nvl(p_subprj_oth_act_value,0)
                    +nvl(p_oth_quantity_to_date,0));

    if (l_derived_etc_value < 0) then
        l_derived_etc_value := 0;
    end if;

    return(l_derived_etc_value);

end derive_etc_values;

function published_dlv_prog_exists
(
 p_project_id        PA_PROJECTS_ALL.PROJECT_ID%TYPE,
 p_dlv_proj_elt_id   PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
)return VARCHAR2
IS
    l_result VARCHAR2(1) ;

    CURSOR published_rec_exists
    IS
                SELECT 'Y'
                FROM PA_PERCENT_COMPLETES
        WHERE object_id = p_dlv_proj_elt_id
                  AND object_type = 'PA_DELIVERABLES'
                  AND project_id  = p_project_id
                  AND structure_type = 'WORKPLAN'
                  AND published_flag = 'Y';

BEGIN

     OPEN published_rec_exists ;
     FETCH published_rec_exists INTO l_result ;

     IF published_rec_exists%NOTFOUND THEN
         l_result := 'N' ;
     END IF;

     CLOSE published_rec_exists ;

     return l_result ;

END published_dlv_prog_exists ;


--Added for performance improvements in the view pa_prog_act_by_period_v
--can be used anywhere else too.
procedure set_global_str_ver_id(p_structure_version_id NUMBER)
IS
BEGIN
     PA_PROGRESS_UTILS.g_structure_version_id := p_structure_version_id;
END set_global_str_ver_id;

function get_global_str_ver_id RETURN NUMBER IS
BEGIN
   return PA_PROGRESS_UTILS.g_structure_version_id;
END get_global_str_ver_id;

procedure set_global_time_phase_period(p_period_name VARCHAR2)
IS
BEGIN
   PA_PROGRESS_UTILS.g_time_phase_period_name := p_period_name;
END set_global_time_phase_period;

function get_global_time_phase_period RETURN VARCHAR2 IS
BEGIN
  return PA_PROGRESS_UTILS.g_time_phase_period_name;
END get_global_time_phase_period;



-- Added following function for bug 3709439
FUNCTION Percent_Spent_Value
(
  p_actual_value       NUMBER
 ,p_planned_value      NUMBER
) RETURN NUMBER

IS
    l_percent_spent_value NUMBER := 0;

BEGIN

     -- 5726773
 	     -- IF NVL(p_actual_value,0) <= 0 THEN
 	     --   l_percent_spent_value := 0;
 	     IF (NVL(p_actual_value,0) <= 0 and p_planned_value >= 0) or (NVL(p_actual_value,0) >= 0 and p_planned_value < 0) THEN  --5726773
       l_percent_spent_value := 0;
    ELSIF NVL(p_planned_value,0) = 0 THEN
        l_percent_spent_value := 100;
    ELSE
       l_percent_spent_value := ( (p_actual_value/p_planned_value) *100 );
    END IF;

    --bug 3824042
    --RETURN TRUNC(l_percent_spent_value,2) ;
    RETURN ROUND(l_percent_spent_value,2) ;

END Percent_Spent_Value ;


-- Added following function for bug 3709439
FUNCTION Percent_Complete_Value
(
  p_actual_value       NUMBER
 ,p_etc_value          NUMBER
) RETURN NUMBER

IS
    l_percent_complete_value NUMBER := 0;
    l_act_etc                NUMBER := NVL(p_actual_value,0) + NVL(p_etc_value,0) ;

BEGIN

     ---5726773
      IF (NVL(p_actual_value,0) <= 0 and l_act_etc > 0) or (NVL(p_actual_value,0) >= 0 and l_act_etc < 0) THEN  --5726773
       l_percent_complete_value := 0;
--    ELSIF NVL(p_etc_value,0) = 0 THEN
--        l_percent_complete_value := 100;
    ELSE
       IF (l_act_etc = 0 ) THEN
          l_act_etc := 1;
       END IF;
       l_percent_complete_value := (  ( p_actual_value/l_act_etc ) * 100  );
       if (l_percent_complete_value > 100) then
 	            l_percent_complete_value := 100;
 	elsif (l_percent_complete_value < 0) then
 	            l_percent_complete_value := 0;
 	end if;
    END IF;

    --bug 3824042
    --RETURN TRUNC(l_percent_complete_value,2) ;
    RETURN ROUND(l_percent_complete_value,8) ; --Bug 6854114

END Percent_Complete_Value ;

-- Bug 3784324 : Added procedure convert_effort_to_cost
PROCEDURE convert_effort_to_cost
(   p_resource_list_mem_id        IN  NUMBER
    ,p_project_id                 IN  NUMBER
    ,p_structure_version_id       IN  NUMBER
    ,p_txn_currency_code              IN  VARCHAR
    ,p_planned_effort             IN  NUMBER
    ,p_planned_rawcost_tc         IN  NUMBER
    ,p_act_effort_this_period     IN  NUMBER
    ,p_act_effort                 IN  NUMBER
    ,p_etc_effort                 IN  NUMBER
    ,p_rate_based_flag            IN  VARCHAR := 'Y'
    ,p_act_rawcost_tc             IN  NUMBER
    ,x_act_rawcost_tc_this_period IN OUT NOCOPY NUMBER    --File.Sql.39 bug 4440895
    ,x_etc_rawcost_tc             IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_comp_effort          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_spent_effort         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_eac_effort                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_comp_rawcost_tc      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_spent_rawcost_tc     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_eac_rawcost_tc             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status          OUT    NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
    ,x_msg_count          OUT    NOCOPY NUMBER         --File.Sql.39 bug 4440895
    ,x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

    l_act_rawcost_tc          NUMBER     := null;
    l_etc_rawcost_tc          NUMBER     := null;
    l_prcnt_comp_effort          NUMBER     := null;
    l_prcnt_spent_effort      NUMBER     := null;
    l_eac_effort              NUMBER     := null;
    l_prcnt_comp_rawcost_tc      NUMBER     := null;
    l_prcnt_spent_rawcost_tc  NUMBER     := null;
    l_eac_rawcost_tc          NUMBER     := null;

    --added Satish
    X_ACT_RAWCOST_TC         NUMBER;
    l_actual_effort_to_date   NUMBER    := null;
    l_actual_rawcost_to_date   NUMBER    := null;
    l_act_rawcost_tc_this_period NUMBER  := null;

    l_plan_res_cur_code           VARCHAR2(30)     := null;
    l_plan_res_raw_rate           NUMBER           := null;
    l_plan_res_burden_rate       NUMBER           := null;
    l_plan_burden_multiplier   NUMBER           := null;
    l_return_status               VARCHAR2(1)      := null;
    l_msg_count                   NUMBER           := null;
    l_msg_data                   VARCHAR2(250)    := null;
    g1_debug_mode            VARCHAR2(1)                                    ;




BEGIN

     g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
     IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_resource_list_mem_id='||p_resource_list_mem_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_txn_currency_code='||p_txn_currency_code, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_planned_effort='||p_planned_effort, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_planned_rawcost_tc='||p_planned_rawcost_tc, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_act_effort_this_period='||p_act_effort_this_period, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_act_effort='||p_act_effort, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_etc_effort='||p_etc_effort, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_rate_based_flag='||p_rate_based_flag, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'p_act_rawcost_tc='||p_act_rawcost_tc, x_Log_Level=> 3);
     END IF;

    x_return_status := fnd_api.g_ret_sts_success ; -- 4537865

    If (p_rate_based_flag = 'N') then
        -- If (p_rate_based_flag  = 'N') the Rawcost values are inputs.
        l_etc_rawcost_tc := nvl(x_etc_rawcost_tc,0);
        l_act_rawcost_tc := nvl(p_act_rawcost_tc,0);
    l_act_rawcost_tc_this_period := nvl(x_act_rawcost_tc_this_period, 0);

        -- Calculate the EAC Rawcost, Percent Complete Rawcost and Percent Spent Rawcost
        -- using the input Rawcost values.
    l_actual_rawcost_to_date := nvl(l_act_rawcost_tc,0)  + nvl(l_act_rawcost_tc_this_period,0);
        l_eac_rawcost_tc := (nvl(l_actual_rawcost_to_date,0) + nvl(l_etc_rawcost_tc,0));
        l_prcnt_comp_rawcost_tc := PA_PROGRESS_UTILS.Percent_Complete_Value(l_actual_rawcost_to_date,l_etc_rawcost_tc);
        l_prcnt_spent_rawcost_tc := PA_PROGRESS_UTILS.Percent_Spent_Value(l_actual_rawcost_to_date,p_planned_rawcost_tc);
    else
        -- ETC effort to ETC Rawcost Conversion.
        l_plan_res_cur_code         := null;
        l_plan_res_raw_rate            := null;
        l_plan_res_burden_rate        := null;
        l_plan_burden_multiplier    := null;
        l_return_status                := null;
        l_msg_count                    := null;
        l_msg_data                    := null;

        PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier(
            P_res_list_mem_id             => p_resource_list_mem_id
           ,P_project_id                  => p_project_id
           ,p_structure_version_id        => p_structure_version_id
           ,p_currency_code               => p_txn_currency_code
           ,p_calling_mode                => 'PLAN_RATES'
           ,x_resource_curr_code          => l_plan_res_cur_code
           ,x_resource_raw_rate           => l_plan_res_raw_rate
           ,x_resource_burden_rate        => l_plan_res_burden_rate
           ,X_burden_multiplier           => l_plan_burden_multiplier
           ,x_return_status               => l_return_status
           ,x_msg_count                   => l_msg_count
           ,x_msg_data                    => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

        l_etc_rawcost_tc := (nvl(p_etc_effort,0) * nvl(l_plan_res_raw_rate,0));

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => '1. l_plan_res_raw_rate='||l_plan_res_raw_rate, x_Log_Level=> 3);
    END IF;


        -- ACT Effort to ACT Rawcost Conversion.

        l_plan_res_cur_code         := null;
        l_plan_res_raw_rate            := null;
        l_plan_res_burden_rate        := null;
        l_plan_burden_multiplier    := null;
        l_return_status                := null;
        l_msg_count                    := null;
        l_msg_data                    := null;

        PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier(
            P_res_list_mem_id             => p_resource_list_mem_id
           ,P_project_id                  => p_project_id
           ,p_structure_version_id        => p_structure_version_id
           ,p_currency_code               => p_txn_currency_code
           ,p_calling_mode                => 'ACTUAL_RATES'
           ,x_resource_curr_code          => l_plan_res_cur_code
           ,x_resource_raw_rate           => l_plan_res_raw_rate
           ,x_resource_burden_rate        => l_plan_res_burden_rate
           ,X_burden_multiplier           => l_plan_burden_multiplier
           ,x_return_status               => l_return_status
           ,x_msg_count                   => l_msg_count
           ,x_msg_data                    => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => '2. l_plan_res_raw_rate='||l_plan_res_raw_rate, x_Log_Level=> 3);
    END IF;

    IF (p_act_rawcost_tc is NULL)
    THEN
        l_act_rawcost_tc := (nvl(p_act_effort,0) * nvl(l_plan_res_raw_rate,0));
    ELSE
    l_act_rawcost_tc := p_act_rawcost_tc;
    END IF;


        l_act_rawcost_tc_this_period := (nvl(p_act_effort_this_period,0) * nvl(l_plan_res_raw_rate,0));   --added new

        -- EAC Effort and EAC Rawcost calculations.

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'l_act_rawcost_tc_this_period='||l_act_rawcost_tc_this_period, x_Log_Level=> 3);
    END IF;
    -- Calculate cumulative values
    l_actual_effort_to_date := nvl(p_act_effort,0) + nvl(p_act_effort_this_period,0);
    l_actual_rawcost_to_date := nvl(l_act_rawcost_tc,0)  + nvl(l_act_rawcost_tc_this_period,0);

        l_eac_effort := (nvl(p_etc_effort,0) + l_actual_effort_to_date);
        l_eac_rawcost_tc := ( nvl(l_etc_rawcost_tc,0) +l_actual_rawcost_to_date );

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'l_eac_effort='||l_eac_effort, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'l_eac_rawcost_tc='||l_eac_rawcost_tc, x_Log_Level=> 3);
    END IF;

        -- Percent Complete Effort and Percent Complete Rawcost calculations.

        l_prcnt_comp_effort := PA_PROGRESS_UTILS.Percent_Complete_Value(l_actual_effort_to_date,p_etc_effort);
        l_prcnt_comp_rawcost_tc := PA_PROGRESS_UTILS.Percent_Complete_Value(l_actual_rawcost_to_date,l_etc_rawcost_tc);

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'l_prcnt_comp_effort='||l_prcnt_comp_effort, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'l_prcnt_comp_rawcost_tc='||l_prcnt_comp_rawcost_tc, x_Log_Level=> 3);
    END IF;

        -- Percent Spent Effort and Percent Spent Rawcost calculations.

        l_prcnt_spent_effort := PA_PROGRESS_UTILS.Percent_Spent_Value(l_actual_effort_to_date,p_planned_effort);
        l_prcnt_spent_rawcost_tc := PA_PROGRESS_UTILS.Percent_Spent_Value(l_actual_rawcost_to_date,p_planned_rawcost_tc);

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'l_prcnt_spent_effort='||l_prcnt_spent_effort, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost', x_Msg => 'l_prcnt_spent_rawcost_tc='||l_prcnt_spent_rawcost_tc, x_Log_Level=> 3);
    END IF;

    end if;  -- If (p_rate_based_flag = 'N')

    x_act_rawcost_tc_this_period :=  nvl(l_act_rawcost_tc_this_period, 0);
    x_etc_rawcost_tc           :=    nvl(l_etc_rawcost_tc,0);
    x_prcnt_comp_effort        :=    nvl(l_prcnt_comp_effort,0);
    x_prcnt_spent_effort       :=    nvl(l_prcnt_spent_effort,0);
    x_eac_effort               :=    nvl(l_eac_effort,0);
    x_prcnt_comp_rawcost_tc    :=    nvl(l_prcnt_comp_rawcost_tc,0);
    x_prcnt_spent_rawcost_tc   :=    nvl(l_prcnt_spent_rawcost_tc,0);
    x_eac_rawcost_tc           :=    nvl(l_eac_rawcost_tc,0);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := Fnd_Msg_Pub.count_msg;

            -- 4537865
            x_act_rawcost_tc_this_period := 0 ;
        x_etc_rawcost_tc             := 0 ;
        x_prcnt_comp_effort          := 0 ;
        x_prcnt_spent_effort         := 0 ;
        x_eac_effort                 := 0 ;
        x_prcnt_comp_rawcost_tc      := 0 ;
        x_prcnt_spent_rawcost_tc     := 0 ;
        x_eac_rawcost_tc             := 0 ;

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SUBSTRB(SQLERRM,1,240);

            -- 4537865
            x_act_rawcost_tc_this_period := 0 ;
            x_etc_rawcost_tc             := 0 ;
            x_prcnt_comp_effort          := 0 ;
            x_prcnt_spent_effort         := 0 ;
            x_eac_effort                 := 0 ;
            x_prcnt_comp_rawcost_tc      := 0 ;
            x_prcnt_spent_rawcost_tc     := 0 ;
            x_eac_rawcost_tc             := 0 ;
    RAISE;

END convert_effort_to_cost;
--Added by rtarway for BUG 3815202
FUNCTION get_last_published_perc_comp(
  p_project_id       NUMBER
 ,p_object_id        NUMBER
 ,p_as_of_date       Date
 ,p_object_type      VARCHAR2
) RETURN NUMBER
IS
l_last_submitted_perc_comp NUMBER ;
Cursor c_get_last_submitted_perc_comp
is
     select ppr.completed_percentage
     from pa_progress_rollup ppr
     where ppr.project_id = p_project_id
     and ppr.object_id = p_object_id
     and ppr.structure_type = 'WORKPLAN'
     and ppr.structure_version_id is null
     and ppr.object_type = p_object_type
     and ppr.current_flag <> 'W' -- Bug 3879461
     and ppr.as_of_date =
     (
          select max(ppr2.as_of_date)
          from pa_progress_rollup ppr2
          where ppr2.project_id = p_project_id
          and ppr2.object_id = p_object_id
          and ppr2.structure_type = 'WORKPLAN'
          and ppr2.structure_version_id is null
          and ppr.object_type = p_object_type
          and ppr2.as_of_date <= p_as_of_date
          and ppr2.current_flag = 'Y'
     );

Begin
l_last_submitted_perc_comp := null;
OPEN c_get_last_submitted_perc_comp;
FETCH c_get_last_submitted_perc_comp into l_last_submitted_perc_comp;
CLOSE c_get_last_submitted_perc_comp;

return l_last_submitted_perc_comp;
END get_last_published_perc_comp;
--Added by rtarway for BUG 3815202

/* Bug # 3861344: Created API: return_start_end_date(). */

Function return_start_end_date(
p_scheduled_date    DATE        := NULL
,p_baselined_date   DATE        := NULL
,p_project_id       NUMBER
,p_proj_element_id  NUMBER
,p_object_type          VARCHAR2        := 'PA_TASKS'
,p_start_end_flag   VARCHAR2    := 'S'
) return date

is

cursor cur_lp_sch_start_date(p_str_ver_id NUMBER) is
select scheduled_start_date
from pa_proj_elem_ver_schedule ppevs
where ppevs.project_id = p_project_id
and  ppevs.proj_element_id = p_proj_element_id
and ppevs.element_version_id = (select ppev.element_version_id
                from pa_proj_element_versions ppev
                where ppev.project_id = p_project_id
                and ppev.proj_element_id = p_proj_element_id
                and ppev.object_type = p_object_type
                and ppev.parent_structure_version_id = p_str_ver_id);

cursor cur_lp_sch_end_date(p_str_ver_id NUMBER) is
select scheduled_finish_date
from pa_proj_elem_ver_schedule ppevs
where ppevs.project_id = p_project_id
and  ppevs.proj_element_id = p_proj_element_id
and ppevs.element_version_id = (select ppev.element_version_id
                                from pa_proj_element_versions ppev
                                where ppev.project_id = p_project_id
                                and ppev.proj_element_id = p_proj_element_id
                                and ppev.object_type = p_object_type
                                and ppev.parent_structure_version_id = p_str_ver_id);

l_lp_str_ver_id NUMBER  := NULL;

l_return_date DATE  := NULL;

begin

    -- If baselined date exists return the baselined date.

    if l_return_date is NULL then

        l_return_date := p_baselined_date;

    end if;

    -- If baselined date does not exist return the scheduled date from the latest published version.

    if l_return_date is NULL then

        -- Get latest published structure version id.

        l_lp_str_ver_id := PA_PROJ_ELEMENTS_UTILS.latest_published_ver_id(p_project_id,'WORKPLAN');

        if p_start_end_flag = 'S' then

            open cur_lp_sch_start_date(l_lp_str_ver_id);
            fetch cur_lp_sch_start_date into l_return_date;
            close cur_lp_sch_start_date;

        else

            open cur_lp_sch_end_date(l_lp_str_ver_id);
                    fetch cur_lp_sch_end_date into l_return_date;
                    close cur_lp_sch_end_date;

        end if;

    end if;

    -- If baselined date does and scheduled date from the latest published version do not exist
    -- return the scheduled date for the current element version.

    if l_return_date is NULL then

        l_return_date := p_scheduled_date;

    end if;

    return(l_return_date);

end;


-- Procedure to be called when applying latest progress to / publishing the working workplan version
PROCEDURE check_txn_currency_diff
(
    p_structure_version_id IN  NUMBER,
    p_context              IN  VARCHAR2 DEFAULT 'PUBLISH_STRUCTURE',
    x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

-- This cursor returns the information for the assignments with mismatched currencies.
-- Bug 5059828. Changed substr to substrb

CURSOR c_get_diff_cur_asgmts(p_struct_ver_id IN NUMBER) IS
    SELECT
    ra.resource_assignment_id,
    substrb(pe.element_number,1,30), -- Bug 4348814 : Added substr
    substrb(pe.name,1,30), -- Bug 4348814 : Added substr
    substrb(rlm.alias,1,40), -- Bug 4348814 : Added substr
    bl.txn_currency_code,
    pr.txn_currency_code
    FROM
    pa_proj_element_versions pev,
    pa_proj_elements pe,
    pa_resource_assignments ra,
    pa_resource_list_members rlm,
    pa_budget_lines bl,
    pa_progress_rollup pr
    WHERE
    pev.parent_structure_version_id = p_struct_ver_id AND
    pe.proj_element_id = pev.proj_element_id AND
    ra.wbs_element_version_id = pev.element_version_id AND
    rlm.resource_list_member_id = ra.resource_list_member_id AND
    bl.resource_assignment_id = ra.resource_assignment_id AND
    pr.project_id = ra.project_id AND
    pr.object_id = ra.resource_list_member_id AND
    pr.object_type = 'PA_ASSIGNMENTS' AND
    pr.structure_type = 'WORKPLAN' AND
    pr.proj_element_id = ra.task_id AND
    pr.current_flag = 'Y' AND
    pr.structure_version_id IS NULL AND
    bl.txn_currency_code <> pr.txn_currency_code
    GROUP BY
    ra.resource_assignment_id,
    pe.element_number,
    pe.name,
    rlm.alias,
    bl.txn_currency_code,
    pr.txn_currency_code;

-- Bug 4348814 : Task number is 100 chars, name is 240 chars, currency is 15 chars in DB.
-- whereas beloe plsql size is wrong.

l_resource_assignment_id_tbl SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_task_number_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_task_name_tbl              SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_alias_tbl                  SYSTEM.PA_VARCHAR2_80_TBL_TYPE := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();

-- Bug 4348814 : Changed the currency table to 15 from 20
l_currency_tbl               SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_actual_currency_tbl            SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();

l_error_msg VARCHAR2(2000);
l_error_count NUMBER;
l_debug_mode varchar2(1);
BEGIN
    -- Bug 4348814 : Added Debug Msgs
    x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF l_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CHECK_TXN_CURRENCY_DIFF', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=>     3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CHECK_TXN_CURRENCY_DIFF', x_Msg => 'p_context='||p_context, x_Log_Level=>     3);
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CHECK_TXN_CURRENCY_DIFF', x_Msg => 'Open Cursor c_get_diff_cur_asgmts', x_Log_Level=>     3);
        END IF;


    OPEN c_get_diff_cur_asgmts(p_structure_version_id);
    FETCH c_get_diff_cur_asgmts BULK COLLECT INTO l_resource_assignment_id_tbl, l_task_number_tbl,
    l_task_name_tbl, l_alias_tbl, l_currency_tbl, l_actual_currency_tbl;
    CLOSE c_get_diff_cur_asgmts;

    l_error_count := l_resource_assignment_id_tbl.COUNT;

        IF l_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.CHECK_TXN_CURRENCY_DIFF', x_Msg => 'l_error_count='||l_error_count, x_Log_Level=>     3);
        END IF;


    IF l_error_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FOR i in 1..l_error_count LOOP
            IF i = 1 THEN
                l_error_msg := l_task_number_tbl(i) || ', ' || l_alias_tbl(i) || ', ' || l_actual_currency_tbl(i);
            ELSE
                IF length (l_error_msg) >= 1700 THEN -- Bug 4348814 : Added so numeric and value error does not come
                    exit;
                END IF;
                l_error_msg := l_error_msg || '; ' || l_task_number_tbl(i) || ', ' || l_alias_tbl(i) || ', ' || l_actual_currency_tbl(i);
            END IF;
        END LOOP;

        --Bug 5059828. Doing this to avoid numeric/value error. Pls refer to code above
        --that has a similar check.
        l_error_msg := substrb(l_error_msg,1,1700);

        IF p_context = 'PUBLISH_STRUCTURE' THEN
            PA_UTILS.ADD_MESSAGE
            (
                p_app_short_name => 'PA',
                p_msg_name       => 'PA_PUB_MISM_CUR_ERR',
                p_token1         => 'PL_RES_LIST',
                p_value1         =>  l_error_msg
            );
        ELSIF p_context = 'APPLY_PROGRESS' THEN
            PA_UTILS.ADD_MESSAGE
            (
                p_app_short_name => 'PA',
                p_msg_name       => 'PA_APPLY_PROG_MISM_CUR_ERR',
                p_token1         => 'PL_RES_LIST',
                p_value1         =>  l_error_msg
            );
        END IF;
    END IF;

    EXCEPTION WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ; -- 4537865
        RAISE;

END check_txn_currency_diff;





-- Procedure to be called when updating task assignments for progress related business rules check.
PROCEDURE check_prog_for_update_asgmts
(
    p_task_assignment_tbl IN  PA_TASK_ASSIGNMENT_UTILS.l_resource_rec_tbl_type,
    x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

CURSOR get_all_parameters IS
    SELECT
    ra.resource_assignment_id,
    ra.resource_list_member_id,
    rat.resource_list_member_id,
    pr.txn_currency_code,
    rat.override_currency_code,
    ra.project_role_id,
    rat.project_role_id,
    ra.total_plan_quantity,
    rat.total_quantity,
    decode(ra.resource_class_code, 'PEOPLE', pr.ppl_act_effort_to_date,
                                   'EQUIPMENT', pr.eqpmt_act_effort_to_date ,pr.oth_quantity_to_date),
    pr.actual_finish_date,
    ra.schedule_start_date,
    ra.schedule_end_date,
    rat.schedule_start_date,
    rat.schedule_end_date,
    decode(pr.structure_version_id, NULL, 'Y', 'N')
    FROM
    pa_res_asgmts_temp rat,
    pa_resource_assignments ra,
    pa_proj_element_versions pev,
    pa_progress_rollup pr
    WHERE
    ra.resource_assignment_id = rat.resource_assignment_id AND
    pev.element_version_id = ra.wbs_element_version_id AND
    pr.project_id = ra.project_id AND
    pr.object_id = ra.resource_list_member_id AND
    pr.object_type = 'PA_ASSIGNMENTS' AND
    pr.structure_type = 'WORKPLAN' AND
    pr.proj_element_id = ra.task_id AND
    pr.current_flag = 'Y' AND
    (pr.structure_version_id IS NULL OR pr.structure_version_id = pev.parent_structure_version_id);

l_res_asgmt_id_tbl          SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
l_old_rlm_id_tbl            SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
l_new_rlm_id_tbl            SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
l_actual_cur_tbl            SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_override_cur_tbl          SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_old_project_role_id_tbl   SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
l_new_project_role_id_tbl   SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
l_old_total_qty_tbl         SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
l_new_total_qty_tbl         SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
l_actual_qty_tbl            SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
l_actual_finish_date_tbl    SYSTEM.PA_DATE_TBL_TYPE         := SYSTEM.PA_DATE_TBL_TYPE();
l_old_sched_start_date_tbl  SYSTEM.PA_DATE_TBL_TYPE         := SYSTEM.PA_DATE_TBL_TYPE();
l_old_sched_finish_date_tbl SYSTEM.PA_DATE_TBL_TYPE         := SYSTEM.PA_DATE_TBL_TYPE();
l_new_sched_start_date_tbl  SYSTEM.PA_DATE_TBL_TYPE         := SYSTEM.PA_DATE_TBL_TYPE();
l_new_sched_finish_date_tbl SYSTEM.PA_DATE_TBL_TYPE         := SYSTEM.PA_DATE_TBL_TYPE();
l_lat_pub_prog_flag_tbl     SYSTEM.PA_VARCHAR2_1_TBL_TYPE   := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

l_num_of_asgmts NUMBER;
l_viol_indicator NUMBER;
l_num_of_rows NUMBER;
l_db_block_size NUMBER;
l_num_blocks NUMBER;

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_num_of_asgmts := p_task_assignment_tbl.COUNT;

    SELECT to_number(value)
    INTO   l_db_block_size
    FROM   v$parameter
    WHERE  name = 'db_block_size';

    l_num_blocks := 1.25 * (l_num_of_asgmts * 75) / l_db_block_size;

    IF l_num_of_asgmts > 0 THEN

        -- Put the input parameters in individual tables for insert.
        l_res_asgmt_id_tbl.extend(l_num_of_asgmts);
        l_new_rlm_id_tbl.extend(l_num_of_asgmts);
        l_override_cur_tbl.extend(l_num_of_asgmts);
        l_new_project_role_id_tbl.extend(l_num_of_asgmts);
        l_new_total_qty_tbl.extend(l_num_of_asgmts);
        l_new_sched_start_date_tbl.extend(l_num_of_asgmts);
        l_new_sched_finish_date_tbl.extend(l_num_of_asgmts);

        FOR i IN 1..l_num_of_asgmts LOOP
            l_res_asgmt_id_tbl(i)           := p_task_assignment_tbl(i).resource_assignment_id;
            l_new_rlm_id_tbl(i)             := p_task_assignment_tbl(i).resource_list_member_id;
            l_override_cur_tbl(i)           := p_task_assignment_tbl(i).override_currency_code;
            l_new_project_role_id_tbl(i)    := p_task_assignment_tbl(i).project_role_id;
            l_new_total_qty_tbl(i)          := p_task_assignment_tbl(i).total_quantity;
            l_new_sched_start_date_tbl(i)   := p_task_assignment_tbl(i).schedule_start_date;
            l_new_sched_finish_date_tbl(i)  := p_task_assignment_tbl(i).schedule_end_date;
        END LOOP;

        -- Manually seed the statistics for the temporary table.
        -- Need to do it before populating the table otherwise the table will be emptied.
        PA_TASK_ASSIGNMENT_UTILS.set_table_stats('PA','PA_RES_ASGMTS_TEMP', l_num_of_asgmts, l_num_blocks, 75);

        -- Populate the temporary table with the parameters passed in.
        DELETE pa_res_asgmts_temp;
        FORALL j IN 1..p_task_assignment_tbl.COUNT
            INSERT INTO pa_res_asgmts_temp VALUES
                (l_res_asgmt_id_tbl(j), l_new_rlm_id_tbl(j), l_override_cur_tbl(j), l_new_project_role_id_tbl(j),
                l_new_total_qty_tbl(j), l_new_sched_start_date_tbl(j), l_new_sched_finish_date_tbl(j));

        -- Initialize the arrays.
        l_res_asgmt_id_tbl          := SYSTEM.PA_NUM_TBL_TYPE();
        l_new_rlm_id_tbl            := SYSTEM.PA_NUM_TBL_TYPE();
        l_override_cur_tbl          := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
        l_new_project_role_id_tbl   := SYSTEM.PA_NUM_TBL_TYPE();
        l_new_total_qty_tbl         := SYSTEM.PA_NUM_TBL_TYPE();
        l_new_sched_start_date_tbl  := SYSTEM.PA_DATE_TBL_TYPE();
        l_new_sched_finish_date_tbl := SYSTEM.PA_DATE_TBL_TYPE();

        -- Populate all the parameters.
        OPEN get_all_parameters;
        FETCH get_all_parameters BULK COLLECT INTO l_res_asgmt_id_tbl, l_old_rlm_id_tbl, l_new_rlm_id_tbl,
        l_actual_cur_tbl, l_override_cur_tbl, l_old_project_role_id_tbl, l_new_project_role_id_tbl,
        l_old_total_qty_tbl, l_new_total_qty_tbl, l_actual_qty_tbl, l_actual_finish_date_tbl,
        l_old_sched_start_date_tbl, l_old_sched_finish_date_tbl, l_new_sched_start_date_tbl,
        l_new_sched_finish_date_tbl, l_lat_pub_prog_flag_tbl;
        CLOSE get_all_parameters;

        l_num_of_rows := l_res_asgmt_id_tbl.COUNT;

        IF l_num_of_rows > 0 THEN

            FOR k IN 1..l_num_of_rows LOOP

                -- Initialize the indicator.
                l_viol_indicator := NULL;

                -- Latest progress entered. Use this row to compare the override currency and the currency of the actuals.
                IF l_lat_pub_prog_flag_tbl(k) = 'Y' THEN

                    -- Cannot override the currency if progress has been collected.
                    IF ( l_actual_cur_tbl(k) IS NOT NULL AND l_override_cur_tbl(k) IS NOT NULL
                         AND l_actual_cur_tbl(k) <> l_override_cur_tbl(k) ) THEN
                        l_viol_indicator := 1;
                    END IF;

                -- Progress applied to the working version. Check the other business rules.
                ELSE -- l_lat_pub_prog_flag_tbl(k) <> 'Y'

                    -- Cannot change the planning resource if progress has been applied to the working version.
                    IF ( l_new_rlm_id_tbl(k) = FND_API.G_MISS_NUM AND l_old_rlm_id_tbl IS NOT NULL) OR
                       ( l_new_rlm_id_tbl(k) <> FND_API.G_MISS_NUM AND l_new_rlm_id_tbl(k) IS NOT NULL
                         AND ( l_new_rlm_id_tbl(k) <> l_old_rlm_id_tbl(k) OR l_old_rlm_id_tbl(k) IS NULL) ) THEN
                        l_viol_indicator := 2;
                    END IF;

                    -- Cannot change the project role if progress has been applied to the working version.
                    IF ( l_new_project_role_id_tbl(k) = FND_API.G_MISS_NUM AND l_old_project_role_id_tbl(k) IS NOT NULL )
                       OR ( l_new_project_role_id_tbl(k) <> FND_API.G_MISS_NUM AND l_new_project_role_id_tbl(k) IS NOT NULL AND
                       ( l_old_project_role_id_tbl(k) <> l_new_project_role_id_tbl(k) OR l_old_project_role_id_tbl(k) IS NULL ) ) THEN
                        l_viol_indicator := 3;
                    END IF;
		    /* Bug Fix 5726773
 	                As a part of supporting negative quantities and amounts the following check is commented out.

                    -- Cannot decrease planned quantity below actual quantity.
                    IF ( l_actual_qty_tbl(k) IS NOT NULL AND l_new_total_qty_tbl(k) IS NOT NULL AND
                       ( l_new_total_qty_tbl(k) = FND_API.G_MISS_NUM OR l_new_total_qty_tbl(k) < l_actual_qty_tbl(k) ) ) THEN
                        l_viol_indicator := 4;
                    END IF;
		    */
 	            -- End of Bug Fix 5726773

                    /* Bug 4570108
		    9/02 M-closeout - Based on discussion with Koushik, Sakthi, Ansari, removing this check:
                    -- If the assignment is completed.
                    IF ( l_actual_finish_date_tbl(k) IS NOT NULL ) THEN

                        -- Cannot change the scheduled start date if an actual end date has been entered.
                        IF ( l_new_sched_start_date_tbl(k) = FND_API.G_MISS_DATE AND l_old_sched_start_date_tbl(k) IS NOT NULL )
                           OR ( l_new_sched_start_date_tbl(k) <> FND_API.G_MISS_DATE AND l_new_sched_start_date_tbl(k) IS NOT NULL AND
                              (l_new_sched_start_date_tbl(k) <> l_old_sched_start_date_tbl(k) OR l_old_sched_start_date_tbl(k) IS NULL) ) THEN
                            l_viol_indicator := 6;
                        END IF;

                        -- Cannot change the scheduled finish date if an actual end date has been entered.
                        IF ( l_new_sched_finish_date_tbl(k) = FND_API.G_MISS_DATE
                           AND l_old_sched_finish_date_tbl(k) IS NOT NULL ) OR
                           ( l_new_sched_finish_date_tbl(k) <> FND_API.G_MISS_DATE AND
                           l_new_sched_finish_date_tbl(k) IS NOT NULL AND ( l_new_sched_finish_date_tbl(k) <> l_old_sched_finish_date_tbl(k)
                           OR l_old_sched_finish_date_tbl(k) IS NULL) ) THEN
                            l_viol_indicator := 7;
                        END IF;

                    END IF; -- l_actual_finish_date_tbl(k) IS NOT NULL
		    */

                END IF; -- l_lat_pub_prog_flag_tbl(k) = 'Y'

                IF l_viol_indicator IS NOT NULL THEN

                    x_return_status := FND_API.G_RET_STS_ERROR;

                    IF l_viol_indicator = 1 THEN
                        PA_UTILS.ADD_MESSAGE
                        (
                            p_app_short_name => 'PA',
                            p_msg_name       => 'PA_UP_TA_CUR_ERR',
                            p_token1         => 'ACTUAL_CURRENCY',
                            p_value1         =>  l_actual_cur_tbl(k)
                        );
                    ELSIF l_viol_indicator = 2 OR l_viol_indicator = 3 THEN
                        PA_UTILS.ADD_MESSAGE
                        (
                            p_app_short_name => 'PA',
                            p_msg_name       => 'PA_UP_TA_PL_RES_ERR'
                        );
                    ELSIF l_viol_indicator = 4 THEN
                        PA_UTILS.ADD_MESSAGE
                        (
                            p_app_short_name => 'PA',
                            p_msg_name       => 'PA_UP_TA_DECR_QTY_ERR'
                        );
                    ELSIF l_viol_indicator = 6 OR l_viol_indicator = 7 THEN
                        PA_UTILS.ADD_MESSAGE
                        (
                            p_app_short_name => 'PA',
                            p_msg_name       => 'PA_UP_TA_ASMT_END_ERR'
                        );
                    END IF; -- l_viol_indicator

                END IF; -- l_viol_indicator IS NOT NULL

            END LOOP;

        END IF; -- l_num_of_rows > 0

    END IF; -- l_num_of_asgmts > 0

    EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

END check_prog_for_update_asgmts;

-- Bug # 3910193: Created API: convert_effort_to_cost_brdn_pc().

PROCEDURE convert_effort_to_cost_brdn_pc
(   p_resource_list_mem_id      IN                        NUMBER
    ,p_project_id                   IN                        NUMBER
    ,p_task_id              IN                    NUMBER
    ,p_as_of_date           IN                    DATE
    ,p_structure_version_id         IN                        NUMBER
    ,p_txn_currency_code            IN                        VARCHAR
    ,p_planned_quantity             IN                        NUMBER
    ,p_act_quantity_this_period     IN                        NUMBER
    ,p_act_quantity                 IN                        NUMBER
    ,p_act_brdncost_pc              IN                        NUMBER
    ,p_etc_quantity                 IN                        NUMBER
    ,p_rate_based_flag              IN                        VARCHAR := 'Y'
    ,x_act_brdncost_pc_this_period      OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_brdncost_pc                  OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_comp_quantity              OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_spent_quantity             OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_eac_quantity                 OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_comp_brdncost_pc       OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_spent_brdncost_pc      OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_eac_brdncost_pc              OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status            OUT                       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count            OUT                       NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data             OUT                       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS
      /* commented out, performance issue
    cursor cur_ptav is
    select planned_bur_cost_proj_cur
    from pa_task_asgmts_v
    where project_id = p_project_id
    and task_id = p_task_id
    and structure_version_id = p_structure_version_id
    and resource_list_member_id = p_resource_list_mem_id;
      */

     cursor cur_ptav is
     select pra.total_project_burdened_cost as planned_bur_cost_proj_cur
     , pra.resource_assignment_id -- Bug 4372462
     , pra.budget_version_id -- Bug 4372462
       FROM pa_resource_assignments pra,
            PA_PROJ_ELEMENT_VERSIONS PPEV
      where pra.resource_list_member_id = p_resource_list_mem_id
        and pra.task_id = p_task_id
        AND PPEV.PROJECT_ID = p_project_id
        AND PPEV.PARENT_STRUCTURE_VERSION_ID = p_structure_version_id
        AND pra.TASK_ID = PPEV.PROJ_ELEMENT_ID
        AND pra.wbs_element_version_id = ppev.element_version_id;

    l_cur_ptav          NUMBER;
    l_resource_assignment_id    NUMBER; -- Bug 4372462
    l_budget_version_id     NUMBER; -- Bug 4372462

    l_planned_brdncost_pc       NUMBER       := null;

        l_plan_res_cur_code             VARCHAR2(30)     := null;

        l_plan_res_burden_rate_etc      NUMBER           := null;
        l_plan_res_burden_rate_act      NUMBER           := null;

        l_plan_res_raw_rate         NUMBER           := null;

        l_plan_burden_multiplier_etc    NUMBER           := null;
        l_plan_burden_multiplier_act    NUMBER           := null;

    l_rawcost_pc            NUMBER       := null;
    l_rawcost_fc            NUMBER       := null;

    l_txn_currency_code     VARCHAR2(15)     := null;

    l_project_curr_code             VARCHAR2(30);
        l_project_rate_type             VARCHAR2(30);
        l_project_rate_date             DATE;
        l_project_exch_rate             NUMBER;

    l_projfunc_curr_code            VARCHAR2(30);
        l_projfunc_cost_rate_type       VARCHAR2(30);
        l_projfunc_cost_rate_date       DATE;
        l_projfunc_cost_exch_rate       NUMBER;

    l_etc_brdncost_tc       NUMBER        := null;
    l_etc_brdncost_pc       NUMBER        := null;

    l_act_brdncost_pc       NUMBER        := null;

    l_act_brdncost_tc_this_period   NUMBER        := null;
    l_act_brdncost_pc_this_period   NUMBER        := null;

    l_act_quantity_to_date      NUMBER        := null;
    l_act_brdncost_to_date_pc   NUMBER        := null;

    l_eac_quantity          NUMBER        := null;
    l_eac_brdncost_pc       NUMBER        := null;

    l_prcnt_comp_quantity       NUMBER        := null;
    l_prcnt_spent_quantity      NUMBER        := null;

    l_prcnt_comp_brdncost_pc    NUMBER        := null;
    l_prcnt_spent_brdncost_pc   NUMBER        := null;

    l_return_status                 VARCHAR2(1)       := null;
        l_msg_count                     NUMBER            := null;
        l_msg_data                      VARCHAR2(250)     := null;

        g1_debug_mode               VARCHAR2(1);
    l_track_wp_cost_flag  VARCHAR2(1) := 'Y'; -- Bug 3921624


BEGIN
     l_return_status := fnd_api.g_ret_sts_success ; -- 4537865
     g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

     IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_resource_list_mem_id='||p_resource_list_mem_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_txn_currency_code='||p_txn_currency_code, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_planned_quantity='||p_planned_quantity, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_act_quantity_this_period='||p_act_quantity_this_period, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_act_quantity='||p_act_quantity, x_Log_Level=> 3);
             pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_act_brdncost_pc='||p_act_brdncost_pc, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_etc_quantity='||p_etc_quantity, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'p_rate_based_flag='||p_rate_based_flag, x_Log_Level=> 3);
     END IF;

     FND_MSG_PUB.initialize;

     l_track_wp_cost_flag :=  pa_fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id);  --Bug 3921624

     IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN   --Bug 3921624
    --  1). Get the input act_brdncost_pc into the corresponding local variable.

        l_act_brdncost_pc := nvl(p_act_brdncost_pc,0);

    --  2). Get the planned_brdncost_pc from pa_task_assignments_v;

    open cur_ptav;
    fetch cur_ptav into l_cur_ptav, l_resource_assignment_id,l_budget_version_id ; -- Bug 4372462 : Added l_resource_assignment_id and l_budget_version_id
    close cur_ptav;


    l_planned_brdncost_pc := nvl(l_cur_ptav,0);

    -- 3.1). Get resource rate burden multiplier to convert etc_rawcost to etc_brdncost and resource burden rate to convert etc_effort to etc_brdncost in tc.

    l_plan_res_cur_code               := null;
        l_plan_res_raw_rate           := null;
        l_return_status                   := null;
        l_msg_count                       := null;
        l_msg_data                        := null;
    l_plan_burden_multiplier_etc      := null;
    l_plan_res_burden_rate_etc        := null;

    PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier(
                P_res_list_mem_id              => p_resource_list_mem_id
                ,P_project_id                  => p_project_id
                ,P_task_id                     => p_task_id      --bug 3927159
            ,p_as_of_date                  => p_as_of_date   --bug 3927159
                ,p_structure_version_id        => p_structure_version_id
                ,p_currency_code               => p_txn_currency_code
                ,p_calling_mode                => 'PLAN_RATES'
                ,x_resource_curr_code          => l_plan_res_cur_code
                ,x_resource_raw_rate           => l_plan_res_raw_rate
                ,x_resource_burden_rate        => l_plan_res_burden_rate_etc
                ,X_burden_multiplier           => l_plan_burden_multiplier_etc
                ,x_return_status               => l_return_status
                ,x_msg_count                   => l_msg_count
                ,x_msg_data                    => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

        -- 3.2). If the rate_based_flag is 'Y' and the resource burden rate currency code is not the same as the txn currency code, convert the resource burden rate into txn currency.
    --    To do this we use the API: PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS() and we pass in
    --    txn_currency code into the projfunc_currency_code parameter and read out the value of
    --    the parameter projfunc_raw_cost.

    IF ((p_rate_based_flag = 'Y') and (p_txn_currency_code <> l_plan_res_cur_code)) then
            l_rawcost_pc := null;
            l_txn_currency_code := p_txn_currency_code;

        PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
                p_project_id               =>  p_project_id
                ,p_task_id                  => p_task_id
                ,p_as_of_date               => p_as_of_date
                ,p_txn_cost                 => l_plan_res_burden_rate_etc
                ,p_txn_curr_code            => l_plan_res_cur_code
            ,p_structure_version_id     => p_structure_version_id
            ,p_project_curr_code        => l_txn_currency_code ---l_project_curr_code
                ,p_project_rate_type        => l_project_rate_type
                ,p_project_rate_date        => l_project_rate_date
                ,p_project_exch_rate        => l_project_exch_rate
                ,p_project_raw_cost         => l_rawcost_pc
            ,p_projfunc_curr_code       => l_projfunc_curr_code ---txn_currency_code
                ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
                ,p_projfunc_raw_cost        => l_rawcost_fc
                ,x_return_status            => l_return_status
                ,x_msg_count                => l_msg_count
                ,x_msg_data                 => l_msg_data
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
            END IF;

        l_plan_res_burden_rate_etc :=   l_rawcost_pc;

    END IF;

    -- 4.1). Get resource rate burden multiplier to convert act_rawcost_this_period to
    --    act_brdncost_this_period and resource burden rate to convert act_effort_this_period
    --    to act_brdncost_tc_this_period.

    l_plan_res_cur_code               := null;
        l_plan_res_raw_rate           := null;
        l_return_status                   := null;
        l_msg_count                       := null;
        l_msg_data                        := null;

    l_plan_burden_multiplier_act      := null;
    l_plan_res_burden_rate_act        := null;

    PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier(
                    P_res_list_mem_id              => p_resource_list_mem_id
                ,P_project_id                  => p_project_id
                ,P_task_id                     => p_task_id      --bug 3927159
            ,p_as_of_date                  => p_as_of_date   --bug 3927159
                ,p_structure_version_id        => p_structure_version_id
                ,p_currency_code               => p_txn_currency_code
                ,p_calling_mode                => 'ACTUAL_RATES'
                ,x_resource_curr_code          => l_plan_res_cur_code
                ,x_resource_raw_rate           => l_plan_res_raw_rate
                ,x_resource_burden_rate        => l_plan_res_burden_rate_act
                ,X_burden_multiplier           => l_plan_burden_multiplier_act
                ,x_return_status               => l_return_status
                ,x_msg_count                   => l_msg_count
                ,x_msg_data                    => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := 'E';
             RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- 4.2). If the rate_based_flag is 'Y' and the resource burden rate currency code is
    --    not the same as the txn currency code, convert the resource burden rate into txn currency.
    --    To do this we use the API: PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS() and we pass in
    --    txn_currency code into the projfunc_currency_code parameter and read out the value of
    --    the parameter projfunc_raw_cost.

    IF ((p_rate_based_flag = 'Y') and (p_txn_currency_code <> l_plan_res_cur_code)) then

        l_rawcost_pc := null;
            l_txn_currency_code := p_txn_currency_code;
        PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
                p_project_id               =>  p_project_id
                ,p_task_id                  => p_task_id
                ,p_as_of_date               => p_as_of_date
                ,p_txn_cost                 => l_plan_res_burden_rate_act
                ,p_txn_curr_code            => l_plan_res_cur_code
            ,p_structure_version_id     => p_structure_version_id
            ,p_project_curr_code        => l_txn_currency_code ---l_project_curr_code
                ,p_project_rate_type        => l_project_rate_type
                ,p_project_rate_date        => l_project_rate_date
                ,p_project_exch_rate        => l_project_exch_rate
                ,p_project_raw_cost         => l_rawcost_pc
            ,p_projfunc_curr_code       => l_projfunc_curr_code ---l_txn_currency_code
                ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
                ,p_projfunc_raw_cost        => l_rawcost_fc
                ,x_return_status            => l_return_status
                ,x_msg_count                => l_msg_count
                ,x_msg_data                 => l_msg_data
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
            END IF;

        l_plan_res_burden_rate_act :=   l_rawcost_pc;
    END IF;

     -- If (p_rate_based_flag  = 'N'), the input quantity values are rawcost_tc values.
    If (p_rate_based_flag = 'N') then

      -- 5.1). Use the resource rate burden multiplier to convert etc_rawcost_tc into etc_brdncost_tc.

      --l_etc_brdncost_tc := nvl(pa_currency.round_trans_currency_amt((nvl(p_etc_quantity,0) * nvl(l_plan_burden_multiplier_etc,0)), p_txn_currency_code),0) + nvl(p_etc_quantity,0);
            l_etc_brdncost_tc := nvl(pa_currency.round_trans_currency_amt1((nvl(p_etc_quantity,0) * nvl(l_plan_burden_multiplier_etc,0)), p_txn_currency_code),0) + nvl(p_etc_quantity,0);
      -- 5.2). Use the resource rate burden multiplier to convert act_rawcost_tc_this_period into  act_brdncost_tc_this_period.

      --l_act_brdncost_tc_this_period := nvl(pa_currency.round_trans_currency_amt(
    --          (nvl(p_act_quantity_this_period,0) * nvl(l_plan_burden_multiplier_act,0)), p_txn_currency_code),0) + nvl(p_act_quantity_this_period,0);

        l_act_brdncost_tc_this_period := nvl(pa_currency.round_trans_currency_amt1(
                (nvl(p_act_quantity_this_period,0) * nvl(l_plan_burden_multiplier_act,0)), p_txn_currency_code),0) + nvl(p_act_quantity_this_period,0);

    else

       -- 6.1). Use resource burden rate to convert etc_effort into etc_brdncost_tc:

       --l_etc_brdncost_tc := pa_currency.round_trans_currency_amt((nvl(p_etc_quantity,0) * nvl(l_plan_res_burden_rate_etc,0)), p_txn_currency_code);
       l_etc_brdncost_tc := pa_currency.round_trans_currency_amt1((nvl(p_etc_quantity,0) * nvl(l_plan_res_burden_rate_etc,0)), p_txn_currency_code);

        -- 6.2). Use resource burden rate to convert act_effort_this_period into
        --       act_brdncost_tc_this_period.

           --l_act_brdncost_tc_this_period := pa_currency.round_trans_currency_amt(
        --      (nvl(p_act_quantity_this_period,0) * nvl(l_plan_res_burden_rate_act,0)), p_txn_currency_code);
         l_act_brdncost_tc_this_period := pa_currency.round_trans_currency_amt1(
                (nvl(p_act_quantity_this_period,0) * nvl(l_plan_res_burden_rate_act,0)), p_txn_currency_code);
     end if;     -- If (p_rate_based_flag = 'N') then

         -- 7.1). Convert etc_brdncost_tc into etc_brdncost_pc. To do this we use the API:
     --      PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS() and we pass in etc_brdncost_tc
     --  into the txn_cost parameter and read out the value of the parameter project_raw_cost.

     l_rawcost_pc := null;

         PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
                p_project_id                => p_project_id
                ,p_task_id                  => p_task_id
                ,p_as_of_date               => p_as_of_date
                ,p_txn_cost                 => l_etc_brdncost_tc
                ,p_txn_curr_code            => p_txn_currency_code
            ,p_structure_version_id     => p_structure_version_id
            ,p_project_curr_code        => l_project_curr_code
                ,p_project_rate_type        => l_project_rate_type
                ,p_project_rate_date        => l_project_rate_date
                ,p_project_exch_rate        => l_project_exch_rate
                ,p_project_raw_cost         => l_rawcost_pc
            ,p_projfunc_curr_code       => l_projfunc_curr_code
                ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
                ,p_projfunc_raw_cost        => l_rawcost_fc
            ,p_calling_mode         => 'PLAN_RATES' -- Bug 4372462
            ,p_budget_version_id        => l_budget_version_id -- Bug 4372462
            ,p_res_assignment_id        => l_resource_assignment_id -- Bug 4372462
                ,x_return_status            => l_return_status
                ,x_msg_count                => l_msg_count
                ,x_msg_data                 => l_msg_data
            );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

     l_etc_brdncost_pc := l_rawcost_pc;

     -- 7.2). Convert act_brdncost_tc_this_period into act_brdncost_pc_this_period.
     --  To do this we use the API: PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS()
     --      and we pass in act_brdncost_tc_this_period into the txn_cost parameter and
     --  read out the value of the parameter project_raw_cost.

     l_rawcost_pc := null;

     PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
                p_project_id                => p_project_id
                ,p_task_id                  => p_task_id
                ,p_as_of_date               => p_as_of_date
                ,p_txn_cost                 => l_act_brdncost_tc_this_period
                ,p_txn_curr_code            => p_txn_currency_code
            ,p_structure_version_id     => p_structure_version_id
            ,p_project_curr_code        => l_project_curr_code
                ,p_project_rate_type        => l_project_rate_type
                ,p_project_rate_date        => l_project_rate_date
                ,p_project_exch_rate        => l_project_exch_rate
                ,p_project_raw_cost         => l_rawcost_pc
            ,p_projfunc_curr_code       => l_projfunc_curr_code
                ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
                ,p_projfunc_raw_cost        => l_rawcost_fc
                ,x_return_status            => l_return_status
                ,x_msg_count                => l_msg_count
                ,x_msg_data                 => l_msg_data
            );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      l_act_brdncost_pc_this_period := l_rawcost_pc;

      END IF;  -- bug 3921624, IF NVL(l_track_wp_cost_flag, 'Y') = 'Y'

      l_act_quantity_to_date := nvl(p_act_quantity,0) + nvl(p_act_quantity_this_period,0);
      l_eac_quantity := (nvl(p_etc_quantity,0) + l_act_quantity_to_date);
      l_prcnt_comp_quantity := PA_PROGRESS_UTILS.Percent_Complete_Value(l_act_quantity_to_date,p_etc_quantity);
      l_prcnt_spent_quantity := PA_PROGRESS_UTILS.Percent_Spent_Value(l_act_quantity_to_date,p_planned_quantity);

      IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- bug 3921624
    l_act_brdncost_to_date_pc := nvl(l_act_brdncost_pc,0)  + nvl(l_act_brdncost_pc_this_period,0);
    l_eac_brdncost_pc := (nvl(l_etc_brdncost_pc,0) + l_act_brdncost_to_date_pc );
    l_prcnt_comp_brdncost_pc := PA_PROGRESS_UTILS.Percent_Complete_Value(l_act_brdncost_to_date_pc,l_etc_brdncost_pc);
    l_prcnt_spent_brdncost_pc := PA_PROGRESS_UTILS.Percent_Spent_Value(l_act_brdncost_to_date_pc,l_planned_brdncost_pc);
      END IF;

      IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'l_eac_quantity='||l_eac_quantity, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'l_eac_brdncost_pc='||l_eac_brdncost_pc, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'l_prcnt_comp_quantity='||l_prcnt_comp_quantity, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'l_prcnt_comp_brdncost_pc='||l_prcnt_comp_brdncost_pc, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'l_prcnt_spent_quantity='||l_prcnt_spent_quantity, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.convert_effort_to_cost_brdn_pc', x_Msg => 'l_prcnt_spent_brdncost_pc='||l_prcnt_spent_brdncost_pc, x_Log_Level=> 3);
      END IF;

    -- Set the values to the output parameters:

    x_act_brdncost_pc_this_period           :=    nvl(l_act_brdncost_pc_this_period, 0);
    x_etc_brdncost_pc                       :=    nvl(l_etc_brdncost_pc,0);

    x_prcnt_comp_quantity                   :=    nvl(l_prcnt_comp_quantity,0);
    x_prcnt_spent_quantity                  :=    nvl(l_prcnt_spent_quantity,0);
    x_eac_quantity                          :=    nvl(l_eac_quantity,0);

    x_prcnt_comp_brdncost_pc                :=    nvl(l_prcnt_comp_brdncost_pc,0);
    x_prcnt_spent_brdncost_pc               :=    nvl(l_prcnt_spent_brdncost_pc,0);
    x_eac_brdncost_pc                       :=    nvl(l_eac_brdncost_pc,0);

    x_return_status                 :=    l_return_status;
    x_msg_count                     :=    l_msg_count;
    x_msg_data                      :=    l_msg_data;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := Fnd_Msg_Pub.count_msg;

    -- 4537865
    x_act_brdncost_pc_this_period   := 0 ;
    x_etc_brdncost_pc               := 0 ;
    x_prcnt_comp_quantity           := 0 ;
    x_prcnt_spent_quantity          := 0 ;
    x_eac_quantity                  := 0 ;
    x_prcnt_comp_brdncost_pc        := 0 ;
    x_prcnt_spent_brdncost_pc       := 0 ;
    x_eac_brdncost_pc               := 0 ;

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SUBSTRB(SQLERRM,1,240);
    -- 4537865
    x_act_brdncost_pc_this_period   := 0 ;
    x_etc_brdncost_pc               := 0 ;
    x_prcnt_comp_quantity           := 0 ;
    x_prcnt_spent_quantity          := 0 ;
    x_eac_quantity                  := 0 ;
    x_prcnt_comp_brdncost_pc        := 0 ;
    x_prcnt_spent_brdncost_pc       := 0 ;
    x_eac_brdncost_pc               := 0 ;
    RAISE;

END convert_effort_to_cost_brdn_pc;

function get_actual_summ_date(p_project_id   IN  NUMBER) return date
is
 l_prog_act_summ_date   date := null;
begin
 /*
   select next_progress_update_date
     into l_prog_act_summ_date
     from pa_proj_progress_attr
    where project_id = p_project_id
      and object_type = 'PA_STRUCTURES'
      and structure_type = 'WORKPLAN';

   --- adding if statement for bug 4490380
   if l_prog_act_summ_date is null then
 */
   --- Bug 4652132 always return latest as_of_date for the project/program.
      select as_of_date
        into l_prog_act_summ_date
        from pa_progress_rollup
       where project_id = p_project_id
         and object_type = 'PA_STRUCTURES'
         and structure_type = 'WORKPLAN'
         and structure_version_id is null
         and current_flag = 'Y';

   return l_prog_act_summ_date;

exception when others then
    return to_date(null);
end;

/* Bug # 3956235: Created API: get_cost_variance(). */

-- 4392189 Phase 2: ignore p_base_percent_complete
Function get_cost_variance(
    p_project_id                NUMBER
    , p_proj_element_id         NUMBER
    , p_structure_version_id        NUMBER
    , p_task_weight_method              VARCHAR2
    , p_structure_type          VARCHAR2 := 'WORKPLAN'
    , p_base_percent_complete       NUMBER
    , p_eff_rollup_percent_comp     NUMBER
    , p_earned_value            NUMBER
    , p_oth_act_cost_to_date_pc     NUMBER
    , p_ppl_act_cost_to_date_pc     NUMBER
    , p_eqpmt_act_cost_to_date_pc       NUMBER
    , p_spj_oth_act_cost_to_date_pc     NUMBER
    , p_spj_ppl_act_cost_pc         NUMBER
    , p_spj_eqpmt_act_cost_pc       NUMBER
) return number
is

    l_cost_variance NUMBER  := null;
    l_bac_value NUMBER  := null;
    l_earned_value  NUMBER  := null;

begin

    if (p_task_weight_method = 'EFFORT') then

        /* Get the corresponding BAC cost value by passing p_task_weight_method as 'COST'. */

            l_bac_value := pa_progress_utils.get_bac_value(
                        p_project_id        => p_project_id
                    ,p_task_weight_method   => 'COST'
                    ,p_proj_element_id  => p_proj_element_id
                    ,p_structure_version_id => p_structure_version_id
                    ,p_structure_type   => p_structure_type
                    );

        /* Calculate the corresponding earned_value cost using the BAC cost value. */

--          l_earned_value := round((nvl(nvl(p_base_percent_complete
--                           ,p_eff_rollup_percent_comp),0)
--                      * nvl(l_bac_value,0)/100),5);
            l_earned_value := round((nvl(p_eff_rollup_percent_comp,0)
                        * nvl(l_bac_value,0)/100),5);


    else

        /* Set earned_value as the input earned_value. */

            l_earned_value := nvl(p_earned_value,0);

    end if;

    /* Calculate the cost_variance. */

        l_cost_variance := nvl(l_earned_value,0)-(nvl(p_oth_act_cost_to_date_pc,0)
                              +nvl(p_ppl_act_cost_to_date_pc,0)
                              +nvl(p_eqpmt_act_cost_to_date_pc,0)
                              +nvl(p_spj_oth_act_cost_to_date_pc,0)
                                  +nvl(p_spj_ppl_act_cost_pc,0)
                              +nvl(p_spj_eqpmt_act_cost_pc,0));

    /* Return the calcualted cost variance. */

        return(l_cost_variance);

end  get_cost_variance;

-- Begin fix for Bug # 4073659.

FUNCTION check_prog_exists_and_delete(
 p_project_id       NUMBER
 ,p_task_id     NUMBER
 ,p_object_type     VARCHAR2 := 'PA_TASKS'
 ,p_object_id       NUMBER   := null
 ,p_structure_type  VARCHAR2 := 'WORKPLAN'
 ,p_delete_progress_flag    VARCHAR2 := 'Y' -- Fix for Bug # 4140984.

) RETURN VARCHAR2 IS

  CURSOR cur_ppc_assgn(c_object_id NUMBER, c_task_id NUMBER, c_object_type VARCHAR2
               , c_project_id NUMBER, c_structure_type VARCHAR2)
  IS
     SELECT 'Y'
     FROM pa_percent_completes ppc
     WHERE ppc.object_id = c_object_id
     AND ppc.task_id = c_task_id
     AND ppc.object_type = c_object_type
     AND ppc.project_id  = c_project_id
     AND ppc.structure_type = c_structure_type
     AND ppc.published_flag = 'Y';

  CURSOR cur_ppr_assgn(c_object_id NUMBER, c_task_id NUMBER, c_object_type VARCHAR2
                       , c_project_id NUMBER, c_structure_type VARCHAR2)
  IS
    SELECT 'Y'
    FROM pa_progress_rollup ppr
    WHERE ppr.object_id = c_object_id
    AND ppr.proj_element_id = c_task_id
    AND ppr.object_type = c_object_type
    AND ppr.project_id  = c_project_id
    AND ppr.structure_type = p_structure_type
    AND (((nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
       +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
           + nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) <> 0 ) -- 4417665 : making it <> 0 rather than >0
     OR
         ((nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)
       +nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)) <> 0) -- 4417665 : making it <> 0 rather than >0
     OR
     ((nvl(ppr.oth_etc_cost_tc,0)+nvl(ppr.ppl_etc_cost_tc,0)
       +nvl(ppr.eqpmt_etc_cost_tc,0)+nvl(ppr.subprj_oth_etc_cost_tc,0)
           +nvl(ppr.subprj_ppl_etc_cost_tc,0) +nvl(ppr.subprj_eqpmt_etc_cost_tc,0)) > 0)
     OR
     ((nvl(ppr.estimated_remaining_effort,0)+nvl(ppr.eqpmt_etc_effort,0)
       +nvl(ppr.subprj_ppl_etc_effort,0)+nvl(ppr.subprj_eqpmt_etc_effort,0)) > 0))
     AND ppr.current_flag in ('Y', 'W')
     AND ppr.structure_version_id is null;

  CURSOR cur_ppc_task(c_task_id NUMBER, c_object_type VARCHAR2
                      , c_project_id NUMBER, c_structure_type VARCHAR2)
  IS
     SELECT 'Y'
     FROM pa_percent_completes ppc
     WHERE ppc.task_id = c_task_id
     AND ppc.object_type = c_object_type
     AND ppc.project_id  = c_project_id
     AND ppc.structure_type = c_structure_type
     AND ppc.published_flag = 'Y';

  CURSOR cur_ppr_task(c_task_id NUMBER, c_object_type VARCHAR2
                       , c_project_id NUMBER, c_structure_type VARCHAR2)
  IS
    SELECT 'Y'
    FROM pa_progress_rollup ppr
    WHERE ppr.proj_element_id = c_task_id
    AND ppr.object_type = c_object_type
    AND ppr.project_id  = c_project_id
    AND ppr.structure_type = p_structure_type
    AND (((nvl(ppr.oth_act_cost_to_date_tc,0)+nvl(ppr.ppl_act_cost_to_date_tc,0)
           +nvl(ppr.eqpmt_act_cost_to_date_tc,0)+nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
           + nvl(ppr.subprj_ppl_act_cost_tc,0)+nvl(ppr.subprj_eqpmt_act_cost_tc,0)) <> 0 ) ---- 4417665 : making it <> 0 rather than >0
         OR
         ((nvl(ppr.ppl_act_effort_to_date,0)+nvl(ppr.eqpmt_act_effort_to_date,0)
           +nvl(ppr.subprj_ppl_act_effort,0)+nvl(ppr.subprj_eqpmt_act_effort,0)) <> 0) -- 4417665 : making it <> 0 rather than >0
         OR
         ((nvl(ppr.oth_etc_cost_tc,0)+nvl(ppr.ppl_etc_cost_tc,0)
           +nvl(ppr.eqpmt_etc_cost_tc,0)+nvl(ppr.subprj_oth_etc_cost_tc,0)
           +nvl(ppr.subprj_ppl_etc_cost_tc,0) +nvl(ppr.subprj_eqpmt_etc_cost_tc,0)) > 0)
         OR
         ((nvl(ppr.estimated_remaining_effort,0)+nvl(ppr.eqpmt_etc_effort,0)
           +nvl(ppr.subprj_ppl_etc_effort,0)+nvl(ppr.subprj_eqpmt_etc_effort,0)) > 0))
     AND ppr.current_flag in ('Y', 'W')
     AND ppr.structure_version_id is null;

  l_return_value        VARCHAR2(1) := 'N';

BEGIN


     -- 1). Default l_return_value.

     l_return_value := 'N';

     -- 2). If progress check and deletion is requested for a single assignment.

    if (p_object_type = 'PA_ASSIGNMENTS') then

         -- 2.1). If published progress exists for the assignment
     --   return ''Y'.
        -- 4469270 : Removed the check for ppc records
            --OPEN cur_ppc_assgn (p_object_id, p_task_id, p_object_type, p_project_id, p_structure_type);
            --FETCH cur_ppc_assgn INTO l_return_value;
            --CLOSE cur_ppc_assgn;

            IF NVL(l_return_value,'N') <> 'Y' THEN

            -- 2.2). If published progress does not exist for the assignment but latest published
            --       or working rollup records exist and actuals /  etc > 0 for the assignment
            --       assignment return 'Y'.

                OPEN cur_ppr_assgn (p_object_id, p_task_id, p_object_type, p_project_id, p_structure_type);
                    FETCH cur_ppr_assgn INTO l_return_value;
                    CLOSE cur_ppr_assgn;

                l_return_value := NVL(l_return_value, 'N');

            END IF;

        -- 2.3). If no published progress exists for the assignment and actuals / etc are = 0 on
        --   the latest published or working rollup records for the assignment then delete
        --   the rollup records for the assignment.

        if ((l_return_value = 'N') and (p_delete_progress_flag = 'Y')) then -- fix for Bug # 4140984.

            DELETE FROM pa_progress_rollup ppr
            WHERE ppr.object_id = p_object_id
            AND ppr.proj_element_id = p_task_id
                AND ppr.object_type = p_object_type
                AND ppr.project_id  = p_project_id
                AND ppr.structure_type = p_structure_type;

        end if;

    -- 3). If progress check and deletion is requested for all the assignments of a task.

    elsif (p_object_type = 'PA_TASKS') then

            -- 3.1). If published progress exists for any of the assignments for the task then
        --   return 'Y'.
            -- 4469270 : Removed the check for ppc records
                    --OPEN cur_ppc_task (p_task_id, 'PA_ASSIGNMENTS'
            --            , p_project_id, p_structure_type);
                    --FETCH cur_ppc_task INTO l_return_value;
                    --CLOSE cur_ppc_task;

            IF NVL(l_return_value,'N') <> 'Y' THEN

                        -- 3.2). If published progress does not exist for any of the assignments for the
            --   task but latest published or working rollup records exist and actuals / etc
            --   > 0 for any of the assignments return 'Y'.

                                OPEN cur_ppr_task (p_task_id, 'PA_ASSIGNMENTS'
                                                   , p_project_id, p_structure_type);
                                FETCH cur_ppr_task INTO l_return_value;
                                CLOSE cur_ppr_task;

                                l_return_value := NVL(l_return_value, 'N');

                        END IF;

                -- 3.3). If no published progress exists for any of the assignments and actuals / etc  = 0
        --   on the latest published or working rollup records for all the assignments then
        --   delete all the rollup records for all the assignments for the given task.

                if ((l_return_value = 'N') and (p_delete_progress_flag = 'Y')) then -- Fix for Bug # 4140984.

                        DELETE FROM pa_progress_rollup ppr
                        WHERE ppr.proj_element_id = p_task_id
            AND ppr.object_type = 'PA_ASSIGNMENTS'
                        AND ppr.project_id  = p_project_id
                        AND ppr.structure_type = p_structure_type;

                end if;

    end if;

    return(l_return_value);

END check_prog_exists_and_delete;

-- End fix for Bug # 4073659.

/* Begin fix for bug # 4115607. */

FUNCTION get_app_cost_budget_cb_wor_ver(p_project_id NUMBER)
return NUMBER
IS

l_plan_version_id               NUMBER := null;
l_plan_type_id                  NUMBER;
l_fp_options_id                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_count                     NUMBER;

BEGIN

        -- Call the FP API to get the approved cost budget current baselined version id.

        l_plan_version_id := PA_FIN_PLAN_UTILS.Get_app_budget_cost_cb_ver(p_project_id);


        -- If approved cost budget current baselined version is null then get the approved cost budget
        -- plan_type_id.

        if l_plan_version_id is null then

        -- First get the approved cost budget plan_type_id.

        PA_FIN_PLAN_UTILS.Get_Appr_Cost_Plan_Type_Info(
        p_project_id            => p_project_id
        ,x_plan_type_id         => l_plan_type_id
        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data);

        -- If plan_type_id is not null,  use the plan_type_id to get the approved cost budget current working        -- version id.

                if (l_plan_type_id is not null) then

                        PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(
                        p_project_id            => p_project_id
                        ,p_fin_plan_type_id     => l_plan_type_id
                        ,p_version_type         => 'COST'
                        ,x_fp_options_id        => l_fp_options_id
                        ,x_fin_plan_version_id  => l_plan_version_id
                        ,x_return_status        => l_return_status
                        ,x_msg_count            => l_msg_count
                        ,x_msg_data             => l_msg_data);

                end if;

        end if;

        return(l_plan_version_id);

END  get_app_cost_budget_cb_wor_ver;

/* End fix for bug # 4115607. */

-- procedure to get resource raw and brdn rates
--Bug 5027965. introduced parameter p_etc_cost_calc_mode which  can be either COPY or DERIVE.
--If its COPY then
----the etc cost in the current working workplan version will returned. In this case
----the parameter p_budget_version_id will contain the budget version id corresponding to the
----current working workplan version
--If its DERIVE then
----the etc cost will be derived based on the rate setup on p_as_of_date
----p_budget_version_id will contain the budget version id corresponding to the latest published
---- workplan version
procedure get_plan_costs_for_qty
(  p_etc_cost_calc_mode         IN        VARCHAR2 DEFAULT 'DERIVE'   --Bug 5027965
  ,p_resource_list_mem_id       IN    NUMBER
  ,p_project_id                 IN    NUMBER
  ,p_task_id            IN    NUMBER
  ,p_as_of_date         IN    DATE
  ,p_structure_version_id       IN    NUMBER
  ,p_txn_currency_code          IN    VARCHAR
  ,p_rate_based_flag            IN    VARCHAR := 'Y'
  ,p_quantity                   IN        NUMBER
  ,p_budget_version_id          IN        NUMBER -- Bug 4372462
  ,p_res_assignment_id          IN        NUMBER
  ,x_rawcost_tc                 OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_brdncost_tc                OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_rawcost_pc                 OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_brdncost_pc                OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_rawcost_fc                 OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_brdncost_fc                OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status      OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count          OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data           OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS
        x_res_brdn_mult_ovrate          NUMBER;
        x_res_raw_rate                  NUMBER;
        L_PLAN_RES_CUR_CODE             VARCHAR2(30);
        l_plan_res_burden_rate_etc      NUMBER           := null;
        l_plan_res_burden_rate_act      NUMBER           := null;

        l_plan_res_raw_rate         NUMBER           := null;

        l_plan_burden_multiplier_etc    NUMBER           := null;
        l_plan_burden_multiplier_act    NUMBER           := null;

    l_rawcost_pc            NUMBER       := null;
    l_rawcost_fc            NUMBER       := null;

    l_txn_currency_code     VARCHAR2(30)     := null;

    l_project_curr_code             VARCHAR2(30);
        l_project_rate_type             VARCHAR2(30);
        l_project_rate_date             DATE;
        l_project_exch_rate             NUMBER;

    l_projfunc_curr_code            VARCHAR2(30);
        l_projfunc_cost_rate_type       VARCHAR2(30);
        l_projfunc_cost_rate_date       DATE;
        l_projfunc_cost_exch_rate       NUMBER;

        g1_debug_mode               VARCHAR2(1);
    l_track_wp_cost_flag  VARCHAR2(1) := 'Y'; -- Bug 3921624


BEGIN

     g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
     x_return_status := 'S';

     IF g1_debug_mode  = 'Y' THEN

         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.get_plan_costs_for_qty', x_Msg => 'p_resource_list_mem_id='||p_resource_list_mem_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.get_plan_costs_for_qty', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.get_plan_costs_for_qty', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.get_plan_costs_for_qty', x_Msg => 'p_txn_currency_code='||p_txn_currency_code, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_UTILS.get_plan_costs_for_qty', x_Msg => 'p_rate_based_flag='||p_rate_based_flag, x_Log_Level=> 3);

     END IF;

   l_track_wp_cost_flag :=  pa_fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id);

   IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN   --Bug 3921624

     --Bug 5027965
     IF p_etc_cost_calc_mode='DERIVE' THEN

         -- 3.1). Get resource rate burden multiplier to convert etc_rawcost to etc_brdncost and resource burden rate to convert etc_effort to etc_brdncost in tc.

        l_plan_res_cur_code               := null;
        l_plan_res_raw_rate           := null;
        l_plan_burden_multiplier_etc      := null;
        l_plan_res_burden_rate_etc        := null;

        PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier(
                P_res_list_mem_id              => p_resource_list_mem_id
                ,P_project_id                  => p_project_id
                ,P_task_id                     => p_task_id      --bug 3927159
                ,p_as_of_date                  => p_as_of_date   --bug 3927159
                ,p_structure_version_id        => p_structure_version_id
                ,p_currency_code               => p_txn_currency_code
                ,p_calling_mode                => 'PLAN_RATES'
                ,x_resource_curr_code          => l_plan_res_cur_code
                ,x_resource_raw_rate           => l_plan_res_raw_rate
                ,x_resource_burden_rate        => l_plan_res_burden_rate_etc
                ,X_burden_multiplier           => l_plan_burden_multiplier_etc
                ,x_return_status               => x_return_status
                ,x_msg_count                   => x_msg_count
                ,x_msg_data                    => x_msg_data);
        x_res_raw_rate := l_plan_res_raw_rate;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

        -- 3.2). If the rate_based_flag is 'Y' and the resource burden rate currency code is not the same as the txn currency code, convert the resource burden rate into txn currency.
        -- to do this we use the API: PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS() and we pass in
        -- txn_currency code into the project_currency_code parameter and read out the value of
        -- the parameter project_raw_cost.

        IF ((p_rate_based_flag = 'Y') and (p_txn_currency_code <> l_plan_res_cur_code)) then
            l_rawcost_pc := null;
            l_txn_currency_code := p_txn_currency_code;

            PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
                p_project_id               =>  p_project_id
                ,p_task_id                  => p_task_id
                ,p_as_of_date               => p_as_of_date
                ,p_txn_cost                 => l_plan_res_burden_rate_etc
                ,p_txn_curr_code            => l_plan_res_cur_code
            ,p_structure_version_id     => p_structure_version_id
            ,p_project_curr_code        => l_txn_currency_code ---l_project_curr_code
                ,p_project_rate_type        => l_project_rate_type
                ,p_project_rate_date        => l_project_rate_date
                ,p_project_exch_rate        => l_project_exch_rate
                ,p_project_raw_cost         => l_rawcost_pc
            ,p_projfunc_curr_code       => l_projfunc_curr_code
                ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
                ,p_projfunc_raw_cost        => l_rawcost_fc
                ,x_return_status            => x_return_status
                ,x_msg_count                => x_msg_count
                ,x_msg_data                 => x_msg_data
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_plan_res_burden_rate_etc :=   l_rawcost_pc;
            if (l_plan_res_raw_rate <> l_plan_res_burden_rate_etc) then
                l_rawcost_pc := null;

                PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
                        p_project_id               =>  p_project_id
                        ,p_task_id                  => p_task_id
                        ,p_as_of_date               => p_as_of_date
                        ,p_txn_cost                 => l_plan_res_raw_rate
                        ,p_txn_curr_code            => l_plan_res_cur_code
                        ,p_structure_version_id     => p_structure_version_id
                        ,p_project_curr_code        => l_txn_currency_code ---l_project_curr_code
                        ,p_project_rate_type        => l_project_rate_type
                        ,p_project_rate_date        => l_project_rate_date
                        ,p_project_exch_rate        => l_project_exch_rate
                        ,p_project_raw_cost         => l_rawcost_pc
                        ,p_projfunc_curr_code       => l_projfunc_curr_code
                        ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                        ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                        ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
                        ,p_projfunc_raw_cost        => l_rawcost_fc
                        ,x_return_status            => x_return_status
                        ,x_msg_count                => x_msg_count
                        ,x_msg_data                 => x_msg_data
                        );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE  FND_API.G_EXC_ERROR;
                END IF;
                x_res_raw_rate := l_rawcost_pc;
            end if;
        END IF;
        if (p_rate_based_flag = 'N') then
           x_res_raw_rate := 1;
           x_res_brdn_mult_ovrate := l_plan_burden_multiplier_etc;
--           x_brdncost_tc := nvl(pa_currency.round_trans_currency_amt((nvl(p_quantity,0) * nvl(x_res_brdn_mult_ovrate,0)), p_txn_currency_code),0) + nvl(p_quantity,0);
             x_brdncost_tc := nvl(pa_currency.round_trans_currency_amt1((nvl(p_quantity,0) * nvl(x_res_brdn_mult_ovrate,0)), p_txn_currency_code),0) + nvl(p_quantity,0);
        else
           x_res_brdn_mult_ovrate := l_plan_res_burden_rate_etc;
           --x_brdncost_tc := nvl(pa_currency.round_trans_currency_amt((nvl(p_quantity,0) * nvl(x_res_brdn_mult_ovrate,0)), p_txn_currency_code),0);
         x_brdncost_tc := nvl(pa_currency.round_trans_currency_amt1((nvl(p_quantity,0) * nvl(x_res_brdn_mult_ovrate,0)), p_txn_currency_code),0);
        end if;
        --x_rawcost_tc := nvl(pa_currency.round_trans_currency_amt((nvl(p_quantity,0) * nvl(x_res_raw_rate,0)), p_txn_currency_code),0);
    x_rawcost_tc := nvl(pa_currency.round_trans_currency_amt1((nvl(p_quantity,0) * nvl(x_res_raw_rate,0)), p_txn_currency_code),0);

        -- convert all costs to proj curr and proj func curr

        PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
                        p_project_id               =>  p_project_id
                        ,p_task_id                  => p_task_id
                        ,p_as_of_date               => p_as_of_date
                        ,p_txn_cost                 => x_rawcost_tc
                        ,p_txn_curr_code            => p_txn_currency_code
                        ,p_structure_version_id     => p_structure_version_id
                        ,p_calling_mode             => 'PLAN_RATES' -- Bug 4372462
                        ,p_budget_version_id        => p_budget_version_id -- Bug 4372462
                        ,p_res_assignment_id        => p_res_assignment_id -- Bug 4372462
                        ,p_project_curr_code        => l_project_curr_code
                        ,p_project_rate_type        => l_project_rate_type
                        ,p_project_rate_date        => l_project_rate_date
                        ,p_project_exch_rate        => l_project_exch_rate
                        ,p_project_raw_cost         => l_rawcost_pc
                        ,p_projfunc_curr_code       => l_projfunc_curr_code
                        ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                        ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                        ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
                        ,p_projfunc_raw_cost        => l_rawcost_fc
                        ,x_return_status            => x_return_status
                        ,x_msg_count                => x_msg_count
                        ,x_msg_data                 => x_msg_data
                        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE  FND_API.G_EXC_ERROR;
        END IF;
        x_rawcost_pc := l_rawcost_pc;
        x_rawcost_fc := l_rawcost_fc;

        PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
                        p_project_id               =>  p_project_id
                        ,p_task_id                  => p_task_id
                        ,p_as_of_date               => p_as_of_date
                        ,p_txn_cost                 => x_brdncost_tc
                        ,p_txn_curr_code            => p_txn_currency_code
                        ,p_structure_version_id     => p_structure_version_id
                        ,p_calling_mode             => 'PLAN_RATES' -- Bug 4372462
                        ,p_budget_version_id        => p_budget_version_id -- Bug 4372462
                        ,p_res_assignment_id        => p_res_assignment_id -- Bug 4372462
                        ,p_project_curr_code        => l_project_curr_code
                        ,p_project_rate_type        => l_project_rate_type
                        ,p_project_rate_date        => l_project_rate_date
                        ,p_project_exch_rate        => l_project_exch_rate
                        ,p_project_raw_cost         => l_rawcost_pc
                        ,p_projfunc_curr_code       => l_projfunc_curr_code
                        ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                        ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                        ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
                        ,p_projfunc_raw_cost        => l_rawcost_fc
                        ,x_return_status            => x_return_status
                        ,x_msg_count                => x_msg_count
                        ,x_msg_data                 => x_msg_data
                        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE  FND_API.G_EXC_ERROR;
        END IF;
        x_brdncost_pc := l_rawcost_pc;
        x_brdncost_fc := l_rawcost_fc;
     --Bug 5027965
     ELSIF p_etc_cost_calc_mode='COPY' THEN

             SELECT NVL(SUM(NVL(pbl.txn_raw_cost,0)-NVL(pbl.txn_init_raw_cost,0)),0),
                    NVL(SUM(NVL(pbl.txn_burdened_cost,0)-NVL(pbl.txn_init_burdened_cost,0)),0),
                    NVL(SUM(NVL(pbl.project_raw_cost,0)-NVL(pbl.project_init_raw_cost,0)),0),
                    NVL(SUM(NVL(pbl.project_burdened_cost,0)-NVL(pbl.project_init_burdened_cost,0)),0),
                    NVL(SUM(NVL(pbl.raw_cost,0)-NVL(pbl.init_raw_cost,0)),0),
                    NVL(SUM(NVL(pbl.burdened_cost,0)-NVL(pbl.init_burdened_cost,0)),0)
             INTO   x_rawcost_tc,
                    x_brdncost_tc,
                    x_rawcost_pc,
                    x_brdncost_pc,
                    x_rawcost_fc,
                    x_brdncost_fc
             FROM   pa_budget_lines pbl,
                    pa_resource_assignments pra
             WHERE  pra.budget_version_id=p_budget_version_id
             AND    pra.project_id=p_project_id
             AND    pra.task_id=p_task_id
             AND    pra.resource_list_member_id=p_resource_list_mem_id
             AND    pbl.resource_assignment_id=pra.resource_assignment_id
             AND    pbl.txn_currency_code=p_txn_currency_code;

     END IF;
   END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := Fnd_Msg_Pub.count_msg;

      -- 4537865

        x_rawcost_tc       := NULL ;
    x_brdncost_tc      := NULL ;
    x_rawcost_pc       := NULL ;
    x_brdncost_pc      := NULL ;
    x_rawcost_fc       := NULL ;
    x_brdncost_fc      := NULL ;

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SUBSTRB(SQLERRM,1,240);

      -- 4537865
        x_rawcost_tc       := NULL ;
    x_brdncost_tc      := NULL ;
    x_rawcost_pc       := NULL ;
    x_brdncost_pc      := NULL ;
    x_rawcost_fc       := NULL ;
    x_brdncost_fc      := NULL ;
    RAISE;
END get_plan_costs_for_qty;

/* Begin Fix for Bug # 4108270.*/

FUNCTION get_pc_from_sub_tasks_assgn
(p_project_id           NUMBER
,p_proj_element_id      NUMBER
,p_structure_version_id     NUMBER
,p_include_sub_tasks_flag   VARCHAR2 := 'Y'
,p_structure_type       VARCHAR2 := 'WORKPLAN'
,p_object_type          VARCHAR2 := 'PA_TASKS'
,p_as_of_date           DATE := null
,p_program_flag                 VARCHAR2 := 'Y' -- 4392189 : Program Reporting Changes - Phase 2
)
RETURN NUMBER
IS

   CURSOR cur_assgn( c_task_ver_id NUMBER, c_task_per_comp_deriv_method VARCHAR2
                     , c_published_structure VARCHAR2, c_wp_rollup_method VARCHAR2
                     , c_as_of_date DATE, c_structure_type VARCHAR2
                     , c_structure_version_id NUMBER)
   IS
   SELECT asgn.resource_assignment_id resource_assignment_id
        , asgn.task_version_id task_version_id
        , 'PA_ASSIGNMENTS' object_type
        , asgn.resource_class_code resource_class_code
        , asgn.rate_based_flag rate_based_flag
        , decode(asgn.rate_based_flag,'Y','EFFORT','N','COST') assignment_type
    , ppr.PPL_ACT_EFFORT_TO_DATE + ppr.EQPMT_ACT_EFFORT_TO_DATE total_act_effort_to_date
    , ppr.EQPMT_ETC_EFFORT + ppr.estimated_remaining_effort total_etc_effort
    , ppr.OTH_ACT_COST_TO_DATE_TC + ppr.PPL_ACT_COST_TO_DATE_TC + ppr.EQPMT_ACT_COST_TO_DATE_TC total_act_cost_to_date_tc
        , ppr.OTH_ACT_COST_TO_DATE_PC + ppr.PPL_ACT_COST_TO_DATE_PC + ppr.EQPMT_ACT_COST_TO_DATE_PC total_act_cost_to_date_pc
        , ppr.OTH_ACT_COST_TO_DATE_FC + ppr.PPL_ACT_COST_TO_DATE_FC + ppr.EQPMT_ACT_COST_TO_DATE_FC total_act_cost_to_date_fc
        , ppr.OTH_ETC_COST_TC + ppr.PPL_ETC_COST_TC + ppr.EQPMT_ETC_COST_TC total_etc_cost_tc
        , ppr.OTH_ETC_COST_PC + ppr.PPL_ETC_COST_PC + ppr.EQPMT_ETC_COST_PC total_etc_cost_pc
        , ppr.OTH_ETC_COST_FC + ppr.PPL_ETC_COST_FC + ppr.EQPMT_ETC_COST_FC total_etc_cost_fc

    , decode(c_task_per_comp_deriv_method,'EFFORT'
                , ( nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0)
                     + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0))
                , ( nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0)
                     + nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0)
                     + nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0))) earned_value
        , decode(c_wp_rollup_method, 'COST'
                 , nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0)
                   + nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0)
                               + nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0)
                   + nvl(ppr.OTH_ETC_COST_PC,0)
                   + nvl(ppr.PPL_ETC_COST_PC,0)
                           + nvl(ppr.EQPMT_ETC_COST_PC,0)
                 , 'EFFORT'
                 , decode(rate_based_flag,'N', 0,
                         nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0)
                         + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)
                         + nvl(ppr.EQPMT_ETC_EFFORT,0)
                         + nvl(ppr.estimated_remaining_effort,0)), 0) bac_value_in_rollup_method
        , decode(c_task_per_comp_deriv_method,'EFFORT'
                 , ( NVL( decode( asgn.rate_based_flag, 'Y',
                                  decode( asgn.resource_class_code,
                                         'PEOPLE', nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0)
                               + nvl(ppr.estimated_remaining_effort,
                                                   decode(sign(nvl(asgn.planned_quantity,0)
                                    -nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0)), -1, 0,
                                                 nvl( asgn.planned_quantity-ppr.PPL_ACT_EFFORT_TO_DATE,0))),
                                          'EQUIPMENT', nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)
                               + nvl(ppr.EQPMT_ETC_EFFORT,
                                                     decode(sign(nvl(asgn.planned_quantity,0)
                                 -nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)), -1, 0,
                                                 nvl( asgn.planned_quantity-ppr.EQPMT_ACT_EFFORT_TO_DATE,0)))),0),0)
                                   ),
                                 ( NVL( decode( asgn.resource_class_code,
                                       'FINANCIAL_ELEMENTS',
                                         nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,
                                            decode(sign(nvl(asgn.planned_bur_cost_proj_cur,0)
                            -nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                 nvl(asgn.planned_bur_cost_proj_cur-ppr.OTH_ACT_COST_TO_DATE_PC,0))),
                                       'MATERIAL_ITEMS',
                                         nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,
                                            decode(sign(nvl(asgn.planned_bur_cost_proj_cur,0)
                           -nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                 nvl( asgn.planned_bur_cost_proj_cur-ppr.OTH_ACT_COST_TO_DATE_PC,0))),
                                       'PEOPLE',
                                        nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ETC_COST_PC,
                                         decode(sign(nvl(asgn.planned_bur_cost_proj_cur,0)
                        -nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                nvl(asgn.planned_bur_cost_proj_cur-ppr.PPL_ACT_COST_TO_DATE_PC,0))),
                                       'EQUIPMENT',
                                        nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ETC_COST_PC,
                                         decode(sign(nvl(asgn.planned_bur_cost_proj_cur,0)
                        -nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                nvl(asgn.planned_bur_cost_proj_cur-ppr.EQPMT_ACT_COST_TO_DATE_PC,0)))),
                                    nvl(asgn.planned_bur_cost_proj_cur,0)
                                    ))) bac_value_in_task_deriv
   FROM
           pa_task_asgmts_v  asgn
           , pa_progress_rollup ppr
   WHERE asgn.task_version_id = c_task_ver_id
         AND asgn.project_id = p_project_id  ---4871809
         AND asgn.task_id = p_proj_element_id
         AND asgn.ta_display_flag = 'Y'
         AND asgn.project_id = ppr.project_id
         AND asgn.RESOURCE_LIST_MEMBER_ID = ppr.object_id
         AND asgn.task_id = ppr.proj_element_id
         AND ppr.object_type = 'PA_ASSIGNMENTS'
         AND ppr.as_of_date = pa_progress_utils.get_max_rollup_asofdate(asgn.project_id
                       ,asgn.RESOURCE_LIST_MEMBER_ID, 'PA_ASSIGNMENTS'
                       ,c_as_of_date,asgn.task_version_id, c_structure_type
                       , decode(c_published_structure, 'Y', null, c_structure_version_id), asgn.task_id)
         AND ppr.current_flag <> 'W'
         AND ppr.structure_type = c_structure_type
         AND ((c_published_structure = 'Y' AND ppr.structure_version_id is null)
               OR (c_published_structure = 'N'
                   AND ppr.structure_version_id = c_structure_version_id))
   UNION ALL
   SELECT asgn.resource_assignment_id resource_assignment_id
          , asgn.task_version_id task_version_id
          , 'PA_ASSIGNMENTS' object_type
          , asgn.resource_class_code resource_class_code
          , asgn.rate_based_flag rate_based_flag
          , decode(asgn.rate_based_flag,'Y','EFFORT','N','COST') assignment_type
          , to_number(null) total_act_effort_to_date
          , to_number(null) total_etc_effort
          , to_number(null) total_act_cost_to_date_tc
          , to_number(null) total_act_cost_to_date_pc
          , to_number(null) total_act_cost_to_date_fc
          , to_number(null) total_etc_cost_tc
          , to_number(null) total_etc_cost_pc
          , to_number(null) total_etc_cost_fc
          , to_number(null) earned_value
          , to_number(null) bac_value_in_rollup_method
          , decode(c_task_per_comp_deriv_method,'EFFORT',
                   decode(asgn.rate_based_flag,'Y',
                          decode(asgn.resource_class_code,'PEOPLE'
                                 , asgn.planned_quantity, 'EQUIPMENT'
                             , asgn.planned_quantity, 0),0)
                                ,asgn.planned_bur_cost_proj_cur) bac_value_in_task_deriv
    FROM
          pa_task_asgmts_v  asgn
    WHERE asgn.task_version_id = c_task_ver_id
          AND  asgn.project_id = p_project_id  ---4871809
          AND  asgn.task_id = p_proj_element_id
          AND  pa_progress_utils.get_max_rollup_asofdate(asgn.project_id
                                        , asgn.RESOURCE_LIST_MEMBER_ID
                                , 'PA_ASSIGNMENTS',c_as_of_date
                                ,asgn.task_version_id
                                , c_structure_type
                                , decode(c_published_structure, 'Y', null
                                 , c_structure_version_id)
                            , asgn.task_id) IS NULL
          AND asgn.ta_display_flag = 'Y';

   CURSOR cur_check_published_version(c_structure_version_id NUMBER, c_project_id NUMBER)
   IS
   SELECT decode(status.project_system_status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N')
   FROM pa_proj_elem_ver_structure str
   , pa_project_statuses status
   where str.element_version_id = c_structure_version_id
   AND str.project_id = c_project_id
   AND str.status_code = status.project_status_code;

   CURSOR cur_max_as_of_date_leq(c_project_id NUMBER, c_object_id NUMBER
                     , c_object_type VARCHAR2
                 , c_structure_type VARCHAR2
                 , c_published_structure VARCHAR2
                 , c_structure_version_id NUMBER
                 , c_as_of_date DATE)
   IS
   SELECT max(as_of_date)
   FROM pa_progress_rollup
   WHERE project_id = c_project_id
   AND object_id = c_object_id
   AND object_type = c_object_type
   AND structure_type = c_structure_type
   AND ((c_published_structure = 'Y' AND structure_version_id is null)
         OR (c_published_structure = 'N'
             AND structure_version_id = c_structure_version_id)
         OR (c_structure_type = 'FINANCIAL' AND structure_version_id is null)    /* Bug#6485646 */
        )
   AND current_flag <> 'W'
   AND as_of_date <= c_as_of_date;

   CURSOR cur_max_as_of_date(c_project_id NUMBER, c_object_id NUMBER
                             , c_object_type VARCHAR2, c_structure_type VARCHAR2
                             , c_published_structure VARCHAR2
                             , c_structure_version_id NUMBER)
   IS
   SELECT max(as_of_date)
   FROM pa_progress_rollup ppr, pa_proj_element_versions ppev -- Bug # 4658185.
   WHERE ppr.project_id = c_project_id
   AND ppr.object_id = c_object_id
   AND ppr.object_type = c_object_type
   AND ppr.structure_type = c_structure_type
   AND ppr.project_id = ppev.project_id  -- Bug # 4658185.
   AND ppr.object_id = ppev.proj_element_id  -- Bug # 4658185.
   AND ppr.object_version_id = ppev.element_version_id  -- Bug # 4658185.
   AND ppev.parent_structure_version_id = c_structure_version_id  -- Bug # 4658185.
   AND ((c_published_structure = 'Y' AND ppr.structure_version_id is null)
             OR (c_published_structure = 'N'
                     AND ppr.structure_version_id = c_structure_version_id))
   AND ppr.current_flag <> 'W';


    CURSOR cur_percent_comp(c_project_id NUMBER, c_object_id NUMBER
                , c_object_type VARCHAR2, c_structure_type VARCHAR2
                , c_as_of_date DATE, c_published_structure VARCHAR2
                , c_structure_version_id NUMBER
                , c_program_flag VARCHAR2 -- 4392189 : Program Reporting Changes - Phase 2
                )
    IS
    SELECT nvl(ppr.completed_percentage,decode(nvl(c_program_flag,'Y'),'Y', ppr.eff_rollup_percent_comp, ppr.base_percent_complete))
    -- 4392189 : Program Reporting Changes - Phase 2 : Added Decode above
    FROM pa_progress_rollup ppr
    WHERE ppr.project_id = c_project_id
    and ppr.object_id = c_object_id
    and ppr.object_type = c_object_type
    and ppr.structure_type = c_structure_type
    and ((c_published_structure = 'Y' AND structure_version_id is null)
         OR (c_published_structure = 'N'
             AND structure_version_id = c_structure_version_id)
         OR (c_structure_type = 'FINANCIAL' AND structure_version_id is null)    /* Bug#6485646 */
             )
    and current_flag <> 'W'
    and ppr.as_of_date = c_as_of_date;

    CURSOR cur_base_pc_deriv_code(c_task_id NUMBER, c_project_id NUMBER
                      , c_object_type VARCHAR2)
    IS
    SELECT decode(elem.base_percent_comp_deriv_code, null
                  , ttype.base_percent_comp_deriv_code,'^'
                  ,ttype.base_percent_comp_deriv_code,elem.base_percent_comp_deriv_code)
    FROM pa_proj_elements elem
         , pa_task_types ttype
    where elem.proj_element_id = c_task_id
    AND elem.project_id = c_project_id
    AND elem.object_type =c_object_type
    AND elem.type_id = ttype.task_type_id;

    CURSOR cur_progress_rollup_method(c_project_id NUMBER, c_task_id NUMBER
                      , c_structure_type VARCHAR2
                      , c_object_type VARCHAR2)
    IS
    SELECT task_weight_basis_code
    from pa_proj_progress_attr pppa
    where pppa.project_id = c_project_id
    AND pppa.object_id = c_task_id
    AND pppa.structure_type = c_structure_type
    and pppa.object_type = c_object_type;

    l_return_pc                  NUMBER := null;
    l_act_cost               NUMBER := null;
    l_act_effort                 NUMBER := null;
    l_bac_value_in_rollup_method         NUMBER := null;
    l_task_per_comp_deriv_method         VARCHAR2(30) := null;
    l_progress_rollup_method         VARCHAR2(30) := null;

    l_published_structure            VARCHAR2(1) := null;
    l_as_of_date                 DATE := null;

BEGIN

     -- 1). Determine if the input structure_version_id corresponds to a published
     --     structure version or not.

    OPEN cur_check_published_version(p_structure_version_id, p_project_id);
        FETCH cur_check_published_version INTO l_published_structure;
        CLOSE cur_check_published_version;

     -- 2.1). If the input structure_type is 'FINANCIAL' and input as_of_date is not null
     --       then use the max as_of_date in the pa_progress_rollup_table less than or equal to
     --       the input as_of_date.

     if ((p_structure_type = 'FINANCIAL') and (p_as_of_date is not null)) then

        open cur_max_as_of_date_leq(p_project_id, p_proj_element_id, p_object_type
                            , p_structure_type, l_published_structure
                                , p_structure_version_id, p_as_of_date);
        fetch cur_max_as_of_date_leq into l_as_of_date;
        close cur_max_as_of_date_leq;

     -- 2.2). Else use the latest as_of_date in the pa_progress_rollup table for the
     --   given task or structure.

     else

        open cur_max_as_of_date(p_project_id, p_proj_element_id, p_object_type
                            , p_structure_type, l_published_structure
                            , p_structure_version_id);
        fetch cur_max_as_of_date into l_as_of_date;
        close cur_max_as_of_date;

     end if;

     -- 3.1). If the p_include_sub_tasks_flag = 'Y' or if the input proj_element_id
     --       is a structure_id then return the rolled-up percent complete for the task
     --       from the pa_progress_rollup table for the above determined as_of_date.

     if ((p_include_sub_tasks_flag = 'Y') or (p_object_type = 'PA_STRUCTURES')) then

        open cur_percent_comp(p_project_id, p_proj_element_id, p_object_type
                          , p_structure_type, l_as_of_date, l_published_structure
                          , p_structure_version_id
                          , p_program_flag) ; -- 4392189 : Program Reporting Changes - Phase 2
        fetch cur_percent_comp into l_return_pc;
        close cur_percent_comp;

     -- 3.2). If the p_include_sub_tasks_flag = 'N' then return the rolled-up
     --       percent complete from all the assignments directly associated with
     --       the task.

     else

         open cur_base_pc_deriv_code(p_proj_element_id, p_project_id, p_object_type);
         fetch cur_base_pc_deriv_code into l_task_per_comp_deriv_method;
         close cur_base_pc_deriv_code;

         open cur_progress_rollup_method(p_project_id, p_proj_element_id
                         , p_structure_type, p_object_type);
         fetch cur_progress_rollup_method into l_progress_rollup_method;
         close cur_progress_rollup_method;

         for cur_assgn_rec in cur_assgn(p_proj_element_id
                        , l_task_per_comp_deriv_method
                        , l_published_structure
                        , l_progress_rollup_method
                        , l_as_of_date
                        , p_structure_type
                        , p_structure_version_id)
         loop

             l_act_cost := (l_act_cost +  cur_assgn_rec.total_act_cost_to_date_pc);
             l_act_effort := (l_act_effort + cur_assgn_rec.total_act_effort_to_date);
             l_bac_value_in_rollup_method := (l_bac_value_in_rollup_method
                                  + cur_assgn_rec.bac_value_in_rollup_method);

         end loop;

         if (nvl(l_progress_rollup_method, 'COST') = 'EFFORT') then

            l_return_pc := (l_act_effort / l_bac_value_in_rollup_method);

         else

            l_return_pc := (l_act_cost / l_bac_value_in_rollup_method);

         end if;

     end if;

     -- Return the calculated value of percent complete.

     return(l_return_pc);

END get_pc_from_sub_tasks_assgn;

/* End Fix for Bug # 4108270.*/


/* Begin fix for Bug # 4185974. */

FUNCTION get_act_for_prev_asofdate (p_as_of_date         IN     DATE
                                ,p_project_id        IN     NUMBER
                                ,p_object_id         IN     NUMBER
                                ,p_object_version_id IN     NUMBER
                    ,p_proj_element_id   IN     NUMBER := null
                    ,p_effort_cost_flag  IN VARCHAR2 := 'C'
                    ,p_cost_type_flag    IN VARCHAR2 := 'B'
                    ,p_currency_flag     IN VARCHAR2 := 'T') return NUMBER
IS

    l_act_for_prev_asofdate     NUMBER := NULL;

        -- Begin fix for Bug # 4185974.

        cursor cur_proj_sharing_code is
                select structure_sharing_Code
                from pa_projects_all
                where project_id=p_project_id;

        l_project_sharing_code          VARCHAR2(150);

        l_as_of_date                    DATE;

        -- End fix for Bug # 4185974.

    cursor cur_effort is
         select (nvl(ppr.ppl_act_effort_to_date,0)
             +nvl(ppr.eqpmt_act_effort_to_date,0)
             +nvl(ppr.subprj_ppl_act_effort,0)
             +nvl(ppr.subprj_eqpmt_act_effort,0)
             +nvl(ppr.oth_quantity_to_date,0)) act_effort_prev_asofdate
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.structure_type = 'WORKPLAN'
        and ppr.proj_element_id = p_proj_element_id
        and ppr.structure_version_id is null
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                      from pa_progress_rollup ppr2
                                      where ppr2.project_id = p_project_id
                                      and ppr2.object_id = p_object_id
                      and ppr2.structure_type = 'WORKPLAN'
                      and ppr2.proj_element_id = p_proj_element_id
                      and ppr2.structure_version_id is null
                      and ppr2.current_flag <> 'W' -- Fix for Bug # 4249286.
                                   -- Fix for Bug # 4185974.
                      and ppr2.as_of_date < l_as_of_date); -- Fix for Bug # 4185974.
                                      -- and ppr2.as_of_date < pa_progress_utils.get_prog_asofdate()+1);
                                        -- Fix for Bug # 4222702.
                                        -- Fix for Bug # 4185974.

--- adding 1 in pa_progress_utils.get_prog_asofdate so that it works fine for shared structures
    cursor cur_bur_cost_tc is
        select (nvl(ppr.oth_act_cost_to_date_tc,0)
            +nvl(ppr.ppl_act_cost_to_date_tc,0)
                        +nvl(ppr.eqpmt_act_cost_to_date_tc,0)
            +nvl(ppr.subprj_oth_act_cost_to_date_tc,0)
                        +nvl(ppr.subprj_ppl_act_cost_tc,0)
            +nvl(ppr.subprj_eqpmt_act_cost_tc,0)) act_bur_cost_tc_prev_asofdate
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.structure_type = 'WORKPLAN'
        and ppr.proj_element_id = p_proj_element_id
        and ppr.structure_version_id is null
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                      from pa_progress_rollup ppr2
                                      where ppr2.project_id = p_project_id
                                      and ppr2.object_id = p_object_id
                      and ppr2.structure_type = 'WORKPLAN'
                      and ppr2.proj_element_id = p_proj_element_id
                      and ppr2.structure_version_id is null
                      and ppr2.current_flag <> 'W' -- Fix for Bug # 4249286.
                                  -- Fix for Bug # 4185974.
                      and ppr2.as_of_date < l_as_of_date); -- Fix for Bug # 4185974.
                                      -- and ppr2.as_of_date < pa_progress_utils.get_prog_asofdate()+1);
                                        -- Fix for Bug # 4222702.
                                        -- Fix for Bug # 4185974.
        cursor cur_bur_cost_pc is
                 select (nvl(ppr.oth_act_cost_to_date_pc,0)
             +nvl(ppr.ppl_act_cost_to_date_pc,0)
                         +nvl(ppr.eqpmt_act_cost_to_date_pc,0)
             +nvl(ppr.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppr.subprj_ppl_act_cost_pc,0)
             +nvl(ppr.subprj_eqpmt_act_cost_pc,0)) act_bur_cost_pc_prev_asofdate
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.structure_type = 'WORKPLAN'
                and ppr.proj_element_id = p_proj_element_id
                and ppr.structure_version_id is null
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                      from pa_progress_rollup ppr2
                                      where ppr2.project_id = p_project_id
                                      and ppr2.object_id = p_object_id
                                      and ppr2.structure_type = 'WORKPLAN'
                                      and ppr2.proj_element_id = p_proj_element_id
                                      and ppr2.structure_version_id is null
                      and ppr2.current_flag <> 'W' -- Fix for Bug # 4249286.
                                   -- Fix for Bug # 4185974.
                      and ppr2.as_of_date < l_as_of_date); -- Fix for Bug # 4185974.
                                      -- and ppr2.as_of_date < pa_progress_utils.get_prog_asofdate()+1);
                                        -- Fix for Bug # 4222702.
                                        -- Fix for Bug # 4185974.

        cursor cur_raw_cost_tc is
         select (nvl(ppr.oth_act_rawcost_to_date_tc,0)
             +nvl(ppr.ppl_act_rawcost_to_date_tc,0)
                         +nvl(ppr.eqpmt_act_rawcost_to_date_tc,0)
             +nvl(ppr.spj_oth_act_rawcost_to_date_tc,0)
                         +nvl(ppr.subprj_ppl_act_rawcost_tc,0)
             +nvl(ppr.subprj_eqpmt_act_rawcost_tc,0)) act_raw_cost_tc_prev_asofdate
                from pa_progress_rollup ppr
                where ppr.project_id = p_project_id
                and ppr.object_id = p_object_id
                and ppr.structure_type = 'WORKPLAN'
                and ppr.proj_element_id = p_proj_element_id
                and ppr.structure_version_id is null
                and ppr.as_of_date = (select max(ppr2.as_of_date)
                                      from pa_progress_rollup ppr2
                                      where ppr2.project_id = p_project_id
                                      and ppr2.object_id = p_object_id
                                      and ppr2.structure_type = 'WORKPLAN'
                                      and ppr2.proj_element_id = p_proj_element_id
                                      and ppr2.structure_version_id is null
                      and ppr2.current_flag <> 'W' -- Fix for Bug # 4249286.
                                  -- Fix for Bug # 4185974.
                      and ppr2.as_of_date < l_as_of_date); -- Fix for Bug # 4185974.
                                      -- and ppr2.as_of_date < pa_progress_utils.get_prog_asofdate()+1);
                                        -- Fix for Bug # 4222702.
                                        -- Fix for Bug # 4185974.

BEGIN

    -- Begin fix for Bug # 4185974.

         l_as_of_date := pa_progress_utils.get_prog_asofdate();

         open cur_proj_sharing_code;

         fetch cur_proj_sharing_code into l_project_sharing_code;

         close cur_proj_sharing_code;

         if (nvl(l_project_sharing_Code,'X') = 'SHARE_FULL') then

            l_as_of_date := l_as_of_date + 1;

         end if;

    -- End fix for Bug # 4185974.

     if (p_effort_cost_flag = 'E') then

        open cur_effort;
        fetch cur_effort into l_act_for_prev_asofdate;
        close cur_effort;

     else

        if ((p_cost_type_flag  = 'B') and (p_currency_flag  = 'T'))  then

            open cur_bur_cost_tc;
            fetch cur_bur_cost_tc into l_act_for_prev_asofdate;
            close cur_bur_cost_tc;

        elsif ((p_cost_type_flag  = 'B') and (p_currency_flag  = 'P'))  then

                        open cur_bur_cost_pc;
                        fetch cur_bur_cost_pc into l_act_for_prev_asofdate;
                        close cur_bur_cost_pc;

        elsif ((p_cost_type_flag  = 'R') and (p_currency_flag  = 'T'))  then

                        open cur_raw_cost_tc;
                        fetch cur_raw_cost_tc into l_act_for_prev_asofdate;
                        close cur_raw_cost_tc;

        end if;

    end if;


    l_act_for_prev_asofdate := nvl(l_act_for_prev_asofdate,0);

/*      4378391  -ive act is allowed
        if (l_act_for_prev_asofdate < 0 ) then

        l_act_for_prev_asofdate := 0;

    end if; */

    return(l_act_for_prev_asofdate);

END get_act_for_prev_asofdate;

/* End fix for Bug # 4185974. */


-- Begin fix for Bug # 4319171.

function calc_act(p_ppl_cost_eff        IN NUMBER := null
                  , p_eqpmt_cost_eff        IN NUMBER := null
                  , p_oth_cost_eff      IN NUMBER := null
                  , p_subprj_ppl_cost_eff   IN NUMBER := null
          , p_subprj_eqpmt_cost_eff     IN NUMBER := null
          , p_subprj_oth_cost_eff   IN NUMBER := null) return NUMBER
is

    l_calc_act NUMBER := null;

begin

    if ((p_ppl_cost_eff is null)
            and (p_eqpmt_cost_eff is null)
            and (p_oth_cost_eff is null)
        and (p_subprj_ppl_cost_eff is null)
            and (p_subprj_eqpmt_cost_eff is null)
            and (p_subprj_oth_cost_eff is null)) then

        l_calc_act := null;

    else

        l_calc_act := (nvl(p_ppl_cost_eff,0)
                           + nvl(p_eqpmt_cost_eff,0)
                           + nvl(p_oth_cost_eff,0)
                           + nvl(p_subprj_ppl_cost_eff,0)
                           + nvl(p_subprj_eqpmt_cost_eff,0)
                           + nvl(p_subprj_oth_cost_eff,0));

    end if;

    return(l_calc_act);

end calc_act;

function calc_etc(p_planned_cost_eff        IN NUMBER := null
          , p_ppl_cost_eff              IN NUMBER := null
                  , p_eqpmt_cost_eff            IN NUMBER := null
                  , p_oth_cost_eff              IN NUMBER := null
                  , p_subprj_ppl_cost_eff       IN NUMBER := null
                  , p_subprj_eqpmt_cost_eff     IN NUMBER := null
                  , p_subprj_oth_cost_eff       IN NUMBER := null
                  , p_oth_quantity              IN NUMBER := null
          , p_act_cost_eff      IN NUMBER := null) return NUMBER
is

        l_calc_etc NUMBER := null;

begin

        if ((p_ppl_cost_eff is null)
            and (p_eqpmt_cost_eff is null)
            and (p_oth_cost_eff is null)
            and (p_subprj_ppl_cost_eff is null)
            and (p_subprj_eqpmt_cost_eff is null)
            and (p_subprj_oth_cost_eff is null)
        and (p_oth_quantity is null)) then


        if ((p_planned_cost_eff is null)
            and (p_act_cost_eff is null)) then

            l_calc_etc := null;

        elsif (p_act_cost_eff is null) then

            l_calc_etc := p_planned_cost_eff;

        elsif (p_planned_cost_eff is null) then


            l_calc_etc := 0;


        else

            ---5726773        l_calc_etc := (nvl(p_planned_cost_eff,0) - nvl(p_act_cost_eff,0));
 	    l_calc_etc := PA_FP_FCST_GEN_AMT_UTILS.get_etc_from_plan_act(nvl(p_planned_cost_eff,0), nvl(p_act_cost_eff,0));

        end if;

        else

                l_calc_etc := (nvl(p_ppl_cost_eff,0)
                               + nvl(p_eqpmt_cost_eff,0)
                               + nvl(p_oth_cost_eff,0)
                               + nvl(p_subprj_ppl_cost_eff,0)
                               + nvl(p_subprj_eqpmt_cost_eff,0)
                               + nvl(p_subprj_oth_cost_eff,0)
                   + nvl(p_oth_quantity,0));

    end if;

/* 5726773
    if (l_calc_etc < 0) then

        l_calc_etc := 0;

    end if;
*/

    return(l_calc_etc);

end calc_etc;

function calc_wetc(p_planned_cost_eff           IN NUMBER := null
                  , p_ppl_cost_eff              IN NUMBER := null
                  , p_eqpmt_cost_eff            IN NUMBER := null
                  , p_oth_cost_eff              IN NUMBER := null
                  , p_subprj_ppl_cost_eff       IN NUMBER := null
                  , p_subprj_eqpmt_cost_eff     IN NUMBER := null
                  , p_subprj_oth_cost_eff       IN NUMBER := null
                  , p_oth_quantity              IN NUMBER := null) return NUMBER
is

        l_calc_wetc NUMBER := null;

begin

        if ((p_planned_cost_eff is null)
        and (p_ppl_cost_eff is null)
            and (p_eqpmt_cost_eff is null)
            and (p_oth_cost_eff is null)
            and (p_subprj_ppl_cost_eff is null)
            and (p_subprj_eqpmt_cost_eff is null)
            and (p_subprj_oth_cost_eff is null)
            and (p_oth_quantity is null)) then

        l_calc_wetc := null;

    else

        l_calc_wetc := nvl(p_planned_cost_eff,0) - (nvl(p_ppl_cost_eff,0)
                                                + nvl(p_eqpmt_cost_eff,0)
                                                + nvl(p_oth_cost_eff,0)
                                                + nvl(p_subprj_ppl_cost_eff,0)
                                                + nvl(p_subprj_eqpmt_cost_eff,0)
                                                + nvl(p_subprj_oth_cost_eff,0)
                                                + nvl(p_oth_quantity,0));

    end if;

        if (l_calc_wetc < 0) then

                l_calc_wetc := 0;

        end if;

        return(l_calc_wetc);

end calc_wetc;

function calc_plan(p_ppl_cost_eff                IN NUMBER := null
                   , p_eqpmt_cost_eff            IN NUMBER := null
                   , p_oth_cost_eff              IN NUMBER := null) return NUMBER

is

        l_calc_plan NUMBER := null;

begin

        if ((p_ppl_cost_eff is null)
            and (p_eqpmt_cost_eff is null)
            and (p_oth_cost_eff is null)) then

                l_calc_plan := null;

        else

                l_calc_plan := (nvl(p_ppl_cost_eff,0)
                               + nvl(p_eqpmt_cost_eff,0)
                               + nvl(p_oth_cost_eff,0));

        end if;

        return(l_calc_plan);

end calc_plan;

-- End fix for Bug # 4319171.

-- Bug 4490532 Begin
function get_self_amounts(p_amount_type         IN VARCHAR2
                   , p_structure_sharing_code   IN VARCHAR2
                   , p_prg_group                IN NUMBER
           , p_project_id       IN NUMBER
           , p_object_version_id    IN NUMBER
           , p_proj_element_id      IN NUMBER
           , p_as_of_date       IN DATE
           , p_current_flag     IN VARCHAR2
           , p_record_version_number    IN NUMBER
           ) return NUMBER
IS


CURSOR c_get_assgn_prog_rec IS
-- 4573486 Just consider ppl amounts, not eqp
--select nvl(ppl_act_effort_to_date,0)+nvl(eqpmt_act_effort_to_date,0) asgn_act_eff
--  ,nvl(ppl_act_cost_to_date_pc,0)+nvl(eqpmt_act_cost_to_date_pc,0)+nvl(oth_act_cost_to_date_pc,0) asgn_act_cost
--  ,nvl(estimated_remaining_effort,0)+nvl(eqpmt_etc_effort,0) asgn_etc_eff
--  ,nvl(ppl_etc_cost_pc,0)+nvl(eqpmt_etc_cost_pc,0)+nvl(oth_etc_cost_pc,0) agn_etc_cost
select nvl(ppl_act_effort_to_date,0) asgn_act_eff
    ,nvl(ppl_act_cost_to_date_pc,0) asgn_act_cost
    ,nvl(estimated_remaining_effort,0) asgn_etc_eff
    ,nvl(ppl_etc_cost_pc,0) agn_etc_cost
from pa_progress_rollup ppr
where ppr.project_id = p_project_id
and ppr.proj_element_id = p_proj_element_id
and ppr.structure_type = 'WORKPLAN'
and ppr.structure_version_id is null
and ppr.object_type = 'PA_ASSIGNMENTS'
and ppr.current_flag = p_current_flag
and ppr.as_of_date = p_as_of_date;

l_actual_effort NUMBER;
l_actual_cost NUMBER;
l_etc_effort NUMBER;
l_etc_cost NUMBER;
l_need_fetch VARCHAR2(1):='N';

BEGIN
    IF p_prg_group is NULL THEN
        return to_number(null);
    END IF;
    IF g_self_project_id IS NOT NULL THEN
        IF g_self_project_id = p_project_id AND g_self_object_version_id = p_object_version_id
           AND g_self_as_of_date = p_as_of_date AND g_self_current_flag = p_current_flag
           AND g_self_rec_version_number = p_record_version_number
        THEN
            l_actual_effort := g_self_act_effort;
            l_actual_cost := g_self_act_cost;
            l_etc_effort := g_self_etc_effort;
            l_etc_cost := g_self_etc_cost;
  	    -- 4591308 : Added code below
	    -- This is a temporary solution, ideally We should include progress_rollup_id also to this
	    -- function and it should be passed from the veiws patvw018.sql and patvw007.sql.
	    IF  p_amount_type = 'ACT_COST' THEN
		l_need_fetch := 'Y';
	    END IF;
        ELSE
            l_need_fetch := 'Y';
        END IF;
    ELSE
        l_need_fetch := 'Y';
    END IF;

    IF l_need_fetch = 'Y' THEN

        IF PA_PROGRESS_UTILS.check_assignment_exists(p_project_id, p_object_version_id, 'PA_TASKS') = 'Y' THEN
            l_actual_effort := null;
            l_actual_cost := null;
            l_etc_effort := null;
            l_etc_cost := null;
        ELSE
            OPEN c_get_assgn_prog_rec;
            FETCH c_get_assgn_prog_rec INTO l_actual_effort, l_actual_cost, l_etc_effort, l_etc_cost;
            CLOSE c_get_assgn_prog_rec;
            IF p_structure_sharing_code = 'SHARE_FULL' THEN
                l_actual_effort := null;
                l_actual_cost := null;
            END IF;
        END IF;

        g_self_project_id := p_project_id;
        g_self_object_version_id := p_object_version_id;
        g_self_as_of_date := p_as_of_date;
        g_self_current_flag := p_current_flag;
        g_self_rec_version_number := p_record_version_number;
        g_self_act_effort := l_actual_effort;
        g_self_act_cost := l_actual_cost;
        g_self_etc_effort := l_etc_effort;
        g_self_etc_cost := l_etc_cost;
    END IF;

    IF p_amount_type = 'ACT_COST' THEN
        return l_actual_cost;
    ELSIF p_amount_type = 'ACT_EFFORT' THEN
        return l_actual_effort;
    ELSIF p_amount_type = 'ETC_COST' THEN
        return l_etc_cost;
    ELSIF p_amount_type = 'ETC_EFFORT' THEN
        return l_etc_effort;
    ELSE
        return to_number(null);
    END IF;
END get_self_amounts;
-- Bug 4490532 End

function check_etc_overridden(p_plan_qty    IN   NUMBER,
 	                               p_actual_qty  IN   NUMBER,
 	                               p_etc_qty     IN   NUMBER) return varchar2 IS
 	 begin
 	     if (nvl(p_actual_qty,0) >= nvl(p_plan_qty,0) and nvl(p_plan_qty,0) < 0 and nvl(p_etc_qty,0) = nvl(p_plan_qty,0) - nvl(p_actual_qty,0)) then
 	        return 'N';
 	     elsif (nvl(p_actual_qty,0) >= nvl(p_plan_qty,0) and nvl(p_plan_qty,0) > 0 and nvl(p_etc_qty,0) = 0) then
 	        return 'N';
 	     elsif (nvl(p_actual_qty,0) <= nvl(p_plan_qty,0) and nvl(p_plan_qty,0) < 0 and nvl(p_etc_qty,0) = 0) then
 	        return 'N';
 	     elsif (nvl(p_actual_qty,0) <= nvl(p_plan_qty,0) and nvl(p_plan_qty,0) > 0 and nvl(p_etc_qty,0) = nvl(p_plan_qty,0) - nvl(p_actual_qty,0)) then
 	        return 'N';
 	     else  return 'Y';
 	     end if;
end check_etc_overridden;


-- Bug 4871809, added this function for performance reasons, used in pa_progress_pvt
function get_w_pub_prupid_asofdate(p_project_id  IN  number,
                                   p_object_id   IN  number,
                                   p_object_type IN  varchar2,
                                   p_task_id     IN  number,
                                   p_as_of_date  IN  date,
                                   p_chk_task    IN  varchar2 default 'Y') return number is
cursor get_work_prog_rollupid is
select progress_rollup_id
            FROM pa_progress_rollup
           WHERE project_id = p_project_id
             AND object_id = p_object_id
             AND decode(p_chk_task,'Y',proj_element_id,p_task_id) = p_task_id
             AND object_type = p_object_type
             AND structure_type = 'WORKPLAN'
             AND structure_version_id is null
             AND as_of_date <= p_as_of_date
             AND current_flag = 'W';

cursor get_pub_prog_rollupid is
select progress_rollup_id
  from pa_progress_rollup ppr
 WHERE ppr.project_id = p_project_id
   AND ppr.object_id = p_object_id
   AND decode(p_chk_task,'Y',ppr.proj_element_id,p_task_id) = p_task_id
   AND ppr.object_type = p_object_Type
   AND ppr.structure_type = 'WORKPLAN'
   AND ppr.structure_version_id is null
   AND ppr.as_of_date = (select max(as_of_date)
                      from pa_progress_rollup
                     where project_id = p_project_id
                       AND object_id = p_object_id
                       AND decode(p_chk_task,'Y',proj_element_id,p_task_id) = p_task_id
                       AND object_type = p_object_Type
                       AND structure_type = 'WORKPLAN'
                       AND structure_version_id is null
                       AND as_of_Date <= p_as_of_date);

 l_prog_rid number;
 l_date     date;
begin
  open get_work_prog_rollupid;
  fetch get_work_prog_rollupid into l_prog_rid;
  close get_work_prog_rollupid;

  if l_prog_rid is not null then
     return l_prog_rid;
  else
     open get_pub_prog_rollupid;
     fetch get_pub_prog_rollupid into l_prog_rid;
     close get_pub_prog_rollupid;
     if (l_prog_rid is not null) then
        return l_prog_rid;
     else
        return -99;
     end if;
  end if;

end get_w_pub_prupid_asofdate;

function get_w_pub_currflag(p_project_id  IN  number,
                            p_object_id   IN  number,
                            p_object_type IN  varchar2,
                            p_task_id     IN  number,
                            p_chk_task    IN  varchar2 default 'N') return varchar2 is
  cursor get_w_pub_currflag is
  select current_flag
    FROM pa_progress_rollup
   WHERE project_id = p_project_id
     AND object_id = p_object_id
     AND object_type = p_object_type
     AND decode(p_chk_task,'Y',proj_element_id,nvl(p_task_id,-99)) = nvl(p_task_id,-99)
     AND structure_type = 'WORKPLAN'
     AND structure_version_id is null
     AND current_flag in ('W','Y')
   order by current_flag asc;

  l_curr_flag   varchar2(1):= null;
begin
  open get_w_pub_currflag;
  fetch get_w_pub_currflag into l_curr_flag;
  close get_w_pub_currflag;

return nvl(l_curr_flag,'X');

end get_w_pub_currflag;

function check_ta_has_prog(
                           p_project_id IN NUMBER,
                           p_proj_element_id IN NUMBER,
                           p_element_ver_id IN NUMBER ) return varchar2 is
	cursor C_TA_PROG_CURSOR is
	select 'Y'
	from
	pa_resource_assignments pra,
	pa_progress_rollup ppr
	where pra.ta_display_flag = 'N'
			and pra.wbs_element_version_id = p_element_ver_id
			and pra.project_id = p_project_id
			and ppr.project_id = p_project_id
			and ppr.object_type = 'PA_ASSIGNMENTS'
			and ppr.object_id = pra.resource_list_member_id
			and ppr.structure_type = 'WORKPLAN'
			and ppr.structure_version_id is null
			and ppr.proj_element_id = p_proj_element_id
			and rownum = 1;

	l_result varchar2(10);
begin
   open C_TA_PROG_CURSOR;
			fetch C_TA_PROG_CURSOR into l_result;
			if C_TA_PROG_CURSOR%FOUND THEN
        close C_TA_PROG_CURSOR;
        return 'Y';
   ELSE
        close C_TA_PROG_CURSOR;
        return 'N';
   END IF;
end check_ta_has_prog;

--Bug 6664716
-- This function is used to calculate the planned value prorated for the period and the amounts are rolled up
-- to the parent tasks. This proc stores the planned value all the elements of the given structure id in
-- temporary table the first time when it is called and uses the values from this table for next calls.
PROCEDURE get_plan_value(p_project_id number, p_structure_version_id number, p_element_id number, p_as_of_date date)

IS

-- Bug 7259306 - Outer join added to the inner inline view for all 6 cursors on pa_progress_rollup table.

-- Working as of date

--This cursor retrieves the accumulated amounts for the periods before each task  before as of date period
  cursor cur_accum_amts_w (p_project_id NUMBER, p_structure_version_id NUMBER, p_baseline_struc_id NUMBER,
                         p_proj_element_id NUMBER,p_cal_id NUMBER, p_cal_type varchar, p_as_of_date date) is
  select time_id.proj_element_id proj_element_id
       ,time_id.as_of_date as_of_date
       ,sum(pfxaf.labor_hrs) labor_hours
       ,sum(pfxaf.equipment_hours) equipment_hours
       ,sum(pfxaf.brdn_cost) prj_brdn_cost
    from   pji_fp_xbs_accum_f pfxaf,
           pa_budget_versions pbv,
           (
            select prog_date.proj_element_id proj_element_id,
            prog_date.as_of_date as_of_date,
            ptcpv.cal_period_id cal_period_id,
            ptcpv.name period_name,
            ptcpv.start_date pstart_date,
            ptcpv.end_date pend_date
            from
            PJI_TIME_CAL_PERIOD_V ptcpv,
             (
               select ppv.proj_element_id proj_element_id,
                      nvl(p_as_of_date,(ppr.as_of_date)) as_of_date
               from pa_progress_rollup ppr,
                      pa_proj_element_versions ppv
                where ppv.parent_structure_version_id=p_structure_version_id
                  and ppv.project_id=p_project_id
                and ppv.proj_element_id=p_proj_element_id
                and ppr.object_id (+) =ppv.proj_element_id
                and ppr.object_version_id (+) =ppv.element_version_id
                and ppr.project_id (+) = ppv.project_id
                and ppr.structure_version_id (+) = ppv.parent_structure_version_id
                and ppr.structure_type (+) = 'WORKPLAN'
                and ppr.current_flag (+) = 'Y'
             )prog_date
             where ptcpv.calendar_id=p_cal_id
            -- and ptcpv.start_date <= prog_date.as_of_date
             and ptcpv.end_date <= prog_date.as_of_date
           )time_id
    where  pfxaf.project_id=p_project_id
    and    pfxaf.project_id=pbv.project_id
    and    pbv.project_structure_version_id=p_baseline_struc_id
    and    pbv.budget_version_id=pfxaf.plan_version_id
    and    pfxaf.project_element_id=time_id.proj_element_id
    and    pfxaf.wbs_rollup_flag='N'
    and    pfxaf.rbs_aggr_level='T'
    and    pfxaf.prg_rollup_flag='N'
    and    pfxaf.period_type_id=32
    and    pfxaf.calendar_type=p_cal_type
    and    pfxaf.time_id=time_id.cal_period_id
    group by time_id.proj_element_id
       ,time_id.as_of_date ;

  cursor cur_curr_prd_amts_w (p_project_id NUMBER, p_structure_version_id NUMBER, p_baseline_struc_id NUMBER,
                         p_proj_element_id NUMBER,p_cal_id NUMBER, p_cal_type varchar, p_as_of_date date) is
  select pfxaf.project_element_id proj_element_id
       ,time_id.pstart_date pstart_date
       ,time_id.pend_date pend_date
       ,time_id.as_of_date as_of_date
       ,pfxaf.labor_hrs labor_hours
       ,pfxaf.equipment_hours equipment_hours
       ,pfxaf.brdn_cost prj_brdn_cost
    from   pji_fp_xbs_accum_f pfxaf,
           pa_budget_versions pbv,
           (
            select prog_date.proj_element_id proj_element_id,
            prog_date.as_of_date as_of_date,
            ptcpv.cal_period_id cal_period_id,
            ptcpv.name period_name,
            ptcpv.start_date pstart_date,
            ptcpv.end_date pend_date
            from
            PJI_TIME_CAL_PERIOD_V ptcpv,
             (
               select ppv.proj_element_id proj_element_id,
                      nvl(p_as_of_date,(ppr.as_of_date)) as_of_date
               from pa_progress_rollup ppr,
                      pa_proj_element_versions ppv
                where ppv.parent_structure_version_id=p_structure_version_id
                  and ppv.project_id=p_project_id
                and ppv.proj_element_id=p_proj_element_id
                and ppr.object_id (+) =ppv.proj_element_id
                and ppr.object_version_id (+) =ppv.element_version_id
                and ppr.project_id (+) = ppv.project_id
                and ppr.structure_version_id (+) = ppv.parent_structure_version_id
                and ppr.structure_type (+) = 'WORKPLAN'
                and ppr.current_flag (+) = 'Y'
             )prog_date
             where ptcpv.calendar_id=p_cal_id
             and ptcpv.start_date <= prog_date.as_of_date
             and ptcpv.end_date >prog_date.as_of_date
           )time_id
    where  pfxaf.project_id=p_project_id
    and    pfxaf.project_id=pbv.project_id
    and    pbv.project_structure_version_id=p_baseline_struc_id
    and    pbv.budget_version_id=pfxaf.plan_version_id
    and    pfxaf.project_element_id=time_id.proj_element_id
    and    pfxaf.wbs_rollup_flag='N'
    and    pfxaf.rbs_aggr_level='T'
    and    pfxaf.prg_rollup_flag='N'
    and    pfxaf.period_type_id=32
    and    pfxaf.calendar_type=p_cal_type
    and    pfxaf.time_id=time_id.cal_period_id
    ;



-- Latest Published
--This cursor retrieves the accumulated amounts for lastest published the periods before each task  before as of date period
  cursor cur_accum_amts_l (p_project_id NUMBER, p_structure_version_id NUMBER, p_baseline_struc_id NUMBER,
                         p_proj_element_id NUMBER,p_cal_id NUMBER, p_cal_type varchar, p_as_of_date date) is
  select time_id.proj_element_id proj_element_id
       ,time_id.as_of_date as_of_date
       ,sum(pfxaf.labor_hrs) labor_hours
       ,sum(pfxaf.equipment_hours) equipment_hours
       ,sum(pfxaf.brdn_cost) prj_brdn_cost
    from   pji_fp_xbs_accum_f pfxaf,
           pa_budget_versions pbv,
           (
            select prog_date.proj_element_id proj_element_id,
            prog_date.as_of_date as_of_date,
            ptcpv.cal_period_id cal_period_id,
            ptcpv.name period_name,
            ptcpv.start_date pstart_date,
            ptcpv.end_date pend_date
            from
            PJI_TIME_CAL_PERIOD_V ptcpv,
             (
               select ppv.proj_element_id proj_element_id,
                      nvl(p_as_of_date,(ppr.as_of_date)) as_of_date
               from pa_progress_rollup ppr,
                      pa_proj_element_versions ppv
                where ppv.parent_structure_version_id=p_structure_version_id
                  and ppv.project_id=p_project_id
                and ppv.proj_element_id=p_proj_element_id
                and ppr.object_id (+) =ppv.proj_element_id
                and ppr.object_version_id (+) =ppv.element_version_id
                and ppr.project_id (+) = ppv.project_id
                and ppr.structure_version_id (+) IS NULL
                and ppr.structure_type (+) = 'WORKPLAN'
                and ppr.current_flag (+) ='Y'
              --group by ppv.proj_element_id
             )prog_date
             where ptcpv.calendar_id=p_cal_id
            -- and ptcpv.start_date <= prog_date.as_of_date
             and ptcpv.end_date <= prog_date.as_of_date
           )time_id
    where  pfxaf.project_id=p_project_id
    and    pfxaf.project_id=pbv.project_id
    and    pbv.project_structure_version_id=p_baseline_struc_id
    and    pbv.budget_version_id=pfxaf.plan_version_id
    and    pfxaf.project_element_id=time_id.proj_element_id
    and    pfxaf.wbs_rollup_flag='N'
    and    pfxaf.rbs_aggr_level='T'
    and    pfxaf.prg_rollup_flag='N'
    and    pfxaf.period_type_id=32
    and    pfxaf.calendar_type=p_cal_type
    and    pfxaf.time_id=time_id.cal_period_id
    group by time_id.proj_element_id
       ,time_id.as_of_date ;

  cursor cur_curr_prd_amts_l (p_project_id NUMBER, p_structure_version_id NUMBER, p_baseline_struc_id NUMBER,
                         p_proj_element_id NUMBER,p_cal_id NUMBER, p_cal_type varchar, p_as_of_date date) is
  select pfxaf.project_element_id proj_element_id
       ,time_id.pstart_date pstart_date
       ,time_id.pend_date pend_date
       ,time_id.as_of_date as_of_date
       ,pfxaf.labor_hrs labor_hours
       ,pfxaf.equipment_hours equipment_hours
       ,pfxaf.brdn_cost prj_brdn_cost
    from   pji_fp_xbs_accum_f pfxaf,
           pa_budget_versions pbv,
           (
            select prog_date.proj_element_id proj_element_id,
            prog_date.as_of_date as_of_date,
            ptcpv.cal_period_id cal_period_id,
            ptcpv.name period_name,
            ptcpv.start_date pstart_date,
            ptcpv.end_date pend_date
            from
            PJI_TIME_CAL_PERIOD_V ptcpv,
             (
               select ppv.proj_element_id proj_element_id,
                      nvl(p_as_of_date,(ppr.as_of_date)) as_of_date
               from pa_progress_rollup ppr,
                      pa_proj_element_versions ppv
                where ppv.parent_structure_version_id=p_structure_version_id
                  and ppv.project_id=p_project_id
                and ppv.proj_element_id=p_proj_element_id
                and ppr.object_id (+) =ppv.proj_element_id
                and ppr.object_version_id (+) =ppv.element_version_id
                and ppr.project_id (+) = ppv.project_id
                and ppr.structure_version_id (+) IS NULL
                and ppr.structure_type (+) = 'WORKPLAN'
                and ppr.current_flag (+) = 'Y'
              --group by ppv.proj_element_id
             )prog_date
             where ptcpv.calendar_id=p_cal_id
             and ptcpv.start_date <= prog_date.as_of_date
             and ptcpv.end_date >prog_date.as_of_date
           )time_id
    where  pfxaf.project_id=p_project_id
    and    pfxaf.project_id=pbv.project_id
    and    pbv.project_structure_version_id=p_baseline_struc_id
    and    pbv.budget_version_id=pfxaf.plan_version_id
    and    pfxaf.project_element_id=time_id.proj_element_id
    and    pfxaf.wbs_rollup_flag='N'
    and    pfxaf.rbs_aggr_level='T'
    and    pfxaf.prg_rollup_flag='N'
    and    pfxaf.period_type_id=32
    and    pfxaf.calendar_type=p_cal_type
    and    pfxaf.time_id=time_id.cal_period_id
    ;



 --Not a Latest Published Seperate cursor for previously published plan is used coz the as of the is picked from older version
 --if the passed structure id does have as of date in the progress_rollup table.
--This cursor retrieves the accumulated amounts for lastest published the for periods before before as of date
  cursor cur_accum_amts_p (p_project_id NUMBER, p_structure_version_id NUMBER, p_baseline_struc_id NUMBER,
                         p_proj_element_id NUMBER,p_cal_id NUMBER, p_cal_type varchar, p_as_of_date date) is
  select time_id.proj_element_id proj_element_id
       ,time_id.as_of_date as_of_date
       ,sum(pfxaf.labor_hrs) labor_hours
       ,sum(pfxaf.equipment_hours) equipment_hours
       ,sum(pfxaf.brdn_cost) prj_brdn_cost
    from   pji_fp_xbs_accum_f pfxaf,
           pa_budget_versions pbv,
           (
            select prog_date.proj_element_id proj_element_id,
            prog_date.as_of_date as_of_date,
            ptcpv.cal_period_id cal_period_id,
            ptcpv.name period_name,
            ptcpv.start_date pstart_date,
            ptcpv.end_date pend_date
            from
            PJI_TIME_CAL_PERIOD_V ptcpv,
             (
               select ppv.proj_element_id proj_element_id,
                      max(ppv.parent_structure_version_id) parent_structure_id,
                      nvl(p_as_of_date,max(ppr.as_of_date)) as_of_date
               from pa_progress_rollup ppr,
                      pa_proj_element_versions ppv
                where ppv.parent_structure_version_id<=p_structure_version_id
                  and ppv.project_id=p_project_id
                and ppv.proj_element_id=p_proj_element_id
                and ppr.object_id (+) =ppv.proj_element_id
                and ppr.object_version_id (+) =ppv.element_version_id
                and ppr.project_id (+) = ppv.project_id
                and ppr.structure_version_id (+) IS NULL
                and ppr.structure_type (+) = 'WORKPLAN'
                and ppr.current_flag (+) <> 'W'
              group by ppv.proj_element_id
             )prog_date
             where ptcpv.calendar_id=p_cal_id
            -- and ptcpv.start_date <= prog_date.as_of_date
             and ptcpv.end_date <= prog_date.as_of_date
           )time_id
    where  pfxaf.project_id=p_project_id
    and    pfxaf.project_id=pbv.project_id
    and    pbv.project_structure_version_id=p_baseline_struc_id
    and    pbv.budget_version_id=pfxaf.plan_version_id
    and    pfxaf.project_element_id=time_id.proj_element_id
    and    pfxaf.wbs_rollup_flag='N'
    and    pfxaf.rbs_aggr_level='T'
    and    pfxaf.prg_rollup_flag='N'
    and    pfxaf.period_type_id=32
    and    pfxaf.calendar_type=p_cal_type
    and    pfxaf.time_id=time_id.cal_period_id
    group by time_id.proj_element_id
       ,time_id.as_of_date ;

  cursor cur_curr_prd_amts_p (p_project_id NUMBER, p_structure_version_id NUMBER, p_baseline_struc_id NUMBER,
                         p_proj_element_id NUMBER,p_cal_id NUMBER, p_cal_type varchar, p_as_of_date date) is
  select pfxaf.project_element_id proj_element_id
       ,time_id.pstart_date pstart_date
       ,time_id.pend_date pend_date
       ,time_id.as_of_date as_of_date
       ,pfxaf.labor_hrs labor_hours
       ,pfxaf.equipment_hours equipment_hours
       ,pfxaf.brdn_cost prj_brdn_cost
    from   pji_fp_xbs_accum_f pfxaf,
           pa_budget_versions pbv,
           (
            select prog_date.proj_element_id proj_element_id,
            prog_date.as_of_date as_of_date,
            ptcpv.cal_period_id cal_period_id,
            ptcpv.name period_name,
            ptcpv.start_date pstart_date,
            ptcpv.end_date pend_date
            from
            PJI_TIME_CAL_PERIOD_V ptcpv,
             (
               select ppv.proj_element_id proj_element_id,
                      max(ppv.parent_structure_version_id) parent_structure_id,
                      nvl(p_as_of_date,max(ppr.as_of_date)) as_of_date
               from pa_progress_rollup ppr,
                      pa_proj_element_versions ppv
                where ppv.parent_structure_version_id<=p_structure_version_id
                  and ppv.project_id=p_project_id
                and ppv.proj_element_id=p_proj_element_id
                and ppr.object_id (+) =ppv.proj_element_id
                and ppr.object_version_id (+) =ppv.element_version_id
                and ppr.project_id (+) = ppv.project_id
                and ppr.structure_version_id (+) IS NULL
                and ppr.structure_type (+) = 'WORKPLAN'
                and ppr.current_flag (+) <> 'W'
              group by ppv.proj_element_id
             )prog_date
             where ptcpv.calendar_id=p_cal_id
             and ptcpv.start_date <= prog_date.as_of_date
             and ptcpv.end_date >prog_date.as_of_date
           )time_id
    where  pfxaf.project_id=p_project_id
    and    pfxaf.project_id=pbv.project_id
    and    pbv.project_structure_version_id=p_baseline_struc_id
    and    pbv.budget_version_id=pfxaf.plan_version_id
    and    pfxaf.project_element_id=time_id.proj_element_id
    and    pfxaf.wbs_rollup_flag='N'
    and    pfxaf.rbs_aggr_level='T'
    and    pfxaf.prg_rollup_flag='N'
    and    pfxaf.period_type_id=32
    and    pfxaf.calendar_type=p_cal_type
    and    pfxaf.time_id=time_id.cal_period_id
    ;

 --Bug 6941104: Added two joins for the existing query
cursor cur_parent_tasks_info(p_project_id number, p_structure_version_id number) is
  select ppev1.proj_element_id proj_element_id,
         ppev2.proj_element_id parent_task_id,
         ppev1.wbs_level,
         nvl(ppe.baseline_start_date,ppevs.scheduled_start_date) sch_start_date,
         nvl(ppe.baseline_finish_date,ppevs.scheduled_finish_date) sch_end_date
  from pa_proj_element_versions ppev1,
           pa_proj_element_versions ppev2,
       pa_object_relationships por,
           pa_proj_elements ppe,
           pa_proj_elem_ver_schedule ppevs
  where ppev1.parent_structure_version_id = p_structure_version_id
  and  ppev1.proj_element_id=ppe.proj_element_id
  and  nvl(ppe.link_task_flag,'N') = 'N'
  and  ppev1.element_version_id=ppevs.element_version_id
  and    ppev1.element_version_id = por.object_id_to1
  and  ppev2.element_version_id = por.object_id_from1
  and  por.relationship_type = 'S'
  and  por.object_type_to = 'PA_TASKS'
  and  ppe.object_type = 'PA_TASKS'
  order by  ppev1.wbs_level desc;

  cursor c1(p_structure_version_id number) is
  select 'Y'
    from pa_proj_elem_ver_structure
   where project_id = p_project_id
     and element_version_id = p_structure_version_id
     and status_code = 'STRUCTURE_PUBLISHED';

  l_cal_id          number :=0;
  l_cal_type        varchar2(1);
  l_parent_task_id  number;
  l_temp_start_date date;
  l_temp_end_date   date;
  l_temp_as_of_date date;
  l_multiplier      number;
  l_flag            varchar2(1) := 'N';
  l_work_struc_id   number := -1;
  l_baseline_struc_id  number := -1;
  l_as_of_date_ovr  date := NULL;
  l_dummy           varchar2(1) := 'N';

BEGIN

-- Initializing
  l_bcws_hash_tbl.delete();

        l_prv_bcws_project_id             := p_project_id;
  l_prv_bcws_struc_ver_id           := p_structure_version_id;

  l_work_struc_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(p_project_id);

  -- To decide the structure_version_id passed is latest published or current working or published version
  IF PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(p_project_id) = p_structure_version_id THEN
    l_flag := 'W';
  ELSIF PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(p_project_id) = p_structure_version_id THEN
    l_flag := 'L';
  ELSE
    -- Doing this handling for split structures where it is possible  to have multiple working versions.
    OPEN c1(p_structure_version_id);
    FETCH c1 into l_dummy;
    CLOSE c1;

    IF nvl(l_dummy,'N') = 'Y' THEN
      l_flag := 'P';
    ELSE
      l_flag := 'W';
    END IF;

  END IF;

  --Code for getting the calendar id.
  SELECT ppfo.cost_time_phased_code INTO l_cal_type
  FROM pa_proj_fp_options ppfo, pa_budget_versions pbv
  WHERE pbv.project_id=p_project_id
  AND   pbv.project_structure_version_id=p_structure_version_id
  AND   pbv.budget_version_id=ppfo.fin_plan_version_id
  AND   ppfo.fin_plan_option_level_code='PLAN_VERSION';

  -- To calculate planned value based on the existing functionality
  -- when workplan is non time phased.
  IF l_cal_type = 'N'
  THEN
    return;
  END IF;

  IF l_cal_type = 'G' THEN
    SELECT ftcn.calendar_id INTO l_cal_id
    FROM fii_time_cal_name ftcn,
         pa_projects_all ppa,
         pa_implementations_all pia,
         gl_sets_of_books gsb
    WHERE ppa.project_id=p_project_id
    AND   ppa.org_id=pia.org_id
    AND   pia.set_of_books_id=gsb.set_of_books_id
    AND   gsb.period_set_name=ftcn.period_set_name
    AND   gsb.accounted_period_type=ftcn.period_type;
  ELSIF l_cal_type = 'P' THEN
    SELECT ftcn.calendar_id INTO l_cal_id
    FROM fii_time_cal_name ftcn,
         pa_projects_all ppa,
         pa_implementations_all pia
    WHERE ppa.project_id=p_project_id
    AND   ppa.org_id=pia.org_id
    AND   pia.period_set_name=ftcn.period_set_name
    AND   pia.pa_period_type=ftcn.period_type;
  END IF;

        -- Retriving baseline structure id to retrive planned values information from baselined structure.
        l_baseline_struc_id := PA_PROJECT_STRUCTURE_UTILS.Get_Baseline_Struct_Ver(p_project_id);

        IF l_baseline_struc_id = -1 THEN
          l_baseline_struc_id := p_structure_version_id;
        END IF;

  -- Populating the parent task id as well as calculating the com and rolls up the amounts to parent task.
  FOR cur_parent_tasks_info_rec in cur_parent_tasks_info(p_project_id, p_structure_version_id)
  LOOP
    l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).parent_task_id := cur_parent_tasks_info_rec.parent_task_id;
    l_as_of_date_ovr := NULL;
    l_parent_task_id := NULL;

    -- Bug 7259306
    -- In the absence of progress, the planned value is calculated based on the as of date displayed in the progress report tab.
    IF (PA_PROJECT_STRUCTURE_UTILS.CHECK_STRUC_VER_PUBLISHED(p_project_id, p_structure_version_id) = 'Y') AND
       (PA_PROGRESS_UTILS.PROJ_TASK_PROG_EXISTS(p_project_id, cur_parent_tasks_info_rec.proj_element_id) = 'N') THEN
        l_as_of_date_ovr := get_def_as_of_date_prog_report(p_project_id, cur_parent_tasks_info_rec.proj_element_id);
    END IF;

    -- Overriding the as of date for showing the changed planned value in progress details page:
          IF l_ovr_task_id IS NOT NULL AND l_ovr_task_id <> -1 AND (l_ovr_task_id = p_element_id) THEN
            IF l_bcws_hash_tbl.exists('PA'||l_ovr_task_id) AND (l_ovr_task_id = cur_parent_tasks_info_rec.proj_element_id) THEN
              l_as_of_date_ovr    := p_as_of_date;
            END IF;
          END IF;

    IF l_flag = 'W' THEN
      FOR cur_accum_amts_w_rec in cur_accum_amts_w(p_project_id, p_structure_version_id, l_baseline_struc_id, cur_parent_tasks_info_rec.proj_element_id,
          l_cal_id,l_cal_type, l_as_of_date_ovr)
      LOOP
              l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tlbr_hrs_baod := cur_accum_amts_w_rec.labor_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).teqp_hrs_baod := cur_accum_amts_w_rec.equipment_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tpbc_hrs_baod := cur_accum_amts_w_rec.prj_brdn_cost;

            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).as_of_date    := cur_accum_amts_w_rec.as_of_date;
            END LOOP;

            --This loop is used to populate the current period amounts.
          FOR cur_curr_prd_amts_w_rec in cur_curr_prd_amts_w(p_project_id, p_structure_version_id, l_baseline_struc_id, cur_parent_tasks_info_rec.proj_element_id,
          l_cal_id,l_cal_type, l_as_of_date_ovr)
          LOOP
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_lbr_hrs   := cur_curr_prd_amts_w_rec.labor_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_eqp_hrs   := cur_curr_prd_amts_w_rec.equipment_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_pbc       := cur_curr_prd_amts_w_rec.prj_brdn_cost;

            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).pstart_date   := cur_curr_prd_amts_w_rec.pstart_date;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).pend_date     := cur_curr_prd_amts_w_rec.pend_date;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).as_of_date    := cur_curr_prd_amts_w_rec.as_of_date;
          END LOOP;
    ELSIF l_flag ='L' THEN
      FOR cur_accum_amts_l_rec in cur_accum_amts_l(p_project_id, p_structure_version_id, l_baseline_struc_id, cur_parent_tasks_info_rec.proj_element_id,
          l_cal_id,l_cal_type,l_as_of_date_ovr)
      LOOP
              l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tlbr_hrs_baod := cur_accum_amts_l_rec.labor_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).teqp_hrs_baod := cur_accum_amts_l_rec.equipment_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tpbc_hrs_baod := cur_accum_amts_l_rec.prj_brdn_cost;

            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).as_of_date    := cur_accum_amts_l_rec.as_of_date;
            END LOOP;

            --This loop is used to populate the current period amounts.
          FOR cur_curr_prd_amts_l_rec in cur_curr_prd_amts_l(p_project_id, p_structure_version_id, l_baseline_struc_id, cur_parent_tasks_info_rec.proj_element_id,
          l_cal_id,l_cal_type,l_as_of_date_ovr)
          LOOP
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_lbr_hrs   := cur_curr_prd_amts_l_rec.labor_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_eqp_hrs   := cur_curr_prd_amts_l_rec.equipment_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_pbc       := cur_curr_prd_amts_l_rec.prj_brdn_cost;

            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).pstart_date   := cur_curr_prd_amts_l_rec.pstart_date;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).pend_date     := cur_curr_prd_amts_l_rec.pend_date;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).as_of_date    := cur_curr_prd_amts_l_rec.as_of_date;
          END LOOP;
    ELSIF l_flag ='P' THEN

      FOR cur_accum_amts_p_rec in cur_accum_amts_p(p_project_id, p_structure_version_id, l_baseline_struc_id, cur_parent_tasks_info_rec.proj_element_id,
          l_cal_id,l_cal_type,l_as_of_date_ovr)
      LOOP
              l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tlbr_hrs_baod := cur_accum_amts_p_rec.labor_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).teqp_hrs_baod := cur_accum_amts_p_rec.equipment_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tpbc_hrs_baod := cur_accum_amts_p_rec.prj_brdn_cost;

            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).as_of_date    := cur_accum_amts_p_rec.as_of_date;
            END LOOP;

            --This loop is used to populate the current period amounts.
          FOR cur_curr_prd_amts_p_rec in cur_curr_prd_amts_p(p_project_id, p_structure_version_id, l_baseline_struc_id, cur_parent_tasks_info_rec.proj_element_id,
          l_cal_id,l_cal_type,l_as_of_date_ovr)
          LOOP
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_lbr_hrs   := cur_curr_prd_amts_p_rec.labor_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_eqp_hrs   := cur_curr_prd_amts_p_rec.equipment_hours;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_pbc       := cur_curr_prd_amts_p_rec.prj_brdn_cost;

            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).pstart_date   := cur_curr_prd_amts_p_rec.pstart_date;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).pend_date     := cur_curr_prd_amts_p_rec.pend_date;
            l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).as_of_date    := cur_curr_prd_amts_p_rec.as_of_date;
          END LOOP;

    END IF;


    -- TO populate the schedule dates from schedule dates  table if baseline date is null
    l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).sch_start_date := cur_parent_tasks_info_rec.sch_start_date;
          l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).sch_end_date   := cur_parent_tasks_info_rec.sch_end_date;

    l_temp_start_date := NULL;
    l_temp_end_date   := NULL;
    l_temp_as_of_date := NULL;
    l_multiplier      := NULL;

    l_temp_start_date := greatest(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).sch_start_date,
                    l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).pstart_date);
    l_temp_end_date := least(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).sch_end_date,
                    l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).pend_date);
    l_temp_as_of_date := l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).as_of_date;


    IF ((l_temp_start_date - l_temp_as_of_date) > 0) THEN
      l_multiplier := 0;
    ELSIF ((l_temp_as_of_date - l_temp_end_date) >= 0) THEN
      l_multiplier := 1;
    ELSIF (nvl((l_temp_end_date - l_temp_start_date),0) >= 0) then
      l_multiplier := nvl((trunc(l_temp_as_of_date) - trunc(l_temp_start_date)+1),0)/
                      nvl((trunc(l_temp_end_date) - trunc(l_temp_start_date)+1),1);
    END IF;

    IF l_multiplier IS NOT NULL THEN
      l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).labor_hrs :=
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).labor_hrs,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tlbr_hrs_baod,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_lbr_hrs,0) * l_multiplier;

      l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).equip_hrs :=
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).equip_hrs,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).teqp_hrs_baod,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_eqp_hrs,0) * l_multiplier;

      l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).prj_brdn_cost :=
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).prj_brdn_cost,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tpbc_hrs_baod,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_pbc,0) * l_multiplier;

    ELSE -- IF mulitplication factor is null then add complete curr period amount to

      l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).labor_hrs :=
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).labor_hrs,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tlbr_hrs_baod,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_lbr_hrs,0);

      l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).equip_hrs :=
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).equip_hrs,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).teqp_hrs_baod,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_eqp_hrs,0);

      l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).prj_brdn_cost :=
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).prj_brdn_cost,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).tpbc_hrs_baod,0) +
        nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).cur_pbc,0);

    END IF;


    l_parent_task_id := l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).parent_task_id;

    -- elements amounts are rolled upto corresponding parent task id.
    IF l_bcws_hash_tbl.exists('PA'||l_parent_task_id) THEN
      l_bcws_hash_tbl('PA'||l_parent_task_id).labor_hrs := nvl(l_bcws_hash_tbl('PA'||l_parent_task_id).labor_hrs,0) +
                                               nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).labor_hrs,0);

      l_bcws_hash_tbl('PA'||l_parent_task_id).equip_hrs := nvl(l_bcws_hash_tbl('PA'||l_parent_task_id).equip_hrs,0) +
                                               nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).equip_hrs,0);

      l_bcws_hash_tbl('PA'||l_parent_task_id).prj_brdn_cost := nvl(l_bcws_hash_tbl('PA'||l_parent_task_id).prj_brdn_cost,0) +
                                               nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).prj_brdn_cost,0);
    ELSE
      l_bcws_hash_tbl('PA'||l_parent_task_id).labor_hrs := nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).labor_hrs,0);

      l_bcws_hash_tbl('PA'||l_parent_task_id).equip_hrs := nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).equip_hrs,0);

      l_bcws_hash_tbl('PA'||l_parent_task_id).prj_brdn_cost := nvl(l_bcws_hash_tbl('PA'||cur_parent_tasks_info_rec.proj_element_id).prj_brdn_cost,0);
    END IF;
  END LOOP;

EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_UTILS',
                              p_procedure_name => 'get_plan_value',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));

END get_plan_value;

-- This is procedure is used to clear the cache.
PROCEDURE clear_tmp_tables(p_task_id Number Default Null)
IS
BEGIN

        l_prv_bcws_project_id             := -1;
  l_prv_bcws_struc_ver_id           := -1;
  l_ovr_task_id                     := p_task_id;
END clear_tmp_tables;
--Bug 6664716

-- Bug 7259306
-- Returns the date displayed in the Progress Report tab
-- Cursor is based on the VO - ProgressAsOfDatesVO which is used to populate the 'as of date' poplist
FUNCTION get_def_as_of_date_prog_report(
    p_project_id        pa_progress_rollup.project_id%TYPE,
    p_proj_element_id   pa_progress_rollup.proj_element_id%TYPE,
    p_object_type       pa_progress_rollup.object_type%TYPE := 'PA_TASKS'
) RETURN DATE IS
    l_return_date         DATE;

    CURSOR cur_get_def_as_of_date
    IS
    SELECT  as_of_date FROM (
    SELECT  ppe.project_id project_id,
            PA_PROGRESS_UTILS.AS_OF_DATE(ppe.project_id, ppe.proj_element_id, ppp.progress_cycle_id, ppe.object_type) as_of_date ,
            ppe.object_type object_type
    FROM    pa_project_statuses po,
            pa_proj_progress_attr ppp,
            pa_proj_elements ppe
    WHERE   ppe.project_id         = ppp.project_id(+)
    AND ppp.structure_type (+) = 'WORKPLAN'
    AND ppe.project_id         = p_project_id
    AND ppe.proj_element_id    = p_proj_element_id
    AND ppe.object_type        = p_object_type
    AND ((ppe.object_type     IN ('PA_TASKS', 'PA_STRUCTURES')
    AND rownum                 <61)
     OR (ppe.object_type       = 'PA_DELIVERABLES'
    AND rownum                 <11))
    MINUS
    SELECT  to_number(p_project_id) project_id,
            to_date(NULL) as_of_date,
            TO_CHAR(p_object_type) object_type
    FROM    dual
    )
    WHERE ROWNUM = 1;

BEGIN
     OPEN cur_get_def_as_of_date;
     FETCH cur_get_def_as_of_date INTO l_return_date;
     CLOSE cur_get_def_as_of_date;

     -- Bug 7633088

     IF pa_progress_utils.get_prog_asofdate is NOT NULL THEN
	RETURN ( pa_progress_utils.get_prog_asofdate );  /* 8220798 */
     ELSIF g_override_as_of_date is NOT NULL THEN
       RETURN ( g_override_as_of_date );
     ELSE
       RETURN ( l_return_date );
     END IF;

END get_def_as_of_date_prog_report;

-- Bug 7633088
PROCEDURE set_override_as_of_date(p_as_of_date IN DATE) IS
BEGIN
    g_override_as_of_date := p_as_of_date;
END set_override_as_of_date;


END PA_PROGRESS_UTILS;

/
