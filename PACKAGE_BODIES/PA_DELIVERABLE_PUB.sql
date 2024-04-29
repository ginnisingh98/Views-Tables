--------------------------------------------------------
--  DDL for Package Body PA_DELIVERABLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DELIVERABLE_PUB" AS
/* $Header: PADLVPUB.pls 120.2.12010000.2 2008/11/12 15:33:17 rthumma ship $ */

g_module_name   VARCHAR2(100) := 'PA_DELIVERABLE_PUB';
Invalid_Arg_Exc_Dlv EXCEPTION ;

Invalid_Arg_Exc_WP Exception;

-- Procedure            : Create_Deliverable
-- Type                 : PUBLIC
-- Purpose              : Create Deliveable Page calls this procedure to create deliverables
-- Note                 : Check for input parameter validations and short name uniqueness.
--                      : Retrieve carrying_out_organization_id and structure_info.
--                      : Call Create_Deliveable procedure of the pa_deliverable_pvt package.
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_api_version                NUMBER      N           1.0
-- p_init_msg_list              VARCHAR2    N           := FND_API.G_TRUE
-- p_commit                     VARCHAR2    N           := FND_API.G_FALSE
-- p_validate_only              VARCHAR2    N           := FND_API.G_TRUE
-- p_validation_level           NUMBER      N           := FND_API.G_VALID_LEVEL_FULL
-- p_calling_module             VARCHAR2    N           := 'SELF_SERVICE'
-- p_debug_mode                 VARCHAR2    N           := 'N'
-- p_max_msg_count              NUMBER      N           := NULL
-- p_record_version_number      NUMBER      N           := 1
-- p_object_type                VARCHAR2    N           Object Type Default 'PA_DELIVERABLES'
-- p_project_id                 NUMBER      Y           Project Id
-- p_dlvr_number                VARCHAR2    Y           Deliverable Number
-- p_dlvr_name                  VARCHAR2    Y           Deliverable Name
-- p_dlvr_description           VARCHAR2    N           Description
-- p_dlvr_owner_id              NUMBER      N           Deliverable Owner Id
-- p_dlvr_owner_name            VARCHAR2    N           Delivearble Owner Name
-- p_carrying_out_org_id        NUMBER      N           Project Carrying Out Organization Id
-- p_carrying_out_org_name      VARCHAR2    N           Project Carrying Out Organization Name
-- p_dlvr_version_id            NUMBER      N           Deliverable Version Id
-- p_status_code                VARCHAR2    N           Delivearble Status
-- p_parent_structure_id        NUMBER      N           Deliverable Parent Structure Id
-- p_dlvr_type_id               NUMBER      N           Deliverable Type Id
-- p_dlvr_type_name             VARCHAR2    N           Deliverable Type Name
-- p_progress_weight            NUMBER      N           Progress Weight
-- p_scheduled_finish_date      DATE        N           Scheduled Finish Date
-- p_actual_finish_date         DATE        N           Actual Finish Date
-- p_task_id                    NUMBER      N
-- p_task_version_id            NUMBER      N
-- p_task_name                  VARCHAR2    N
-- p_attribute_category         VARCHAR2    N
-- p_attribute1                 VARCHAR2    N
-- p_attribute2                 VARCHAR2    N
-- p_attribute3                 VARCHAR2    N
-- p_attribute4                 VARCHAR2    N
-- p_attribute5                 VARCHAR2    N
-- p_attribute6                 VARCHAR2    N
-- p_attribute7                 VARCHAR2    N
-- p_attribute8                 VARCHAR2    N
-- p_attribute9                 VARCHAR2    N
-- p_attribute10                VARCHAR2    N
-- p_attribute11                VARCHAR2    N
-- p_attribute12                VARCHAR2    N
-- p_attribute13                VARCHAR2    N
-- p_attribute14                VARCHAR2    N
-- p_attribute15                VARCHAR2    N
-- x_return_status              VARCHAR2    N           Return Status
-- x_msg_count                  NUMBER      N           Message Count
-- x_msg_data                   VARCHAR2    N           Message Data

PROCEDURE Create_Deliverable
    (
       p_api_version            IN  NUMBER     := 1.0
     , p_init_msg_list          IN  VARCHAR2   := FND_API.G_TRUE
     , p_commit                 IN  VARCHAR2   := FND_API.G_FALSE
     , p_validate_only          IN  VARCHAR2   := FND_API.G_TRUE
     , p_validation_level       IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module         IN  VARCHAR2   := 'SELF_SERVICE'
     , p_debug_mode             IN  VARCHAR2   := 'N'
     , p_max_msg_count          IN  NUMBER     := NULL
     , p_record_version_number  IN  NUMBER     := 1
     , p_object_type            IN  PA_PROJ_ELEMENTS.OBJECT_TYPE%TYPE      := 'PA_DELIVERABLES'
     , p_project_id             IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
     , p_dlvr_number            IN  PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE
     , p_dlvr_name              IN  PA_PROJ_ELEMENTS.NAME%TYPE
     , p_dlvr_description       IN  PA_PROJ_ELEMENTS.DESCRIPTION%TYPE          := NULL
     , p_dlvr_owner_id          IN  PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE    := NULL
     , p_dlvr_owner_name        IN  VARCHAR2    := NULL
     , p_carrying_out_org_id    IN  PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE := NULL
     , p_carrying_out_org_name  IN  VARCHAR2    := NULL
     , p_dlvr_version_id        IN  PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE := NULL
     , p_status_code            IN  PA_PROJ_ELEMENTS.STATUS_CODE%TYPE              := NULL
     , p_parent_structure_id    IN  PA_PROJ_ELEMENTS.PARENT_STRUCTURE_ID%TYPE      := NULL
     , p_dlvr_type_id           IN  PA_PROJ_ELEMENTS.TYPE_ID%TYPE                  := NULL
     , p_dlvr_type_name         IN  VARCHAR2    := NULL
     , p_progress_weight        IN  PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE          := NULL
     , p_scheduled_finish_date  IN  PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE        := NULL
     , p_actual_finish_date     IN  PA_PROJ_ELEM_VER_SCHEDULE.ACTUAL_FINISH_DATE%TYPE        := NULL
     , p_task_id                IN  NUMBER     := NULL
     , p_task_version_id        IN  NUMBER     := NULL
     , p_task_name              IN  VARCHAR2   := NULL
     , p_deliverable_reference  IN  VARCHAR2   := NULL
     , p_attribute_category     IN  PA_PROJ_ELEMENTS.ATTRIBUTE_CATEGORY%TYPE    := NULL
     , p_attribute1             IN  PA_PROJ_ELEMENTS.ATTRIBUTE1%TYPE := NULL
     , p_attribute2             IN  PA_PROJ_ELEMENTS.ATTRIBUTE2%TYPE := NULL
     , p_attribute3             IN  PA_PROJ_ELEMENTS.ATTRIBUTE3%TYPE := NULL
     , p_attribute4             IN  PA_PROJ_ELEMENTS.ATTRIBUTE4%TYPE := NULL
     , p_attribute5             IN  PA_PROJ_ELEMENTS.ATTRIBUTE5%TYPE := NULL
     , p_attribute6             IN  PA_PROJ_ELEMENTS.ATTRIBUTE6%TYPE := NULL
     , p_attribute7             IN  PA_PROJ_ELEMENTS.ATTRIBUTE7%TYPE := NULL
     , p_attribute8             IN  PA_PROJ_ELEMENTS.ATTRIBUTE8%TYPE := NULL
     , p_attribute9             IN  PA_PROJ_ELEMENTS.ATTRIBUTE9%TYPE := NULL
     , p_attribute10            IN  PA_PROJ_ELEMENTS.ATTRIBUTE10%TYPE := NULL
     , p_attribute11            IN  PA_PROJ_ELEMENTS.ATTRIBUTE11%TYPE := NULL
     , p_attribute12            IN  PA_PROJ_ELEMENTS.ATTRIBUTE12%TYPE := NULL
     , p_attribute13            IN  PA_PROJ_ELEMENTS.ATTRIBUTE13%TYPE := NULL
     , p_attribute14            IN  PA_PROJ_ELEMENTS.ATTRIBUTE14%TYPE := NULL
     , p_attribute15            IN  PA_PROJ_ELEMENTS.ATTRIBUTE15%TYPE := NULL
     , p_item_id                IN  NUMBER        := NULL
     , p_inventory_org_id       IN  NUMBER        := NULL
     , p_quantity               IN  NUMBER        := NULL
     , p_uom_code               IN  VARCHAR2      := NULL
     , p_item_description       IN  VARCHAR2      := NULL
     , p_unit_price             IN  NUMBER        := NULL
     , p_unit_number            IN  VARCHAR2      := NULL
     , p_currency_code          IN  VARCHAR2      := NULL
     , p_pm_source_code         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR              /* Bug no. 3651113 */
     , p_dlvr_item_id           OUT  NOCOPY PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE --File.Sql.39 bug 4440895
     , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
IS

l_msg_count                     NUMBER := 0;
l_element_id                    NUMBER := NULL;
l_data                          VARCHAR2(2000);
l_return_status                 VARCHAR2(1);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_structure_type                VARCHAR2(150)   := 'DELIVERABLE';
l_structure_id                  NUMBER;
l_element_structure_id          NUMBER;
is_dlvr_number_unique           VARCHAR2(1)     := 'N';
l_carrying_out_org              NUMBER          :=  NULL;

l_dlvr_description          PA_PROJ_ELEMENTS.DESCRIPTION%TYPE;
l_dlvr_owner_id             PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE;
l_carrying_out_org_id       PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE;
l_progress_weight           PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE;
l_scheduled_finish_date     DATE;
l_actual_finish_date        DATE;
l_dlvr_version_id           PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;

l_dlvr_prg_enabled          VARCHAR2(1)     := NULL;
l_dlvr_action_enabled       VARCHAR2(1)     := NULL;
l_status_code               Pa_task_types.initial_status_code%TYPE := NULL;


l_item_dlv                  VARCHAR2(1)     := NULL;
l_dlv_rec                   oke_amg_grp.dlv_rec_type;

l_project_number            Pa_Projects_All.Segment1%TYPE;
l_task_number               Pa_Proj_Elements.Name%TYPE;

l_item_id                   OKE_DELIVERABLES_B.ITEM_ID%TYPE;
l_inventory_org_id          OKE_DELIVERABLES_B.INVENTORY_ORG_ID%TYPE;
l_quantity                  OKE_DELIVERABLES_B.QUANTITY%TYPE;
l_uom_code                  OKE_DELIVERABLES_B.UOM_CODE%TYPE;
l_item_description          VARCHAR2(2000);
l_unit_price                OKE_DELIVERABLES_B.UNIT_PRICE%TYPE;
l_unit_number               OKE_DELIVERABLES_B.UNIT_NUMBER%TYPE;
l_currency_code             OKE_DELIVERABLES_B.CURRENCY_CODE%TYPE;
l_dlv_elem_ver_id           PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
l_master_inv_org_id         PA_PLAN_RES_DEFAULTS.item_master_id%TYPE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'CREATE_DELIVERABLE',
                                     p_debug_mode => l_debug_mode );
    END IF;

