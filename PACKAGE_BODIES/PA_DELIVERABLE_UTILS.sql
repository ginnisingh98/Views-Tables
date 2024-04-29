--------------------------------------------------------
--  DDL for Package Body PA_DELIVERABLE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DELIVERABLE_UTILS" AS
     /* $Header: PADLUTLB.pls 120.8.12010000.2 2010/01/18 10:55:44 amehrotr ship $ */
g_module_name    VARCHAR2(100) := 'pa.plsql.PA_DELIVERABLE_UTILS';
l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;


-- SubProgram           : IS_DLV_TYPE_NAME_UNIQUE
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether deliverable type name is unique
-- Note                 : If the passed deliverable type name already exists in the database then it is not unique
-- Assumptions          : None
-- Parameter                      IN/OUT            Type         Required     Description and Purpose
-- --------------------------  ------------    ----------      ----------    --------------------------

--  P_deliverable_type_name     IN          VARCHAR2           N           Deliverable Type Name

FUNCTION IS_DLV_TYPE_NAME_UNIQUE
(
     p_deliverable_type_name IN VARCHAR2
)   RETURN VARCHAR2
IS

l_return_status  varchar2(1);
l_dummy          varchar2(1);


CURSOR c_deliverable_type_name_exists IS
SELECT 'X'
FROM PA_TASK_TYPES
WHERE TASK_TYPE = p_deliverable_type_name  -- 3946664 removed upper from both the sides
AND OBJECT_TYPE='PA_DLVR_TYPES';

--The cursor c_deliverable_type_name_exists returns 'X'
--if there is atleast one row with the same deliverable type name

BEGIN
    OPEN c_deliverable_type_name_exists;
    FETCH c_deliverable_type_name_exists into l_dummy ;
    IF c_deliverable_type_name_exists%found THEN
       l_return_status:='N';
    ELSE
       l_return_status:='Y';
    END IF;
    CLOSE c_deliverable_type_name_exists;

return l_return_status;

END IS_DLV_TYPE_NAME_UNIQUE;

-- SubProgram           : IS_DLV_TYPE_IN_USE
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether deliverable type  is in use
-- Note                 : If there is an entry for the deliverable type id in the pa_proj_elements table
--                        it means that deliverable type is in use.
-- Assumptions          : None
-- Parameter                      IN/OUT           Type                   Required         Description and Purpose
-- ---------------------------  ------------    ----------                  ---------       ---------------------------

--  p_deliverable_type_id        IN          PA_TASK_TYPES.TASK_TYPE_ID%TYPE  N              Deliverable Type Id


FUNCTION IS_DLV_TYPE_IN_USE
(
     p_deliverable_type_id IN PA_TASK_TYPES.TASK_TYPE_ID%TYPE
)   RETURN VARCHAR2
IS

l_return_status  varchar2(1);
l_dummy          varchar2(1);

--The cursor c_dlv_type_in_use will return 'X'
--if the deliverable type id is present in the
--PA_PROJ_ELEMENTS table .If it is present then
--it means that it is in use.

CURSOR c_dlv_type_in_use IS
SELECT 'X'
FROM DUAL
    WHERE EXISTS (SELECT 'X'
     FROM PA_PROJ_ELEMENTS
     WHERE TYPE_ID = p_deliverable_type_id
     AND OBJECT_TYPE='PA_DELIVERABLES');

BEGIN
     OPEN c_dlv_type_in_use;
     FETCH c_dlv_type_in_use into l_dummy ;
     IF c_dlv_type_in_use%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE c_dlv_type_in_use;

return l_return_status;

END IS_DLV_TYPE_IN_USE;

-- SubProgram           : IS_DLV_TYPE_ACTIONS_EXISTS
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether actions exist for the Deliverable Type
-- Note                 : If there are any actions by defaultly defined for a deliverable type,
--                        then that relationship will be present in the PA_OBJECT_RELATIONSHIPS table
--                        The relationship is defined by the relationship_type 'A'
--                        and the subtype is 'DLVR_TYPE_TO_ACTION'
-- Assumptions          : None
-- Parameter                      IN/OUT            Type               Required         Description and Purpose
-- ---------------------------  ------------    -----------            ---------       ---------------------------

--  p_deliverable_type_id        IN     PA_TASK_TYPES.TASK_TYPE_ID%TYPE   N          Deliverable Type Id

FUNCTION IS_DLV_TYPE_ACTIONS_EXISTS
(
     p_deliverable_type_id IN PA_TASK_TYPES.TASK_TYPE_ID%TYPE
)   RETURN VARCHAR2
IS

l_return_status  varchar2(1);
l_dummy          varchar2(1);

--The cursor c_dlv_type_action_exists returns 'X' at the first hit
--If there exists a relationship 'DLVR_TYPE_TO_ACTION'
--FROM the passed p_deliverable_type_id of object_type 'PA_DLVR_TYPES'
--TO any of the deliverable actions of object_type 'PA_ACTIONS' in the PA_OBJECT_RELATIONSHIPS table
--Note : The relationship is defined by the relationship_type 'A'

CURSOR c_dlv_type_action_exists IS
SELECT 'X'
FROM DUAL
    WHERE EXISTS (SELECT 'X'
                   FROM PA_OBJECT_RELATIONSHIPS obj
                  WHERE obj.object_id_from2 = p_deliverable_type_id
                         AND obj.object_type_from  = 'PA_DLVR_TYPES'
                     AND obj.relationship_subtype  = 'DLVR_TYPE_TO_ACTION'
                         AND obj.relationship_type  = 'A'
                         AND obj.object_type_to = 'PA_ACTIONS');

BEGIN
     OPEN c_dlv_type_action_exists;
     FETCH c_dlv_type_action_exists into l_dummy ;
     IF c_dlv_type_action_exists%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE c_dlv_type_action_exists;

return l_return_status;

END IS_DLV_TYPE_ACTIONS_EXISTS;

-- SubProgram           : IS_DLV_ACTIONS_EXISTS
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether
--                        there exists a deliverable of type p_deliverable_type_id
--                        which is associated with actions
-- Note                 : If there are any actions are defined for a deliverable,
--                        then that relationship will be present in the PA_OBJECT_RELATIONSHIPS table
--                        The relationship is defined by the relationship_type 'A'
--                        and the subtype is 'DELIVERABLE_TO_ACTION'
-- Assumptions          : None
-- Parameter                      IN/OUT          Type                 Required         Description and Purpose
-- ---------------------------  ------------    ----------             ---------       ---------------------------

--  p_deliverable_type_id       IN      PA_TASK_TYPES.TASK_TYPE_ID%TYPE    N           Deliverable Type Id

FUNCTION IS_DLV_ACTIONS_EXISTS
(
     p_deliverable_type_id IN PA_TASK_TYPES.TASK_TYPE_ID%TYPE
)   RETURN VARCHAR2
IS

l_return_status  varchar2(1);
l_dummy          varchar2(1);

--The cursor c_dlv_action_exists returns 'X' at the first hit
--If there exists a deliverable of object_type "PA_DELIVERABLES'
--of type p_deliverable_type_id
--and the deliverable has a relationship 'DELIVERABLE_TO_ACTION'
--WITH any of the Deliverable Actions of object_type 'PA_ACTIONS'

--Note : The relationship is defined by the relationship_type 'A'

CURSOR c_dlv_action_exists IS
SELECT 'X'
FROM DUAL
WHERE EXISTS  (SELECT 'X'
               FROM PA_OBJECT_RELATIONSHIPS obj,
                     PA_PROJ_ELEMENTS ppe
                    where ppe.type_id = p_deliverable_type_id
                    and ppe.object_type='PA_DELIVERABLES'
                    and ppe.proj_element_id = obj.object_id_from2
                  and obj.object_type_from  = 'PA_DELIVERABLES'
                and obj.object_type_to = 'PA_ACTIONS'
                and obj.relationship_subtype  = 'DELIVERABLE_TO_ACTION'
                and obj.relationship_type  = 'A');


BEGIN
     OPEN c_dlv_action_exists;
     FETCH c_dlv_action_exists into l_dummy ;
     IF c_dlv_action_exists%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE c_dlv_action_exists;

return l_return_status;

END IS_DLV_ACTIONS_EXISTS;

-- SubProgram           : IS_DLV_BASED_ASSCN_EXISTS
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether
--                        there exists a deliverable of type p_deliverable_type_id
--                        has been associated with a Deliverable-based task
-- Note                 : 1) If a deliverable has been associated with a task
--                        then an entry corresponding to its association with the task can be found
--                        in the PA_OBJECT_RELATIONSHIPS table with the relationship_type defined by 'A'
--                        and relationship_sub_type 'TASK_TO_DELIVERABLE'
--                        2)If a task is deliverable then
--                        the progress rollup method of the task is "Deliverable-based" .This can be found
--                        from the PA_PROJ_ELEMENTS table.
-- Assumptions          : None
-- Parameter                      IN/OUT          Type                  Required         Description and Purpose
-- ---------------------------  ------------    ----------                ---------       ---------------------------

--  p_deliverable_type_id         IN       PA_TASK_TYPES.TASK_TYPE_ID%TYPE     N          Deliverable Type Id


FUNCTION IS_DLV_BASED_ASSCN_EXISTS
(
     p_deliverable_type_id IN PA_TASK_TYPES.TASK_TYPE_ID%TYPE
)   RETURN VARCHAR2
IS
l_return_status  varchar2(1);
l_dummy          varchar2(1);

--The cursor c_dlv_based_task_exists returns 'X' at the first hit
--If there exists a deliverable of object_type 'PA_DELIVERABLES'
--of type p_deliverable_id
--and which has a relationship 'TASK_TO_DELIVERABLE' with a
--'DELIVERABLE' task of object_type 'PA_TASKS'

--Note : The relationship is defined by the relationship_type 'A'

CURSOR c_dlv_based_task_exists IS
SELECT 'X'
FROM DUAL
WHERE EXISTS (SELECT 'X'
              FROM PA_OBJECT_RELATIONSHIPS obj,
                  PA_PROJ_ELEMENTS ppe1,
                  PA_PROJ_ELEMENTS ppe2
                   where ppe1.type_id = p_deliverable_type_id
                   and ppe1.object_type= 'PA_DELIVERABLES'
                and ppe1.proj_element_id = obj.object_id_to2
                and ppe2. proj_element_id = obj.object_id_from2
                   and ppe2.object_type = 'PA_TASKS'
                   and ppe2.project_id = ppe1.project_id
                and ppe2.base_percent_comp_deriv_code = 'DELIVERABLE'
                 and obj.object_type_from  = 'PA_TASKS'
                and obj.object_type_to  = 'PA_DELIVERABLES'  -- 3570283 removed extra spaces
                and obj.relationship_subtype  = 'TASK_TO_DELIVERABLE'
                and obj.relationship_type  = 'A');


BEGIN
     OPEN c_dlv_based_task_exists;
     FETCH c_dlv_based_task_exists into l_dummy ;
     IF c_dlv_based_task_exists%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE c_dlv_based_task_exists;

return l_return_status;

END IS_DLV_BASED_ASSCN_EXISTS;

-- SubProgram           : IS_EFF_FROM_TO_DATE_VALID
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether
--                        the entered start date and end date are valid
--                        If and Only if,the startdate is greater than the end date then it is Invalid
-- Note                 : None
-- Assumption           : If the startdate and enddate are the same,then it is valid
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    ----------     ---------       ---------------------------

--  p_start_date_Active         IN             DATE       N          Effetive Start date
--  p_end_date_Active            IN            DATE       N          Effective End date


FUNCTION IS_EFF_FROM_TO_DATE_VALID
(
     p_start_date_active   IN  DATE,
     p_end_date_active     IN  DATE
)    RETURN VARCHAR2
IS

l_return_status  varchar2(1);

BEGIN
     IF p_end_date_active IS NOT NULL AND TRUNC(p_start_date_active) > TRUNC(p_end_date_active) THEN
          l_return_status:='N';
     ELSE
          l_return_status:='Y';
     END IF;
return l_return_status;
END IS_EFF_FROM_TO_DATE_VALID;

-- SubProgram           : GET_ASSOCIATED_TASKS
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will get the list of tasks associated to the deliverable
--                        in the format task1,task2,task3,More..
-- Note                 : None
-- Assumption           : None
-- Parameter                      IN/OUT            Type                    Required         Description and Purpose
-- ---------------------------  ------------    ----------                  ---------       ---------------------------
-- p_deliverable_id            IN        PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE    N            Deliverable Type Id

 FUNCTION GET_ASSOCIATED_TASKS
 (
     p_deliverable_id   IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
 )   RETURN VARCHAR2
 IS

 TYPE l_tbl IS TABLE OF VARCHAR2(350) INDEX BY BINARY_INTEGER;
 l_name_number_tbl l_tbl ;
 l_count NUMBER ;
 l_string varchar2(500);
 l_meaning varchar2(80);

CURSOR c_associated_tasks IS
SELECT  ppe. name||'('|| ppe.element_number||')' name_number
FROM  PA_PROJ_ELEMENTS ppe ,
      PA_OBJECT_RELATIONSHIPS obj
WHERE  ppe.object_type='PA_TASKS'
  AND  ppe.proj_element_id = OBJ.object_id_from2
  AND  OBJ.object_id_to2 =p_deliverable_id
  AND  OBJ.object_type_to = 'PA_DELIVERABLES'
  AND  OBJ.object_type_from = 'PA_TASKS'
  AND  OBJ.relationship_type = 'A'
  AND  OBJ.relationship_subtype = 'TASK_TO_DELIVERABLE'
       ORDER BY ppe.base_percent_comp_deriv_code;

CURSOR c_lookup_meaning IS
SELECT meaning
FROM pa_lookups
WHERE lookup_type = 'PA_DLV_MORE'
  AND lookup_code = 'MORE';
BEGIN
OPEN c_associated_tasks;
OPEN c_lookup_meaning;
FETCH  c_associated_tasks BULK COLLECT INTO l_name_number_tbl;
CLOSE  c_associated_tasks;
     IF  nvl(l_name_number_tbl.LAST,0)>0
     THEN
          FETCH  c_lookup_meaning INTO l_meaning;
          CLOSE  c_lookup_meaning;
          FOR l_count in l_name_number_tbl.FIRST..l_name_number_tbl.LAST LOOP
             IF l_count = 1
               THEN
                    l_string :=l_name_number_tbl(l_count);
               ELSE
                    l_string := l_string||','||l_name_number_tbl(l_count);
               END IF;
          EXIT  WHEN l_count >= 3 ;
          END LOOP ;
        IF nvl(l_name_number_tbl.LAST,0)>3
          THEN
            l_string := l_string||','|| l_meaning||'..';
        END IF ;
          RETURN l_string;
     ELSE
          RETURN NULL;
     END IF ;
END GET_ASSOCIATED_TASKS;

-- SubProgram           : GET_OKE_FLAGS
-- Type                 : UTIL PROCEDURE
-- Purpose              : This procedure will return all the required flags for OKE
--                        validation . This API will call util APIs provided by OKE
--                        team.
-- Note                 : None
-- Assumption           : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    ----------     ---------       ---------------------------
-- p_project_id                     IN            NUMBER          Y             Project Id
-- p_dlvr_item_id                   IN            NUMBER          Y             element id of the deliverable
-- p_dlvr_version_id                IN            NUMBER          Y             version id of the deliverable
-- p_action_item_id                 IN            NUMBER          Y             element id of the action
-- p_action_version_id              IN            VARCHAR2        Y             version id of the action
-- p_calling_module                 IN            VARCHAR2        Y             Calling module
-- x_ready_to_ship                  OUT           VARCHAR2        Y             Ready to ship flag
-- x_ready_to_procure               OUT           VARCHAR2        Y             Ready to procure flag
-- x_planning_initiated             OUT           VARCHAR2        Y             Planning initiated flag
-- x_proc_initiated                 OUT           VARCHAR2        Y             Procurement initiated flag
-- x_shipping_initiated             OUT           VARCHAR2        Y             Shipping initiated flag
-- x_item_exists                    OUT           VARCHAR2        Y             Item Exists Flag
-- x_item_shippable                 OUT           VARCHAR2        Y             Item Shippable Flag
-- x_item_billable                  OUT           VARCHAR2        Y             Item billable Flag
-- x_item_purchasable               OUT           VARCHAR2        Y             Item purchasable Flag
-- x_ship_procure_flag_dlv          OUT           VARCHAR2        Y             Shipping/Procurement Flag for deliverable
-- x_return_status                  OUT           VARCHAR2        Y
-- x_msg_count                      OUT           VARCHAR2        Y
-- x_msg_data                       OUT

PROCEDURE GET_OKE_FLAGS
         ( p_project_id             IN  pa_projects_all.project_id%TYPE
          ,p_dlvr_item_id           IN  pa_proj_elements.proj_element_id%TYPE
          ,p_dlvr_version_id        IN  pa_proj_element_versions.element_version_id%TYPE
          ,p_action_item_id         IN  pa_proj_elements.proj_element_id%TYPE
          ,p_action_version_id      IN  pa_proj_element_versions.element_version_id%TYPE
          ,p_calling_module         IN  VARCHAR2
          ,x_ready_to_ship          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_ready_to_procure       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_planning_initiated     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_proc_initiated         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_shipping_initiated     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_item_exists            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_item_shippable         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_item_billable          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_item_purchasable       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_ship_procure_flag_dlv  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         )
IS

     CURSOR ship_procure_flag_dlv IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE obj.object_id_from2 = p_dlvr_item_id
                        AND obj.object_type_to = 'PA_ACTIONS'
                        AND obj.object_type_from = 'PA_DELIVERABLES'
                        AND obj.object_id_to2 = ver.proj_element_id
                        AND obj.RELATIONSHIP_TYPE = 'A'
                        AND obj.RELATIONSHIP_SUBTYPE = 'DELIVERABLE_TO_ACTION'
                              AND (nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Ship_Yn(ver.element_version_id),'N') = 'Y'
                               OR nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Procure_Yn(ver.element_version_id),'N') = 'Y' )
                  ) ;

     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'GET_OKE_FLAGS'
                                     ,p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside CREATE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

          x_ready_to_ship         := 'N' ;
          x_ready_to_procure      := 'N' ;
          x_planning_initiated    := 'N' ;
          x_proc_initiated        := 'N' ;
          x_shipping_initiated    := 'N' ;
          x_item_exists           := 'N' ;
          x_item_shippable        := 'N' ;
          x_item_billable         := 'N' ;
          x_item_purchasable      := 'N' ;
          x_ship_procure_flag_dlv := 'N' ;

--     IF p_calling_module  'DELETE_DELIVERABLE' THEN
     IF p_calling_module IN ( 'DELETE_DELIVERABLE','DELETE_ASSOCIATION','UPDATE_DUE_DATE' ) THEN
          OPEN ship_procure_flag_dlv ;
          FETCH ship_procure_flag_dlv INTO x_ship_procure_flag_dlv ;
          CLOSE ship_procure_flag_dlv ;
     ELSE
     -- Initialize all the out parameters

          x_ready_to_ship      := nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Ship_Yn (P_Action_ID => p_action_version_id),'N')   ;
          x_ready_to_procure   := nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Procure_Yn(P_Action_ID => p_action_version_id ),'N')    ;
          x_planning_initiated := nvl(OKE_DELIVERABLE_UTILS_PUB.MDS_Initiated_Yn(P_Action_ID => p_action_version_id ),'N')       ;
          x_proc_initiated     := nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(P_Action_ID => p_action_version_id ),'N')       ;
          x_shipping_initiated := nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(P_Action_ID => p_action_version_id ),'N')       ;
--          x_item_exists        := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Defined_Yn(P_Action_ID => p_action_version_id ),'N')        ;
          x_item_exists        := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Defined_Yn( p_dlvr_version_id ),'N')        ;
          x_item_shippable     := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Shippable_Yn(P_Deliverable_ID=>p_dlvr_version_id),'N')      ;
          x_item_billable      := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Billable_Yn(P_Deliverable_ID => p_dlvr_version_id ),'N')    ;
          x_item_purchasable   := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Purchasable_Yn(P_Deliverable_ID => p_dlvr_version_id ),'N') ;

          pa_debug.g_err_stage:= 'Inside CREATE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLE_UTILS'
                     ,p_procedure_name  => 'GET_OKE_FLAGS');

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('GET_OKE_FLAGS:'|| g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END GET_OKE_FLAGS ;

-- SubProgram           : IS_TASK_ASSGMNT_EXISTS
-- Type                 : UTIL FUNCTION
-- Purpose              : This procedure will return 'Y' or 'N' based on whether
--                        deliverable is associated with task Assignment or not .
-- Note                 : None
-- Assumption           : None
--
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    ----------     ---------       ---------------------------
-- p_project_id                     IN            NUMBER          Y             Project Id
-- p_dlvr_item_id                   IN            NUMBER          Y             element id of the deliverable
-- p_dlvr_version_id                IN            NUMBER          Y             version id of the deliverable

FUNCTION IS_TASK_ASSGMNT_EXISTS
         ( p_project_id             IN  pa_projects_all.project_id%TYPE
          ,p_dlvr_item_id           IN  pa_proj_elements.proj_element_id%TYPE
          ,p_dlvr_version_id        IN  pa_proj_element_versions.element_version_id%TYPE
          )
RETURN VARCHAR2
IS
     l_task_assignment_exists VARCHAR2(1) := 'N' ;
     CURSOR C IS
     SELECT 'Y'
       FROM dual
      WHERE EXISTS (SELECT 'X'
                      from pa_object_relationships
                     where object_id_to2 = p_dlvr_item_id
                       and object_type_from = 'PA_ASSIGNMENTS'
                       and object_type_to = 'PA_DELIVERABELS'
                       and relationship_type = 'A'
                       and relationship_subtype = 'ASSIGNMENT_TO_DELIVERABLE') ;
BEGIN
     OPEN C ;
     FETCH C INTO l_task_assignment_exists ;
     CLOSE C ;
RETURN l_task_assignment_exists ;
END IS_TASK_ASSGMNT_EXISTS ;


-- SubProgram           : IS_DLV_STATUS_CHANGE_ALLOWED
-- Type                 : UTIL PROCEDURE
-- Purpose              : This procedure will return 'Y' or 'N' based on whether
--                        deliverable status change is allowed or not.
-- Note                 : None
-- Assumption           : None
--
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    ----------     ---------       ---------------------------
-- p_project_id                     IN            NUMBER          Y             Project Id
-- p_dlvr_item_id                   IN            NUMBER          Y             element id of the deliverable
-- p_dlv_type_id                    IN            NUMBER          Y             Deliverable type id
-- p_dlvr_version_id                IN            NUMBER          Y             version id of the deliverable
-- x_return_status                  OUT           VARCHAR2
-- x_msg_count                      OUT           NUMBER
-- x_msg_data                       OUT           VARCHAR2


PROCEDURE IS_DLV_STATUS_CHANGE_ALLOWED
       ( p_project_id             IN  pa_projects_all.project_id%TYPE
        ,p_dlvr_item_id           IN  pa_proj_elements.proj_element_id%TYPE
        ,p_dlvr_version_id        IN  pa_proj_element_versions.element_version_id%TYPE
        ,p_dlv_type_id            IN  pa_task_types.task_type_id%TYPE
        ,p_dlvr_status_code       IN  PA_PROJ_ELEMENTS.STATUS_CODE%TYPE
        ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       )
IS

     -- Cursor to check whether there existis any
     -- action for the deliverable for which either
     -- procurement is initiated or shipping has
     -- been initiated or billing action exists

     CURSOR c_ship_procure_flag_dlv IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE obj.object_id_from2 = p_dlvr_item_id
                        AND obj.object_type_to = 'PA_ACTIONS'
                        AND obj.object_type_from = 'PA_DELIVERABLES'
                        AND obj.object_id_to2 = ver.proj_element_id
                        AND obj.relationship_type = 'A'
                        AND obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
                              AND (nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(ver.element_version_id),'N') = 'Y'
                               OR  nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(ver.element_version_id),'N') = 'Y'
                               OR PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(object_id_to2) = 'BILLING')
                  ) ;

     -- This cursor will fetch the system_status_code
     -- for the given status_code .

     CURSOR c_get_system_status IS
     SELECT project_system_status_code
       FROM pa_project_statuses
      WHERE project_status_code = p_dlvr_status_code
            AND status_type = 'DELIVERABLE' ;
     -- Bug 3503296 In the following cursor ,we have to check
     --"Whether Shipping Or Procurement has NOT been initiated for any of the deliverable's actions"
     --If for atleast one hit that "Either Shipping Or Procurement has not been initiated for some action" then We cannot change
     --the deliverable's status to completed .So,if this cursor returns 'Y' then status change to COMPLETED should not be allowed

     CURSOR c_complete_dlv_check IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE
                            obj.object_id_from2          = p_dlvr_item_id
                        AND obj.object_type_to           = 'PA_ACTIONS'
                        AND obj.object_type_from         = 'PA_DELIVERABLES'
                        AND obj.object_id_to2            = ver.proj_element_id
                        AND
                        (
                          (
                                  PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(object_id_to2) = 'SHIPPING'
        -- Commented for Bug 3503296  AND  nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(ver.element_version_id),'N') = 'Y'
                           AND  nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(ver.element_version_id),'N') = 'N' --Included for Bug 3503296
                          )
                          OR
                          (
                                    PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(object_id_to2) = 'PROCUREMENT'
        -- Commented for Bug 3503296  AND   nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(ver.element_version_id),'N') = 'Y'
                           AND   nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(ver.element_version_id),'N') = 'N' --Included for Bug 3503296
                          )
                        )
                  );


  -- Bug 3512346 CHECK_DELV_EVENT_PROCESSED API was uncommented by avaithia on 01-Apr-2004 (Also,Included Project Id,ElementVerId as params)
     CURSOR c_complete_dlv_bill_check IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE
                            obj.object_id_from2         = p_dlvr_item_id
                        AND obj.object_type_to          = 'PA_ACTIONS'
                        AND obj.object_type_from        = 'PA_DELIVERABLES'
                        AND obj.object_id_to2           = ver.proj_element_id
                        AND
                        (
                                PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(object_id_to2) = 'BILLING'
                            AND nvl(PA_BILLING_WRKBNCH_EVENTS.CHECK_DELV_EVENT_PROCESSED(ver.project_id,p_dlvr_version_id,ver.element_version_id) ,'N') = 'N'
                        )
                  );

     l_system_status_code  pa_lookups.lookup_code%TYPE  ;
     l_status_change_allowed  VARCHAR2(1) ;
BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN c_get_system_status ;
     FETCH c_get_system_status INTO l_system_status_code ;
     IF c_get_system_status%NOTFOUND THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF ;
     CLOSE c_get_system_status ;

     -- Status mapped to system defined DLVR_ON_HOLD/DLVR_CANCELLED
     -- is not allowed if :
     --    1. Billing function extsts
     --    2. Shipping has been initiated for any of the action
     --    3. Procurement has been initiated for any of the action

     IF l_system_status_code IN ('DLVR_ON_HOLD','DLVR_CANCELLED') THEN

          OPEN c_ship_procure_flag_dlv ;
          FETCH c_ship_procure_flag_dlv INTO l_status_change_allowed  ;

          IF c_ship_procure_flag_dlv%NOTFOUND THEN
               l_status_change_allowed := 'Y' ;
          ELSE
               l_status_change_allowed := 'N' ;
               -- 4229934 Added code to populate error  message if dlvr status change to cancel is
               -- not allowed
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLV_STATUS_CHG_NOT_ALLOWED');
               -- 4229934 end
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF ;

          CLOSE c_ship_procure_flag_dlv ;

     ELSE
          l_status_change_allowed := 'Y' ;
     END IF ;

     -- Status mapped to system defined DLVR_COMPLETED is not allowed if
     --   1. Shipping has not been initiated for shipping action.
     --   2. Procurement has not been initiated for procurement action .
     --   3. Event has not been processed by billing action .
     --   4. Document based deliverable has no deliverbale docs. defined.
     --   5. Item based document has no item defined .

     IF l_system_status_code = 'DLVR_COMPLETED' THEN

          IF PA_DELIVERABLE_UTILS.GET_DLV_TYPE_CLASS_CODE(p_dlv_type_id) = 'DOCUMENT' THEN

               IF PA_DELIVERABLE_UTILS.IS_DLV_DOC_DEFINED(p_dlvr_item_id,p_dlvr_version_id) = 'N' THEN
                    l_status_change_allowed := 'N' ;
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                           p_msg_name       => 'PA_DLV_DOC_NOT_DEFINED');
                    x_return_status := FND_API.G_RET_STS_ERROR;
               ELSE
                    l_status_change_allowed := 'Y' ;
               END IF ;

          ELSIF PA_DELIVERABLE_UTILS.GET_DLV_TYPE_CLASS_CODE(p_dlv_type_id) = 'ITEM' THEN

               IF OKE_DELIVERABLE_UTILS_PUB.Item_Defined_Yn(p_dlvr_version_id) = 'N' THEN
                    l_status_change_allowed := 'N' ;
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                           p_msg_name     => 'PA_DLV_ITEM_NOT_DEFINED');
                    x_return_status := FND_API.G_RET_STS_ERROR;
               ELSE
                    l_status_change_allowed := 'Y' ;
               END IF ;

          END IF ;

          OPEN c_complete_dlv_check ;
          FETCH c_complete_dlv_check INTO l_status_change_allowed ;

          IF c_complete_dlv_check%NOTFOUND THEN
               l_status_change_allowed := 'Y' ;
          ELSE
               l_status_change_allowed := 'N' ;
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name     => 'PA_DLV_WSH_REQ_NOT_INITIATED');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF ;
          CLOSE c_complete_dlv_check ;


          OPEN c_complete_dlv_bill_check ;
          FETCH c_complete_dlv_bill_check INTO l_status_change_allowed ;

          IF c_complete_dlv_bill_check%NOTFOUND THEN
               l_status_change_allowed := 'Y' ;
          ELSE
               l_status_change_allowed := 'N' ;
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name     => 'PA_DLV_BILL_EVT_NOT_INITIATED');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF ;
          CLOSE c_complete_dlv_bill_check ;

     END IF ;
EXCEPTION
WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF c_ship_procure_flag_dlv%ISOPEN THEN
        CLOSE c_ship_procure_flag_dlv;
     END IF;

     IF c_complete_dlv_check%ISOPEN THEN
        CLOSE c_complete_dlv_check;
     END IF;

     IF c_complete_dlv_bill_check%ISOPEN THEN
        CLOSE c_complete_dlv_bill_check;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                    , p_procedure_name  => 'IS_DLV_STATUS_CHANGE_ALLOWED'
                    , p_error_text      => x_msg_data);

END IS_DLV_STATUS_CHANGE_ALLOWED ;

-- SubProgram           : GET_DLV_TYPE_CLASS_CODE
-- Type                 : UTIL FUNCTION
-- Purpose              : This procedure will return Deliverable Type Class Code
-- Note                 : None
-- Assumption           : None
--
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    ----------     ---------       ---------------------------
-- p_dlv_type_id                    IN            NUMBER          Y             Deliverable type id

FUNCTION GET_DLV_TYPE_CLASS_CODE
     (
      p_dlvr_type_id IN pa_task_types.task_type_id%TYPE
     )
RETURN VARCHAR2
IS
CURSOR c_dlv_type_class IS
SELECT task_type_class_code
  FROM pa_task_types
 WHERE task_type_id = p_dlvr_type_id ;
 l_task_type_class_code pa_task_types.task_type_class_code%TYPE ;
BEGIN
     OPEN c_dlv_type_class ;
     FETCH c_dlv_type_class INTO l_task_type_class_code ;
     IF c_dlv_type_class%NOTFOUND THEN
          l_task_type_class_code := null ;
     END IF ;
     CLOSE c_dlv_type_class ;
     RETURN l_task_type_class_code ;
END GET_DLV_TYPE_CLASS_CODE ;

-- SubProgram           : GET_FUNCTION_CODE
-- Type                 : UTIL FUNCTION
-- Purpose              : This procedure will return function code of action
-- Note                 : None
-- Assumption           : None
--
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    ----------     ---------       ---------------------------
-- p_action_element_id             IN            NUMBER          Y             Element Id Of Action

FUNCTION GET_FUNCTION_CODE
     (
      p_action_element_id IN pa_proj_elements.proj_element_id%TYPE
      )
RETURN VARCHAR2
IS
     CURSOR c_function_code IS
     SELECT function_code
     FROM pa_proj_elements
     WHERE proj_element_id = p_action_element_id ;
     l_function_code pa_proj_elements.function_code%TYPE ;
BEGIN
     OPEN c_function_code ;
     FETCH c_function_code INTO l_function_code ;
     IF c_function_code%NOTFOUND THEN
          l_function_code := null ;
     END IF ;
     CLOSE c_function_code ;
     RETURN l_function_code ;
END GET_FUNCTION_CODE ;

-- SubProgram           : IS_DLV_DOC_DEFINED
-- Type                 : UTIL FUNCTION
-- Purpose              : This procedure will return 'Y' or 'N' based on whether
--                        Deliverable Documents is defined or not
-- Note                 : None
-- Assumption           : None
--
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    ----------     ---------       ---------------------------
-- p_action_element_id             IN            NUMBER          Y             Element Id Of Action
-- p_dlvr_item_id                  IN            NUMBER          Y             Element Version Id of Action


FUNCTION IS_DLV_DOC_DEFINED
     (
         p_dlvr_item_id         IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
        ,p_dlvr_version_id      IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )  RETURN VARCHAR2
IS

l_doc_defined VARCHAR2(1) := 'N' ;

CURSOR l_doc_exists_csr
IS
SELECT
      'Y'
FROM
      DUAL
WHERE EXISTS
    (
        SELECT
               'Y'
        FROM
               FND_ATTACHED_DOCUMENTS ATT
        WHERE
                  ATT.ENTITY_NAME = 'PA_DLVR_DOC_ATTACH'
              AND ATT.PK1_VALUE   = p_dlvr_version_id
    );

BEGIN

     OPEN l_doc_exists_csr ;
     FETCH l_doc_exists_csr INTO l_doc_defined ;
     CLOSE l_doc_exists_csr ;

     RETURN l_doc_defined ;

EXCEPTION

WHEN NO_DATA_FOUND THEN
         l_doc_defined  := null;
         return l_doc_defined;

WHEN OTHERS THEN

     IF l_doc_exists_csr%ISOPEN THEN
        CLOSE l_doc_exists_csr;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                    , p_procedure_name  => 'IS_DLV_DOC_DEFINED'
                    , p_error_text      => SUBSTRB(SQLERRM,1,240));


     RAISE;

END IS_DLV_DOC_DEFINED;


-- dthakker :: added the following procedures and functions

-- Procedure            : GET_STRUCTURE_INFO
-- Type                 : UTILITY
-- Purpose              : To retrieve Structure Information
-- Note                 : Fetch structure element_id and element_version_id from
--                      : the cursor
-- Assumptions          : Use this API to get structure info of only 'DELIVERABLE' structure type
--                        For other structure types it mau not work
-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_api_version                NUMBER      N           1.0
-- p_calling_module             VARCHAR2    N           := 'SELF_SERVICE'
-- p_project_id                 NUMBER      Y           Project Id
-- p_structure_type             VARCHAR2    Y           Structure Type
-- x_proj_element_id            NUMBER
-- x_element_version_id         NUMBER
-- x_return_status              VARCHAR2    N           Return Status
-- x_msg_count                  NUMBER      N           Message Count
-- x_msg_data                   VARCHAR2    N           Message Data


PROCEDURE GET_STRUCTURE_INFO
    (
         p_api_version              IN      NUMBER   := 1.0
        ,p_calling_module           IN      VARCHAR2 := 'SELF_SERVICE'
        ,p_project_id               IN      PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_structure_type           IN      VARCHAR2 := 'DELIVERABLE'
        ,x_proj_element_id          OUT     NOCOPY PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE --File.Sql.39 bug 4440895
        ,x_element_version_id       OUT     NOCOPY PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE --File.Sql.39 bug 4440895
        ,x_return_status            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
IS
l_msg_count                      NUMBER := 0;
l_data                           VARCHAR2(2000);
l_msg_data                       VARCHAR2(2000);
l_msg_index_out                  NUMBER;
l_debug_mode                     VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

l_object_type                    VARCHAR2(150) := 'PA_STRUCTURES';
l_proj_element_id                NUMBER;
l_element_version_id             NUMBER;

CURSOR l_struct_info_csr
IS
SELECT ppe.proj_element_id
      ,ppe.element_version_id
  FROM pa_proj_elem_ver_structure ppe
      ,pa_proj_structure_types pst
      ,pa_structure_types sty
 WHERE ppe.project_id = p_project_id
   AND ppe.proj_element_id = pst.proj_element_id
   AND pst.structure_type_id = sty.structure_type_id
   AND sty.structure_type = p_structure_type
   AND sty.structure_type_class_code = p_structure_type ;

/* Commented following existing code for Performance Fix : Bug  3614361
   Instead of deriving structure information in the way mentioned in commented code,a better
   approach will be to retrieve the Structure Information from pa_proj_elem_ver_structure table
   as above */

/*Select
     ppe.proj_element_id
    ,pev.element_version_id
From
    pa_proj_elements ppe,
    pa_proj_element_versions pev,
    pa_proj_structure_types pst,
    pa_structure_types st
Where
            ppe.project_id = p_project_id
       and  pev.project_id = p_project_id
       and  ppe.object_type = l_object_type
       and  ppe.proj_element_id = pev.proj_element_id
       and  pev.object_type = l_object_type
       and  ppe.proj_element_id = pst.proj_element_id
       and  pst.STRUCTURE_TYPE_ID = st.STRUCTURE_TYPE_ID
       and  st.structure_type = p_structure_type
       and  st.structure_type_class_code = p_structure_type;
*/

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'GET_STRICTURE_INFO',
                                     p_debug_mode => l_debug_mode );
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'GET_STRICTURE_INFO : Printing Input parameters';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_PROJECT_ID '||':'|| p_project_id,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_STRUCTURE_TYPE '||':'|| p_structure_type,
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'Fetch Structure Info From Cursor';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
    END IF;

    OPEN l_struct_info_csr;
    FETCH l_struct_info_csr INTO l_proj_element_id, l_element_version_id;
    CLOSE l_struct_info_csr;

    x_proj_element_id := l_proj_element_id;
    x_element_version_id := l_element_version_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF l_struct_info_csr%ISOPEN THEN
        CLOSE l_struct_info_csr;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                    , p_procedure_name  => 'GET_STRUCTURE_INFO'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;

END GET_STRUCTURE_INFO;


-- Procedure            : GET_CARRYING_OUT_ORG
-- Type                 : UTILITY
-- Purpose              : To retrieve Carrying Out Organization Id
-- Note                 : Retrieve Carrying Out Organization Id from pa_projects if task_id  is null,
--                      : Retrieve Carrying Out Organization Id from pa_proj_elements if task_id is not null
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_project_id                 NUMBER      Y           Project Id
-- p_task_id                    NUMBER      Y           Task Id

FUNCTION GET_CARRYING_OUT_ORG
        (
             p_project_id   PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
            ,p_task_id      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
        )
        RETURN NUMBER
IS
        x_organization_id      PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE;
BEGIN
        -- if task_id is null then retrive carrying_out_organization_id from pa_projects
        IF (p_task_id IS NULL) THEN
                SELECT
                    p.carrying_out_organization_id    INTO x_organization_id
                FROM
                    PA_PROJECTS_ALL p
                WHERE   p.project_id = p_project_id;
        -- else retrive carrying_out_organization_id from pa_proj_elements
        ELSE
             SELECT
                    ppe.carrying_out_organization_id INTO x_organization_id
             FROM
                    PA_PROJ_ELEMENTS ppe
             WHERE
                        ppe.proj_element_id = p_task_id
                    AND ppe.object_type     = 'PA_TASKS'
                    AND ppe.project_id      = p_project_id;
        END IF;

        return x_organization_id;
EXCEPTION

WHEN NO_DATA_FOUND THEN
         x_organization_id  := null;
         return x_organization_id;

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_CARRYING_OUT_ORG'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         RAISE;

END GET_CARRYING_OUT_ORG;

-- Procedure            : GET_PROGRESS_ROLLUP_METHOD
-- Type                 : UTILITY
-- Purpose              : To retrieve Progress Rollup Method
-- Note                 : Retrieve Progress Rollup Method from pa_proj_elements for task id
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_task_id                    NUMBER      Y           Task Id


FUNCTION GET_PROGRESS_ROLLUP_METHOD
            (
                p_task_id   PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
            )
        RETURN VARCHAR2
IS
        x_base_percent_comp_deriv_code      VARCHAR2(30);
BEGIN
         SELECT ppe.base_percent_comp_deriv_code
           INTO x_base_percent_comp_deriv_code
         FROM   PA_PROJ_ELEMENTS ppe
         WHERE  ppe.proj_element_id = p_task_id
          AND   ppe.object_type = 'PA_TASKS';

        -- 3625019 when task type is changed from update task detail page
        -- base_percent_comp_deriv_code attribute is set to null and task type id
        -- is set to null value

        -- to handle above case, if base_percent_comp_deriv_code is null , retrieve
        -- progress rollup method from task type

        IF x_base_percent_comp_deriv_code IS NULL THEN
                 select ptt.base_percent_comp_deriv_code
                   INTO x_base_percent_comp_deriv_code
                   from pa_task_types ptt,
                        pa_proj_elements ppe
                  where ppe.proj_element_id = p_task_id
                    and ptt.task_type_id = ppe.type_id ;
        END IF;

        return x_base_percent_comp_deriv_code;
EXCEPTION

WHEN NO_DATA_FOUND THEN

         x_base_percent_comp_deriv_code  := null;
         return x_base_percent_comp_deriv_code;

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_PROGRESS_ROLLUP_METHOD'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         RAISE;

END GET_PROGRESS_ROLLUP_METHOD;


-- Procedure            : IS_ACTIONS_EXISTS
-- Type                 : UTILITY
-- Purpose              : To check Deliverable Actions exists for Deliverable
-- Note                 : Used in Update_Deliverable API
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_proj_element_id            NUMBER      Y           Deliverable Id ( Proj Element Id )
-- p_project_id                 NUMBER      Y           Project Id

FUNCTION IS_ACTIONS_EXISTS
    (
         p_project_id        IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_proj_element_id   IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )
        RETURN VARCHAR2
IS
        x_actions_exists        VARCHAR2(1)     := 'N';
        l_relationship_type     VARCHAR2(30)    := 'DELIVERABLE_TO_ACTION';
BEGIN

         SELECT
                'Y' into x_actions_exists
         FROM
                DUAL
         WHERE
         EXISTS
                (
                     SELECT
                            OBJECT_RELATIONSHIP_ID
                     FROM
                            PA_OBJECT_RELATIONSHIPS
                     WHERE
                                OBJECT_ID_FROM2         = p_proj_element_id
                            AND RELATIONSHIP_SUBTYPE    = l_relationship_type
                            AND RELATIONSHIP_TYPE       = 'A'
                );

         return nvl(x_actions_exists,'N');
EXCEPTION

WHEN NO_DATA_FOUND THEN

         x_actions_exists  := 'N';
         return x_actions_exists;

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'IS_ACTIONS_EXISTS'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         RAISE;

END IS_ACTIONS_EXISTS;


-- Procedure            : IS_BILLING_FUNCTION_EXISTS
-- Type                 : UTILITY
-- Purpose              : To check BILLING function exists for Deliverable Actions
-- Note                 : Used in Update_Deliverable API
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_proj_element_id            NUMBER      Y           Deliverable Id ( Proj Element Id )
-- p_project_id                 NUMBER      Y           Project Id

FUNCTION IS_BILLING_FUNCTION_EXISTS
    (
         p_project_id        IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_proj_element_id   IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )
        RETURN VARCHAR2
IS
        x_biling_function_exists        VARCHAR2(1) := 'N';
        l_function_code                 VARCHAR2(30) := 'BILLING';
BEGIN

         SELECT
                'Y' into x_biling_function_exists
         FROM
                DUAL
         WHERE
         EXISTS
                (
                     SELECT
                            PPE.PROJ_ELEMENT_ID
                     FROM
                             PA_OBJECT_RELATIONSHIPS POR
                            ,PA_PROJ_ELEMENTS PPE
                     WHERE
                                POR.OBJECT_ID_FROM2     =  p_proj_element_id
                            AND PPE.PROJ_ELEMENT_ID     =  POR.OBJECT_ID_TO2
                            AND POR.OBJECT_TYPE_FROM    = 'PA_DELIVERABLES'
                            AND POR.OBJECT_TYPE_TO      = 'PA_ACTIONS'
                            AND PPE.FUNCTION_CODE       =  l_function_code
                );

         return nvl(x_biling_function_exists,'N');
EXCEPTION

WHEN NO_DATA_FOUND THEN

         x_biling_function_exists  := 'N';
         return x_biling_function_exists;

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'IS_BILLING_FUNCTION_EXISTS'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         RAISE;

END IS_BILLING_FUNCTION_EXISTS;

-- Procedure            : IS_DELIVERABLE_HAS_PROGRESS
-- Type                 : UTILITY
-- Purpose              : To check Progress Record Exists for Deliverable
-- Note                 : Used in Update_Deliverable API
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_proj_element_id            NUMBER      Y           Deliverable Id ( Proj Element Id )
-- p_project_id                 NUMBER      Y           Project Id

FUNCTION IS_DELIVERABLE_HAS_PROGRESS
    (
         p_project_id        IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_proj_element_id   IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )
        RETURN VARCHAR2
IS
        x_deliverable_has_progress        VARCHAR2(1) := 'N';
BEGIN

        -- 3279978 added function call to check progress records for deliverable

        x_deliverable_has_progress := PA_PROGRESS_UTILS.check_object_has_prog(
                                             p_project_id    =>  p_project_id
                                            ,p_object_id     =>  p_proj_element_id
                                            ,p_object_type   =>  'PA_DELIVERABLES'
                                      );

        return nvl(x_deliverable_has_progress,'N');
EXCEPTION

WHEN NO_DATA_FOUND THEN

         x_deliverable_has_progress  := 'N';
         return x_deliverable_has_progress;

WHEN OTHERS THEN
         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'IS_DELIVERABLE_HAS_PROGRESS'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         RAISE;
END IS_DELIVERABLE_HAS_PROGRESS;


-- Procedure            : GET_DLVR_TYPE_INFO
-- Type                 : UTILITY
-- Purpose              : To retrieve Deliverable Type Info
-- Note                 :
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_type_id               NUMBER      Y           Task Id
-- x_dlvr_prg_enabled           VARCHAR2                dlvr prg flag
-- x_dlvr_action_enabled        VARCHAR2                enable_action_flag
-- x_dlvr_default_status_code   VARCHAR2                default_status_code


PROCEDURE GET_DLVR_TYPE_INFO
            (
                 p_dlvr_type_id              IN   PA_TASK_TYPES.TASK_TYPE_ID%TYPE
                ,x_dlvr_prg_enabled          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_dlvr_action_enabled       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_dlvr_default_status_code  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            )
IS
CURSOR l_dlvr_type_info_csr
IS
     SELECT
             ptt.prog_entry_enable_flag
            ,ptt.enable_dlvr_actions_flag
            ,ptt.initial_status_code
     FROM
            PA_TASK_TYPES ptt
     WHERE
                ptt.task_type_id = p_dlvr_type_id
            AND ptt.object_type = 'PA_DLVR_TYPES';

BEGIN

        OPEN l_dlvr_type_info_csr;
        FETCH l_dlvr_type_info_csr INTO x_dlvr_prg_enabled, x_dlvr_action_enabled, x_dlvr_default_status_code;
        CLOSE l_dlvr_type_info_csr;

EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'IS_DLVR_PRG_ENABLED'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_dlvr_type_info_csr%ISOPEN THEN
            CLOSE l_dlvr_type_info_csr;
         END IF;

         RAISE;

END GET_DLVR_TYPE_INFO;

-- Procedure            : GET_DLVR_DETAIL
-- Type                 : UTILITY
-- Purpose              : To retrieve Deliverable name and number
-- Note                 : Retrieve Name and Number from pa_proj_elements
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_version_id            NUMBER      Y           Deliverable Version Id
-- x_name                       VARCHAR2                Deliverable Name
-- x_number                     VARCHAR2                Deliverable Number


PROCEDURE GET_DLVR_DETAIL
    (
          p_dlvr_ver_id         IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
         ,x_name                OUT     NOCOPY PA_PROJ_ELEMENTS.NAME%TYPE --File.Sql.39 bug 4440895
         ,x_number              OUT     NOCOPY PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE --File.Sql.39 bug 4440895
    )
IS
CURSOR l_dlvr_info_csr
IS
        SELECT
            PPE.NAME,
            PPE.ELEMENT_NUMBER
        FROM
            PA_PROJ_ELEMENTS PPE,
            PA_PROJ_ELEMENT_VERSIONS PEV
        WHERE
                PEV.ELEMENT_VERSION_ID  = p_dlvr_ver_id
            AND PPE.PROJECT_ID          = PEV.PROJECT_ID
            AND PPE.PROJ_ELEMENT_ID     = PEV.PROJ_ELEMENT_ID
            AND PPE.OBJECT_TYPE         = 'PA_DELIVERABLES'
            AND PEV.OBJECT_TYPE         = 'PA_DELIVERABLES';

BEGIN

        OPEN l_dlvr_info_csr;
        FETCH l_dlvr_info_csr INTO x_name, x_number;
        CLOSE l_dlvr_info_csr;

EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_DLVR_DETAIL'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_dlvr_info_csr%ISOPEN THEN
            CLOSE l_dlvr_info_csr;
         END IF;

         RAISE;

END GET_DLVR_DETAIL;


-- Procedure            : GET_ACTION_DETAIL
-- Type                 : UTILITY
-- Purpose              : To retrieve Deliverable Action name and number
-- Note                 : Retrieve Action Name and Number from pa_proj_elements
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_action_ver_id         NUMBER      Y           Delivearble Action Version Id
-- x_name                       VARCHAR2                Deliverable Action Name
-- x_number                     VARCHAR2                Deliverable Action Number


