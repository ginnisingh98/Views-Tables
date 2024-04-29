--------------------------------------------------------
--  DDL for Package Body PA_ACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTIONS_PUB" as
/* $Header: PAACTNPB.pls 120.4.12010000.3 2009/04/23 07:05:32 bifernan ship $ */

Invalid_Arg_Exc_Dlv EXCEPTION ;
g_plsql_max_array_size NUMBER := 200 ;
g_module_name    VARCHAR2(100) := 'pa.plsql.pa_actions_pub';
g_insert         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'INSERT' ;
g_create         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'CREATE' ;
g_delete         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'DELETE' ;
g_update         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'UPDATE' ;
g_modified       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'MODIFIED' ;
g_unmodified     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'UNMODIFIED' ;
g_billing        CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'BILLING';
g_shipping       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'SHIPPING';
g_procurement    CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PROCUREMENT';
g_item           CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'ITEM';
g_document       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'DOCUMENT';
g_others         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'OTHERS';
g_deliverables   CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PA_DELIVERABLES';
g_dlvr_types     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PA_DLVR_TYPES';
g_dlv_action_ship CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE:= 'WSH';
g_dlv_action_proc CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE:= 'REQ';

-- SubProgram           : CREATE_DLV_ACTIONS_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Public API to create to Deliverable Actions
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
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE := null
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
     l_rel_subtype                PA_OBJECT_RELATIONSHIPS.RELATIONSHIP_SUBTYPE%TYPE ;
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
          PA_DEBUG.set_curr_function( p_function   => 'CR_DLV_ACTIONS_IN_BULK'
                                     ,p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside CREATE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CR_DLV_ACTIONS_SP ;
     END IF;

     -- Call the pvt Create API only if something is fetched
     -- to avoid unnecessary API call.
     IF nvl(p_name_tbl.LAST,0)> 0 THEN

          IF l_debug_mode = 'Y' THEN
        pa_debug.write(g_module_name,'Before Calling PA_ACTIONS_PVT.CREATE_DLV_ACTIONS_IN_BULK' ,3);
     END IF;
          PA_ACTIONS_PVT.CREATE_DLV_ACTIONS_IN_BULK
               (p_api_version                  => p_api_version
               ,p_init_msg_list                => FND_API.G_FALSE
               ,p_commit                       => p_commit
               ,p_validate_only                => p_validate_only
               ,p_validation_level             => p_validation_level
               ,p_calling_module               => p_calling_module
               ,p_debug_mode                   => l_debug_mode
               ,p_max_msg_count                => p_max_msg_count
               ,p_name_tbl                     => p_name_tbl
               ,p_manager_person_id_tbl        => p_manager_person_id_tbl
               ,p_function_code_tbl            => p_function_code_tbl
               ,p_due_date_tbl                 => p_due_date_tbl
               ,p_completed_flag_tbl           => p_completed_flag_tbl
               ,p_completion_date_tbl          => p_completion_date_tbl
               ,p_description_tbl              => p_description_tbl
               ,p_attribute_category_tbl       => p_attribute_category_tbl
               ,p_attribute1_tbl               => p_attribute1_tbl
               ,p_attribute2_tbl               => p_attribute2_tbl
               ,p_attribute3_tbl               => p_attribute3_tbl
               ,p_attribute4_tbl               => p_attribute4_tbl
               ,p_attribute5_tbl               => p_attribute5_tbl
               ,p_attribute6_tbl               => p_attribute6_tbl
               ,p_attribute7_tbl               => p_attribute7_tbl
               ,p_attribute8_tbl               => p_attribute8_tbl
               ,p_attribute9_tbl               => p_attribute9_tbl
               ,p_attribute10_tbl              => p_attribute10_tbl
               ,p_attribute11_tbl              => p_attribute11_tbl
               ,p_attribute12_tbl              => p_attribute12_tbl
               ,p_attribute13_tbl              => p_attribute13_tbl
               ,p_attribute14_tbl              => p_attribute14_tbl
               ,p_attribute15_tbl              => p_attribute15_tbl
               ,p_element_version_id_tbl       => p_element_version_id_tbl
               ,p_proj_element_id_tbl          => p_proj_element_id_tbl
               ,p_record_version_number_tbl    => p_record_version_number_tbl
               ,p_project_id                   => p_project_id
               ,p_object_id                    => p_object_id
               ,p_object_version_id            => p_object_version_id
               ,p_object_type                  => p_object_type
               ,p_pm_source_code               => p_pm_source_code
               ,p_pm_source_reference          => p_pm_source_reference
               ,p_pm_source_reference_tbl      => p_pm_source_reference_tbl -- added 3435905
               ,p_carrying_out_organization_id => p_carrying_out_organization_id
               ,x_return_status                => x_return_status
               ,x_msg_count                    => x_msg_count
               ,x_msg_data                     => x_msg_data
               ) ;
     END IF ;
     IF l_debug_mode = 'Y' THEN
     pa_debug.write(g_module_name,'x_return_status is ' || x_return_status,3);
    END IF ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting PA_ACTIONS_PUB.CREATE_DLV_ACTIONS_IN_BULK' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CR_DLV_ACTIONS_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of CR_DLV_ACTIONS_IN_BULK';
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

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CR_DLV_ACTIONS_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'CREATE_DLV_ACTIONS_IN_BULK');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write(g_module_name, pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END CREATE_DLV_ACTIONS_IN_BULK ;

-- SubProgram           : UPDATE_DLV_ACTIONS_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Public API to Update To Deliverable Actions
-- Note                 : Its a BULK API
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N      Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N      Standard Parameter
-- p_commit                        IN          VARCHAR2          N      Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N      Standard Parameter
-- p_validation_level              IN          NUMBER            N      Standard Parameter
-- p_calling_module                IN          VARCHAR2          N      Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N      Standard Parameter
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
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null -- 3578694 passing default null
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
          PA_DEBUG.set_curr_function( p_function   => 'UPDADTE_DLV_ACTIONS_IN_BULK'
                                     ,p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside UPDATE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UP_DLV_ACTIONS_SP ;
     END IF;

     -- Call the pvt Create API only if something is fetched
     -- to avoid unnecessary API call.
     IF nvl(p_name_tbl.LAST,0)>0 THEN

          PA_ACTIONS_PVT.UPDATE_DLV_ACTIONS_IN_BULK
               (p_api_version                     => p_api_version
               ,p_init_msg_list                   => FND_API.G_FALSE
               ,p_commit                          => p_commit
               ,p_validate_only                   => p_validate_only
               ,p_validation_level                => p_validation_level
               ,p_calling_module                  => p_calling_module
               ,p_debug_mode                      => l_debug_mode
               ,p_max_msg_count                   => p_max_msg_count
               ,p_name_tbl                        => p_name_tbl
               ,p_manager_person_id_tbl           => p_manager_person_id_tbl
               ,p_function_code_tbl               => p_function_code_tbl
               ,p_due_date_tbl                    => p_due_date_tbl
               ,p_completed_flag_tbl              => p_completed_flag_tbl
               ,p_completion_date_tbl             => p_completion_date_tbl
               ,p_description_tbl                 => p_description_tbl
               ,p_attribute_category_tbl          => p_attribute_category_tbl
               ,p_attribute1_tbl                  => p_attribute1_tbl
               ,p_attribute2_tbl                  => p_attribute2_tbl
               ,p_attribute3_tbl                  => p_attribute3_tbl
               ,p_attribute4_tbl                  => p_attribute4_tbl
               ,p_attribute5_tbl                  => p_attribute5_tbl
               ,p_attribute6_tbl                  => p_attribute6_tbl
               ,p_attribute7_tbl                  => p_attribute7_tbl
               ,p_attribute8_tbl                  => p_attribute8_tbl
               ,p_attribute9_tbl                  => p_attribute9_tbl
               ,p_attribute10_tbl                 => p_attribute10_tbl
               ,p_attribute11_tbl                 => p_attribute11_tbl
               ,p_attribute12_tbl                 => p_attribute12_tbl
               ,p_attribute13_tbl                 => p_attribute13_tbl
               ,p_attribute14_tbl                 => p_attribute14_tbl
               ,p_attribute15_tbl                 => p_attribute15_tbl
               ,p_element_version_id_tbl          => p_element_version_id_tbl
               ,p_proj_element_id_tbl             => p_proj_element_id_tbl
               ,p_record_version_number_tbl       => p_record_version_number_tbl
               ,p_project_id                      => p_project_id
               ,p_object_id                       => p_object_id
               ,p_object_version_id               => p_object_version_id
               ,p_object_type                     => p_object_type
               ,p_pm_source_code                  => p_pm_source_code
               ,p_pm_source_reference             => p_pm_source_reference
               ,p_carrying_out_organization_id    => p_carrying_out_organization_id
               ,x_return_status                   => x_return_status
               ,x_msg_count                       => x_msg_count
               ,x_msg_data                        => x_msg_data
               ) ;

     END IF ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting UPDATE_DLV_ACTIONS_IN_BULK' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO UP_DLV_ACTIONS_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of UPDATE_DLV_ACTIONS_IN_BULK';
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

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO UP_DLV_ACTIONS_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
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
-- Purpose              : Public API to Delete To Deliverable Actions
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
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_ACTIONS_IN_BULK',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;


     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DEL_DLV_ACTIONS_SP ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     PA_ACTIONS_PVT.DELETE_DLV_ACTIONS_IN_BULK
          (p_api_version               => p_api_version
          ,p_init_msg_list             => FND_API.G_FALSE
          ,p_commit                    => p_commit
          ,p_validate_only             => p_validate_only
          ,p_validation_level          => p_validation_level
          ,p_calling_module            => p_calling_module
          ,p_debug_mode                => l_debug_mode
          ,p_max_msg_count             => p_max_msg_count
          ,p_object_type               => p_object_type
          ,p_object_id                 => p_object_id
          ,p_element_version_id_tbl    => p_element_version_id_tbl
          ,p_proj_element_id_tbl       => p_proj_element_id_tbl
          ,p_record_version_number_tbl => p_record_version_number_tbl
          ,x_return_status             => x_return_status
          ,x_msg_count                 => x_msg_count
          ,x_msg_data                  => x_msg_data
          ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO DEL_DLV_ACTIONS_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of CR_UP_DLV_ACTIONS_IN_BULK';
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

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO UP_DLV_ACTIONS_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'DELETE_DLV_ACTIONS_IN_BULK');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_ACTIONS_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_ACTIONS_IN_BULK ;

-- SubProgram           : CR_UP_DLV_ACTIONS_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Public API to Create/Update To Deliverable Actions
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
-- p_insert_or_update              IN          VARCHAR2          N        Identifies the API Mode
-- x_return_status                 OUT         VARCHAR2          N        Mandatory Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Mandatory Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Mandatory Out Parameter

PROCEDURE CR_UP_DLV_ACTIONS_IN_BULK
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
     ,p_user_action_tbl           IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE  := null
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE
     ,p_object_version_id         IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_pm_source_code            IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_pm_source_reference       IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_reference_tbl   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE() -- added 3435905
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE := null
     ,p_insert_or_update          IN VARCHAR2 := 'INSERT'
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS

     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;

     l_ins_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_mgr_person_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_ins_function_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_ins_due_date_tbl           SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_ins_comp_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()      ;
     l_ins_comp_date_tbl          SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_ins_element_id_tbl         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_ins_element_ver_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_ins_rec_ver_num_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_ins_description_tbl        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_ins_attribute_category_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;
     l_ins_attribute1_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute2_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute3_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute4_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute5_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute6_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute7_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute8_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute9_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute10_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute11_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute12_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute13_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute14_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_ins_attribute15_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;

     l_upd_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_mgr_person_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_upd_function_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_upd_due_date_tbl           SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_upd_comp_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()      ;
     l_upd_comp_date_tbl          SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_upd_element_id_tbl         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_upd_element_ver_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_upd_rec_ver_num_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_upd_description_tbl        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_upd_attribute_category_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;
     l_upd_attribute1_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute2_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute3_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute4_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute5_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute6_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute7_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute8_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute9_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute10_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute11_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute12_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute13_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute14_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute15_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;

     l_del_element_id_tbl         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_del_element_ver_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_del_rec_ver_num_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;

     j_ins NUMBER ;
     j_upd NUMBER ;
     j_del NUMBER ;

     -- 3769024 curstor to retrieve element_version_id of action from proj_element_id

     Cursor c_actn_info(l_action_ver_id IN NUMBER) IS
     SELECT
            PEV.PROJ_ELEMENT_ID
     FROM
            PA_PROJ_ELEMENT_VERSIONS PEV
     WHERE
            PEV.ELEMENT_VERSION_ID = l_action_ver_id
        AND PEV.OBJECT_TYPE        = 'PA_ACTIONS';

    -- 3769024 end

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CR_UP_DLV_ACTIONS_IN_BULK',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside CR_UP_DLV_ACTIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Printing Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.write(g_module_name,'p_object_id'||':'||p_object_id,3) ;
          pa_debug.write(g_module_name,'p_object_type'||':'||p_object_type,3) ;
          pa_debug.write(g_module_name,'p_insert_or_update'||':'||p_insert_or_update,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CR_UP_DLV_ACTIONS_SP ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF p_insert_or_update IS NULL
     THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'INVALID INPUT PARAMETER';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                             ,p_msg_name         => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;


     -- Call the validation API. It will
     -- perform all the validation.
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Calling PA_ACTIONS_PUB.VALIDATE_ACTIONS';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

       -- Bug 3651563 ,If p_calling_module is nt passed ,
       -- Whatever validation is done in this API specific to AMG Flow will not get fired
       -- So,Passing p_calling_module also
       PA_ACTIONS_PUB.VALIDATE_ACTIONS
            ( p_init_msg_list         => FND_API.G_FALSE
             ,p_debug_mode            => l_debug_mode
             ,p_calling_module        => p_calling_module   -- Included by avaithia Bug 3651563
             ,p_name_tbl              => p_name_tbl
             ,p_completed_flag_tbl    => p_completed_flag_tbl
             ,p_completion_date_tbl   => p_completion_date_tbl
             ,p_description_tbl       => p_description_tbl
             ,p_function_code_tbl     => p_function_code_tbl
             ,p_due_date_tbl          => p_due_date_tbl
             ,p_element_version_id_tbl=> p_element_version_id_tbl
             ,p_proj_element_id_tbl   => p_proj_element_id_tbl
             ,p_user_action_tbl       => p_user_action_tbl
             ,p_object_id             => p_object_id
             ,p_object_version_id     => p_object_version_id
             ,p_object_type           => p_object_type
             ,p_project_id            => p_project_id
             ,p_action_owner_id_tbl   => p_manager_person_id_tbl
             ,p_carrying_out_org_id   => p_carrying_out_organization_id
             ,p_action_reference_tbl  => p_pm_source_reference_tbl
             ,p_deliverable_id        => p_object_id
             ,p_insert_or_update      => p_insert_or_update
             ,x_return_status         => x_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
           ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;


     -- In update mode user can perform following actions
     -- 1. Create a new action.
     -- 2. Update an existing/new action.
     -- 3. Delete an existing/new action.
     -- So, in update mode following execution order will
     -- be maintained.
     --     1. Delete
     --     2. Update
     --     3. Insert

     -- Loop through p_user_actions_tbl to find out the
     -- actions which are deleted by user.


     -- Initialize the local variable
     j_ins := 0 ;
     j_upd := 0 ;
     j_del := 0 ;

     IF nvl(p_user_action_tbl.last,0) >= 1 THEN -- Only if something is fetched

          FOR i in p_user_action_tbl.FIRST .. p_user_action_tbl.LAST LOOP

               IF nvl(p_user_action_tbl(i),g_insert) = g_insert THEN

                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Insert Operation';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    j_ins:=j_ins+1 ;

                    -- Get all the actions which are created, into
                    -- local plsql tables, which will be used to
                    -- call PLSQL bulk API for create.

                    -- extend the size of PLSQL table
                    l_ins_element_id_tbl.extend        ;
                    l_ins_element_ver_id_tbl.extend    ;
                    l_ins_rec_ver_num_id_tbl.extend    ;
                    l_ins_name_tbl.extend              ;
                    l_ins_function_code_tbl.extend     ;
                    l_ins_mgr_person_id_tbl.extend     ;
                    l_ins_due_date_tbl.extend          ;
                    l_ins_comp_flag_tbl.extend         ;
                    l_ins_comp_date_tbl.extend         ;
                    l_ins_attribute_category_tbl.extend;
                    l_ins_attribute1_tbl.extend        ;
                    l_ins_attribute2_tbl.extend        ;
                    l_ins_attribute3_tbl.extend        ;
                    l_ins_attribute4_tbl.extend        ;
                    l_ins_attribute5_tbl.extend        ;
                    l_ins_attribute6_tbl.extend        ;
                    l_ins_attribute7_tbl.extend        ;
                    l_ins_attribute8_tbl.extend        ;
                    l_ins_attribute9_tbl.extend        ;
                    l_ins_attribute10_tbl.extend       ;
                    l_ins_attribute11_tbl.extend       ;
                    l_ins_attribute12_tbl.extend       ;
                    l_ins_attribute13_tbl.extend       ;
                    l_ins_attribute14_tbl.extend       ;
                    l_ins_attribute15_tbl.extend       ;
                    l_ins_description_tbl.extend       ;


                    l_ins_element_id_tbl(j_ins)      := p_proj_element_id_tbl(i)           ;
                    l_ins_element_ver_id_tbl(j_ins)  := p_element_version_id_tbl(i)        ;

                    IF p_debug_mode = 'Y' THEN
                        pa_debug.write(g_module_name,'Tracking vers id ['||p_element_version_id_tbl(i)||'] elem id['||p_proj_element_id_tbl(i) ,3) ;
                    END IF;

                    l_ins_rec_ver_num_id_tbl(j_ins)  := p_record_version_number_tbl(i)     ;
                    l_ins_name_tbl(j_ins)            := p_name_tbl(i)                      ;
                    l_ins_function_code_tbl(j_ins)   := p_function_code_tbl(i)             ;

                    IF p_object_type <> g_dlvr_types THEN
                         l_ins_mgr_person_id_tbl(j_ins)     := p_manager_person_id_tbl(i)  ;
                         l_ins_due_date_tbl(j_ins)          := p_due_date_tbl(i)           ;
                         l_ins_comp_flag_tbl(j_ins)         := p_completed_flag_tbl(i)     ;
                         l_ins_comp_date_tbl(j_ins)         := p_completion_date_tbl(i)    ;
                         l_ins_attribute_category_tbl(j_ins):= p_attribute_category_tbl(i) ;
                         l_ins_attribute1_tbl(j_ins)        := p_attribute1_tbl(i)         ;
                         l_ins_attribute2_tbl(j_ins)        := p_attribute2_tbl(i)         ;
                         l_ins_attribute3_tbl(j_ins)        := p_attribute3_tbl(i)         ;
                         l_ins_attribute4_tbl(j_ins)        := p_attribute4_tbl(i)         ;
                         l_ins_attribute5_tbl(j_ins)        := p_attribute5_tbl(i)         ;
                         l_ins_attribute6_tbl(j_ins)        := p_attribute6_tbl(i)         ;
                         l_ins_attribute7_tbl(j_ins)        := p_attribute7_tbl(i)         ;
                         l_ins_attribute8_tbl(j_ins)        := p_attribute8_tbl(i)         ;
                         l_ins_attribute9_tbl(j_ins)        := p_attribute9_tbl(i)         ;
                         l_ins_attribute10_tbl(j_ins)       := p_attribute10_tbl(i)        ;
                         l_ins_attribute11_tbl(j_ins)       := p_attribute11_tbl(i)        ;
                         l_ins_attribute12_tbl(j_ins)       := p_attribute12_tbl(i)        ;
                         l_ins_attribute13_tbl(j_ins)       := p_attribute13_tbl(i)        ;
                         l_ins_attribute14_tbl(j_ins)       := p_attribute14_tbl(i)        ;
                         l_ins_attribute15_tbl(j_ins)       := p_attribute15_tbl(i)        ;
                         l_ins_description_tbl(j_ins)       := p_description_tbl(i)        ;
                    END IF;

               ELSIF nvl(p_user_action_tbl(i),g_insert) = g_modified THEN

                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Update Operation';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    j_upd:=j_upd+1 ;

                    -- Get all the actions which are updated, into
                    -- local plsql tables, which will be used to
                    -- call PLSQL bulk API for update.

                    -- extend the size of PLSQL table
                    l_upd_element_id_tbl.extend        ;
                    l_upd_element_ver_id_tbl.extend    ;
                    l_upd_rec_ver_num_id_tbl.extend    ;
                    l_upd_name_tbl.extend              ;
                    l_upd_function_code_tbl.extend     ;
                    l_upd_mgr_person_id_tbl.extend     ;
                    l_upd_due_date_tbl.extend          ;
                    l_upd_comp_flag_tbl.extend         ;
                    l_upd_comp_date_tbl.extend         ;
                    l_upd_attribute_category_tbl.extend;
                    l_upd_attribute1_tbl.extend        ;
                    l_upd_attribute2_tbl.extend        ;
                    l_upd_attribute3_tbl.extend        ;
                    l_upd_attribute4_tbl.extend        ;
                    l_upd_attribute5_tbl.extend        ;
                    l_upd_attribute6_tbl.extend        ;
                    l_upd_attribute7_tbl.extend        ;
                    l_upd_attribute8_tbl.extend        ;
                    l_upd_attribute9_tbl.extend        ;
                    l_upd_attribute10_tbl.extend       ;
                    l_upd_attribute11_tbl.extend       ;
                    l_upd_attribute12_tbl.extend       ;
                    l_upd_attribute13_tbl.extend       ;
                    l_upd_attribute14_tbl.extend       ;
                    l_upd_attribute15_tbl.extend       ;
                    l_upd_description_tbl.extend       ;

                    -- 3769024 added IF below code to handle following scenarion :
                    -- on Create Deliverable Actions page, user created some actions and clicked on Save button
                    -- After that updated that action's description and clicked on Apply button
                    -- description was not getting updated.

                    -- Because, Update_Dlv_Actions_In_Bulk api, uses proj_element_id to update action info
                    -- In above scenario, proj_element_id will be passed as NULL and update is failing
                    -- Added code to retrieve proj_element_id in update actions,
                    -- if proj_element id is null and element_version_id is not null
                    -- else it's normal scenario

                    IF p_proj_element_id_tbl(i) IS NULL AND p_element_version_id_tbl(i) IS NOT NULL THEN
                        Open c_actn_info(p_element_version_id_tbl(i));
                        Fetch c_actn_info INTO l_upd_element_id_tbl(j_upd);
                        Close c_actn_info;
                    ELSE
                        l_upd_element_id_tbl(j_upd)      := p_proj_element_id_tbl(i)           ;
                    END IF;

                    -- 3769024 end

                    l_upd_element_ver_id_tbl(j_upd)  := p_element_version_id_tbl(i)        ;
                    l_upd_rec_ver_num_id_tbl(j_upd)  := p_record_version_number_tbl(i)     ;
                    l_upd_name_tbl(j_upd)            := p_name_tbl(i)                      ;
                    l_upd_function_code_tbl(j_upd)   := p_function_code_tbl(i)             ;

                    IF p_object_type <> g_dlvr_types THEN
                         l_upd_mgr_person_id_tbl(j_upd)     := p_manager_person_id_tbl(i)  ;
                         l_upd_due_date_tbl(j_upd)          := p_due_date_tbl(i)           ;
                         l_upd_comp_flag_tbl(j_upd)         := p_completed_flag_tbl(i)     ;
                         l_upd_comp_date_tbl(j_upd)         := p_completion_date_tbl(i)    ;
                         l_upd_attribute_category_tbl(j_upd):= p_attribute_category_tbl(i) ;
                         l_upd_attribute1_tbl(j_upd)        := p_attribute1_tbl(i)         ;
                         l_upd_attribute2_tbl(j_upd)        := p_attribute2_tbl(i)         ;
                         l_upd_attribute3_tbl(j_upd)        := p_attribute3_tbl(i)         ;
                         l_upd_attribute4_tbl(j_upd)        := p_attribute4_tbl(i)         ;
                         l_upd_attribute5_tbl(j_upd)        := p_attribute5_tbl(i)         ;
                         l_upd_attribute6_tbl(j_upd)        := p_attribute6_tbl(i)         ;
                         l_upd_attribute7_tbl(j_upd)        := p_attribute7_tbl(i)         ;
                         l_upd_attribute8_tbl(j_upd)        := p_attribute8_tbl(i)         ;
                         l_upd_attribute9_tbl(j_upd)        := p_attribute9_tbl(i)         ;
                         l_upd_attribute10_tbl(j_upd)       := p_attribute10_tbl(i)        ;
                         l_upd_attribute11_tbl(j_upd)       := p_attribute11_tbl(i)        ;
                         l_upd_attribute12_tbl(j_upd)       := p_attribute12_tbl(i)        ;
                         l_upd_attribute13_tbl(j_upd)       := p_attribute13_tbl(i)        ;
                         l_upd_attribute14_tbl(j_upd)       := p_attribute14_tbl(i)        ;
                         l_upd_attribute15_tbl(j_upd)       := p_attribute15_tbl(i)        ;
                         l_upd_description_tbl(j_upd)       := p_description_tbl(i)        ;
                    END IF ;

               ELSIF nvl(p_user_action_tbl(i),g_insert) = g_delete THEN

                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Delete Operation';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    j_del:=j_del+1 ;

                    -- Get all the actions which are deleted, into
                    -- local plsql table, which will be used to
                    -- call PLSQL bulk API for delete. This is not
                    -- applicable for actions which are deleted
                    -- from Actions page.  From action page the
                    -- Deletion is handled in a seperate way .

                    -- extend the size of PLSQL table
                    l_del_element_id_tbl.extend        ;
                    l_del_element_ver_id_tbl.extend    ;
                    l_del_rec_ver_num_id_tbl.extend    ;

                    l_del_element_id_tbl(j_del)     := p_proj_element_id_tbl(i)           ;
                    l_del_element_ver_id_tbl(j_del) := p_element_version_id_tbl(i)        ;
                    l_del_rec_ver_num_id_tbl(j_del) := p_record_version_number_tbl(i)     ;

               END IF ;

          END LOOP ;


          -- Call the respective APIs to delete,insert,update
          -- if and only if some actions are either deleted
          -- or created or updated. The order of the API call
          -- is important.First the delete API will be called
          -- then update and then insert.

          -- Call Delete API to perform the delete operation
          IF j_del > 0 THEN

               IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Call DELETE_DLV_ACTIONS_IN_BULK ';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;

               PA_ACTIONS_PUB.DELETE_DLV_ACTIONS_IN_BULK
                    (p_api_version               => p_api_version
                    ,p_init_msg_list             => FND_API.G_FALSE
                    ,p_commit                    => p_commit
                    ,p_validate_only             => p_validate_only
                    ,p_validation_level          => p_validation_level
                    ,p_calling_module            => p_calling_module
                    ,p_debug_mode                => l_debug_mode
                    ,p_max_msg_count             => p_max_msg_count
                    ,p_object_type               => p_object_type
                    ,p_object_id                 => p_object_id
                    ,p_element_version_id_tbl    => l_del_element_ver_id_tbl
                    ,p_proj_element_id_tbl       => l_del_element_id_tbl
                    ,p_record_version_number_tbl => l_del_rec_ver_num_id_tbl
                    ,x_return_status             => x_return_status
                    ,x_msg_count                 => x_msg_count
                    ,x_msg_data                  => x_msg_data
                    ) ;

               IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE Invalid_Arg_Exc_Dlv ;
               END IF ;

         END IF ;

         -- Call Update API to perform the delete operation
         IF j_upd > 0 THEN

               IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Call UPDATE_DLV_ACTIONS_IN_BULK ';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;

               PA_ACTIONS_PUB.UPDATE_DLV_ACTIONS_IN_BULK
                    (p_api_version               => p_api_version
                    ,p_init_msg_list             => FND_API.G_FALSE
                    ,p_commit                    => p_commit
                    ,p_validate_only             => p_validate_only
                    ,p_validation_level          => p_validation_level
                    ,p_calling_module            => p_calling_module
                    ,p_debug_mode                => l_debug_mode
                    ,p_max_msg_count             => p_max_msg_count
                    ,p_name_tbl                  => l_upd_name_tbl
                    ,p_manager_person_id_tbl     => l_upd_mgr_person_id_tbl
                    ,p_function_code_tbl         => l_upd_function_code_tbl
                    ,p_due_date_tbl              => l_upd_due_date_tbl
                    ,p_completed_flag_tbl        => l_upd_comp_flag_tbl
                    ,p_completion_date_tbl       => l_upd_comp_date_tbl
                    ,p_description_tbl           => l_upd_description_tbl
                    ,p_attribute_category_tbl    => l_upd_attribute_category_tbl
                    ,p_attribute1_tbl            => l_upd_attribute1_tbl
                    ,p_attribute2_tbl            => l_upd_attribute2_tbl
                    ,p_attribute3_tbl            => l_upd_attribute3_tbl
                    ,p_attribute4_tbl            => l_upd_attribute4_tbl
                    ,p_attribute5_tbl            => l_upd_attribute5_tbl
                    ,p_attribute6_tbl            => l_upd_attribute6_tbl
                    ,p_attribute7_tbl            => l_upd_attribute7_tbl
                    ,p_attribute8_tbl            => l_upd_attribute8_tbl
                    ,p_attribute9_tbl            => l_upd_attribute9_tbl
                    ,p_attribute10_tbl           => l_upd_attribute10_tbl
                    ,p_attribute11_tbl           => l_upd_attribute11_tbl
                    ,p_attribute12_tbl           => l_upd_attribute12_tbl
                    ,p_attribute13_tbl           => l_upd_attribute13_tbl
                    ,p_attribute14_tbl           => l_upd_attribute14_tbl
                    ,p_attribute15_tbl           => l_upd_attribute15_tbl
                    ,p_element_version_id_tbl    => l_upd_element_ver_id_tbl
                    ,p_proj_element_id_tbl       => l_upd_element_id_tbl
                    ,p_record_version_number_tbl => l_upd_rec_ver_num_id_tbl
                    ,p_project_id                => p_project_id
                    ,p_object_id                 => p_object_id
                    ,p_object_version_id         => p_object_version_id
                    ,p_object_type               => p_object_type
                    ,p_pm_source_code            => p_pm_source_code
                    ,p_pm_source_reference       => p_pm_source_reference
                    ,p_carrying_out_organization_id => p_carrying_out_organization_id
                    ,x_return_status             => x_return_status
                    ,x_msg_count                 => x_msg_count
                    ,x_msg_data                  => x_msg_data
                    ) ;


               IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE Invalid_Arg_Exc_Dlv ;
               END IF ;

         END IF ;

         -- Call Insert API to perform the Insert operation
         IF j_ins > 0 THEN

               IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Call CREATE_DLV_ACTIONS_IN_BULK ';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;

               PA_ACTIONS_PUB.CREATE_DLV_ACTIONS_IN_BULK
                    (p_api_version               => p_api_version
                    ,p_init_msg_list             => FND_API.G_FALSE
                    ,p_commit                    => p_commit
                    ,p_validate_only             => p_validate_only
                    ,p_validation_level          => p_validation_level
                    ,p_calling_module            => p_calling_module
                    ,p_debug_mode                => l_debug_mode
                    ,p_max_msg_count             => p_max_msg_count
                    ,p_name_tbl                  => l_ins_name_tbl
                    ,p_manager_person_id_tbl     => l_ins_mgr_person_id_tbl
                    ,p_function_code_tbl         => l_ins_function_code_tbl
                    ,p_due_date_tbl              => l_ins_due_date_tbl
                    ,p_completed_flag_tbl        => l_ins_comp_flag_tbl
                    ,p_completion_date_tbl       => l_ins_comp_date_tbl
                    ,p_description_tbl           => l_ins_description_tbl
                    ,p_attribute_category_tbl    => l_ins_attribute_category_tbl
                    ,p_attribute1_tbl            => l_ins_attribute1_tbl
                    ,p_attribute2_tbl            => l_ins_attribute2_tbl
                    ,p_attribute3_tbl            => l_ins_attribute3_tbl
                    ,p_attribute4_tbl            => l_ins_attribute4_tbl
                    ,p_attribute5_tbl            => l_ins_attribute5_tbl
                    ,p_attribute6_tbl            => l_ins_attribute6_tbl
                    ,p_attribute7_tbl            => l_ins_attribute7_tbl
                    ,p_attribute8_tbl            => l_ins_attribute8_tbl
                    ,p_attribute9_tbl            => l_ins_attribute9_tbl
                    ,p_attribute10_tbl           => l_ins_attribute10_tbl
                    ,p_attribute11_tbl           => l_ins_attribute11_tbl
                    ,p_attribute12_tbl           => l_ins_attribute12_tbl
                    ,p_attribute13_tbl           => l_ins_attribute13_tbl
                    ,p_attribute14_tbl           => l_ins_attribute14_tbl
                    ,p_attribute15_tbl           => l_ins_attribute15_tbl
                    ,p_element_version_id_tbl    => l_ins_element_ver_id_tbl
                    ,p_proj_element_id_tbl       => l_ins_element_id_tbl
                    ,p_record_version_number_tbl => l_ins_rec_ver_num_id_tbl
                    ,p_project_id                => p_project_id
                    ,p_object_id                 => p_object_id
                    ,p_object_version_id         => p_object_version_id
                    ,p_object_type               => p_object_type
                    ,p_pm_source_code            => p_pm_source_code
                    ,p_pm_source_reference       => p_pm_source_reference
                    ,p_pm_source_reference_tbl   => p_pm_source_reference_tbl
                    ,p_carrying_out_organization_id => p_carrying_out_organization_id
                    ,x_return_status             => x_return_status
                    ,x_msg_count                 => x_msg_count
                    ,x_msg_data                  => x_msg_data
                    ) ;

           IF l_debug_mode = 'Y' THEN
                   pa_debug.write(g_module_name,' return from PA_ACTIONS_PUB.CREATE_DLV_ACTIONS_IN_BULK ['||x_return_status||']',3);
               END IF;

               IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE Invalid_Arg_Exc_Dlv ;
               END IF ;

         END IF ;

     END IF ;  -- Only if something is fetched

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting CR_UP_DLV_ACTIONS_IN_BULK' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CR_UP_DLV_ACTIONS_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of CR_UP_DLV_ACTIONS_IN_BULK';
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
     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Leaving CR_UP_DLV_ACTIONS_IN_BULK with return status ' || x_return_status ;
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;
     RETURN;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CR_UP_DLV_ACTIONS_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'CR_UP_DLV_ACTIONS_IN_BULK');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write(g_module_name,'CR_UP_DLV_ACTIONS_IN_BULK: '|| pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END CR_UP_DLV_ACTIONS_IN_BULK ;

-- SubProgram           : VALIDATE_ACTIONS
-- Type                 : PROCEDURE
-- Purpose              : Public API to Create/Update To Deliverable Actions
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
-- p_due_date_tbl                  IN          PLSQL Table       N        Due Date
-- p_completed_flag_tbl            IN          PLSQL Table       N        Completed Flag
-- p_completion_date_tbl           IN          PLSQL Table       N        Completed Date
-- p_description_tbl               IN          PLSQL Table       N        Description
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
-- p_insert_or_update              IN          VARCHAR2          N        Identifies the API Mode
-- x_return_status                 OUT         VARCHAR2          N        Mandatory Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Mandatory Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Mandatory Out Parameter

PROCEDURE  VALIDATE_ACTIONS
     ( p_api_version           IN NUMBER    :=1.0
      ,p_init_msg_list         IN VARCHAR2  :=FND_API.G_TRUE
      ,p_commit                IN VARCHAR2  :=FND_API.G_FALSE
      ,p_validate_only         IN VARCHAR2  :=FND_API.G_TRUE
      ,p_validation_level      IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
      ,p_calling_module        IN VARCHAR2  :='SELF_SERVICE'
      ,p_debug_mode            IN VARCHAR2  :='N'
      ,p_max_msg_count         IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ,p_name_tbl              IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_completed_flag_tbl    IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
      ,p_completion_date_tbl   IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
      ,p_description_tbl       IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
      ,p_function_code_tbl     IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_due_date_tbl          IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
      ,p_element_version_id_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
      ,p_proj_element_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
      ,p_user_action_tbl       IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_object_id             IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE
      ,p_object_version_id     IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null
      ,p_object_type           IN PA_LOOKUPS.LOOKUP_CODE%TYPE
      ,p_action_owner_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
      ,p_carrying_out_org_id   IN NUMBER := null
      ,p_action_reference_tbl  IN  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_deliverable_id        IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE := null
      ,p_insert_or_update      IN VARCHAR2 := 'INSERT'
      ,p_project_id            IN PA_PROJECTS_ALL.PROJECT_ID%TYPE
      ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data              OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
     l_err_message fnd_new_messages.message_text%TYPE ;

     l_debug_mode                 VARCHAR2(10);
     l_debug_level3               NUMBER := 3;
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;

     l_dlv_type_class_code        pa_task_types.task_type_class_code%type ;
     l_item_billable              VARCHAR2(1) := 'N' ;
     l_item_shippable             VARCHAR2(1) := 'N' ;
     l_item_purchasable           VARCHAR2(1) := 'N' ;
     l_bill_event_processed       VARCHAR2(1) := 'N' ;
     l_item_defined               VARCHAR2(1) := 'N' ;
     l_shipping_initiated         VARCHAR2(1) := 'N' ;
     l_proc_initiated             VARCHAR2(1) := 'N' ;
     l_ready_to_ship              VARCHAR2(1) := 'N' ;
     l_ready_to_proc              VARCHAR2(1) := 'N' ;
     l_due_date                   DATE ;
     l_completed_date             DATE ;
     l_completed_flag             VARCHAR2(1) ;

     l_is_dlv_itembased          VARCHAR2(1);
     l_function_code             PA_LOOKUPS.LOOKUP_CODE%TYPE := NULL;
     l_function_code_valid       VARCHAR2(1) := 'N';
     l_carrying_out_org_id       NUMBER;
     l_action_owner_id           NUMBER;

     l_project_number            PA_PROJECTS_ALL.SEGMENT1%TYPE := NULL;
     l_deliverable_number        PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE := NULL;

     -- added for bug :4537865
     l_new_carrying_out_org_id       NUMBER ;
     l_new_action_owner_id 	NUMBER;
     -- added for bug :4537865
     i_act                       NUMBER := 1;

     -- Included for Bug 3651563
     j_act               NUMBER := 1;
     k_act                       NUMBER := 1;
     l_existing_count            NUMBER := 0;
     l_name_tbl          SYSTEM.PA_VARCHAR2_240_TBL_TYPE :=  SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
     l_function_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE() ;
     l_proj_element_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;

     CURSOR c_completed_flag (c_action_id IN pa_proj_elements.proj_element_id%TYPE)IS
     SELECT decode(pps.project_system_status_code,'DLVR_COMPLETED','Y','N')
       FROM pa_project_statuses pps,
            pa_proj_elements ppe
      WHERE ppe.proj_element_id = c_action_id
        AND pps.project_status_code = ppe.status_code ;

     CURSOR c_completed_date (c_action_ver_id IN pa_proj_element_versions.element_version_id%TYPE) IS
     SELECT actual_finish_date
           ,scheduled_finish_date
       FROM pa_proj_elem_ver_schedule
      WHERE element_version_id = c_action_ver_id ;

     -- Bug 3651563 Needed in AMG Flow
     -- The Following cursor will retrieve the list of actions for a given deliverable

     CURSOR c_existing_action
     IS
       SELECT PPE.NAME ,
              PPE.FUNCTION_CODE,
          PPE.PROJ_ELEMENT_ID
       FROM PA_PROJ_ELEMENTS PPE ,
            PA_OBJECT_RELATIONSHIPS OBJ
       WHERE PPE.PROJECT_ID = p_project_id
         AND OBJ.OBJECT_ID_FROM2= p_object_id
     AND PPE.PROJ_ELEMENT_ID = OBJ.OBJECT_ID_TO2
     AND OBJ.OBJECT_TYPE_FROM = 'PA_DELIVERABLES'
     AND OBJ.OBJECT_TYPE_TO = 'PA_ACTIONS'
     AND OBJ.RELATIONSHIP_SUBTYPE  = 'DELIVERABLE_TO_ACTION'
     AND OBJ.RELATIONSHIP_TYPE  = 'A' ;

     -- 3947021 Added below cursor to derive proj_element_id from element version id for action

     Cursor c_actn_info(l_action_ver_id IN NUMBER) IS
     SELECT
            PEV.PROJ_ELEMENT_ID
     FROM
            PA_PROJ_ELEMENT_VERSIONS PEV
     WHERE
            PEV.ELEMENT_VERSION_ID = l_action_ver_id
        AND PEV.OBJECT_TYPE        = 'PA_ACTIONS';

     l_action_id NUMBER;

     -- 3947021 end

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CR_UP_DLV_ACTIONS_IN_BULK',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside VALIDATE_ACTIONS ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Printing Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.write(g_module_name,'p_object_type'||':'||p_object_type,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF p_object_type = g_deliverables THEN

          -- The Type Class Code line has been commented by avaithia for Bug 3496957
          -- The line is wrong .The GET_DLV_TYPE_CLASS_CODE expects The Deliverable
          -- Type Id as parameter whereas here the DeliverablVersionId is being passed .
          -- Our requirement is handle the case if the deliverable is Item Based .
          -- For that l_is_dlv_itembased is included.

          -- l_dlv_type_class_code := nvl(PA_DELIVERABLE_UTILS.GET_DLV_TYPE_CLASS_CODE(p_object_version_id),'N') ;

          IF nvl(p_element_version_id_tbl.LAST,0) > 0 THEN
               l_is_dlv_itembased := nvl(PA_DELIVERABLE_UTILS.IS_DLV_ITEM_BASED(p_element_version_id_tbl(1)),'N');
          END IF;

          l_dlv_type_class_code := nvl(PA_DELIVERABLE_UTILS.GET_DLV_TYPE_CLASS_CODE(p_object_version_id),'N') ;
          l_item_billable       := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Billable_Yn(p_object_version_id),'N') ;
          l_item_shippable      := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Shippable_Yn(p_object_version_id),'N') ;
          l_item_purchasable    := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Purchasable_Yn(p_object_version_id),'N') ;
          l_item_defined        := nvl(OKE_DELIVERABLE_UTILS_PUB.Item_Defined_Yn(p_object_version_id),'N') ;
     END IF ;

     -- Do the locking part here in update and delete mode

     -- Validate action name.
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'No of records fetched'||p_name_tbl.LAST;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

     IF nvl(p_name_tbl.LAST,0)>0 THEN
            FOR i IN p_name_tbl.FIRST..p_name_tbl.LAST LOOP
                 FOR j in p_name_tbl.FIRST..p_name_tbl.LAST LOOP
                      IF ((nvl(p_name_tbl(i),'X') = nvl(p_name_tbl(j),'Y')) AND
                           i <> j) THEN
                           l_err_message := FND_MESSAGE.GET_STRING('PA','PA_ALL_DUPLICATE_NAME') ;
                           PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_NAME_ERR',
                                p_token1         => 'ACTION_NAME',
                                p_value1         =>  p_name_tbl(i),
                                p_token2         => 'MESSAGE',
                                p_value2         =>  l_err_message
                                );
               END IF;
        END LOOP ;
            END LOOP ;

            IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='The error message content is :' || l_err_message;
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
            END IF ;
     END IF ;


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'After Name Validation ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;


     -- 1. Validate completed check box. If Completed Check Box is
     -- 'Y' the completion date should not be null and vice versa
     -- 2. Validation Related to Billing Function
     --   2.1 Description cannot be null for billing function.
     --   2.2 Due Date cannot be null for billing function.
     --   2.3 IF deliverable is item based and billing is not enabled
     --       OR item info. is not available then action cannot be marked
     --       as completed .
     --   2.4 Completeion date cannot be updated if event has been processed
     --   2.5 Completion flag cannot be unchecked for billing function
     -- 3. Validation Related to Shipping Function
     --   3.1 Action cannot be completed if shipping is not initiated
     --   3.2 Completed flag cannot be unchecked , if shipping has been initiated
     --   3.3 Due Date cannot be updated if ready to ship is checked .
     -- 4. Validation Related to Procurement Function
     --   4.1 Action cannot be completed if procurement is not initiated
     --   4.2 Completed flag cannot be unchecked , if procurement has been initiated
     --   4.3 Due Date cannot be updated if ready to procure is checked .

     -- Following validation is required only in context of deliverables.
     IF nvl(p_object_type,g_deliverables) = g_deliverables THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= '@@@Calling Context is Deliverables #######()' ;
                pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
            END IF ;

           -- For all the records do the validation in loop .
           FOR i IN p_element_version_id_tbl.FIRST..p_element_version_id_tbl.LAST LOOP

               -- Perform the validation for new and updated records only .
               IF p_user_action_tbl(i) <> g_unmodified THEN

                     -- 3947021 Moved below code here,  earlier it was inside "IF l_action_id IS NOT NULL THEN" condition

                     -- After processing existing completed billing action if second action is new billing action,
                     -- the flags were not getting reset to original default value because for new actions
                     -- proj_element_id will be null ( validate_actions is getting called before new action creation )
                     -- Because of that validation 2.5 was failing , which should not fail for new billing action

                     -- Initialize all the local variables
                     -- for every action

                     l_due_date       := to_date(null) ;
                     l_completed_date := to_date(null) ;
                     l_completed_flag := 'N' ;
                     l_action_id      := NULL;

                    -- 3947021 end

                    -- 3947021 After the SAVE button introduction , it is possible to have proj_element_id value for existing action
                    -- as null in passed IN parameter ( Reason : after clicking on SAVE button proj_element_id is not reflected
                    -- in VO attribute for new actions and because of that p_proj_element_id_tbl(i) wont reflect the actual value )
                    -- Because of this, validation 2.5 wont fire for the existing billing action , ideally it should fire for the
                    -- existing action

                    -- Added below code to derive proj_element_id for the existing action

                    IF p_proj_element_id_tbl(i) IS NULL AND p_element_version_id_tbl(i) IS NOT NULL THEN
                        Open c_actn_info(p_element_version_id_tbl(i));
                        Fetch c_actn_info INTO l_action_id;
                        Close c_actn_info;
                    ELSE
                        l_action_id := p_proj_element_id_tbl(i);
                    END IF;

                    -- 3947021 end

                     -- Get the completed flag and due date for existing records

                     -- 3947021 changed from p_proj_element_id_tbl(i) to l_action_id

                     IF l_action_id IS NOT NULL THEN

                         -- 3947021 changed from p_proj_element_id_tbl(i) to l_action_id
                         OPEN c_completed_flag(l_action_id) ;
                         FETCH c_completed_flag into l_completed_flag ;
                         CLOSE c_completed_flag ;

                         OPEN c_completed_date(p_element_version_id_tbl(i))  ;
                         FETCH c_completed_date into l_completed_date ,l_due_date;
                         CLOSE c_completed_date ;

                     END IF ;

                     -- Please see point 1. in comments to know what validation ?
                     IF (nvl(p_completed_flag_tbl(i),'N') = 'Y' AND
                          p_completion_date_tbl(i) IS NULL  )
                     THEN
                         l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLVR_COMPLT_DATE_MISSING') ;
                         PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_NAME_ERR',
                                p_token1         => 'ACTION_NAME',
                                p_value1         =>  p_name_tbl(i),
                                p_token2         => 'MESSAGE',
                                p_value2         =>  l_err_message
                                );

                     END IF ;

                     -- Validation 1
                     IF (p_completion_date_tbl(i) IS NOT NULL AND
                         (nvl(p_completed_flag_tbl(i),'N') = 'N'))
                     THEN
                         l_err_message := FND_MESSAGE.GET_STRING('PA','PA_COMPLETION_FLAG_MUST_ERR') ;
                         PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_NAME_ERR',
                                p_token1         => 'ACTION_NAME',
                                p_value1         =>  p_name_tbl(i),
                                p_token2         => 'MESSAGE',
                                p_value2         =>  l_err_message
                                );
                     END IF ;

                     -- If action has a BILLING function
                     -- Perform validation related to BILLING function
                     IF p_function_code_tbl(i) = g_billing THEN

                          -- Initialize l_bill_event_processed
                          -- to 'N' for every action
                          l_bill_event_processed := 'N' ;

                          --For new records ,the CHECK_DELV_EVENT_PROCESSED API IS
                          --THROWING NO DATA FOUND ERROR .Thats why Included if clause
                          l_bill_event_processed := nvl(PA_BILLING_WRKBNCH_EVENTS.CHECK_DELV_EVENT_PROCESSED(p_project_id,p_object_version_id,p_element_version_id_tbl(i) ),'N') ; -- Passing Actions' version Id also (Included By avaithia for Bug 3512346 )

                          -- Validation 2.1
                          IF p_description_tbl(i) IS NULL THEN
                              l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DESCRIPTION_NULL_ERR') ;
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );
                          END IF ;

                          -- Validation 2.2  Commented by avaithia (1-Apr-04) Bug 3512346
                          --  IF p_due_date_tbl(i) IS NULL THEN
                          --     l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DUE_DATE_NULL_ERR') ;
                          --    PA_UTILS.ADD_MESSAGE
                          --          (p_app_short_name => 'PA',
                          --           p_msg_name       => 'PA_ACTION_NAME_ERR',
                          --           p_token1         => 'ACTION_NAME',
                          --           p_value1         =>  p_name_tbl(i),
                          --           p_token2         => 'MESSAGE',
                          --           p_value2         =>  l_err_message
                          --           );
                          -- END IF ;
                          --
                          -- Validation 2.3

     -- Commented for Bug 3496957 by avaithia                     IF l_dlv_type_class_code = g_item THEN
                          IF l_is_dlv_itembased ='Y' THEN
                             IF (l_item_billable = 'N'
                              AND nvl(p_completed_flag_tbl(i),'N') = 'Y'
                              AND l_item_defined = 'Y')                 -- This check has been included by avaithia Bug 3496957
                             THEN
                               l_err_message := FND_MESSAGE.GET_STRING('PA','PA_BILL_ITEM_NOT_BILLABLE_ERR') ;/*Corrected by avaithia*/
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );
                             END IF ;
                          END IF ;

                           IF l_is_dlv_itembased ='Y' THEN
                             IF (l_item_defined = 'N'
                              AND nvl(p_completed_flag_tbl(i),'N') = 'Y' )
                             THEN
                               l_err_message := FND_MESSAGE.GET_STRING('PA','PA_BILL_NO_ITEM_ERR') ;
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );
                             END IF ;
                          END IF ;
                          -- Validation 2.4

                        IF (((nvl(trunc(p_completion_date_tbl(i)),to_date(null))<> trunc(l_completed_date))
                           AND l_bill_event_processed = 'Y' ))
                        THEN
                              l_err_message := FND_MESSAGE.GET_STRING('PA','PA_BILL_COMP_DATE_ERR') ;
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );

                        END IF ;

                        -- 3951763 Added l_bill_event_processed = 'Y' condition , if billing event is processed
                        -- then and then unchecking of completion flag is not allowed

                        -- Validation 2.5
                        IF(l_bill_event_processed = 'Y' AND (nvl(p_completed_flag_tbl(i),'N') = 'N'
                              AND nvl(l_completed_flag,'N') = 'Y'))
                        THEN
                              l_err_message := FND_MESSAGE.GET_STRING('PA','PA_BILL_COMP_FLAG_ERR') ;
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );
                        END IF ;

                     -- Else If action has a SHIPPING function
                     -- Perform validation related to SHIPPING function
                     ELSIF (p_function_code_tbl(i) = g_shipping) THEN

                        -- 4227845 Added dlvr action due date not null check and populating error message
                        IF p_due_date_tbl(i) IS NULL THEN
                          l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DUE_DATE_ERR') ;
                          PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_ACTION_NAME_ERR',
                                 p_token1         => 'ACTION_NAME',
                                 p_value1         =>  p_name_tbl(i),
                                 p_token2         => 'MESSAGE',
                                 p_value2         =>  l_err_message
                                 );
                        END IF;
                        -- 4227845 end

                        --Initialize local var for each action
                        l_shipping_initiated := 'N' ;
                        l_ready_to_ship      := 'N' ;

                        l_shipping_initiated := nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(p_element_version_id_tbl(i)),'N') ;
                        l_ready_to_ship      := nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Ship_Yn(p_element_version_id_tbl(i)),'N');

                          -- Validation 3.1
                        IF ( l_shipping_initiated = 'N'
                            AND nvl(p_completed_flag_tbl(i),'N') = 'Y' )
                        THEN
                              l_err_message := FND_MESSAGE.GET_STRING('PA','PA_SHIP_PROC_COMP_ERR_Y') ;
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );

                        END IF ;

                        -- Validation 3.2
                        -- Bug#3555460
                        -- Commenting the validation as per the latest changes
                        -- in functional design.
                        -- IF ((nvl(p_completed_flag_tbl(i),'N') = 'N'
                        --    AND l_completed_flag = 'Y')
                        --    AND l_shipping_initiated = 'Y')
                        -- THEN
                        --      l_err_message := FND_MESSAGE.GET_STRING('PA','PA_SHIP_PROC_COMP_ERR_N') ;
                        --      PA_UTILS.ADD_MESSAGE
                        --            (p_app_short_name => 'PA',
                        --             p_msg_name       => 'PA_ACTION_NAME_ERR',
                        --             p_token1         => 'ACTION_NAME',
                        --             p_value1         =>  p_name_tbl(i),
                        --             p_token2         => 'MESSAGE',
                        --             p_value2         =>  l_err_message
                        --             );
                        -- END IF ;

                        -- Validation 3.3
                        IF ((trunc(p_due_date_tbl(i)) <> trunc(l_due_date )) AND
                            l_ready_to_ship = 'Y' )
                        THEN
                              l_err_message := FND_MESSAGE.GET_STRING('PA','PA_SHIP_DUE_DATE_UPDATE_ERR') ;
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );
                        END IF ;

                     -- Else If action has a PROCUREMENT function
                     -- Perform validation related to PROCUREMENT function
                     ELSIF (p_function_code_tbl(i) = g_procurement ) THEN

                        -- 4227845 Added dlvr action due date not null check and populating error message
                        IF p_due_date_tbl(i) IS NULL THEN
                          l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DUE_DATE_ERR') ;
                          PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_ACTION_NAME_ERR',
                                 p_token1         => 'ACTION_NAME',
                                 p_value1         =>  p_name_tbl(i),
                                 p_token2         => 'MESSAGE',
                                 p_value2         =>  l_err_message
                                 );
                        END IF;
                        -- 4227845 end

                        l_proc_initiated := 'N' ;
                        l_ready_to_proc  := 'N' ;

                        -- 3555460 WSH_Initiated_Yn function call was used instead of REQ_Initiated_Yn
                        l_proc_initiated := nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(p_element_version_id_tbl(i)),'N') ;
                        l_ready_to_proc  := nvl(OKE_DELIVERABLE_UTILS_PUB.Ready_To_Procure_Yn(p_element_version_id_tbl(i)),'N') ;

                        -- Validation 4.1
                        IF (l_proc_initiated = 'N' AND
                            nvl(p_completed_flag_tbl(i),'N') = 'Y' )
                        THEN
                              l_err_message := FND_MESSAGE.GET_STRING('PA','PA_SHIP_PROC_COMP_ERR_Y') ;
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );
                        END IF ;

                        -- Validation 4.2
                        -- Bug#3555460
                        -- Commenting the validation as per the latest changes
                        -- in functional design.
                        -- IF (( nvl(p_completed_flag_tbl(i),'N') = 'N'
                        --       AND l_completed_flag = 'Y')
                        --       AND l_proc_initiated = 'Y' )
                        -- THEN
                        --      l_err_message := FND_MESSAGE.GET_STRING('PA','PA_SHIP_PROC_COMP_ERR_N') ;
                        --      PA_UTILS.ADD_MESSAGE
                        --            (p_app_short_name => 'PA',
                        --             p_msg_name       => 'PA_ACTION_NAME_ERR',
                        --             p_token1         => 'ACTION_NAME',
                        --             p_value1         =>  p_name_tbl(i),
                        --             p_token2         => 'MESSAGE',
                        --             p_value2         =>  l_err_message
                        --             );
                        --
                        -- END IF ;
                        --

                        -- Validation 4.3
                        IF ((trunc(p_due_date_tbl(i)) <> trunc(l_due_date)) AND
                            l_ready_to_proc = 'Y' )
                        THEN
                              l_err_message := FND_MESSAGE.GET_STRING('PA','PA_PROC_DUE_DATE_UPDATE_ERR') ;
                              PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_ACTION_NAME_ERR',
                                     p_token1         => 'ACTION_NAME',
                                     p_value1         =>  p_name_tbl(i),
                                     p_token2         => 'MESSAGE',
                                     p_value2         =>  l_err_message
                                     );
                        END IF ;
                     END IF ; -- If p_function_code_tbl(i) = g_billing
                END IF ;  -- If p_user_action_tbl(i) <> g_unmodified
           END LOOP ;
      END IF ;

      x_msg_count := FND_MSG_PUB.count_msg ;
      IF x_msg_count > 0 THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF ;