/*==============3435905 : FP M : Deliverables Changes For AMG - START ==============================*/

    IF p_dlvr_description  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     THEN
       l_dlvr_description := NULL;
    ELSE
       l_dlvr_description := p_dlvr_description;
    END IF;

    IF p_dlvr_owner_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
       l_dlvr_owner_id := NULL;
    ELSE
       l_dlvr_owner_id := p_dlvr_owner_id;
    END IF;

    IF p_carrying_out_org_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
       l_carrying_out_org_id := NULL;
    ELSE
       l_carrying_out_org_id := p_carrying_out_org_id;
    END IF;

    IF p_status_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     THEN
       l_status_code := NULL;
    ELSE
       l_status_code := p_status_code;
    END IF;

    IF p_progress_weight  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
       l_progress_weight := NULL;
    ELSE
       l_progress_weight := p_progress_weight;
    END IF;

    IF p_scheduled_finish_date  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     THEN
       l_scheduled_finish_date := NULL;
    ELSE
       l_scheduled_finish_date := p_scheduled_finish_date;
    END IF;

    IF p_actual_finish_date  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     THEN
       l_actual_finish_date := NULL;
    ELSE
       l_actual_finish_date := p_actual_finish_date;
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

 /*==============3435905 : FP M : Deliverables Changes For AMG - END ============================== */
    IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'CREATE_DELIVERABLE : Printing Input parameters';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_PROJECT_ID '||':'|| p_project_id,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_DLVR_NUMBER '||':'|| p_dlvr_number,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_DLVR_NAME '||':'|| p_dlvr_name,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_DLVR_TYPE_ID '||':'|| p_dlvr_type_id,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_DLVR_TYPE_NAME '||':'|| p_dlvr_type_name,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_TASK_VERSION_ID '||':'|| p_task_version_id,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_TASK_NAME '||':'|| p_task_name,
                                    l_debug_level3);
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
       savepoint CREATE_DLVR_PUB;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'Validating Input parameters';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
    END IF;

    -- Input parameter Validation Logic

    --Bug Number 3861930
    --Negative Progress Weight Entry Should not be allowed

    IF p_progress_weight IS NOT NULL AND p_progress_weight < 0 THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => 'PA_NEG_PRG_NOT_ALLOWED');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    --End Bug Number 3861930

/*==============3435905 : FP M : Deliverables Changes For AMG - START ==============================*/
    IF (p_calling_module = 'AMG') THEN
      Pa_Deliverable_Utils.Validate_Deliverable
     (
        p_deliverable_id         =>  null
      , p_deliverable_reference  =>  p_deliverable_reference
      , p_dlvr_number            =>  p_dlvr_number
      , p_dlvr_name              =>  p_dlvr_name
      , px_dlvr_owner_id         =>  l_dlvr_owner_id
      , p_dlvr_owner_name        =>  p_dlvr_owner_name
      , p_dlvr_type_id           =>  p_dlvr_type_id
      , px_actual_finish_date    =>  l_actual_finish_date
      , px_progress_weight       =>  l_progress_weight
      , p_carrying_out_org_id    =>  p_carrying_out_org_id
      , px_status_code           =>  l_status_code
      , p_project_id             =>  p_project_id
      , p_task_id                =>  p_task_id
      , p_calling_mode           =>  'INSERT'
      , x_return_status          =>  x_return_status
      , x_msg_count              =>  x_msg_count
      , x_msg_data               =>  x_msg_data
      );

       IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Validated deliverable returns ['||x_return_status||']';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
       END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- Fetch dlvr_version_id from sequence
       SELECT PA_PROJ_ELEMENT_VERSIONS_S.nextval
       INTO   l_dlvr_version_id
       FROM    DUAL;

/*==============3435905 : FP M : Deliverables Changes For AMG - END ============================== */

    ELSE /* context <> 'AMG' */
        IF (p_project_id IS NULL ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF (p_dlvr_number IS NULL ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF (p_dlvr_name IS NULL ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF (p_dlvr_type_id IS NULL ) THEN
            IF (p_dlvr_type_name IS NULL ) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;


       IF (p_dlvr_version_id IS NULL ) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
           l_dlvr_version_id := p_dlvr_version_id;
       END IF;

   END IF;
    -- Business Logic

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Retrieving Carrying Out Organization Information ',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_DELIVERABLE_UTILS.get_carrying_out_org called ',
                                    l_debug_level3);
    END IF;

    -- retrieve carrying_out_organization_id

    l_carrying_out_org := PA_DELIVERABLE_UTILS.get_carrying_out_org
                                (
                                     p_project_id       => p_project_id
                                    ,p_task_id          => p_task_id
                                );

    IF (l_carrying_out_org IS NULL ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE Invalid_Arg_Exc_WP;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_DELIVERABLE_UTILS.get_carrying_out_org ',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Retrieving Structure Information ',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_DELIVERABLE_UTILS.get_structure_info called ',
                                    l_debug_level3);
    END IF;

    -- retrieve structure information

    PA_DELIVERABLE_UTILS.get_structure_info
        (
             p_project_id           =>  p_project_id
            ,P_structure_type       =>  l_structure_type
            ,X_proj_element_id      =>  l_structure_id
            ,X_element_version_id   =>  l_element_structure_id
            ,x_return_status        =>  x_return_status
            ,x_msg_count            =>  x_msg_count
            ,x_msg_data             =>  x_msg_data
        );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_DELIVERABLE_UTILS.get_structure_info ',
                                    l_debug_level3);
    END IF;


--    l_status_code := p_status_code;

    -- retrieve default status code, if not passed

    IF l_status_code IS NULL THEN

        -- call PA_DELIVERABLE_UTILS.get_dlvr_type_info to retrieve default status code

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' PA_DELIVERABLE_UTILS.get_dlvr_type_info called ',
                                        l_debug_level3);
        END IF;

        PA_DELIVERABLE_UTILS.get_dlvr_type_info
            (
                p_dlvr_type_id              =>  p_dlvr_type_id,
                x_dlvr_prg_enabled          =>  l_dlvr_prg_enabled,
                x_dlvr_action_enabled       =>  l_dlvr_action_enabled,
                x_dlvr_default_status_code  =>  l_status_code
            );

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' Out of PA_DELIVERABLE_UTILS.get_dlvr_type_info ',
                                        l_debug_level3);
        END IF;

    END IF;


    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Checking Uniqueness for Deliverable Number ',
                                    l_debug_level3);
    END IF;

    -- check for dlvr_number uniqueness
    -- check for dlvr_number uniqueness

    is_dlvr_number_unique := PA_PROJ_ELEMENTS_UTILS.Check_element_NUmber_Unique
                                (
                                     p_element_number   => p_dlvr_number
                                    ,p_element_id       => l_element_id
                                    ,p_project_id       => p_project_id
                                    ,p_structure_id     => l_structure_id
                                    ,p_object_type      => p_object_type
                                );
    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Dlvr Num Unique['||p_dlvr_number||']['||is_dlvr_number_unique||']', l_debug_level3);
    END IF;
    -- if is_dlvr_number_unique is 'N' return with error

    IF (is_dlvr_number_unique = 'N' ) THEN
        IF (p_calling_module = 'AMG') THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN

              l_err_message := FND_MESSAGE.GET_STRING('PA','DLVR_NUMBER_DUPLICATE') ;
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
    END IF; /* context=AMG */
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_DLVR_NUMBER_EXISTS');
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- else call create_deliveable procedure of pa_deliveable_pvt package

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Calling  PA_DELIVERABLE_PVT.Create_Deliverable',
                                    l_debug_level3);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_DELIVERABLE_PVT.Create_Deliverable
        (
             p_api_version             =>   p_api_version
            ,p_init_msg_list           =>   FND_API.G_FALSE
            ,p_commit                  =>   p_commit
            ,p_validate_only           =>   p_validate_only
            ,p_validation_level        =>   p_validation_level
            ,p_calling_module          =>   p_calling_module
            ,p_debug_mode              =>   l_debug_mode
            ,p_max_msg_count           =>   p_max_msg_count
            ,p_record_version_number   =>   p_record_version_number
            ,p_object_type             =>   p_object_type
            ,p_project_id              =>   p_project_id
            ,p_dlvr_number             =>   p_dlvr_number
            ,p_dlvr_name               =>   p_dlvr_name
            ,p_dlvr_description        =>   l_dlvr_description
            ,p_dlvr_owner_id           =>   l_dlvr_owner_id
            ,p_dlvr_owner_name         =>   p_dlvr_owner_name
            ,p_carrying_out_org_id     =>   l_carrying_out_org
            ,p_carrying_out_org_name   =>   p_carrying_out_org_name
            ,p_dlvr_version_id         =>   l_dlvr_version_id
            ,p_status_code             =>   l_status_code
            ,p_parent_structure_id     =>   l_structure_id
            ,p_parent_struct_ver_id    =>   l_element_structure_id
            ,p_dlvr_type_id            =>   p_dlvr_type_id
            ,p_dlvr_type_name          =>   p_dlvr_type_name
            ,p_dlvr_reference          =>   p_deliverable_reference
            ,p_progress_weight         =>   l_progress_weight
            ,p_scheduled_finish_date   =>   l_scheduled_finish_date
            ,p_actual_finish_date      =>   l_actual_finish_date
            ,p_task_id                 =>   p_task_id
            ,p_task_version_id         =>   p_task_version_id
            ,p_task_name               =>   p_task_name
            ,p_attribute_category      =>   p_attribute_category
            ,p_attribute1              =>   p_attribute1
            ,p_attribute2              =>   p_attribute2
            ,p_attribute3              =>   p_attribute3
            ,p_attribute4              =>   p_attribute4
            ,p_attribute5              =>   p_attribute5
            ,p_attribute6              =>   p_attribute6
            ,p_attribute7              =>   p_attribute7
            ,p_attribute8              =>   p_attribute8
            ,p_attribute9              =>   p_attribute9
            ,p_attribute10             =>   p_attribute10
            ,p_attribute11             =>   p_attribute11
            ,p_attribute12             =>   p_attribute12
            ,p_attribute13             =>   p_attribute13
            ,p_attribute14             =>   p_attribute14
            ,p_attribute15             =>   p_attribute15
            ,p_dlvr_item_id            =>   p_dlvr_item_id
            ,p_pm_source_code          =>   p_pm_source_code              /* Bug no. 3651113 */
            ,x_return_status           =>   x_return_status
            ,x_msg_count               =>   l_msg_count
            ,x_msg_data                =>   l_msg_data
        );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Returned from PA_DELIVERABLE_PVT.Create_Deliverable['||x_return_status||']',
                                    l_debug_level3);
    END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
