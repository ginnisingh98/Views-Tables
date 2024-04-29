--------------------------------------------------------
--  DDL for Package Body PA_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTIONS_PVT" as
/* $Header: PAACTNVB.pls 120.2.12010000.3 2010/02/24 05:42:57 dbudhwar ship $ */

g_module_name  VARCHAR2(100) := 'pa.plsql.pa_actions_pvt';

Invalid_Arg_Exc_Dlv EXCEPTION ;
g_dlvr_types CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PA_DLVR_TYPES';
g_actions    CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PA_ACTIONS';
g_dlvr_type_to_action  CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'DLVR_TYPE_TO_ACTION';
g_dlvr_to_action  CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'DELIVERABLE_TO_ACTION';
g_billing        CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'BILLING';
g_shipping       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'SHIPPING';
g_procurement    CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PROCUREMENT';

-- SubProgram           : CREATE_DLV_ACTIONS_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Private API to create to Deliverable Actions
-- Note                 : Its a BULK API
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_name_tbl                      IN          PLSQL Table       N        Action Name
-- p_manager_person_id_tbl         IN          PLSQL Table       N        Manager Id
-- p_function_code_tbl             IN          PLSQL Table       N        Action Function
-- p_due_date_tbl                  IN          PLSQL Table       N        Due Date
-- p_completed_flag_tbl            IN          PLSQL Table       N        Completed Flag
-- p_completion_date_tbl           IN          PLSQL Table       N        Completed Date
-- p_description_tbl               IN          PLSQL Table       N        Description
-- p_attribute_category_tbl        IN          PLSQL Table       N        DFF Field
-- p_attribute1_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute2_tbl                IN          PLSQL Table       N        DFF Field
-- p_attribute3_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute4_tbl                IN          PLSQL Table       N        DFF Field
-- p_attribute5_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute6_tbl                IN          PLSQL Table       N        DFF Field
-- p_attribute7_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute8_tbl                IN          PLSQL Table       N        DFF Field
-- p_attribute9_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute10_tbl               IN          PLSQL Table       N        DFF Field
-- p_attribute11_tbl               IN          PLSQL Table       N        DFF Filed
-- p_attribute12_tbl               IN          PLSQL Table       N        DFF Field
-- p_attribute13_tbl               IN          PLSQL Table       N        DFF Filed
-- p_attribute14_tbl               IN          PLSQL Table       N        DFF Field
-- p_attribute15_tbl               IN          PLSQL Table       N        DFF Filed
-- p_element_version_id_tbl        IN          PLSQL Table       N        Action VErsion Id
-- p_proj_element_id_tbl           IN          PLSQL Table       N        Action Element Id
-- p_record_version_number_tbl     IN          PLSQL Table       N        Record Version NUmber
-- p_project_id                    IN          NUMBER            N        Project Id
-- p_object_id                     IN          NUMBER            Y        Parent Id
-- p_object_version_id             IN          NUMBER            N        Parent Version ID
-- p_object_type                   IN          VARCHAR2          Y        Parent Type
-- p_pm_source_code                IN          NUMBER            N        PM Source Code
-- p_pm_source_reference           IN          VARCHAR2          N        PM Source Reference
-- p_carrying_out_organization_id  IN          VARCHAR2          N        Carrying Out Org ID
-- x_return_status                 OUT         VARCHAR2          N        Mandatory Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Mandatory Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Mandatory Out Parameter