/* ==============3435905 : FP M : Deliverables Changes For AMG - Start * =========================*/

IF (p_calling_module = 'AMG') THEN

     -- Start Bug 3651563
     --If p_calling_module is 'AMG' then do action name related validation in a special manner
     -- (i.e) In addition to checking for duplicate names among the passed actions
     --need to check for duplicate action  names with the existing actions also

     -- In case of AMG,we can pass new actions as well as action id's which are to be updated .
     -- Not all actions will be passed

     -- Consider this case,An existing actions' name is 'XYZ' (it need not be passed to this API)
     -- But for the new action passed in UPDATE Mode ,the name is 'XYZ' .So,existing code will fail

     -- Same explanation holds good for Shipping Action / Procurement action restricting code also
     -- An existing shipping action might be there and a new shipping action may be passed through AMG
     -- But Check will not happen against existing shipping action

     -- Note : In case of Self Service ,all actions will be passed - all new actions as well as existing actions
     -- So, the existing code will absolutely work fine with out any issues


     IF p_calling_module = 'AMG' THEN
     OPEN c_existing_action ;
         FETCH c_existing_action BULK COLLECT INTO l_name_tbl,l_function_code_tbl,l_proj_element_id_tbl ;
         CLOSE c_existing_action ;

         l_existing_count := nvl(l_name_tbl.LAST,0) ;

         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'No of records already existing are ' || l_existing_count;
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     END IF;

     --End Bug 3651563

     -- Start Bug 3651563
     -- p_proj_element_id_tbl(i) <> l_proj_element_id_tbl(k) This check is needed because
     -- Consider this case
     -- An existing action 'ABC' is passed by AMG (say for some updation of any of its values like duedate)
     -- Now,this cursor will retrieve all existing actions ,so 'ABC' will also get selected
     -- To avoid validation of the action with itself in this scenario
     -- This check is needed

     IF l_existing_count > 0 THEN -- IF some records already exist
          FOR i IN p_name_tbl.FIRST..p_name_tbl.LAST LOOP
               FOR k IN l_name_tbl.FIRST..l_name_tbl.LAST LOOP
                IF ( (nvl(p_name_tbl(i),'X') = nvl(l_name_tbl(k),'Y')) AND
                          p_proj_element_id_tbl(i) <> l_proj_element_id_tbl(k) ) THEN

                          x_return_status := FND_API.G_RET_STS_ERROR ;
                          l_err_message := FND_MESSAGE.GET_STRING('PA','PA_ALL_DUPLICATE_NAME') ;
                           PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_NAME_ERR',
                                p_token1         => 'ACTION_NAME',
                                p_value1         =>  p_name_tbl(i),
                                p_token2         => 'MESSAGE',
                                p_value2         =>  l_err_message
                                );
                    END IF;
               END LOOP ;
          END LOOP;
      END IF;

      --End Bug 3651563


 -- Fetch Deliverable Name and Project Name for tokens
      IF l_debug_mode = 'Y' THEN
         Pa_Debug.WRITE(g_module_name, 'proj id ['||p_project_id||'] dlvr id ['||p_deliverable_id||']',l_debug_level3);
      END IF;

      SELECT element_Number INTO l_deliverable_number
      FROM   pa_Proj_elements
      WHERE  proj_element_id = p_deliverable_id
      AND    project_id  = p_project_id;

      SELECT segment1 INTO   l_project_number
      FROM Pa_Projects_All
      WHERE  project_id = p_project_id;

      IF l_debug_mode = 'Y' THEN
         Pa_Debug.WRITE(g_module_name, 'token values proj ['||l_Project_Number||'] deliverable ['||l_deliverable_Number||']',l_debug_level3);
      END IF;

 -- Validate Carrying Out Org Id - valid value
       IF p_carrying_out_org_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
          l_carrying_out_org_id := NULL;
       ELSE
          l_carrying_out_org_id := p_carrying_out_org_id;
       END IF;

       IF  (l_carrying_out_org_id   IS  NOT NULL ) THEN
          Pa_Hr_Org_Utils.CHECK_ORGNAME_OR_ID
            ( p_organization_id    => l_carrying_out_org_id
             ,p_organization_name  =>  NULL
             ,p_check_id_flag      => 'Y'
         --  ,x_organization_id    => l_carrying_out_org_id
	     ,x_organization_id => l_new_carrying_out_org_id  -- this is added for the bug: 4537865
             ,x_return_status      => x_return_status
             ,x_error_msg_code     => l_msg_data);

           IF l_debug_mode = 'Y' THEN
               Pa_Debug.WRITE(g_module_name,' validating carrying out org ['||l_carrying_out_org_id||']status['||x_return_status||']',  l_debug_level3);
           END IF;
	  -- added for bug: 4537865
          IF x_return_status = FND_API.G_RET_STS_SUCCESS       THEN
          l_carrying_out_org_id := l_new_carrying_out_org_id ;
	  END IF;
          -- added for bug: 4537865

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
              l_err_message := FND_MESSAGE.GET_STRING('PA','ACTION_CARRYING_ORG_INVALID') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTN_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         =>  'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_number,
                                p_token3         => 'MESSAGE',
                                p_value3         =>  l_err_message
                                );
           x_return_status             := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

 -- validate action_owner_id - valid value
    i_act := p_action_owner_id_tbl.first();
    j_act := p_action_owner_id_tbl.first();

    WHILE i_act is not null LOOP

       IF p_action_owner_id_tbl(i_act)  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
          l_action_owner_id := NULL;
       ELSE
          l_action_owner_id := p_action_owner_id_tbl(i_act);
       END IF;

       IF  (l_action_owner_id   IS  NOT NULL ) THEN
          Pa_Tasks_Maint_Utils.CHECK_TASK_MGR_NAME_OR_ID (
          p_task_mgr_name  => null
             ,p_task_mgr_id    => l_action_owner_id
             ,p_project_id     => p_project_id
             ,p_check_id_flag  => 'Y'
             ,p_calling_module => 'AMG'
           -- x_task_mgr_id    => l_action_owner_id  * added for bug 4537865
	     ,x_task_mgr_id    => l_new_action_owner_id
	   -- 					     * added for bug 4537865
             ,x_return_status  => x_return_status
             ,x_error_msg_code => l_msg_data );
          IF l_debug_mode = 'Y' THEN
             Pa_Debug.WRITE(g_module_name,' validated owner id ['||l_action_owner_id||']status['||x_return_status||']' , l_debug_level3);
          END IF;

           -- added for bug 4537865
          IF x_return_status = FND_API.G_RET_STS_SUCCESS       THEN
          l_action_owner_id := l_new_action_owner_id;
          END IF;
           -- added for bug 4537865

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
              l_err_message := FND_MESSAGE.GET_STRING('PA','ACTION_OWNER_INVALID') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_number,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_reference_tbl(i_act),
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );
           x_return_status             := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

 -- validate function code
      IF (p_function_code_tbl(i_act) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          OR p_function_code_tbl(i_act) = NULL )THEN
          l_function_code := NULL;
       ELSE
          l_function_code := p_function_code_tbl(i_act);
       END IF;

       l_function_code_valid := Pa_Deliverable_Utils.Is_Function_Code_Valid(l_function_code);

       IF l_debug_mode = 'Y' THEN
         Pa_Debug.WRITE(g_module_name,'function code '||l_Function_code||'] validity ['||l_function_code_valid||']' , l_debug_level3);
       END IF;

       IF l_function_code_valid IS NULL OR l_function_code_valid = 'N' THEN
          l_err_message := FND_MESSAGE.GET_STRING('PA','ACTION_FUNC_CODE_INVALID') ;
              PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_number,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_reference_tbl(i_act),
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                                );
           x_return_status             := FND_API.G_RET_STS_ERROR;
       END IF;

            --Bug 3651563
            --If p_calling_module is 'AMG' then do function code related validation
        --(i.e) More than one shipping action or more than one procurement action is not allowed
        --Note : In case of Self Service ,it is taken care in the Java Code itself

       WHILE j_act IS NOT NULL LOOP
            IF ( ((p_function_code_tbl(i_act) = 'SHIPPING' AND p_function_code_tbl(j_act) = 'SHIPPING')
                 OR (p_function_code_tbl(i_act) = 'PROCUREMENT' AND p_function_code_tbl(j_act) = 'PROCUREMENT'))
                     AND i_act <> j_act ) THEN
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                                    l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLV_TOO_MANY_ACTIONS');
                                    PA_UTILS.ADD_MESSAGE
                                            (p_app_short_name => 'PA',
                                             p_msg_name       => 'PA_ACTION_VALID_ERR',
                                         p_token1         => 'PROJECT',
                                         p_value1         =>  l_project_number,
                                         p_token2         => 'DLVR_REFERENCE',
                                             p_value2         =>  l_deliverable_number,
                                         p_token3         => 'ACTION_REFERENCE',
                                         p_value3         =>  p_action_reference_tbl(i_act),
                                         p_token4         => 'MESSAGE',
                                         p_value4         =>  l_err_message
                                        );
            END IF ;
            j_act := p_action_owner_id_tbl.next(j_act);
       END LOOP ;

            -- Start of Bug 3651563 - Check with existing actions also
            IF l_existing_count > 0 THEN -- IF some records already exist
                FOR k_act IN l_function_code_tbl.FIRST..l_function_code_tbl.LAST LOOP

                     IF ( ((p_function_code_tbl(i_act) = 'SHIPPING' AND l_function_code_tbl(k_act) = 'SHIPPING')
                          OR (p_function_code_tbl(i_act) = 'PROCUREMENT' AND  l_function_code_tbl(k_act) = 'PROCUREMENT'))
                             AND p_proj_element_id_tbl(i_act) <> l_proj_element_id_tbl(k_act) ) THEN

                          x_return_status := FND_API.G_RET_STS_ERROR;
                          l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLV_TOO_MANY_ACTIONS') ;
                          PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_number,
                p_token3         => 'ACTION_REFERENCE',
                p_value3         =>  p_action_reference_tbl(i_act),
                p_token4         => 'MESSAGE',
                p_value4         =>  l_err_message
                );
                     END IF;
                END LOOP ;
            END IF;

            --End of Bug 3651563

 -- validate financial task id

       i_act := p_action_owner_id_tbl.next(i_act);

    END LOOP; -- WHILE LOOP