PROCEDURE GET_ACTION_DETAIL
    (
          p_dlvr_action_ver_id       IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
         ,x_name                     OUT     NOCOPY PA_PROJ_ELEMENTS.NAME%TYPE --File.Sql.39 bug 4440895
         ,x_number                   OUT     NOCOPY PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE --File.Sql.39 bug 4440895
    )
IS

CURSOR l_dlvr_action_info_csr
IS
        SELECT
            PPE.NAME,
            PPE.ELEMENT_NUMBER
        FROM
            PA_PROJ_ELEMENTS PPE,
            PA_PROJ_ELEMENT_VERSIONS PEV
        WHERE
                PEV.ELEMENT_VERSION_ID  = p_dlvr_action_ver_id
            AND PPE.PROJECT_ID          = PEV.PROJECT_ID
            AND PPE.PROJ_ELEMENT_ID     = PEV.PROJ_ELEMENT_ID
            AND PPE.OBJECT_TYPE         = 'PA_ACTIONS'
            AND PEV.OBJECT_TYPE         = 'PA_ACTIONS';


BEGIN

        OPEN l_dlvr_action_info_csr;
        FETCH l_dlvr_action_info_csr INTO x_name, x_number;
        CLOSE l_dlvr_action_info_csr;

EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_ACTION_DETAIL'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_dlvr_action_info_csr%ISOPEN THEN
            CLOSE l_dlvr_action_info_csr;
         END IF;

         RAISE;

END GET_ACTION_DETAIL;


-- Procedure            : GET_PROJ_CURRENCY_CODE
-- Type                 : UTILITY
-- Purpose              : To retrieve Project Currency Code
-- Note                 : Retrieve projfunc_currency_code from pa_projects_all
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_ver_id                NUMBER      Y           Deliverable Version Id


FUNCTION GET_PROJ_CURRENCY_CODE
            (
                p_dlvr_ver_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
            )
        RETURN VARCHAR2
IS
        x_proj_currency_code      PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE  := null;

CURSOR l_proj_currency_code_csr
IS
        SELECT
               PPA.PROJFUNC_CURRENCY_CODE
        FROM
               PA_PROJECTS_ALL PPA,
               PA_PROJ_ELEMENT_VERSIONS PEV
        WHERE
                    PEV.ELEMENT_VERSION_ID = p_dlvr_ver_id
               AND  PEV.PROJECT_ID = PPA.PROJECT_ID
               AND  PEV.OBJECT_TYPE = 'PA_DELIVERABLES';

BEGIN

        OPEN l_proj_currency_code_csr;
        FETCH l_proj_currency_code_csr INTO x_proj_currency_code;
        CLOSE l_proj_currency_code_csr;

        return x_proj_currency_code;

EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_PROJ_CURRENCY_CODE'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         RAISE;

END GET_PROJ_CURRENCY_CODE;

-- Procedure            : GET_DLVR_PROJECT_DETAIL
-- Type                 : UTILITY
-- Purpose              : To retrieve Project Id and name
-- Note                 : Retrieve Project Id and Name from pa_projects_all
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_ver_id                NUMBER      Y           Delivearble Version Id
-- x_project_id                 NUMBER                  Project Id
-- x_project_name               VARCHAR2                Project Name


PROCEDURE GET_DLVR_PROJECT_DETAIL
    (
          p_dlvr_ver_id       IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
         ,x_project_id        OUT     NOCOPY PA_PROJ_ELEMENTS.PROJECT_ID%TYPE --File.Sql.39 bug 4440895
         ,x_project_name      OUT     NOCOPY PA_PROJECTS_ALL.NAME%TYPE --File.Sql.39 bug 4440895
    )
IS

CURSOR l_project_info_csr
IS
        SELECT
               PPA.PROJECT_ID,
               PPA.NAME
        FROM
               PA_PROJECTS_ALL PPA,
               PA_PROJ_ELEMENT_VERSIONS PEV
        WHERE
                    PEV.ELEMENT_VERSION_ID  = p_dlvr_ver_id
               AND  PEV.PROJECT_ID          = PPA.PROJECT_ID
               AND  PEV.OBJECT_TYPE         = 'PA_DELIVERABLES';

BEGIN

        OPEN l_project_info_csr;
        FETCH l_project_info_csr INTO x_project_id, x_project_name;
        CLOSE l_project_info_csr;

EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_DLVR_PROJECT_DETAIL'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_project_info_csr%ISOPEN THEN
            CLOSE l_project_info_csr;
         END IF;

         RAISE;

END GET_DLVR_PROJECT_DETAIL;


-- Procedure            : GET_ACTION_PROJECT_DETAIL
-- Type                 : UTILITY
-- Purpose              : To retrieve Project Id and name
-- Note                 : Retrieve Project Id and Name from pa_projects_all
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_action_ver_id         NUMBER      Y           Delivearble Action Version Id
-- x_project_id                 NUMBER                  Project Id
-- x_project_name               VARCHAR2                Project Name


PROCEDURE GET_ACTION_PROJECT_DETAIL
    (
          p_dlvr_action_ver_id       IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
         ,x_project_id               OUT     NOCOPY PA_PROJ_ELEMENTS.PROJECT_ID%TYPE --File.Sql.39 bug 4440895
         ,x_project_name             OUT     NOCOPY PA_PROJECTS_ALL.NAME%TYPE --File.Sql.39 bug 4440895
    )
IS

CURSOR l_project_info_csr
IS
        SELECT
               PPA.PROJECT_ID,
               PPA.NAME
        FROM
               PA_PROJECTS_ALL PPA,
               PA_PROJ_ELEMENT_VERSIONS PEV
        WHERE
                    PEV.ELEMENT_VERSION_ID = p_dlvr_action_ver_id
               AND  PEV.PROJECT_ID = PPA.PROJECT_ID
               AND  PEV.OBJECT_TYPE = 'PA_ACTIONS';

BEGIN

        OPEN l_project_info_csr;
        FETCH l_project_info_csr INTO x_project_id, x_project_name;
        CLOSE l_project_info_csr;

EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_ACTION_PROJECT_DETAIL'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_project_info_csr%ISOPEN THEN
            CLOSE l_project_info_csr;
         END IF;

         RAISE;

END GET_ACTION_PROJECT_DETAIL;


-- Procedure            : GET_ACTION_TASK_DETAIL
-- Type                 : UTILITY
-- Purpose              : To retrieve Task  number
-- Note                 : Retrieve Task Number
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_task_id                    NUMBER                  Task Versioin Id


FUNCTION GET_ACTION_TASK_DETAIL
    (
          p_task_id                  IN     PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
    )   RETURN VARCHAR2
IS

l_task_number       VARCHAR2(340) ;

CURSOR l_task_info_csr
IS
        SELECT
               PPE. NAME||'('|| PPE.ELEMENT_NUMBER||')' NAME_NUMBER
        FROM
               PA_PROJ_ELEMENTS PPE
        WHERE PPE.PROJ_ELEMENT_ID    = p_task_id
              AND PPE.OBJECT_TYPE    = 'PA_TASKS';

BEGIN

        OPEN l_task_info_csr;
        FETCH l_task_info_csr INTO l_task_number;
        CLOSE l_task_info_csr;

        return l_task_number;
EXCEPTION

WHEN OTHERS THEN

         IF l_task_info_csr%ISOPEN THEN
            CLOSE l_task_info_csr;
         END IF;

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_ACTION_TASK_DETAIL'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         RAISE;

END GET_ACTION_TASK_DETAIL;


-- Procedure            : GET_DEFAULT_DLVR_OWNER
-- Type                 : UTILITY
-- Purpose              : To retrieve Default Deliverable Owner Id And Name
-- Note                 :
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_project_id                 NUMBER      Y           Project Id
-- p_task_ver_id                NUMBER      Y           Task Version Id
-- x_owner_id                   NUMBER                  Owner Id
-- x_owner_name                 VARCHAR                 Owner Name

PROCEDURE GET_DEFAULT_DLVR_OWNER
    (
         p_project_id                   IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
        ,p_task_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_owner_id                     OUT     NOCOPY PER_ALL_PEOPLE_F.PERSON_ID%TYPE --File.Sql.39 bug 4440895
        ,x_owner_name                   OUT     NOCOPY PER_ALL_PEOPLE_F.FULL_NAME%TYPE --File.Sql.39 bug 4440895
    )
IS

CURSOR l_owner_info_csr
IS
        SELECT
                PPF.PERSON_ID
               ,PPF.FULL_NAME
        FROM
               PA_PROJ_ELEMENTS PPE,
               PER_ALL_PEOPLE_F PPF,
               PA_PROJ_ELEMENT_VERSIONS PEV
        WHERE
                   PEV.ELEMENT_VERSION_ID   = p_task_ver_id
               AND PEV.OBJECT_TYPE          = 'PA_TASKS'
               AND PEV.PROJ_ELEMENT_ID   = PPE.PROJ_ELEMENT_ID
               AND PPE.OBJECT_TYPE          = 'PA_TASKS'
               AND PPE.MANAGER_PERSON_ID    = PPF.PERSON_ID
               AND PPE.PROJECT_ID            = p_project_id
               AND PEV.PROJECT_ID            = p_project_id
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;

BEGIN

        IF p_task_ver_id IS NOT NULL THEN
            OPEN l_owner_info_csr;
            FETCH l_owner_info_csr INTO x_owner_id, x_owner_name;
            CLOSE l_owner_info_csr;
        ELSE
            x_owner_id      :=  PA_PROJECT_PARTIES_UTILS.GET_PROJECT_MANAGER
                                    (
                                        p_project_id    =>  p_project_id
                                    );
            x_owner_name    :=  PA_PROJECT_PARTIES_UTILS.GET_PROJECT_MANAGER_NAME
                                    (
                                        p_project_id    =>  p_project_id
                                    );
        END IF;
EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_DEFAULT_DLVR_OWNER'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_owner_info_csr%ISOPEN THEN
            CLOSE l_owner_info_csr;
         END IF;

         RAISE;

END GET_DEFAULT_DLVR_OWNER;


-- Procedure            : GET_DEFAULT_DLVR_DATE
-- Type                 : UTILITY
-- Purpose              : To retrieve Default Deliverable Due Date
-- Note                 :
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_project_id                 NUMBER      Y           Project Id
-- p_task_ver_                  NUMBER      Y           Task Version Id
-- x_due_date                   DATE                    Dlvr Due Date

PROCEDURE GET_DEFAULT_DLVR_DATE
    (
         p_project_id                   IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
        ,p_task_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_due_date                     OUT     NOCOPY DATE --File.Sql.39 bug 4440895
    )
IS

l_scheduled_finish_date                 DATE    := NULL;
l_target_finish_date                    DATE    := NULL;
l_completion_date                       DATE    := NULL;
l_sysdate                               DATE    := NULL;

CURSOR l_proj_date_info_csr
IS
        SELECT
               SCHEDULED_FINISH_DATE,
               TARGET_FINISH_DATE,
               COMPLETION_DATE,
               SYSDATE
        FROM
               PA_PROJECTS_ALL
        WHERE
               PROJECT_ID = p_project_id;


CURSOR l_task_date_info_csr
IS
      SELECT
             PES.SCHEDULED_FINISH_DATE,
             SYSDATE
      FROM
              PA_PROJ_ELEMENT_VERSIONS  PEV
             ,PA_PROJ_ELEM_VER_SCHEDULE PES
      WHERE
                 PEV.ELEMENT_VERSION_ID = p_task_ver_id
             AND PEV.ELEMENT_VERSION_ID = PES.ELEMENT_VERSION_ID ;

            /* AND PEV.OBJECT_TYPE        = 'PA_TASKS'
             AND PES.PROJECT_ID         = p_project_id;Commented Unnecessary joins -
             This Query was flagged by xpl utility because of missing index PA_PROJ_ELEM_VER_SCHEDULE_U2 in ch2m  3614361 */

BEGIN

        IF p_task_ver_id IS NOT NULL THEN

            OPEN l_task_date_info_csr;
            FETCH l_task_date_info_csr INTO l_scheduled_finish_date ,l_sysdate;
            CLOSE l_task_date_info_csr;

            IF l_scheduled_finish_date IS NOT NULL THEN
                x_due_date  :=  l_scheduled_finish_date;
            ELSE
                x_due_date  :=  l_sysdate;
            END IF;

        ELSE

            OPEN l_proj_date_info_csr;
            FETCH l_proj_date_info_csr INTO l_scheduled_finish_date, l_target_finish_date, l_completion_date, l_sysdate ;
            CLOSE l_proj_date_info_csr;


            IF l_scheduled_finish_date IS NOT NULL THEN
                x_due_date  :=  l_scheduled_finish_date;
            ELSIF l_target_finish_date IS NOT NULL THEN
                x_due_date  :=  l_target_finish_date;
            ELSIF l_completion_date IS NOT NULL THEN
                x_due_date  :=  l_completion_date;
            ELSE
                x_due_date  :=  l_sysdate;
            END IF;

        END IF;
EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_DEFAULT_DLVR_DATE'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_proj_date_info_csr%ISOPEN THEN
            CLOSE l_proj_date_info_csr;
         END IF;

         IF l_task_date_info_csr%ISOPEN THEN
            CLOSE l_task_date_info_csr;
         END IF;

         RAISE;

END GET_DEFAULT_DLVR_DATE;


-- Procedure            : GET_DEFAULT_ACTION_OWNER
-- Type                 : UTILITY
-- Purpose              : To retrieve Default Deliverable Owner Id And Name
-- Note                 :
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_verid                 NUMBER      Y           Deliverable Version Id
-- x_owner_id                   NUMBER                  Owner Id
-- x_owner_name                 VARCHAR                 Owner Name

PROCEDURE GET_DEFAULT_ACTION_OWNER
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_owner_id                     OUT     NOCOPY PER_ALL_PEOPLE_F.PERSON_ID%TYPE --File.Sql.39 bug 4440895
        ,x_owner_name                   OUT     NOCOPY PER_ALL_PEOPLE_F.FULL_NAME%TYPE --File.Sql.39 bug 4440895
    )
IS

CURSOR l_owner_info_csr
IS
         SELECT
                 PPF.PERSON_ID
                ,PPF.FULL_NAME
         FROM
                 PA_PROJ_ELEMENT_VERSIONS PEV
                ,PA_PROJ_ELEMENTS PPE
                ,PER_ALL_PEOPLE_F PPF
         WHERE
                    PEV.ELEMENT_VERSION_ID       = p_dlvr_ver_id
                AND PPE.OBJECT_TYPE              = 'PA_DELIVERABLES'
                AND PPE.PROJ_ELEMENT_ID          = PEV.PROJ_ELEMENT_ID
                AND PEV.OBJECT_TYPE              = 'PA_DELIVERABLES'
                AND PPE.MANAGER_PERSON_ID        = PPF.PERSON_ID
                AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;

BEGIN

         OPEN l_owner_info_csr;
         FETCH l_owner_info_csr INTO x_owner_id, x_owner_name;
         CLOSE l_owner_info_csr;

EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_DEFAULT_ACTION_OWNER'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_owner_info_csr%ISOPEN THEN
            CLOSE l_owner_info_csr;
         END IF;

         RAISE;

END GET_DEFAULT_ACTION_OWNER;


-- Procedure            : GET_DEFAULT_ACTION_DATE
-- Type                 : UTILITY
-- Purpose              : To retrieve Default Deliverable Action Due Date
-- Note                 :
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_ver_id                NUMBER      Y           Dlvr Ver Id
-- p_task_ver_id                NUMBER      Y           Task Ver Id
-- p_calling_mode               NUMBER      Y           Possible Values are 'TEMPLATE', 'PROJECT'
-- x_due_date                   DATE                    Dlvr Due Date
-- x_earliest_start_date        DATE                    Earliest Start Date
-- x_earliest_finish_date       DATE                    Earliest Finish Date

PROCEDURE GET_DEFAULT_ACTION_DATE
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,p_task_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,p_project_mode                 IN      VARCHAR2
        ,p_function_code                IN      PA_PROJ_ELEMENTS.FUNCTION_CODE%TYPE
        ,x_due_date                     OUT     NOCOPY DATE --File.Sql.39 bug 4440895
    )
IS

l_scheduled_finish_date                 DATE    := NULL;
l_task_scheduled_finish_date            DATE    := NULL;
l_sysdate                               DATE    := NULL;
l_earliest_start_date                   DATE    := NULL;
l_earliest_finish_date                  DATE    := NULL;

CURSOR l_proj_date_info_csr
IS
      SELECT
             PES.SCHEDULED_FINISH_DATE,
             SYSDATE
      FROM
             PA_PROJ_ELEMENT_VERSIONS  PEV,
             PA_PROJ_ELEM_VER_SCHEDULE PES
      WHERE
                 PEV.ELEMENT_VERSION_ID = p_dlvr_ver_id
             AND PEV.ELEMENT_VERSION_ID = PES.ELEMENT_VERSION_ID ;

         /*  AND PEV.OBJECT_TYPE        = 'PA_DELIVERABLES'
         AND PEV.PROJECT_ID         = PES.PROJECT_ID;
            Commented Unwanted Joins - This query was flagged by xpl utility because of missing index
            PA_PROJ_ELEM_VER_SCHEDULE_U2 in ch2m database Bug  3614361 */

CURSOR l_task_date_info_csr
IS
      SELECT
              PES.EARLY_START_DATE
             ,PES.EARLY_FINISH_DATE
             ,PES.SCHEDULED_FINISH_DATE
      FROM
              PA_PROJ_ELEMENT_VERSIONS  PEV
             ,PA_PROJ_ELEM_VER_SCHEDULE PES
      WHERE
                 PEV.ELEMENT_VERSION_ID = p_task_ver_id
             AND PEV.ELEMENT_VERSION_ID = PES.ELEMENT_VERSION_ID ;

        /*     AND PEV.OBJECT_TYPE        = 'PA_TASKS'
         AND PEV.PROJECT_ID = PES.PROJECT_ID;
            Commented Unwanted Joins - This query was flagged by xpl utility because of missing index
            PA_PROJ_ELEM_VER_SCHEDULE_U2 in ch2m database Bug  3614361 */
BEGIN

        OPEN l_proj_date_info_csr;
        FETCH l_proj_date_info_csr INTO l_scheduled_finish_date, l_sysdate;
        CLOSE l_proj_date_info_csr;

        IF p_task_ver_id IS NULL THEN
            IF l_scheduled_finish_date IS NOT NULL THEN
                x_due_date  :=  l_scheduled_finish_date;
            ELSE
                x_due_date  :=  l_sysdate;
            END IF;
        ELSE
            IF p_project_mode = 'TEMPLATE' THEN
                IF l_scheduled_finish_date IS NOT NULL THEN
                    x_due_date  :=  l_scheduled_finish_date;
                ELSE
                    x_due_date  :=  l_sysdate;
                END IF;
            ELSE
                OPEN l_task_date_info_csr;
                FETCH l_task_date_info_csr INTO l_earliest_start_date, l_earliest_finish_date, l_task_scheduled_finish_date;
                CLOSE l_task_date_info_csr;

                IF p_function_code = 'PROCUREMENT' THEN
                        x_due_date :=  l_earliest_start_date;
                ELSIF p_function_code = 'SHIPPING' THEN
                        x_due_date :=  l_earliest_finish_date;
                ELSE
                    IF l_scheduled_finish_date IS NOT NULL THEN
                        x_due_date  :=  l_scheduled_finish_date;
                    ELSIF l_task_scheduled_finish_date IS NOT NULL THEN
                        x_due_date  :=  l_task_scheduled_finish_date;
                    ELSE
                        x_due_date  :=  l_sysdate;
                    END IF;
                END IF;

                IF p_function_code = 'PROCUREMENT' or p_function_code = 'SHIPPING' THEN
                    IF x_due_date IS NULL THEN
                        IF l_scheduled_finish_date IS NOT NULL THEN
                            x_due_date  :=  l_scheduled_finish_date;
                        ELSIF l_task_scheduled_finish_date IS NOT NULL THEN
                            x_due_date  :=  l_task_scheduled_finish_date;
                        ELSE
                            x_due_date  :=  l_sysdate;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_DEFAULT_ACTION_DATE'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_proj_date_info_csr%ISOPEN THEN
            CLOSE l_proj_date_info_csr;
         END IF;

         IF l_task_date_info_csr%ISOPEN THEN
            CLOSE l_task_date_info_csr;
         END IF;

         RAISE;

END GET_DEFAULT_ACTION_DATE;

-- API to check whether deliverable based association
-- exists for Deliverable

FUNCTION IS_DLV_BASED_ASSCN_EXISTS
     (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
         ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE := NULL
     )
RETURN VARCHAR2
IS
l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;
-- Bug: 3902158 - Changing Cursor query to avoid call to function PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD
/*CURSOR c_dlv_based_task_exists IS
SELECT 'X'
FROM DUAL
WHERE EXISTS (SELECT 'X'
              FROM PA_OBJECT_RELATIONSHIPS obj,
                  PA_PROJ_ELEMENTS ppe
                   where ppe.proj_element_id = p_dlv_element_id
                    and ppe.object_type= 'PA_DELIVERABLES'
                    and obj.object_id_to2 = ppe.proj_element_id
                    and obj.object_type_from  = 'PA_TASKS'
                    and obj.object_type_to  = 'PA_DELIVERABLES' -- 3570283 removed extra spaces
                    and obj.relationship_subtype  = 'TASK_TO_DELIVERABLE'
                    and obj.relationship_type  = 'A'
                    and nvl(PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(obj.object_id_from2),'X') = 'DELIVERABLE'
                   ); */

CURSOR c_dlv_based_task_exists IS
SELECT 'X'
 FROM DUAL
 WHERE EXISTS (SELECT 'X'
               FROM PA_OBJECT_RELATIONSHIPS obj,
                pa_proj_elements ppe,
            pa_task_types ptt
               where obj.object_id_to2 = p_dlv_element_id
                 and obj.object_type_from  = 'PA_TASKS'
                 and obj.object_type_to  = 'PA_DELIVERABLES'
                 and obj.relationship_subtype  = 'TASK_TO_DELIVERABLE'
                 and obj.relationship_type  = 'A'
                 and ppe.proj_element_id = obj.object_id_from2
                 and ppe.type_id=ptt.task_type_id
                 and nvl(ppe.base_percent_comp_deriv_code,ptt.base_percent_comp_deriv_code) =  'DELIVERABLE');


BEGIN
     OPEN c_dlv_based_task_exists;
     FETCH c_dlv_based_task_exists into l_dummy ;
     IF c_dlv_based_task_exists%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE c_dlv_based_task_exists;
     return l_return_status;
END IS_DLV_BASED_ASSCN_EXISTS ;

-- This function will return 'Y' if there exists any action
-- with ready to ship flag as 'Y'

FUNCTION GET_READY_TO_SHIP_FLAG
     (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
          ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR ship_flag_dlv IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE obj.object_id_from2 = p_dlv_element_id
                        AND obj.object_type_to = 'PA_ACTIONS'
                        AND obj.object_type_from = 'PA_DELIVERABLES'
                        AND obj.object_id_to2 = ver.proj_element_id
                        AND obj.relationship_type = 'A'
                        AND obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
                        AND nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Ship_Yn(ver.element_version_id),'N') = 'Y'
                  ) ;
l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;
BEGIN
     OPEN ship_flag_dlv;
     FETCH ship_flag_dlv into l_dummy ;
     IF ship_flag_dlv%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE ship_flag_dlv;
return l_return_status;
END GET_READY_TO_SHIP_FLAG ;

FUNCTION GET_READY_TO_PROC_FLAG
     (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
          ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR proc_flag_dlv IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE obj.object_id_from2 = p_dlv_element_id
                        AND obj.object_type_to = 'PA_ACTIONS'
                        AND obj.object_type_from = 'PA_DELIVERABLES'
                        AND obj.object_id_to2 = ver.proj_element_id
                        AND obj.relationship_type = 'A'
                        AND obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
                        AND nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Procure_Yn(ver.element_version_id),'N') = 'Y'
                   ) ;
l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;
BEGIN
     OPEN proc_flag_dlv;
     FETCH proc_flag_dlv into l_dummy ;
     IF proc_flag_dlv%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE proc_flag_dlv;
return l_return_status;
END GET_READY_TO_PROC_FLAG ;

-- This API will return 'Y' if for a task if there exists any
-- progress enabled deliverable .

FUNCTION IS_PROG_ENABLED_DLV_EXISTS
     (
          p_proj_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR c_prog_enabled_dlv_exists IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_elements ppe
                           ,pa_task_types  ptt
                      WHERE obj.object_id_from2 = p_proj_element_id
                        AND obj.object_type_to = 'PA_DELIVERABLES'
                        AND obj.object_type_from = 'PA_TASKS'
                        AND obj.relationship_type = 'A'
                        AND obj.relationship_subtype = 'TASK_TO_DELIVERABLE'
                        AND obj.object_id_to2 = ppe.proj_element_id
                        AND ppe.object_type = 'PA_DELIVERABLES'
                        AND ptt.task_type_id = ppe.type_id
                        AND nvl(ptt.prog_entry_enable_flag ,'N') = 'Y'
                   ) ;