/*==============3435905 : FP M : Deliverables Changes For AMG - START ==============================*/
    IF (p_calling_module = 'AMG') THEN

       -- 3630378 changed below cursor to retrieve deliverable element version id

       SELECT Pa_Deliverable_Utils.IS_Dlvr_Item_Based(element_version_id), element_version_id
       INTO   l_item_dlv, l_dlv_elem_ver_id
       FROM   Pa_Proj_Element_Versions
       WHERE  proj_element_id = p_dlvr_item_id
       AND    project_id   = p_project_id;

       -- 3630378 Added below code for item information

       IF p_item_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
          l_item_id := NULL;
       ELSE
          l_item_id := p_item_id;
       END IF;

       IF p_inventory_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
          l_inventory_org_id := NULL;
       ELSE
          l_inventory_org_id := p_inventory_org_id;
       END IF;

       -- 3630378 added code to retrieve master inventory organization id

       PA_RESOURCE_UTILS1.Return_Material_Class_Id
                                (
                                     x_material_class_id     =>  l_master_inv_org_id
                                    ,x_return_status         =>  l_return_status
                                    ,x_msg_data              =>  l_msg_data
                                    ,x_msg_count             =>  l_msg_count
                                );

       IF p_quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
          l_quantity := NULL;
       ELSE
          l_quantity := p_quantity;
       END IF;

       IF p_uom_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     THEN
          l_uom_code := NULL;
       ELSE
          l_uom_code := p_uom_code;
       END IF;

       IF p_unit_price  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     THEN
          l_unit_price := NULL;
       ELSE
          l_unit_price := p_unit_price;
       END IF;

       IF p_unit_number  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     THEN
          l_unit_number := NULL;
       ELSE
          l_unit_number := p_unit_number;
       END IF;

       IF p_currency_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     THEN
          l_currency_code := NULL;
       ELSE
          l_currency_code := p_currency_code;
       END IF;

       -- 3630378 changed from input parameter passing to local variable passing
       -- this local variables are initialized to user passed values or
       -- null in above code

       l_dlv_rec.dlv_short_name       :=    p_dlvr_number           ;
       l_dlv_rec.dlv_description      :=    l_dlvr_description      ;
       l_dlv_rec.item_id              :=    l_item_id               ;
       l_dlv_rec.inventory_org_id     :=    l_inventory_org_id      ;
       l_dlv_rec.quantity             :=    l_quantity              ;
       l_dlv_rec.uom_code             :=    l_uom_code              ;
       l_dlv_rec.unit_price           :=    l_unit_price            ;
       l_dlv_rec.unit_number          :=    l_unit_number           ;
       l_dlv_rec.pa_deliverable_id    :=    l_dlv_elem_ver_id       ;
       l_dlv_rec.project_id           :=    p_project_id            ;
       l_dlv_rec.currency_code        :=    l_currency_code         ;

       -- 3630378 end

       -- 3630378 changed parameter passing
       -- passing l_master_inv_org_id instead of 0

       oke_amg_grp.manage_dlv
       (  p_api_version          =>  p_api_version
        , p_init_msg_list        =>  p_init_msg_list
        , p_commit               =>  FND_API.G_FALSE
        , p_action               =>  'CREATE'
        , p_item_dlv             =>  l_item_dlv
        , p_master_inv_org_id    =>  l_master_inv_org_id
        , p_dlv_rec              =>  l_dlv_rec
        , x_return_status        =>  x_return_status
        , x_msg_data             =>  x_msg_data
        , x_msg_count            =>  x_msg_count
        );

    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Returned from oke_amg_grp.manage_dlv['||x_return_status||']',
                                    l_debug_level3);
    END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

/*==============3435905 : FP M : Deliverables Changes For AMG - END ==============================*/

    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO CREATE_DLVR_PUB;
     END IF;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_DELIVERABLE_PUB : Create_Deliverable : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO CREATE_DLVR_PUB;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_DELIVERABLE_PUB'
                    , p_procedure_name  => 'Create_Deliverable'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO CREATE_DLVR_PUB;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_DELIVERABLE_PUB'
                    , p_procedure_name  => 'Create_Deliverable'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END Create_Deliverable;


-- Procedure            : Update_Deliverable
-- Type                 : PUBLIC
-- Purpose              : Create Deliveable Page calls this procedure to create deliverables
-- Note                 : Check for input parameter validations and short name uniqueness.
--                      : Retrieve carrying_out_organization_id and structure_info.
--                      : Call Update_Deliverable procedure of the pa_deliverable_pvt package.
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_api_version                NUMBER      N           1.0
-- p_init_msg_list              VARCHAR2    N           := FND_API.G_TRUE
-- p_commit                     VARCHAR2    N           := FND_API.G_FALSE
-- p_validate_only              VARCHAR2    N           := FND_API.G_TRUE
-- p_validation_level           NUMBER      N           := FND_API.G_VALID_LEVEL_FULL
-- p_calling_module             VARCHAR2    N           := 'SELF_SERVICE'
-- p_debug_mode                 VARCHAR2    N           := 'N'
-- p_max_msg_count              NUMBER      N           := NULL
-- p_record_version_number      NUMBER      N           := 1
-- p_object_type                VARCHAR2    N           Object Type Default 'PA_DELIVERABLES'
-- p_project_id                 NUMBER      Y             Project Id
-- p_dlvr_number                VARCHAR2    Y             Deliverable Number
-- p_dlvr_name                  VARCHAR2    Y             Deliverable Name
-- p_dlvr_description           VARCHAR2    N             Description
-- p_dlvr_owner_id              NUMBER      N           Deliverable Owner Id
-- p_dlvr_owner_name            VARCHAR2    N             Delivearble Owner Name
-- p_carrying_out_org_id        NUMBER      N             Project Carrying Out Organization Id
-- p_carrying_out_org_name      VARCHAR2    N             Project Carrying Out Organization Name
-- p_dlvr_version_id            NUMBER      N             Deliverable Version Id
-- p_status_code                VARCHAR2    N             Delivearble Status
-- p_parent_structure_id        NUMBER      N           Deliverable Parent Structure Id
-- p_dlvr_type_id               NUMBER      N           Deliverable Type Id
-- p_dlvr_type_name             VARCHAR2    N           Deliverable Type Name
-- p_progress_weight            NUMBER      N           Progress Weight
-- p_scheduled_finish_date      DATE        N           Scheduled Finish Date
-- p_actual_finish_date         DATE        N           Actual Finish Date
-- p_task_id                    NUMBER      N
-- p_task_version_id            NUMBER      N
-- p_task_name                  VARCHAR2    N
-- p_attribute_category         VARCHAR2    N
-- p_attribute1                 VARCHAR2    N
-- p_attribute2                 VARCHAR2    N
-- p_attribute3                 VARCHAR2    N
-- p_attribute4                 VARCHAR2    N
-- p_attribute5                 VARCHAR2    N
-- p_attribute6                 VARCHAR2    N
-- p_attribute7                 VARCHAR2    N
-- p_attribute8                 VARCHAR2    N
-- p_attribute9                 VARCHAR2    N
-- p_attribute10                VARCHAR2    N
-- p_attribute11                VARCHAR2    N
-- p_attribute12                VARCHAR2    N
-- p_attribute13                VARCHAR2    N
-- p_attribute14                VARCHAR2    N
-- p_attribute15                VARCHAR2    N
-- x_return_status              VARCHAR2    N           Return Status
-- x_msg_count                  NUMBER      N           Message Count
-- x_msg_data                   VARCHAR2    N           Message Data

