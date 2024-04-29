--------------------------------------------------------
--  DDL for Package PA_DELIVERABLE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DELIVERABLE_UTILS" AUTHID CURRENT_USER AS
/* $Header: PADLUTLS.pls 120.1.12010000.2 2010/01/18 10:57:27 amehrotr ship $ */

      l_err_message             Fnd_New_Messages.Message_text%TYPE;  -- for AMG message

FUNCTION IS_DLV_TYPE_NAME_UNIQUE
     (
          p_deliverable_type_name IN VARCHAR2
     )   RETURN VARCHAR2;

FUNCTION IS_DLV_TYPE_IN_USE
     (
          p_deliverable_type_id IN PA_TASK_TYPES.TASK_TYPE_ID%TYPE
     )   RETURN VARCHAR2;

FUNCTION IS_DLV_TYPE_ACTIONS_EXISTS
     (
          p_deliverable_type_id IN PA_TASK_TYPES.TASK_TYPE_ID%TYPE
     )   RETURN VARCHAR2;

FUNCTION IS_DLV_ACTIONS_EXISTS
     (
          p_deliverable_type_id IN PA_TASK_TYPES.TASK_TYPE_ID%TYPE
     )   RETURN VARCHAR2;

FUNCTION IS_DLV_BASED_ASSCN_EXISTS
     (
          p_deliverable_type_id IN PA_TASK_TYPES.TASK_TYPE_ID%TYPE
     )   RETURN VARCHAR2;

FUNCTION IS_EFF_FROM_TO_DATE_VALID
     (
          p_start_date_active   IN  DATE,
          p_end_date_active     IN  DATE
     )    RETURN VARCHAR2;

FUNCTION GET_ASSOCIATED_TASKS
     (
          p_deliverable_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     )    RETURN VARCHAR2;

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
         ) ;

FUNCTION IS_TASK_ASSGMNT_EXISTS
         ( p_project_id       IN  pa_projects_all.project_id%TYPE
          ,p_dlvr_item_id     IN  pa_proj_elements.proj_element_id%TYPE
          ,p_dlvr_version_id  IN  pa_proj_element_versions.element_version_id%TYPE
         )
RETURN VARCHAR2 ;

PROCEDURE IS_DLV_STATUS_CHANGE_ALLOWED
       ( p_project_id        IN  pa_projects_all.project_id%TYPE
        ,p_dlvr_item_id      IN  pa_proj_elements.proj_element_id%TYPE
        ,p_dlvr_version_id   IN  pa_proj_element_versions.element_version_id%TYPE
        ,p_dlv_type_id       IN  pa_task_types.task_type_id%TYPE
        ,p_dlvr_status_code  IN  PA_PROJ_ELEMENTS.STATUS_CODE%TYPE
        ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       );

FUNCTION GET_FUNCTION_CODE(p_action_element_id IN pa_proj_elements.proj_element_id%TYPE)
RETURN VARCHAR2 ;

FUNCTION GET_DLV_TYPE_CLASS_CODE(p_dlvr_type_id IN pa_task_types.task_type_id%TYPE )
RETURN VARCHAR2 ;

FUNCTION IS_DLV_DOC_DEFINED(p_dlvr_item_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
                           ,p_dlvr_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
                           )
RETURN VARCHAR2 ;

--  dthakker added the below procedures and functions