PROCEDURE CREATE_DLV_ACTIONS_IN_BULK
     (p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_name_tbl                  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_manager_person_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_function_code_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_due_date_tbl              IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_completed_flag_tbl        IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
     ,p_completion_date_tbl       IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_description_tbl           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
     ,p_attribute_category_tbl    IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_attribute1_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute2_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute3_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute4_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute5_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute6_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute7_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute8_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute9_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute10_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute11_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute12_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute13_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute14_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute15_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_version_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl       IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE  := null
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE
     ,p_object_version_id         IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_pm_source_code            IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_pm_source_reference       IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_reference_tbl   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE() -- added 3435905
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE := null
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_proj_element_id_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
     l_element_version_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
     l_rel_subtype                PA_OBJECT_RELATIONSHIPS.RELATIONSHIP_SUBTYPE%TYPE ;
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;
     i NUMBER;
     l_pm_source_reference_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(); -- added for 3574730
BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CREATE_DLV_ACTIONS_IN_BULK'
                                     ,p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside CREATE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF p_debug_mode = 'Y' THEN
          pa_debug.write(g_module_name,'Printing Input Parameters ',3) ;
          pa_debug.write(g_module_name,'#'||p_project_id||'#'||p_object_id||'#'||p_object_version_id||'#'||p_object_type||'#'||
                     p_pm_source_code||'#'||p_carrying_out_organization_id,3) ;

          IF (p_calling_module = 'AMG') THEN
             i := p_name_tbl.first();
         WHILE i is not null loop
            pa_debug.write(g_module_name,'#1'||p_name_tbl(i)||'#'||p_manager_person_id_tbl(i)||'#'||p_function_code_tbl(i)||'#'||p_due_date_tbl(i)||'#'||p_completed_flag_tbl(i)||'#'||p_pm_source_reference_tbl(i),3) ;
                pa_debug.write(g_module_name,'#2'||p_completion_date_tbl(i)||'#'||p_description_tbl(i)||'#'||p_element_version_id_tbl(i)||'#'||p_proj_element_id_tbl(i)||'#'||p_record_version_number_tbl(i) ,3) ;

            i := p_name_tbl.next(i);
         end loop;
          END IF; -- p_calling_module = 'AMG'
     END IF;

     IF nvl(p_name_tbl.LAST,0)> 0 THEN

          -- populate the element table
          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Bulk inserting into PA_PROJ_ELEMENTS';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          END IF;

          -- 3574730 : not able to create deliverable, default actions copy is causing the problem
          -- the below code must be removed once permanent fix is done
          -- here, if calling module is self_service extend the p_pm_source_reference_tbl
          -- this is required because, when ever this api is called in self_service mode
          -- decode statement in the insert will try to evaluate p_pm_source_reference_tbl(i) value
          -- so temparorily fix the issue, we are extending the table

          -- when ever permanant fix is done, remove local varaible, the below code and in insert from local to input parameter

          IF p_calling_module = 'SELF_SERVICE' THEN
              FOR i IN p_name_tbl.FIRST..p_name_tbl.LAST
              LOOP
                l_pm_source_reference_tbl.extend;
                l_pm_source_reference_tbl(i):= null;           /* Bug # 3590235 */
              END LOOP;
          ELSE
              FOR i IN p_name_tbl.FIRST..p_name_tbl.LAST
              LOOP
                l_pm_source_reference_tbl.extend;              /* Bug # 3590235 */
                l_pm_source_reference_tbl(i) := p_pm_source_reference_tbl(i) ;
              END LOOP;
          END IF;

          -- 3574730 end

          -- For action level record associated to Deliverable Type
          -- Project id is populated as null .

          FORALL i in p_name_tbl.FIRST..p_name_tbl.LAST
               INSERT INTO PA_PROJ_ELEMENTS(
                     proj_element_id
                    ,project_id
                    ,object_type
                    ,name
                    ,element_number
                    ,creation_date
                    ,created_by
                    ,last_update_date
                    ,last_updated_by
                    ,description
                    ,status_code
                    ,function_code
                    ,pm_source_code
                    ,pm_source_reference
                    ,manager_person_id
                    ,carrying_out_organization_id
                    ,record_version_number
                    ,last_update_login
                    ,program_application_id
                    ,attribute_category
                    ,attribute1
                    ,attribute2
                    ,attribute3
                    ,attribute4
                    ,attribute5
                    ,attribute6
                    ,attribute7
                    ,attribute8
                    ,attribute9
                    ,attribute10
                    ,attribute11
                    ,attribute12
                    ,attribute13
                    ,attribute14
                    ,attribute15
                    ,source_object_id
                    ,source_object_type
                    )
                VALUES
                    (
                     nvl(p_proj_element_id_tbl(i),pa_tasks_s.nextval )
                    ,nvl(p_project_id,-99)
                    ,g_actions
                    ,p_name_tbl(i)
                    ,pa_tasks_s.currval
                    ,SYSDATE
                    ,fnd_global.user_id
                    ,SYSDATE
                    ,fnd_global.user_id
                    ,p_description_tbl(i)
                    ,decode(p_completed_flag_tbl(i),'Y','DLVR_COMPLETED','DLVR_IN_PROGRESS')
                    ,p_function_code_tbl(i)
                    ,p_pm_source_code
                    ,decode(p_calling_module, 'SELF_SERVICE', p_pm_source_reference , l_pm_source_reference_tbl(i))  -- added decode 3435905
                    ,p_manager_person_id_tbl(i)
                    ,p_carrying_out_organization_id
                    ,1
                    ,fnd_global.login_id
                    ,fnd_global.prog_appl_id
                    ,p_attribute_category_tbl(i)
                    ,p_attribute1_tbl(i)
                    ,p_attribute2_tbl(i)
                    ,p_attribute3_tbl(i)
                    ,p_attribute4_tbl(i)
                    ,p_attribute5_tbl(i)
                    ,p_attribute6_tbl(i)
                    ,p_attribute7_tbl(i)
                    ,p_attribute8_tbl(i)
                    ,p_attribute9_tbl(i)
                    ,p_attribute10_tbl(i)
                    ,p_attribute11_tbl(i)
                    ,p_attribute12_tbl(i)
                    ,p_attribute13_tbl(i)
                    ,p_attribute14_tbl(i)
                    ,p_attribute15_tbl(i)
                    ,nvl(p_project_id,-99)
                    ,'PA_PROJECTS'
                    )
                RETURNING proj_element_id
                BULK COLLECT INTO l_proj_element_id_tbl ;


          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Bulk inserting into PA_PROJ_ELEMENT_VERSIONS';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          END IF;


          -- populate the element version table

          -- From copy action API p_element_version_id_tbl will be passed
          -- as null.Hence using nvl

          FORALL i in l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST
               INSERT INTO PA_PROJ_ELEMENT_VERSIONS(
                     element_version_id
                    ,proj_element_id
                    ,object_type
                    ,project_id
                    ,creation_date
                    ,created_by
                    ,last_update_date
                    ,last_updated_by
                    ,record_version_number
                    ,last_update_login
                    ,source_object_id
                    ,source_object_type
                    )
                 VALUES
                    (
                     nvl(p_element_version_id_tbl(i),pa_proj_element_versions_s.nextval)
                    ,l_proj_element_id_tbl(i)
                    ,g_actions
                    ,nvl(p_project_id,-99)
                    ,SYSDATE
                    ,fnd_global.user_id
                    ,SYSDATE
                    ,fnd_global.user_id
                    ,1
                    ,fnd_global.login_id
                    ,nvl(p_project_id,-99)
                    ,'PA_PROJECTS'
                    )
                RETURNING element_version_id
                BULK COLLECT INTO l_element_version_id_tbl ;


          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Bulk inserting into PA_PROJ_ELEM_VER_SCHEDULE';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          END IF;

          -- populate the element version table
          FORALL i in l_element_version_id_tbl.FIRST..l_element_version_id_tbl.LAST
               INSERT INTO PA_PROJ_ELEM_VER_SCHEDULE(
                     pev_schedule_id
                    ,element_version_id
                    ,project_id
                    ,proj_element_id
                    ,creation_date
                    ,created_by
                    ,last_update_date
                    ,last_updated_by
                    ,last_update_login
                    ,scheduled_finish_date
                    ,actual_finish_date
                    ,record_version_number
                    ,source_object_id
                    ,source_object_type
                    )
                 VALUES
                    (
                     pa_proj_elem_ver_schedule_s.nextval
                    ,l_element_version_id_tbl(i)
                    ,nvl(p_project_id,-99)
                    ,l_proj_element_id_tbl(i)
                    ,SYSDATE
                    ,fnd_global.user_id
                    ,SYSDATE
                    ,fnd_global.user_id
                    ,fnd_global.login_id
                    ,p_due_date_tbl(i)
                    ,p_completion_date_tbl(i)
                    ,1
                    ,nvl(p_project_id,-99)
                    ,'PA_PROJECTS'
                    ) ;

          IF p_object_type = g_dlvr_types THEN
               l_rel_subtype := g_dlvr_type_to_action ;
          ELSE
               l_rel_subtype := g_dlvr_to_action      ;
          END IF;

          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Bulk inserting into PA_OBJECT_RELATIONSHIPS';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          END IF;

          -- populate the object relationships table
          FORALL i in l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST
               INSERT INTO PA_OBJECT_RELATIONSHIPS(
                     object_relationship_id
                    ,object_type_from
                    ,object_id_from1
                    ,object_type_to
                    ,object_id_to1
                    ,relationship_type
                    ,created_by
                    ,creation_date
                    ,last_updated_by
                    ,last_update_date
                    ,object_id_from2
                    ,object_id_to2
                    ,relationship_subtype
                    ,record_version_number
                    ,last_update_login
                    )
                 VALUES
                    (
                     pa_object_relationships_s.nextval
                    ,p_object_type
                    ,p_object_version_id
                    ,g_actions
                    ,l_element_version_id_tbl(i)
                    ,'A'
                    ,fnd_global.user_id
                    ,SYSDATE
                    ,fnd_global.user_id
                    ,SYSDATE
                    ,p_object_id
                    ,l_proj_element_id_tbl(i)
                    ,l_rel_subtype
                    ,1
                    ,fnd_global.login_id
                    ) ;
     END IF ;

          IF p_debug_mode = 'Y' THEN           --Added for bug 4945876
          pa_debug.reset_curr_function;
          END IF;

EXCEPTION
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PVT'
                     ,p_procedure_name  => 'CREATE_DLV_ACTIONS_IN_BULK');
     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Exiting CREATE_DLV_ACTIONS_IN_BULK' ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END CREATE_DLV_ACTIONS_IN_BULK ;