l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;
BEGIN
     OPEN c_prog_enabled_dlv_exists;
     FETCH c_prog_enabled_dlv_exists into l_dummy ;
     IF c_prog_enabled_dlv_exists%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE c_prog_enabled_dlv_exists;
return l_return_status;
END IS_PROG_ENABLED_DLV_EXISTS;

-- This API will return 'Y' is progress is enabled for deliverable

FUNCTION IS_PROGRESS_ENABLED
     (
          p_proj_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR c_is_prog_enabled_dlv IS
     SELECT 'Y'
       FROM pa_proj_elements ppe
           ,pa_task_types ptt
      WHERE ppe.proj_element_id = p_proj_element_id
       AND  ppe.object_type = 'PA_DELIVERABLES'
       AND  ptt.task_type_id = ppe.type_id
       AND  nvl(ptt.prog_entry_enable_flag,'N') = 'Y'
       AND  ptt.object_type = 'PA_DLVR_TYPES' ;

l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;

BEGIN
     OPEN c_is_prog_enabled_dlv;
     FETCH c_is_prog_enabled_dlv into l_dummy ;
     IF c_is_prog_enabled_dlv%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE c_is_prog_enabled_dlv;
return l_return_status;
END IS_PROGRESS_ENABLED;

-- Procedure            : GET_PROJECT_DETAILS
-- Type                 : UTILITY
-- Purpose              : To retrieve Project Currency Code and Organization Id
-- Note                 :
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_project_id                 NUMBER      Y           Project Id
-- x_projfunc_currency_code     VARCHAR                 Project Currency Code
-- x_org_id                     VARCHAR                 Organization Id

PROCEDURE GET_PROJECT_DETAILS
    (
         p_project_id                   IN      PA_PROJECTS_ALL.PROJECT_ID%TYPE
        ,x_projfunc_currency_code       OUT     NOCOPY PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE --File.Sql.39 bug 4440895
        ,x_org_id                       OUT     NOCOPY PA_PLAN_RES_DEFAULTS.item_master_id%TYPE -- 3462360 changed type --File.Sql.39 bug 4440895
    )
IS

l_return_status     VARCHAR2(1) := 'S';
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

CURSOR l_project_detail_csr
IS
        SELECT
                P.PROJFUNC_CURRENCY_CODE
--               ,P.ORG_ID              -- 3462360 removed org_id column
        FROM
               PA_PROJECTS_ALL P
        WHERE
               P.PROJECT_ID = p_project_id;

BEGIN

         OPEN l_project_detail_csr;
         FETCH l_project_detail_csr INTO x_projfunc_currency_code;
         CLOSE l_project_detail_csr;

         -- 3462360 added procedure call to retrieve material_Class_id

         PA_RESOURCE_UTILS1.Return_Material_Class_Id
                                   (
                                         x_material_class_id     =>  x_org_id
                                        ,x_return_status         =>  l_return_status
                                        ,x_msg_data              =>  l_msg_data
                                        ,x_msg_count             =>  l_msg_count
                                   );

EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_PROJECT_DETAILS'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_project_detail_csr%ISOPEN THEN
            CLOSE l_project_detail_csr;
         END IF;

         RAISE;

END GET_PROJECT_DETAILS;

FUNCTION GET_DLV_DESCRIPTION
     (
          p_action_ver_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR c_dlv_desc IS
     SELECT ppe.description
       FROM pa_proj_elements ppe
           ,pa_object_relationships obj
           ,pa_proj_element_versions pev
      WHERE pev.element_version_id = p_action_ver_id
       AND pev.object_type = 'PA_ACTIONS' /*Included this clause for Performance fix Bug # 3614361 */
       AND  pev.proj_element_id = obj.object_id_to2
       AND  obj.relationship_type = 'A'
       AND  obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
       AND  obj.object_type_from = 'PA_DELIVERABLES'
       AND  obj.object_type_to = 'PA_ACTIONS'
       AND  obj.object_id_from2 = ppe.proj_element_id
       AND  ppe.object_type = 'PA_DELIVERABLES' /*Included this clause for Performance fix Bug # 3614361 */
       ;

l_dummy pa_proj_elements.description%TYPE;
BEGIN
     OPEN c_dlv_desc;
     FETCH c_dlv_desc into l_dummy ;
     CLOSE c_dlv_desc;
     RETURN l_dummy ;
END GET_DLV_DESCRIPTION;

-- 3470061 oke needed this api which will take deliverable version id as in parameter
-- and return deliverable description

FUNCTION GET_DELIVERABLE_DESCRIPTION
     (
          p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR c_dlv_desc IS
     SELECT
        ppe.description
       FROM
        pa_proj_elements ppe
           ,pa_proj_element_versions pev
      WHERE
        pev.element_version_id =  p_deliverable_id
           AND  ppe.object_type        =  'PA_DELIVERABLES'
           AND  pev.object_type        =  'PA_DELIVERABLES'
       AND  ppe.proj_element_id    =  pev.proj_element_id
       AND  ppe.project_id         =  pev.project_id;

l_dummy pa_proj_elements.description%TYPE;

BEGIN
     OPEN c_dlv_desc;
     FETCH c_dlv_desc into l_dummy ;
     CLOSE c_dlv_desc;
     RETURN l_dummy ;

END GET_DELIVERABLE_DESCRIPTION;

-- 3470061

FUNCTION IS_DLV_ITEM_BASED
     (
          p_action_ver_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR  c_is_dlv_item_based IS
      SELECT 'Y'
       FROM  dual
WHERE EXISTS (SELECT 'Y'
                FROM pa_proj_elements ppe
                    ,pa_object_relationships obj
                    ,pa_proj_element_versions pev
                    ,pa_task_types ptt
                WHERE pev.element_version_id = p_action_ver_id
                  AND pev.proj_element_id = obj.object_id_to2
                  AND obj.relationship_type = 'A'
                  AND obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
                  AND obj.object_type_from = 'PA_DELIVERABLES'
                  AND obj.object_type_to = 'PA_ACTIONS'
                  AND obj.object_id_from2 = ppe.proj_element_id
                  AND ptt.task_type_id = ppe.type_id
                  AND ptt.task_type_class_code = 'ITEM'
             ) ;
l_dummy VARCHAR2(1) := 'N' ;
BEGIN
     OPEN c_is_dlv_item_based;
     FETCH c_is_dlv_item_based into l_dummy ;
     CLOSE c_is_dlv_item_based;
     RETURN l_dummy ;
END IS_DLV_ITEM_BASED ;

-- Procedure            : GET_DEFAULT_ACTN_DATE
-- Type                 : UTILITY
-- Purpose              : To retrieve Default Deliverable Due Date
-- Note                 :
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_dlvr_ver_id                NUMBER      Y           Dlvr Ver Id
-- p_task_ver_id                NUMBER      Y           Task Ver Id
-- p_project_mode               NUMBER      Y           Possible Values are 'TEMPLATE', 'PROJECT'
-- x_due_date                   DATE                    Dlvr Due Date
-- x_earliest_start_date        DATE                    Earliest Start Date
-- x_earliest_finish_date       DATE                    Earliest Finish Date

PROCEDURE GET_DEFAULT_ACTN_DATE
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,p_task_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,p_project_mode                 IN      VARCHAR2
        ,x_due_date                     OUT     NOCOPY DATE --File.Sql.39 bug 4440895
        ,x_earliest_start_date          OUT     NOCOPY DATE --File.Sql.39 bug 4440895
        ,x_earliest_finish_date         OUT     NOCOPY DATE --File.Sql.39 bug 4440895
    )
IS

l_scheduled_finish_date                 DATE    := NULL;
l_task_scheduled_finish_date            DATE    := NULL;
l_sysdate                               DATE    := NULL;

CURSOR l_proj_date_info_csr
IS
      SELECT
             PES.SCHEDULED_FINISH_DATE,
             SYSDATE
      FROM
             PA_PROJ_ELEMENT_VERSIONS  PEV,
             PA_PROJ_ELEM_VER_SCHEDULE PES
      WHERE
                 PEV.ELEMENT_VERSION_ID = p_dlvr_ver_id
             AND PEV.ELEMENT_VERSION_ID = PES.ELEMENT_VERSION_ID
             AND PEV.OBJECT_TYPE        = 'PA_DELIVERABLES'
             AND PEV.PROJECT_ID         = PES.PROJECT_ID;/* Including this additional clause for Performance Fix : Bug  3614361 */

CURSOR l_task_date_info_csr
IS
      SELECT
              PES.EARLY_START_DATE
             ,PES.EARLY_FINISH_DATE
             ,PES.SCHEDULED_FINISH_DATE
      FROM
              PA_PROJ_ELEMENT_VERSIONS  PEV
             ,PA_PROJ_ELEM_VER_SCHEDULE PES
      WHERE
                 PEV.ELEMENT_VERSION_ID = p_task_ver_id
             AND PEV.ELEMENT_VERSION_ID = PES.ELEMENT_VERSION_ID
             AND PEV.OBJECT_TYPE        = 'PA_TASKS'
             AND PEV.PROJECT_ID         = PES.PROJECT_ID;/* Including this additional clause for Performance Fix : Bug  3614361 */

BEGIN

        OPEN l_proj_date_info_csr;
        FETCH l_proj_date_info_csr INTO l_scheduled_finish_date, l_sysdate;
        CLOSE l_proj_date_info_csr;

        IF p_task_ver_id IS NULL THEN

            IF l_scheduled_finish_date IS NOT NULL THEN
                x_due_date  :=  l_scheduled_finish_date;
            ELSE
                x_due_date  :=  l_sysdate;
            END IF;

            x_earliest_start_date       := NULL;
            x_earliest_finish_date      := NULL;

        ELSE

            IF p_project_mode = 'TEMPLATE' THEN

                IF l_scheduled_finish_date IS NOT NULL THEN
                    x_due_date  :=  l_scheduled_finish_date;
                ELSE
                    x_due_date  :=  l_sysdate;
                END IF;

                x_earliest_start_date       := NULL;
                x_earliest_finish_date      := NULL;

            ELSE

                OPEN l_task_date_info_csr;
                FETCH l_task_date_info_csr INTO x_earliest_start_date, x_earliest_finish_date, l_task_scheduled_finish_date;
                CLOSE l_task_date_info_csr;

                IF l_scheduled_finish_date IS NOT NULL THEN
                    x_due_date  :=  l_scheduled_finish_date;
                ELSIF l_task_scheduled_finish_date IS NOT NULL THEN
                    x_due_date  :=  l_task_scheduled_finish_date;
                ELSE
                    x_due_date  :=  l_sysdate;
                END IF;

            END IF;

        END IF;
EXCEPTION

WHEN OTHERS THEN

         Fnd_Msg_Pub.add_exc_msg
                       ( p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'GET_DEFAULT_ACTN_DATE'
                        , p_error_text      => SUBSTRB(SQLERRM,1,240));

         IF l_proj_date_info_csr%ISOPEN THEN
            CLOSE l_proj_date_info_csr;
         END IF;

         IF l_task_date_info_csr%ISOPEN THEN
            CLOSE l_task_date_info_csr;
         END IF;

         RAISE;

END GET_DEFAULT_ACTN_DATE;

PROCEDURE CHECK_DLVR_DISABLE_ALLOWED( p_api_version    IN NUMBER := 1.0
                                      ,p_calling_module IN VARCHAR2 := 'SELF_SERVICE'
                                      ,p_debug_mode     IN VARCHAR2 := 'N'
                                      ,p_project_id     IN PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
                                      ,x_return_flag        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                      ,x_msg_data           OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

/* Bug 3597178 This cursor is no more needed
   As we dont need to check for existence of association b/w deliverable and  deliverable based tasks for that project
CURSOR cur_tsk_assoc IS
SELECT 1 FROM dual
WHERE EXISTS(
          SELECT ppe.proj_element_id DlvrElemId, ppev.element_version_id DlvrElemVerId
          FROM pa_proj_elements ppe,
               pa_proj_element_versions ppev
          WHERE ppe.proj_element_id = ppev.proj_element_id
            AND ppe.project_id = p_project_id
            AND ppev.project_id = p_project_id
            AND ppe.object_type = ppev.object_type
            AND ppe.object_type = 'PA_DELIVERABLES'
            AND 'Y' = PA_DELIVERABLE_UTILS.IS_DLV_BASED_ASSCN_EXISTS(ppe.proj_element_id,ppev.element_version_id)
            );
*/

CURSOR cur_dlvr_progress IS
SELECT 1 FROM dual
WHERE EXISTS(
          SELECT 1
          FROM pa_proj_elements ppe
          WHERE ppe.project_id = p_project_id
            AND ppe.object_type = 'PA_DELIVERABLES'
            AND 'Y' = PA_DELIVERABLE_UTILS.IS_DELIVERABLE_HAS_PROGRESS(p_project_id,ppe.proj_element_id)
            );
/* Commented the following SELECT statement for Performance Bug Fix 3614361 */
/*
SELECT 1 FROM dual
WHERE EXISTS(
          SELECT ppe.proj_element_id DlvrElemId, ppev.element_version_id DlvrElemVerId
          FROM pa_proj_elements ppe,
               pa_proj_element_versions ppev
          WHERE ppe.project_id = p_project_id
            AND ppe.object_type = 'PA_DELIVERABLES'
            AND 'Y' = PA_DELIVERABLE_UTILS.IS_DELIVERABLE_HAS_PROGRESS(p_project_id,ppe.proj_element_id)
            );
*/

CURSOR cur_ship_or_proc IS
SELECT 1 FROM dual
WHERE EXISTS(
          SELECT ppe.proj_element_id DlvrElemId, ppev.element_version_id DlvrElemVerId
          FROM pa_proj_elements ppe,
               pa_proj_element_versions ppev
          WHERE ppe.proj_element_id = ppev.proj_element_id
            AND ppe.project_id = p_project_id
            AND ppev.project_id = p_project_id
            AND ppe.object_type = ppev.object_type
            AND ppe.object_type = 'PA_ACTIONS'
            AND ( 'Y' = PA_DELIVERABLE_UTILS.GET_READY_TO_SHIP_FLAG(ppe.proj_element_id,ppev.element_version_id)
               OR 'Y' = PA_DELIVERABLE_UTILS.GET_READY_TO_PROC_FLAG(ppe.proj_element_id,ppev.element_version_id) )
            );

CURSOR cur_billing_fn IS
SELECT 1 FROM dual
WHERE EXISTS(
          SELECT 1
          FROM pa_proj_elements ppe
          WHERE ppe.project_id = p_project_id
            AND ppe.object_type = 'PA_ACTIONS'
            AND PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(ppe.proj_element_id) = 'BILLING'
            AND 'Y' = PA_Billing_Wrkbnch_Events.CHECK_BILLING_EVENT_EXISTS(p_project_id,ppe.proj_element_id)
            );

l_debug_mode   VARCHAR2(1);
l_debug_level2 CONSTANT NUMBER := 2;
l_debug_level3 CONSTANT NUMBER := 3;
l_debug_level4 CONSTANT NUMBER := 4;
l_debug_level5 CONSTANT NUMBER := 5;

l_dummy NUMBER;

BEGIN

     x_return_flag := null;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count   := 0;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'PA_DELIVERABLE_UTILS : CHECK_DLVR_DISABLE_ALLOWED',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_DELIVERABLE_UTILS : CHECK_DLVR_DISABLE_ALLOWED : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);
     END IF;

     IF 'N' = PA_PROJECT_STRUCTURE_UTILS.CHECK_DELIVERABLE_ENABLED(p_project_id) THEN
          x_return_flag := 'Y';
     ELSE

          /*  Bug 3597178 This check is not needed
          OPEN cur_tsk_assoc;
          FETCH cur_tsk_assoc INTO l_dummy;
          IF cur_tsk_assoc%FOUND THEN
               x_return_flag := 'N';
               x_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLV_TASK_ASSN_EXISTS' );
               CLOSE cur_tsk_assoc;
               return;
          ELSE
               CLOSE cur_tsk_assoc;
          END IF;
           End of Changes for Bug 3597178    */

          OPEN cur_dlvr_progress;
          FETCH cur_dlvr_progress INTO l_dummy;
          IF cur_dlvr_progress%FOUND THEN
               x_return_flag := 'N';
               x_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLV_HAS_PROGRESS' );
               CLOSE cur_dlvr_progress;
               return;
          ELSE
               CLOSE cur_dlvr_progress;
          END IF;

          OPEN cur_ship_or_proc;
          FETCH cur_ship_or_proc INTO l_dummy;
          IF cur_ship_or_proc%FOUND THEN
               x_return_flag := 'N';
               x_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLV_ACTION_TXN_EXISTS' );
               CLOSE cur_ship_or_proc;
               return;
          ELSE
               CLOSE cur_ship_or_proc;
          END IF;

          OPEN cur_billing_fn;
          FETCH cur_billing_fn INTO l_dummy;
          IF cur_billing_fn%FOUND THEN
               x_return_flag := 'N';
               x_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLV_ACTION_TXN_EXISTS' );
               CLOSE cur_billing_fn;
               return;
          ELSE
               CLOSE cur_billing_fn;
          END IF;

--          x_return_flag := 'W';
--          x_return_status := FND_API.G_RET_STS_ERROR;
--          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
--                                p_msg_name       => 'PA_DLV_DEFINED' );
          return;
     END IF;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF cur_dlvr_progress%ISOPEN THEN
          CLOSE cur_dlvr_progress;
     END IF;
     IF cur_ship_or_proc%ISOPEN THEN
          CLOSE cur_ship_or_proc;
     END IF;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

     Fnd_Msg_Pub.add_exc_msg
                       (  p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'CHECK_DLVR_DISABLE_ALLOWED'
                        , p_error_text      => x_msg_data );
     RAISE;
END CHECK_DLVR_DISABLE_ALLOWED;





PROCEDURE UPDATE_TSK_STATUS_CANCELLED( p_api_version    IN  NUMBER := 1.0
                                      ,p_calling_module IN  VARCHAR2 := 'SELF_SERVICE'
                                      ,p_debug_mode     IN  VARCHAR2 := 'N'
                                      ,p_task_id        IN  NUMBER
                                      ,p_status_code    IN  PA_PROJECT_STATUSES.PROJECT_STATUS_CODE%TYPE
                                      ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                      ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      )
IS

CURSOR cur_check_cancel_possible IS
SELECT 1 FROM dual
WHERE EXISTS(
              SELECT 1
              FROM pa_proj_elements ppe,
                   pa_proj_element_versions ppv,
                   pa_object_relationships obj1,
                   pa_object_relationships obj2
              WHERE ppe.proj_element_id=p_task_id
                AND ppe.object_type='PA_TASKS'
                AND obj1.relationship_type='A'
              AND obj1.relationship_subtype='TASK_TO_DELIVERABLE'
              AND obj1.object_id_from2=p_task_id
              AND obj1.object_type_from='PA_TASKS'
              AND obj1.object_type_to='PA_DELIVERABLES'
                AND obj2.relationship_type='A'
              AND obj2.relationship_subtype='DELIVERABLE_TO_ACTION'
              AND obj2.object_id_from2=obj1.object_id_to2
              AND obj2.object_type_from='PA_DELIVERABLES'
              AND obj2.object_type_to='PA_ACTIONS'
              AND ppv.proj_element_id=obj2.object_id_to2
                AND ppv.object_type='PA_ACTIONS'
              AND (    nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(ppv.element_version_id),'N') = 'Y'
                      OR nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(ppv.element_version_id),'N') = 'Y'
                      OR PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(obj2.object_id_to2) = 'BILLING'  )
             );
CURSOR cur_get_assoc_dlvr IS
SELECT proj_element_id
FROM pa_proj_elements ppe,
     pa_object_relationships obj
WHERE obj.relationship_type='A'
  AND obj.relationship_subtype='TASK_TO_DELIVERABLE'
  AND obj.object_id_from2=p_task_id
  AND obj.object_type_from='PA_TASKS'
  AND obj.object_type_to='PA_DELIVERABLES'
  AND ppe.proj_element_id = obj.object_id_to2
  AND ppe.object_type = 'PA_DELIVERABLES';

l_debug_mode   VARCHAR2(1);
l_debug_level2 CONSTANT NUMBER := 2;
l_debug_level3 CONSTANT NUMBER := 3;
l_debug_level4 CONSTANT NUMBER := 4;
l_debug_level5 CONSTANT NUMBER := 5;

l_system_code PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE;
l_dummy NUMBER;
BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count   := 0;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'PA_DELIVERABLE_UTILS : UPDATE_TSK_STATUS_CANCELLED',
                                      p_debug_mode => l_debug_mode );
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_DELIVERABLE_UTILS : UPDATE_TSK_STATUS_CANCELLED : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_task_id'||':'||p_task_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_status_code'||':'||p_status_code,
                                     l_debug_level3);
     END IF;

     SELECT distinct PROJECT_SYSTEM_STATUS_CODE INTO l_system_code
     FROM pa_project_statuses
     WHERE STATUS_TYPE='TASK'
       AND PROJECT_STATUS_CODE=p_status_code;

     IF  'DELIVERABLE' <> PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(p_task_id)
     OR (l_system_code <> 'CANCELLED' AND l_system_code <> 'ON_HOLD') THEN
          return;
     ELSIF l_system_code = 'CANCELLED' THEN
          OPEN cur_check_cancel_possible;
          FETCH cur_check_cancel_possible INTO l_dummy;
          IF cur_check_cancel_possible%FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_TSK_DEL_TXN_EXISTS' );
               CLOSE cur_check_cancel_possible;
               return;
          ELSE
               CLOSE cur_check_cancel_possible;
          END IF;
     END IF;
     FOR assoc_dlvr_rec IN cur_get_assoc_dlvr LOOP
          UPDATE pa_proj_elements
          SET status_code = p_status_code
          WHERE proj_element_id = assoc_dlvr_rec.proj_element_id;
     END LOOP;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF cur_check_cancel_possible%ISOPEN THEN
          CLOSE cur_check_cancel_possible;
     END IF;
     IF cur_get_assoc_dlvr%ISOPEN THEN
          CLOSE cur_get_assoc_dlvr;
     END IF;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

     Fnd_Msg_Pub.add_exc_msg
                       (  p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'UPDATE_TSK_STATUS_CANCELLED'
                        , p_error_text      => x_msg_data );
     RAISE;
END UPDATE_TSK_STATUS_CANCELLED;





PROCEDURE CHECK_CHANGE_MAPPING_OK( p_api_version    IN  NUMBER := 1.0
                                  ,p_calling_module IN  VARCHAR2 := 'SELF_SERVICE'
                                  ,p_debug_mode     IN  VARCHAR2 := 'N'
                                  ,p_wp_task_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
                                  ,p_fp_task_verison_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
                                  ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                  ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  )
IS
CURSOR cur_check_transaction_init IS
SELECT 1 FROM dual
WHERE EXISTS(
              SELECT 1
              FROM pa_proj_elements ppe,
                   pa_proj_element_versions ppv,
                   pa_object_relationships obj1,
                   pa_object_relationships obj2
              WHERE ppe.proj_element_id=p_wp_task_version_id
                AND ppe.object_type='PA_TASKS'
                AND obj1.relationship_type='A'
              AND obj1.relationship_subtype='TASK_TO_DELIVERABLE'
              AND obj1.object_id_from2=ppe.proj_element_id
              AND obj1.object_type_from='PA_TASKS'
              AND obj1.object_type_to='PA_DELIVERABLES'
                AND obj2.relationship_type='A'
              AND obj2.relationship_subtype='DELIVERABLE_TO_ACTION'
              AND obj2.object_id_from2=obj1.object_id_to2
              AND obj2.object_type_from='PA_DELIVERABLES'
              AND obj2.object_type_to='PA_ACTIONS'
              AND ppv.proj_element_id=obj2.object_id_to2
                AND ppv.object_type='PA_ACTIONS'
              AND (    nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(ppv.element_version_id),'N') = 'Y'
                      OR nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(ppv.element_version_id),'N') = 'Y'
                      OR nvl(OKE_DELIVERABLE_UTILS_PUB.MDS_Initiated_Yn(ppv.element_version_id),'N') = 'Y'
                      OR PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(obj2.object_id_to2) = 'BILLING'  )
             );

l_debug_mode   VARCHAR2(1);
l_debug_level2 CONSTANT NUMBER := 2;
l_debug_level3 CONSTANT NUMBER := 3;
l_debug_level4 CONSTANT NUMBER := 4;
l_debug_level5 CONSTANT NUMBER := 5;

l_dummy NUMBER;
BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count   := 0;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'PA_DELIVERABLE_UTILS : CHECK_CHANGE_MAPPING_OK',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage := 'PA_DELIVERABLE_UTILS : CHECK_CHANGE_MAPPING_OK : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_wp_task_version_id'||':'||p_wp_task_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_fp_task_verison_id'||':'||p_fp_task_verison_id,
                                     l_debug_level3);
     END IF;

     OPEN cur_check_transaction_init;
     FETCH cur_check_transaction_init INTO l_dummy;
     IF cur_check_transaction_init%FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                p_msg_name       => 'PA_PS_WP_MAPPING_TXN_EXISTS' );
     END IF;
     CLOSE cur_check_transaction_init;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF cur_check_transaction_init%ISOPEN THEN
          CLOSE cur_check_transaction_init;
     END IF;
     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;
     Fnd_Msg_Pub.add_exc_msg
                       (  p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'CHECK_DLVR_DISABLE_ALLOWED'
                        , p_error_text      => x_msg_data );
     RAISE;