PROCEDURE Update_Deliverable
    (
       p_api_version            IN  NUMBER     := 1.0
     , p_init_msg_list          IN  VARCHAR2   := FND_API.G_TRUE
     , p_commit                 IN  VARCHAR2   := FND_API.G_FALSE
     , p_validate_only          IN  VARCHAR2   := FND_API.G_TRUE
     , p_validation_level       IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module         IN  VARCHAR2   := 'SELF_SERVICE'
     , p_debug_mode             IN  VARCHAR2   := 'N'
     , p_max_msg_count          IN  NUMBER     := NULL
     , p_record_version_number  IN  NUMBER     := 1
     , p_object_type            IN  PA_PROJ_ELEMENTS.OBJECT_TYPE%TYPE      := 'PA_DELIVERABLES'
     , p_project_id             IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
     , p_dlvr_number            IN  PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE
     , p_dlvr_name              IN  PA_PROJ_ELEMENTS.NAME%TYPE
     , p_dlvr_description       IN  PA_PROJ_ELEMENTS.DESCRIPTION%TYPE          := NULL
     , p_dlvr_owner_id          IN  PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE    := NULL
     , p_dlvr_owner_name        IN  VARCHAR2    := NULL
     , p_carrying_out_org_id    IN  PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE := NULL
     , p_carrying_out_org_name  IN  VARCHAR2    := NULL
     , p_dlvr_version_id        IN  PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE := NULL
     , p_status_code            IN  PA_PROJ_ELEMENTS.STATUS_CODE%TYPE              := NULL
     , p_parent_structure_id    IN  PA_PROJ_ELEMENTS.PARENT_STRUCTURE_ID%TYPE      := NULL
     , p_dlvr_type_id           IN  PA_PROJ_ELEMENTS.TYPE_ID%TYPE                  := NULL
     , p_dlvr_type_name         IN  VARCHAR2    := NULL
     , p_progress_weight        IN  PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE          := NULL
     , p_scheduled_finish_date  IN  PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE := NULL
     , p_actual_finish_date     IN  PA_PROJ_ELEM_VER_SCHEDULE.ACTUAL_FINISH_DATE%TYPE    := NULL
     , p_task_id                IN  NUMBER     := NULL
     , p_task_version_id        IN  NUMBER     := NULL
     , p_task_name              IN  VARCHAR2   := NULL
     , p_deliverable_reference  IN  VARCHAR2   := NULL
     , p_attribute_category     IN  PA_PROJ_ELEMENTS.ATTRIBUTE_CATEGORY%TYPE    := NULL
     , p_attribute1             IN  PA_PROJ_ELEMENTS.ATTRIBUTE1%TYPE := NULL
     , p_attribute2             IN  PA_PROJ_ELEMENTS.ATTRIBUTE2%TYPE := NULL
     , p_attribute3             IN  PA_PROJ_ELEMENTS.ATTRIBUTE3%TYPE := NULL
     , p_attribute4             IN  PA_PROJ_ELEMENTS.ATTRIBUTE4%TYPE := NULL
     , p_attribute5             IN  PA_PROJ_ELEMENTS.ATTRIBUTE5%TYPE := NULL
     , p_attribute6             IN  PA_PROJ_ELEMENTS.ATTRIBUTE6%TYPE := NULL
     , p_attribute7             IN  PA_PROJ_ELEMENTS.ATTRIBUTE7%TYPE := NULL
     , p_attribute8             IN  PA_PROJ_ELEMENTS.ATTRIBUTE8%TYPE := NULL
     , p_attribute9             IN  PA_PROJ_ELEMENTS.ATTRIBUTE9%TYPE := NULL
     , p_attribute10            IN  PA_PROJ_ELEMENTS.ATTRIBUTE10%TYPE := NULL
     , p_attribute11            IN  PA_PROJ_ELEMENTS.ATTRIBUTE11%TYPE := NULL
     , p_attribute12            IN  PA_PROJ_ELEMENTS.ATTRIBUTE12%TYPE := NULL
     , p_attribute13            IN  PA_PROJ_ELEMENTS.ATTRIBUTE13%TYPE := NULL
     , p_attribute14            IN  PA_PROJ_ELEMENTS.ATTRIBUTE14%TYPE := NULL
     , p_attribute15            IN  PA_PROJ_ELEMENTS.ATTRIBUTE15%TYPE := NULL
     , p_item_id                IN  NUMBER        := NULL
     , p_inventory_org_id       IN  NUMBER        := NULL
     , p_quantity               IN  NUMBER        := NULL
     , p_uom_code               IN  VARCHAR2      := NULL
     , p_item_description       IN  VARCHAR2      := NULL
     , p_unit_price             IN  NUMBER        := NULL
     , p_unit_number            IN  VARCHAR2      := NULL
     , p_currency_code          IN  VARCHAR2      := NULL
     , p_dlvr_item_id           IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     , p_pm_source_code         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR              /* Bug no. 3651113 */
     , x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

 l_dlvr_name                     PA_PROJ_ELEMENTS.NAME%TYPE;
 l_dlvr_description              PA_PROJ_ELEMENTS.DESCRIPTION%TYPE;
 l_dlvr_owner_id                 PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE;
 l_carrying_out_org_id           PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE;
 l_progress_weight               PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE;
 l_scheduled_finish_date         DATE;
 l_actual_finish_date            DATE;
 l_dlvr_version_id               PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
 l_status_code                   PA_PROJ_ELEMENTS.STATUS_CODE%TYPE;
 l_dlvr_type_id                  PA_PROJ_ELEMENTS.TYPE_ID%TYPE;
 l_task_id                       PA_TASKS.TASK_ID%TYPE; --added bug 3651538
 l_deliverable_reference         PA_PROJ_ELEMENTS.PM_SOURCE_CODE%TYPE; -- added for bug# 3749447

 l_structure_type                VARCHAR2(150) := 'DELIVERABLE';
 l_structure_id                  NUMBER;
 l_element_structure_id          NUMBER;
 is_dlvr_number_unique           VARCHAR2(1) := 'N';
 l_carrying_out_org              NUMBER;

 l_item_id                   OKE_DELIVERABLES_B.ITEM_ID%TYPE                    ;
 l_inventory_org_id          OKE_DELIVERABLES_B.INVENTORY_ORG_ID%TYPE           ;
 l_quantity                  OKE_DELIVERABLES_B.QUANTITY%TYPE                   ;
 l_uom_code                  OKE_DELIVERABLES_B.UOM_CODE%TYPE                   ;
 l_item_description          OKE_DELIVERABLES_TL.DESCRIPTION%TYPE               ;
 l_unit_price                OKE_DELIVERABLES_B.UNIT_PRICE%TYPE                 ;
 l_unit_number               OKE_DELIVERABLES_B.UNIT_NUMBER%TYPE                ;
 l_currency_code             OKE_DELIVERABLES_B.CURRENCY_CODE%TYPE              ;
 l_item_dlv                  VARCHAR2(1)                                        ;

  Cursor C_dlvr IS SELECT
     decode( p_dlvr_name           ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, element_name, p_dlvr_name)  element_name
   , decode( p_dlvr_description    ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, description , p_dlvr_description) description
   , decode( p_dlvr_owner_id       ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, manager_person_id, p_dlvr_owner_id) manager_person_id
   , decode( p_carrying_out_org_id ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, null        , p_carrying_out_org_id) carrying_out_org_id -- to be derived later
   , decode( p_status_code         ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,status_code , p_status_code)  status_code
   , decode( p_dlvr_type_id        ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, dlvr_type_id, p_dlvr_type_id) dlvr_type_id
   , decode( p_progress_weight     ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, progress_weight, p_progress_weight) progress_weight
   , decode( p_scheduled_finish_date, PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,due_date , p_scheduled_finish_date) due_date
   , decode( p_actual_finish_date  ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,completion_date, p_actual_finish_date) completion_date
   , decode( p_task_id             ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, null           , p_task_id) task_id  -- added bug 3651538
   , decode( p_deliverable_reference, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, pm_source_reference, p_deliverable_reference) pm_source_reference -- added for bug# 3749447
  FROM  pa_deliverables_v
  WHERE element_version_id = p_dlvr_version_id;

  Cursor C_oke IS SELECT
     decode( p_item_id          ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , item_id, p_item_id) item_id
   , decode( p_inventory_org_id ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , inventory_org_id, p_inventory_org_id) inventory_org_id
   , decode( p_quantity         ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , quantity, p_quantity) quantity
   , decode( p_uom_code         ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , uom_code, p_uom_code) uom_code
   , decode( p_item_description ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , description, p_item_description) description
   , decode( p_unit_price       ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  , unit_price, p_unit_price) unit_price
   , decode( p_unit_number      ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , unit_number, p_unit_number) unit_number -- 3749447 changed from G_PA_MISS_NUM to G_PA_MISS_CHAR
   , decode( p_currency_code    ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR , currency_code, p_currency_code) currency_code
 FROM  oke_deliverables_vl
 WHERE source_deliverable_id = p_dlvr_version_id; -- 3749447 changed where clause condition from deliverable_number = p_dlvr_number to use deliverable ver id

 l_dlv_rec                       oke_amg_grp.dlv_rec_type;

 -- added for bug# 3651542
 l_dlv_elem_ver_id           PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
 l_master_inv_org_id         PA_PLAN_RES_DEFAULTS.item_master_id%TYPE;
 l_return_status             VARCHAR2(1);
-- end bug#  3651542

 l_manage_dlv_flag           VARCHAR2(1); -- Bug 7562076

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'UPDATE_DELIVERABLE',
                                     p_debug_mode => l_debug_mode );
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'UPDATE_DELIVERABLE : Printing Input parameters';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_PROJECT_ID '||':'|| p_project_id,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_DLVR_NUMBER '||':'|| p_dlvr_number,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_DLVR_NAME '||':'|| p_dlvr_name,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_DLVR_TYPE_ID '||':'|| p_dlvr_type_id,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_DLVR_TYPE_NAME '||':'|| p_dlvr_type_name,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_TASK_VERSION_ID '||':'|| p_task_version_id,
                                    l_debug_level3);
       Pa_Debug.WRITE(g_module_name,' P_TASK_NAME '||':'|| p_task_name,
                                    l_debug_level3);
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
       savepoint UPDATE_DLVR_PUB;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'Validating Input parameters';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
    END IF;

    -- Input parameter Validation Logic

    --Bug 3861930 negative progress weight should not be allowed

    IF p_progress_weight IS NOT NULL AND p_progress_weight < 0 THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => 'PA_NEG_PRG_NOT_ALLOWED');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    --End 3861930
/*==============3435905 : FP M : Deliverables Changes For AMG - START ==============================*/
    IF (p_calling_module = 'AMG') THEN

--  Fetching the values from database.
--  If passed value is MISS_CHAR or MISS_NUM or MISS_DATE then passed the fetched values.

       For C_dlvr_rec IN C_dlvr  LOOP

           l_dlvr_name             :=  C_dlvr_rec.element_name          ;
           l_dlvr_description      :=  C_dlvr_rec.description           ;
           l_dlvr_owner_id         :=  C_dlvr_rec.manager_person_id     ;
           l_carrying_out_org_id   :=  C_dlvr_rec.carrying_out_org_id   ;
           l_status_code           :=  C_dlvr_rec.status_code           ;
           l_dlvr_type_id          :=  C_dlvr_rec.dlvr_type_id          ;
           l_progress_weight       :=  C_dlvr_rec.progress_weight       ;
           l_scheduled_finish_date :=  C_dlvr_rec.due_date              ;
           l_actual_finish_date    :=  C_dlvr_rec.completion_date       ;
           l_task_id               :=  C_dlvr_rec.task_id               ;  -- added bug 3651538
           l_deliverable_reference :=  C_dlvr_rec.pm_source_reference   ;  -- added for bug# 3749447
        END LOOP;

        For C_oke_rec IN C_oke        LOOP

           l_item_id           :=  C_oke_rec.item_id            ;
           l_inventory_org_id  :=  C_oke_rec.inventory_org_id   ;
           l_quantity          :=  C_oke_rec.quantity           ;
           l_uom_code          :=  C_oke_rec.uom_code           ;
           l_item_description  :=  C_oke_rec.description        ;
           l_unit_price        :=  C_oke_rec.unit_price         ;
           l_unit_number       :=  C_oke_rec.unit_number        ;
           l_currency_code     :=  C_oke_rec.currency_code      ;
        END LOOP;