PROCEDURE GET_STRUCTURE_INFO
    (
         p_api_version              IN          NUMBER   := 1.0
        ,p_calling_module           IN          VARCHAR2 := 'SELF_SERVICE'
        ,p_project_id               IN          PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_structure_type           IN          VARCHAR2 := 'DELIVERABLE'
        ,x_proj_element_id          OUT         NOCOPY PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE --File.Sql.39 bug 4440895
        ,x_element_version_id       OUT         NOCOPY PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE --File.Sql.39 bug 4440895
        ,x_return_status            OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                OUT         NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data                 OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

FUNCTION GET_CARRYING_OUT_ORG
    (
         p_project_id                   IN      PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_task_id                      IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )  RETURN NUMBER ;

-- 3625019

FUNCTION GET_PROGRESS_ROLLUP_METHOD
    (
        p_task_id                       IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )  RETURN VARCHAR2;

FUNCTION IS_DELIVERABLE_HAS_PROGRESS
    (
         p_project_id                   IN      PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_proj_element_id              IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )  RETURN VARCHAR2;

FUNCTION IS_BILLING_FUNCTION_EXISTS
    (
         p_project_id                   IN      PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_proj_element_id              IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )  RETURN VARCHAR2;

FUNCTION IS_ACTIONS_EXISTS
    (
         p_project_id                   IN      PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
        ,p_proj_element_id              IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )  RETURN VARCHAR2;

PROCEDURE GET_DLVR_TYPE_INFO
    (
         p_dlvr_type_id                 IN      PA_TASK_TYPES.TASK_TYPE_ID%TYPE
        ,x_dlvr_prg_enabled             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_dlvr_action_enabled          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_dlvr_default_status_code     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

PROCEDURE GET_DEFAULT_DLVR_OWNER
    (
         p_project_id                   IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
        ,p_task_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_owner_id                     OUT     NOCOPY PER_ALL_PEOPLE_F.PERSON_ID%TYPE --File.Sql.39 bug 4440895
        ,x_owner_name                   OUT     NOCOPY PER_ALL_PEOPLE_F.FULL_NAME%TYPE --File.Sql.39 bug 4440895
    );

PROCEDURE GET_DEFAULT_DLVR_DATE
    (
         p_project_id                   IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
        ,p_task_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_due_date                     OUT     NOCOPY DATE --File.Sql.39 bug 4440895
    );

PROCEDURE GET_DEFAULT_ACTION_OWNER
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_owner_id                     OUT     NOCOPY PER_ALL_PEOPLE_F.PERSON_ID%TYPE --File.Sql.39 bug 4440895
        ,x_owner_name                   OUT     NOCOPY PER_ALL_PEOPLE_F.FULL_NAME%TYPE --File.Sql.39 bug 4440895
    );

PROCEDURE GET_DEFAULT_ACTION_DATE
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,p_task_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,p_project_mode                 IN      VARCHAR2
        ,p_function_code                IN      PA_PROJ_ELEMENTS.FUNCTION_CODE%TYPE
        ,x_due_date                     OUT     NOCOPY DATE --File.Sql.39 bug 4440895
    );

PROCEDURE GET_DEFAULT_ACTN_DATE
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,p_task_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,p_project_mode                 IN      VARCHAR2
        ,x_due_date                     OUT     NOCOPY DATE --File.Sql.39 bug 4440895
        ,x_earliest_start_date          OUT     NOCOPY DATE --File.Sql.39 bug 4440895
        ,x_earliest_finish_date         OUT     NOCOPY DATE --File.Sql.39 bug 4440895
    );

FUNCTION IS_DLV_BASED_ASSCN_EXISTS
    (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
         ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE := NULL
    )   RETURN VARCHAR2 ;

FUNCTION GET_READY_TO_SHIP_FLAG
     (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
         ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2;

FUNCTION GET_READY_TO_PROC_FLAG
     (
          p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
         ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2;

FUNCTION IS_PROG_ENABLED_DLV_EXISTS
     (
          p_proj_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     )   RETURN VARCHAR2;
FUNCTION IS_PROGRESS_ENABLED
     (
          p_proj_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     )   RETURN VARCHAR2;

PROCEDURE GET_PROJECT_DETAILS
    (
         p_project_id                   IN      PA_PROJECTS_ALL.PROJECT_ID%TYPE
        ,x_projfunc_currency_code       OUT     NOCOPY PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE --File.Sql.39 bug 4440895
        ,x_org_id                       OUT     NOCOPY PA_PLAN_RES_DEFAULTS.item_master_id%TYPE    -- 3462360 changed type --File.Sql.39 bug 4440895
    );

-- OKEAPI
-- This API will return deliverable name and number based on
-- deliverable version id
PROCEDURE GET_DLVR_DETAIL
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_name                         OUT     NOCOPY PA_PROJ_ELEMENTS.NAME%TYPE --File.Sql.39 bug 4440895
        ,x_number                       OUT     NOCOPY PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE --File.Sql.39 bug 4440895
    );

-- OKEAPI
-- This API will return action name and number based on
-- action version id
PROCEDURE GET_ACTION_DETAIL
    (
         p_dlvr_action_ver_id           IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_name                         OUT     NOCOPY PA_PROJ_ELEMENTS.NAME%TYPE --File.Sql.39 bug 4440895
        ,x_number                       OUT     NOCOPY PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE --File.Sql.39 bug 4440895
    );

-- OKEAPI
-- This API will return projfunc currency code
-- for given deliverable version id .
FUNCTION GET_PROJ_CURRENCY_CODE
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
    )    RETURN VARCHAR2;