END CHECK_CHANGE_MAPPING_OK;


-- Bug 3957706 < Start >
-- This API is called from the following places :-
-- 1) PA_TASK_PVT1.Update_Task API
--    In this Context,
--    p_task_id          - The Task's Proj Element ID
--    p_prog_method_code - New Progress Method Code for the Task

PROCEDURE CHECK_PROGRESS_MTH_CODE_VALID( p_api_version    IN  NUMBER := 1.0
                                        ,p_calling_module IN  VARCHAR2 := 'SELF_SERVICE'
                                        ,p_debug_mode     IN  VARCHAR2 := 'N'
                                        ,p_task_id        IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
                                        ,p_prog_method_code IN PA_PROJ_ELEMENTS.BASE_PERCENT_COMP_DERIV_CODE%TYPE
                                        ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        )
IS
/* Commented this Cursor as It is not used anywhere
CURSOR cur_assoc_dlvr_has_prog IS
SELECT 1 FROM dual
WHERE EXISTS(
               SELECT ppe.proj_element_id
               FROM pa_proj_elements ppe,
                    pa_object_relationships obj
               WHERE obj.relationship_type='A'
                 AND obj.relationship_subtype='TASK_TO_DELIVERABLE'
                 AND obj.object_id_from2=p_task_id
                 AND obj.object_type_from='PA_TASKS'
                 AND obj.object_type_to='PA_DELIVERABLES'
                 AND ppe.proj_element_id = obj.object_id_to2
                 AND 'Y' = PA_DELIVERABLE_UTILS.IS_DELIVERABLE_HAS_PROGRESS(ppe.project_id,ppe.proj_element_id)
             );
*/

CURSOR cur_dlvr_assoc_exists IS
SELECT 1 FROM dual
WHERE EXISTS(
              SELECT 1
              FROM pa_proj_elements ppe,
                   pa_object_relationships obj,
                   pa_proj_element_versions ppev
              WHERE ppe.proj_element_id=p_task_id
                AND ppe.object_type='PA_TASKS'
                AND obj.relationship_type='A'
              AND obj.relationship_subtype='TASK_TO_DELIVERABLE'
              AND obj.object_id_from2=ppe.proj_element_id
              AND obj.object_type_from='PA_TASKS'
              AND obj.object_type_to='PA_DELIVERABLES'
                AND ppev.proj_element_id = obj.object_id_to2
                AND ppev.project_id = ppe.project_id
               /*This AND Clause is Wrong as the 1st param passed is the Task ID whereas IS_DLV_BASED_ASSCN_EXISTS API
                 expects the 1st param as the Deliverable's Proj Element ID
                AND 'Y' = PA_DELIVERABLE_UTILS.IS_DLV_BASED_ASSCN_EXISTS(ppe.proj_element_id,
                                                                         ppev.element_version_id)
               So,Included the new AND CLause as below */
                AND 'Y' =  PA_DELIVERABLE_UTILS.IS_DLV_BASED_ASSCN_EXISTS(ppev.proj_element_id ,
                                                                          ppev.element_version_id)
             );

l_dummy NUMBER;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count   := 0;

/*   Commented this code because we dont need this code
     In the Context ,this API is used .
     IF  'DELIVERABLE' = PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(p_task_id)
     AND 'DELIVERABLE' <> p_prog_method_code THEN
          OPEN cur_assoc_dlvr_has_prog;
          FETCH cur_assoc_dlvr_has_prog INTO l_dummy;
          IF cur_assoc_dlvr_has_prog%FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_TSK_PROGRESS_LOSE_WARN' );
               CLOSE cur_assoc_dlvr_has_prog;
               return;
          ELSIF */

            --nvl check needed in following if Clause as NULL Value also can be returned
            IF 'DELIVERABLE' <> nvl(PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(p_task_id),'X')
            AND 'DELIVERABLE' = p_prog_method_code THEN

               OPEN cur_dlvr_assoc_exists;
               FETCH cur_dlvr_assoc_exists INTO l_dummy;
               CLOSE cur_dlvr_assoc_exists;

               IF nvl(l_dummy,0)=1 THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                          p_msg_name       => 'PA_TSK_PROGRESS_MTH_ERR' );
                   /* CLOSE cur_assoc_dlvr_has_prog; Commented as Cursor not used*/
               END IF;

            END IF;

/*          CLOSE cur_assoc_dlvr_has_prog;

     END IF; Commented as this cursor not used anymore */

EXCEPTION
WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

/*     IF cur_assoc_dlvr_has_prog%ISOPEN THEN
          CLOSE cur_assoc_dlvr_has_prog;
     END IF;
Commented as cursor not used */
--Bug 3957706 < End >

     IF cur_dlvr_assoc_exists%ISOPEN THEN
          CLOSE cur_dlvr_assoc_exists;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                       (  p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'CHECK_PROGRESS_MTH_CODE_VALID'
                        , p_error_text      => x_msg_data );
     RAISE;
END CHECK_PROGRESS_MTH_CODE_VALID;





FUNCTION CHECK_PROJ_DLV_TXN_EXISTS( p_api_version    IN  NUMBER := 1.0
                                   ,p_calling_module IN  VARCHAR2 := 'SELF_SERVICE'
                                   ,p_debug_mode     IN  VARCHAR2 := 'N'
                                   ,p_project_id     IN PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
                                   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                   ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   )
RETURN VARCHAR2 IS

CURSOR cur_proj_txn_exists IS
SELECT 'Y' FROM dual
WHERE EXISTS(
             SELECT 1
             FROM pa_proj_elements ppe,
                  pa_proj_elements ppe2,
                  pa_proj_element_versions ppev,
                  pa_object_relationships obj1,
                  pa_object_relationships obj2
             WHERE ppe.project_id  = p_project_id
              AND  ppe.object_type = 'PA_ACTIONS'
              AND  ppev.project_id = p_project_id
              AND  ppe.proj_element_id = ppev.proj_element_id
              AND  obj1.object_id_to2 = ppe.proj_element_id
              AND  obj1.relationship_type ='A'
              AND  obj1.relationship_subtype = 'DELIVERABLE_TO_ACTION'
              AND  obj1.object_type_from ='PA_DELIVERABLES'
              AND  obj1.object_type_to = 'PA_ACTIONS'
              AND  obj2.object_id_to2 = obj1.object_id_from2
              AND  obj2.relationship_type ='A'
              AND  obj2.relationship_subtype='TASK_TO_DELIVERABLE'
              AND  obj2.object_type_from = 'PA_TASKS'
              AND  obj2.object_type_to = 'PA_DELIVERABLES'
              AND  ppe2.proj_element_id=obj2.object_id_from1
              AND  ppe2.object_type='PA_TASKS'
              AND (     nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(ppev.element_version_id),'N') = 'Y'
                     OR nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(ppev.element_version_id),'N') = 'Y'
                     OR nvl(OKE_DELIVERABLE_UTILS_PUB.MDS_Initiated_Yn(ppev.element_version_id),'N') = 'Y'
                     OR PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(ppe.proj_element_id) = 'BILLING'  )
             );

l_debug_mode   VARCHAR2(1);
l_debug_level2 CONSTANT NUMBER := 2;
l_debug_level3 CONSTANT NUMBER := 3;
l_debug_level4 CONSTANT NUMBER := 4;
l_debug_level5 CONSTANT NUMBER := 5;

l_return_flag VARCHAR2(1) := 'Y';
BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count   := 0;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'PA_DELIVERABLE_UTILS : CHECK_PROJ_DLV_TXN_EXISTS',
                                      p_debug_mode => l_debug_mode );
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_DELIVERABLE_UTILS : CHECK_PROJ_DLV_TXN_EXISTS : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);
     END IF;

     OPEN cur_proj_txn_exists;
     FETCH cur_proj_txn_exists INTO l_return_flag;
     IF cur_proj_txn_exists%FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                p_msg_name       => 'PA_STR_SETUP_CHANGE_ERR' );
     ELSE
          l_return_flag := 'N';
     END IF;
     CLOSE cur_proj_txn_exists;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

     return l_return_flag;
EXCEPTION
WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF cur_proj_txn_exists%ISOPEN THEN
          CLOSE cur_proj_txn_exists;
     END IF;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

     Fnd_Msg_Pub.add_exc_msg
                       (  p_pkg_name        => 'PA_DELIVERABLE_UTILS'
                        , p_procedure_name  => 'CHECK_PROJ_DLV_TXN_EXISTS'
                        , p_error_text      => x_msg_data );
     RAISE;
END CHECK_PROJ_DLV_TXN_EXISTS;

FUNCTION GET_ASSOCIATED_DELIVERABLES
 (
     p_task_id   IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
 )   RETURN VARCHAR2
 IS

 TYPE l_tbl IS TABLE OF VARCHAR2(350) INDEX BY BINARY_INTEGER;
 l_name_number_tbl l_tbl ;
 l_count NUMBER ;
 l_string varchar2(5000); -- Modified size from 500 to 5000 for Bug#6153741
 l_meaning varchar2(80);

CURSOR c_associated_deliverables IS
SELECT  ppe. name||'('|| ppe.element_number||')' name_number
FROM  PA_PROJ_ELEMENTS ppe ,
      PA_OBJECT_RELATIONSHIPS obj
WHERE  ppe.object_type='PA_DELIVERABLES'
  AND  ppe.proj_element_id = OBJ.object_id_to2
  AND  OBJ.object_id_from2 =p_task_id
  AND  OBJ.object_type_to = 'PA_DELIVERABLES'
  AND  OBJ.object_type_from = 'PA_TASKS'
  AND  OBJ.relationship_type = 'A'
  AND  OBJ.relationship_subtype = 'TASK_TO_DELIVERABLE';

CURSOR c_lookup_meaning IS
SELECT meaning
FROM pa_lookups
WHERE lookup_type = 'PA_DLV_MORE'
  AND lookup_code = 'MORE';

BEGIN

OPEN c_associated_deliverables;
-- Bug Fix 5609470.
-- Moved the following code to inside the code to avoid unnecessary executions as the cursor
-- gets opened even when the meaning is not used.
-- Hence moving the open fetch and close as well to inside just before the usage.

-- OPEN c_lookup_meaning;
FETCH c_associated_deliverables BULK COLLECT INTO l_name_number_tbl;
CLOSE c_associated_deliverables;
     IF  nvl(l_name_number_tbl.LAST,0)>0 THEN

       -- Bug Fix 5609470.
       -- Moved the following code to inside the code to avoid unnecessary executions as the cursor
       -- gets opened even when the meaning is not used.
       -- Hence moving the open fetch and close as well to inside just before the usage.
       --   FETCH  c_lookup_meaning INTO l_meaning;
       --   CLOSE  c_lookup_meaning;

          FOR l_count in l_name_number_tbl.FIRST..l_name_number_tbl.LAST LOOP
             IF l_count = 1
               THEN
                    l_string :=l_name_number_tbl(l_count);
               ELSE
                    l_string := l_string||','||l_name_number_tbl(l_count);
               END IF;
          EXIT  WHEN l_count >= 3 ;
          END LOOP ;

        IF nvl(l_name_number_tbl.LAST,0)>3 THEN

       -- Bug Fix 5609470.
       -- Moved the following code to here to avoid unnecessary executions as the cursor
       -- gets opened even when the meaning is not used.
       -- Hence moving the open fetch and close as well to inside just before the usage.

            OPEN c_lookup_meaning;
            FETCH  c_lookup_meaning INTO l_meaning;
            CLOSE  c_lookup_meaning;

       -- End of Bug Fix 5609470.

            l_string := l_string||','|| l_meaning||'..';
        END IF ;
          RETURN l_string;
     ELSE
          RETURN NULL;
     END IF ;
END GET_ASSOCIATED_DELIVERABLES;

/*===============================================================================================
Deliverable Defaulting Logic for Copy From Project/Template Flow
Case 1:
Source Project/Template Dates
|------------------|-----------------|----------------------|
|ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|----------------------|
|     NULL         |      NULL       |            NULL      |
|------------------|-----------------|----------------------|


|------------------|-----------------|------------------|-----------------|----------------------|
|  QE Start Date   |   QE End Date   |ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|------------------|-----------------|----------------------|
|     NULL         |      NULL       |     NULL         |      NULL       |            NULL      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2002    |      NULL       |   01-APR-2002    |      NULL       |     01-APR-2002      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2002    |   01-APR-2003   |   01-APR-2002    |   01-APR-2003   |     01-APR-2003      |
|------------------|-----------------|------------------|-----------------|----------------------|

Case 2:
|------------------|-----------------|----------------------|
|ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|----------------------|
|  01-APR-2002     |      NULL       |            NULL      |
|------------------|-----------------|----------------------|

|------------------|-----------------|------------------|-----------------|----------------------|
|  QE Start Date   |   QE End Date   |ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|------------------|-----------------|----------------------|
|     NULL         |      NULL       |   01-APR-2002    |      NULL       |     01-APR-2002      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |      NULL       |   01-APR-2003    |      NULL       |     01-APR-2003      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |   01-APR-2004   |   01-APR-2003    |   01-APR-2004   |     01-APR-2004      |
|------------------|-----------------|------------------|-----------------|----------------------|

Case 3:
|------------------|-----------------|----------------------|
|ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|----------------------|
|  01-APR-2002     |      NULL       |   15-APR-2002        |
|------------------|-----------------|----------------------|

|------------------|-----------------|------------------|-----------------|----------------------|
|  QE Start Date   |   QE End Date   |ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|------------------|-----------------|----------------------|
|     NULL         |      NULL       |   01-APR-2002    |      NULL       |     15-APR-2002      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |      NULL       |   01-APR-2003    |      NULL       |     15-APR-2003      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |   01-APR-2004   |   01-APR-2003    |   01-APR-2004   |     15-APR-2004      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |   12-APR-2003   |   01-APR-2003    |   12-APR-2003   |     12-APR-2003      |
|------------------|-----------------|------------------|-----------------|----------------------|

Case 4:
|------------------|-----------------|----------------------|
|ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|----------------------|
|     NULL         |      NULL       |    15-APR-2002       |
|------------------|-----------------|----------------------|

|------------------|-----------------|------------------|-----------------|----------------------|
|  QE Start Date   |   QE End Date   |ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|------------------|-----------------|----------------------|
|     NULL         |      NULL       |        NULL      |      NULL       |     15-APR-2002      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |      NULL       |   01-APR-2003    |      NULL       |     01-APR-2003      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |   01-APR-2004   |   01-APR-2003    |   01-APR-2004   |     01-APR-2004      |
|------------------|-----------------|------------------|-----------------|----------------------|

Case 5:
|------------------|-----------------|----------------------|
|ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|----------------------|
|  01-APR-2002     |  15-APR-2003    |  15-APR-2002         |
|------------------|-----------------|----------------------|

|------------------|-----------------|------------------|-----------------|----------------------|
|  QE Start Date   |   QE End Date   |ProjectStart Date |ProjectEnd Date  |Deliverable Due Date  |
|------------------|-----------------|------------------|-----------------|----------------------|
|     NULL         |      NULL       |   01-APR-2002    |   15-APR-2003   |     15-APR-2002      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |      NULL       |   01-APR-2003    |   15-APR-2004   |     15-APR-2003      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |   01-APR-2004   |   01-APR-2003    |   01-APR-2004   |     15-APR-2003      |
|------------------|-----------------|------------------|-----------------|----------------------|
|   01-APR-2003    |   12-APR-2003   |   01-APR-2003    |   12-APR-2003   |     12-APR-2003      |
|------------------|-----------------|------------------|-----------------|----------------------|

=================================================================================================*/

FUNCTION GET_ADJUSTED_DATES
     (
          p_project_id   IN pa_projects_all.project_id%TYPE
         ,p_dlv_due_date IN DATE
         ,p_delta        IN NUMBER
     )   RETURN DATE
IS
     CURSOR c_proj_dates IS
     SELECT start_date
           ,completion_date
       FROM pa_projects_all pa
      WHERE pa.project_id = p_project_id ;
l_start_date   DATE ;
l_end_date     DATE ;
l_dlv_due_date DATE ;
l_delta        NUMBER ;

BEGIN
     OPEN c_proj_dates ;
     FETCH c_proj_dates into l_start_date,l_end_date ;
     CLOSE c_proj_dates ;

    IF p_dlv_due_date IS NULL THEN
          IF l_end_date IS NOT NULL THEN
               l_dlv_due_date := l_end_date ;
          ELSE
               l_dlv_due_date := l_start_date ;
          END IF ;

     ELSE
          l_delta := nvl(p_delta,0) ;

          IF l_end_date IS NOT NULL  THEN
               l_dlv_due_date := LEAST(l_end_date,p_dlv_due_date + l_delta);
          ELSE
               -- Bug#3601622
               -- GREATEST function returns null if any of the
               -- parameter is null. To avaid this added nvl on both side.
               l_dlv_due_date := GREATEST(nvl(l_start_date,p_dlv_due_date + l_delta),nvl(p_dlv_due_date + l_delta,l_start_date));
          END IF ;

         -- 3493612 , new defaulted due date will be always between adjusted project start date and end date
         -- or it will be project end date

         -- added below code to check new defaulted due date is between adjusted project start date and end date
         -- if it is not , defaulted due date will be set to adjusted project end date

         IF l_end_date IS NOT NULL AND l_start_date IS NOT NULL THEN
            IF NOT (l_dlv_due_date > l_start_date AND l_dlv_due_date < l_end_date) THEN
                l_dlv_due_date := l_end_date;
            END IF;
         END IF;

         -- 3493612

     END IF ;

     RETURN l_dlv_due_date ;

END GET_ADJUSTED_DATES;

FUNCTION IS_ITEM_BASED_DLV_EXISTS RETURN VARCHAR2
IS
CURSOR C IS
SELECT 'Y' FROM DUAL
WHERE EXISTS(SELECT 'Y'
               FROM pa_proj_elements ppe,
                    pa_task_types ptt
               WHERE ppe.object_type = 'PA_DELIVERABLES'
                 AND ppe.type_id = ptt.task_type_id
                 AND ptt.task_type_class_code = 'ITEM'
                 AND ptt.object_type = 'PA_DLVR_TYPES'
                              ) ;
l_dummy VARCHAR2(1) := 'N' ;
BEGIN
OPEN C ;
FETCH C INTO l_dummy ;
CLOSE C ;
RETURN l_dummy ;
END IS_ITEM_BASED_DLV_EXISTS ;

FUNCTION IS_BILLING_FUNCTION
     (
      p_action_version_id IN pa_proj_element_versions.element_version_id%TYPE
      )
RETURN VARCHAR2
IS
     CURSOR C IS
     SELECT 'Y'
       FROM DUAL
  WHERE EXISTS (Select 'Y'
                  from pa_proj_elements ppe,
                       pa_proj_element_versions pev
                  where pev.element_version_id = p_action_version_id
                    and ppe.proj_element_id = pev.proj_element_id
                    and ppe.function_code = 'BILLING'
                 )   ;

l_dummy VARCHAR2(1) := 'N' ;
BEGIN
     OPEN C ;
     FETCH C INTO l_dummy  ;
     CLOSE C ;
     RETURN l_dummy ;
END IS_BILLING_FUNCTION ;

-- API name                      : Get_Project_Type_Class
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : VARCHAR2
-- Prameters
-- p_project_id                 IN      NUMBER          REQUIRED
-- x_return_status              OUT     VARCHAR2        REQUIRED

 FUNCTION Get_Project_Type_Class(
   p_project_id NUMBER ,
   x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) RETURN VARCHAR2 AS

  CURSOR cur_projects_all
  IS
    SELECT ppt.project_type_class_code
      FROM pa_projects_all ppa, pa_project_types ppt
     WHERE ppa.project_id = p_project_id
       AND ppa.project_type = ppt.project_type
       AND ppa.org_id = ppt.org_id; -- 4363092 MOAC Changes

  l_project_type_class_code  VARCHAR2(30);
BEGIN
   OPEN cur_projects_all;
   FETCH cur_projects_all INTO l_project_type_class_code;
   CLOSE cur_projects_all;
   RETURN l_project_type_class_code;
   x_return_status:= FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Project_Type_Class;

-- SubProgram           : IS_DLVR_ITEM_BASED
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether the deliverable is item based,
--                        It takes the deliverable version id as input parameter
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------