--  Validating the input parameters passed through AMG
    Pa_Deliverable_Utils.Validate_Deliverable
    (
        p_deliverable_id         =>  p_dlvr_item_id
      , p_deliverable_reference  =>  l_deliverable_reference -- changed for bug# 3749447
      , p_dlvr_number            =>  p_dlvr_number
      , p_dlvr_name              =>  l_dlvr_name
      , px_dlvr_owner_id         =>  l_dlvr_owner_id
      , p_dlvr_owner_name        =>  p_dlvr_owner_name
      , p_dlvr_type_id           =>  l_dlvr_type_id
      , p_carrying_out_org_id    =>  l_carrying_out_org_id
      , px_actual_finish_date    =>  l_actual_finish_date
      , px_progress_weight       =>  l_progress_weight
      , px_status_code           =>  l_status_code
      , p_project_id             =>  p_project_id
      , p_task_id                =>  l_task_id   -- changed p_task_id to l_task_id 3651538
      , p_calling_mode           =>  'UPDATE'
      , x_return_status          =>  x_return_status
      , x_msg_count              =>  x_msg_count
      , x_msg_data               =>  x_msg_data  );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

/*==============3435905 : FP M : Deliverables Changes For AMG - END ============================== */

    ELSE /* context <> 'AMG' */

        IF (p_project_id IS NULL ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF (p_dlvr_number IS NULL ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF (p_dlvr_name IS NULL ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF (p_dlvr_type_id IS NULL ) THEN
            IF (p_dlvr_type_name IS NULL ) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        IF (p_status_code IS NULL ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


        IF (p_dlvr_version_id IS NULL ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

       l_dlvr_name                :=  p_dlvr_name                ;
       l_dlvr_description         :=  p_dlvr_description         ;
       l_dlvr_owner_id            :=  p_dlvr_owner_id            ;
       l_carrying_out_org_id      :=  p_carrying_out_org_id      ;
      /* l_progress_weight          :=  p_dlvr_version_id          ; Commented by avaithia Bug 3518386*/
       l_progress_weight          :=  p_progress_weight          ; /*Included by avaithia  Bug 3518386*/
       l_scheduled_finish_date    :=  p_scheduled_finish_date    ;
       l_actual_finish_date       :=  p_actual_finish_date       ;
       l_status_code              :=  p_status_code              ;
       l_dlvr_type_id             :=  p_dlvr_type_id             ;
       l_task_id                  :=  p_task_id                  ;  -- added bug 3651538

       l_item_id                  :=  p_item_id                  ;
       l_inventory_org_id         :=  p_inventory_org_id         ;
       l_quantity                 :=  p_quantity                 ;
       l_uom_code                 :=  p_uom_code                 ;
       l_item_description         :=  p_item_description         ;
       l_unit_price               :=  p_unit_price               ;
       l_unit_number              :=  p_unit_number              ;
       l_currency_code            :=  p_currency_code            ;


    END IF; /* context =AMG */
    -- Business Logic

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE Invalid_Arg_Exc_WP;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_DELIVERABLE_UTILS.get_carrying_out_org ',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Retrieving Structure Information ',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_DELIVERABLE_UTILS.get_structure_info called ',
                                    l_debug_level3);
    END IF;

    -- retrieve structure information

    PA_DELIVERABLE_UTILS.get_structure_info
        (
             p_project_id           =>  p_project_id
            ,P_structure_type       =>  l_structure_type
            ,X_proj_element_id      =>  l_structure_id
            ,X_element_version_id   =>  l_element_structure_id
            ,x_return_status        =>  x_return_status
            ,x_msg_count            =>  x_msg_count
            ,x_msg_data             =>  x_msg_data
        );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_DELIVERABLE_UTILS.get_structure_info ',
                                    l_debug_level3);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Checking Uniqueness for Deliverable Number ',
                                    l_debug_level3);
    END IF;

    -- check for dlvr_number uniqueness

    is_dlvr_number_unique := PA_PROJ_ELEMENTS_UTILS.Check_element_NUmber_Unique
                                (
                                     p_element_number   => p_dlvr_number
                                    ,p_element_id       => p_dlvr_item_id
                                    ,p_project_id       => p_project_id
                                    ,p_structure_id     => l_structure_id
                                    ,p_object_type      => p_object_type
                                );

    -- if is_dlvr_number_unique is 'N' return with error

    IF (is_dlvr_number_unique = 'N' ) THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_DLVR_NUMBER_EXISTS');
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- else call update_deliveable procedure of pa_deliveable_pvt package

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Deliverable Number is unique',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Calling  PA_DELIVERABLE_PVT.Update_Deliverable',
                                    l_debug_level3);
    END IF;

    PA_DELIVERABLE_PVT.Update_Deliverable
        (
             p_api_version             =>   p_api_version
            ,p_init_msg_list           =>   FND_API.G_FALSE
            ,p_commit                  =>   p_commit
            ,p_validate_only           =>   p_validate_only
            ,p_validation_level        =>   p_validation_level
            ,p_calling_module          =>   p_calling_module
            ,p_debug_mode              =>   l_debug_mode
            ,p_max_msg_count           =>   p_max_msg_count
            ,p_record_version_number   =>   p_record_version_number
            ,p_object_type             =>   p_object_type
            ,p_project_id              =>   p_project_id
            ,p_dlvr_number             =>   p_dlvr_number
            ,p_dlvr_name               =>   l_dlvr_name
            ,p_dlvr_description        =>   l_dlvr_description
            ,p_dlvr_owner_id           =>   l_dlvr_owner_id
            ,p_dlvr_owner_name         =>   p_dlvr_owner_name
            ,p_carrying_out_org_id     =>   l_carrying_out_org
            ,p_carrying_out_org_name   =>   p_carrying_out_org_name
            ,p_dlvr_version_id         =>   p_dlvr_version_id
            ,p_status_code             =>   l_status_code
            ,p_parent_structure_id     =>   l_structure_id
            ,p_parent_struct_ver_id    =>   l_element_structure_id
            ,p_dlvr_type_id            =>   l_dlvr_type_id
            ,p_dlvr_type_name          =>   p_dlvr_type_name
            ,p_progress_weight         =>   l_progress_weight
            ,p_scheduled_finish_date   =>   l_scheduled_finish_date
            ,p_actual_finish_date      =>   l_actual_finish_date
            ,p_task_id                 =>   l_task_id -- changed p_task_id to l_task_id 3651538
            ,p_task_version_id         =>   p_task_version_id
            ,p_task_name               =>   p_task_name
            ,p_attribute_category      =>   p_attribute_category
            ,p_attribute1              =>   p_attribute1
            ,p_attribute2              =>   p_attribute2
            ,p_attribute3              =>   p_attribute3
            ,p_attribute4              =>   p_attribute4
            ,p_attribute5              =>   p_attribute5
            ,p_attribute6              =>   p_attribute6
            ,p_attribute7              =>   p_attribute7
            ,p_attribute8              =>   p_attribute8
            ,p_attribute9              =>   p_attribute9
            ,p_attribute10             =>   p_attribute10
            ,p_attribute11             =>   p_attribute11
            ,p_attribute12             =>   p_attribute12
            ,p_attribute13             =>   p_attribute13
            ,p_attribute14             =>   p_attribute14
            ,p_attribute15             =>   p_attribute15
            ,p_dlvr_item_id            =>   p_dlvr_item_id
            ,p_pm_source_code          =>   p_pm_source_code              /* Bug no. 3651113 */
            ,p_deliverable_reference   =>   l_deliverable_reference    -- added for bug# 3749447
            ,x_return_status           =>   x_return_status
            ,x_msg_count               =>   l_msg_count
            ,x_msg_data                =>   l_msg_data
        );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Returned from PA_DELIVERABLE_PVT.Update_Deliverable',
                                    l_debug_level3);
    END IF;


      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

/*==============3435905 : FP M : Deliverables Changes For AMG - START ==============================*/
    IF (p_calling_module = 'AMG') THEN

       -- 3651542 added element_version_id column in select statement
       -- this retrieved element_version_id will be passed to oke

       SELECT Pa_Deliverable_Utils.IS_Dlvr_Item_Based(element_version_id), element_version_id
       INTO   l_item_dlv, l_dlv_elem_ver_id
       FROM   Pa_Proj_Element_Versions
       WHERE  proj_element_id = p_dlvr_item_id
       AND    project_id   = p_project_id;

       -- Bug 7562076
       -- Added code to check if we are passing any input parameters to override the existing data present
       -- in oke tables.If we are not passing or if we are passing the values which are present in system
       -- then oke_amg_grp.manage_dlv is not required to be called.

       l_manage_dlv_flag := 'Y';

       IF (l_item_id IS NULL AND l_inventory_org_id IS NULL AND l_quantity IS NULL AND l_uom_code IS NULL AND
           l_unit_price IS NULL AND l_unit_number IS NULL AND l_currency_code IS NULL) THEN

           l_manage_dlv_flag := 'N';

       ELSE
                BEGIN
                  SELECT 'N' INTO l_manage_dlv_flag
                  FROM OKE_DELIVERABLES_B
                  WHERE project_id = p_project_id
                  AND source_deliverable_id = l_dlv_elem_ver_id
                  AND CURRENCY_CODE = l_currency_code
                  AND nvl(unit_number,-99) = nvl(l_unit_number,-99)
                  AND nvl(unit_price,-99) = nvl(l_unit_price,-99)
                  AND uom_code = l_uom_code
                  AND nvl(quantity,-99) = nvl(l_quantity,-99)
                  AND inventory_org_id = l_inventory_org_id
                  AND item_id = l_item_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_manage_dlv_flag := 'Y';
                END;

       END IF;

      IF l_manage_dlv_flag = 'Y' THEN

       l_dlv_rec.dlv_short_name       :=    p_dlvr_number           ;
       l_dlv_rec.dlv_description      :=    l_dlvr_description      ;
       l_dlv_rec.item_id              :=    l_item_id               ;
       l_dlv_rec.inventory_org_id     :=    l_inventory_org_id      ;
       l_dlv_rec.quantity             :=    l_quantity              ;
       l_dlv_rec.uom_code             :=    l_uom_code              ;
       l_dlv_rec.unit_price           :=    l_unit_price            ;
       l_dlv_rec.unit_number          :=    l_unit_number           ;
       -- 3651542 oke is expecting element_version_id of deliverable, earlier proj_element_id was passed
       -- passing deliverable element_version_id
       l_dlv_rec.pa_deliverable_id    :=    l_dlv_elem_ver_id       ;
       l_dlv_rec.project_id           :=    p_project_id            ;
       l_dlv_rec.currency_code        :=    l_currency_code         ;

       --  added below code to retrieve master inventory org id

       PA_RESOURCE_UTILS1.Return_Material_Class_Id
                                (
                                     x_material_class_id     =>  l_master_inv_org_id
                                    ,x_return_status         =>  l_return_status
                                    ,x_msg_data              =>  l_msg_data
                                    ,x_msg_count             =>  l_msg_count
                                );

       oke_amg_grp.manage_dlv
       (  p_api_version          =>  p_api_version
        , p_init_msg_list        =>  p_init_msg_list
        , p_commit               =>  FND_API.G_FALSE
        , p_action               =>  'UPDATE'
        , p_item_dlv             =>  l_item_dlv
        , p_master_inv_org_id    =>  l_master_inv_org_id -- 3651542 passing retrieved master inventory org id
        , p_dlv_rec              =>  l_dlv_rec
        , x_return_status        =>  x_return_status
        , x_msg_data             =>  x_msg_data
        , x_msg_count            =>  x_msg_count
       );

      END IF; -- Bug 7562076
    END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