-- OKEAPI
-- This API will return project id and project name
-- based on deliverable version id
PROCEDURE GET_DLVR_PROJECT_DETAIL
    (
         p_dlvr_ver_id                  IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_project_id                   OUT     NOCOPY PA_PROJ_ELEMENTS.PROJECT_ID%TYPE --File.Sql.39 bug 4440895
        ,x_project_name                 OUT     NOCOPY PA_PROJECTS_ALL.NAME%TYPE --File.Sql.39 bug 4440895
    );

-- OKEAPI
-- This API will return project id and project name
-- based on action version id
PROCEDURE GET_ACTION_PROJECT_DETAIL
    (
         p_dlvr_action_ver_id           IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_project_id                   OUT     NOCOPY PA_PROJ_ELEMENTS.PROJECT_ID%TYPE --File.Sql.39 bug 4440895
        ,x_project_name                 OUT     NOCOPY PA_PROJECTS_ALL.NAME%TYPE --File.Sql.39 bug 4440895
    );

-- OKEAPI
-- This API will return task number based on task version id
FUNCTION GET_ACTION_TASK_DETAIL
    (
         p_task_id                     IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
    ) RETURN VARCHAR2;

-- OKEAPI
-- This API will return deliverable description
-- based on action version id
FUNCTION GET_DLV_DESCRIPTION
     (
          p_action_ver_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2;

-- OKEAPI
-- This API will return 'Y' if deliverable is itrm based or not
-- based on action version id. Else will return 'N'
FUNCTION IS_DLV_ITEM_BASED
     (
          p_action_ver_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2;

PROCEDURE CHECK_DLVR_DISABLE_ALLOWED( p_api_version    IN NUMBER := 1.0
                                      ,p_calling_module IN VARCHAR2 := 'SELF_SERVICE'
                                      ,p_debug_mode     IN VARCHAR2 := 'N'
                                      ,p_project_id     IN PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
                                      ,x_return_flag        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                      ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    );

PROCEDURE UPDATE_TSK_STATUS_CANCELLED( p_api_version    IN  NUMBER := 1.0
                                      ,p_calling_module IN  VARCHAR2 := 'SELF_SERVICE'
                                      ,p_debug_mode     IN  VARCHAR2 := 'N'
                                      ,p_task_id        IN  NUMBER
                                      ,p_status_code    IN  PA_PROJECT_STATUSES.PROJECT_STATUS_CODE%TYPE
                                      ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                      ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      );

PROCEDURE CHECK_CHANGE_MAPPING_OK( p_api_version    IN  NUMBER := 1.0
                                  ,p_calling_module IN  VARCHAR2 := 'SELF_SERVICE'
                                  ,p_debug_mode     IN  VARCHAR2 := 'N'
                                  ,p_wp_task_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
                                  ,p_fp_task_verison_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
                                  ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                  ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  );

PROCEDURE CHECK_PROGRESS_MTH_CODE_VALID( p_api_version    IN  NUMBER := 1.0
                                         ,p_calling_module IN  VARCHAR2 := 'SELF_SERVICE'
                                         ,p_debug_mode     IN  VARCHAR2 := 'N'
                                         ,p_task_id        IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
                                         ,p_prog_method_code IN PA_PROJ_ELEMENTS.BASE_PERCENT_COMP_DERIV_CODE%TYPE
                                         ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                         ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                         ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        );

FUNCTION CHECK_PROJ_DLV_TXN_EXISTS( p_api_version    IN  NUMBER := 1.0
                                   ,p_calling_module IN  VARCHAR2 := 'SELF_SERVICE'
                                   ,p_debug_mode     IN  VARCHAR2 := 'N'
                                   ,p_project_id     IN PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
                                   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                   ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   )
RETURN VARCHAR2;

FUNCTION GET_ASSOCIATED_DELIVERABLES
     (
          p_task_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     ) RETURN VARCHAR2;

FUNCTION GET_ADJUSTED_DATES
     (
          p_project_id   IN pa_projects_all.project_id%TYPE
         ,p_dlv_due_date IN DATE
         ,p_delta        IN NUMBER
     )   RETURN DATE ;

FUNCTION IS_ITEM_BASED_DLV_EXISTS RETURN VARCHAR2 ;

FUNCTION IS_BILLING_FUNCTION
     (
      p_action_version_id IN pa_proj_element_versions.element_version_id%TYPE
      )
RETURN VARCHAR2 ;

FUNCTION Get_Project_Type_Class(
   p_project_id NUMBER ,
   x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) RETURN VARCHAR2;

FUNCTION IS_DLVR_ITEM_BASED
    (
        p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
    )
RETURN VARCHAR2;

-- 3470061 oke needed this api which will take deliverable version id as in parameter
-- and return deliverable description

FUNCTION GET_DELIVERABLE_DESCRIPTION
     (
          p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2;

-- 3470061

-- 3454572 added function for TM Home Page

FUNCTION GET_DLVR_NAME_NUMBER
     (
          p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2;

FUNCTION GET_DLVR_NUMBER
     (
          p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     )   RETURN VARCHAR2;

-- 3454572 end
-- 3442451 added for deliverable security
FUNCTION IS_DLVR_OWNER
     (
           p_deliverable_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
          ,p_user_id        IN NUMBER
     )   RETURN VARCHAR2;
-- 3442451
/* ==============3435905 : FP M : Deliverables Changes For AMG  START ========*/
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
   )   ;

FUNCTION IS_DLV_TYPE_ID_VALID
(
     p_deliverable_type_id IN NUMBER
)   RETURN VARCHAR2      ;

FUNCTION IS_STATUS_CODE_VALID
(
     p_status_code IN VARCHAR2
   , p_calling_mode IN VARCHAR2 := 'INSERT'
)   RETURN VARCHAR2;

FUNCTION get_deliverable_version_id
(
    p_deliverable_id         IN NUMBER     ,
    p_structure_version_id  IN NUMBER     ,
    p_project_id             IN NUMBER
 ) RETURN NUMBER;

PROCEDURE is_dlvr_reference_unique
(
    p_deliverable_reference IN VARCHAR2  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_project_id            IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_unique_flag          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

 PROCEDURE Convert_pm_dlvrref_to_id
 (
    p_deliverable_reference IN VARCHAR2  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_deliverable_id        IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id            IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_out_deliverable_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,p_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

FUNCTION get_action_version_id
(
    p_action_id              IN NUMBER     ,
    p_structure_version_id  IN NUMBER     ,
    p_project_id             IN NUMBER
 ) RETURN NUMBER;

FUNCTION IS_FUNCTION_CODE_VALID
(
   p_function_code       IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION GET_DLVR_TASK_ASSCN_ID
(
    p_deliverable_id         IN NUMBER     ,
    p_task_id             IN NUMBER
 ) RETURN NUMBER;

PROCEDURE is_action_reference_unique
(
    p_action_reference      IN VARCHAR2  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_deliverable_id        IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id            IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_unique_flag          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

 PROCEDURE Convert_pm_actionref_to_id
 (
    p_action_reference IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_action_id        IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_deliverable_id   IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id       IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_out_action_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,p_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

   PROCEDURE Progress_Enabled_Validation
   (
      p_deliverable_id         IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    , p_project_id             IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    , p_dlvr_type_id           IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    , px_actual_finish_date    IN OUT NOCOPY DATE --File.Sql.39 bug 4440895
    , px_progress_weight       IN OUT NOCOPY PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE --File.Sql.39 bug 4440895
    , px_status_code           IN OUT NOCOPY Pa_task_types.initial_status_code%TYPE --File.Sql.39 bug 4440895
    , p_calling_Mode           IN VARCHAR2  := 'INSERT'
   ) ;

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
  );
/* ==============3435905 : FP M : Deliverables Changes For AMG END ========*/

FUNCTION IS_DLV_PROGRESSABLE
(
     p_project_id     IN NUMBER
    ,p_deliverable_id IN NUMBER
)   RETURN VARCHAR2;

FUNCTION IS_STR_TASK_HAS_DELIVERABLES
(
    p_str_task_id IN NUMBER
)   RETURN VARCHAR2;

-- 3442451

FUNCTION GET_TASK_DATES
(
     p_project_id           IN NUMBER
    ,p_date_type            IN VARCHAR2
    ,p_task_id              IN NUMBER
)   RETURN DATE;

-- 3442451


FUNCTION IS_DLV_BASED_TASK_EXISTS
(
    p_project_id IN NUMBER
)   RETURN VARCHAR2;

FUNCTION IS_DELIVERABLES_DEFINED
(
    p_project_id IN NUMBER
)   RETURN VARCHAR2;

FUNCTION CHECK_USER_VIEW_DLV_PRIVILEGE
(
    p_project_id IN NUMBER
)   RETURN VARCHAR2;

-- 3586196 added two out parameters for task names
-- added two out parameters for task numbers

PROCEDURE GET_DEFAULT_TASK
(
    p_dlv_element_id    IN NUMBER
   ,p_dlv_version_id    IN NUMBER
   ,p_project_id        IN NUMBER
   ,x_oke_task_id       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_oke_task_name     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_oke_task_number   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_bill_task_id      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_bill_task_name    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_bill_task_number  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)   ;

FUNCTION IS_SHIPPING_INITIATED
(
    p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
   ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
)  RETURN VARCHAR2;

FUNCTION IS_PROCUREMENT_INITIATED
(
    p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
   ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
)  RETURN VARCHAR2;

FUNCTION IS_BILLING_EVENT_PROCESSED
(
    p_dlv_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
   ,p_dlv_version_id IN PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
)  RETURN VARCHAR2;

-- 3622126 added for action dates not in synch with billing txn date

PROCEDURE GET_BILLING_DETAILS
(
    p_action_version_id     IN  PA_PROJ_ELEM_VER_SCHEDULE.ELEMENT_VERSION_ID%TYPE
   ,x_bill_completion_date  OUT NOCOPY PA_PROJ_ELEM_VER_SCHEDULE.ACTUAL_FINISH_DATE%TYPE --File.Sql.39 bug 4440895
   ,x_bill_description      OUT NOCOPY PA_PROJ_ELEMENTS.DESCRIPTION%TYPE --File.Sql.39 bug 4440895
   ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)   ;

-- 3651340 added for retrieving task version id and parent structure version id

FUNCTION GET_TASK_INFO
(
     p_project_id           IN NUMBER
    ,p_task_id              IN NUMBER
    ,p_task_or_struct       IN VARCHAR2
)  RETURN NUMBER;

-- added for bug# 3911050

PROCEDURE GET_SHIP_PROC_ACTN_DETAIL
    (
         p_dlvr_id                      IN      PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
        ,x_ship_id                      OUT     NOCOPY PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE --File.Sql.39 bug 4440895
        ,x_ship_name                    OUT     NOCOPY PA_PROJ_ELEMENTS.NAME%TYPE --File.Sql.39 bug 4440895
        ,x_ship_due_date                OUT     NOCOPY PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE --File.Sql.39 bug 4440895
        ,x_proc_id                      OUT     NOCOPY PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE --File.Sql.39 bug 4440895
        ,x_proc_name                    OUT     NOCOPY PA_PROJ_ELEMENTS.NAME%TYPE --File.Sql.39 bug 4440895
        ,x_proc_due_date                OUT     NOCOPY PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE --File.Sql.39 bug 4440895
    );

-- 9071494
FUNCTION IS_ACTIONS_ENABLED
    (
        p_proj_element_id IN PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
    )   RETURN VARCHAR2;

END PA_DELIVERABLE_UTILS;


/