END IF ;-- p_calling_module ='AMG'

/* ==============3435905 : FP M : Deliverables Changes For AMG - End * =========================*/

     /* Bug 3651563 Very Important Fix .Please do not add any code after the following statements
     because if some message is there in the error stack
     before exiting this API,x_return_status should be set as 'ERROR'*/

     x_msg_count := FND_MSG_PUB.count_msg ;
     IF x_msg_count > 0 THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF ;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Exiting Validate Actions ';
          pa_debug.write('VALIDATE_ACTIONS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

         IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of VALIDATE_ACTIONS';
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

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'VALIDATE_ACTIONS');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('VALIDATE_ACTIONS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;

END VALIDATE_ACTIONS;


-- SubProgram           : DELETE_DLV_ACTION
-- Type                 : PROCEDURE
-- Purpose              : Public API to Delete Deliverable Actions
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER             N     Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2      N      Standard Parameter
-- p_commit                     IN         VARCHAR2      N      Standard Parameter
-- p_validate_only                 IN          VARCHAR2      N      Standard Parameter
-- p_validation_level             IN           NUMBER             N     Standard Parameter
-- p_calling_module                IN          VARCHAR2      N      Standard Parameter
-- p_debug_mode                    IN          VARCHAR2      N      Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_action_id                     IN          NUMBER            Y        Action Element Id
-- p_action_ver_id                 IN          NUMBER            Y        Action Version Id

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
     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;

     -- 3769024 curstor to retrieve element_version_id of action from proj_element_id
     l_action_id                  NUMBER;

     Cursor c_actn_info IS
     SELECT
            PEV.PROJ_ELEMENT_ID
     FROM
            PA_PROJ_ELEMENT_VERSIONS PEV
     WHERE
            PEV.ELEMENT_VERSION_ID = p_action_ver_id
        AND PEV.OBJECT_TYPE        = 'PA_ACTIONS'
        AND PEV.PROJECT_ID         = p_project_id;

     -- end

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_ACTION',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_ACTIONS ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Printing Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.write(g_module_name,'p_action_id'||':'||p_action_id,3) ;
          pa_debug.write(g_module_name,'p_action_ver_id'||':'||p_action_ver_id,3) ;
          pa_debug.write(g_module_name,'p_dlv_element_id'||':'||p_dlv_element_id,3) ;
          pa_debug.write(g_module_name,'p_dlv_version_id'||':'||p_dlv_version_id,3) ;
          pa_debug.write(g_module_name,'p_function_code'||':'||p_function_code,3) ;
          pa_debug.write(g_module_name,'p_project_id'||':'||p_project_id,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DELETE_DLV_ACTIONS_SP ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- 3769024 , if p_action_id ( i.e proj_element_id ) is null and action element_version id is not null
     -- derive proj_element_id from proj_element_id

     -- proj_element_id will be null in below scenarion : if user has created action and on create action page
     -- user deletes it , proj_element_id passed from java code to plsql api will be null

     IF p_action_id IS NULL AND p_action_ver_id IS NOT NULL THEN
        Open c_actn_info;
        Fetch c_actn_info INTO l_action_id;
        Close c_actn_info;
     ELSE
        l_action_id := p_action_id;
     END IF;

     -- 3769024 end

     -- 3769024 using l_action_id instead of p_action_id , changed from p_action_id to p_action_ver_id
     -- duplicate validation

     IF ((l_action_id IS NULL OR  p_action_ver_id IS NULL ) OR
        (p_dlv_element_id IS NULL OR p_dlv_version_id IS NULL) OR
        (p_function_code IS NULL OR  p_project_id IS NULL ))
     THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'INVALID INPUT PARAMETER';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                             ,p_msg_name         => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     PA_ACTIONS_PVT.DELETE_DLV_ACTION
          (p_api_version      => p_api_version
          ,p_init_msg_list    => p_init_msg_list
          ,p_commit           => p_commit
          ,p_validate_only    => p_validate_only
          ,p_validation_level => p_validation_level
          ,p_calling_module   => p_calling_module
          ,p_debug_mode       => l_debug_mode
          ,p_max_msg_count    => p_max_msg_count
          ,p_action_id        => l_action_id            -- 3769024 using derived value
          ,p_action_ver_id    => p_action_ver_id
          ,p_dlv_element_id   => p_dlv_element_id
          ,p_dlv_version_id   => p_dlv_version_id
          ,p_function_code    => p_function_code
          ,p_project_id       => p_project_id
          ,x_return_status    => x_return_status
          ,x_msg_count        => x_msg_count
          ,x_msg_data         => x_msg_data
          ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting DELETE_DLV_ACTION' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO DELETE_DLV_ACTIONS_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DLV_ACTIONS';
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

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO DELETE_DLV_ACTIONS_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'DELETE_DLV_ACTION');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_ACTION: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_ACTION ;

-- SubProgram           : COPY_ACTIONS
-- Type                 : PROCEDURE
-- Purpose              : Public API to Copy Actions From Source To Destination
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
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE  := null
     ,p_pm_source_reference IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_code      IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_calling_mode        IN VARCHAR2 := NULL -- Added for bug# 3911050
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
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
          PA_DEBUG.set_curr_function( p_function   => 'COPY_ACTIONS',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside COPY_ACTIONS ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Printing Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.write(g_module_name,'p_source_object_id  '||':'||p_source_object_id  ,3) ;
          pa_debug.write(g_module_name,'p_source_object_type'||':'||p_source_object_type,3) ;
          pa_debug.write(g_module_name,'p_target_object_id  '||':'||p_target_object_id  ,3) ;
          pa_debug.write(g_module_name,'p_target_object_type'||':'||p_target_object_type,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint COPY_ACTIONS_SP ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_source_object_id IS NULL OR  p_source_object_type IS NULL
         OR  p_target_object_id IS NULL OR p_target_object_type IS NULL )
     THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'INVALID INPUT PARAMETER';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                             ,p_msg_name         => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     PA_ACTIONS_PVT.COPY_ACTIONS
          (p_api_version         => p_api_version
          ,p_init_msg_list       => p_init_msg_list
          ,p_commit              => p_commit
          ,p_validate_only       => p_validate_only
          ,p_validation_level    => p_validation_level
          ,p_calling_module      => p_calling_module
          ,p_debug_mode          => l_debug_mode
          ,p_max_msg_count       => p_max_msg_count
          ,p_source_object_id    => p_source_object_id
          ,p_source_object_type  => p_source_object_type
          ,p_target_object_id    => p_target_object_id
          ,p_target_object_type  => p_target_object_type
          ,p_source_project_id   => p_source_project_id
          ,p_target_project_id   => p_target_project_id
          ,p_task_id             => p_task_id
          ,p_task_ver_id         => p_task_ver_id
          ,p_carrying_out_organization_id => p_carrying_out_organization_id
          ,p_pm_source_reference => p_pm_source_reference
          ,p_pm_source_code      => p_pm_source_code
          ,p_calling_mode        => p_calling_mode  -- added for bug# 3911050
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
           ) ;


     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting COPY_ACTIONS' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO COPY_ACTIONS_SP;
     END IF ;

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

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO COPY_ACTIONS_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'COPY_ACTIONS');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('COPY_ACTIONS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END COPY_ACTIONS ;

--------------------------------------------------------------------------------
--Name:               is_action_rec_empty_yn
--Type:               Function
--Description:        This function checks if the action record passed is empty
--                    for shipping and procurement actions and ignore other actions
--
--Called subprograms: None
--
--History:
--    05-SEP-2008   SKKOPPUL            Created
--
FUNCTION is_action_rec_empty_yn
    (
          p_action_in_rec          IN  PA_PROJECT_PUB.action_in_rec_type,
          p_function_code          IN  VARCHAR2
    )   RETURN VARCHAR2
IS
BEGIN

     -- common parameters for both shipping and procurement actions
     IF ( p_action_in_rec.action_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_action_in_rec.action_name IS NOT NULL) THEN
        RETURN 'N';
     END IF;
     IF ( p_action_in_rec.financial_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_action_in_rec.financial_task_id IS NOT NULL) THEN
        RETURN 'N';
     END IF;
     IF ( p_action_in_rec.financial_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_action_in_rec.financial_task_reference IS NOT NULL) THEN
        RETURN 'N';
     END IF;
     -- OKE procurement parameters
     IF ( p_function_code = g_procurement) THEN

        IF ( p_action_in_rec.destination_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.destination_type_code IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.po_need_by_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
             AND p_action_in_rec.po_need_by_date IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.receiving_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.receiving_org_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.receiving_location_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.receiving_location_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.vendor_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.vendor_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.vendor_site_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.vendor_site_code IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.quantity <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.quantity IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.uom_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.uom_code IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.unit_price <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.unit_price IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.exchange_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.exchange_rate_type IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.exchange_rate_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
             AND p_action_in_rec.exchange_rate_date IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.exchange_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.exchange_rate IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.expenditure_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.expenditure_type IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.expenditure_item_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
             AND p_action_in_rec.expenditure_item_date IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.expenditure_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.expenditure_org_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.requisition_line_type_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.requisition_line_type_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.category_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.category_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.ready_to_procure_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.ready_to_procure_flag IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.initiate_procure_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.initiate_procure_flag IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        -- OKE procurement parameters

     ELSIF ( p_function_code = g_shipping) THEN

        -- OKE shipping parameters
        IF ( p_action_in_rec.ship_from_organization_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.ship_from_organization_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.ship_from_location_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.ship_from_location_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.ship_to_organization_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.ship_to_organization_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.ship_to_location_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.ship_to_location_id IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.demand_schedule <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.demand_schedule IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.expected_shipment_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
             AND p_action_in_rec.expected_shipment_date IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.promised_shipment_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
             AND p_action_in_rec.promised_shipment_date IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.volume <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.volume IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.volume_uom <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.volume_uom IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.weight <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.weight IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.weight_uom <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.weight_uom IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.ready_to_ship_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.ready_to_ship_flag IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.initiate_planning_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.initiate_planning_flag IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.initiate_shipping_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.initiate_shipping_flag IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.quantity <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND p_action_in_rec.quantity IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        IF ( p_action_in_rec.uom_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND p_action_in_rec.uom_code IS NOT NULL) THEN
           RETURN 'N';
        END IF;
        -- OKE shipping parameters
    ELSE
        -- ignore all other cases
        RETURN 'N';
    END IF;

    RETURN 'Y';

EXCEPTION
    WHEN OTHERS THEN
         RETURN 'N';
END is_action_rec_empty_yn;

-------3435905 : FP M : Deliverables Changes For AMG -Start--------------------
--------------------------------------------------------------------------------
--Name:               Create_Dlvr_Actions_Wrapper
--Type:               Procedure
--Description:        This procedure will be called from AMP api. It validates the
--                    input values and then call the pa_action_pub apis
--
--Called subprograms:   PA_ACTION_PUB.VALIDATE_ACTION
--                      PA_ACTION_PUB.CREATE_DLV_ACTIONS_IN_BULK
--
--
--
--History:
--    08-Mar-2004   Puneet            Created
--

PROCEDURE  Create_Dlvr_Actions_Wrapper
    ( p_api_version            IN NUMBER    :=1.0
    , p_init_msg_list          IN VARCHAR2  :=FND_API.G_TRUE
    , p_commit                 IN VARCHAR2  :=FND_API.G_FALSE
    , p_validate_only          IN VARCHAR2  :=FND_API.G_TRUE
    , p_validation_level       IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
    , p_calling_module         IN VARCHAR2  :='AMG'
    , p_debug_mode             IN VARCHAR2  :='N'
    , p_insert_or_update       IN VARCHAR2 := 'INSERT'
    , p_action_in_tbl          IN  PA_PROJECT_PUB.action_in_tbl_type
    , x_action_out_tbl         OUT NOCOPY PA_PROJECT_PUB.action_out_tbl_type --File.Sql.39 bug 4440895
    , x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    , x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    , x_msg_data               OUT NOCOPY VARCHAR2  ) --File.Sql.39 bug 4440895
IS
     l_action_name_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_action_owner_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_function_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_due_date_tbl           SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_completed_flag_tbl     SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()      ;
     l_completion_date_tbl    SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_element_version_id_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_proj_element_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_rec_ver_num_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_description_tbl        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_user_action_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_pm_source_reference_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;

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

     l_project_id             PA_PROJ_ELEMENTS.PROJECT_ID%TYPE  := NULL                              ;
     l_object_id              PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE := NULL                          ;
     l_object_version_id      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE := NULL               ;
     l_object_type            PA_PROJ_ELEMENTS.OBJECT_TYPE%TYPE := NULL                              ;
     l_pm_source_code         VARCHAR2(30) := NULL                                                   ;
     l_pm_source_reference    VARCHAR2(30) := NULL                                                   ;
-- to be modified     l_pm_source_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
-- to be modified     l_pm_source_reference_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;    -- should be 25 instead of 30
     l_carrying_out_organization_id  PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE := NULL      ;

     -- 3749462 changes for financial top task and lowest chargeable task validation
     l_fin_task_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_fin_task_num_tbl   SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     -- 3749462 end

     i_proc    NUMBER := 0;
     i_ship    NUMBER := 0;
     i_bill    NUMBER := 0;
     i_actn    NUMBER := 0;
     i_none    NUMBER := 0;

     i_ship1   NUMBER := 0;
     i_proc1   NUMBER := 0;

     l_api_name      CONSTANT  VARCHAR2(30)     := 'Create_Dlvr_Actions_Wrapper';

     l_action_out_tbl  PA_PROJECT_PUB.action_out_tbl_type;
     l_dlv_ship_action_tbl   dlv_ship_action_tbl_type;
     l_dlv_req_action_tbl    dlv_req_action_tbl_type;

     l_project_number        pa_projects_all.segment1%TYPE;
     l_deliverable_number    pa_proj_elements.element_number%TYPE;
     l_action_id             pa_proj_elements.proj_element_id%TYPE;
     l_org_id                PA_PROJECTS_ALL.ORG_ID%TYPE;
     l_organization_name     pa_organizations_event_v.name%TYPE;
     l_projfunc_currency_code PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE;
     l_action_owner_id       NUMBER;                                                     /* Bug # 3590235 */
     l_item_dlv              VARCHAR2(1);
     l_action                VARCHAR2(30);
     l_actn_version_id       NUMBER; -- 3651489 added local variable to store action's element_version_id

     l_msg_index_out              NUMBER;
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_err_message fnd_new_messages.message_text%TYPE ;

     Cursor C_vers (p_proj_element_id IN NUMBER) IS
     SELECT   vers.element_version_id
           ,  elem.carrying_out_organization_id
       ,  proj.segment1
       ,  elem.element_Number
       ,  proj.project_id
       ,  Pa_Deliverable_Utils.IS_Dlvr_Item_Based(vers.element_version_id)
     FROM     pa_proj_element_versions vers
           ,  pa_proj_elements elem
       ,  pa_projects_all proj
     WHERE    vers.proj_element_id = elem.proj_element_id
     AND      elem.project_id  = vers.project_id
     AND      elem.proj_element_id  = p_Proj_element_id
     AND      elem.project_id  = proj.project_id
     AND      elem.object_type = 'PA_DELIVERABLES';

     CURSOR C_org_name (p_org_id IN NUMBER) IS
     SELECT name
     FROM pa_organizations_event_v
     WHERE organization_id = P_org_id
     AND TRUNC(SYSDATE) BETWEEN date_from AND nvl(date_to, TRUNC(SYSDATE));

     -- 3651489 added cursor to retrieve actions' element version id
     -- proj element id is passed as argument

     Cursor C_act_ver (p_proj_element_id IN NUMBER) IS
     SELECT   pev.element_version_id
     FROM     pa_proj_element_versions pev
     WHERE    pev.proj_element_id   = p_proj_element_id
     AND      pev.object_type       = 'PA_ACTIONS';

    -- 3749462 changes for financial top task and lowest chargeable task validation

    l_fin_task_id   pa_proj_elements.proj_element_id%TYPE;
    --added for bug: 4537865
    l_new_fin_task_id pa_proj_elements.proj_element_id%TYPE;
    --added for bug: 4537865
    l_fin_task_ref  VARCHAR2(25);


    Cursor is_top_task (project_id NUMBER, fin_task_id NUMBER) IS
       SELECT
              TASK_NUMBER
       FROM
              PA_TASKS
       WHERE
                 PROJECT_ID = project_id
             AND TASK_ID    = TOP_TASK_ID
             AND TASK_ID    = fin_task_id;

    Cursor is_lowest_task (project_id NUMBER, fin_task_id NUMBER) IS
       SELECT
              TASK_NUMBER
       FROM
              PA_TASKS
       WHERE
                 PROJECT_ID      = project_id
             AND TASK_ID         = fin_task_id
             AND CHARGEABLE_FLAG = 'Y';

    -- For Bug 3749447 , Added below local variables and cursor

    l_unique_flag VARCHAR2(1);

    Cursor C_dlvr_type(l_project_id NUMBER, l_deliverable_id NUMBER) IS
       SELECT type_id
       FROM   PA_PROJ_ELEMENTS
       WHERE  proj_element_id = l_deliverable_id
       AND    project_id      = l_project_id
       AND    OBJECT_TYPE     = 'PA_DELIVERABLES';

    l_dlvr_type_id            Pa_Proj_Elements.type_id%TYPE;

    l_dlvr_prg_enabled  VARCHAR2(1) := NULL;
    l_dlvr_action_enabled  VARCHAR2(1) := NULL;
    l_status_code   PA_PROJ_ELEMENTS.STATUS_CODE%TYPE;

    -- end 3749447

    -- 3651542 added local variable for defaulting

    l_default_owner_id      NUMBER;
    l_default_owner_name    PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
    l_default_date          DATE;
    l_earliest_start_date   DATE;
    l_earliest_finish_date  DATE;

    -- bug 7385017 skkoppul
    l_update_oke_yn         VARCHAR2(1) := 'Y';

BEGIN

    IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT create_dlvr_actions_wrapper;
    END IF;
--  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number  ,
                               p_api_version  ,
                               l_api_name         ,
                               G_PKG_NAME       )
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--  Initialize the message table if requested.
    IF FND_API.TO_BOOLEAN( p_init_msg_list )   THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => l_api_name,
                                      p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside '||l_api_name;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
    END IF;

--  Set API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--  OKE apis expect CREATE instead of INSERT. Initializing local variable
--  l_action based on value of p_insert_or_update

    IF (p_insert_or_update = g_insert) THEN
       l_action := g_create;
    ELSE
       l_action := p_insert_or_update;
    END IF;

    i_actn := p_action_in_tbl.first();

    WHILE i_actn IS NOT NULL LOOP

   /* Bug # 3590235 : Added a condition to check null value for action_owner_id */

        IF ( p_action_in_tbl(i_actn).action_owner_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
            p_action_in_tbl(i_actn).action_owner_id IS NULL) THEN
              l_action_owner_id := null;
        ELSE
              l_action_owner_id := p_action_in_tbl(i_actn).action_owner_id ;
        END IF;

        IF ( i_actn = p_action_in_tbl.first()) THEN
           l_object_id                    :=  p_action_in_tbl(i_actn).deliverable_id     ;
           l_object_type                  :=  g_deliverables                             ;
           l_pm_source_code               :=  nvl(p_action_in_tbl(i_actn).pm_source_code,'MSPROJECT')     ;

           -- Getting the project /deliverable related information
           Open C_vers (l_object_id);
           Fetch C_vers INTO l_object_version_id, l_carrying_out_organization_id,
                             l_project_number, l_deliverable_number, l_project_id, l_item_dlv;
           Close C_vers;

           Pa_Deliverable_Utils.Get_Project_Details    (
                      p_project_id                   =>  l_project_id
                     ,x_projfunc_currency_code       =>  l_projfunc_currency_code
                     ,x_org_id                       =>  l_org_id
                     );


           IF p_debug_mode = 'Y' THEN
              pa_debug.write(g_module_name,'Entering the loop fetched values obj id ['||l_object_id||']vers id['||l_object_version_id||']',3) ;
              pa_debug.write(g_module_name,'carry out org id ['||l_carrying_out_organization_id||']proj num['|| l_project_number||']dlvr num['||l_deliverable_number||']',3) ;
              pa_debug.write(g_module_name,'org id ['||l_org_id||']PFC['|| l_projfunc_currency_code||']item dlv['||l_item_dlv||']',3) ;
           END IF;

           -- 3651542 Added below code to retrieve default owner and date in create mode
           -- Assumption : defaulting will done for 'PROJECT' only , for AMG task flow is not
           -- considered , Also, this will be in case of project , not the template

           -- because of above assumption, passing task ver id null
           -- l_earliest_start_date and l_earliest_finish_date will be null

           -- retrieve only once, i.e. this call will be made for only first action

            IF (l_action = g_create) THEN
                PA_DELIVERABLE_UTILS.GET_DEFAULT_ACTN_DATE
                    (
                          p_dlvr_ver_id             =>  l_object_version_id
                         ,p_task_ver_id             =>  NULL
                         ,p_project_mode            =>  'PROJECT'
                         ,x_due_date                =>  l_default_date
                         ,x_earliest_start_date     =>  l_earliest_start_date
                         ,x_earliest_finish_date    =>  l_earliest_finish_date
                     );

                PA_DELIVERABLE_UTILS.GET_DEFAULT_ACTION_OWNER
                    (
                         p_dlvr_ver_id              =>  l_object_version_id
                        ,x_owner_id                 =>  l_default_owner_id
                        ,x_owner_name               =>  l_default_owner_name
                    );
            END IF;

            -- 3651542 end
        END IF;

        -- 3749447 Start
        -- If this api is called for creating actions, do below validation
        --      1. for deliverable, action is enabled
        --      2. for deliverable, action reference is unique
        --      3. action name is valid , i.e not null and not '^'

        IF l_action = g_create THEN

           OPEN C_dlvr_type(l_project_id,l_object_id);
           FETCH C_dlvr_Type INTO l_dlvr_type_id;
           CLOSE  C_dlvr_type;

           -- Will create actions only when deliverable type of deliverable
           -- has action creation enabled.

           Pa_Deliverable_Utils.GET_DLVR_TYPE_INFO
           (
               p_dlvr_type_id                 =>  l_dlvr_type_id
              ,x_dlvr_prg_enabled             =>  l_dlvr_prg_enabled
              ,x_dlvr_action_enabled          =>  l_dlvr_action_enabled
              ,x_dlvr_default_status_code     =>  l_status_code
            );

           IF (l_dlvr_action_enabled <> 'Y') THEN

               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_ACTION_NOT_ENABLED') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_number,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_in_tbl(i_actn).pm_action_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );
               END IF;

               x_return_status             := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;

           END IF;

            -- Validate Action reference - not null, unique
            pa_deliverable_utils.is_action_reference_unique (
                 p_action_reference      => p_action_in_tbl(i_actn).pm_action_reference
               , p_deliverable_id        => l_object_id
               , p_project_id            => l_project_id
               , x_unique_flag           => l_unique_flag
               , x_return_status         => x_return_status
               );

            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF p_action_in_tbl(i_actn).action_name IS NULL OR p_action_in_tbl(i_actn).action_name =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_ACTION_NAME_NULL_ERROR') ;
                  PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_ACTION_VALID_ERR',
                                p_token1         => 'PROJECT',
                                p_value1         =>  l_project_number,
                                p_token2         => 'DLVR_REFERENCE',
                                p_value2         =>  l_deliverable_number,
                                p_token3         => 'ACTION_REFERENCE',
                                p_value3         =>  p_action_in_tbl(i_actn).pm_action_reference,
                                p_token4         => 'MESSAGE',
                                p_value4         =>  l_err_message
                               );

               END IF;
               x_return_status             := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;

            END IF;

        END IF;

        -- end 3749447

  --  Populating the action PLSQL table

        l_action_name_tbl.extend;
        l_action_owner_id_tbl.extend;
        l_function_code_tbl.extend;
        l_due_date_tbl.extend;
        l_completed_flag_tbl.extend;
        l_completion_date_tbl.extend;
        l_element_version_id_tbl.extend;
        l_proj_element_id_tbl.extend;
        l_rec_ver_num_id_tbl.extend;
        l_description_tbl.extend;
        l_user_action_tbl.extend;
        l_pm_source_reference_tbl.extend;

        l_attribute_category_tbl.extend;
        l_attribute1_tbl.extend        ;
        l_attribute2_tbl.extend        ;
        l_attribute3_tbl.extend        ;
        l_attribute4_tbl.extend        ;
        l_attribute5_tbl.extend        ;
        l_attribute6_tbl.extend        ;
        l_attribute7_tbl.extend        ;
        l_attribute8_tbl.extend        ;
        l_attribute9_tbl.extend        ;
        l_attribute10_tbl.extend       ;
        l_attribute11_tbl.extend       ;
        l_attribute12_tbl.extend       ;
        l_attribute13_tbl.extend       ;
        l_attribute14_tbl.extend       ;
        l_attribute15_tbl.extend       ;

        -- 3749462 changes for financial top task and lowest chargeable task validation
        l_fin_task_id_tbl.extend       ;
        l_fin_task_num_tbl.extend     ;

-- to be modified        l_pm_source_code_tbl(i_actn)        :=  p_action_in_tbl(i_actn).pm_source_code      ;
-- to be modified       l_pm_source_reference_tbl(i_actn)   :=  p_action_in_tbl(i_actn).pm_source_reference ;

-- Changed the direct initialization of local variables to select statement as values would differ in case of update or create bug 3651139
        IF (l_action = g_create) THEN
           SELECT
               decode(p_action_in_tbl(i_actn).action_name        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).action_name         )
             , l_action_owner_id
             , decode(p_action_in_tbl(i_actn).function_code      ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).function_code       )
             , decode(p_action_in_tbl(i_actn).due_date           ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE , null, p_action_in_tbl(i_actn).due_date            )
             , NULL                               --l_completed_flag
             , NULL                               --l_completion_date
             , NULL                               --l_element_version_id
             , NULL                               --l_proj_element_id
             , 1                                  --l_rec_ver_num_id
             , decode(p_action_in_tbl(i_actn).description        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).description         )
             , p_insert_or_update
             , decode(p_action_in_tbl(i_actn).pm_action_reference,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).pm_action_reference )
             , NULL               --l_attribute_category
             , NULL               --l_attribute1
             , NULL               --l_attribute2
             , NULL               --l_attribute3
             , NULL               --l_attribute4
             , NULL               --l_attribute5
             , NULL               --l_attribute6
             , NULL               --l_attribute7
             , NULL               --l_attribute8
             , NULL               --l_attribute9
             , NULL               --l_attribute10
             , NULL               --l_attribute11
             , NULL               --l_attribute12
             , NULL               --l_attribute13
             , NULL               --l_attribute14
             , NULL               --l_attribute15
           INTO
               l_action_name_tbl(i_actn)
             , l_action_owner_id_tbl(i_actn)
             , l_function_code_tbl(i_actn)
             , l_due_date_tbl(i_actn)
             , l_completed_flag_tbl(i_actn)
             , l_completion_date_tbl(i_actn)
             , l_element_version_id_tbl(i_actn)
             , l_proj_element_id_tbl(i_actn)
             , l_rec_ver_num_id_tbl(i_actn)
             , l_description_tbl(i_actn)
             , l_user_action_tbl(i_actn)
             , l_pm_source_reference_tbl(i_actn)
             , l_attribute_category_tbl(i_actn)
             , l_attribute1_tbl(i_actn)
             , l_attribute2_tbl(i_actn)
             , l_attribute3_tbl(i_actn)
             , l_attribute4_tbl(i_actn)
             , l_attribute5_tbl(i_actn)
             , l_attribute6_tbl(i_actn)
             , l_attribute7_tbl(i_actn)
             , l_attribute8_tbl(i_actn)
             , l_attribute9_tbl(i_actn)
             , l_attribute10_tbl(i_actn)
             , l_attribute11_tbl(i_actn)
             , l_attribute12_tbl(i_actn)
             , l_attribute13_tbl(i_actn)
             , l_attribute14_tbl(i_actn)
             , l_attribute15_tbl(i_actn)
          FROM DUAL;
        ELSE    -- UPDATE
           SELECT
               decode(p_action_in_tbl(i_actn).action_name        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , element_name     , p_action_in_tbl(i_actn).action_name         )
             , decode(p_action_in_tbl(i_actn).action_owner_id    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , manager_person_id, p_action_in_tbl(i_actn).action_owner_id     )
             , decode(p_action_in_tbl(i_actn).function_code      ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , function_code    , p_action_in_tbl(i_actn).function_code       )
             , decode(p_action_in_tbl(i_actn).due_date           ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE , due_date         , p_action_in_tbl(i_actn).due_date            )
             , decode(action_status_code , 'DLVR_COMPLETED', 'Y', 'N')                             --l_completed_flag
             , decode(p_action_in_tbl(i_actn).completion_date    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE , actual_finish_date, p_action_in_tbl(i_actn).completion_date     ) -- for bug# 3749462-- earlier passed as NULL      --l_completion_date
             , element_version_id
             , proj_element_id
             , NULL                               --l_rec_ver_num_id
             , decode(p_action_in_tbl(i_actn).description        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , description, p_action_in_tbl(i_actn).description         )
             -- 3729250 removed p_insert_or_update passing , for update expected value is 'MODIFIED'
             -- because CR_UP_DLV_ACTIONS_IN_BULK procedure is expecting this value to be 'MODIFIED' , not 'UPDATE'
             , g_modified
             , decode(p_action_in_tbl(i_actn).pm_action_reference,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).pm_action_reference )
             , attribute_category
             , attribute1
             , attribute2
             , attribute3
             , attribute4
             , attribute5
             , attribute6
             , attribute7
             , attribute8
             , attribute9
             , attribute10
             , attribute11
             , attribute12
             , attribute13
             , attribute14
             , attribute15
           INTO
               l_action_name_tbl(i_actn)
             , l_action_owner_id_tbl(i_actn)
             , l_function_code_tbl(i_actn)
             , l_due_date_tbl(i_actn)
             , l_completed_flag_tbl(i_actn)
             , l_completion_date_tbl(i_actn)
             , l_element_version_id_tbl(i_actn)
             , l_proj_element_id_tbl(i_actn)
             , l_rec_ver_num_id_tbl(i_actn)
             , l_description_tbl(i_actn)
             , l_user_action_tbl(i_actn)
             , l_pm_source_reference_tbl(i_actn)
             , l_attribute_category_tbl(i_actn)
             , l_attribute1_tbl(i_actn)
             , l_attribute2_tbl(i_actn)
             , l_attribute3_tbl(i_actn)
             , l_attribute4_tbl(i_actn)
             , l_attribute5_tbl(i_actn)
             , l_attribute6_tbl(i_actn)
             , l_attribute7_tbl(i_actn)
             , l_attribute8_tbl(i_actn)
             , l_attribute9_tbl(i_actn)
             , l_attribute10_tbl(i_actn)
             , l_attribute11_tbl(i_actn)
             , l_attribute12_tbl(i_actn)
             , l_attribute13_tbl(i_actn)
             , l_attribute14_tbl(i_actn)
             , l_attribute15_tbl(i_actn)
          FROM pa_dlvr_actions_V
          where proj_element_id = p_action_in_tbl(i_actn).action_id;
        END IF; -- l_action= g_create

        -- 3651542  if create mode , check action_owner_id and due_date is not passed
        -- set default owner id and due date to local variable

        IF (l_action = g_create) THEN
            IF p_action_in_tbl(i_actn).action_owner_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                l_action_owner_id_tbl(i_actn) := l_default_owner_id;
            END IF;

            IF p_action_in_tbl(i_actn).due_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                l_due_date_tbl(i_actn) := l_default_date;
            END IF;
        END IF;

        -- 3749462 changes for financial top task and lowest chargeable task validation

        l_fin_task_id   := NULL;
        l_fin_task_ref  := NULL;

        -- if passed financial task id or reference is not passed , set it to null

        IF ( p_action_in_tbl(i_actn).financial_task_id IS NOT NULL AND p_action_in_tbl(i_actn).financial_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN
            l_fin_task_id   := p_action_in_tbl(i_actn).financial_task_id;
        END IF;

        IF ( p_action_in_tbl(i_actn).financial_task_reference IS NOT NULL AND p_action_in_tbl(i_actn).financial_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN
            l_fin_task_ref  := p_action_in_tbl(i_actn).financial_task_reference;
        END IF;

        -- if task reference / id is passed , validate passed reference with id
        -- if only reference is passed, retrieve id

        IF ( l_fin_task_id IS NOT NULL OR l_fin_task_ref IS NOT NULL ) THEN

            PA_PROJECT_PVT.Convert_pm_taskref_to_id_all (
                       p_pa_project_id      => l_project_id
                     , p_structure_type     => 'FINANCIAL'
                     , p_pa_task_id         => l_fin_task_id
                     , p_pm_task_reference  => l_fin_task_ref
                  -- , p_out_task_id        => l_fin_task_id     * added for bug: 4537865
		     , p_out_task_id	    => l_new_fin_task_id
		  --                                             * added for bug: 4537865
                     , p_return_status      => x_return_status );

	    --added for bug: 4537865
            IF x_return_status = FND_API.G_RET_STS_SUCCESS	 THEN
	    l_fin_task_id := l_new_fin_task_id;
            END IF;
            --added for bug: 4537865

            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
                  RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF l_function_code_tbl(i_actn) IN ( 'SHIPPING' , 'PROCUREMENT') THEN

                -- For Procurement / Shipping action , validate passed financial task should be lowest chargeable task

                Open is_lowest_task (l_project_id,l_fin_task_id);
                Fetch is_lowest_task INTO l_fin_task_num_tbl(i_actn);

                IF is_lowest_task%NOTFOUND THEN
                     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLVR_INVALID_LOW_FIN_TASK') ;
                       PA_UTILS.ADD_MESSAGE
                                   (p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_ACTION_VALID_ERR',
                                    p_token1         => 'PROJECT',
                                    p_value1         =>  l_project_number,
                                    p_token2         => 'DLVR_REFERENCE',
                                    p_value2         =>  l_deliverable_number,
                                    p_token3         => 'ACTION_REFERENCE',
                                    p_value3         =>  l_pm_source_reference_tbl(i_actn),
                                    p_token4         => 'MESSAGE',
                                    p_value4         =>  l_err_message
                                   );

                    END IF;
                    x_return_status             := FND_API.G_RET_STS_ERROR;

                    RAISE FND_API.G_EXC_ERROR;
                ELSE
                    l_fin_task_id_tbl(i_actn)   := l_fin_task_id;
                END IF;

                Close is_lowest_task;

            ELSIF l_function_code_tbl(i_actn) IN ( 'BILLING') THEN

                -- For Billing action , validate passed financial task should be top financial task

                Open is_top_task (l_project_id,l_fin_task_id);
                Fetch is_top_task INTO l_fin_task_num_tbl(i_actn);

                IF is_top_task%NOTFOUND THEN
                     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLVR_INVALID_TOP_FIN_TASK') ;
                       PA_UTILS.ADD_MESSAGE
                                   (p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_ACTION_VALID_ERR',
                                    p_token1         => 'PROJECT',
                                    p_value1         =>  l_project_number,
                                    p_token2         => 'DLVR_REFERENCE',
                                    p_value2         =>  l_deliverable_number,
                                    p_token3         => 'ACTION_REFERENCE',
                                    p_value3         =>  l_pm_source_reference_tbl(i_actn),
                                    p_token4         => 'MESSAGE',
                                    p_value4         =>  l_err_message
                                   );

                    END IF;
                    x_return_status             := FND_API.G_RET_STS_ERROR;

                    RAISE FND_API.G_EXC_ERROR;
                ELSE
                    l_fin_task_id_tbl(i_actn)   := l_fin_task_id;
                END IF;

                Close is_top_task;

            END IF;
        ELSE
            l_fin_task_num_tbl(i_actn) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
        END IF;

        -- for bug# 3749462
        -- create mode, completion date is null and comleted flag will become 'N'
        -- update mode, if comp date is passed, make completed flag 'Y'
        -- update mode, if action is complte and comp date is not passed, completed flag will retain value from the db

        IF l_completion_date_tbl(i_actn) IS NOT NULL THEN
            l_completed_flag_tbl(i_actn) := 'Y';
        END IF;

        i_actn := p_action_in_tbl.next(i_actn);

    END LOOP;

    IF p_debug_mode = 'Y' THEN
        pa_debug.write(g_module_name,'Populated action PLSQL table, calling api for bulk insert',3) ;
    END IF;

  --  Invoke the API to create dlvr actions in bulk.

    Pa_Actions_Pub.CR_UP_DLV_ACTIONS_IN_BULK (
        p_init_msg_list                 =>  p_init_msg_list
       ,p_commit                        =>  p_commit
       ,p_validate_only                 =>  FND_API.G_FALSE
       ,p_validation_level              =>  FND_API.G_VALID_LEVEL_FULL
       ,p_calling_module                =>  'AMG'
       ,p_debug_mode                    =>  p_debug_mode
       ,p_max_msg_count                 =>  NULL
       ,p_name_tbl                      =>  l_action_name_tbl
       ,p_manager_person_id_tbl         =>  l_action_owner_id_tbl
       ,p_function_code_tbl             =>  l_function_code_tbl
       ,p_due_date_tbl                  =>  l_due_date_tbl
       ,p_completed_flag_tbl            =>  l_completed_flag_tbl
       ,p_completion_date_tbl           =>  l_completion_date_tbl
       ,p_description_tbl               =>  l_description_tbl
       ,p_element_version_id_tbl        =>  l_element_version_id_tbl
       ,p_proj_element_id_tbl           =>  l_proj_element_id_tbl
       ,p_user_action_tbl               =>  l_user_action_tbl
       ,p_record_version_number_tbl     =>  l_rec_ver_num_id_tbl
       ,p_attribute_category_tbl        =>  l_attribute_category_tbl
       ,p_attribute1_tbl                =>  l_attribute1_tbl
       ,p_attribute2_tbl                =>  l_attribute2_tbl
       ,p_attribute3_tbl                =>  l_attribute3_tbl
       ,p_attribute4_tbl                =>  l_attribute4_tbl
       ,p_attribute5_tbl                =>  l_attribute5_tbl
       ,p_attribute6_tbl                =>  l_attribute6_tbl
       ,p_attribute7_tbl                =>  l_attribute7_tbl
       ,p_attribute8_tbl                =>  l_attribute8_tbl
       ,p_attribute9_tbl                =>  l_attribute9_tbl
       ,p_attribute10_tbl               =>  l_attribute10_tbl
       ,p_attribute11_tbl               =>  l_attribute11_tbl
       ,p_attribute12_tbl               =>  l_attribute12_tbl
       ,p_attribute13_tbl               =>  l_attribute13_tbl
       ,p_attribute14_tbl               =>  l_attribute14_tbl
       ,p_attribute15_tbl               =>  l_attribute15_tbl
       ,p_project_id                    =>  l_project_id
       ,p_object_id                     =>  l_object_id
       ,p_object_version_id             =>  l_object_version_id
       ,p_object_type                   =>  l_object_type
       ,p_pm_source_code                =>  l_pm_source_code
       ,p_pm_source_reference           =>  l_pm_source_reference
       ,p_pm_source_reference_tbl       =>  l_pm_source_reference_tbl
       ,p_carrying_out_organization_id  =>  l_carrying_out_organization_id
       ,p_insert_or_update              =>  p_insert_or_update
       ,x_return_status                 =>  x_return_status
       ,x_msg_count                     =>  x_msg_count
       ,x_msg_data                      =>  x_msg_data);

     IF  p_debug_mode = 'Y' THEN
           pa_debug.write(g_module_name,'Returned from Pa_Actions_Pub.CR_UP_DLV_ACTIONS_IN_BULK ['||x_return_status||']',5);
     END IF;

     IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE  FND_API.G_EXC_ERROR;
     END IF;

  -- After successfull creation of actions, looping the action-in table and populating
  -- OKE and Billing PLSQL tables

     i_actn := p_action_in_tbl.first();

     WHILE i_actn IS NOT NULL LOOP

        -- bug 7385017 skkoppul - default it to 'Y' as we are looping through
        l_update_oke_yn := 'Y';

-- Derive the action_id based on action reference in case of INSERT only.
-- It is not required in case of UPDATE as action id will be passed as in parameter.

        IF (p_insert_or_update = 'INSERT') THEN

            Pa_Deliverable_Utils.Convert_pm_actionref_to_id
               (
                    p_action_reference  =>  p_action_in_tbl(i_actn).pm_action_reference
                   ,p_action_id         =>  null
                   ,p_deliverable_id    =>  l_object_id
                   ,p_project_id        =>  l_Project_id
                   ,p_out_action_id     =>  l_action_id
                   ,p_return_status     =>  x_return_status
               );

        ELSE -- p_insert_or_update = 'INSERT'

            -- bug 7385017 skkoppul - if action record is empty,
            -- OKE_AMG_GRP.manage_dlv_action should not be called so update the flag
            IF is_action_rec_empty_yn(p_action_in_tbl(i_actn),l_function_code_tbl(i_actn)) = 'Y' THEN
               l_update_oke_yn := 'N';
            END IF;

            l_action_id := p_action_in_tbl(i_actn).action_id;

        END IF; --p_insert_or_update = 'INSERT'

        IF  p_debug_mode = 'Y' THEN
           pa_debug.write(g_module_name,'Derived action id ['||l_action_id||']for reference['||p_action_in_tbl(i_actn).pm_action_reference||
                      ']status['||x_return_status||']',5);
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF  p_debug_mode = 'Y' THEN
           pa_debug.write(g_module_name,'Should we update OKE attributes? '||l_update_oke_yn);
        END IF;

        -- bug 7385017 skkoppul - Update only in case of changes to OKE attributes
        -- Bug 7759051 - l_update_oke_yn should demarcate the code only for OKE procurement and shipping and *not* billing action
        -- IF l_update_oke_yn = 'Y' THEN

           -- 3651489 retrieving action's element version id

           Open C_act_ver (l_action_id);
           Fetch C_act_ver INTO l_actn_version_id;
           Close C_act_ver;

  --  Populating the OKE Procurement PLSQL table

        -- 3729250, In update mode, if function is not passed, p_action_in_tbl(i_actn).function_code value is G_PA_MISS_CHAR
        -- and so below condition was failing and oke data was not getting updated
        -- changed from p_action_in_tbl(i_actn).function_code to l_function_code_tbl(i_actn)
        IF ( l_function_code_tbl(i_actn) = g_procurement) THEN

        IF l_update_oke_yn = 'Y' THEN -- Bug 7759051 (For OKE Procurement)

           i_proc := i_proc + 1;

           IF (l_action = g_create) THEN   -- added IF condition and else part of the code bug 3651139
              SELECT l_object_version_id
                 ,  l_actn_version_id     -- 3651489 changed from l_action_id to l_actn_version_id, as element version id should be passed to oke
                 ,  decode(p_action_in_tbl(i_actn).action_name               ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).action_name               )
                 ,  decode(l_fin_task_id_tbl(i_actn)                         ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, l_fin_task_id_tbl(i_actn)                         ) -- for bug# 3749462
                 ,  decode(p_action_in_tbl(i_actn).destination_type_code     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).destination_type_code     )
                 ,  decode(p_action_in_tbl(i_actn).receiving_org_id          ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).receiving_org_id          )
                 ,  decode(p_action_in_tbl(i_actn).receiving_location_id     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).receiving_location_id     )
                 -- 3729250 , po_need_by_date should be populated with procurement action due date
                 -- 3749462 changed from po_need_by_date to p_action_in_tbl(i_actn).due_date
                 ,  l_due_date_tbl(i_actn) --  3651542 Using local variable , if defaulting is done p_action_in_tbl(i_actn).due_date will not reflect it
                 ,  decode(p_action_in_tbl(i_actn).vendor_id                 ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).vendor_id                 )
                 ,  decode(p_action_in_tbl(i_actn).vendor_site_code          ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).vendor_site_code          )
                 ,  decode(p_action_in_tbl(i_actn).quantity                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).quantity                  )
                 ,  decode(p_action_in_tbl(i_actn).unit_price                ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).unit_price                )
                 ,  decode(p_action_in_tbl(i_actn).exchange_rate_type        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).exchange_rate_type        )
                 ,  decode(p_action_in_tbl(i_actn).exchange_rate_date        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE , null, p_action_in_tbl(i_actn).exchange_rate_date        )
                 ,  decode(p_action_in_tbl(i_actn).exchange_rate             ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).exchange_rate             )
                 ,  decode(p_action_in_tbl(i_actn).expenditure_type          ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).expenditure_type          )
                 ,  decode(p_action_in_tbl(i_actn).expenditure_org_id        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).expenditure_org_id        )
                 ,  decode(p_action_in_tbl(i_actn).expenditure_item_date     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE , null, p_action_in_tbl(i_actn).expenditure_item_date     )
                 ,  decode(p_action_in_tbl(i_actn).requisition_line_type_id  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).requisition_line_type_id  )
                 ,  decode(p_action_in_tbl(i_actn).category_id               ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).category_id               )
                 ,  decode(p_action_in_tbl(i_actn).ready_to_procure_flag     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).ready_to_procure_flag     )
                 ,  decode(p_action_in_tbl(i_actn).initiate_procure_flag     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).initiate_procure_flag     )
                 ,  decode(p_action_in_tbl(i_actn).uom_code                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).uom_code                  )
                 ,  decode(p_action_in_tbl(i_actn).currency                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).currency                  )
             INTO
                    l_dlv_req_action_tbl(i_proc).pa_deliverable_id
                 ,  l_dlv_req_action_tbl(i_proc).pa_action_id
                 ,  l_dlv_req_action_tbl(i_proc).action_name
                 ,  l_dlv_req_action_tbl(i_proc).proc_finnancial_task_id
                 ,  l_dlv_req_action_tbl(i_proc).destination_type_code
                 ,  l_dlv_req_action_tbl(i_proc).receiving_org_id
                 ,  l_dlv_req_action_tbl(i_proc).receiving_location_id
                 ,  l_dlv_req_action_tbl(i_proc).po_need_by_date
                 ,  l_dlv_req_action_tbl(i_proc).vendor_id
                 ,  l_dlv_req_action_tbl(i_proc).vendor_site_id
                 ,  l_dlv_req_action_tbl(i_proc).quantity
                 ,  l_dlv_req_action_tbl(i_proc).unit_price
                 ,  l_dlv_req_action_tbl(i_proc).exchange_rate_type
                 ,  l_dlv_req_action_tbl(i_proc).exchange_rate_date
                 ,  l_dlv_req_action_tbl(i_proc).exchange_rate
                 ,  l_dlv_req_action_tbl(i_proc).expenditure_type
                 ,  l_dlv_req_action_tbl(i_proc).expenditure_org_id
                 ,  l_dlv_req_action_tbl(i_proc).expenditure_item_date
                 ,  l_dlv_req_action_tbl(i_proc).requisition_line_type_id
                 ,  l_dlv_req_action_tbl(i_proc).category_id
                 ,  l_dlv_req_action_tbl(i_proc).ready_to_procure_flag
                 ,  l_dlv_req_action_tbl(i_proc).initiate_procure_flag
                 ,  l_dlv_req_action_tbl(i_proc).uom_code
                 ,  l_dlv_req_action_tbl(i_proc).currency
                 FROM DUAL;

           ELSE    -- UPDATE

              SELECT l_object_version_id
                 ,  l_actn_version_id     -- 3651489 changed from l_action_id to l_actn_version_id, as element version id should be passed to oke
                 ,  decode(p_action_in_tbl(i_actn).action_name               ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , action_name           , p_action_in_tbl(i_actn).action_name               )
                 ,  decode(l_fin_task_id_tbl(i_actn)                         ,NULL                                  , task_id               , l_fin_task_id_tbl(i_actn)                         ) -- for bug# 3749462
                 ,  decode(p_action_in_tbl(i_actn).destination_type_code     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , destination_type_code , p_action_in_tbl(i_actn).destination_type_code     )
                 ,  decode(p_action_in_tbl(i_actn).receiving_org_id          ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , ship_to_org_id        , p_action_in_tbl(i_actn).receiving_org_id          )
                 ,  decode(p_action_in_tbl(i_actn).receiving_location_id     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , ship_to_location_id   , p_action_in_tbl(i_actn).receiving_location_id     )
                 -- 3729250 , po_need_by_date should be populated with procurement action due date
                 -- 3749462 changed from po_need_by_date to l_due_date_tbl(i_actn)
                 ,  l_due_date_tbl(i_actn)
                 ,  decode(p_action_in_tbl(i_actn).vendor_id                 ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , ship_from_org_id      , p_action_in_tbl(i_actn).vendor_id                 )
                 ,  decode(p_action_in_tbl(i_actn).vendor_site_code          ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , ship_from_location_id , p_action_in_tbl(i_actn).vendor_site_code          )
                 ,  decode(p_action_in_tbl(i_actn).quantity                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , quantity              , p_action_in_tbl(i_actn).quantity                  )
                 ,  decode(p_action_in_tbl(i_actn).unit_price                ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , unit_price            , p_action_in_tbl(i_actn).unit_price                )
                 ,  decode(p_action_in_tbl(i_actn).exchange_rate_type        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , rate_type             , p_action_in_tbl(i_actn).exchange_rate_type        )
                 ,  decode(p_action_in_tbl(i_actn).exchange_rate_date        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE , rate_date             , p_action_in_tbl(i_actn).exchange_rate_date        )
                 ,  decode(p_action_in_tbl(i_actn).exchange_rate             ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , exchange_rate         , p_action_in_tbl(i_actn).exchange_rate             )
                 ,  decode(p_action_in_tbl(i_actn).expenditure_type          ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , expenditure_type      , p_action_in_tbl(i_actn).expenditure_type          )
                 ,  decode(p_action_in_tbl(i_actn).expenditure_org_id        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , expenditure_organization_id, p_action_in_tbl(i_actn).expenditure_org_id        )
                 ,  decode(p_action_in_tbl(i_actn).expenditure_item_date     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE , expenditure_item_date , p_action_in_tbl(i_actn).expenditure_item_date     )
                 ,  decode(p_action_in_tbl(i_actn).requisition_line_type_id  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , requisition_line_type_id, p_action_in_tbl(i_actn).requisition_line_type_id  )
                 ,  decode(p_action_in_tbl(i_actn).category_id               ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , po_category_id        , p_action_in_tbl(i_actn).category_id               )
                 ,  decode(p_action_in_tbl(i_actn).ready_to_procure_flag     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null                  , p_action_in_tbl(i_actn).ready_to_procure_flag     )
                 ,  decode(p_action_in_tbl(i_actn).initiate_procure_flag     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null                  , p_action_in_tbl(i_actn).initiate_procure_flag     )
                 ,  decode(p_action_in_tbl(i_actn).uom_code                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , uom_code              , p_action_in_tbl(i_actn).uom_code                  )
                 ,  decode(p_action_in_tbl(i_actn).currency                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , currency_code         , p_action_in_tbl(i_actn).currency                  )
             INTO
                    l_dlv_req_action_tbl(i_proc).pa_deliverable_id
                 ,  l_dlv_req_action_tbl(i_proc).pa_action_id
                 ,  l_dlv_req_action_tbl(i_proc).action_name
                 ,  l_dlv_req_action_tbl(i_proc).proc_finnancial_task_id
                 ,  l_dlv_req_action_tbl(i_proc).destination_type_code
                 ,  l_dlv_req_action_tbl(i_proc).receiving_org_id
                 ,  l_dlv_req_action_tbl(i_proc).receiving_location_id
                 ,  l_dlv_req_action_tbl(i_proc).po_need_by_date
                 ,  l_dlv_req_action_tbl(i_proc).vendor_id
                 ,  l_dlv_req_action_tbl(i_proc).vendor_site_id
                 ,  l_dlv_req_action_tbl(i_proc).quantity
                 ,  l_dlv_req_action_tbl(i_proc).unit_price
                 ,  l_dlv_req_action_tbl(i_proc).exchange_rate_type
                 ,  l_dlv_req_action_tbl(i_proc).exchange_rate_date
                 ,  l_dlv_req_action_tbl(i_proc).exchange_rate
                 ,  l_dlv_req_action_tbl(i_proc).expenditure_type
                 ,  l_dlv_req_action_tbl(i_proc).expenditure_org_id
                 ,  l_dlv_req_action_tbl(i_proc).expenditure_item_date
                 ,  l_dlv_req_action_tbl(i_proc).requisition_line_type_id
                 ,  l_dlv_req_action_tbl(i_proc).category_id
                 ,  l_dlv_req_action_tbl(i_proc).ready_to_procure_flag
                 ,  l_dlv_req_action_tbl(i_proc).initiate_procure_flag
                 ,  l_dlv_req_action_tbl(i_proc).uom_code
                 ,  l_dlv_req_action_tbl(i_proc).currency
                 FROM oke_deliverable_actions_v
                 WHERE pa_action_id = l_actn_version_id;

           END IF; -- l_action= g_create

       IF p_debug_mode = 'Y' THEN
               pa_debug.write(g_module_name,'Populated OKE Procurement PLSQL table',3) ;
           END IF;

        END IF; -- Bug 7759051 (For OKE Procurement)

        -- 3729250, In update mode, if function is not passed, p_action_in_tbl(i_actn).function_code value is G_PA_MISS_CHAR
        -- and so below condition was failing and oke data was not getting updated
        -- changed from p_action_in_tbl(i_actn).function_code to l_function_code_tbl(i_actn)

          ELSIF ( l_function_code_tbl(i_actn) = g_shipping) THEN

          IF l_update_oke_yn = 'Y' THEN -- Bug 7759051 (For OKE Shipping)

           --  Populating the OKE Shipping    PLSQL table
           i_ship := i_ship + 1;

           IF (l_action = g_create) THEN  -- added IF condition and else part of the code bug 3651139
              SELECT l_object_version_id
              ,  l_actn_version_id             -- 3651489 changed from l_action_id to l_actn_version_id, as element version id should be passed to oke
              ,  decode(p_action_in_tbl(i_actn).action_name               ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).action_name               )
              ,  decode(l_fin_task_id_tbl(i_actn)                         ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, l_fin_task_id_tbl(i_actn)                         ) -- for bug# 3749462
              ,  decode(p_action_in_tbl(i_actn).demand_schedule           ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).demand_schedule           )
              ,  decode(p_action_in_tbl(i_actn).ship_from_organization_id ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).ship_from_organization_id )
              ,  decode(p_action_in_tbl(i_actn).ship_from_location_id     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).ship_from_location_id     )
              ,  decode(p_action_in_tbl(i_actn).ship_to_organization_id   ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).ship_to_organization_id   )
              ,  decode(p_action_in_tbl(i_actn).ship_to_location_id       ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).ship_to_location_id       )
              ,  decode(p_action_in_tbl(i_actn).promised_shipment_date    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  , null, p_action_in_tbl(i_actn).promised_shipment_date   )
              -- 3729250 , expected_shipment_date should be populated with shipping action due date
              -- 3749462 , changed from p_action_in_tbl(i_actn).expected_shipment_date to p_action_in_tbl(i_actn).due_date
              ,  l_due_date_tbl(i_actn) --  3651542 Using local variable , if defaulting is done p_action_in_tbl(i_actn).due_date will not reflect it
              ,  decode(p_action_in_tbl(i_actn).volume                    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).volume                    )
              ,  decode(p_action_in_tbl(i_actn).volume_uom                ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  , null, p_action_in_tbl(i_actn).volume_uom                   )
              ,  decode(p_action_in_tbl(i_actn).weight                    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).weight                    )
              ,  decode(p_action_in_tbl(i_actn).weight_uom                ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).weight_uom                )
              ,  decode(p_action_in_tbl(i_actn).ready_to_ship_flag        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).ready_to_ship_flag        )
              ,  decode(p_action_in_tbl(i_actn).initiate_planning_flag    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).initiate_planning_flag    )
              ,  decode(p_action_in_tbl(i_actn).initiate_shipping_flag    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null, p_action_in_tbl(i_actn).initiate_shipping_flag    )
              ,  decode(p_action_in_tbl(i_actn).uom_code                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  , null, p_action_in_tbl(i_actn).uom_code                     )
              ,  decode(p_action_in_tbl(i_actn).quantity                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , null, p_action_in_tbl(i_actn).quantity                  )
              INTO
                 l_dlv_ship_action_tbl(i_ship).pa_deliverable_id
              ,  l_dlv_ship_action_tbl(i_ship).pa_action_id
              ,  l_dlv_ship_action_tbl(i_ship).action_name
              ,  l_dlv_ship_action_tbl(i_ship).ship_finnancial_task_id
              ,  l_dlv_ship_action_tbl(i_ship).demand_schedule
              ,  l_dlv_ship_action_tbl(i_ship).ship_from_organization_id
              ,  l_dlv_ship_action_tbl(i_ship).ship_from_location_id
              ,  l_dlv_ship_action_tbl(i_ship).ship_to_organization_id
              ,  l_dlv_ship_action_tbl(i_ship).ship_to_location_id
              ,  l_dlv_ship_action_tbl(i_ship).promised_shipment_date
              ,  l_dlv_ship_action_tbl(i_ship).expected_shipment_date
              ,  l_dlv_ship_action_tbl(i_ship).volume
              ,  l_dlv_ship_action_tbl(i_ship).volume_uom
              ,  l_dlv_ship_action_tbl(i_ship).weight
              ,  l_dlv_ship_action_tbl(i_ship).weight_uom
              ,  l_dlv_ship_action_tbl(i_ship).ready_to_ship_flag
              ,  l_dlv_ship_action_tbl(i_ship).initiate_planning_flag
              ,  l_dlv_ship_action_tbl(i_ship).initiate_shipping_flag
              ,  l_dlv_ship_action_tbl(i_ship).uom_code
              ,  l_dlv_ship_action_tbl(i_ship).quantity
              FROM DUAL;

           ELSE    -- UPDATE
              SELECT l_object_version_id
              ,  l_actn_version_id             -- 3651489 changed from l_action_id to l_actn_version_id, as element version id should be passed to oke
              ,  decode(p_action_in_tbl(i_actn).action_name               ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , action_name           , p_action_in_tbl(i_actn).action_name               )
              ,  decode(l_fin_task_id_tbl(i_actn)                         ,NULL                                  , task_id               , l_fin_task_id_tbl(i_actn)                         ) -- for bug# 3749462
              ,  decode(p_action_in_tbl(i_actn).demand_schedule           ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , schedule_designator   , p_action_in_tbl(i_actn).demand_schedule           )
              ,  decode(p_action_in_tbl(i_actn).ship_from_organization_id ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , ship_from_org_id      , p_action_in_tbl(i_actn).ship_from_organization_id )
              ,  decode(p_action_in_tbl(i_actn).ship_from_location_id     ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , ship_from_location_id , p_action_in_tbl(i_actn).ship_from_location_id     )
              ,  decode(p_action_in_tbl(i_actn).ship_to_organization_id   ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , ship_to_org_id        , p_action_in_tbl(i_actn).ship_to_organization_id   )
              ,  decode(p_action_in_tbl(i_actn).ship_to_location_id       ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , ship_to_location_id   , p_action_in_tbl(i_actn).ship_to_location_id       )
              ,  decode(p_action_in_tbl(i_actn).promised_shipment_date    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE , promised_date         , p_action_in_tbl(i_actn).promised_shipment_date    )
              -- 3729250 , expected_shipment_date should be populated with shipping action due date
              -- 3749462 , changed from p_action_in_tbl(i_actn).expected_shipment_date to l_due_date_tbl(i_actn)
              ,  l_due_date_tbl(i_actn)
              ,  decode(p_action_in_tbl(i_actn).volume                    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , volume                , p_action_in_tbl(i_actn).volume                    )
              ,  decode(p_action_in_tbl(i_actn).volume_uom                ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , volume_uom_code       , p_action_in_tbl(i_actn).volume_uom                   )
              ,  decode(p_action_in_tbl(i_actn).weight                    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , weight                , p_action_in_tbl(i_actn).weight                    )
              ,  decode(p_action_in_tbl(i_actn).weight_uom                ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , weight_uom_code       , p_action_in_tbl(i_actn).weight_uom                )
              ,  decode(p_action_in_tbl(i_actn).ready_to_ship_flag        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , ready_flag            , p_action_in_tbl(i_actn).ready_to_ship_flag        )
              ,  decode(p_action_in_tbl(i_actn).initiate_planning_flag    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null                  , p_action_in_tbl(i_actn).initiate_planning_flag    )
              ,  decode(p_action_in_tbl(i_actn).initiate_shipping_flag    ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , null                  , p_action_in_tbl(i_actn).initiate_shipping_flag    )
              ,  decode(p_action_in_tbl(i_actn).uom_code                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , uom_code              , p_action_in_tbl(i_actn).uom_code                     )
              ,  decode(p_action_in_tbl(i_actn).quantity                  ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , quantity              , p_action_in_tbl(i_actn).quantity                  )
              INTO
                 l_dlv_ship_action_tbl(i_ship).pa_deliverable_id
              ,  l_dlv_ship_action_tbl(i_ship).pa_action_id
              ,  l_dlv_ship_action_tbl(i_ship).action_name
              ,  l_dlv_ship_action_tbl(i_ship).ship_finnancial_task_id
              ,  l_dlv_ship_action_tbl(i_ship).demand_schedule
              ,  l_dlv_ship_action_tbl(i_ship).ship_from_organization_id
              ,  l_dlv_ship_action_tbl(i_ship).ship_from_location_id
              ,  l_dlv_ship_action_tbl(i_ship).ship_to_organization_id
              ,  l_dlv_ship_action_tbl(i_ship).ship_to_location_id
              ,  l_dlv_ship_action_tbl(i_ship).promised_shipment_date
              ,  l_dlv_ship_action_tbl(i_ship).expected_shipment_date
              ,  l_dlv_ship_action_tbl(i_ship).volume
              ,  l_dlv_ship_action_tbl(i_ship).volume_uom
              ,  l_dlv_ship_action_tbl(i_ship).weight
              ,  l_dlv_ship_action_tbl(i_ship).weight_uom
              ,  l_dlv_ship_action_tbl(i_ship).ready_to_ship_flag
              ,  l_dlv_ship_action_tbl(i_ship).initiate_planning_flag
              ,  l_dlv_ship_action_tbl(i_ship).initiate_shipping_flag
              ,  l_dlv_ship_action_tbl(i_ship).uom_code
              ,  l_dlv_ship_action_tbl(i_ship).quantity
              FROM oke_deliverable_actions_v
              WHERE pa_action_id = l_actn_version_id;

           END IF; -- l_action= g_create

           /*                       INSPECTION_REQ_FLAG        Varchar2(1),*/

       IF p_debug_mode = 'Y' THEN
               pa_debug.write(g_module_name,'Populated OKE Shipping PLSQL table',3) ;
           END IF;

          END IF; -- Bug 7759051 (For OKE Shipping)

        -- 3729250, In update mode, if function is not passed, p_action_in_tbl(i_actn).function_code value is G_PA_MISS_CHAR
        -- and so below condition was failing and oke data was not getting updated
        -- changed from p_action_in_tbl(i_actn).function_code to l_function_code_tbl(i_actn)
       ELSIF ( l_function_code_tbl(i_actn) = g_billing) THEN

           -- 4027500 Passing l_organization_name as PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR if update mode and p_organization_id
           -- is not passed
           -- else call C_org_name to derive organization_name from id
           IF p_insert_or_update = g_update AND p_action_in_tbl(i_actn).organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
               l_organization_name := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
           ELSE
               OPEN C_org_name(p_action_in_tbl(i_actn).organization_id);
               FETCH C_org_name INTO l_organization_name;
               IF (C_org_name%rowcount = 0 ) THEN
                  l_err_message := FND_MESSAGE.GET_STRING('PA','PA_INVALID_EVNT_ORG_AMG') ; -- 3810957, changed error msg code
                  PA_UTILS.ADD_MESSAGE
                                   (p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_ACTN_VALID_ERR',
                                    p_token1         => 'PROJECT',
                                    p_value1         =>  l_project_number,
                                    p_token2         =>  'DLVR_REFERENCE',
                                    p_value2         =>  l_deliverable_number,
                                    p_token3         => 'MESSAGE',
                                    p_value3         =>  l_err_message
                                    );
                 x_return_status             := FND_API.G_RET_STS_ERROR;
                 CLOSE C_org_name;

                 -- Added for bug# 3810957 , throwing invalid cursor error
                 -- here, C_org_name cursor was closed and second time closing it was throwing above error
                 -- if invalid event org id , set return status to 'E' , close the cursor and raise FND_API.G_EXC_ERROR exception
                 RAISE  FND_API.G_EXC_ERROR;
                 -- 3810957 end
               END IF;
               CLOSE C_org_name;
           END IF;

           IF p_debug_mode = 'Y' THEN
               pa_debug.write(g_module_name,'Organization name derived ['||l_organization_name||']',3) ;
           END IF;

           -- Bug 7759051
           IF ((l_action <> g_create) AND
               ((p_action_in_tbl(i_actn).pm_event_reference IS NOT NULL AND
                 p_action_in_tbl(i_actn).pm_event_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (l_fin_task_num_tbl(i_actn)                 IS NOT NULL AND
                 l_fin_task_num_tbl(i_actn)                 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).event_type         IS NOT NULL AND
                 p_action_in_tbl(i_actn).event_type         = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).description        IS NOT NULL AND
                 p_action_in_tbl(i_actn).description        = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).bill_hold_flag     IS NOT NULL AND
                 p_action_in_tbl(i_actn).bill_hold_flag     = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (l_organization_name                        IS NOT NULL AND
                 l_organization_name                        = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).quantity           IS NOT NULL AND
                 p_action_in_tbl(i_actn).quantity           = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                (p_action_in_tbl(i_actn).uom_code           IS NOT NULL AND
                 p_action_in_tbl(i_actn).uom_code           = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).unit_price         IS NOT NULL AND
                 p_action_in_tbl(i_actn).unit_price         = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                (p_action_in_tbl(i_actn).currency           IS NOT NULL AND
                 p_action_in_tbl(i_actn).currency           = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).invoice_amount     IS NOT NULL AND
                 p_action_in_tbl(i_actn).invoice_amount     = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                (p_action_in_tbl(i_actn).revenue_amount     IS NOT NULL AND
                 p_action_in_tbl(i_actn).revenue_amount     = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                (p_action_in_tbl(i_actn).project_rate_type IS NOT NULL AND
                 p_action_in_tbl(i_actn).project_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).project_rate_date IS NOT NULL AND
                 p_action_in_tbl(i_actn).project_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) AND
                (p_action_in_tbl(i_actn).project_rate      IS NOT NULL AND
                 p_action_in_tbl(i_actn).project_rate      = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                (p_action_in_tbl(i_actn).project_functional_rate_type IS NOT NULL AND
                 p_action_in_tbl(i_actn).project_functional_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).project_functional_rate_date IS NOT NULL AND
                 p_action_in_tbl(i_actn).project_functional_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) AND
                (p_action_in_tbl(i_actn).project_functional_rate      IS NOT NULL AND
                 p_action_in_tbl(i_actn).project_functional_rate      = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                (p_action_in_tbl(i_actn).funding_rate_type IS NOT NULL AND
                 p_action_in_tbl(i_actn).funding_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                (p_action_in_tbl(i_actn).funding_rate_date IS NOT NULL AND
                 p_action_in_tbl(i_actn).funding_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) AND
                (p_action_in_tbl(i_actn).funding_rate      IS NOT NULL AND
                 p_action_in_tbl(i_actn).funding_rate      = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
              )THEN
	       -- In Update context, if none of the billing event related parameters are passed,
	       -- then it is not required to call pa_event_pub.update_event
	       NULL;
           ELSE

   --  Populating the Billing Event   PLSQL table
           i_bill := i_bill + 1;

           l_event_in_tbl(i_bill).p_pm_event_reference    :=         p_action_in_tbl(i_actn).pm_event_reference ;  -- 3651489 changed from action_ref to event_ref
           l_event_in_tbl(i_bill).p_task_number           :=         l_fin_task_num_tbl(i_actn)                 ; -- 3749462 passing task num, earlier was passed as null
           l_event_in_tbl(i_bill).p_event_number          :=         null                                       ;
           l_event_in_tbl(i_bill).p_event_type            :=         p_action_in_tbl(i_actn).event_type         ;
           l_event_in_tbl(i_bill).p_description           :=         p_action_in_tbl(i_actn).description        ;
           l_event_in_tbl(i_bill).p_bill_hold_flag        :=         p_action_in_tbl(i_actn).bill_hold_flag     ;
           l_event_in_tbl(i_bill).p_completion_date       :=         l_completion_date_tbl(i_actn)              ; -- 3749462 , create mode event date can't be set
           l_event_in_tbl(i_bill).p_project_number        :=         l_project_number                           ;
           l_event_in_tbl(i_bill).p_organization_name     :=         l_organization_name                        ;
           l_event_in_tbl(i_bill).p_inventory_org_name    :=         null                                       ;
           l_event_in_tbl(i_bill).p_inventory_item_id     :=         null                                       ;
           l_event_in_tbl(i_bill).p_quantity_billed       :=         p_action_in_tbl(i_actn).quantity           ;
           l_event_in_tbl(i_bill).p_uom_code              :=         p_action_in_tbl(i_actn).uom_code           ;
           l_event_in_tbl(i_bill).p_unit_price            :=         p_action_in_tbl(i_actn).unit_price         ;
           l_event_in_tbl(i_bill).p_bill_trans_currency_code :=      p_action_in_tbl(i_actn).currency           ;
           l_event_in_tbl(i_bill).p_bill_trans_bill_amount:=         p_action_in_tbl(i_actn).invoice_amount     ;
           l_event_in_tbl(i_bill).p_bill_trans_rev_amount :=         p_action_in_tbl(i_actn).revenue_amount     ;
           l_event_in_tbl(i_bill).p_project_rate_type     :=         p_action_in_tbl(i_actn).project_rate_type  ;
           l_event_in_tbl(i_bill).p_project_rate_date     :=         p_action_in_tbl(i_actn).project_rate_date  ;
           l_event_in_tbl(i_bill).p_project_exchange_rate :=         p_action_in_tbl(i_actn).project_rate       ;
           l_event_in_tbl(i_bill).p_projfunc_rate_type    :=         p_action_in_tbl(i_actn).project_functional_rate_type;
           l_event_in_tbl(i_bill).p_projfunc_rate_date    :=         p_action_in_tbl(i_actn).project_functional_rate_date;
           l_event_in_tbl(i_bill).p_projfunc_exchange_rate:=         p_action_in_tbl(i_actn).project_functional_rate     ;
           l_event_in_tbl(i_bill).p_funding_rate_type     :=         p_action_in_tbl(i_actn).funding_rate_type  ;
           l_event_in_tbl(i_bill).p_funding_rate_date     :=         p_action_in_tbl(i_actn).funding_rate_date  ;
           l_event_in_tbl(i_bill).p_funding_exchange_rate :=         p_action_in_tbl(i_actn).funding_rate   ;
           l_event_in_tbl(i_bill).p_adjusting_revenue_flag:=         null                                       ;
           l_event_in_tbl(i_bill).p_event_id              :=         NULL                                       ;
           -- 3651489 changed from deliverable proj element id to version id, as element version id should be passed to billing
           l_event_in_tbl(i_bill).p_deliverable_id        :=         l_object_version_id                        ;
           -- 3651489 changed from l_action_id to l_actn_version_id, as element version id should be passed to oke
           l_event_in_tbl(i_bill).p_action_id             :=         l_actn_version_id                          ;
           l_event_in_tbl(i_bill).p_context               :=         'D'     ;-- to be passed as 'D' for deliverable action event
           l_event_in_tbl(i_bill).p_record_version_number :=         1                                          ;

       IF p_debug_mode = 'Y' THEN
               pa_debug.write(g_module_name,'Populated Billing PLSQL table',3) ;
           END IF;

           END IF; -- Bug 7759051 (For Billing events)

       ELSE
           i_none := i_none + 1;

       IF p_debug_mode = 'Y' THEN
               pa_debug.write(g_module_name,'Function code is NONE',3) ;
           END IF;
       END IF;

       -- Bug 7759051 - Reduced the scope to only OKE Procurement and Shipping
       -- END IF;
       i_actn := p_action_in_tbl.next(i_actn);

    END LOOP; -- i_act is not null

    IF  p_debug_mode = 'Y' THEN
         pa_debug.write(g_module_name,'action processed ['||i_actn||']bill['||i_bill||']proc['||i_proc||']ship['||i_ship||']none['||i_none||']',5);
    END IF;

  --  Invoke the API to create records in OKE tables
    IF ( i_ship > 0) THEN

       i_ship1 := l_dlv_ship_action_tbl.first();

       WHILE (i_ship1 IS NOT NULL) LOOP

           l_dlv_ship_action_rec.pa_deliverable_id         :=  l_dlv_ship_action_tbl(i_ship1).pa_deliverable_id        ;
           l_dlv_ship_action_rec.pa_action_id              :=  l_dlv_ship_action_tbl(i_ship1).pa_action_id             ;
           l_dlv_ship_action_rec.action_name               :=  l_dlv_ship_action_tbl(i_ship1).action_name              ;
           l_dlv_ship_action_rec.ship_finnancial_task_id   :=  l_dlv_ship_action_tbl(i_ship1).ship_finnancial_task_id  ;
           l_dlv_ship_action_rec.demand_schedule           :=  l_dlv_ship_action_tbl(i_ship1).demand_schedule          ;
           l_dlv_ship_action_rec.ship_from_organization_id :=  l_dlv_ship_action_tbl(i_ship1).ship_from_organization_id;
           l_dlv_ship_action_rec.ship_from_location_id     :=  l_dlv_ship_action_tbl(i_ship1).ship_from_location_id    ;
           l_dlv_ship_action_rec.ship_to_organization_id   :=  l_dlv_ship_action_tbl(i_ship1).ship_to_organization_id  ;
           l_dlv_ship_action_rec.ship_to_location_id       :=  l_dlv_ship_action_tbl(i_ship1).ship_to_location_id      ;
           l_dlv_ship_action_rec.promised_shipment_date    :=  l_dlv_ship_action_tbl(i_ship1).promised_shipment_date   ;
           l_dlv_ship_action_rec.volume                    :=  l_dlv_ship_action_tbl(i_ship1).volume                   ;
           l_dlv_ship_action_rec.volume_uom                :=  l_dlv_ship_action_tbl(i_ship1).volume_uom               ;
           l_dlv_ship_action_rec.weight                    :=  l_dlv_ship_action_tbl(i_ship1).weight                   ;
           l_dlv_ship_action_rec.weight_uom                :=  l_dlv_ship_action_tbl(i_ship1).weight_uom               ;
           l_dlv_ship_action_rec.ready_to_ship_flag        :=  l_dlv_ship_action_tbl(i_ship1).ready_to_ship_flag       ;
           l_dlv_ship_action_rec.initiate_planning_flag    :=  l_dlv_ship_action_tbl(i_ship1).initiate_planning_flag   ;
           l_dlv_ship_action_rec.initiate_shipping_flag    :=  l_dlv_ship_action_tbl(i_ship1).initiate_shipping_flag   ;
           l_dlv_ship_action_rec.expected_shipment_date    :=  l_dlv_ship_action_tbl(i_ship1).expected_shipment_date   ;
           l_dlv_ship_action_rec.uom_code                  :=  l_dlv_ship_action_tbl(i_ship1).uom_code                 ;
           l_dlv_ship_action_rec.quantity                  :=  l_dlv_ship_action_tbl(i_ship1).quantity                 ;

           oke_amg_grp.manage_dlv_action
              ( p_api_version          =>    p_api_version
              , p_init_msg_list         =>    FND_API.G_FALSE
              , p_commit                =>    p_commit
              , p_action                =>    l_action
              , p_dlv_action_type       =>    g_dlv_action_ship
              , p_master_inv_org_id     =>    l_org_id
              , p_item_dlv              =>    l_item_dlv
              , p_dlv_ship_action_rec   =>    l_dlv_ship_action_rec
              , p_dlv_req_action_rec    =>    l_dlv_req_action_rec_b
              , x_return_status         =>    x_return_status
              , x_msg_data              =>    x_msg_data
              , x_msg_count             =>    x_msg_count
              );

           IF  p_debug_mode = 'Y' THEN
              pa_debug.write(g_module_name,'Returned from oke_amg_grp.manage_dlv_action for shipping action ['||x_return_status||']',5);
           END IF;

           i_ship1 := l_dlv_ship_action_tbl.next(i_ship1);

       END LOOP;

    END IF;

    IF ( i_proc > 0 ) THEN

       i_proc1 := l_dlv_req_action_tbl.first();

       WHILE (i_proc1 IS NOT NULL) LOOP

           l_dlv_req_action_rec.pa_deliverable_id          :=  l_dlv_req_action_tbl(i_proc1).pa_deliverable_id          ;
           l_dlv_req_action_rec.pa_action_id               :=  l_dlv_req_action_tbl(i_proc1).pa_action_id               ;
           l_dlv_req_action_rec.action_name                :=  l_dlv_req_action_tbl(i_proc1).action_name                ;
           l_dlv_req_action_rec.proc_finnancial_task_id    :=  l_dlv_req_action_tbl(i_proc1).proc_finnancial_task_id    ;
           l_dlv_req_action_rec.destination_type_code      :=  l_dlv_req_action_tbl(i_proc1).destination_type_code      ;
           l_dlv_req_action_rec.receiving_org_id           :=  l_dlv_req_action_tbl(i_proc1).receiving_org_id           ;
           l_dlv_req_action_rec.receiving_location_id      :=  l_dlv_req_action_tbl(i_proc1).receiving_location_id      ;
           l_dlv_req_action_rec.po_need_by_date            :=  l_dlv_req_action_tbl(i_proc1).po_need_by_date            ;
           l_dlv_req_action_rec.vendor_id                  :=  l_dlv_req_action_tbl(i_proc1).vendor_id                  ;
           l_dlv_req_action_rec.vendor_site_id             :=  l_dlv_req_action_tbl(i_proc1).vendor_site_id             ;
--         l_dlv_req_action_rec.project_currency           :=  l_dlv_req_action_tbl(i_proc1).project_currency           ;
           l_dlv_req_action_rec.quantity                   :=  l_dlv_req_action_tbl(i_proc1).quantity                   ;
           l_dlv_req_action_rec.unit_price                 :=  l_dlv_req_action_tbl(i_proc1).unit_price                 ;
           l_dlv_req_action_rec.exchange_rate_type         :=  l_dlv_req_action_tbl(i_proc1).exchange_rate_type         ;
           l_dlv_req_action_rec.exchange_rate_date         :=  l_dlv_req_action_tbl(i_proc1).exchange_rate_date         ;
           l_dlv_req_action_rec.exchange_rate              :=  l_dlv_req_action_tbl(i_proc1).exchange_rate              ;
           l_dlv_req_action_rec.expenditure_type           :=  l_dlv_req_action_tbl(i_proc1).expenditure_type           ;
           l_dlv_req_action_rec.expenditure_org_id         :=  l_dlv_req_action_tbl(i_proc1).expenditure_org_id         ;
           l_dlv_req_action_rec.expenditure_item_date      :=  l_dlv_req_action_tbl(i_proc1).expenditure_item_date      ;
           l_dlv_req_action_rec.requisition_line_type_id   :=  l_dlv_req_action_tbl(i_proc1).requisition_line_type_id   ;
           l_dlv_req_action_rec.category_id                :=  l_dlv_req_action_tbl(i_proc1).category_id                ;
           l_dlv_req_action_rec.ready_to_procure_flag      :=  l_dlv_req_action_tbl(i_proc1).ready_to_procure_flag      ;
           l_dlv_req_action_rec.initiate_procure_flag      :=  l_dlv_req_action_tbl(i_proc1).initiate_procure_flag      ;
           l_dlv_req_action_rec.uom_code                   :=  l_dlv_req_action_tbl(i_proc1).uom_code                   ;
           l_dlv_req_action_rec.currency                   :=  l_dlv_req_action_tbl(i_proc1).currency                   ;

           oke_amg_grp.manage_dlv_action
              (  p_api_version          =>    p_api_version
              , p_init_msg_list         =>    FND_API.G_FALSE
              , p_commit                =>    p_commit
              , p_action                =>    l_action
              , p_dlv_action_type       =>    g_dlv_action_proc
              , p_master_inv_org_id     =>    l_org_id
              , p_item_dlv              =>    l_item_dlv
              , p_dlv_ship_action_rec   =>    l_dlv_ship_action_rec_b
              , p_dlv_req_action_rec    =>    l_dlv_req_action_rec
              , x_return_status         =>    x_return_status
              , x_msg_data              =>    x_msg_data
              , x_msg_count             =>    x_msg_count
              );

       IF  p_debug_mode = 'Y' THEN
              pa_debug.write(g_module_name,'Returned from oke_amg_grp.manage_dlv_action for proc action ['||x_return_status||']',5);
           END IF;

           i_proc1 := l_dlv_req_action_tbl.next(i_proc1);

      END LOOP;

    END IF;

  --  Invoke the API to create event for billing actions
    IF ( i_bill > 0 ) THEN
        IF ( p_insert_or_update = g_insert) THEN

           Pa_Event_Pub.create_event
           (  p_api_version_number   =>   p_api_version
             ,p_commit               =>   p_commit
             ,p_init_msg_list        =>   FND_API.G_FALSE
             ,p_pm_product_code      =>   l_pm_source_code
             ,p_event_in_tbl         =>   l_event_in_tbl
             ,p_event_out_tbl        =>   l_event_out_tbl
             ,p_msg_count            =>   x_msg_count
             ,p_msg_data             =>   x_msg_data
             ,p_return_status        =>   x_return_status
           );

          IF  p_debug_mode = 'Y' THEN
              pa_debug.write(g_module_name,'Returned from Pa_Event_Pub.create_event for billing action ['||x_return_status||']',5);
           END IF;

          IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

       ELSIF ( p_insert_or_update = g_update) THEN

         Pa_Event_Pub.Update_Event
          (   p_api_version_number   =>   p_api_version
            , p_commit               =>   p_commit
            , p_init_msg_list        =>   FND_API.G_FALSE
            , p_pm_product_code      =>   l_pm_source_code
            , p_event_in_tbl         =>   l_event_in_tbl
            , p_event_out_tbl        =>   l_event_out_tbl
            , p_msg_count            =>   x_msg_count
            , p_msg_data             =>   x_msg_data
            , p_return_status        =>   x_return_status
           );

           IF  p_debug_mode = 'Y' THEN
              pa_debug.write(g_module_name,'Returned from Pa_Event_Pub.update_event for billing action ['||x_return_status||']',5);
           END IF;

          IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

      END IF; -- p_insert_or_update values
    END IF;   -- i_bill > 0

    IF  p_debug_mode = 'Y' THEN
        pa_debug.reset_curr_function;
        pa_debug.write(g_module_name,l_api_name||': Exiting without error',5);
    END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR  THEN
      IF (p_commit = FND_API.G_TRUE) THEN
         ROLLBACK TO create_dlvr_actions_wrapper;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_FALSE,
                p_msg_index      => 1,
                p_msg_count      => x_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);

       x_msg_data := l_data;
           x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;

     END IF;

     IF  p_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
          pa_debug.write(g_module_name,l_api_name||': Inside G_EXC_ERROR exception',5);
     END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
     IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK TO create_dlvr_actions_wrapper;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 AND x_msg_data IS NULL
     THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_FALSE,
                p_msg_index      => 1,
                p_msg_count      => x_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);

       x_msg_data := l_data;
           x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;

     END IF;

     IF  p_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
          pa_debug.write(g_module_name,l_api_name||': Inside G_EXC_UNEXPECTED_ERROR exception',5);
     END IF;

   WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
         ROLLBACK TO create_dlvr_actions_wrapper;
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
                   ( p_pkg_name            => G_PKG_NAME
                   , p_procedure_name      => l_api_name   );
      END IF;
  END  Create_Dlvr_Actions_Wrapper;
-------3435905 : FP M : Deliverables Changes For AMG -END--------------------

PROCEDURE RUN_ACTION_CONC_PROCESS
(
 errbuf                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,retcode                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_function              IN     pa_lookups.lookup_code%TYPE
,p_project_number_from   IN     pa_projects_all.segment1%TYPE := NULL
,p_project_number_to     IN     pa_projects_all.segment1%TYPE := NULL
)
IS
l_project_id_tbl             SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
l_count                      NUMBER ;
l_request_id                 pa_proj_elem_ver_structure.conc_request_id%TYPE;

l_debug_mode                 VARCHAR2(10);
l_debug_level3               NUMBER := 3;
l_msg_count                  NUMBER := 0;
l_msg_data                   VARCHAR2(2000);
l_data                       VARCHAR2(2000);
l_msg_index_out              NUMBER;
l_return_status              VARCHAR2(2000);
l_error_message_code         VARCHAR2(2000);
-- Added for Bug Number 4907103
l_project_number_from    pa_projects_all.segment1%TYPE :=nvl(p_project_number_from,p_project_number_to);
l_project_number_to pa_projects_all.segment1%TYPE :=nvl(p_project_number_to,p_project_number_from) ;
-- 3752898
-- We need this variable only for passing to OKE API
-- Though they dont have any logic as of now to re-initialise Message stack if l_init_msg_list is TRUE ,
-- Its not correct to initialise this variable as TRUE .By default this value should be FALSE
l_init_msg_list              VARCHAR2(20) := FND_API.G_FALSE ;

l_valid                      VARCHAR2(1);

/* Commented for Bug Number 4907103
CURSOR c_project_id_range IS
SELECT proj.project_id
FROM PA_PROJECTS_ALL proj
WHERE segment1 between nvl(p_project_number_from,p_project_number_to)
                   and nvl(p_project_number_to,p_project_number_from) ;
*/
-- Changed  for Bug Number 4907103
CURSOR c_project_id_range IS
SELECT proj.project_id
FROM PA_PROJECTS_ALL proj
WHERE segment1 between l_project_number_from and l_project_number_to;
-- End of BugNumber 4907103
CURSOR c_valid_project_number_entry(l_project_number IN pa_projects_all.segment1%TYPE) IS
SELECT 'Y'
FROM PA_PROJECTS_ALL
WHERE segment1 = l_project_number;

BEGIN

 -- Set the error stack.
pa_debug.set_err_stack('PA_ACTIONS_PUB.RUN_ACTION_CONC_PROCESS');

-- Get the Debug mode into local variable and set it to 'Y'if its NULL
l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

l_request_id  := FND_GLOBAL.CONC_REQUEST_ID;
retcode       := '0';
errbuf        := NULL;

 -- Initialize the return status to success
 l_return_status := FND_API.G_RET_STS_SUCCESS;
 pa_debug.set_process('PLSQL','LOG',l_debug_mode);

IF l_debug_mode = 'Y' THEN
     pa_debug.set_curr_function( p_function   => 'RUN_ACTION_CONC_PROCESS',
                                 p_debug_mode => l_debug_mode );
     pa_debug.g_err_stage:= 'Entering RUN_ACTION_CONC_PROCESS : ' || l_request_id;
     pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
END IF;

--Printing Input Parameters

IF l_debug_mode = 'Y' THEN
     pa_debug.g_err_stage:= 'RUN_ACTION_CONC_PROCESS : Function is :' || p_function ;
     pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
     pa_debug.g_err_stage:= 'RUN_ACTION_CONC_PROCESS : Project Number From is :' || p_project_number_from ;
     pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
     pa_debug.g_err_stage:= 'RUN_ACTION_CONC_PROCESS : Project Number To is :' || p_project_number_to ;
     pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
END IF;

--Valid Parameter Validations
IF ( (p_project_number_from IS NOT NULL) OR (p_project_number_to IS NOT NULL) ) THEN
     IF p_project_number_from IS NOT NULL THEN
          OPEN c_valid_project_number_entry(p_project_number_from) ;
          FETCH c_valid_project_number_entry INTO l_valid ;

          IF c_valid_project_number_entry%NOTFOUND THEN
               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'RUN_ACTION_CONC_PROCESS : Invalid value entered for Project Number From';
                    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
               END IF;
               l_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_INV_PARAM_PASSED');
               CLOSE c_valid_project_number_entry ;
               RAISE Invalid_Arg_Exc_Dlv;
          END IF ;
     ELSE
          OPEN c_valid_project_number_entry(p_project_number_to) ;
          FETCH c_valid_project_number_entry INTO l_valid ;

          IF c_valid_project_number_entry%NOTFOUND THEN
               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'RUN_ACTION_CONC_PROCESS : Invalid value entered for Project Number To' ;
                    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
               END IF;
               l_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_INV_PARAM_PASSED');
           CLOSE c_valid_project_number_entry ;
               RAISE Invalid_Arg_Exc_Dlv;
          END IF ;
      END IF;
END IF;

--Business Rule Validations
IF (p_function IS NULL) THEN
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Mandatory parameter to this API : Function is NULL';
          pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
     END IF;
     l_return_status := FND_API.G_RET_STS_ERROR;
     PA_UTILS.ADD_MESSAGE
           (p_app_short_name => 'PA',
            p_msg_name       => 'PA_INV_PARAM_PASSED');
     RAISE Invalid_Arg_Exc_Dlv;
END IF;

IF l_debug_mode = 'Y' THEN
    pa_debug.g_err_stage := 'Before doing cursor operation';
    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
END IF;

OPEN   c_project_id_range ;
FETCH  c_project_id_range  BULK COLLECT INTO l_project_id_tbl ;
CLOSE  c_project_id_range;

IF l_debug_mode = 'Y' THEN
    pa_debug.g_err_stage := 'After fetching the project id range into local table';
    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
END IF;

IF(NVL(l_project_id_tbl.LAST,0) > 0) THEN

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Project Id table is not empty';
          pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
     END IF;

    FOR l_count IN l_project_id_tbl.FIRST..l_project_id_tbl.LAST LOOP

        --Bug   3611598 If and Only if Deliverable is Enabled for a Project,Proceed

        PA_PROJECT_STRUCTURE_UTILS.Check_Structure_Type_Exists
        (
          p_project_id     => l_project_id_tbl(l_count)
         ,p_structure_type => 'DELIVERABLE'
         ,x_return_status  => l_return_status
         ,x_error_message_code => l_error_message_code
        );

        IF l_return_status = 'E' THEN -- This API returns 'E' if Structure Type is Enabled

             IF p_function = 'DEMAND' THEN
                  OKE_DELIVERABLE_UTILS_PUB.BATCH_MDS(
                                  P_PROJECT_ID     => l_project_id_tbl(l_count)
                                 ,P_Task_ID        => null
                                 ,P_Init_Msg_List  => l_init_msg_list
                                 ,X_RETURN_STATUS  => l_return_status
                                 ,X_MSG_COUNT      => l_msg_count
                                 ,X_MSG_DATA       => l_msg_data
                            );
                     IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'OKE_DELIVERABLE_UTILS_PUB.BATCH_MDS returned status :' || l_return_status ;
                          pa_debug.g_err_stage := pa_debug.g_err_stage || ' for project id '||l_project_id_tbl(l_count) ;
                          pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
                     END IF;

                     IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE Invalid_Arg_Exc_Dlv ;
                     END IF ;
            ELSIF p_function = 'PROCUREMENT' THEN
             OKE_DELIVERABLE_UTILS_PUB.BATCH_REQ(
                            P_PROJECT_ID     => l_project_id_tbl(l_count)
                            ,P_Task_ID        => null
                            ,P_Init_Msg_List  => l_init_msg_list
                            ,X_RETURN_STATUS  => l_return_status
                            ,X_MSG_COUNT      => l_msg_count
                            ,X_MSG_DATA       => l_msg_data
                                         );
                    IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage := 'OKE_DELIVERABLE_UTILS_PUB.BATCH_REQ returned status :' || l_return_status;
                             pa_debug.g_err_stage := pa_debug.g_err_stage || ' for project id '||l_project_id_tbl(l_count) ;
                             pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
                    END IF;

                    IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             RAISE Invalid_Arg_Exc_Dlv ;
                    END IF ;

             ELSIF p_function = 'BOTH' THEN
                 OKE_DELIVERABLE_UTILS_PUB.BATCH_MDS(
                                   P_PROJECT_ID     => l_project_id_tbl(l_count)
                                  ,P_Task_ID        => null
                                  ,P_Init_Msg_List  => l_init_msg_list
                                  ,X_RETURN_STATUS  => l_return_status
                                  ,X_MSG_COUNT      => l_msg_count
                                  ,X_MSG_DATA       => l_msg_data
                               );
                        IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage := 'OKE_DELIVERABLE_UTILS_PUB.BATCH_MDS returned status :' || l_return_status;
                             pa_debug.g_err_stage := pa_debug.g_err_stage || ' for project id '||l_project_id_tbl(l_count) ;
                             pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
                        END IF;

                    IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE Invalid_Arg_Exc_Dlv ;
                    END IF ;
                    OKE_DELIVERABLE_UTILS_PUB.BATCH_REQ(
                            P_PROJECT_ID     => l_project_id_tbl(l_count)
                            ,P_Task_ID        => null
                            ,P_Init_Msg_List  => l_init_msg_list
                            ,X_RETURN_STATUS  => l_return_status
                            ,X_MSG_COUNT      => l_msg_count
                            ,X_MSG_DATA       => l_msg_data
                            );
                    IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage := 'OKE_DELIVERABLE_UTILS_PUB.BATCH_REQ returned status :' || l_return_status;
                             pa_debug.g_err_stage := pa_debug.g_err_stage || ' for project id '||l_project_id_tbl(l_count) ;
                             pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
                    END IF;

                    IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE Invalid_Arg_Exc_Dlv ;
                    END IF ;

             END IF;

        END IF;

    END LOOP;
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'After Calling OKE API for all the actions (passed project id)';
          pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
     END IF;

ELSE

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Here,No Project Id range is entered';
          pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
     END IF;

    IF p_function = 'DEMAND' THEN

               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Selected Option is Initiate Demand(project_id is null)';
                    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
               END IF;

             OKE_DELIVERABLE_UTILS_PUB.BATCH_MDS(
                             P_PROJECT_ID     => null
                            ,P_Task_ID        => null
                            ,P_Init_Msg_List  => l_init_msg_list
                            ,X_RETURN_STATUS  => l_return_status
                            ,X_MSG_COUNT      => l_msg_count
                            ,X_MSG_DATA       => l_msg_data
                            );
               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'OKE_DELIVERABLE_UTILS_PUB.BATCH_MDS returned status :' || l_return_status;
                    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
               END IF;

               IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE Invalid_Arg_Exc_Dlv ;
            END IF ;

     ELSIF p_function = 'PROCUREMENT' THEN

          IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Selected Option is Initiate Procurement(project_id is null)';
          pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
          END IF;
             OKE_DELIVERABLE_UTILS_PUB.BATCH_REQ(
                            P_PROJECT_ID     => null
                            ,P_Task_ID        => null
                            ,P_Init_Msg_List  => l_init_msg_list
                            ,X_RETURN_STATUS  => l_return_status
                            ,X_MSG_COUNT      => l_msg_count
                            ,X_MSG_DATA       => l_msg_data
                            );
               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'OKE_DELIVERABLE_UTILS_PUB.BATCH_REQ returned status :' || l_return_status;
                    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
               END IF;


               IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE Invalid_Arg_Exc_Dlv ;
            END IF ;
    ELSIF p_function = 'BOTH' THEN

               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Selected Option is All(project_id is null)';
                    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
               END IF;

             OKE_DELIVERABLE_UTILS_PUB.BATCH_MDS(
                                             P_PROJECT_ID     => null
                            ,P_Task_ID        => null
                            ,P_Init_Msg_List  => l_init_msg_list
                                ,X_RETURN_STATUS  => l_return_status
                                ,X_MSG_COUNT      => l_msg_count
                            ,X_MSG_DATA       => l_msg_data
                            );
               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'OKE_DELIVERABLE_UTILS_PUB.BATCH_MDS returned status :' || l_return_status;
                    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
               END IF;

               IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE Invalid_Arg_Exc_Dlv ;
            END IF ;

               OKE_DELIVERABLE_UTILS_PUB.BATCH_REQ(
                                                      P_PROJECT_ID     => null
                                                     ,P_Task_ID        => null
                                                     ,P_Init_Msg_List  => l_init_msg_list
                                                     ,X_RETURN_STATUS  => l_return_status
                                                     ,X_MSG_COUNT      => l_msg_count
                                                     ,X_MSG_DATA       => l_msg_data
                                                );

               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'OKE_DELIVERABLE_UTILS_PUB.BATCH_REQ returned status :' || l_return_status;
                    pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
               END IF;

               IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE Invalid_Arg_Exc_Dlv ;
            END IF ;
         END IF;

END IF;

IF l_debug_mode = 'Y' THEN
     pa_debug.g_err_stage:= 'Exiting RUN_ACTION_CONC_PROCESS';
     pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
     pa_debug.reset_err_stack;
     pa_debug.reset_curr_function;    --Added for bug 4945876
END IF;

EXCEPTION

WHEN Invalid_Arg_Exc_Dlv THEN
     l_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;
     retcode     := '-1';

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Inside Invalid Argument exception of RUN_ACTION_CONC_PROCESS';
        pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' ||  pa_debug.g_err_stage);
     END IF;

     IF  c_project_id_range%ISOPEN THEN
          CLOSE c_project_id_range ;
     END IF;

     IF c_valid_project_number_entry%ISOPEN THEN
          CLOSE c_valid_project_number_entry ;
     END IF;

     IF c_valid_project_number_entry%ISOPEN THEN
          CLOSE c_valid_project_number_entry ;
     END IF ;

     IF l_msg_count >= 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
                errbuf := l_data;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_Stack);
          pa_debug.reset_err_stack;
	  pa_debug.reset_curr_function;    --Added for bug 4945876
     END IF ;
     RAISE; /* Will have to raise since called as part of conc request .After Reports is built for the C.P no need for this raise */