-- SubProgram           : UPDATE_DLV_ACTIONS_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Private API to Update To Deliverable Actions
-- Note                 : Its a BULK API
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_name_tbl                      IN          PLSQL Table       N        Action Name
-- p_manager_person_id_tbl         IN          PLSQL Table       N        Manager Id
-- p_function_code_tbl             IN          PLSQL Table       N        Action Function
-- p_due_date_tbl                  IN          PLSQL Table       N        Due Date
-- p_completed_flag_tbl            IN          PLSQL Table       N        Completed Flag
-- p_completion_date_tbl           IN          PLSQL Table       N        Completed Date
-- p_description_tbl               IN          PLSQL Table       N        Description
-- p_attribute_category_tbl        IN          PLSQL Table       N        DFF Field
-- p_attribute1_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute2_tbl                IN          PLSQL Table       N        DFF Field
-- p_attribute3_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute4_tbl                IN          PLSQL Table       N        DFF Field
-- p_attribute5_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute6_tbl                IN          PLSQL Table       N        DFF Field
-- p_attribute7_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute8_tbl                IN          PLSQL Table       N        DFF Field
-- p_attribute9_tbl                IN          PLSQL Table       N        DFF Filed
-- p_attribute10_tbl               IN          PLSQL Table       N        DFF Field
-- p_attribute11_tbl               IN          PLSQL Table       N        DFF Filed
-- p_attribute12_tbl               IN          PLSQL Table       N        DFF Field
-- p_attribute13_tbl               IN          PLSQL Table       N        DFF Filed
-- p_attribute14_tbl               IN          PLSQL Table       N        DFF Field
-- p_attribute15_tbl               IN          PLSQL Table       N        DFF Filed
-- p_element_version_id_tbl        IN          PLSQL Table       N        Action VErsion Id
-- p_proj_element_id_tbl           IN          PLSQL Table       N        Action Element Id
-- p_record_version_number_tbl     IN          PLSQL Table       N        Record Version NUmber
-- p_project_id                    IN          NUMBER            N        Project Id
-- p_object_id                     IN          NUMBER            Y        Parent Id
-- p_object_version_id             IN          NUMBER            N        Parent Version ID
-- p_object_type                   IN          VARCHAR2          Y        Parent Type
-- p_pm_source_code                IN          NUMBER            N        PM Source Code
-- p_pm_source_reference           IN          VARCHAR2          N        PM Source Reference
-- p_carrying_out_organization_id  IN          VARCHAR2          N        Carrying Out Org ID
-- x_return_status                 OUT         VARCHAR2          N        Mandatory Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Mandatory Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Mandatory Out Parameter