/*==============3435905 : FP M : Deliverables Changes For AMG - END ==============================*/

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO UPDATE_DLVR_PUB;
     END IF;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_DELIVERABLE_PUB : Update_Deliverable : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO UPDATE_DLVR_PUB;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_DELIVERABLE_PUB'
                    , p_procedure_name  => 'Update_Deliverable'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO UPDATE_DLVR_PUB;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_DELIVERABLE_PUB'
                    , p_procedure_name  => 'Update_Deliverable'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END Update_Deliverable;

-- SubProgram           : DELETE_DLV_TASK_ASSOCIATION
-- Type                 : PROCEDURE
-- Purpose              : Public API to Delete Task - Deliverable Association
-- Note                 : Public API called from Task Detail and Deliverable Details Page
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
-- p_task_element_id               IN          NUMBER            N        Task Element Id
-- p_task_version_id               IN          NUMBER            N        Task Version Id
-- p_dlv_element_id                IN          NUMBER            N        Deliverable Element Id
-- p_dlv_version_id                IN          NUMBER            N        Deliverable Version Id
-- p_object_relationship_id        IN          NUMBER            N        Object Relationship Id
-- p_obj_rec_ver_number            IN          NUMBER            N        Record Version NUmber
-- p_project_id                    IN          NUMBER            N        Project Id
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter




PROCEDURE DELETE_DLV_TASK_ASSOCIATION
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_task_element_id     IN pa_proj_elements.proj_element_id%TYPE
     ,p_task_version_id     IN pa_proj_element_versions.element_version_id%TYPE
     ,p_dlv_element_id      IN pa_proj_elements.proj_element_id%TYPE
     ,p_dlv_version_id      IN pa_proj_element_versions.element_version_id%TYPE
     ,p_object_relationship_id IN pa_object_relationships.object_relationship_id%TYPE
     ,p_obj_rec_ver_number  IN pa_object_relationships.record_version_number%TYPE
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_calling_context     IN VARCHAR2 := 'TASKS'
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
     l_disassociation_allowed     VARCHAR2(1);

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_TASK_ASSOCIATION',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_TASK_ASSOCIATION ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Printing Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.write(g_module_name,'p_task_element_id  '||':'||p_task_element_id,3) ;
          pa_debug.write(g_module_name,'p_task_version_id'||':'||p_task_version_id,3) ;
          pa_debug.write(g_module_name,'p_dlv_element_id  '||':'||p_dlv_element_id,3) ;
          pa_debug.write(g_module_name,'p_dlv_version_id'||':'||p_dlv_version_id,3) ;
          pa_debug.write(g_module_name,'p_object_relationship_id'||':'||p_object_relationship_id,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DEL_DLV_TASK_ASSCN_PUB_SP ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_dlv_element_id IS NULL OR p_dlv_element_id IS NULL ) OR
        (p_task_element_id IS NULL OR p_task_version_id IS NULL)
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

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Calling PA_DELIVERABLE_PVT.DELETE_DLV_TASK_ASSOCIATION ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

    -- Call PA_DELIVERAB_PVT.DELETE_DLV_TASK_ASSOCIATION
    PA_DELIVERABLE_PVT.DELETE_DLV_TASK_ASSOCIATION
          (p_api_version           => p_api_version
          ,p_init_msg_list         => p_init_msg_list
          ,p_commit                => p_commit
          ,p_validate_only         => p_validate_only
          ,p_validation_level      => p_validation_level
          ,p_calling_module        => p_calling_module
          ,p_debug_mode            => l_debug_mode
          ,p_max_msg_count         => p_max_msg_count
          ,p_task_element_id       => p_task_element_id
          ,p_task_version_id       => p_task_version_id
          ,p_dlv_element_id        => p_dlv_element_id
          ,p_dlv_version_id        => p_dlv_version_id
          ,p_object_relationship_id => p_object_relationship_id
          ,p_obj_rec_ver_number    => p_obj_rec_ver_number
          ,p_project_id            => p_project_id
          ,p_calling_context       => p_calling_context
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting DELETE_DLV_TASK_ASSOCIATION' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO DEL_DLV_TASK_ASSCN_PUB_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DLV_TASK_ASSOCIATION';
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
           ROLLBACK TO DEL_DLV_TASK_ASSCN_PUB_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PUB'
                     ,p_procedure_name  => 'DELETE_DLV_TASK_ASSOCIATION');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_TASK_ASSOCIATION: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_TASK_ASSOCIATION ;

-- SubProgram           : DELETE_DELIVERABLES_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Public API to Delete Multiple Deliverables from Deliverable List Page
-- Note                 : This API is called from Deliverable List Page
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
-- p_dlv_element_id_tbl            IN          PLSQL Table       N        PLSQL table of Dlv Element Id
-- p_dlv_version_id_tbl            IN          PLSQL Table       N        PLSQL table of Dlv Version Id
-- p_rec_ver_number_tbl            IN          PLSQL Table       N        PLSQL Table of Rec. Version Number
-- p_dlv_name_tbl                  IN          PLSQL Table       N        PLSQL Table of Dlv. Name
-- p_dlv_number_tbl                IN          PLSQL Table       N        PLSQL Table of Dlv. Number
-- p_project_id                    IN          NUMBER            N        Project Id
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter

PROCEDURE DELETE_DELIVERABLES_IN_BULK
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_dlv_element_id_tbl  IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_dlv_version_id_tbl  IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_rec_ver_number_tbl  IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_dlv_name_tbl        IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_dlv_number_tbl      IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_msg_count         NUMBER := 0;
     l_msg_data          VARCHAR2(2000);
     l_return_status     VARCHAR2(1);
     l_dummy_app_name    VARCHAR2(30);
     l_enc_msg_data      VARCHAR2(2000);
     l_msg_name          VARCHAR2(30);
     l_msg_index_out     NUMBER ;
     l_debug_mode        VARCHAR2(1);

     TYPE l_error_msg_name_tbl_type IS TABLE OF
               fnd_new_messages.message_text%TYPE INDEX BY BINARY_INTEGER ;
     TYPE l_element_name_tbl_type IS TABLE OF
               pa_proj_elements.name%TYPE INDEX BY BINARY_INTEGER ;
     TYPE l_element_number_tbl_type IS TABLE OF
               pa_proj_elements.element_number%TYPE INDEX BY BINARY_INTEGER ;

     l_error_msg_name_tbl l_error_msg_name_tbl_type ;
     l_element_name_tbl   l_element_name_tbl_type ;
     l_element_number_tbl l_element_number_tbl_type ;
     j                  NUMBER ;

BEGIN
     l_msg_count := 0;
     l_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     j := 0 ;

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DELIVERABLES_IN_BULK',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DELIVERABLES_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     SAVEPOINT DELETE_DELIVERABLES ;

     IF nvl(p_dlv_element_id_tbl.LAST,0)>0 THEN
         IF l_debug_mode = 'Y' THEN
              pa_debug.debug('Some row is fetched for deletion');
         END IF ;
          FOR i in p_dlv_element_id_tbl.FIRST..p_dlv_element_id_tbl.LAST LOOP

         IF l_debug_mode = 'Y' THEN
              pa_debug.debug('Deliverable Element Id is :'||p_dlv_element_id_tbl(i));
              pa_debug.debug('record version id is :'||p_rec_ver_number_tbl(i));
         END IF ;

         -- initialization is required for every loop
         l_return_status := FND_API.G_RET_STS_SUCCESS ;
         l_msg_count := 0 ;
         l_msg_data := null ;

               PA_DELIVERABLE_PVT.DELETE_DELIVERABLE
                    (p_api_version      => p_api_version
                    ,p_init_msg_list    => p_init_msg_list
                    ,p_commit           => p_commit
                    ,p_validate_only    => p_validate_only
                    ,p_validation_level => p_validation_level
                    ,p_calling_module   => p_calling_module
                    ,p_debug_mode       => l_debug_mode
                    ,p_max_msg_count    => p_max_msg_count
                    ,p_dlv_element_id   => p_dlv_element_id_tbl(i)
                    ,p_dlv_version_id   => p_dlv_version_id_tbl(i)
                    ,p_rec_ver_number   => p_rec_ver_number_tbl(i)
                    ,p_project_id       => p_project_id
                    ,x_return_status    => l_return_status
                    ,x_msg_count        => l_msg_count
                    ,x_msg_data         => l_msg_data
                    );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                     j := j+1 ;


                    PA_INTERFACE_UTILS_PUB.get_messages
                            (p_encoded        => FND_API.G_FALSE,     -- Get the encoded message.
                             p_msg_index      => 1,                   -- Get the message at index 1.
                             p_data           => l_enc_msg_data,
                             p_msg_index_out  => l_msg_index_out);


                    l_error_msg_name_tbl(j) := l_enc_msg_data ;
                    l_element_name_tbl(j)   := p_dlv_name_tbl(i) ;
                    l_element_number_tbl(j) := p_dlv_number_tbl(i) ;


              END IF ;

          END LOOP ;

          IF j > 0 THEN

              ROLLBACK TO DELETE_DELIVERABLES;

              FND_MSG_PUB.initialize;

              FOR k IN l_element_name_tbl.FIRST..l_element_name_tbl.LAST  LOOP

                   PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_PS_TASK_NAME_NUM_ERR',
                         p_token1         => 'TASK_NAME',
                         p_value1         =>  l_element_name_tbl(k),
                         p_token2         => 'TASK_NUMBER',
                         p_value2         =>  l_element_number_tbl(k),
                         p_token3         => 'MESSAGE',
                         p_value3         =>  l_error_msg_name_tbl(k)
                         );


              END LOOP ;
          END IF ;
     END IF ;

     x_msg_count := FND_MSG_PUB.count_msg ;

    IF x_msg_count > 0 THEN
       x_return_status := 'E' ;
    END IF ;

    IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
    END IF ;