--  p_deliverable_id               IN            VARCHAR2        N          Deliverable Version Id
FUNCTION IS_DLVR_ITEM_BASED
     (
         p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR  c_is_dlvr_item_based IS
     SELECT 'Y'
     FROM PA_TASK_TYPES
     WHERE TASK_TYPE_ID=(SELECT TYPE_ID
                           FROM PA_PROJ_ELEMENTS PPE,
                                PA_PROJ_ELEMENT_VERSIONS PEV
                           WHERE PPE.PROJ_ELEMENT_ID= PEV.PROJ_ELEMENT_ID
                       AND PEV.ELEMENT_VERSION_ID = p_deliverable_id
                              AND PEV.OBJECT_TYPE='PA_DELIVERABLES'
                              AND PPE.OBJECT_TYPE='PA_DELIVERABLES')
       AND TASK_TYPE_CLASS_CODE='ITEM'
       AND OBJECT_TYPE='PA_DLVR_TYPES';
l_dummy VARCHAR2(1) := 'N' ;
BEGIN
     OPEN c_is_dlvr_item_based;
     FETCH c_is_dlvr_item_based into l_dummy ;
     CLOSE c_is_dlvr_item_based;
     RETURN nvl(l_dummy,'N') ;
END IS_DLVR_ITEM_BASED ;

-- 3454572 added function for TM Home Page

-- SubProgram           : GET_DLVR_NAME_NUMBER
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will return deliverale name and number
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------

--  p_deliverable_id               IN            VARCHAR2        N          Deliverable Version Id

FUNCTION GET_DLVR_NAME_NUMBER
     (
          p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR c_dlv_name_number IS
     SELECT
            ppe.name || '(' || ppe.element_number || ')'
       FROM
            pa_proj_elements ppe
            ,pa_proj_element_versions pev
      WHERE
            pev.element_version_id =  p_deliverable_id
       AND  ppe.object_type        =  'PA_DELIVERABLES'
       AND  pev.object_type        =  'PA_DELIVERABLES'
       AND  ppe.proj_element_id    =  pev.proj_element_id
       AND  ppe.project_id         =  pev.project_id;

l_dummy VARCHAR2(350) := NULL;

BEGIN
     OPEN c_dlv_name_number;
     FETCH c_dlv_name_number into l_dummy ;
     CLOSE c_dlv_name_number;
     RETURN l_dummy ;

END GET_DLVR_NAME_NUMBER;

-- SubProgram           : GET_DLVR_NUMBER
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will return deliverale number
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------

--  p_deliverable_id               IN            VARCHAR2        N          Deliverable Version Id

FUNCTION GET_DLVR_NUMBER
     (
          p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR c_dlv_name_number IS
     SELECT
            ppe.ELEMENT_NUMBER
       FROM
            pa_proj_elements ppe
            ,pa_proj_element_versions pev
      WHERE
            pev.element_version_id =  p_deliverable_id
       AND  ppe.object_type        =  'PA_DELIVERABLES'
       AND  pev.object_type        =  'PA_DELIVERABLES'
       AND  ppe.proj_element_id    =  pev.proj_element_id
       AND  ppe.project_id         =  pev.project_id;

l_dummy VARCHAR2(350) := NULL;

BEGIN
     OPEN c_dlv_name_number;
     FETCH c_dlv_name_number into l_dummy ;
     CLOSE c_dlv_name_number;
     RETURN l_dummy ;

END GET_DLVR_NUMBER;

-- 3454572 end
-- 3442451 added for deliverable security implementation

-- SubProgram           : IS_DLVR_OWNER
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will return Y, if user is deliverable owner
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
--  p_deliverable_id               IN            VARCHAR2        Y               Deliverable Version Id
--  p_user_id                      IN            NUMBER          Y               User Id


FUNCTION IS_DLVR_OWNER
     (
           p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
          ,p_user_id        IN NUMBER
     )   RETURN VARCHAR2
IS
     CURSOR c_dlvr_owner IS
        select
             ppe.manager_person_id
        from
             pa_proj_elements ppe,
             pa_proj_element_versions pev
        where
                 pev.element_version_id  = p_deliverable_id
             and pev.object_type                 = 'PA_DELIVERABLES'
             and ppe.object_type                 = 'PA_DELIVERABLES'
             and pev.proj_element_id     = ppe.proj_element_id
             and pev.project_id          = ppe.project_id
             and pev.object_type         = pev.object_type;

l_is_owner          VARCHAR2(1) := 'N';
l_dlvr_owner_id     NUMBER := NULL;
l_person_id         NUMBER := NULL;

BEGIN

     l_person_id := PA_UTILS.GetEmpIdFromUser(p_user_id);

     OPEN c_dlvr_owner;
     FETCH c_dlvr_owner into l_dlvr_owner_id ;
     CLOSE c_dlvr_owner;

     IF l_dlvr_owner_id = l_person_id THEN
        l_is_owner := 'Y';
     END IF;
    RETURN l_is_owner;

END IS_DLVR_OWNER;

-- 3442451 end
/* ==============3435905 : FP M : Deliverables Changes For AMG - Start * =========================*/


-- SubProgram           : VALIDATE_DELIVERABLE
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will validate the IDs passed from AMG apis. It will be called
--                        only when context is AMG, for both Create and Update
-- Assumptions          : None

   Procedure Validate_Deliverable
   (
        p_deliverable_id         IN  NUMBER
      , p_deliverable_reference  IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      , p_dlvr_number            IN  PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      , p_dlvr_name              IN  PA_PROJ_ELEMENTS.NAME%TYPE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      , px_dlvr_owner_id         IN  OUT NOCOPY PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE --File.Sql.39 bug 4440895
      , p_dlvr_owner_name        IN  VARCHAR2    := NULL
      , p_dlvr_type_id           IN  PA_PROJ_ELEMENTS.TYPE_ID%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      , px_actual_finish_date    IN OUT NOCOPY DATE --File.Sql.39 bug 4440895
      , px_progress_weight       IN OUT NOCOPY PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE --File.Sql.39 bug 4440895
      , px_status_code           IN OUT NOCOPY Pa_task_types.initial_status_code%TYPE --File.Sql.39 bug 4440895
      , p_carrying_out_org_id    IN  NUMBER                                := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      , p_project_id             IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
      , p_task_id                IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
      , p_calling_mode           IN  VARCHAR2 := 'INSERT'
      , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      , x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
      , x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )
   IS
      l_api_name    CONSTANT    VARCHAR2(100) := 'VALIDATE_DELIVERABLE';
      l_debug_mode              VARCHAR2(1);
      l_msg_data                VARCHAR2(2000);

      l_dlvr_owner_id           PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE;
      --added for Bug: 4537865
      l_new_dlvr_owner_id	PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE;
      l_new_carrying_out_org_id PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE;
      --added for Bug: 4537865
      l_carrying_out_org_id     PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE;
      l_dlvr_prg_enabled              VARCHAR2(1)     := NULL;
      l_dlvr_action_enabled           VARCHAR2(1)     := NULL;
      l_status_code             PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE    := NULL;
      l_status_code_valid       VARCHAR2(1) := NULL;

      l_project_number          Pa_Projects_All.Segment1%TYPE;
      l_task_number             Pa_Proj_Elements.Name%TYPE;

   BEGIN

       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

       IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'VALIDATE_DELIVERABLE', p_debug_mode => l_debug_mode );
       END IF;

       IF px_dlvr_owner_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
          l_dlvr_owner_id := NULL;
       ELSE
          l_dlvr_owner_id := px_dlvr_owner_id;
       END IF;

       IF p_carrying_out_org_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
          l_carrying_out_org_id := NULL;
       ELSE
          l_carrying_out_org_id := p_carrying_out_org_id;
       END IF;

    -- Fetching Task Name , Project Name to use as token in Error Messages.
      IF (p_task_id IS NOT NULL AND p_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)  THEN
          SELECT name INTO   l_task_number
          FROM Pa_Proj_Elements
          WHERE  proj_element_id = p_task_id;
       ELSE
          l_task_number := null;
       END IF;

       SELECT segment1 INTO   l_project_number
       FROM Pa_Projects_All
       WHERE  project_id = p_project_id;

       IF l_debug_mode = 'Y' THEN
          Pa_Debug.WRITE(g_module_name, 'token values proj ['||l_Project_Number||'] task ['||l_task_Number||']',l_debug_level3);
       END IF;

    -- Validating deliverable_name - not null
       IF  p_dlvr_name   IS NULL
           OR  p_dlvr_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR    THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
               l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_NAME_MISSING') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  l_task_number,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );
          END IF;
          x_return_status             := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' validating deliverable name '||p_dlvr_name,  l_debug_level3);
    END IF;

    -- Validating deliverable_short_name - not null
       IF  p_dlvr_number   IS NULL
           OR  p_dlvr_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR    THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
              l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_NUMBER_MISSING') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  l_task_number,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );
          END IF;
          x_return_status             := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' validating deliverable short name '||p_dlvr_number,  l_debug_level3);
    END IF;

    -- Validating Deliverable Type Id - not null, valid value
       IF  p_dlvr_type_id   IS NULL
           OR  p_dlvr_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM    THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
              l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_TYPE_MISSING') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  l_task_number,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );
          END IF;
          x_return_status             := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;

       ELSE -- Deliverable type is not null, checking for valid value
          IF (Pa_Deliverable_Utils.IS_DLV_TYPE_ID_VALID(p_dlvr_type_id) = 'N') THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
              l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_TYPE_INVALID') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  l_task_number,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );
         END IF;
             x_return_status             := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
      END IF;
       END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' validating deliverable type'||p_dlvr_type_id,  l_debug_level3);
    END IF;

    -- Validating Deliverable Owner Id - valid value
       IF  (l_dlvr_owner_id   IS  NOT NULL ) THEN
          Pa_Tasks_Maint_Utils.CHECK_TASK_MGR_NAME_OR_ID (
          p_task_mgr_name  => p_dlvr_owner_name
             ,p_task_mgr_id    => l_dlvr_owner_id
             ,p_project_id     => p_project_id
             ,p_check_id_flag  => 'Y'
             ,p_calling_module => 'AMG'
          -- ,x_task_mgr_id    => l_dlvr_owner_id		* commenented for bug: 4537865
	     ,x_task_mgr_id    => l_new_dlvr_owner_id		-- added for bug:      4537865
             ,x_return_status  => x_return_status
             ,x_error_msg_code => l_msg_data );
      IF l_debug_mode = 'Y' THEN
         Pa_Debug.WRITE(g_module_name,' validated owner id'||l_dlvr_owner_id||x_return_status , l_debug_level3);
      END IF;

          -- added for bug:      4537865
          IF x_return_status = FND_API.G_RET_STS_SUCCESS       THEN
	  l_dlvr_owner_id := l_new_dlvr_owner_id;
          END IF;
          -- added for bug:      4537865

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
              l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_OWNER_INVALID') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  l_task_number,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );
           x_return_status             := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

 -- Validating Status Code - valid value
     l_status_code_valid := Pa_Deliverable_Utils.IS_STATUS_CODE_VALID(px_status_code, p_calling_mode);

     IF l_debug_mode = 'Y' THEN
         Pa_Debug.WRITE(g_module_name,' validated status code ['||px_status_code||'] outcome ['||l_status_code_valid||']' , l_debug_level3);
     END IF;

      IF (px_status_code IS NOT NULL and l_status_code_valid = 'N') THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
              l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_STATUS_INVALID') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  l_task_number,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );

           END IF;
           x_return_status             := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- Validating Carrying Out Org Id - valid value
       IF  (l_carrying_out_org_id   IS  NOT NULL ) THEN
          Pa_Hr_Org_Utils.CHECK_ORGNAME_OR_ID
            ( p_organization_id    => l_carrying_out_org_id
             ,p_organization_name  =>  NULL
             ,p_check_id_flag      => 'Y'
          -- ,x_organization_id    => l_carrying_out_org_id      * commented for Bug: 4537685
	     ,x_organization_id    => l_new_carrying_out_org_id  -- added for Bug:    4537685
             ,x_return_status      => x_return_status
             ,x_error_msg_code     => l_msg_data);
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.WRITE(g_module_name,' validating carrying out org'||l_carrying_out_org_id||x_return_status,  l_debug_level3);
           END IF;

          -- added for Bug:    4537685
          IF x_return_status = FND_API.G_RET_STS_SUCCESS   THEN
          l_carrying_out_org_id := l_new_carrying_out_org_id;
          END IF;
          -- added for Bug:    4537685

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
              l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_CARRYING_ORG_INVALID') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  l_task_number,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );
           x_return_status             := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

     Pa_Deliverable_Utils.Progress_Enabled_Validation
     (
          p_deliverable_id         =>   p_deliverable_id
        , p_project_id             =>   p_project_id
        , p_dlvr_type_id           =>   p_dlvr_type_id
        , px_actual_finish_date    =>   px_actual_finish_date
        , px_progress_weight       =>   px_progress_weight
        , px_status_code           =>   px_status_code
        , p_calling_Mode           =>   p_calling_Mode
      ) ;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR        THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
	  IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
             pa_debug.reset_curr_function;
          END IF ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR        THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
             pa_debug.reset_curr_function;
          END IF ;

     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	  IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
             pa_debug.reset_curr_function;
          END IF ;

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)       THEN
              FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name            => g_module_name
                   , p_procedure_name      => l_api_name   );
          END IF;

   END Validate_Deliverable ;

-- SubProgram           : IS_DLVR_TYPE_ID_VALID
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether the deliverable type id is valid
-- Assumptions          : None

   FUNCTION IS_DLV_TYPE_ID_VALID
   (
        p_deliverable_type_id IN NUMBER
   )   RETURN VARCHAR2
   IS

   l_return_status  varchar2(1);
   l_dummy          varchar2(1);

   CURSOR c_dlvr_type_id_exists IS
   SELECT 'X'
   FROM PA_TASK_TYPES
   WHERE TASK_TYPE_ID = p_deliverable_type_id
   AND   sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active, sysdate)
   AND OBJECT_TYPE='PA_DLVR_TYPES';

   BEGIN
       OPEN c_dlvr_type_id_exists;
       FETCH c_dlvr_type_id_exists into l_dummy ;

       IF c_dlvr_type_id_exists%found THEN
          l_return_status:='Y';
       ELSE
          l_return_status:='N';
       END IF;

       CLOSE c_dlvr_type_id_exists;

       return l_return_status;

   END IS_DLV_TYPE_ID_VALID;

-- SubProgram           : get_deliverable_version_id
-- Type                 : UTIL FUNCTION
-- Purpose              : This function returns the deliverable version id of a deliverable
-- Assumptions          : None

  FUNCTION get_deliverable_version_id
  (
      p_deliverable_id         IN NUMBER     ,
      p_structure_version_id   IN NUMBER     ,
      p_project_id             IN NUMBER
   ) RETURN NUMBER
   IS

   l_dummy          pa_proj_element_versions.element_version_id%TYPE;

   CURSOR c_dlvr_version IS
   SELECT
       pev.element_version_id
   FROM
       pa_proj_elements ppe
      ,pa_proj_element_versions pev
   WHERE
    pev.proj_element_id    =  p_deliverable_id
   AND  ppe.object_type        =  'PA_DELIVERABLES'
   AND  pev.object_type        =  'PA_DELIVERABLES'
   AND  ppe.proj_element_id    =  pev.proj_element_id
   AND  ppe.project_id         =  pev.project_id
   AND  ppe.project_id         = p_project_id
   AND  pev.parent_structure_version_id = nvl(p_structure_version_id, pev.parent_structure_version_id);

   BEGIN
       OPEN c_dlvr_version;
       FETCH c_dlvr_version into l_dummy ;

       IF c_dlvr_version%found THEN
          CLOSE c_dlvr_version;
          RETURN l_dummy;
       ELSE
          CLOSE c_dlvr_version;
          RETURN NULL;
       END IF;

   END get_deliverable_version_id;


-- SubProgram           : GET_DLVR_TASK_ASSCN_ID
-- Type                 : UTIL FUNCTION
-- Purpose              : This function returns the object_relationship_id of task and deliverable association
-- Assumptions          : None

   FUNCTION GET_DLVR_TASK_ASSCN_ID
   (
      p_deliverable_id         IN NUMBER     ,
      p_task_id             IN NUMBER
   ) RETURN NUMBER
   IS

   l_dummy          pa_object_relationships.object_relationship_Id%TYPE;

    CURSOR  c_dlvr_task_asscn IS
    SELECT  obj.object_relationship_id
    FROM    PA_OBJECT_RELATIONSHIPS obj
    WHERE   OBJ.object_id_from2 = p_task_id
    AND     OBJ.object_id_to2 =p_deliverable_id
    AND     OBJ.object_type_to = 'PA_DELIVERABLES'
    AND     OBJ.object_type_from = 'PA_TASKS'
    AND     OBJ.relationship_type = 'A'
    AND     OBJ.relationship_subtype = 'TASK_TO_DELIVERABLE';

   BEGIN
       OPEN c_dlvr_task_asscn;
       FETCH c_dlvr_task_asscn into l_dummy ;

       IF c_dlvr_task_asscn%found THEN
          CLOSE c_dlvr_task_asscn;
          RETURN l_dummy;
       ELSE
          CLOSE c_dlvr_task_asscn;
          RETURN NULL;
       END IF;

   END GET_DLVR_TASK_ASSCN_ID;

-- SubProgram           : IS_STATUS_CODE_VALID
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether the status code is valid
-- Assumptions          : None

   FUNCTION IS_STATUS_CODE_VALID
   (
        p_status_code IN VARCHAR2
      , p_calling_mode IN VARCHAR2 := 'INSERT'
   )   RETURN VARCHAR2
   IS

   l_return_status  varchar2(1);
   l_dummy          varchar2(1);

   CURSOR c_status_code_exists IS
   SELECT 'X'
   FROM PA_PROJECT_STATUSES
   WHERE UPPER(project_status_code)  = UPPER(p_status_code)
   AND   UPPER(project_system_status_code) = DECODE(p_calling_mode, 'INSERT', 'DLVR_NOT_STARTED',project_system_status_code)
   AND   status_type = 'DELIVERABLE'
   AND   sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active,sysdate);

   BEGIN
       OPEN c_status_code_exists;
       FETCH c_status_code_exists into l_dummy ;
       IF c_status_code_exists%found THEN
          l_return_status:='Y';
       ELSE
          l_return_status:='N';
       END IF;
       CLOSE c_status_code_exists;

   return l_return_status;

   END IS_STATUS_CODE_VALID;

   --====================================================================================
   --Name:               is_dlvr_reference_unique
   --Type:               procedure
   --Description:        Checking if deliverable_reference is passed or not. If passed is
   --                    unique or not
   --
   --Called subprograms: none
   --
   --
   --
   --History:
   --    19-AUG-1996        Puneet     Created
   --
   PROCEDURE is_dlvr_reference_unique
   (p_deliverable_reference IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_project_id         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_unique_flag          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status        OUT NOCOPY VARCHAR2                            ) --File.Sql.39 bug 4440895

   IS

      CURSOR l_dlvr_ref_csr
      IS
      SELECT  elem.proj_element_id, proj.segment1
      FROM    pa_proj_elements elem, pa_projects_all proj
      where   pm_source_reference = p_deliverable_reference
      and     elem.project_id = p_project_id
      and     elem.project_id = proj.project_id
      and     object_type = 'PA_DELIVERABLES';

      l_api_name      CONSTANT        VARCHAR2(30) := 'is_dlvr_reference_unique';
      l_deliverable_id                NUMBER ;
      l_dummy                         VARCHAR2(1);

      l_err_message             Fnd_New_Messages.Message_text%TYPE;  -- for AMG message
      l_project_number          Pa_Projects_All.Segment1%TYPE;


   BEGIN

       x_return_status :=  FND_API.G_RET_STS_SUCCESS;

       IF p_deliverable_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_deliverable_reference IS NOT NULL
       THEN
           OPEN l_dlvr_ref_csr;
           FETCH l_dlvr_ref_csr INTO l_deliverable_id, l_project_number;

           IF l_dlvr_ref_csr%FOUND
           THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DUP_DLVR_REFERENCE') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  null,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
          END IF;
          x_unique_flag := 'N';
          --RAISE FND_API.G_EXC_ERROR;  Commented bug 3651538 as Exception should not be raised as
          --                             it indicates that dlvr is to be updated.
           ELSE --l_dlvr_ref_csr%FOUND
          x_unique_flag := 'Y';
       END IF; --l_dlvr_ref_csr%FOUND
       CLOSE l_dlvr_ref_csr;

        ELSE

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLVR_REF_AND_ID_MISSING') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  null,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
           END IF;
       x_unique_flag := Null;
           RAISE FND_API.G_EXC_ERROR;

        END IF; -- If p_deliverable_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM


   EXCEPTION
        WHEN FND_API.G_EXC_ERROR   THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR    THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_MODULE_NAME
                                , p_procedure_name      => l_api_name   );
            END IF;

   END is_dlvr_reference_unique;

   --====================================================================================
   --Name:               convert_pm_dlvrref_to_id
   --Type:               Procedure
   --Description:        This procedure can be used to converse
   --                    an incoming deliverable reference to
   --                    a deliverable ID.
   --
   --Called subprograms: none
   --
   --
   --
   --History:
   --    19-AUG-1996        Puneet     Created
   --
   PROCEDURE Convert_pm_dlvrref_to_id
   (p_deliverable_reference IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_deliverable_id        IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id            IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_out_deliverable_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,p_return_status         OUT NOCOPY VARCHAR2                            ) --File.Sql.39 bug 4440895

   IS

   CURSOR  l_dlvr_id_csr
   IS
   SELECT  'X'
   FROM    pa_proj_elements
   where   proj_element_id = p_deliverable_id
   and     project_id = p_project_id
   and     object_type = 'PA_DELIVERABLES';

   CURSOR l_dlvr_ref_csr
   IS
   SELECT  proj_element_id
   FROM    pa_proj_elements
   where   pm_source_reference = p_deliverable_reference
   and     project_id = p_project_id
   and     object_type = 'PA_DELIVERABLES';

   CURSOR  proj_num
   IS
   SELECT  segment1
   FROM    pa_projects_all
   WHERE   project_id = p_project_id;

   l_api_name      CONSTANT        VARCHAR2(30) := 'Convert_pm_dlvrref_to_id';
   l_deliverable_id                NUMBER ;
   l_dummy                         VARCHAR2(1);
   l_project_number          Pa_Projects_All.Segment1%TYPE;

   BEGIN

       p_return_status :=  FND_API.G_RET_STS_SUCCESS;

       OPEN proj_num;
       FETCH proj_num INTO l_project_number;
       CLOSE proj_num;

       IF p_deliverable_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       AND p_deliverable_id IS NOT NULL
       THEN

           --check validity of this ID
           OPEN l_dlvr_id_csr;
           FETCH l_dlvr_id_csr INTO l_dummy;

           IF l_dlvr_id_csr%NOTFOUND
           THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLVR_ID_INVALID') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  null,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
               END IF;
               CLOSE l_dlvr_id_csr;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           CLOSE l_dlvr_id_csr;
           p_out_deliverable_id := p_deliverable_id;

       ELSIF  p_deliverable_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_deliverable_reference IS NOT NULL
       THEN

           --check validity of this reference
           OPEN l_dlvr_ref_csr;
           FETCH l_dlvr_ref_csr INTO l_deliverable_id;

           IF l_dlvr_ref_csr%NOTFOUND
           THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLVR_REF_INVALID') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'TASK',
                                p_value2         =>  null,
                                p_token3         => 'DLVR_REFERENCE',
                                p_value3         =>  p_deliverable_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
              END IF;
          CLOSE l_dlvr_ref_csr;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          CLOSE l_dlvr_ref_csr;
          p_out_deliverable_id := l_deliverable_id;
        ELSE
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLVR_REF_AND_ID_MISSING') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  p_deliverable_reference,
                                p_token3         => 'MESSAGE',
                                p_value3         =>  l_err_message
                               );
           END IF;
           RAISE FND_API.G_EXC_ERROR;

        END IF; -- If p_deliverable_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR   THEN
            p_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR    THEN
            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN
            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_MODULE_NAME
                                , p_procedure_name      => l_api_name   );
            END IF;

   END Convert_pm_dlvrref_to_id;

-- SubProgram           : get_action_version_id
-- Type                 : UTIL FUNCTION
-- Purpose              : This function returns the action version id of an action
-- Assumptions          : None

   FUNCTION get_action_version_id
   (
       p_action_id              IN NUMBER     ,
       p_structure_version_id  IN NUMBER     ,
       p_project_id             IN NUMBER
   ) RETURN NUMBER
   IS

   l_dummy          pa_proj_element_versions.element_version_id%TYPE;

   CURSOR c_action_version IS
   SELECT
       pev.element_version_id
   FROM
       pa_proj_elements ppe
      ,pa_proj_element_versions pev
   WHERE
    pev.proj_element_id    =  p_action_id
   AND  ppe.object_type        =  'PA_ACTIONS'
   AND  pev.object_type        =  'PA_ACTIONS'
   AND  ppe.proj_element_id    =  pev.proj_element_id
   AND  ppe.project_id         =  pev.project_id
   AND  ppe.project_id         =  p_project_id
   AND  nvl(pev.parent_structure_version_id,-99) = nvl(nvl(p_structure_version_id, pev.parent_structure_version_id),-99);

   BEGIN
       OPEN c_action_version;
       FETCH c_action_version into l_dummy ;

       IF c_action_version%found THEN
          CLOSE c_action_version;
          RETURN l_dummy;
       ELSE
          CLOSE c_action_version;
          RETURN NULL;
       END IF;

   END get_action_version_id;