WHEN OTHERS THEN
     l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     retcode         := '-1';
     errbuf          := SQLERRM;

     IF  c_project_id_range%ISOPEN THEN
     CLOSE c_project_id_range ;
     END IF;

     IF c_valid_project_number_entry%ISOPEN THEN
          CLOSE c_valid_project_number_entry ;
     END IF;

     IF c_valid_project_number_entry%ISOPEN THEN
          CLOSE c_valid_project_number_entry ;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'RUN_ACTION_CONC_PROCESS'
                     ,p_error_text      => errbuf);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||errbuf;
          pa_debug.write_file('RUN_ACTION_CONC_PROCESS :' || pa_debug.g_err_stage);
          pa_debug.reset_err_stack;
	  pa_debug.reset_curr_function;    --Added for bug 4945876
     END IF;

     RAISE;
END  RUN_ACTION_CONC_PROCESS ;


-- SubProgram           : UPD_DLV_ACTIONS_IN_BULK_TM ( 3578694 )
-- Type                 : PROCEDURE
-- Purpose              : Public API to Update Deliverable Actions From TM Home Actions Page
-- Note                 : Its a BULK API
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N      Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N      Standard Parameter
-- p_commit                        IN          VARCHAR2          N      Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N      Standard Parameter
-- p_validation_level              IN          NUMBER            N      Standard Parameter
-- p_calling_module                IN          VARCHAR2          N      Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N      Standard Parameter
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
-- p_project_id_tbl                IN          PLSQL Table       N        Project Id
-- p_object_id_tbl                 IN          PLSQL Table       Y        Parent Id
-- p_object_version_id_tbl         IN          PLSQL Table       N        Parent Version ID
-- p_object_type                   IN          VARCHAR2          Y        Parent Type
-- p_pm_source_code                IN          NUMBER            N        PM Source Code
-- p_pm_source_reference           IN          VARCHAR2          N        PM Source Reference
-- p_insert_or_update              IN          VARCHAR2          N        Identifies the API Mode
-- x_return_status                 OUT         VARCHAR2          N        Mandatory Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Mandatory Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Mandatory Out Parameter