EXCEPTION
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     ROLLBACK TO DELETE_DELIVERABLES;

     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_DELIVERABLE_PUB'
              ,p_procedure_name => 'DELETE_DELIVERABLES_IN_BULK' );
     IF l_debug_mode = 'Y' THEN
             pa_debug.write('DELETE_DELIVERABLES_IN_BULK' || g_module_name,SQLERRM,4);
             pa_debug.write('DELETE_DELIVERABLES_IN_BULK' || g_module_name,pa_debug.G_Err_Stack,4);
             pa_debug.reset_curr_function;
     END IF;
     RAISE ;
END DELETE_DELIVERABLES_IN_BULK ;

-- SubProgram           : CREATE_ASSOCIATIONS_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Public API to Create associations from Associate Deliverable
--                        and Associate Tasks page .
-- Note                 : This API is called from Associate Deliverable and Associate Tasks page
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
-- p_element_id_tbl                IN          PLSQL Table       N        PLSQL table of Dlv Element Id
-- p_version_id_tbl                IN          PLSQL Table       N        PLSQL table of Dlv Version Id
-- p_element_name_tbl              IN          PLSQL Table       N        PLSQL Table of Dlv. Name
-- p_element_number_tbl            IN          PLSQL Table       N        PLSQL Table of Dlv. Number
-- p_task_or_dlv_elt_id            IN          NUMBER            Y        Task or deliverable element id
-- p_task_or_dlv_elt_id            IN          NUMBER            Y        Task or deliverable version id
-- p_project_id                    IN          NUMBER            N        Project Id
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter

-- How the data should be passed to this API ?
-- When called from ASSOCIATE DELIVERABLE page
     -- p_element_id_tbl will have all the element id of selected deliverables
     -- p_version_id_tbl will have all the version id of selected deliverables
     -- p_element_name_tbl will have selected deliverables name
     -- p_element_number_tbl will have selected deliverables name
     -- p_task_or_dlv_elt_id will have Task Id
     -- p_task_or_dlv_ver_id will have task version id
     -- p_project_id will have project id
     -- p_task_or_dlv will be 'PA_TASKS'
-- When called from ASSOCIATE TASKS page
     -- p_element_id_tbl will have all the element id of selected tasks
     -- p_version_id_tbl will have all the version id of selected tasks
     -- p_element_name_tbl will have selected tasks name
     -- p_element_number_tbl will have selected tasks name
     -- p_task_or_dlv_elt_id will have Deliverable element Id
     -- p_task_or_dlv_ver_id will have Deliverable version id
     -- p_project_id will have project id
     -- p_task_or_dlv will be 'PA_DELIVERABLES'