-- SubProgram           : is_action_reference_unique
-- Type                 : UTIL FUNCTION
-- Purpose              : Check if action_reference is passed or not. Is it unique or not
-- Assumptions          : None

   PROCEDURE is_action_reference_unique
   (
       p_action_reference      IN VARCHAR2  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      ,p_deliverable_id        IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ,p_project_id            IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ,x_unique_flag          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
   IS

      CURSOR l_action_ref_csr
      IS
      SELECT  'X'
      FROM    pa_proj_elements  ppe,
              pa_object_relationships por
      WHERE   por.object_id_from2 = p_deliverable_id
      AND     object_id_to2 =ppe.proj_element_id
      AND     ppe.pm_source_reference = p_action_reference
      and     project_id = p_project_id
      and     object_type = 'PA_ACTIONS'
      and     object_type_from = 'PA_DELIVERABLES';

      CURSOR  proj_num   IS
      SELECT  proj.segment1
            , elem.name
      FROM    pa_projects_all proj
            , pa_proj_elements elem
      WHERE   proj.project_id = p_project_id
      AND     elem.project_id = proj.project_id
      AND     elem.object_type = 'PA_DELIVERABLES'
      AND     elem.proj_element_id = p_deliverable_id;

      l_api_name            CONSTANT        VARCHAR2(30) := 'is_action_reference_unique';
      l_action_id                           NUMBER ;
      l_dummy                               VARCHAR2(1);
      l_project_number                      Pa_Projects_All.Segment1%TYPE;
      l_deliverable_name                    Pa_proj_elements.name%TYPE;

   BEGIN

       x_return_status :=  FND_API.G_RET_STS_SUCCESS;

       OPEN proj_num;
       FETCH proj_num INTO l_project_number, l_deliverable_name;
       CLOSE proj_num;

       IF p_action_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_action_reference IS NOT NULL
       THEN
           OPEN l_action_ref_csr;
           FETCH l_action_ref_csr INTO l_dummy;   -- 3749462 changed from l_action_id to l_dummy

           IF l_action_ref_csr%FOUND THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_ACTION_REF_INVALID') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_name,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
              END IF; -- fnd_msg_pub.g_msg_lvl_error

              CLOSE l_action_ref_csr;
              x_unique_flag := 'N';
              RAISE FND_API.G_EXC_ERROR;

          END IF; -- l_action_dlvr_relation%FOUND
          CLOSE l_action_ref_csr;

        ELSE -- p_action_reference IS NULL
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_ACTION_REF_AND_ID_MISSING') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_name,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
            END IF;-- fnd_msg_pub.g_msg_lvl_error

            x_unique_flag := Null;

            RAISE FND_API.G_EXC_ERROR;

        END IF; -- p_action_reference IS NULL

        x_unique_flag := 'Y';

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR   THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR    THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_MODULE_NAME
                                , p_procedure_name      => l_api_name   );
            END IF;

   END is_action_reference_unique;

   --Name:               IS_FUNCTION_CODE_VALID
   --Type:               FUNCTION
   --Description:        This functions validate the function code based on lookup values
   --                    an action ID.

   FUNCTION IS_FUNCTION_CODE_VALID
   (
        p_function_code       IN VARCHAR2
   ) RETURN VARCHAR2
   IS

     CURSOR c_func_code  IS
     SELECT 'X'
     FROM   pa_lookups
     WHERE  lookup_type = 'PA_DLVR_ACTION_FUNCTION'
     AND    lookup_code = p_function_code;

     l_dummy VARCHAR2(1) := 'Y';

   BEGIN

       OPEN c_func_code;
       FETCH c_func_code into l_dummy;

       IF c_func_code%NOTFOUND THEN
      CLOSE c_Func_code;
          return 'N';
       ELSE
      CLOSE c_Func_code;
          return 'Y';
       END IF;

   END IS_FUNCTION_CODE_VALID;

   --Name:               convert_pm_actionref_to_id
   --Type:               Procedure
   --Description:        This procedure can be used to converse an incoming action reference to
   --                    an action ID.

    PROCEDURE Convert_pm_actionref_to_id
    (
       p_action_reference IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      ,p_action_id        IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ,p_deliverable_id   IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ,p_project_id       IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ,p_out_action_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
   IS

   CURSOR  l_action_id_csr
   IS
      SELECT  ppe.proj_element_id
      FROM    pa_proj_elements  ppe,
              pa_object_relationships por
      WHERE   por.object_id_from2 = p_deliverable_id
      AND     object_id_to2 = ppe.proj_element_id
      AND     ppe.proj_element_id = p_action_id
      and     ppe.project_id = p_project_id
      and     object_type = 'PA_ACTIONS'
      and     object_type_from = 'PA_DELIVERABLES';

   CURSOR  l_action_ref_csr
   IS
      SELECT  ppe.proj_element_id
      FROM    pa_proj_elements  ppe,
              pa_object_relationships por
      WHERE   por.object_id_from2 = p_deliverable_id
      AND     object_id_to2 = ppe.proj_element_id
      AND     ppe.pm_source_reference = p_action_reference
      and     ppe.project_id = p_project_id
      and     object_type = 'PA_ACTIONS'
      and     object_type_from = 'PA_DELIVERABLES';

      CURSOR  proj_num   IS
      SELECT  proj.segment1
            , elem.name
      FROM    pa_projects_all proj
            , pa_proj_elements elem
      WHERE   proj.project_id = p_project_id
      AND     elem.project_id = proj.project_id
      AND     elem.object_type = 'PA_DELIVERABLES'
      AND     elem.proj_element_id = p_deliverable_id;


   l_api_name      CONSTANT        VARCHAR2(30) := 'Convert_pm_dlvrref_to_id';
   l_action_id                     NUMBER ;
   l_dummy                         VARCHAR2(1);
   l_project_number          Pa_Projects_All.Segment1%TYPE;
   l_deliverable_name        Pa_proj_elements.name%TYPE;

   BEGIN

       p_return_status :=  FND_API.G_RET_STS_SUCCESS;

       OPEN proj_num;
       FETCH proj_num INTO l_project_number, l_deliverable_name;
       CLOSE proj_num;

       IF p_action_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       AND p_action_id IS NOT NULL
       THEN

           --check validity of this ID
           OPEN l_action_id_csr;
           FETCH l_action_id_csr INTO l_action_id;

           IF l_action_id_csr%NOTFOUND
           THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_ACTION_ID_INVALID') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_name,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );

                   END IF;
                   CLOSE l_action_id_csr;
                   RAISE FND_API.G_EXC_ERROR;
           END IF;

           CLOSE l_action_id_csr;
           p_out_action_id := p_action_id;

       ELSIF  p_action_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_action_reference IS NOT NULL
       THEN

           --check validity of this reference
           OPEN l_action_ref_csr;
           FETCH l_action_ref_csr INTO l_action_id;

           IF l_action_ref_csr%NOTFOUND
           THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_ACTION_REF_INVALID') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_name,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
              END IF;

              CLOSE l_action_ref_csr;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           CLOSE l_action_ref_csr;
           p_out_action_id := l_action_id;
        ELSE
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_ACTION_REF_AND_ID_MISSING') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_DLVR_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_name,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
           END IF;
           RAISE FND_API.G_EXC_ERROR;

        END IF; -- If p_action_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR   THEN
            p_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR    THEN
            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN
            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_MODULE_NAME
                                , p_procedure_name      => l_api_name   );
            END IF;

   END Convert_pm_actionref_to_id;

   --Name:               Progress_Enabled_Validation
   --Type:               Procedure
   --Description:        This procedure is used to modify/validate
   --                     completion date, status code, progress weight
   --                    based on progress enabled or not for a dlvr.
   --
   -- Logic :
   --   FOR CREATE
   --     Progress  Completion  Status                      Progress
   --     Enabled   Date        Code                        Weight
   --
   --         Y     Null        mapped to DLV_NOT_STARTED    User value
   --         N     Null        mapped to DLV_NOT_STARTED    Null
   --   FOR UPDATE
   --         Y     No updation  No updation                 User Value
   --         N     User Value   User Value                   Null

   PROCEDURE Progress_Enabled_Validation
   (
      p_deliverable_id         IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    , p_project_id             IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    , p_dlvr_type_id           IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    , px_actual_finish_date    IN OUT NOCOPY DATE --File.Sql.39 bug 4440895
    , px_progress_weight       IN OUT NOCOPY PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE --File.Sql.39 bug 4440895
    , px_status_code           IN OUT NOCOPY Pa_task_types.initial_status_code%TYPE --File.Sql.39 bug 4440895
    , p_calling_Mode           IN VARCHAR2  := 'INSERT'
   ) IS

       Cursor C1 IS
       SELECT  completion_date, status_code
       FROM    pa_deliverables_v
       WHERE   project_id = p_project_id
       AND     proj_element_id = p_deliverable_id
       AND     dlvr_type_id = p_dlvr_type_id;


       l_dlvr_prg_enabled              VARCHAR2(1)     := NULL;
       l_dlvr_action_enabled           VARCHAR2(1)     := NULL;
       l_status_code            Pa_task_types.initial_status_code%TYPE := NULL;

   BEGIN
   -- Fetching information based on deliverable type
      PA_DELIVERABLE_UTILS.get_dlvr_type_info
      (
         p_dlvr_type_id              =>  p_dlvr_type_id,
         x_dlvr_prg_enabled          =>  l_dlvr_prg_enabled,
         x_dlvr_action_enabled       =>  l_dlvr_action_enabled,
         x_dlvr_default_status_code  =>  l_status_code
       );

     Pa_Debug.WRITE(g_module_name,'Progress_Enabled dlvr_type['||p_dlvr_type_id||']Prg Enabled[' ||l_dlvr_prg_enabled||
                     ']Action Enabled['||l_dlvr_action_enabled||']status['||l_status_code||']',l_debug_level3);

 -- Override the default status code in case passed by customer.
      IF px_status_code IS NOT NULL THEN
      l_status_code := px_status_code;
      END IF;

      IF (l_dlvr_prg_enabled = 'Y') THEN

         IF ( p_calling_mode = 'INSERT') THEN
             px_actual_finish_date := NULL;
             px_status_code        := l_status_code;
         px_progress_weight    := px_progress_weight;
     ELSE  --p_calling_mode = 'UPDATE'
         OPEN C1;
         FETCH C1 INTO  px_actual_finish_date , px_status_code;
         px_progress_weight    := px_progress_weight;
         CLOSE C1;
     END IF;  --p_calling_mode = 'INSERT'

      ELSE -- l_dlvr_prg_enabled = 'N'

         IF ( p_calling_mode = 'INSERT') THEN
             px_actual_finish_date := NULL;
             px_status_code        := l_status_code;
         px_progress_weight    := NULL;
     ELSE  --p_calling_mode = 'UPDATE'
             px_actual_finish_date := px_actual_finish_date;
             px_status_code        := l_status_code;
         px_progress_weight    := NULL;
     END IF;  --p_calling_mode = 'INSERT'

      END IF; -- l_dlvr_prg_enabled = 'Y'
   END Progress_Enabled_Validation;

   --Name:               enable_deliverable
   --Type:               Procedure
   --Description:        This api calls Pa_Project_Structure_Pub1 apis for
   --                    creating Structure, Structure Versions, Structure Version Attributes

   Procedure enable_deliverable(
    p_api_version            IN  NUMBER     := 1.0
   ,p_init_msg_list          IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                 IN  VARCHAR2    := FND_API.G_FALSE
  , p_debug_mode             IN  VARCHAR2   := 'N'
  , p_validate_only          IN VARCHAR2  :=FND_API.G_TRUE
  , p_project_id             IN   Pa_Projects_All.project_id%TYPE
  , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )IS
    Cursor C_name  IS
           SELECT  segment1||':Deliverable'
           FROM    pa_Projects_All
           WHERE   Project_id = p_Project_Id;

    l_name                      Pa_Proj_Elements.Name%TYPE;
    l_structure_id              Pa_Proj_Elements.Proj_Element_Id%TYPE;
    l_structure_version_id      Pa_Proj_Element_Versions.Element_Version_Id%TYPE;
    l_pev_structure_id          Pa_Proj_Element_Versions.Element_Version_Id%TYPE;

    l_api_name      CONSTANT  VARCHAR2(30)     := 'ENABLE_DELIVERABLES';
    l_msg_index_out              NUMBER;
    -- added for Bug:4537865
    l_new_msg_data 		 VARCHAR2(2000);
    -- added for Bug:4537865
BEGIN

 --  Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list )  THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
       savepoint CREATE_DELIVERABLE_PUB;
    END IF;

    IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => l_api_name,
                                      p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside '||l_api_name;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

   --  Set API return status to success
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

     OPEN   C_name;
     FETCH  C_name INTO l_name;
     CLOSE  C_name;

     PA_PROJECT_STRUCTURE_PUB1.create_structure (
             p_api_version       => p_api_version
         ,   p_init_msg_list     => p_init_msg_list
         ,   p_commit            => p_commit
         ,   p_debug_mode        => p_debug_mode
         ,   p_validate_only     => p_validate_only
         ,   p_project_id        => p_project_id
         ,   p_calling_flag      => 'DELIVERABLE'
         ,   p_calling_module    => 'AMG'
         ,   p_structure_name    => l_name
         ,   p_structure_description  => l_name
         ,   x_return_status     => x_return_status
         ,   x_msg_count         => x_msg_count
         ,   x_msg_data          => x_msg_data
         ,   x_structure_id      => l_structure_Id
         );

     IF p_debug_mode = 'Y' THEN
           pa_debug.write(g_module_name,'PA_PROJECT_STRUCTURE_PUB1.create_structure Return Status ['||x_return_status||']Struc ID['||l_structure_id||']',3) ;
     END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;


      PA_PROJECT_STRUCTURE_PUB1.Create_Structure_Version (
             p_api_version       => p_api_version
         ,   p_init_msg_list     => p_init_msg_list
         ,   p_commit            => p_commit
         ,   p_debug_mode        => p_debug_mode
         ,   p_validate_only     => p_validate_only
         ,   p_calling_module    => 'AMG'
         ,   p_structure_id      => l_structure_id
         ,   x_return_status     => x_return_status
         ,   x_msg_count         => x_msg_count
         ,   x_msg_data          => x_msg_data
         ,   x_structure_version_id => l_structure_version_id
         );

     IF p_debug_mode = 'Y' THEN
           pa_debug.write(g_module_name,'PA_PROJECT_STRUCTURE_PUB1.Create_Structure_Version Return Status ['||x_return_status||']Struc Vers ID['||l_structure_version_id||']',3) ;
     END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;


      PA_PROJECT_STRUCTURE_PUB1.Create_Structure_Version_Attr (
             p_api_version            => p_api_version
         ,   p_init_msg_list          => p_init_msg_list
         ,   p_commit                 => p_commit
         ,   p_debug_mode             => p_debug_mode
         ,   p_validate_only          => p_validate_only
         ,   p_calling_module         => 'AMG'
         ,   p_structure_version_id   => l_structure_version_id
         ,   p_structure_version_name => l_name
         ,   p_structure_version_desc => l_name
         ,   p_change_reason_code     =>  null
         ,   x_pev_structure_id       => l_pev_structure_id
         ,   x_return_status          => x_return_status
         ,   x_msg_count              => x_msg_count
         ,   x_msg_data               => x_msg_data
         );

     IF p_debug_mode = 'Y' THEN
           pa_debug.write(g_module_name,'PA_PROJECT_STRUCTURE_PUB1.Create_Structure_Version_Attr Return Status ['||x_return_status||']Struc ID['||l_pev_structure_id||']',3) ;
     END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF p_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR        THEN
      IF (p_commit = FND_API.G_TRUE) THEN
         ROLLBACK TO CREATE_DELIVERABLE_PUB;
      END IF;
      IF p_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
          pa_debug.write(g_module_name,l_api_name||': Inside G_EXC_ERROR exception',5);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;

      IF x_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_FALSE,
                p_msg_index      => 1,
                p_msg_count      => x_msg_count,
                p_msg_data       => x_msg_data,
            --  p_data           => x_msg_data, 	* commented for Bug: 4537865
		p_data           => l_new_msg_data,     -- added for Bug: 4537865
                p_msg_index_out  => l_msg_index_out);

		 -- added for Bug: 4537865
		x_msg_data := l_new_msg_data;
		 -- added for Bug: 4537865
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR        THEN
      IF (p_commit = FND_API.G_TRUE) THEN
         ROLLBACK TO CREATE_DELIVERABLE_PUB;
      END IF;
      IF p_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;

          pa_debug.write(g_module_name,l_api_name||': Inside G_EXC_UNEXPECTED_ERROR exception',5);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;

      IF x_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_FALSE,
                p_msg_index      => 1,
                p_msg_count      => x_msg_count,
                p_msg_data       => x_msg_data,
         --     p_data           => x_msg_data,     * commented for Bug: 4537865
		p_data           => l_new_msg_data, -- added for Bug: 4537865
                p_msg_index_out  => l_msg_index_out);

		-- added for Bug: 4537865
		 x_msg_data := l_new_msg_data;
		-- added for Bug: 4537865

     END IF;

   WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
         ROLLBACK TO CREATE_DELIVERABLE_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;
      x_msg_data := SQLERRM;

      IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:=l_api_name||': Unexpected Error'||SQLERRM;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
      END IF;


   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)       THEN
       FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name            => g_module_name
                   , p_procedure_name      => l_api_name   );
  END IF;
END enable_deliverable;

/* ==============3435905 : FP M : Deliverables Changes For AMG - END * =========================*/

-- SubProgram           : IS_DLV_PROGRESSABLE
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether  the given delievrable has progress
--                        entry allowed
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
--      p_project_id                     IN                  NUMBER              Project Id
--      p_deliverable_id                 IN                  NUMBER              Deliverable Proj Element Id

FUNCTION IS_DLV_PROGRESSABLE
(
     p_project_id     IN NUMBER
    ,p_deliverable_id IN NUMBER
)   RETURN VARCHAR2
IS

l_dummy          varchar2(1):='N';

CURSOR c_dlv_type IS
SELECT nvl(prog_entry_enable_flag,'N')
from pa_proj_elements elem
, pa_task_types dlvtype
where elem.type_id = dlvtype.task_type_id
and elem.proj_element_id = p_deliverable_id
and elem.object_type = 'PA_DELIVERABLES'
and elem.project_id = p_project_id;

BEGIN
     OPEN c_dlv_type;
     FETCH c_dlv_type into l_dummy ;
     IF c_dlv_type%notfound THEN
       l_dummy:='N';
     END IF;
     CLOSE c_dlv_type;

return l_dummy;

END IS_DLV_PROGRESSABLE;

-- SubProgram           : IS_STR_TASK_HAS_DELIVERABLES
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will check whether  the given task has deliverables
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
--      p_str_task_id                    IN                  NUMBER              Proj Element Id of structure or task

FUNCTION IS_STR_TASK_HAS_DELIVERABLES
(
    p_str_task_id IN NUMBER
)   RETURN VARCHAR2
IS

l_dummy          varchar2(1):='N';

CURSOR c_task_dlvs IS
SELECT 'Y'
FROM dual
WHERE exists
(Select 'xyz'
from pa_object_relationships
where object_id_from2 = p_str_task_id
and relationship_type = 'A'
and relationship_subtype IN ('STRUCTURE_TO_DELIVERABLE', 'TASK_TO_DELIVERABLE')
);

BEGIN
     OPEN c_task_dlvs;
     FETCH c_task_dlvs into l_dummy ;
     IF c_task_dlvs%found THEN
       l_dummy:='Y';
     ELSE
       l_dummy:='N';
     END IF;

     CLOSE c_task_dlvs;

return l_dummy;

END IS_STR_TASK_HAS_DELIVERABLES;

-- SubProgram           : GET_TASK_DATES ( 3442451 )
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will retrun date ( i.e. schedule_start_date / schedule_finish_date /
--                        actual_start_date / actual_finish_date / earliest_start_date / earliest_finish_date )
--                        based on p_date_type parameter
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
-- p_project_id                    IN               NUMBER       Yes           Project Id
-- p_date_type                     IN               VARCHAR2     Yes           Date Type
-- p_task_id                       IN               NUMBER       Yes           proj element id of task

FUNCTION GET_TASK_DATES
(
     p_project_id           IN NUMBER
    ,p_date_type            IN VARCHAR2
    ,p_task_id              IN NUMBER
)  RETURN DATE
IS


-- 3578694 removed the cursor
-- as PA_PROJ_ELEMENT_VERSIONS had join with object relationship table
-- and one of the where condition was checking the structure_to_task relationship subtype
-- so for child tasks, above condition is failing

--cursor c_task_exists(l_struct_ver_id IN NUMBER) IS
--    SELECT
--           PEV.ELEMENT_VERSION_ID
--    FROM
--           PA_OBJECT_RELATIONSHIPS POR
--           ,PA_PROJ_ELEMENT_VERSIONS PEV
--    WHERE
--           POR.OBJECT_ID_FROM1 = l_struct_ver_id
--       AND PEV.PROJ_ELEMENT_ID = p_task_id
--       AND POR.OBJECT_ID_TO1 = PEV.ELEMENT_VERSION_ID
--       AND POR.OBJECT_TYPE_FROM = 'PA_STRUCTURES'
--       AND POR.OBJECT_TYPE_TO = 'PA_TASKS'
--       AND POR.RELATIONSHIP_SUBTYPE = 'STRUCTURE_TO_TASK';

-- 3578694 cursor will return task element version id for the
-- passed structure version id
cursor c_task_exists(l_struct_ver_id IN NUMBER) IS
    SELECT
           PEV.ELEMENT_VERSION_ID
    FROM
           PA_PROJ_ELEMENT_VERSIONS PEV
    WHERE
           PEV.PARENT_STRUCTURE_VERSION_ID = l_struct_ver_id
       AND PEV.PROJ_ELEMENT_ID = p_task_id
       AND PEV.PROJECT_ID = p_project_id;

CURSOR c_task_info(l_task_ver_id IN NUMBER) IS
    SELECT
            SCHEDULED_START_DATE
           ,SCHEDULED_FINISH_DATE
           ,ACTUAL_START_DATE
           ,ACTUAL_FINISH_DATE
           ,EARLY_START_DATE
           ,EARLY_FINISH_DATE
    FROM
           PA_PROJ_ELEM_VER_SCHEDULE
    WHERE
           ELEMENT_VERSION_ID = l_task_ver_id ;

         /*AND  PROJECT_ID = p_project_id Commented Unwanted Join 3614361 */

l_date                              DATE := NULL;

l_latest_pub_wp_struct_id           NUMBER := NULL;
l_current_working_wp_struct_id      NUMBER := NULL;
l_wp_struct_id                      NUMBER := NULL;

l_task_ver_id                       NUMBER := NULL;

is_task_in_published_ver            VARCHAR(1) := 'N';
is_task_in_curnt_wrkng_ver          VARCHAR(1) := 'N';

c_task_rec c_task_exists%rowtype;
c_task_date_rec c_task_info%rowtype;

BEGIN

    -- retrieve published wp structure version id

    l_latest_pub_wp_struct_id := PA_PROJ_ELEMENTS_UTILS.latest_published_ver_id(p_project_id);

    -- check whether task exists for published wp structure
    -- if yes
    --     retrieve task version id, set is_task_in_published_ver to 'Y' and task version id in local variable
    -- else
    --     retrieve current working wp structure version id
    --     if yes retrieve task version id,
    --        set is_task_in_published_ver to 'Y' and task version id in local variible
    --     end if
    -- end if
    -- if task_vers_id retrieved is not null , i.e. task is either in published or current working
    --    retrieve the required dates for the task version id based on date type variable value
    -- else
    --    return null value
    -- end if

    -- 3578694 added if condition for checking l_latest_pub_wp_struct_id for NULL
    -- if l_latest_pub_wp_struct_id is null, set is_task_in_published_ver to 'N'
    -- and do not check for task existance for that particular structure version

    IF l_latest_pub_wp_struct_id IS NULL THEN
        is_task_in_published_ver := 'N';
    ELSE

        OPEN c_task_exists(l_latest_pub_wp_struct_id);
        FETCH c_task_exists into c_task_rec;

        IF c_task_exists%NOTFOUND THEN
            is_task_in_published_ver := 'N';
        ELSE
            is_task_in_published_ver := 'Y';
            l_task_ver_id := c_task_rec.ELEMENT_VERSION_ID;
        END IF;

        CLOSE c_task_exists;
    END IF;

    IF is_task_in_published_ver = 'N' THEN
        l_current_working_wp_struct_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(p_project_id);

        OPEN c_task_exists(l_current_working_wp_struct_id);
        FETCH c_task_exists into c_task_rec ;

        IF c_task_exists%notfound THEN
            is_task_in_curnt_wrkng_ver := 'N';
        ELSE
            is_task_in_curnt_wrkng_ver := 'Y';
            l_task_ver_id := c_task_rec.ELEMENT_VERSION_ID;
        END IF;

        CLOSE c_task_exists;
    END IF;

    IF l_task_ver_id IS NOT NULL THEN
        OPEN c_task_info(l_task_ver_id);
        FETCH c_task_info into c_task_date_rec ;
        CLOSE c_task_info;

        IF p_date_type = 'SCH_START_DATE' THEN
            l_date := c_task_date_rec.SCHEDULED_START_DATE;
        ELSIF p_date_type = 'SCH_FINISH_DATE' THEN
            l_date := c_task_date_rec.SCHEDULED_FINISH_DATE;
        ELSIF p_date_type = 'ACT_START_DATE' THEN
            l_date := c_task_date_rec.ACTUAL_START_DATE;
        ELSIF p_date_type = 'ACT_FINISH_DATE' THEN
            l_date := c_task_date_rec.ACTUAL_FINISH_DATE;
        ELSIF p_date_type = 'EARLY_START_DATE' THEN
            l_date := c_task_date_rec.EARLY_START_DATE;
        ELSIF p_date_type = 'EARLY_FINISH_DATE' THEN
            l_date := c_task_date_rec.EARLY_FINISH_DATE;
        ELSE
            l_date := NULL;
        END IF;
    END IF;

    return l_date;

END GET_TASK_DATES;

FUNCTION IS_DLV_BASED_TASK_EXISTS
(
    p_project_id IN NUMBER
)   RETURN VARCHAR2
IS
  CURSOR dlv_based_task IS
  SELECT 'Y'
    FROM dual
  WHERE EXISTS ( SELECT 'Y'
                   FROM pa_proj_elements
                   WHERE base_percent_comp_deriv_code = 'DELIVERABLE'
                     AND object_type = 'PA_TASKS'
                     AND project_id = p_project_id);
 l_dummy VARCHAR2(1) := 'N' ;
BEGIN
   OPEN dlv_based_task ;
  FETCH dlv_based_task INTO l_dummy ;
  CLOSE dlv_based_task ;

  RETURN l_dummy ;
END IS_DLV_BASED_TASK_EXISTS ;

FUNCTION IS_DELIVERABLES_DEFINED
(
    p_project_id IN NUMBER
)   RETURN VARCHAR2
IS
 CURSOR is_dlv_exists IS
  SELECT 'Y'
    FROM dual
  WHERE EXISTS ( SELECT 'Y'
                   FROM pa_proj_elements
                   WHERE object_type = 'PA_DELIVERABLES'
                     AND project_id = p_project_id);
 l_dummy VARCHAR2(1) := 'N' ;
BEGIN

  OPEN is_dlv_exists ;
  FETCH is_dlv_exists INTO l_dummy ;
  CLOSE is_dlv_exists ;

  RETURN l_dummy ;
END IS_DELIVERABLES_DEFINED ;

FUNCTION CHECK_USER_VIEW_DLV_PRIVILEGE
(
    p_project_id IN NUMBER
)   RETURN VARCHAR2
IS
l_ret_code VARCHAR2(1) ;
BEGIN
l_ret_code := PA_SECURITY_PVT.check_user_privilege
  ( p_privilege    => 'PA_DELIVERABLE_VIEW'
   ,p_object_name  => 'PA_PROJECTS'
   ,p_object_key   => p_project_id
   ) ;
RETURN l_ret_code ;
END CHECK_USER_VIEW_DLV_PRIVILEGE;