PROCEDURE UPD_DLV_ACTIONS_IN_BULK_TM
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
     ,p_project_id_tbl            IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_object_id_tbl             IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_object_version_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_pm_source_code            IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_pm_source_reference       IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_reference_tbl   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_insert_or_update          IN VARCHAR2 := 'UPDATE'
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS

     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;

     l_upd_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_mgr_person_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_upd_function_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_upd_due_date_tbl           SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_upd_comp_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()      ;
     l_upd_comp_date_tbl          SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_upd_element_id_tbl         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_upd_element_ver_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_upd_rec_ver_num_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_upd_description_tbl        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_upd_attribute_category_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;
     l_upd_attribute1_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute2_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute3_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute4_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute5_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute6_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute7_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute8_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute9_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute10_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute11_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute12_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute13_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute14_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_upd_attribute15_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;

     j_upd NUMBER ;

     l_name_tbl                   SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_completed_flag_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM.PA_VARCHAR2_1_TBL_TYPE()      ;
     l_completion_date_tbl        SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_description_tbl            SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_function_code_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_due_date_tbl               SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_element_version_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_proj_element_id_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_user_action_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_action_owner_id_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_pm_source_reference_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()     ;
     l_object_id                  NUMBER;
     l_object_version_id          NUMBER;
     l_project_id                 NUMBER;

     l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
     l_count NUMBER;