PROCEDURE UPDATE_DLV_ACTIONS_IN_BULK
     (p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_name_tbl                  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_manager_person_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_function_code_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_due_date_tbl              IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_completed_flag_tbl        IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
     ,p_completion_date_tbl       IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_description_tbl           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
     ,p_attribute_category_tbl    IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_attribute1_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute2_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute3_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute4_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute5_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute6_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute7_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute8_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute9_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute10_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute11_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute12_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute13_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute14_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute15_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_version_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl       IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE := null
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null -- 3578694 added default value
     ,p_object_version_id         IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_pm_source_code            IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_pm_source_reference       IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE := null
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;
BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CR_DLV_ACTIONS_IN_BULK'
                                     ,p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside UPDATE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     -- Update attributes related to proj element table.
     -- Following attributes related to PA_PROJ_ELEMENTS
     -- are updateable from SS page
     --   1. Action Name
     --   2. Owner
     --   3. Function Code
     --   4. Description
     --   5. Completed Flag , mapped to status column
     --   6. DFF Fields

     FORALL i in p_name_tbl.FIRST..p_name_tbl.LAST
          UPDATE pa_proj_elements
             SET name = p_name_tbl(i)
                ,manager_person_id = p_manager_person_id_tbl(i)
                ,description = p_description_tbl(i)
                ,status_code = decode(p_completed_flag_tbl(i),'Y','DLVR_COMPLETED','DLVR_IN_PROGRESS')
                ,function_code = p_function_code_tbl(i)
                ,attribute_category = p_attribute_category_tbl(i)
                ,attribute1         = p_attribute1_tbl(i)
                ,attribute2         = p_attribute2_tbl(i)
                ,attribute3         = p_attribute3_tbl(i)
                ,attribute4         = p_attribute4_tbl(i)
                ,attribute5         = p_attribute5_tbl(i)
                ,attribute6         = p_attribute6_tbl(i)
                ,attribute7         = p_attribute7_tbl(i)
                ,attribute8         = p_attribute8_tbl(i)
                ,attribute9         = p_attribute9_tbl(i)
                ,attribute10        = p_attribute10_tbl(i)
                ,attribute11        = p_attribute11_tbl(i)
                ,attribute12        = p_attribute12_tbl(i)
                ,attribute13        = p_attribute13_tbl(i)
                ,attribute14        = p_attribute14_tbl(i)
                ,attribute15        = p_attribute15_tbl(i)
                ,record_version_number = nvl(record_version_number,0) + 1
                ,last_update_date   = SYSDATE
                ,last_updated_by    = fnd_global.user_id
                ,last_update_login  = fnd_global.login_id
          WHERE proj_element_id = p_proj_element_id_tbl(i) ;


     -- Update attributes related to proj elem ver schedule table.
     -- Following attributes related to PA_PROJ_ELEM_VER_SVHEDULE
     -- are updateable from SS page
     --   1. Due Date (Shedule Finish Date)
     --   2. Completion Date (Actual Finish Date)

     FORALL i in p_element_version_id_tbl.FIRST..p_element_version_id_tbl.LAST
          UPDATE PA_PROJ_ELEM_VER_SCHEDULE
             SET scheduled_finish_date  = p_due_date_tbl(i)
                ,actual_finish_date = p_completion_date_tbl(i)
                ,record_version_number = nvl(record_version_number,0) + 1
                ,last_update_date   = SYSDATE
                ,last_updated_by    = fnd_global.user_id
                ,last_update_login  = fnd_global.login_id
          WHERE  element_version_id = p_element_version_id_tbl(i) ;

      -- 3941159 , added code to loop through actions and update event
      -- date for billing actions

      FOR i IN p_element_version_id_tbl.FIRST..p_element_version_id_tbl.LAST
      LOOP

        -- removed completion date not null check because, for billing action, completion check box can be
        -- unchecked if billing event is not processed and changed completion date ( null value ) should be reflected in
        -- pa_events table

        IF p_function_code_tbl(i) = 'BILLING' THEN
         PA_Billing_Wrkbnch_Events.Upd_Event_Comp_Date(
                        P_Deliverable_Id  =>    p_object_version_id
                       ,P_Action_Id       =>    p_element_version_id_tbl(i)
                       ,P_Event_Date      =>    p_completion_date_tbl(i));
        END IF;
      END LOOP;

    -- 3941159 end

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Exiting UPDATE_DLV_ACTIONS_IN_BULK' ;
          pa_debug.write(g_module_name, pa_debug.g_err_stage, 5);
          pa_debug.reset_curr_function;
     END IF;

EXCEPTION
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PVT'
                     ,p_procedure_name  => 'UPDATE_DLV_ACTIONS_IN_BULK');
     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('UPDATE_DLV_ACTIONS_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END UPDATE_DLV_ACTIONS_IN_BULK ;

-- SubProgram           : DELETE_DLV_ACTIONS_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Private API to Delete To Deliverable Actions.This API will be called
--                        when deliverable type is deleted. In such cases only object type and
--                        object id will be passed .
-- Note                 : Its a BULK API
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_element_version_id_tbl        IN          PLSQL Table       N        Action VErsion Id
-- p_proj_element_id_tbl           IN          PLSQL Table       N        Action Element Id
-- p_record_version_number_tbl     IN          PLSQL Table       N        Record Version NUmber
-- p_object_id                     IN          NUMBER            Y        Parent Id
-- p_object_version_id             IN          NUMBER            N        Parent Version ID
-- p_object_type                   IN          VARCHAR2          Y        Parent Type
-- x_return_status                 OUT         VARCHAR2          N        Mandatory Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Mandatory Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Mandatory Out Parameter

PROCEDURE DELETE_DLV_ACTIONS_IN_BULK
     (p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE
     ,p_element_version_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl       IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS

     CURSOR get_element_id IS
     SELECT object_id_to2,
            object_relationship_id
       FROM pa_object_relationships
      WHERE object_id_from2 = p_object_id
        AND object_type_from = p_object_type
        AND object_type_to = g_actions
        AND relationship_type = 'A';

l_proj_element_id_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
l_obj_relationship_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;

-- Bug 3614361
l_elem_version_id_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_ACTIONS_IN_BULK'
                                     ,p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF  nvl(p_proj_element_id_tbl.LAST,0)=0 THEN

          OPEN  get_element_id ;
          FETCH get_element_id BULK COLLECT INTO l_proj_element_id_tbl,l_obj_relationship_id_tbl ;
          CLOSE  get_element_id ;

          IF  nvl(l_proj_element_id_tbl.LAST,0) > 0 THEN
                    -- Delete from PA_PROJ_ELEMENTS Table
                    FORALL i in l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST
                         DELETE FROM pa_proj_elements
                               WHERE proj_element_id = l_proj_element_id_tbl(i) ;

                    -- Delete from PA_PROJ_ELEMENT_VERSIONS Table
            -- Bug 3614361 Including Returning Clause
                    FORALL i in l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST
                         DELETE FROM pa_proj_element_versions
                               WHERE proj_element_id = l_proj_element_id_tbl(i)
                   RETURNING element_version_id
                        BULK COLLECT INTO l_elem_version_id_tbl;

                    -- Delete from PA_PROJ_ELEM_VER_SCHEDULE Table

                    /* Following Code has been commented for Performance Fix Bug # 3614361
                       Basing logic on Element Version Id will improve performance
            in the below delete statement
                    FORALL i in l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST
                         DELETE FROM pa_proj_elem_ver_schedule
                               WHERE proj_element_id = l_proj_element_id_tbl(i) ;
            */

           -- Bug 3614361 Start
           FORALL i in l_elem_version_id_tbl.FIRST..l_elem_version_id_tbl.LAST
             DELETE FROM pa_proj_elem_ver_schedule
                               WHERE element_version_id = l_elem_version_id_tbl(i) ;
           -- 3614361 End

                    -- Delete from PA_OBJECT_RELATIONSHIPS table
                    FORALL i in l_obj_relationship_id_tbl.FIRST..l_obj_relationship_id_tbl.LAST
                         DELETE FROM PA_OBJECT_RELATIONSHIPS
                               WHERE object_relationship_id = l_obj_relationship_id_tbl(i) ;

          END IF ;
     END IF ;

     -- Delete the entries from PA_OBJECT_RELATIONSHIPS table
     IF nvl(p_proj_element_id_tbl.LAST,0)>0 THEN

          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Delete entries from PA_OBJECT_RELATIONSHIPS table' ;
               pa_debug.write('DELETE_DLV_ACTIONS_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;

          FORALL i in p_proj_element_id_tbl.FIRST..p_proj_element_id_tbl.LAST
               DELETE FROM PA_OBJECT_RELATIONSHIPS
                     WHERE OBJECT_ID_TO2 = p_proj_element_id_tbl(i)
                       AND OBJECT_ID_FROM2 = p_object_id ;
     END IF ;

     -- Delete the entries from PA_PROJ_ELEM_VER_SCHEDULE table
     IF nvl(p_element_version_id_tbl.LAST,0)>0 THEN

          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Delete entries from PA_PROJ_ELEM_VER_SCHEDULE table' ;
               pa_debug.write('DELETE_DLV_ACTIONS_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;

          FORALL i in p_element_version_id_tbl.FIRST..p_element_version_id_tbl.LAST
               DELETE FROM PA_PROJ_ELEM_VER_SCHEDULE
                     WHERE element_version_id = p_element_version_id_tbl(i) ;

     END IF ;

     -- Delete the entries from PA_ELEMENT_VERSIONS table
     IF nvl(p_element_version_id_tbl.LAST,0)>0 THEN

          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Delete entries from PA_ELEMENT_VERSIONS table' ;
               pa_debug.write('DELETE_DLV_ACTIONS_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;

          FORALL i in p_element_version_id_tbl.FIRST..p_element_version_id_tbl.LAST
               DELETE FROM PA_PROJ_ELEMENT_VERSIONS
                     WHERE element_version_id = p_element_version_id_tbl(i) ;

     END IF ;


     -- Delete the entries from PA_PROJ_ELEMENTS table
     IF nvl(p_proj_element_id_tbl.LAST,0)>0 THEN

          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Delete entries from PA_ELEMENT_VERSIONS table' ;
               pa_debug.write('DELETE_DLV_ACTIONS_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;

          FORALL i in p_proj_element_id_tbl.FIRST..p_proj_element_id_tbl.LAST
               DELETE FROM PA_PROJ_ELEMENTS
                     WHERE proj_element_id = p_proj_element_id_tbl(i) ;

     END IF ;

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Exiting UPDATE_DLV_ACTIONS_IN_BULK' ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;

EXCEPTION
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PVT'
                     ,p_procedure_name  => 'DELETE_DLV_ACTIONS_IN_BULK');
     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_ACTIONS_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_ACTIONS_IN_BULK ;

-- SubProgram           : DELETE_DLV_ACTION
-- Type                 : PROCEDURE
-- Purpose              : Private API to Delete Deliverable Actions
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER           N           Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2         N           Standard Parameter
-- p_commit                        IN          VARCHAR2         N           Standard Parameter
-- p_validate_only                 IN          VARCHAR2         N           Standard Parameter
-- p_validation_level              IN          NUMBER           N           Standard Parameter
-- p_calling_module                IN          VARCHAR2         N           Standard Parameter
-- p_debug_mode                    IN          VARCHAR2         N           Standard Parameter
-- p_max_msg_count                 IN          NUMBER           N           Standard Parameter
-- p_action_id                     IN          NUMBER           Y           Action Id .
-- p_action_ver_id                 IN          VARCHAR2         Y           ACtion Ver Id.

PROCEDURE DELETE_DLV_ACTION
     (p_api_version      IN NUMBER   :=1.0
     ,p_init_msg_list    IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit           IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only    IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module   IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode       IN VARCHAR2 :='N'
     ,p_max_msg_count    IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_action_id        IN pa_proj_elements.proj_element_id%TYPE
     ,p_action_ver_id    IN pa_proj_element_versions.element_version_id%TYPE
     ,p_dlv_element_id   IN pa_proj_elements.proj_element_id%TYPE
     ,p_dlv_version_id   IN pa_proj_element_versions.element_version_id%TYPE
     ,p_function_code    IN pa_proj_elements.function_code%TYPE
     ,p_project_id       IN pa_projects_all.project_id%TYPE
     ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_action_del_allowed VARCHAR2(1) := 'Y';
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;
     l_name                       pa_proj_elements.name%TYPE ;
     l_function_code              pa_proj_elements.function_code%TYPE ;

     l_dlv_ship_action_rec   oke_amg_grp.dlv_ship_action_rec_type;
     l_dlv_req_action_rec    oke_amg_grp.dlv_req_action_rec_type;
     l_dlv_ship_action_rec_b   oke_amg_grp.dlv_ship_action_rec_type;
     l_dlv_req_action_rec_b    oke_amg_grp.dlv_req_action_rec_type;

     CURSOR c_action_info (c_action_elt_id IN NUMBER )
     IS
     SELECT name
           ,function_code
       FROM pa_proj_elements
      WHERE proj_element_id = c_action_elt_id
        AND object_type = 'PA_ACTIONS';

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'PA_DELETE_DLV_ACTION'
                                     ,p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_ACTION ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     PA_ACTIONS_PVT.IS_DELETE_ACTION_ALLOWED
          (p_api_version           => p_api_version
          ,p_init_msg_list         => FND_API.G_FALSE
          ,p_commit                => p_commit
          ,p_validate_only         => p_validate_only
          ,p_validation_level      => p_validation_level
          ,p_calling_module        => p_calling_module
          ,p_debug_mode            => p_debug_mode
          ,p_max_msg_count         => p_max_msg_count
          ,p_action_id             => p_action_id
          ,p_action_ver_id         => p_action_ver_id
          ,p_dlv_element_id        => p_dlv_element_id
          ,p_dlv_version_id        => p_dlv_version_id
          ,p_function_code         => p_function_code
          ,p_project_id            => p_project_id
          ,x_action_del_allowed    => l_action_del_allowed
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ) ;

     IF  (l_action_del_allowed = 'N' OR x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     OPEN c_action_info(p_action_id) ;
     FETCH c_action_info INTO l_name,l_function_code ;
     CLOSE c_action_info ;

     IF l_function_code = g_billing THEN

          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Inside DELETE BILLING EVENTS ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          END IF;

          -- Delete the billing event if its a billing function
          PA_BILLING_WRKBNCH_EVENTS.DELETE_DELV_EVENT
                        ( P_Project_Id     => p_project_id
                         ,P_Deliverable_Id => p_dlv_version_id
                         ,P_Action_Id      => p_action_ver_id
                         ,P_Action_Name    => l_name
                         ,X_Return_Status  => x_return_status
                          ) ;
      IF p_debug_mode = 'Y' THEN
             pa_debug.write(g_module_name,'Returned from PA_BILLING_WRKBNCH_EVENTS.DELETE_DELV_EVENT ['||x_return_status||']',3) ;
          END IF;

          IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE Invalid_Arg_Exc_Dlv ;
          END IF ;

     END IF ;

     --Start Bug # 3431156

     -- Delete the shipping or Procurement actions from OKE tables
     IF l_function_code in( g_shipping,g_procurement) THEN
         IF ( p_calling_module   = 'SELF_SERVICE') THEN

--             removed oke's delete_action call, according to new stratergy, PA will not call oke's delete api
--              oke will set the row status to deleted in their AM method, which will be called by PA, and oke
--              will override EO's doDML method to handle delete case

--             OKE_DELIVERABLE_UTILS_PUB.DELETE_ACTION
--                            ( P_Action_ID       => p_action_ver_id
--                             , X_Return_Status  => x_return_status
--                             , X_Msg_Count      => x_msg_count
--                             , X_Msg_Data       => x_msg_data
--                             ) ;

             IF p_debug_mode = 'Y' THEN
                pa_debug.write(g_module_name,'Returned from OKE_DELIVERABLE_UTILS_PUB.DELETE_ACTION ['||x_return_status||']',3) ;
             END IF;

--             IF  X_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
--                 RAISE Invalid_Arg_Exc_Dlv ;
--             END IF ;

         ELSIF (p_calling_module   = 'AMG' and l_function_code = g_procurement) THEN

           l_dlv_req_action_rec.pa_action_id := p_action_ver_id;

           oke_amg_grp.manage_dlv_action
             (  p_api_version          =>    p_api_version
              , p_init_msg_list         =>    FND_API.G_FALSE
              , p_commit                =>    p_commit
              , p_action                =>    'DELETE'
              -- 3732873 earlier l_function_code was passed for p_dlv_action_type
              -- and the value will be 'PROCUREMENT', but OKE expects this value to be 'REQ' for procurement
              -- if the value is not 'WSH' or 'REQ' , oke will throw the error message saying invalid action type
              , p_dlv_action_type       =>    'REQ'
              , p_master_inv_org_id     =>    null
              , p_item_dlv              =>    null
              , p_dlv_ship_action_rec   =>    l_dlv_ship_action_rec_b
              , p_dlv_req_action_rec    =>    l_dlv_req_action_rec
              , x_return_status         =>    x_return_status
              , x_msg_data              =>    x_msg_data
              , x_msg_count             =>    x_msg_count
              );

             IF p_debug_mode = 'Y' THEN
                pa_debug.write(g_module_name,'Returned from oke_amg_grp.manage_dlv_action['||l_function_code||'] ['||x_return_status||']',3) ;
             END IF;

             IF  X_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE Invalid_Arg_Exc_Dlv ;
             END IF ;

         ELSIF (p_calling_module   = 'AMG' and l_function_code = g_shipping) THEN

           l_dlv_ship_action_rec.pa_action_id := p_action_ver_id;

           oke_amg_grp.manage_dlv_action
             (  p_api_version          =>    p_api_version
              , p_init_msg_list         =>    FND_API.G_FALSE
              , p_commit                =>    p_commit
              , p_action                =>    'DELETE'
              -- 3732873 earlier l_function_code was passed for p_dlv_action_type
              -- and the value will be 'SHIPPING', but OKE expects this value to be 'WSH' for shipping
              -- if the value is not 'WSH' or 'REQ' , oke will throw the error message saying invalid action type
              , p_dlv_action_type       =>    'WSH'
              , p_master_inv_org_id     =>    null
              , p_item_dlv              =>    null
              , p_dlv_ship_action_rec   =>    l_dlv_ship_action_rec
              , p_dlv_req_action_rec    =>    l_dlv_req_action_rec_b
              , x_return_status         =>    x_return_status
              , x_msg_data              =>    x_msg_data
              , x_msg_count             =>    x_msg_count
              );

             IF p_debug_mode = 'Y' THEN
                pa_debug.write(g_module_name,'Returned from oke_amg_grp.manage_dlv_action['||l_function_code||'] ['||x_return_status||']',3) ;
             END IF;

             IF  X_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE Invalid_Arg_Exc_Dlv ;
             END IF ;

         END IF; --p_calling_module   = 'AMG'
     END IF ;

     -- End Bug # 3431156

     -- Delete from PA_PROJ_ELEMENTS Table
     DELETE FROM pa_proj_elements
           WHERE proj_element_id = p_action_id ;

     -- Delete from PA_PROJ_ELEMENT_VERSIONS Table
     DELETE FROM pa_proj_element_versions
           WHERE element_version_id = p_action_ver_id ;

     -- Delete from PA_PROJ_ELEM_VER_SCHEDULE Table
     DELETE FROM pa_proj_elem_ver_schedule
           WHERE element_version_id = p_action_ver_id ;

     -- Delete from PA_OBJECT_RELATIONSHIPS table
     DELETE FROM PA_OBJECT_RELATIONSHIPS
           WHERE object_id_to2 = p_action_id
           and   object_id_to1 = p_action_ver_id; -- Added condition for perf bug# 3964701

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Exiting DELETE_DLV_ACTION' ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;
     IF p_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DLV_ACTION';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF x_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_FALSE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF p_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PVT'
                             ,p_procedure_name  => 'DELETE_DLV_ACTION');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write(g_module_name, 'DELETE_DLV_ACTION: ' ||pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_ACTION ;

PROCEDURE IS_DELETE_ACTION_ALLOWED
     (p_api_version      IN NUMBER   :=1.0
     ,p_init_msg_list    IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit           IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only    IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module   IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode       IN VARCHAR2 :='N'
     ,p_max_msg_count    IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_action_id        IN pa_proj_elements.proj_element_id%TYPE
     ,p_action_ver_id    IN pa_proj_element_versions.element_version_id%TYPE
     ,p_dlv_element_id   IN pa_proj_elements.proj_element_id%TYPE
     ,p_dlv_version_id   IN pa_proj_element_versions.element_version_id%TYPE
     ,p_function_code    IN pa_proj_elements.function_code%TYPE
     ,p_project_id       IN pa_projects_all.project_id%TYPE
     ,x_action_del_allowed IN VARCHAR2
     ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_err_message fnd_new_messages.message_name%TYPE ;
     l_shipping_initiated         VARCHAR2(1) := 'N' ;
     l_proc_initiated             VARCHAR2(1) := 'N' ;

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'IS_DELETE_ACTION_ALLOWED'
                                     ,p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside IS_DELETE_ACTION_ALLOWED ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     --Bug 3512346 The Following Check (CHECK_DELV_EVENT_PROCESSED) has been uncommented.Also,passing p_Action_ver_id for the API
     --This change has been done by avaithia on Apr 1st,2004 (This is not a part of actual resolution for the bug.This is just an
     --additional fix included as a part of Bug 3512346

     IF p_function_code = g_billing THEN
          IF nvl(PA_BILLING_WRKBNCH_EVENTS.CHECK_DELV_EVENT_PROCESSED(p_project_id,p_dlv_version_id,p_action_ver_id),'Y') = 'Y' THEN /* changes done for bug 8890368 */
               l_err_message := 'PA_BILLING_ACTION_DEL_ERR' ; /* reverted the flag to 'Y' from 'N' in above for bug 9278197 */
          END IF ;
          pa_debug.g_err_stage := 'Exiting IS_DELETE_ACTION_ALLOWED' ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     ELSIF p_function_code = g_shipping THEN
          -- 3570283 changed parameter from p_dlv_version_id to p_action_ver_id
          -- api is expecting action version id and was passed deliverable version id

          -- 3555460 added validation for shipping action initiation
          -- if shipping is initiated and user is deleting shipping action,
          --    throw error message for shipping initiation
          -- else
          --    check for ready to ship flag for shipping action
          --    if ready to ship flag is set
          --        throw error message for ready to ship
          --    else
          --        allow shipping action deletion
          --    end if

          l_shipping_initiated := nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(p_action_ver_id),'N') ;

          IF l_shipping_initiated = 'Y' THEN
              l_err_message := 'PA_SHIP_ACTN_INIT_DEL_ERR';
          ELSE
              IF nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Ship_Yn(p_action_ver_id),'N') = 'Y' THEN
                   l_err_message := 'PA_SHIPPING_ACTION_DEL_ERR' ;
              END IF ;
          END IF;
     ELSIF p_function_code = g_procurement THEN
          -- 3570283 changed parameter from p_dlv_version_id to p_action_ver_id
          -- api is expecting action version id and was passed deliverable version id

          -- 3555460 added validation for procurement action initiation
          -- if procurement is initiated and user is deleting procurement action,
          --    throw error message for procurement initiation
          -- else
          --    check for ready to procure flag for procuremetn action
          --    if ready to procure flag is set
          --        throw error message for ready to procure
          --    else
          --        allow procurement action deletion
          --    end if

          l_proc_initiated := nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(p_action_ver_id),'N') ;

          IF l_proc_initiated = 'Y' THEN
              l_err_message := 'PA_PROC_ACTN_INIT_DEL_ERR';
          ELSE
              IF nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Procure_Yn(p_action_ver_id),'N') = 'Y' THEN
                   l_err_message := 'PA_PROCUREMENT_ACTION_DEL_ERR' ;
              END IF ;
          END IF ;
     END IF ;

     IF l_err_message IS NOT NULL THEN
          PA_UTILS.ADD_MESSAGE('PA',l_err_message);
          x_return_status := 'E';
     END IF ;

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Exiting IS_DELETE_ACTION_ALLOWED' ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;

EXCEPTION
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PVT'
                             ,p_procedure_name  => 'IS_DELETE_ACTION_ALLOWED');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('IS_DELETE_ACTION_ALLOWED: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END IS_DELETE_ACTION_ALLOWED;

-- SubProgram           : COPY_ACTIONS
-- Type                 : PROCEDURE
-- Purpose              : Private API to Copy Actions From Source To Destination
-- Note                 : Its a BULK API
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_source_object_id              IN          NUMBER            Y        Source Object Id
-- p_source_object_type            IN          VARCHAR2          Y        Source Object Type
-- p_target_object_id              IN          NUMBER            Y        Target Object Id
-- p_target_object_type            IN          VARCHAR2          Y        Target Object Type
-- p_project_id                    IN          NUMBER            Y        Project Id
-- p_task_id                       IN          NUMBER            N        Task Id
-- p_pm_source_reference           IN          VARCHAR2          N        PM Source Reference
-- p_carrying_out_organization_id  IN          VARCHAR2          N        Carrying Out Org ID
-- p_insert_or_update              IN          VARCHAR2          N        Identifies the API Mode
-- x_return_status                 OUT         VARCHAR2          N        Mandatory Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Mandatory Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Mandatory Out Parameter

PROCEDURE COPY_ACTIONS
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_source_object_id    IN pa_object_relationships.object_id_from2%TYPE
     ,p_source_object_type  IN pa_object_relationships.object_type_from%TYPE
     ,p_target_object_id    IN pa_object_relationships.object_id_from2%TYPE
     ,p_target_object_type  IN pa_object_relationships.object_type_from%TYPE
     ,p_source_project_id   IN pa_projects_all.project_id%TYPE
     ,p_target_project_id   IN pa_projects_all.project_id%TYPE
     ,p_task_id             IN pa_proj_elements.proj_element_id%TYPE := null
     ,p_task_ver_id         IN pa_proj_element_versions.element_version_id%TYPE := null
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE := null
     ,p_pm_source_reference IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_code      IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_calling_mode        IN VARCHAR2 := NULL -- Added for bug# 3911050
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS

--Bug 3614361
l_proj_id                   pa_projects_all.project_id%TYPE;

CURSOR get_source_actions IS
   SELECT  ppe.name
          ,ppe.manager_person_id
          ,ppe.function_code
          ,psc.scheduled_finish_date
          ,'N'
-- Bug 3665911 Action Completion date should not get copied   ,psc.actual_finish_date
          ,null                  -- Hence passing the completion date as null
          ,ppe.description
          ,ppe.attribute_category
          ,ppe.attribute1
          ,ppe.attribute2
          ,ppe.attribute3
          ,ppe.attribute4
          ,ppe.attribute5
          ,ppe.attribute6
          ,ppe.attribute7
          ,ppe.attribute8
          ,ppe.attribute9
          ,ppe.attribute10
          ,ppe.attribute11
          ,ppe.attribute12
          ,ppe.attribute13
          ,ppe.attribute14
          ,ppe.attribute15
--          ,null  --Commented for Bug # 3431156  --This corresponds to the target action version id
--          ,null  --Commented for Bug # 3431156  --This corresponds to target action projelementid
          ,ppe.proj_element_id                 --Source Action Proj Element Id -- Included for Bug # 3431156
          ,ppv.element_version_id         --Source Action Version Id -- Included for Bug # 3431156
          ,pa_proj_element_versions_s.nextval  -- Target Action Version Id  -- Included for Bug # 3431156
          ,pa_tasks_s.nextval                  -- Target Action Proj Element Id -- Included for Bug # 3431156
          ,null    -- record version number
    FROM  pa_proj_elements ppe,
          pa_proj_element_versions ppv,
          pa_proj_elem_ver_schedule psc,
          pa_object_relationships obj,
          pa_projects_all pa,
          pa_project_types_all ppt
   WHERE  obj.object_id_from2 = p_source_object_id
     AND  obj.object_type_from = p_source_object_type
     AND  obj.relationship_type = 'A'
     AND  ppe.object_type = g_actions
     AND  ppe.project_id = l_proj_id /*3614361*/
     AND  ppv.project_id = l_proj_id /*3614361*/
     AND  psc.project_id = l_proj_id /*3614361*/
     AND  obj.object_id_to2 = ppe.proj_element_id
     AND  ppe.proj_element_id = ppv.proj_element_id
     AND  ppv.element_version_id = psc.element_version_id
     AND  pa.project_id = p_target_project_id
     AND  pa.project_type = ppt.project_type
     AND  pa.org_id = ppt.org_id
     AND  decode(ppt.project_type_class_code,'CONTRACT','X',ppe.function_code) <> 'BILLING' ;


     l_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_mgr_person_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_function_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_due_date_tbl           SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_comp_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()      ;
     l_comp_date_tbl          SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_element_id_tbl         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_element_ver_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_rec_ver_num_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_description_tbl        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_attribute_category_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;
     l_attribute1_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute2_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute3_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute4_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute5_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute6_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute7_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute8_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute9_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute10_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute11_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute12_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute13_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute14_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute15_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;

     l_carrying_out_org_id    PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE ;
     l_object_version_id      PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null  ; --The target Deliverable version id

     --Start Bug # 3431156
     l_source_object_ver_id   PA_OBJECT_RELATIONSHIPS.OBJECT_ID_FROM1%TYPE :=null ; --The source Deliverable version id
     l_source_action_id_tbl   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()  ;  --The Source Action Id
     l_source_action_ver_id_tbl   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(); --The Source Action Version Id
     --End --Bug # 3431156

     l_project_mode           VARCHAR2(30) := 'PROJECT' ;
     l_dummy                  VARCHAR2(240) ;

     l_debug_mode             VARCHAR2(10);
     l_msg_count              NUMBER ;
     l_data                   VARCHAR2(2000);
     l_msg_data               VARCHAR2(2000);
     l_msg_index_out          NUMBER;

     l_action_type            VARCHAR2(5);      -- 3573134 added variable to set action type for
                                                -- oke actions

     --Commented for Bug # 3431156
     /*CURSOR get_version_id
     IS
     SELECT element_version_id
       FROM pa_proj_element_versions
      WHERE proj_element_id = l_target_object_id
        AND object_type = 'PA_DELIVERABLES' ;*/

    --Bug # 3431156 Modified the cursor to fetch
    --either the source deliverable version id/target deliverable version id
     CURSOR get_version_id (l_dlv_id NUMBER)
     IS
     SELECT element_version_id
       FROM pa_proj_element_versions
      WHERE proj_element_id = l_dlv_id
        AND object_type = 'PA_DELIVERABLES' ;

     CURSOR get_project_mode
     IS
     SELECT 'TEMPLATE'
     FROM pa_projects_all
     WHERE project_id = p_target_project_id
       AND template_flag = 'Y';
BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'COPY_ACTIONS'
                                     ,p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside COPY_ACTIONS ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     OPEN get_project_mode ;
     FETCH get_project_mode INTO l_project_mode ;
     CLOSE get_project_mode ;

     --Fetch all the actions from the source to
     --PLSQL table.
     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Before fetch:get_source_actions : ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     -- Bug 3614361
      IF p_source_object_type = g_dlvr_types THEN
        l_proj_id := -99 ;
      ELSE
        l_proj_id := p_source_project_id ;
      END IF;
     -- Bug 3614361

     OPEN  get_source_actions ;
     FETCH get_source_actions BULK COLLECT INTO
            l_name_tbl
           ,l_mgr_person_id_tbl
           ,l_function_code_tbl
           ,l_due_date_tbl
           ,l_comp_flag_tbl
           ,l_comp_date_tbl
           ,l_description_tbl
           ,l_attribute_category_tbl
           ,l_attribute1_tbl
           ,l_attribute2_tbl
           ,l_attribute3_tbl
           ,l_attribute4_tbl
           ,l_attribute5_tbl
           ,l_attribute6_tbl
           ,l_attribute7_tbl
           ,l_attribute8_tbl
           ,l_attribute9_tbl
           ,l_attribute10_tbl
           ,l_attribute11_tbl
           ,l_attribute12_tbl
           ,l_attribute13_tbl
           ,l_attribute14_tbl
           ,l_attribute15_tbl
           ,l_source_action_id_tbl     --Source action id
           ,l_source_action_ver_id_tbl --Source action version id
           ,l_element_ver_id_tbl       --target action version id  (already available)
           ,l_element_id_tbl           --target action id          (already available)
           ,l_rec_ver_num_id_tbl ;
     CLOSE get_source_actions ;

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'After fetch:get_source_actions : ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.g_err_stage:= ':l_name_tbl.LAST: '||l_name_tbl.LAST;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;
     --Following code commented for Bug # 3431156
     /* -- Get the  element version id of the deliverable
     IF  p_target_object_type = 'PA_DELIVERABLES' THEN
          OPEN get_version_id
          FETCH get_version_id INTO l_object_version_id ;
          CLOSE get_version_id ;
     END IF ;*/

     --Passing p_target_object_id to the cursor as the cursor has been
     --modified for Bug # 3431156

     -- Get the target element version id of the deliverable
     IF  p_target_object_type = 'PA_DELIVERABLES' THEN
          OPEN get_version_id (p_target_object_id);
          FETCH get_version_id INTO l_object_version_id ;
          CLOSE get_version_id ;
     END IF ;

     IF nvl(l_name_tbl.LAST,0)>0 THEN
          FOR i in l_name_tbl.FIRST..l_name_tbl.LAST LOOP

                IF l_due_date_tbl(i) is NULL THEN
                     -- Get default action date
                     PA_DELIVERABLE_UTILS.GET_DEFAULT_ACTION_DATE
                               ( p_dlvr_ver_id   => l_object_version_id
                                ,p_task_ver_id   => p_task_ver_id
                                ,p_project_mode  => l_project_mode
                                ,p_function_code => l_function_code_tbl(i)
                                ,x_due_date      => l_due_date_tbl(i)
                               ) ;
                 END IF ;

               IF l_mgr_person_id_tbl(i) IS NULL THEN
                     -- Get default action owner
                     PA_DELIVERABLE_UTILS.GET_DEFAULT_ACTION_OWNER
                              (p_dlvr_ver_id  => l_object_version_id
                              ,x_owner_id     => l_mgr_person_id_tbl(i)
                              ,x_owner_name   => l_dummy
                               ) ;
               END IF ;
          END LOOP ;
     END IF ;
     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Before calling CREATE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     -- If some thing is fetched call CREATE_DLV_ACTIONS_INBULK API
     IF nvl(l_name_tbl.LAST,0) > 0 THEN
          PA_ACTIONS_PVT.CREATE_DLV_ACTIONS_IN_BULK
               (p_api_version               => p_api_version
               ,p_init_msg_list             => p_init_msg_list
               ,p_commit                    => p_commit
               ,p_validate_only             => p_validate_only
               ,p_validation_level          => p_validation_level
               ,p_calling_module            => p_calling_module
               ,p_debug_mode                => p_debug_mode
               ,p_max_msg_count             => p_max_msg_count
               ,p_name_tbl                  => l_name_tbl
               ,p_manager_person_id_tbl     => l_mgr_person_id_tbl
               ,p_function_code_tbl         => l_function_code_tbl
               ,p_due_date_tbl              => l_due_date_tbl
               ,p_completed_flag_tbl        => l_comp_flag_tbl
               ,p_completion_date_tbl       => l_comp_date_tbl
               ,p_description_tbl           => l_description_tbl
               ,p_attribute_category_tbl    => l_attribute_category_tbl
               ,p_attribute1_tbl            => l_attribute1_tbl
               ,p_attribute2_tbl            => l_attribute2_tbl
               ,p_attribute3_tbl            => l_attribute3_tbl
               ,p_attribute4_tbl            => l_attribute4_tbl
               ,p_attribute5_tbl            => l_attribute5_tbl
               ,p_attribute6_tbl            => l_attribute6_tbl
               ,p_attribute7_tbl            => l_attribute7_tbl
               ,p_attribute8_tbl            => l_attribute8_tbl
               ,p_attribute9_tbl            => l_attribute9_tbl
               ,p_attribute10_tbl           => l_attribute10_tbl
               ,p_attribute11_tbl           => l_attribute11_tbl
               ,p_attribute12_tbl           => l_attribute12_tbl
               ,p_attribute13_tbl           => l_attribute13_tbl
               ,p_attribute14_tbl           => l_attribute14_tbl
               ,p_attribute15_tbl           => l_attribute15_tbl
               ,p_element_version_id_tbl    => l_element_ver_id_tbl
               ,p_proj_element_id_tbl       => l_element_id_tbl
               ,p_record_version_number_tbl => l_rec_ver_num_id_tbl
               ,p_project_id                => p_target_project_id
               ,p_object_id                 => p_target_object_id
               ,p_object_version_id         => l_object_version_id
               ,p_object_type               => p_target_object_type
               ,p_pm_source_code            => p_pm_source_code
               ,p_pm_source_reference       => p_pm_source_reference
               ,p_carrying_out_organization_id => p_carrying_out_organization_id
               ,x_return_status             => x_return_status
               ,x_msg_count                 => x_msg_count
               ,x_msg_data                  => x_msg_data
          ) ;

     END IF ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     --Start Bug # 3431156

     IF  p_source_object_type = 'PA_DELIVERABLES' THEN
          -- Get the source element version id of the deliverable
          OPEN get_version_id (p_source_object_id);
          FETCH get_version_id INTO l_source_object_ver_id ;
          CLOSE get_version_id ;

          IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'The source element version id(deliverable)is :'|| l_source_object_ver_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          END IF;

          --If something is fetched Call the Copy Action API of OKE
          IF nvl(l_name_tbl.LAST,0)>0 THEN

               IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Before calling OKE_DELIVERABLE_UTILS_PUB.Copy_Action ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5) ;
               END IF;

               -- 3612702 : when deliverable actions are copied based on due date
               -- defaulting logic dates should be populated,
               -- added one parameter to take due date, oke will populate this date in their table
               -- and dlvr action due date and txn dates will be in synch when actions are copied

               FOR i in l_name_tbl.FIRST..l_name_tbl.LAST LOOP
                    OKE_DELIVERABLE_UTILS_PUB.Copy_Action
                     ( P_Source_Project_ID             =>  p_source_project_id
                     , P_Target_Project_ID             =>  p_target_project_id
                     , P_Source_Deliverable_ID         =>  l_source_object_ver_id
                     , P_Target_Deliverable_ID         =>  l_object_version_id
                     , P_Source_Action_ID              =>  l_source_action_ver_id_tbl(i)
                     , P_Target_Action_ID              =>  l_element_ver_id_tbl(i)
                     , P_Target_Action_Name            =>  l_name_tbl(i)
                     , P_Target_Action_Date            =>  l_due_date_tbl(i) -- 3612702 added new parameter
                     , X_Return_Status                 =>  x_return_status
                     , X_Msg_Count                     =>  x_msg_count
                     , X_Msg_Data                      =>  x_msg_data );
                     IF  X_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE Invalid_Arg_Exc_Dlv ;
                     END IF ;

               END LOOP ;

               IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'After calling OKE_DELIVERABLE_UTILS_PUB.Copy_Action ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5) ;
               END IF;

          END IF ;

          IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE Invalid_Arg_Exc_Dlv ;
          END IF ;

     -- 3573134 added else if statement for deliverable type
     -- when ever deliverable defaults actions from type , action entry for defaulted shipping and
     -- procurement should be created in oke table also
     -- if defaulted action is of type shipping or procurement, call default_action oke api to
     -- default it to oke table

     ELSIF p_source_object_type = 'PA_DLVR_TYPES' THEN

          -- 3911050 reverted back the old changes
          -- Added a condition to check p_calling_mode, if it is UPDATE then and then call oke default_action api
          -- to default action from dlvr type to dlvr in oke tables
          -- In case of CREATE, oke create deliverable api is defaulting actions from dlvr type in their tables

          IF p_calling_mode = 'UPDATE' THEN

              -- Get the target element version id of the deliverable

              OPEN get_version_id (p_target_object_id);
              FETCH get_version_id INTO l_object_version_id ;
              CLOSE get_version_id ;

              IF p_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'The target element version id(deliverable)is :'|| l_object_version_id;
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
              END IF;

              --If something is fetched Call the Default_Action API of OKE

              IF nvl(l_name_tbl.LAST,0)>0 THEN

                   IF p_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:= 'Before calling OKE_DELIVERABLE_UTILS_PUB.Default_Action In Loop ';
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,5) ;
                   END IF;

                   FOR i in l_name_tbl.FIRST..l_name_tbl.LAST LOOP

                        l_action_type := null;

                        IF l_function_code_tbl(i) = 'SHIPPING' THEN
                            l_action_type := 'WSH';
                        ELSIF l_function_code_tbl(i) = 'PROCUREMENT' THEN
                            l_action_type := 'REQ';
                        END IF;

                        IF l_action_type IS NOT NULL THEN

                           -- 3612702 : when deliverable actions are defaulted, based on due date
                           -- defaulting logic dates should be populated,
                           -- added one parameter to take due date, oke will populate this date in their table
                           -- and dlvr action due date and txn dates will be in synch when actions are defaulted

                            OKE_DELIVERABLE_UTILS_PUB.Default_Action
                                        (
                                             P_Source_Code                =>  'PA'
                                            ,P_Action_Type                =>  l_action_type
                                            ,P_Source_Action_Name         =>  l_name_tbl(i)
                                            ,P_Source_Deliverable_ID      =>  l_object_version_id
                                            ,P_Source_Action_ID           =>  l_element_ver_id_tbl(i)
                                            ,P_Action_Date                =>  l_due_date_tbl(i) -- 3612702 added new parameter
                                        );
                        END IF;

                   END LOOP ;

                   IF p_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:= 'After calling OKE_DELIVERABLE_UTILS_PUB.Default_Action In Loop';
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,5) ;
                   END IF;

                 END IF ;
          END IF;
     END IF ;
     -- 3573134

     --End Bug # 3431156

     -- 3911050 end

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Exiting COPY_ACTIONS' ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;
     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of COPY_ACTIONS';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF get_source_actions%ISOPEN THEN
          CLOSE get_source_actions ;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PVT'
                     ,p_procedure_name  => 'COPY_ACTIONS');
     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('COPY_ACTIONS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END COPY_ACTIONS;
END PA_ACTIONS_PVT;

/