PROCEDURE GET_DEFAULT_TASK
(
    p_dlv_element_id    IN  NUMBER
   ,p_dlv_version_id    IN  NUMBER
   ,p_project_id        IN  NUMBER
   ,x_oke_task_id       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_oke_task_name     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_oke_task_number   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_bill_task_id      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_bill_task_name    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_bill_task_number  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  -- This cursor will return the fin. task id which are mapped to WP
  -- task which are associated to give deliverable for SPLIT
  -- MAPPING setup.

  -- 3586196 changed cursor for where conditions and
  -- added task name number column
  CURSOR split_mapping(c_parent_struct_ver_id IN NUMBER) IS
  SELECT distinct  pt.task_id
                  ,pt.task_name
                  ,pt.task_number
    FROM pa_tasks pt
        ,pa_proj_element_versions pev1
        ,pa_proj_element_versions pev2
        ,pa_object_relationships obj1
        ,pa_object_relationships obj2
   WHERE obj1.object_id_to2 = p_dlv_element_id
     AND obj1.relationship_type = 'A'
     AND obj1.relationship_subtype = 'TASK_TO_DELIVERABLE'
     AND obj1.object_type_from = 'PA_TASKS'
     AND obj1.object_type_to = 'PA_DELIVERABLES'
     AND pev1.proj_element_id = obj1.object_id_from2
     AND pev1.parent_structure_version_id = c_parent_struct_ver_id
     AND pev1.project_id = p_project_id
     AND obj2.object_id_from1 = pev1.element_version_id
     AND obj2.relationship_type = 'M'
     AND pev2.element_version_id = obj2.object_id_to1
     AND pt.project_id = p_project_id
     AND pt.task_id = pev2.proj_element_id
     AND pt.chargeable_flag = 'Y' ;

  -- This cursor will return the fin. task id in PARTLY /FULLY
  -- SHARED structure
  CURSOR share_partial_or_full(c_parent_struct_ver_id IN NUMBER) IS
  SELECT distinct  pt.task_id
                   ,pt.task_name
                   ,pt.task_number
    FROM pa_tasks pt
        ,pa_proj_element_versions pev
        ,pa_object_relationships obj
   WHERE obj.object_id_to2 = p_dlv_element_id
     AND obj.relationship_type = 'A'
     AND obj.relationship_subtype = 'TASK_TO_DELIVERABLE'
     AND obj.object_type_from = 'PA_TASKS'
     AND obj.object_type_to = 'PA_DELIVERABLES'
     AND pev.proj_element_id = obj.object_id_from2
     AND pev.parent_structure_version_id = c_parent_struct_ver_id
     AND pev.project_id = p_project_id
     AND pev.proj_element_id = pt.task_id
     AND pt.project_id = p_project_id
     AND pt.chargeable_flag = 'Y' ;


  -- This cursor will return the fin. top task id which are
  -- mapped to WP task which are associated to give deliver
  -- able for SPLIT MAPPING setup.
  CURSOR split_mapping_bill(c_parent_struct_ver_id IN NUMBER) IS
  SELECT distinct  pt.top_task_id
                   ,pt1.task_name
                   ,pt1.task_number
    FROM pa_tasks pt
        ,pa_proj_element_versions pev1
        ,pa_proj_element_versions pev2
        ,pa_object_relationships obj1
        ,pa_object_relationships obj2
        ,pa_tasks pt1
   WHERE obj1.object_id_to2 = p_dlv_element_id
     AND obj1.relationship_type = 'A'
     AND obj1.relationship_subtype = 'TASK_TO_DELIVERABLE'
     AND obj1.object_type_from = 'PA_TASKS'
     AND obj1.object_type_to = 'PA_DELIVERABLES'
     AND pev1.proj_element_id = obj1.object_id_from2
     AND pev1.parent_structure_version_id = c_parent_struct_ver_id
     AND pev1.project_id = p_project_id
     AND obj2.object_id_from1 = pev1.element_version_id
     AND obj2.relationship_type = 'M'
     AND pev2.element_version_id = obj2.object_id_to1
     AND pt.project_id = p_project_id
     AND pt.task_id = pev2.proj_element_id
     AND pt1.task_id = pt.top_task_id
     AND pt1.project_id = p_project_id;

  -- This cursor will return the fin. top task id which in PARTLY/FULLY
  -- SHARED STRUCTURE
  CURSOR share_partial_or_full_bill(c_parent_struct_ver_id IN NUMBER) IS
  SELECT distinct  pt.top_task_id
                   ,pt1.task_name
                   ,pt1.task_number
    FROM pa_tasks pt
        ,pa_proj_element_versions pev
        ,pa_object_relationships obj
        ,pa_tasks pt1
   WHERE obj.object_id_to2 = p_dlv_element_id
     AND obj.relationship_type = 'A'
     AND obj.relationship_subtype = 'TASK_TO_DELIVERABLE'
     AND obj.object_type_from = 'PA_TASKS'
     AND obj.object_type_to = 'PA_DELIVERABLES'
     AND pev.proj_element_id = obj.object_id_from2
     AND pev.parent_structure_version_id = c_parent_struct_ver_id
     AND pev.project_id = p_project_id
     AND pev.proj_element_id = pt.task_id
     AND pt.project_id = p_project_id
     AND pt1.task_id = pt.top_task_id
     AND pt1.project_id = p_project_id;


i                    NUMBER ;
l_share_type         VARCHAR2(30) := null ;
l_struct_version_id  NUMBER := null ;
l_debug_mode         VARCHAR2(1) ;

BEGIN

x_msg_count := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

IF l_debug_mode = 'Y' THEN
     PA_DEBUG.set_curr_function( p_function   => 'GET_DEFAULT_TASK'
                                ,p_debug_mode => l_debug_mode );
     pa_debug.g_err_stage:= 'Inside GET_DEFAULT_TASK ';
     pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

l_share_type := PA_PROJ_TASK_STRUC_PUB.GET_SHARE_TYPE(p_project_id => p_project_id );

-- 3586196 added debug statements

IF l_debug_mode = 'Y' THEN
     pa_debug.write(g_module_name,'l_share_type: ' || l_share_type,3);
END IF;

-- First get the current working version. If its not available get the latest published version.
l_struct_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_CURRENT_WORKING_VER_ID(p_project_id => p_project_id) ;

IF l_debug_mode = 'Y' THEN
     pa_debug.write(g_module_name,'l_struct_version_id: ' || l_struct_version_id,3);
END IF;

If nvl(l_struct_version_id,-99)=-99 THEN
     l_struct_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(p_project_id => p_project_id) ;
END IF ;

IF l_debug_mode = 'Y' THEN
     pa_debug.write(g_module_name,'l_struct_version_id: ' || l_struct_version_id,3);
END IF;

IF l_share_type = 'SPLIT_MAPPING' THEN

     -- Get the default task id for OKE
     OPEN split_mapping(l_struct_version_id) ;
     i:=0 ;
     LOOP
          i:=i+1 ;
          FETCH split_mapping INTO x_oke_task_id, x_oke_task_name, x_oke_task_number ;
     EXIT WHEN (split_mapping%NOTFOUND OR i>2) ;
     END LOOP;
     CLOSE split_mapping ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.write(g_module_name,'i: ' || i,3);
     END IF;

     IF i>2 THEN
          x_oke_task_id := null ;
          x_oke_task_name := null;
          x_oke_task_number := null;
     END IF ;

     -- Get the default task id for BILLING
     OPEN split_mapping_bill(l_struct_version_id) ;
     i:=0 ;
     LOOP
          i:=i+1 ;
          FETCH split_mapping_bill INTO x_bill_task_id, x_bill_task_name, x_bill_task_number ;
     EXIT WHEN (split_mapping_bill%NOTFOUND OR i>2) ;
     END LOOP;
     CLOSE split_mapping_bill ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.write(g_module_name,'i: ' || i,3);
     END IF;

     IF i>2 THEN
          x_bill_task_id := null ;
          x_bill_task_name := null;
     END IF ;

ELSIF l_share_type IN ('SHARE_PARTIAL','SHARE_FULL')  THEN

     -- Get the default task id for OKE
     OPEN share_partial_or_full(l_struct_version_id) ;
     i:=0 ;
     LOOP
          i:=i+1 ;
          FETCH share_partial_or_full INTO x_oke_task_id, x_oke_task_name, x_oke_task_number ;
     EXIT WHEN (share_partial_or_full%NOTFOUND OR i>2) ;
     END LOOP;
     CLOSE share_partial_or_full ;

     IF i>2 THEN
          x_oke_task_id := null ;
          x_oke_task_name := null;
          x_oke_task_number := null;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.write(g_module_name,'i: ' || i,3);
     END IF;

     -- Get the default task id for BILLING
     OPEN share_partial_or_full_bill(l_struct_version_id) ;
     i:=0 ;
     LOOP
          i:=i+1 ;
          FETCH share_partial_or_full_bill INTO x_bill_task_id, x_bill_task_name, x_bill_task_number ;
     EXIT WHEN (share_partial_or_full_bill%NOTFOUND OR i>2) ;
     END LOOP;
     CLOSE share_partial_or_full_bill ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.write(g_module_name,'i: ' || i,3);
     END IF;

     IF i>2 THEN
          x_bill_task_id := null ;
          x_bill_task_name := null;
          x_bill_task_number := null;
     END IF ;

END IF ;

 IF l_debug_mode = 'Y' THEN
    pa_debug.write(g_module_name,'x_oke_task_id: ' || x_oke_task_id,3);
    pa_debug.write(g_module_name,'x_oke_task_name: ' || x_oke_task_name,3);
    pa_debug.write(g_module_name,'x_oke_task_number: ' || x_oke_task_number,3);
    pa_debug.write(x_bill_task_id,'x_bill_task_id: ' || x_bill_task_id,3);
    pa_debug.write(g_module_name,'x_bill_task_name: ' || x_bill_task_name,3);
    pa_debug.write(g_module_name,'x_bill_task_number: ' || x_bill_task_number,3);
 END IF;


IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:= 'Exiting GET_DEFAULT_TASK' ;
      pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
      pa_debug.reset_curr_function;
END IF;
EXCEPTION
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLE_UTILS'
                     ,p_procedure_name  => 'GET_DEFAULT_TASK');

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('GET_DEFAULT_TASK: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END GET_DEFAULT_TASK;



-- SubProgram           : IS_SHIPPING_INITIATED ( 3555460 )
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will 'Y' if shipping is initiated for deliverable
--                        'N' if shipping is not initiated
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
-- p_dlv_element_id                IN               NUMBER       Yes           Deliverale Element ID
-- p_dlv_version_id                IN               NUMBER       Yes           Deliverable Version Id

FUNCTION IS_SHIPPING_INITIATED
     (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
          ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR ship_flag_dlv IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE obj.object_id_from2 = p_dlv_element_id
                        AND obj.object_type_to = 'PA_ACTIONS'
                        AND obj.object_type_from = 'PA_DELIVERABLES'
                        AND obj.object_id_to2 = ver.proj_element_id
                        AND obj.relationship_type = 'A'
                        AND obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
                        AND nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(ver.element_version_id),'N') = 'Y'
                  ) ;
l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;
BEGIN
     OPEN ship_flag_dlv;
     FETCH ship_flag_dlv into l_dummy ;
     IF ship_flag_dlv%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE ship_flag_dlv;
return l_return_status;
END IS_SHIPPING_INITIATED ;

-- SubProgram           : IS_PROCUREMENT_INITIATED ( 3555460 )
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will 'Y' if procurement is initiated for deliverable
--                        'N' if procurement is not initiated
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
-- p_dlv_element_id                IN               NUMBER       Yes           Deliverale Element ID
-- p_dlv_version_id                IN               NUMBER       Yes           Deliverable Version Id


FUNCTION IS_PROCUREMENT_INITIATED
     (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
          ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR proc_flag_dlv IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE obj.object_id_from2 = p_dlv_element_id
                        AND obj.object_type_to = 'PA_ACTIONS'
                        AND obj.object_type_from = 'PA_DELIVERABLES'
                        AND obj.object_id_to2 = ver.proj_element_id
                        AND obj.relationship_type = 'A'
                        AND obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
                        AND nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(ver.element_version_id),'N') = 'Y'
                  ) ;
l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;
BEGIN
     OPEN proc_flag_dlv;
     FETCH proc_flag_dlv into l_dummy ;
     IF proc_flag_dlv%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE proc_flag_dlv;
return l_return_status;
END IS_PROCUREMENT_INITIATED ;

-- SubProgram           : IS_BILLING_EVENT_PROCESSED ( 3555460 )
-- Type                 : UTIL FUNCTION
-- Purpose              : This function will 'Y' if billing event  is processed for deliverable
--                        'N' if billing event is not processed
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
-- p_dlv_element_id                IN               NUMBER       Yes           Deliverale Element ID
-- p_dlv_version_id                IN               NUMBER       Yes           Deliverable Version Id


FUNCTION IS_BILLING_EVENT_PROCESSED
     (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
          ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2
IS
     CURSOR bill_flag_dlv IS
     SELECT 'Y'
       FROM dual
     WHERE EXISTS ( SELECT 'Y'
                      FROM  pa_object_relationships obj
                           ,pa_proj_element_versions ver
                      WHERE obj.object_id_from2 = p_dlv_element_id
                        AND obj.object_type_to = 'PA_ACTIONS'
                        AND obj.object_type_from = 'PA_DELIVERABLES'
                        AND obj.object_id_to2 = ver.proj_element_id
                        AND obj.relationship_type = 'A'
                        AND obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
                        AND nvl(PA_BILLING_WRKBNCH_EVENTS.CHECK_DELV_EVENT_PROCESSED(ver.project_id,p_dlv_version_id,ver.element_version_id),'N') = 'Y'
                  ) ;
l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;
BEGIN
     OPEN bill_flag_dlv;
     FETCH bill_flag_dlv into l_dummy ;
     IF bill_flag_dlv%found THEN
       l_return_status:='Y';
     ELSE
       l_return_status:='N';
     END IF;
     CLOSE bill_flag_dlv;
return l_return_status;
END IS_BILLING_EVENT_PROCESSED ;


-- Procedure            : GET_BILLING_DETAILS ( 3622126 )
-- Type                 : UTILITY
-- Purpose              : To return billing action description and completion date
-- Note                 : Retrieve action description and completion date
--                      :
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_action_version_id         NUMBER      Y            Delivearble Action Version Id
-- x_bill_completion_date      DATE                     Billing Event Date
-- x_bill_description          VARCHAR2                 Billing Action Description

PROCEDURE GET_BILLING_DETAILS
(
    p_action_version_id     IN  PA_PROJ_ELEM_VER_SCHEDULE.ELEMENT_VERSION_ID%TYPE
   ,x_bill_completion_date  OUT NOCOPY PA_PROJ_ELEM_VER_SCHEDULE.ACTUAL_FINISH_DATE%TYPE --File.Sql.39 bug 4440895
   ,x_bill_description      OUT NOCOPY PA_PROJ_ELEMENTS.DESCRIPTION%TYPE --File.Sql.39 bug 4440895
   ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

  CURSOR bill_details IS
  SELECT
            PPE.DESCRIPTION
           ,PES.ACTUAL_FINISH_DATE
  FROM
           PA_PROJ_ELEMENTS PPE,
           PA_PROJ_ELEM_VER_SCHEDULE PES
  WHERE
           PES.ELEMENT_VERSION_ID = p_action_version_id
       AND PES.PROJ_ELEMENT_ID    = PPE.PROJ_ELEMENT_ID
       AND PPE.OBJECT_TYPE        = 'PA_ACTIONS'
       AND PPE.FUNCTION_CODE      = 'BILLING'
       AND PPE.PROJECT_ID         = PES.PROJECT_ID ;


l_debug_mode         VARCHAR2(1) ;

BEGIN

x_msg_count := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

IF l_debug_mode = 'Y' THEN
     PA_DEBUG.set_curr_function( p_function   => 'GET_BILLING_DETAILS'
                                ,p_debug_mode => l_debug_mode );
     pa_debug.g_err_stage:= 'Inside GET_BILLING_DETAILS ';
     pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

OPEN bill_details;
FETCH bill_details into x_bill_description, x_bill_completion_date ;
CLOSE bill_details;

IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:= 'Exiting GET_BILLING_DETAILS' ;
      pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
      pa_debug.reset_curr_function;
END IF;

EXCEPTION
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLE_UTILS'
                     ,p_procedure_name  => 'GET_BILLING_DETAILS');

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('GET_BILLING_DETAILS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END GET_BILLING_DETAILS;


-- SubProgram           : GET_TASK_INFO ( 3651340 )
-- Type                 : UTIL FUNCTION
-- Purpose              : This function returns task version id if p_task_or_struct is 'T'
--                        parent structure version id if p_task_or_struct is 'S'
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
-- p_project_id                    IN               NUMBER       Yes           Project Id
-- p_task_id                       IN               NUMBER       Yes           proj element id of task
-- p_task_or_struct                IN               VARCHAR2     Yes           Valid Values are ( 'T' - for task version id, 'S' -
--                                                                             for parent structure version id

FUNCTION GET_TASK_INFO
(
     p_project_id           IN NUMBER
    ,p_task_id              IN NUMBER
    ,p_task_or_struct       IN VARCHAR2
)  RETURN NUMBER
IS

cursor c_task_exists(l_struct_ver_id IN NUMBER) IS
    SELECT
           PEV.ELEMENT_VERSION_ID
    FROM
           PA_PROJ_ELEMENT_VERSIONS PEV
    WHERE
           PEV.PARENT_STRUCTURE_VERSION_ID = l_struct_ver_id
       AND PEV.PROJ_ELEMENT_ID = p_task_id
       AND PEV.PROJECT_ID = p_project_id;

-- 3651340 added desc to order by clause in cursor

CURSOR c_task_in_wp_version IS
     SELECT  PPEVS.ELEMENT_VERSION_ID STRUCT_VER_ID
            ,PEV.ELEMENT_VERSION_ID TASK_VER_ID
        FROM
             PA_PROJ_ELEM_VER_STRUCTURE PPEVS
            ,PA_PROJ_ELEMENT_VERSIONS PEV
       WHERE PEV.PROJECT_ID = p_project_id
         AND PEV.PARENT_STRUCTURE_VERSION_ID = PPEVS.ELEMENT_VERSION_ID
         AND PEV.PROJ_ELEMENT_ID = p_task_id
         AND PEV.PROJECT_ID = PPEVS.PROJECT_ID
         AND ROWNUM < 2
         ORDER BY PPEVS.LAST_UPDATE_DATE DESC;

l_latest_pub_wp_struct_id           NUMBER := NULL;
l_current_working_wp_struct_id      NUMBER := NULL;
l_task_ver_id                       NUMBER := NULL;
l_wp_structure_ver_id               NUMBER := NULL;

BEGIN

    -- retrieve published wp structure version id
    -- if task is in in latest published wp verion, return task version id and parent structure version id

    l_latest_pub_wp_struct_id := PA_PROJ_ELEMENTS_UTILS.latest_published_ver_id(p_project_id);

    IF l_latest_pub_wp_struct_id IS NOT NULL THEN

        OPEN c_task_exists(l_latest_pub_wp_struct_id);
        FETCH c_task_exists into l_task_ver_id;
        CLOSE c_task_exists;

        l_wp_structure_ver_id := l_latest_pub_wp_struct_id;

    END IF;

    -- if task is not in the latest published version, retrieve current working structure version id
    -- if task is in the current working version, return task version id and parent structure version id

    IF l_task_ver_id IS NULL THEN

        l_current_working_wp_struct_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(p_project_id);

        IF l_current_working_wp_struct_id IS NOT NULL THEN

            OPEN c_task_exists(l_current_working_wp_struct_id);
            FETCH c_task_exists into l_task_ver_id ;
            CLOSE c_task_exists;
            l_wp_structure_ver_id := l_current_working_wp_struct_id;
        END IF;

    END IF;

    -- if task is not in current working versioin, retrieve the last updated structure version
    -- for which task is associated to structure

    IF l_task_ver_id IS NULL THEN

        OPEN c_task_in_wp_version;
        FETCH c_task_in_wp_version into l_wp_structure_ver_id, l_task_ver_id;
        CLOSE c_task_in_wp_version;

    END IF;

    -- if p_task_or_struct is 'T' then return task version id
    -- if p_task_or_struct is 'S' then return parent structure version id

    IF p_task_or_struct = 'T' THEN
        return l_task_ver_id;
    ELSIF p_task_or_struct = 'S' THEN
        return l_wp_structure_ver_id;
    END IF;

END GET_TASK_INFO;

-- added for bug# 3911050
-- SubProgram           : GET_SHIP_PROC_ACTN_DETAIL ( 3911050 )
-- Type                 : UTIL FUNCTION
-- Purpose              : This function returns shipping and procurement action details ( name, id, due date )
-- Note                 : OKE is calling this procedure while create dlvr to default dlvr type actions to dlvr
-- Assumptions          : None
-- Parameter                      IN/OUT            Type       Required         Description and Purpose
-- ---------------------------  ------------    -----------    ---------       ---------------------------
--   p_dlvr_id                      IN          NUMBER          Yes             Dlvr Ver Id
--   x_ship_id                      OUT         NUMBER                          Shipping Action Ver Id
--   x_ship_name                    OUT         VARCHAR2                        Shipping Action Name
--   x_ship_due_date                OUT         Date                            Shipping Due Date
--   x_proc_id                      OUT         NUMBER                          Procurement Action Ver Id
--   x_proc_name                    OUT         VARCHAR2                        Procurement Action Name
--   x_proc_due_date                OUT         Date                            Procurement Due Date
--

PROCEDURE GET_SHIP_PROC_ACTN_DETAIL
    (
         p_dlvr_id                      IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_ship_id                      OUT     NOCOPY PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE --File.Sql.39 bug 4440895
        ,x_ship_name                    OUT     NOCOPY PA_PROJ_ELEMENTS.NAME%TYPE --File.Sql.39 bug 4440895
        ,x_ship_due_date                OUT     NOCOPY PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE --File.Sql.39 bug 4440895
        ,x_proc_id                      OUT     NOCOPY PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE --File.Sql.39 bug 4440895
        ,x_proc_name                    OUT     NOCOPY PA_PROJ_ELEMENTS.NAME%TYPE --File.Sql.39 bug 4440895
        ,x_proc_due_date                OUT     NOCOPY PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE --File.Sql.39 bug 4440895
    )
IS

CURSOR l_ship_info_csr
IS
    select
           obj.object_id_to1
          ,ppe.name
          ,ppevs.scheduled_finish_date
    from
           pa_object_relationships obj
          ,pa_proj_elements ppe
          ,pa_proj_elem_ver_schedule ppevs
          ,pa_proj_element_versions pev
    where
          pev.element_version_id   = p_dlvr_id
      and obj.object_id_from2      = pev.proj_element_id
      and pev.object_type          = 'PA_DELIVERABLES'
      and obj.object_type_from     = 'PA_DELIVERABLES'
      and obj.object_type_to       = 'PA_ACTIONS'
      and obj.relationship_type    = 'A'
      and obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
      and ppe.proj_element_id      = obj.object_id_to2
      and ppe.proj_element_id      = ppevs.proj_element_id
      and ppe.project_id           = ppevs.project_id
      and ppe.function_code        = 'SHIPPING';

CURSOR l_proc_info_csr
IS
    select
           obj.object_id_to1
          ,ppe.name
          ,ppevs.scheduled_finish_date
    from
           pa_object_relationships obj
          ,pa_proj_elements ppe
          ,pa_proj_elem_ver_schedule ppevs
          ,pa_proj_element_versions pev
    where
          pev.element_version_id   = p_dlvr_id
      and obj.object_id_from2      = pev.proj_element_id
      and pev.object_type          = 'PA_DELIVERABLES'
      and obj.object_type_from     = 'PA_DELIVERABLES'
      and obj.object_type_to       = 'PA_ACTIONS'
      and obj.relationship_type    = 'A'
      and obj.relationship_subtype = 'DELIVERABLE_TO_ACTION'
      and ppe.proj_element_id      = obj.object_id_to2
      and ppe.proj_element_id      = ppevs.proj_element_id
      and ppe.project_id           = ppevs.project_id
      and ppe.function_code        = 'PROCUREMENT';

BEGIN

     OPEN l_ship_info_csr;
     FETCH l_ship_info_csr into x_ship_id, x_ship_name, x_ship_due_date ;
     CLOSE l_ship_info_csr;

     OPEN l_proc_info_csr;
     FETCH l_proc_info_csr into x_proc_id, x_proc_name, x_proc_due_date ;
     CLOSE l_proc_info_csr;

END GET_SHIP_PROC_ACTN_DETAIL;

-- 9071494 - Returns 'Y' if actions is enabled for corresponding deliverable type
FUNCTION IS_ACTIONS_ENABLED
    (
        p_proj_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )   RETURN VARCHAR2
IS
    CURSOR c_is_actions_enabled_dlv IS
    SELECT 'Y'
    FROM pa_proj_elements ppe
        ,pa_task_types ptt
    WHERE ppe.proj_element_id = p_proj_element_id
    AND  ppe.object_type = 'PA_DELIVERABLES'
    AND  ptt.task_type_id = ppe.type_id
    AND  nvl(ptt.enable_dlvr_actions_flag,'N') = 'Y'
    AND  ptt.object_type = 'PA_DLVR_TYPES' ;

l_dummy VARCHAR2(1) := 'N' ;
l_return_status VARCHAR2(1) := 'N' ;

BEGIN
    OPEN c_is_actions_enabled_dlv;
    FETCH c_is_actions_enabled_dlv into l_dummy ;
    IF c_is_actions_enabled_dlv%found THEN
      l_return_status:='Y';
    ELSE
      l_return_status:='N';
    END IF;
    CLOSE c_is_actions_enabled_dlv;

RETURN l_return_status;
END IS_ACTIONS_ENABLED;


END PA_DELIVERABLE_UTILS;

/