BEGIN

     -- this api will be called from TM Home Update Actions Page
     -- popluate plsql table, having single row, and pass this table
     -- to validation actions api for validations
     -- if validations are successful, call UPDATE_DLV_ACTIONS_IN_BULK api

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'UPD_DLV_ACTIONS_IN_BULK_TM',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside UPD_DLV_ACTIONS_IN_BULK_TM ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Printing Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.write(g_module_name,'p_insert_or_update'||':'||p_insert_or_update,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CR_UP_DLV_ACTIONS_SP ;
     END IF;

     -- Call the validation API. It will
     -- perform all the validation.
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Calling PA_ACTIONS_PUB.VALIDATE_ACTIONS';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

     l_name_tbl.extend;
     l_completed_flag_tbl.extend;
     l_completion_date_tbl.extend;
     l_description_tbl.extend;
     l_function_code_tbl.extend;
     l_due_date_tbl.extend;
     l_element_version_id_tbl.extend;
     l_proj_element_id_tbl.extend;
     l_user_action_tbl.extend;
     l_action_owner_id_tbl.extend;
     l_pm_source_reference_tbl.extend;

     l_count:= 0;

     IF l_debug_mode = 'Y' THEN
          pa_debug.write(g_module_name,'No of actions ' || p_name_tbl.last,3) ;
     END IF ;

     IF nvl(p_name_tbl.last,0) >= 1 THEN -- Only if something is fetched

         l_count := l_count + 1;

         FOR i in p_name_tbl.FIRST .. p_name_tbl.LAST LOOP

             IF l_debug_mode = 'Y' THEN
                  pa_debug.write(g_module_name,'i ' || i,3) ;
             END IF ;

             l_name_tbl(l_count)                    := p_name_tbl(i);

             l_completed_flag_tbl(l_count)          := p_completed_flag_tbl(i);
             l_completion_date_tbl(l_count)         := p_completion_date_tbl(i);
             l_description_tbl(l_count)             := p_description_tbl(i);
             l_function_code_tbl(l_count)           := p_function_code_tbl(i);
             l_due_date_tbl(l_count)                := p_due_date_tbl(i);
             l_element_version_id_tbl(l_count)      := p_element_version_id_tbl(i);
             l_proj_element_id_tbl(l_count)         := p_proj_element_id_tbl(i);
             l_user_action_tbl(l_count)             := 'MODIFIED';
             l_action_owner_id_tbl(l_count)         := p_manager_person_id_tbl(i);
             l_object_id                            := p_object_id_tbl(i);
             l_object_version_id                    := p_object_version_id_tbl(i);
             l_project_id                           := p_project_id_tbl(i);

             IF l_debug_mode = 'Y' THEN
                  pa_debug.write(g_module_name,' validating action p_element_version_id_tbl ' || p_element_version_id_tbl(i) ,3) ;
                  pa_debug.write(g_module_name,' validating action ( version id ) ' || l_element_version_id_tbl(l_count) ,3) ;
             END IF ;

             PA_ACTIONS_PUB.VALIDATE_ACTIONS
                    ( p_init_msg_list         => FND_API.G_FALSE
                     ,p_debug_mode            => l_debug_mode
                     ,p_name_tbl              => l_name_tbl
                     ,p_completed_flag_tbl    => l_completed_flag_tbl
                     ,p_completion_date_tbl   => l_completion_date_tbl
                     ,p_description_tbl       => l_description_tbl
                     ,p_function_code_tbl     => l_function_code_tbl
                     ,p_due_date_tbl          => l_due_date_tbl
                     ,p_element_version_id_tbl=> l_element_version_id_tbl
                     ,p_proj_element_id_tbl   => l_proj_element_id_tbl
                     ,p_user_action_tbl       => l_user_action_tbl
                     ,p_object_id             => l_object_id
                     ,p_object_version_id     => l_object_version_id
                     ,p_object_type           => p_object_type
                     ,p_project_id            => l_project_id
                     ,p_action_owner_id_tbl   => l_action_owner_id_tbl
                     ,p_carrying_out_org_id   => NULL
                     ,p_action_reference_tbl  => p_pm_source_reference_tbl
                     ,p_deliverable_id        => l_object_id
                     ,p_insert_or_update      => 'UPDATE'
                     ,x_return_status         => x_return_status
                     ,x_msg_count             => x_msg_count
                     ,x_msg_data              => x_msg_data
                   ) ;

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;

         END LOOP ;

     END IF;

     IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     -- Loop through p_name_tbl to find out the
     -- actions which are updated by user.

     -- Initialize the local variable
     j_upd := 0 ;

     IF nvl(p_name_tbl.last,0) >= 1 THEN -- Only if something is fetched

          FOR i in p_name_tbl.FIRST .. p_name_tbl.LAST LOOP

                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Update Operation';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    j_upd:=j_upd+1 ;

                    -- Get all the actions which are updated, into
                    -- local plsql tables, which will be used to
                    -- call PLSQL bulk API for update.

                    -- extend the size of PLSQL table
                    l_upd_element_id_tbl.extend        ;
                    l_upd_element_ver_id_tbl.extend    ;
                    l_upd_rec_ver_num_id_tbl.extend    ;
                    l_upd_name_tbl.extend              ;
                    l_upd_function_code_tbl.extend     ;
                    l_upd_mgr_person_id_tbl.extend     ;
                    l_upd_due_date_tbl.extend          ;
                    l_upd_comp_flag_tbl.extend         ;
                    l_upd_comp_date_tbl.extend         ;
                    l_upd_attribute_category_tbl.extend;
                    l_upd_attribute1_tbl.extend        ;
                    l_upd_attribute2_tbl.extend        ;
                    l_upd_attribute3_tbl.extend        ;
                    l_upd_attribute4_tbl.extend        ;
                    l_upd_attribute5_tbl.extend        ;
                    l_upd_attribute6_tbl.extend        ;
                    l_upd_attribute7_tbl.extend        ;
                    l_upd_attribute8_tbl.extend        ;
                    l_upd_attribute9_tbl.extend        ;
                    l_upd_attribute10_tbl.extend       ;
                    l_upd_attribute11_tbl.extend       ;
                    l_upd_attribute12_tbl.extend       ;
                    l_upd_attribute13_tbl.extend       ;
                    l_upd_attribute14_tbl.extend       ;
                    l_upd_attribute15_tbl.extend       ;
                    l_upd_description_tbl.extend       ;

                    l_upd_element_id_tbl(j_upd)      := p_proj_element_id_tbl(i)           ;
                    l_upd_element_ver_id_tbl(j_upd)  := p_element_version_id_tbl(i)        ;
                    l_upd_rec_ver_num_id_tbl(j_upd)  := p_record_version_number_tbl(i)     ;
                    l_upd_name_tbl(j_upd)            := p_name_tbl(i)                      ;
                    l_upd_function_code_tbl(j_upd)   := p_function_code_tbl(i)             ;

--                    IF p_object_type <> g_dlvr_types THEN // removed for bug# 3578694, not required condition
                         l_upd_mgr_person_id_tbl(j_upd)     := p_manager_person_id_tbl(i)  ;
                         l_upd_due_date_tbl(j_upd)          := p_due_date_tbl(i)           ;
                         l_upd_comp_flag_tbl(j_upd)         := p_completed_flag_tbl(i)     ;
                         l_upd_comp_date_tbl(j_upd)         := p_completion_date_tbl(i)    ;
                         l_upd_attribute_category_tbl(j_upd):= p_attribute_category_tbl(i) ;
                         l_upd_attribute1_tbl(j_upd)        := p_attribute1_tbl(i)         ;
                         l_upd_attribute2_tbl(j_upd)        := p_attribute2_tbl(i)         ;
                         l_upd_attribute3_tbl(j_upd)        := p_attribute3_tbl(i)         ;
                         l_upd_attribute4_tbl(j_upd)        := p_attribute4_tbl(i)         ;
                         l_upd_attribute5_tbl(j_upd)        := p_attribute5_tbl(i)         ;
                         l_upd_attribute6_tbl(j_upd)        := p_attribute6_tbl(i)         ;
                         l_upd_attribute7_tbl(j_upd)        := p_attribute7_tbl(i)         ;
                         l_upd_attribute8_tbl(j_upd)        := p_attribute8_tbl(i)         ;
                         l_upd_attribute9_tbl(j_upd)        := p_attribute9_tbl(i)         ;
                         l_upd_attribute10_tbl(j_upd)       := p_attribute10_tbl(i)        ;
                         l_upd_attribute11_tbl(j_upd)       := p_attribute11_tbl(i)        ;
                         l_upd_attribute12_tbl(j_upd)       := p_attribute12_tbl(i)        ;
                         l_upd_attribute13_tbl(j_upd)       := p_attribute13_tbl(i)        ;
                         l_upd_attribute14_tbl(j_upd)       := p_attribute14_tbl(i)        ;
                         l_upd_attribute15_tbl(j_upd)       := p_attribute15_tbl(i)        ;
                         l_upd_description_tbl(j_upd)       := p_description_tbl(i)        ;
--                    END IF ;


          END LOOP ;


         -- Call Update API to perform the update operation
         IF j_upd > 0 THEN

               IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Call UPDATE_DLV_ACTIONS_IN_BULK ';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;

               PA_ACTIONS_PUB.UPDATE_DLV_ACTIONS_IN_BULK
                    (p_api_version               => p_api_version
                    ,p_init_msg_list             => FND_API.G_FALSE
                    ,p_commit                    => p_commit
                    ,p_validate_only             => p_validate_only
                    ,p_validation_level          => p_validation_level
                    ,p_calling_module            => p_calling_module
                    ,p_debug_mode                => l_debug_mode
                    ,p_max_msg_count             => p_max_msg_count
                    ,p_name_tbl                  => l_upd_name_tbl
                    ,p_manager_person_id_tbl     => l_upd_mgr_person_id_tbl
                    ,p_function_code_tbl         => l_upd_function_code_tbl
                    ,p_due_date_tbl              => l_upd_due_date_tbl
                    ,p_completed_flag_tbl        => l_upd_comp_flag_tbl
                    ,p_completion_date_tbl       => l_upd_comp_date_tbl
                    ,p_description_tbl           => l_upd_description_tbl
                    ,p_attribute_category_tbl    => l_upd_attribute_category_tbl
                    ,p_attribute1_tbl            => l_upd_attribute1_tbl
                    ,p_attribute2_tbl            => l_upd_attribute2_tbl
                    ,p_attribute3_tbl            => l_upd_attribute3_tbl
                    ,p_attribute4_tbl            => l_upd_attribute4_tbl
                    ,p_attribute5_tbl            => l_upd_attribute5_tbl
                    ,p_attribute6_tbl            => l_upd_attribute6_tbl
                    ,p_attribute7_tbl            => l_upd_attribute7_tbl
                    ,p_attribute8_tbl            => l_upd_attribute8_tbl
                    ,p_attribute9_tbl            => l_upd_attribute9_tbl
                    ,p_attribute10_tbl           => l_upd_attribute10_tbl
                    ,p_attribute11_tbl           => l_upd_attribute11_tbl
                    ,p_attribute12_tbl           => l_upd_attribute12_tbl
                    ,p_attribute13_tbl           => l_upd_attribute13_tbl
                    ,p_attribute14_tbl           => l_upd_attribute14_tbl
                    ,p_attribute15_tbl           => l_upd_attribute15_tbl
                    ,p_element_version_id_tbl    => l_upd_element_ver_id_tbl
                    ,p_proj_element_id_tbl       => l_upd_element_id_tbl
                    ,p_record_version_number_tbl => l_upd_rec_ver_num_id_tbl
                    ,p_project_id                => NULL
                    ,p_object_id                 => NULL
                    ,p_object_version_id         => NULL
                    ,p_object_type               => p_object_type
                    ,p_pm_source_code            => p_pm_source_code
                    ,p_pm_source_reference       => p_pm_source_reference
                    ,p_carrying_out_organization_id => NULL
                    ,x_return_status             => x_return_status
                    ,x_msg_count                 => x_msg_count
                    ,x_msg_data                  => x_msg_data
                    ) ;


               IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE Invalid_Arg_Exc_Dlv ;
               END IF ;

         END IF ;


         IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE Invalid_Arg_Exc_Dlv ;
         END IF ;

     END IF ;  -- Only if something is fetched

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting UPD_DLV_ACTIONS_IN_BULK_TM' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CR_UP_DLV_ACTIONS_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of UPD_DLV_ACTIONS_IN_BULK_TM';
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

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CR_UP_DLV_ACTIONS_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'UPD_DLV_ACTIONS_IN_BULK_TM');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write(g_module_name,'UPD_DLV_ACTIONS_IN_BULK_TM: '|| pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END UPD_DLV_ACTIONS_IN_BULK_TM ;


/*=======================================================================
   This is a wrapper API that will launch the concurrent process
   PRC: Initiate Project Deliverable Actions
   For Initiating Demand as soon as a Project Is Approved,we need to
   call this Wrapper API whenever Project Status is changed to Approved.

   Please not that ,the Caller of this API should validate for the Project
   Status Change = Approved .

   So,The parameters that would be passed to this concurrent process are :
   1) 'Demand' and 2) The Project Number
  =======================================================================*/


PROCEDURE RUN_ACTION_CONC_PROCESS_WRP
     (
      p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE
     ,p_project_number            IN PA_PROJECTS_ALL.SEGMENT1%TYPE  -- 3671408 added IN paramter
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
     IS
     l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
     l_project_number             PA_PROJECTS_ALL.SEGMENT1%TYPE  ;
     l_status_code                PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE ;
     l_request_id                 PA_PROJ_ELEM_VER_STRUCTURE.CONC_REQUEST_ID%TYPE;

     l_debug_mode                 VARCHAR2(1);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;

     -- 3671408 removed following cursor
     -- as project_number is been directly passed to api,
/*
     CURSOR c_project_number_from IS
     SELECT SEGMENT1
     FROM   PA_PROJECTS_ALL
     WHERE  PROJECT_ID = p_project_id ;
*/
    -- THE FOLLOWING CURSOR WILL NOT BE USED ANYWHERE
     /*CURSOR c_project_sys_status_code IS
     SELECT PROJECT_SYSTEM_STATUS_CODE
     FROM PA_PROJECT_STATUSES pps,
               PA_PROJECTS_ALL pa
     WHERE pa.PROJECT_ID = p_project_id
       AND pps.PROJECT_STATUS_CODE = pa.PROJECT_STATUS_CODE ;
    */
     PRAGMA AUTONOMOUS_TRANSACTION;

     BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entering RUN_ACTION_CONC_PROCESS_WRP';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);

          pa_debug.set_curr_function( p_function   => 'RUN_ACTION_CONC_PROCESS_WRP',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Initialise Message Stack
     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     -- Define Save Point
     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint RUN_ACTION_CONC_PROCESS_WRP_SP ;
     END IF;

     --Printing Input Parameters

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'The Project Id is :' || p_project_id ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF ;

     -- Validate Input parameters
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF p_project_id IS NULL THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Mandatory parameter to this API : Project ID is NULL';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;
          l_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name       => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     --Check for valid project id passed
     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Before doing cursor operation';
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

    -- 3671408 project_number is passed directly to the api
    -- removed below code to retrieve and validate project_number
/*
     OPEN c_project_number_from;
     FETCH c_project_number_from INTO l_project_number;

     IF c_project_number_from%NOTFOUND THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'No Project Number returned for the passed Project ID ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;
          l_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name       => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     CLOSE c_project_number_from ;
*/

     -- 3671408 added below code to validate project_number

     IF p_project_number IS NULL THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'No Project Number returned for the passed Project ID ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;
          l_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name       => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     -- 3671408 end

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'After doing cursor operation - Valid Project Number ';
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

    -- If the new project status has not been committed into Database,this cursor will fail
    -- This is due to the Autonomous Transaction definition.So,commented the following code
    /* --If the project status is Approved,then only submit the request.
     --If not return

     OPEN c_project_sys_status_code;
     FETCH c_project_sys_status_code into l_status_code ;
     CLOSE c_project_sys_status_code;
     IF nvl(l_status_code,'-99') <> 'APPROVED' THEN
         IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'The Project Status is not approved .So,No need to invoke concurrent process ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
         END IF;
         RETURN;
     END IF ;
     */
     -- Submit the request.
     l_request_id := fnd_request.submit_request
     (
           application                =>   'PA',
           program                    =>   'PAINIACT',
           description                =>   'PRC: Initiate Project Deliverable Actions',
           start_time                 =>   NULL,
           sub_request                =>   false,
           argument1                  =>   'DEMAND',
           argument2                  =>   p_project_number, -- 3671408 changed parameter value to passed IN parameter
           argument3                  =>   NULL
     );
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Request id is '||l_request_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Throw an error if the request could not be submitted.
     IF l_request_id = 0 THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name       => 'PA_DLV_INI_CONC_PGM_ERR');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     COMMIT ;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting RUN_ACTION_CONC_PROCESS_WRP ' ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
	  pa_debug.reset_curr_function;    --Added for bug 4945876
     END IF;
 EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

    -- 3671408  cursor is not used now , commented below code
    /*
     --Close any open cursors and roll back
     IF c_project_number_from%ISOPEN THEN
          CLOSE c_project_number_from;
     END IF;
    */
    -- 3671408 end
   /*  IF c_project_sys_status_code%ISOPEN THEN
          CLOSE c_project_sys_status_code;
     END IF;*/

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO RUN_ACTION_CONC_PROCESS_WRP_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Inside Invalid arg exception of RUN_ACTION_CONC_PROCESS_WRP';
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
     END IF;
     IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

    -- 3671408 cursor is not used now, removed below code
     /*
     --Close any open cursors and roll back
     IF c_project_number_from%ISOPEN THEN
          CLOSE c_project_number_from;
     END IF;
     */
     -- 3671408

     /*IF c_project_sys_status_code%ISOPEN THEN
          CLOSE c_project_sys_status_code;
     END IF;*/

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO RUN_ACTION_CONC_PROCESS_WRP_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'RUN_ACTION_CONC_PROCESS_WRP');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write(g_module_name, pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END RUN_ACTION_CONC_PROCESS_WRP ;

/*==================================================================================
  This is the wrapper API which has to be called from FORMS whenever Project Status
  is changed to 'Approved' .This API inturn places call to another wrapper API
  RUN_ACTION_CONC_PROCESS_WRP - which places concurrent request for automatically
  generating demand (When the Project Status is 'Approved')
  ==================================================================================*/

PROCEDURE RUN_ACTION_CONC_FRM_WRP
     (
      p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE
    , x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    , x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    , x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
     IS
     l_project_number             PA_PROJECTS_ALL.SEGMENT1%TYPE  ;

     -- 3671408 Added below cursor to retrieve project_number

     CURSOR c_project_details(p_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE) IS
     SELECT segment1
     FROM  PA_PROJECTS_ALL
     WHERE PROJECT_ID = p_project_id;

     BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_project_id IS NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name       => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     -- 3671408 added code to retrieve project number

     OPEN  c_project_details(p_project_id) ;
     FETCH c_project_details INTO l_project_number ;
     CLOSE c_project_details;

     --Bug 3752898
     --While Calling this API ,the Message Stack should not be re-initialized.
     --If it gets reinitialized it will break fix for Bug # 3134205

     PA_ACTIONS_PUB.RUN_ACTION_CONC_PROCESS_WRP
     (
      p_calling_module            =>  'FORMS'
     ,p_init_msg_list             =>  FND_API.G_FALSE   -- 3752898 , Passing False to avoid re-initialization of Message Stack
     ,p_project_id                =>  p_project_id
     ,p_project_number            =>  l_project_number  -- 3671408 , passing retrieved value
     ,x_return_status             =>  x_return_status
     ,x_msg_count                 =>  x_msg_count
     ,x_msg_data                  =>  x_msg_data
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN

     -- 3671408 added code to handle cursor
     IF c_project_details%ISOPEN THEN
          CLOSE c_project_details;
     END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data :='Invalid Argument Exception inside RUN_ACTION_CONC_FRM_WRP' || x_msg_data;
     RETURN;
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := SQLERRM;

     -- 3671408 added code to handle cursor
     IF c_project_details%ISOPEN THEN
          CLOSE c_project_details;
     END IF;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_ACTIONS_PUB'
                     ,p_procedure_name  => 'RUN_ACTION_CONC_FRM_WRP');

     RAISE;
END RUN_ACTION_CONC_FRM_WRP;

END PA_ACTIONS_PUB;

/