PROCEDURE CREATE_ASSOCIATIONS_IN_BULK
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_element_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_version_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_element_name_tbl    IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_number_tbl  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_task_or_dlv_elt_id  IN NUMBER
     ,p_task_or_dlv_ver_id  IN NUMBER
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_task_or_dlv         IN VARCHAR2 := 'PA_TASKS'
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
     l_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CREATE_ASSOCIATIONS_IN_BULK',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside CREATE_ASSOCIATIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
          SAVEPOINT CREATE_ASSOCIATIONS_SP ;
     END IF ;

     IF (p_task_or_dlv IS NULL OR p_task_or_dlv_elt_id IS NULL OR p_task_or_dlv_ver_id IS NULL )
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

     IF nvl(p_element_id_tbl.LAST,0)>0 THEN
          PA_DELIVERABLE_PVT.CREATE_ASSOCIATIONS_IN_BULK
               (p_api_version         => p_api_version
               ,p_init_msg_list       => FND_API.G_FALSE
               ,p_commit              => p_commit
               ,p_validate_only       => p_validate_only
               ,p_validation_level    => p_validation_level
               ,p_calling_module      => p_calling_module
               ,p_debug_mode          => l_debug_mode
               ,p_max_msg_count       => p_max_msg_count
               ,p_element_id_tbl      => p_element_id_tbl
               ,p_version_id_tbl      => p_version_id_tbl
               ,p_element_name_tbl    => p_element_name_tbl
               ,p_element_number_tbl  => p_element_number_tbl
               ,p_task_or_dlv_elt_id  => p_task_or_dlv_elt_id
               ,p_task_or_dlv_ver_id  => p_task_or_dlv_ver_id
               ,p_project_id          => p_project_id
               ,p_task_or_dlv         => p_task_or_dlv
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
          ) ;
     END IF ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF  l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CREATE_ASSOCIATIONS_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of CREATE_ASSOCIATIONS_IN_BULK';
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
           ROLLBACK TO CREATE_ASSOCIATIONS_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PUB'
                     ,p_procedure_name  => 'CREATE_ASSOCIATIONS_IN_BULK');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('CREATE_ASSOCIATIONS_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END CREATE_ASSOCIATIONS_IN_BULK ;

-- SubProgram           : DELETE_DELIVERABLE_STRUCTURE
-- Type                 : PROCEDURE
-- Purpose              : Public API to Delete Multiple Deliverables from Deliverable List Page
-- Note                 : This API is called from Deliverable List Page
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
-- p_project_id                    IN          NUMBER            N        Project Id
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter

PROCEDURE DELETE_DELIVERABLE_STRUCTURE
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_msg_count          NUMBER := 0;
     l_msg_data           VARCHAR2(2000);
     l_data               VARCHAR2(2000);
     l_return_status      VARCHAR2(1);
     l_msg_index_out      NUMBER ;
     l_debug_mode         VARCHAR2(1);
     l_proj_element_id    NUMBER ;
     l_element_version_id NUMBER ;
     l_return_flag        VARCHAR2(1);


BEGIN
     l_msg_count := 0;
     l_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DELIVERABLE_STRUCTURE',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DELIVERABLE_STRUCTURE ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
           SAVEPOINT DELETE_DELIVERABLE_STRUCTURE;
     END IF ;

     IF (p_project_id IS NULL )
     THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'INVALID INPUT PARAMETER';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                              ,p_msg_name        => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Calling PA_DELIVERABLE_PVT.DELETE_DELIVERABLE_STRUCTURE';
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Call the pvt API
     PA_DELIVERABLE_PVT.DELETE_DELIVERABLE_STRUCTURE
          (p_debug_mode     => l_debug_mode
          ,p_project_id     => p_project_id
          ,x_return_status  => x_return_status
          ,x_msg_count      => x_msg_count
          ,x_msg_data       => x_msg_data
          ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;


     IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO DELETE_DELIVERABLE_STRUCTURE;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DELIVERABLE_STRUCTURE';
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
           ROLLBACK TO DELETE_DELIVERABLE_STRUCTURE;
     END IF ;

     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_DELIVERABLE_PUB'
              ,p_procedure_name => 'DELETE_DELIVERABLE_STRUCTURE' );
     IF l_debug_mode = 'Y' THEN
             pa_debug.write('DELETE_DELIVERABLE_STRUCTURE' || g_module_name,SQLERRM,4);
             pa_debug.write('DELETE_DELIVERABLE_STRUCTURE' || g_module_name,pa_debug.G_Err_Stack,4);
             pa_debug.reset_curr_function;
     END IF;
     RAISE ;
END DELETE_DELIVERABLE_STRUCTURE ;

PROCEDURE DELETE_DLV_TASK_ASSCN_IN_BULK
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_calling_context     IN VARCHAR2 := 'PA_TASKS'
     ,p_task_element_id     IN pa_proj_elements.proj_element_id%TYPE
     ,p_task_version_id     IN pa_proj_element_versions.element_version_id%TYPE
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_delete_or_validate  IN VARCHAR2 := 'B'  -- 3955848 V- Validate , D - Delete, B - Validate and Delete
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
     l_dummy                      VARCHAR2(1) ;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_TASK_ASSCN_IN_BULK',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_TASK_ASSCN_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK TO DELETE_DLV_TASK_ASSCN_IN_BULK ;
     END IF ;

     -- 3651542 Removed "p_task_version_id IS NULL" check from below IF condition
     --  IF (p_task_element_id IS NULL OR p_task_version_id IS NULL OR p_project_id IS NULL )
     IF (p_task_element_id IS NULL OR p_project_id IS NULL )
     THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'INVALID INPUT PARAMETER';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                              ,p_msg_name        => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

    PA_DELIVERABLE_PVT.DELETE_DLV_TASK_ASSCN_IN_BULK
               (p_api_version         => p_api_version
               ,p_init_msg_list       => p_init_msg_list
               ,p_commit              => p_commit
               ,p_validate_only       => p_validate_only
               ,p_validation_level    => p_validation_level
               ,p_calling_module      => p_calling_module
               ,p_debug_mode          => l_debug_mode
               ,p_max_msg_count       => p_max_msg_count
               ,p_calling_context     => p_calling_context
               ,p_task_element_id     => p_task_element_id
               ,p_task_version_id     => p_task_version_id
               ,p_project_id          => p_project_id
               ,p_delete_or_validate  => p_delete_or_validate -- 3955848 passing it to pvt api
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
               ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting DELETE_DLV_TASK_ASSCN_IN_BULK' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DLV_TASK_ASSCN_IN_BULK';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK TO DELETE_DLV_TASK_ASSCN_IN_BULK ;
     END IF ;

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
          ROLLBACK TO DELETE_DLV_TASK_ASSCN_IN_BULK ;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PVT'
                             ,p_procedure_name  => 'DELETE_DLV_TASK_ASSCN_IN_BULK');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_TASK_ASSCN_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_TASK_ASSCN_IN_BULK ;

PROCEDURE DELETE_DLV_ASSOCIATIONS
     (p_api_version       IN NUMBER   :=1.0
     ,p_init_msg_list     IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit            IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only     IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level  IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module    IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode        IN VARCHAR2 :='N'
     ,p_max_msg_count     IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_project_id        IN NUMBER
     ,x_return_status     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;
     l_dummy                      VARCHAR2(1) ;
     l_return_flag                VARCHAR2(1) ;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_ASSOCIATIONS',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_TASK_ASSOCIATION ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_project_id IS NULL )
     THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'INVALID INPUT PARAMETER';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                              ,p_msg_name        => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Calling PA_DELIVERABLE_PVT.DELETE_DLV_ASSOCIATIONS';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

     PA_DELIVERABLE_PVT.DELETE_DLV_ASSOCIATIONS
          (p_api_version      => p_api_version
          ,p_init_msg_list    => p_init_msg_list
          ,p_commit           => p_commit
          ,p_validate_only    => p_validate_only
          ,p_validation_level => p_validation_level
          ,p_calling_module   => p_calling_module
          ,p_debug_mode       => l_debug_mode
          ,p_max_msg_count    => p_max_msg_count
          ,p_project_id       => p_project_id
          ,x_return_status    => x_return_status
          ,x_msg_count        => x_msg_count
          ,x_msg_data         => x_msg_data
          ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting DELETE_DLV_ASSOCIATIONS' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DLV_ASSOCIATIONS';
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

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PVT'
                             ,p_procedure_name  => 'DELETE_DLV_ASSOCIATIONS');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_ASSOCIATIONS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_ASSOCIATIONS ;

PROCEDURE COPY_DELIVERABLES
     (p_api_version          IN NUMBER   :=1.0
     ,p_init_msg_list        IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit               IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only        IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level     IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module       IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode           IN VARCHAR2 :='N'
     ,p_max_msg_count        IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_source_project_id    IN NUMBER
     ,p_target_project_id    IN NUMBER
     ,p_dlv_element_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_dlv_version_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_item_details_flag    IN VARCHAR2 := 'N'
     ,p_dlv_actions_flag     IN VARCHAR2 := 'N'
     ,p_dlv_attachments_flag IN VARCHAR2 := 'N'
     ,p_association_flag     IN VARCHAR2 := 'N'
     ,p_prefix               IN VARCHAR2 := null
     ,p_delta                IN NUMBER := null
     ,p_calling_context      IN VARCHAR2
     ,p_task_id              IN NUMBER :=null --Bug 3429393
     ,p_task_version_id      IN NUMBER :=null --Bug 3429393
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
     l_dummy                      VARCHAR2(1) ;
     l_return_flag                VARCHAR2(1) ;
BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'COPY_DELIVERABLES',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside COPY_DELIVERABLES ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;
     IF (p_commit = FND_API.G_TRUE) THEN
          SAVEPOINT COPY_DELIVERABLES_SP ;
     END IF ;
     --Bug 3429393
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'p_source_project_id is  '||p_source_project_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.g_err_stage:= 'p_target_project_id is  '||p_target_project_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.g_err_stage:= 'p_calling_context is  '||p_calling_context;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.g_err_stage:= 'p_task_id is  '||p_task_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.g_err_stage:= 'p_task_version_id is  '||p_task_version_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     PA_DELIVERABLE_PVT.COPY_DELIVERABLES
          (p_api_version          => p_api_version
          ,p_init_msg_list        => FND_API.G_FALSE
          ,p_debug_mode           => l_debug_mode
          ,p_source_project_id    => p_source_project_id
          ,p_target_project_id    => p_target_project_id
          ,p_dlv_element_id_tbl   => p_dlv_element_id_tbl
          ,p_dlv_version_id_tbl   => p_dlv_version_id_tbl
          ,p_item_details_flag    => p_item_details_flag
          ,p_dlv_actions_flag     => p_dlv_actions_flag
          ,p_dlv_attachments_flag => p_dlv_attachments_flag
          ,p_association_flag     => p_association_flag
          ,p_prefix               => p_prefix
          ,p_delta                => p_delta
          ,p_calling_context      => p_calling_context
          ,p_task_id              => p_task_id                --Bug 3429393
          ,p_task_version_id      => p_task_version_id        --Bug 3429393
          ,x_return_status        => x_return_status
          ,x_msg_count            => x_msg_count
          ,x_msg_data             => x_msg_data
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
          ROLLBACK TO COPY_DELIVERABLES_SP ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of COPY_DELIVERABLES';
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
          ROLLBACK TO COPY_DELIVERABLES_SP ;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLE_PUB'
                             ,p_procedure_name  => 'COPY_DELIVERABLES');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_ASSOCIATIONS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END COPY_DELIVERABLES ;

PROCEDURE COPY_ASSOCIATIONS
     (p_api_version             IN NUMBER   :=1.0
     ,p_init_msg_list           IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit                  IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only           IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level        IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module          IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode              IN VARCHAR2 :='N'
     ,p_max_msg_count           IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_src_task_versions_tab   IN SYSTEM.pa_num_tbl_type
     ,p_dest_task_versions_tab  IN SYSTEM.pa_num_tbl_type
     ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_debug_mode            VARCHAR2(10);
     l_msg_count             NUMBER ;
     l_data                  VARCHAR2(2000);
     l_msg_data              VARCHAR2(2000);
     l_msg_index_out         NUMBER;
     l_dummy                 VARCHAR2(1) ;
     l_proj_element_id       NUMBER ;
     l_project_id            NUMBER ;
     l_task_element_id       NUMBER ;


     l_element_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()  ;
     l_version_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()  ;
     l_element_name_tbl    SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE() ;
     l_element_number_tbl  SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE() ;

     -- 3461959 : Task_To_Deliverable association not getting copied
     -- changed the c_source_deliverable query
     -- changed the c_get_element_id query

     CURSOR c_source_deliverable (c_task_version_id IN NUMBER )
     IS
     SELECT ppe.proj_element_id
           ,pev1.element_version_id
           ,ppe.element_number
           ,ppe.name
       FROM pa_proj_elements ppe
           ,pa_proj_element_versions pev1
           ,pa_proj_element_versions pev2
           ,pa_object_relationships obj
      WHERE pev2.element_version_id = c_task_version_id
        AND obj.object_id_from2 = pev2.proj_element_id
        AND obj.object_type_from = 'PA_TASKS'
        AND obj.object_type_to = 'PA_DELIVERABLES'
        AND obj.relationship_type = 'A'
        AND obj.relationship_subtype = 'TASK_TO_DELIVERABLE'
        AND obj.object_id_to2 = ppe.proj_element_id
        AND pev1.proj_element_id = ppe.proj_element_id ; -- 3461959 changed from element_version_id to proj_element_id

     CURSOR c_get_element_id(c_task_version_id IN NUMBER )
     IS
     SELECT ppe.proj_element_id
           ,ppe.project_id
       FROM pa_proj_elements ppe ,
            pa_proj_element_versions pev
      WHERE pev.element_version_id = c_task_version_id
        AND ppe.proj_element_id = pev.proj_element_id
        AND nvl(ppe.base_percent_comp_deriv_code,'X') <> 'DELIVERABLE' ;  -- 3461959 added nvl function

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'COPY_ASSOCIATIONS',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside COPY_ASSOCIATIONS ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
          SAVEPOINT COPY_ASSOCIATIONS_SP ;
     END IF ;

     FOR i IN p_src_task_versions_tab.FIRST..p_src_task_versions_tab.LAST LOOP

          OPEN c_source_deliverable (p_src_task_versions_tab(i));
          FETCH c_source_deliverable BULK COLLECT INTO
                     l_element_id_tbl
                    ,l_version_id_tbl
                    ,l_element_name_tbl
                    ,l_element_number_tbl ;
          CLOSE c_source_deliverable ;

          IF nvl(l_element_id_tbl.LAST,0)>0 THEN

               OPEN c_get_element_id(p_src_task_versions_tab(i));
               FETCH c_get_element_id INTO l_proj_element_id,l_project_id ;
               IF c_get_element_id%NOTFOUND THEN
                    PA_UTILS.ADD_MESSAGE('PA','PA_DLV_COPY_TASK_ERR');
                    RAISE Invalid_Arg_Exc_Dlv ;
               END IF ;
               CLOSE c_get_element_id ;

           -- 3461959 added the below code to fetch proj_element_id for destination
           -- task

               OPEN c_get_element_id(p_dest_task_versions_tab(i));
               FETCH c_get_element_id INTO l_task_element_id,l_project_id ;
               CLOSE c_get_element_id ;

               PA_DELIVERABLE_PUB.CREATE_ASSOCIATIONS_IN_BULK
                    (p_element_id_tbl     => l_element_id_tbl
                    ,p_version_id_tbl     => l_version_id_tbl
                    ,p_element_name_tbl   => l_element_name_tbl
                    ,p_element_number_tbl => l_element_number_tbl
            ,p_task_or_dlv_elt_id => l_task_element_id  -- 3461959 changed from l_proj_element_id to l_task_element_id
                    ,p_task_or_dlv_ver_id => p_dest_task_versions_tab(i)
                    ,p_project_id         => l_project_id
                    ,p_task_or_dlv        => 'PA_TASKS'
                    ,x_return_status      => x_return_status
                    ,x_msg_count          => x_msg_count
                    ,x_msg_data           => x_msg_data
                    ) ;
          END IF ;

          IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE Invalid_Arg_Exc_Dlv ;
          END IF ;
     END LOOP ;

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK TO COPY_ASSOCIATIONS_SP ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of COPY_ASSOCIATIONS';
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
          ROLLBACK TO COPY_ASSOCIATIONS_SP ;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLE_PUB'
                             ,p_procedure_name  => 'COPY_ASSOCIATIONS');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('COPY_ASSOCIATIONS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END COPY_ASSOCIATIONS ;

END PA_DELIVERABLE_PUB;

/
