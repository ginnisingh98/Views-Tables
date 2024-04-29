--------------------------------------------------------
--  DDL for Package Body PA_PROJ_STRUCTURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_STRUCTURE_PUB" as
/* $Header: PAXSTRPB.pls 120.30.12010000.5 2009/07/21 14:33:26 anuragar ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJ_STRUCTURE_PUB';
-- Added for Bug# 6156686
l_d_lines_exist_flag     VARCHAR2(1);
l_issue_lines_exist_flag VARCHAR2(1);
l_cr_lines_exist_flag    VARCHAR2(1);
l_co_lines_exist_flag    VARCHAR2(1);
l_pc_lines_exist_flag    VARCHAR2(1);

procedure CREATE_RELATIONSHIP
(
    p_api_version               IN      NUMBER      := 1.0,
    p_init_msg_list         IN      VARCHAR2    := FND_API.G_TRUE,
    p_commit                        IN      VARCHAR2    := FND_API.G_FALSE,
    p_validate_only         IN      VARCHAR2    := FND_API.G_TRUE,
    p_debug_mode                IN      VARCHAR2    := 'N',
    p_task_id                       IN      NUMBER,
    p_project_id                IN      NUMBER,
    x_return_status         OUT    NOCOPY  VARCHAR2,
    x_msg_count                 OUT  NOCOPY    NUMBER,
    x_msg_data                  OUT   NOCOPY   VARCHAR2
)
IS
    l_task_id               NUMBER;
    l_project_id        NUMBER;
Begin
    pa_debug.init_err_stack('PA_PROJ_STRUCTURE_PUB.CREATE_RELATIONSHIP');
    IF (p_commit= FND_API.G_TRUE) THEN
    SAVEPOINT CREATE_TASK_PROJ_REL;
  END IF;
    l_task_id := p_task_id;
    l_project_id := p_project_id;

    PA_PROJ_STRUCTURE_PVT.CREATE_RELATIONSHIP(
        p_task_id => l_task_id,
        p_project_id => l_project_id,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
    );
EXCEPTION
    When OTHERS Then
        IF (p_commit = FND_API.G_TRUE) THEN
            ROLLBACK TO CREATE_TASK_PROJ_REL;
        END IF;
        FND_MSG_PUB.add_exc_msg(
            p_pkg_name => 'CREATE_RELATIONSHIP',
            p_procedure_name => PA_DEBUG.G_Err_Stack
            );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
END CREATE_RELATIONSHIP;



function CHECK_SUBPROJ_CONTRACT_ASSO
(
    p_project_id    IN NUMBER
)
return VARCHAR2
IS
BEGIN
    pa_debug.init_err_stack('PA_PROJ_STRUCTURE_PUB.CHECK_SUBPROJ_CONTRACT_ASSO');

    return PA_PROJ_STRUCTURE_UTILS.CHECK_PROJECT_CONTRACT_EXISTS(p_project_id);
EXCEPTION
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(
            p_pkg_name => 'CHECK_SUBPROJ_CONTRACT_ASSO',
            p_procedure_name => PA_DEBUG.G_Err_Stack
            );
        RAISE;
END CHECK_SUBPROJ_CONTRACT_ASSO;



function CHECK_TASK_CONTRACT_ASSO
(
    p_task_id IN NUMBER
)
return VARCHAR2
IS
Begin
    pa_debug.init_err_stack('PA_PROJ_STRUCTURE_PUB.CHECK_TASK_CONTRACT_ASSO');

    return PA_PROJ_STRUCTURE_UTILS.CHECK_TASK_CONTRACT_EXISTS(p_task_id);
EXCEPTION
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(
            p_pkg_name => 'CHECK_TASK_CONTRACT_ASSO',
            p_procedure_name => PA_DEBUG.G_Err_Stack
            );
        RAISE;
END CHECK_TASK_CONTRACT_ASSO;



procedure DELETE_RELATIONSHIP
(
    p_api_version               IN      NUMBER      := 1.0,
    p_init_msg_list         IN      VARCHAR2    := FND_API.G_TRUE,
    p_commit                        IN      VARCHAR2    := FND_API.G_FALSE,
    p_validate_only         IN      VARCHAR2    := FND_API.G_TRUE,
    p_debug_mode                IN      VARCHAR2    := 'N',
    p_task_id                       IN      NUMBER,
    p_project_id                IN      NUMBER,
    x_return_status         OUT    NOCOPY  VARCHAR2,
    x_msg_count                 OUT  NOCOPY    NUMBER,
    x_msg_data                  OUT   NOCOPY   VARCHAR2
)
IS
    l_project_id                                NUMBER;
    l_task_id                                       NUMBER;

BEGIN
    pa_debug.init_err_stack('PA_PROJ_STRUCTURE_PUB.DELETE_RELATIONSHIP');
    IF (p_commit= FND_API.G_TRUE) THEN
    SAVEPOINT DELETE_TASK_PROJ_REL;
  END IF;

    l_project_id := p_project_id;
    l_task_id := p_task_id;
    PA_PROJ_STRUCTURE_PVT.DELETE_RELATIONSHIP(
    p_task_id => p_task_id,
    p_project_id => p_project_id,
    x_return_status=> x_return_status,
    x_msg_count=> x_msg_count,
    x_msg_data=> x_msg_data);

EXCEPTION
    When OTHERS Then
        IF (p_commit = FND_API.G_TRUE) THEN
            ROLLBACK TO DELETE_TASK_PROJ_REL;
        END IF;
        FND_MSG_PUB.add_exc_msg(
            p_pkg_name => 'DELETE_RELATIONSHIP',
            p_procedure_name => PA_DEBUG.G_Err_Stack
            );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
END DELETE_RELATIONSHIP;

procedure POPULATE_STRUCTURES_TMP_TAB
(
    p_api_version           IN      NUMBER      := 1.0,
    p_init_msg_list         IN      VARCHAR2    := FND_API.G_TRUE,
    p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
    p_validate_only         IN      VARCHAR2    := FND_API.G_TRUE,
    p_debug_mode            IN      VARCHAR2    := 'N',
    p_project_id            IN      NUMBER,
    p_structure_version_id          IN              NUMBER,
    p_task_version_id          IN              NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_calling_page_name             IN              VARCHAR2,
    p_populate_tmp_tab_flag         IN              VARCHAR2           := 'Y',
    p_parent_project_id                 IN              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_sequence_offset     IN      NUMBER := 0,   --bug 4448499
    p_wbs_display_depth             IN              NUMBER          := -1, -- Bug # 4875311.
    x_return_status         OUT   NOCOPY   VARCHAR2,
    x_msg_count             OUT   NOCOPY   NUMBER,
    x_msg_data              OUT   NOCOPY   VARCHAR2
)
IS


   l_api_name                      CONSTANT VARCHAR(30) := 'POPULATE_STRUCTURES_TMP_TAB'   ;
   l_api_version                   CONSTANT NUMBER      := 1.0                            ;
   l_return_status                 VARCHAR2(1)                                       ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID                   ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID                  ;
   g1_debug_mode            VARCHAR2(1)                                    ;

   CURSOR check_pub_str
   IS
   SELECT 'Y'
     FROM pa_proj_elem_ver_structure
    WHERE project_id= p_project_id
      AND element_version_id = p_structure_version_id
      AND status_code = 'STRUCTURE_PUBLISHED';

   l_pub_structure_flag     VARCHAR2(1) := 'N';

   CURSOR check_prog_flag
   IS
    SELECT sys_program_flag
      FROM pa_projects_all
     WHERE project_id = p_project_id
    ;

   l_program_flag          VARCHAR2(1)  := 'N';

   --bug 4197654
   l_parent_project_id   NUMBER;
   --end bug 4197654

   -- Bug # 4875311.

   l_wbs_display_depth     NUMBER;
   l_task_version_id       NUMBER;
   l_structure_version_id  NUMBER;

   -- Bug # 4875311.

BEGIN
    g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'ENTERED', x_Log_Level=> 3);
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;


    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'p_structure_version_id: '||p_structure_version_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'p_calling_page_name: '||p_calling_page_name, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'p_parent_project_id: '||p_parent_project_id, x_Log_Level=> 3);
--bug 4448499
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'p_sequence_offset: '||p_sequence_offset, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'p_populate_tmp_tab_flag: '||p_populate_tmp_tab_flag, x_Log_Level=> 3);
--bug 4448499
    END IF;

        --bug 4197654
        IF p_parent_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_parent_project_id := p_project_id;
        ELSE
          l_parent_project_id := p_parent_project_id;
        END IF;
        --end bug 4197654

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --bug 4448499   moved this code here from below to have access to program flag.
        IF p_calling_page_name NOT IN ('TASK_DETAILS','WP_UPD_TASKS')
            -- <> 'TASK_DETAILS'    --No need to get the program data for Task details page.
        THEN
            OPEN check_prog_flag;
            FETCH check_prog_flag INTO l_program_flag;
            IF check_prog_flag%NOTFOUND
            THEN
                l_program_flag := 'N';
            END IF;
            CLOSE check_prog_flag;
        END IF;

    -- Bug # 4875311.

    if ((p_calling_page_name = 'GANTT_REGION') or (p_calling_page_name = 'LIST_REGION') or (l_program_flag = 'Y')) then
        l_wbs_display_depth := -1;
        l_task_version_id := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
    else
        l_wbs_display_depth := nvl(p_wbs_display_depth, -1);
        l_task_version_id := nvl(p_task_version_id, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM);
    end if;

    -- Bug # 4875311.

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'l_program_flag='||l_program_flag, x_Log_Level=> 3);
        END IF;

        IF l_parent_project_id = p_project_id
        THEN
            global_sequence_number := 0;
            global_sub_proj_task_count := 0;
        END IF;

        --bug 4448499

        IF ( p_populate_tmp_tab_flag = 'N'
             AND l_program_flag = 'N'     --bug 4448499  --bugfix 4290593i was done in order not to call thsi temp table
                                          --api multiple if the the table is already populated if calling region is GANTT.
                                          --Now for  bug 4448499, the api should get executed if the project is a program.
             AND PA_PROJ_STRUCTURE_UTILS.CHECK_STR_TEMP_TAB_POPULATED(p_project_id) = 'Y' ) OR   --bug 4290593
           ( p_calling_page_name = 'TASK_DETAILS' AND
             ( p_task_version_id IS NULL OR
               p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) )
        THEN
           return;
        END IF;

    -- Begin fix for Bug # 4485192.

    -- first delete from the temp table

    -- delete from pa_structures_tasks_tmp where parent_project_id = p_project_id;

    -- If this API is being called for the parent project then delete all the parent projects records
    -- from the table: pa_structures_tasks_tmp before re-populating the records.

    -- Bug # 4875311.

    if ((l_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
       and (l_program_flag = 'N') --Bug # 4875311.
       and (p_calling_page_name <> 'TASK_DETAILS')) -- Bug # 4875311.
    then

        delete from pa_structures_tasks_tmp  pstt
        where pstt.parent_structure_version_id = p_structure_version_id
        and pstt.parent_element_version_id = l_task_version_id;

    else

    -- Bug # 4875311.

    if (l_parent_project_id = p_project_id) then

        delete from pa_structures_tasks_tmp where project_id = p_project_id;

        delete from pa_structures_tasks_tmp where parent_project_id = p_project_id; -- Fix for Bug # 4540645.

    end if;

    end if; -- Bug # 4875311.

    -- End fix for Bug # 4485192.

    OPEN check_pub_str;
    FETCH check_pub_str INTO l_pub_structure_flag;
    IF check_pub_str%NOTFOUND
    THEN
       l_pub_structure_flag := 'N';
    END IF;
    CLOSE check_pub_str;

    IF g1_debug_mode  = 'Y' THEN
          pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'After deleting from temp table', x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'l_pub_structure_flag='||l_pub_structure_flag, x_Log_Level=> 3);
    END IF;


    IF l_pub_structure_flag = 'Y'
    THEN

      IF p_calling_page_name = 'TASK_DETAILS'
        AND p_task_version_id IS NOT NULL
        AND p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
       IF g1_debug_mode  = 'Y' THEN
           pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'Calling PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORD', x_Log_Level=> 3);
       END IF;

       PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORD(
            p_api_version           =>  p_api_version,
            p_init_msg_list               =>  p_init_msg_list,
            p_commit                =>  p_commit,
            p_validate_only         =>  p_validate_only,
            p_debug_mode            =>  p_debug_mode,
            p_project_id            =>  p_project_id,
            p_structure_version_id        =>  p_structure_version_id,
            p_task_version_id             =>  p_task_version_id,
                p_parent_project_id     =>  l_parent_project_id,
            x_return_status         =>  l_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data)
           ;

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'After calling PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORD l_return_status='||l_return_status, x_Log_Level=> 3);
    END IF;

      ELSIF  p_calling_page_name = 'WP_UPD_TASKS' THEN

         IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'Before calling PA_PROJ_STRUCTURE_PUB.INSERT_UPD_PUBLISHED_RECORDS', x_Log_Level=> 3);
         END IF;

             PA_PROJ_STRUCTURE_PUB.INSERT_UPD_PUBLISHED_RECORDS(
                p_api_version                   =>  p_api_version,
                p_init_msg_list                 =>  p_init_msg_list,
                p_commit                        =>  p_commit,
                p_validate_only                 =>  p_validate_only,
                p_debug_mode                    =>  p_debug_mode,
                p_project_id                    =>  p_project_id,
                p_structure_version_id          =>  p_structure_version_id,
                p_parent_project_id             =>  l_parent_project_id,
                p_wbs_display_depth             =>  l_wbs_display_depth,  -- Bug # 4875311.
                p_task_version_id               =>  l_task_version_id, -- Bug # 4875311.
                x_return_status                 =>  l_return_status,
                x_msg_count                     =>  x_msg_count,
                x_msg_data                      =>  x_msg_data)
            ;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'After calling PA_PROJ_STRUCTURE_PUB.INSERT_UPD_PUBLISHED_RECORDS l_return_status='||l_return_status, x_Log_Level=> 3);
        END IF;

      ELSE

          IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'Calling PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORDS', x_Log_Level=> 3);
          END IF;

          PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORDS(
            p_api_version           =>  p_api_version,
            p_init_msg_list         =>  p_init_msg_list,
            p_commit                =>  p_commit,
            p_validate_only         =>  p_validate_only,
            p_debug_mode            =>  p_debug_mode,
            p_project_id            =>  p_project_id,
            p_structure_version_id  =>  p_structure_version_id,
            p_parent_project_id     =>  l_parent_project_id,
            p_sequence_offset       =>  p_sequence_offset,     --bug 4448499
            p_wbs_display_depth     =>  l_wbs_display_depth,  -- Bug # 4875311.
            p_task_version_id       =>  l_task_version_id, -- Bug # 4875311.
            x_return_status         =>  l_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data)
           ;

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'After calling PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORDS l_return_status='||l_return_status, x_Log_Level=> 3);
        END IF;


      END IF;  --p_calling_page_name = 'TASK_DETAILS'

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;  -- l_pub_structure_flag = 'Y'

    IF l_pub_structure_flag = 'N'
    THEN

      IF p_calling_page_name = 'TASK_DETAILS'
        AND p_task_version_id IS NOT NULL
        AND p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
        IF g1_debug_mode  = 'Y' THEN
           pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'Before calling PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORD', x_Log_Level=> 3);
        END IF;

        PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORD(
            p_api_version           =>  p_api_version,
            p_init_msg_list               =>  p_init_msg_list,
            p_commit                =>  p_commit,
            p_validate_only         =>  p_validate_only,
            p_debug_mode            =>  p_debug_mode,
            p_project_id            =>  p_project_id,
            p_structure_version_id        =>  p_structure_version_id,
            p_task_version_id             =>  p_task_version_id,
                p_parent_project_id     =>  l_parent_project_id,   --bug 4240538
            x_return_status         =>  l_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data)
            ;

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'After calling PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORD l_return_status='||l_return_status, x_Log_Level=> 3);
        END IF;

      ELSIF  p_calling_page_name = 'WP_UPD_TASKS' THEN

     IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'Before calling PA_PROJ_STRUCTURE_PUB.INSERT_UPD_WORKING_RECORDS', x_Log_Level=> 3);
         END IF;

             PA_PROJ_STRUCTURE_PUB.INSERT_UPD_WORKING_RECORDS(
                p_api_version                   =>  p_api_version,
                p_init_msg_list                 =>  p_init_msg_list,
                p_commit                        =>  p_commit,
                p_validate_only                 =>  p_validate_only,
                p_debug_mode                    =>  p_debug_mode,
                p_project_id                    =>  p_project_id,
                p_structure_version_id  =>  p_structure_version_id,
                p_parent_project_id     =>  l_parent_project_id,
                p_wbs_display_depth             =>  l_wbs_display_depth,  -- Bug # 4875311.
                p_task_version_id               =>  l_task_version_id, -- Bug # 4875311.
                x_return_status                 =>  l_return_status,
                x_msg_count                     =>  x_msg_count,
                x_msg_data                      =>  x_msg_data)
            ;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'After calling PA_PROJ_STRUCTURE_PUB.INSERT_UPD_WORKING_RECORDS l_return_status='||l_return_status, x_Log_Level=> 3);
        END IF;

      ELSE

         IF g1_debug_mode  = 'Y' THEN
              pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'Before calling PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORDS', x_Log_Level=> 3);
         END IF;

         PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORDS(
                p_api_version           =>  p_api_version,
            p_init_msg_list         =>  p_init_msg_list,
            p_commit                =>  p_commit,
            p_validate_only         =>  p_validate_only,
            p_debug_mode            =>  p_debug_mode,
            p_project_id            =>  p_project_id,
            p_structure_version_id  =>  p_structure_version_id,
            p_parent_project_id     =>  l_parent_project_id,
            p_sequence_offset       =>  p_sequence_offset,     --bug 4448499
            p_wbs_display_depth     =>  l_wbs_display_depth,  -- Bug # 4875311.
            p_task_version_id       =>  l_task_version_id, -- Bug # 4875311.
            x_return_status         =>  l_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data)
            ;

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'After calling PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORDS l_return_status='||l_return_status, x_Log_Level=> 3);
        END IF;


      END IF; --- p_calling_page_name = 'TASK_DETAILS'

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   END IF;  -- l_pub_structure_flag = 'N'

    IF p_calling_page_name NOT IN ('TASK_DETAILS','WP_UPD_TASKS')
    -- <> 'TASK_DETAILS'    --No need to get the program data for Task details page.
    THEN
      /* move this cursor up in the beginning for performance for bug 4448499
        OPEN check_prog_flag;
        FETCH check_prog_flag INTO l_program_flag;
        IF check_prog_flag%NOTFOUND
        THEN
           l_program_flag := 'N';
        END IF;
        CLOSE check_prog_flag;

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'l_program_flag='||l_program_flag, x_Log_Level=> 3);
        END IF;
        */

        IF l_program_flag = 'Y'
        THEN

           IF g1_debug_mode  = 'Y' THEN
              pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'Before calling PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Log_Level=> 3);
           END IF;

            PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS(
            p_api_version           =>  p_api_version,
            p_init_msg_list         =>  p_init_msg_list,
            p_commit                =>  p_commit,
            p_validate_only         =>  p_validate_only,
            p_debug_mode            =>  p_debug_mode,
            p_calling_page_name     =>  p_calling_page_name,
            p_project_id            =>  p_project_id,
            p_structure_version_id  =>  p_structure_version_id,
            p_parent_project_id     =>  l_parent_project_id,
            p_wbs_display_depth     =>  l_wbs_display_depth, -- Bug # 4875311.
            x_return_status         =>  l_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data)
          ;

            IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.POPULATE_STRUCTURES_TMP_TAB', x_Msg => 'After calling PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS l_return_status='||l_return_status, x_Log_Level=> 3);
        END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;  --l_program_flag = 'Y'
    END IF;  -- p_calling_page_name <> 'TASK_DETAILS'

EXCEPTION

     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'POPULATE_STRUCTURES_TMP_TAB',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'POPULATE_STRUCTURES_TMP_TAB',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;

END POPULATE_STRUCTURES_TMP_TAB;


procedure INSERT_PUBLISHED_RECORDS
(
    p_api_version           IN      NUMBER      := 1.0,
    p_init_msg_list         IN      VARCHAR2    := FND_API.G_TRUE,
    p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
    p_validate_only         IN      VARCHAR2    := FND_API.G_TRUE,
    p_debug_mode            IN      VARCHAR2    := 'N',
    p_project_id            IN      NUMBER,
    p_structure_version_id  IN      NUMBER,
    p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_sequence_offset     IN      NUMBER := 0,   --bug 4448499
    p_wbs_display_depth             IN              NUMBER       := -1, -- Bug # 4875311.
    p_task_version_id               IN              NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, -- Bug # 4875311.
    x_return_status         OUT    NOCOPY  VARCHAR2,
    x_msg_count             OUT    NOCOPY  NUMBER,
    x_msg_data              OUT    NOCOPY  VARCHAR2
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'INSERT_PUBLISHED_RECORDS'   ;
   l_api_version                   CONSTANT NUMBER      := 1.0                            ;
   l_return_status                 VARCHAR2(1)                                       ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID                   ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID                  ;
   g1_debug_mode            VARCHAR2(1)                                    ;

   /*4275236 : Some Perf Enhancements*/
   l_yes                    FND_LOOKUPS.MEANING%TYPE;
   l_no                     FND_LOOKUPS.MEANING%TYPE;

   --Added the below variables for bug 5580992
   l_rowid_tbl                    pa_plsql_datatypes.RowidTabTyp   ;
   rec_count                      NUMBER;
   TYPE pc_tbl IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
   l_pc_tbl                       pc_tbl;
   l_desc_tbl                     pa_plsql_datatypes.Char1000TabTyp   ;
   l_tmp_pc                       VARCHAR2(4000);
   l_tmp_desc                     VARCHAR2(250);
   --End of variable declaration for bug 5580992

  -- Start of Bug 6156686
   CURSOR C1
   IS
   SELECT NULL
   FROM   DUAL
   WHERE EXISTS
   (SELECT NULL
    FROM   pa_structures_tasks_tmp
    WHERE  proj_element_id IS NULL);

    CURSOR C2
    IS
    SELECT 'Y'
    FROM   DUAL
    WHERE EXISTS
    (SELECT 1
     FROM   pa_object_relationships
     WHERE  relationship_type='D');

    CURSOR C3(c_ci_type VARCHAR2)
    IS
    SELECT NULL
    FROM   DUAL
    WHERE  EXISTS
    (SELECT 1
     FROM   pa_control_items pci,
            pa_structures_tasks_tmp t1,
            pa_ci_types_b pct
     WHERE  pci.project_id=t1.project_id
     AND    pci.ci_type_id=pct.ci_type_id
     AND    pct.ci_type_class_Code = c_ci_type);


CURSOR C4(p_project_id number)
    IS
    SELECT 'Y'
    FROM   DUAL
    WHERE  EXISTS
    (SELECT 1
     FROM   pa_percent_completes ppc
     WHERE  ppc.project_id=p_project_id);

    c1_rec                   C1%ROWTYPE;

    l_track_cost_amt_flag    VARCHAR2(1);
    l_dummy                  VARCHAR2(1);
-- End of Bug 6156686

  -- Bug Fix 5609629.
  -- Caching the wp_version_enable_flag in a local variable in order to avoid the function call
  -- during the insert statements. This will avoid the multiple executions of the same select.
  -- The project id is passed as a parameter to the pa_workplan_attr_utils.check_wp_versioning_enabled
  -- As the project id is not going to change during the insert statement records we can safely cache
  -- the value in a local variable and use that during the insert statment.

  l_versioning_enabled_flag pa_proj_workplan_attr.wp_enable_version_flag%TYPE;

  -- End of Bug Fix 5609629

BEGIN
    g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORDS', x_Msg => 'ENTERED', x_Log_Level=> 3);
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;


    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORDS', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*4275236 : Some Perf Enhancements*/
    l_yes := PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO','Y');
    l_no  := PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO','N');

    -- Bug Fix 5609629
    -- Caching the versioning_enabled_flag attribute value locally.
    l_versioning_enabled_flag := pa_workplan_attr_utils.check_wp_versioning_enabled(p_project_id);
    -- End of Bug Fix 5609629

--Populate published versions records first.
-- Bug # 4875311.

-- ************************************************************************************************************************
-- if only p_structure_version_id is passed in, populate all task records for the given structure version.
-- ************************************************************************************************************************

-- Start of Bug 6156686
if (l_yes is null or l_no is null) then
        OPEN c1;
        FETCH c1 INTO c1_rec;
        IF c1%FOUND THEN

            l_yes := PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO','Y');
            l_no  := PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO','N');
        CLOSE c1;
end if;
if l_d_lines_exist_flag is null then
            OPEN C2;
            FETCH C2 INTO l_d_lines_exist_flag;
            IF C2%FOUND THEN
                l_d_lines_exist_flag := 'Y';
            ELSE
                l_d_lines_exist_flag := 'N';
            END IF;
            CLOSE C2;
end if;
if l_issue_lines_exist_flag is null then
            OPEN C3('ISSUE');
            FETCH C3 INTO l_dummy;
            IF C3%FOUND THEN
                l_issue_lines_exist_flag := 'Y';
            ELSE
                l_issue_lines_exist_flag := 'N';
            END IF;
            CLOSE C3;
end if;
if l_co_lines_exist_flag is null then
            OPEN C3('CHANGE_ORDER');
            FETCH C3 INTO l_dummy;
            IF C3%FOUND THEN
                l_co_lines_exist_flag := 'Y';
            ELSE
                l_co_lines_exist_flag := 'N';
            END IF;
            CLOSE C3;
end if;
if l_cr_lines_exist_flag is null then
            OPEN C3('CHANGE_REQUEST');
            FETCH C3 INTO l_dummy;
            IF C3%FOUND THEN
                l_cr_lines_exist_flag := 'Y';
            ELSE
                l_cr_lines_exist_flag := 'N';
            END IF;
            CLOSE C3;
end if;
if l_pc_lines_exist_flag is null then
            OPEN C4(p_project_id);
            FETCH C4 INTO l_pc_lines_exist_flag;
            IF C4%FOUND THEN
                l_pc_lines_exist_flag := 'Y';
            ELSE
                l_pc_lines_exist_flag := 'N';
            END IF;
            CLOSE C4;
end if;
end if;
-- End of Bug 6156686

if ((p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and (p_wbs_display_depth = -1)) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
, PLANNED_BASELINE_EFFORT_VAR  -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
    --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppa.project_id
   ,ppv.display_sequence + p_sequence_offset   --bug 4448499  adjust the display sequnece of sub-project tasks with the offset.
   ,ppvsch.milestone_flag
   /* 4275236 : Perf Enhancement - Replaced with  Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
   */
   ,decode(NVL( ppvsch.milestone_flag, 'N' ),'N',l_no,l_yes)
   ,ppvsch.critical_flag
   /* 4275236 : Perf Enhancement - Replaced with  Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
   */
   ,decode(NVL( ppvsch.critical_flag, 'N' ),'N',l_no,l_yes)
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type , 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null  ---ppc.PROGRESS_COMMENT
   ,null  ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_PRIORITY_CODE' ,ppe.priority_code)
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type),'Y',l_yes,l_no)
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_start_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   ,papf.work_telephone
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
*/
   ,decode(pt.chargeable_flag,'Y',l_yes,l_no)
   ,pt.chargeable_flag
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
*/
   ,decode(pt.billable_flag,'Y',l_yes,l_no)
   ,pt.billable_flag
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
*/
   ,decode(pt.receive_project_invoice_flag,'Y',l_yes,l_no)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date --Changes for 8566495 anuragag
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   -- Bug 6156686
   ,DECODE(l_pc_lines_exist_flag,'Y',PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date),0)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
*/
   ,decode(ppvsch.actual_finish_date,NULL,l_no,l_yes)
   ,ppe.CREATION_DATE
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id),'Y',l_yes,l_no)
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,pps3.PROJECT_STATUS_NAME
   ,ppe5.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                        -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,pt.address_id
   ,addr.address1
   ,addr.address2
   ,addr.address3
   ,addr.address4|| decode(addr.address4,null,null,', ')|| addr.city||', '||nvl(addr.state,addr.province)||', ' ||addr.county
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
   ,decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', tt.PERCENT_COMP_ENABLE_FLAG, 'N')
   ,decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', tt.REMAIN_EFFORT_ENABLE_FLAG, 'N')
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE', NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                         -- Fix for Bug # 4319171.
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
                                        -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug 6156686
   ,ppwa.wp_enable_version_flag--pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   ,ppe.phase_version_id
   ,ppe5.name
   ,ppe5.element_number
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
   ,ppwa.lifecycle_version_id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   -- Bug 6156686
   ,DECODE(l_issue_lines_exist_flag,'Y',
                pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE'),
                0)
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,ppeph.name
   -- Bug 6156686
   ,DECODE(l_cr_lines_exist_flag,'Y',
                pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST'),
                0)
   ,DECODE(l_co_lines_exist_flag,'Y',
                pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER'),
                0)
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                   , null, null, null) Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   -- Bug 6156686
   ,DECODE(l_d_lines_exist_flag,'Y',PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id),NULL) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                     ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , 'N')  Lowest_Task -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                , ppru.estimated_remaining_effort
                , ppru.eqpmt_etc_effort
                , null
                , ppru.subprj_ppl_etc_effort
                , ppru.subprj_eqpmt_etc_effort
                , null
                , null
                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                 , ppru.eqpmt_act_effort_to_date
                                 , null
                                 , ppru.subprj_ppl_act_effort
                                 , ppru.subprj_eqpmt_act_effort
                                 , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) Estimate_At_Completion_Effort
   ,nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING'))) Variance_At_Completion_Effort
   ,ppru.earned_value -(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                       , ppru.eqpmt_act_cost_to_date_pc
                   , ppru.oth_act_cost_to_date_pc
                   , null
                   , null
                   , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) Estimate_At_Completion_Cost
   ,NVL(ppru.earned_value,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),2) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),2) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppe.proj_element_id,
                                                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')))) Variance_At_Completion_Cost
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
 (((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
 -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0)))) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/* Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index */
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                          ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                      pppa.task_weight_basis_code,
                                          ppe.baseline_start_date,
                                          ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      pppa.task_weight_basis_code,
                                                                          ppe.baseline_start_date,
                                                                      ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                                                       ppru.object_id,
                                                                       ppe.proj_element_id,
                                                                       ppru.as_of_date,
                                                                       ppv.parent_structure_version_id,
                                                                       pppa.task_weight_basis_code,
                                                                                                                                           ppe.baseline_start_date,
                                                                                                                               ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',
 (nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))
 ,0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
            ,0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
    -- Bug Fix 5150944. NAMBURI
    --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,DECODE(ppa.structure_sharing_code,'SPLIT_MAPPING',PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code)) Mapped_Financial_Task
   ,PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,pt.gen_etc_source_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                   , ppru.ppl_etc_cost_pc
                   , ppru.eqpmt_etc_cost_pc
                   , ppru.oth_etc_cost_pc
                   , ppru.subprj_ppl_etc_cost_pc
                   , ppru.subprj_eqpmt_etc_cost_pc
                   , ppru.subprj_oth_etc_cost_pc
                   , null
                   , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                , ppru.eqpmt_act_cost_to_date_pc
                                , ppru.oth_act_cost_to_date_pc
                                , ppru.subprj_ppl_act_cost_pc
                                , ppru.subprj_eqpmt_act_cost_pc
                                , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                        -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   ,ppru.BASE_PERCENT_COMPLETE --Bug 4416432 Issue 2
   ,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))  PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
   ,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) Planned_Baseline_Finish  -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    --,ra_addresses_all addr
     ,HZ_CUST_ACCT_SITES_ALL S
     ,HZ_PARTY_SITES PS
     ,HZ_LOCATIONS addr
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,pa_work_types_tl pwt
    ,pa_task_types tt
    ,pa_project_statuses pps3
    ,pa_page_layouts ppl
    ,pa_progress_rollup ppru
    -----,pa_percent_completes ppc
    ,pa_project_statuses pps
    ,pa_project_statuses pps5
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,pa_proj_workplan_attr ppwa
    ,pa_proj_element_versions ppev6
    ,pa_proj_progress_attr pppa
    ,pa_proj_element_versions ppv2
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pa_proj_elements ppeph
    ,pa_proj_element_versions ppevph
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND ppe.object_type = 'PA_TASKS'
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null) --Changes for 8566495 anuragag
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id (+)
 AND pwt.language (+) = userenv('lang')
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.status_code = pps3.PROJECT_STATUS_CODE (+)
 AND pps3.STATUS_TYPE (+) = 'TASK'
 --AND pt.address_id = addr.address_id (+)
      AND pt.ADDRESS_ID = S.CUST_ACCT_SITE_ID(+)
     AND PS.PARTY_SITE_ID(+) = S.PARTY_SITE_ID
     AND addr.LOCATION_ID(+) = PS.LOCATION_ID
 AND ppe.task_progress_entry_page_id = ppl.page_id (+)
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 -- Begin fix for Bug # 4499065.
 AND ppru.current_flag (+) <> 'W'   -----= 'Y' (changed to <> 'W' condition)
 AND ppru.object_version_id(+) = ppv.element_version_id
 AND nvl(ppru.as_of_date, trunc(sysdate)) = (select /*+  INDEX (ppr2 pa_progress_rollup_u2)*/ nvl(max(ppr2.as_of_date),trunc(sysdate))  --Bug 7644130
                                           from pa_progress_rollup ppr2
                                           where
                                           ppr2.object_id = ppv.proj_element_id
                                           and ppr2.proj_element_id = ppv.proj_element_id
                                           and ppr2.object_version_id = ppv.element_version_id
                                           and ppr2.project_id = ppv.project_id
                                           and ppr2.object_type = 'PA_TASKS'
                                           and ppr2.structure_type = 'WORKPLAN'
                                           and ppr2.structure_version_id is null
                                           and ppr2.current_flag <> 'W')
 -- End fix for Bug # 4499065.
 AND ppru.structure_version_id(+) IS NULL
 AND NVL(ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+) = ppru.object_id
 ---AND ppc.date_computed (+) = ppru.as_of_date
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND ppe.project_id <> 0
 AND ppv.parent_structure_version_id = ppev6.element_version_id (+)
 AND ppev6.proj_element_id = ppwa.proj_element_id (+)
 AND ppev6.project_id = pppa.project_id (+)
 AND 'PA_STRUCTURES' = pppa.object_type (+)
 AND ppev6.proj_element_id = pppa.object_id (+)
 AND ppwa.current_phase_version_id = ppevph.element_version_id (+)
 AND ppevph.proj_element_id = ppeph.proj_element_id (+)
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+) > 0
 AND pfxat.txn_currency_code(+) is null
 AND pppa.structure_type(+) = 'WORKPLAN'
 AND ppa.project_id= p_project_id
 ---and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4190747.
 ---and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4190747.
 ---and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4216980.
 AND ppv.parent_structure_version_id = p_structure_version_id;

-- ************************************************************************************************************************
-- if p_structure_version_id and p_wbs_display_depth are passed in, populate all task records for the structure version until the depth.
-- ************************************************************************************************************************

elsif ((p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and ( p_wbs_display_depth <> -1)) then
--Bug 5580992: Removed the reference to pa_percent_completes. The columns Progress_comments and
--Progress_brief_overview are updated after this insert.

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
--, Progress_comments  Bug 5580992
--, Progress_brief_overview Bug 5580992
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
    --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppa.project_id
   ,ppv.display_sequence + p_sequence_offset   --bug 4448499  adjust the display sequnece of sub-project tasks with the offset.
   ,ppvsch.milestone_flag
   /* 4275236 : Perf Enhancement - Replaced with  Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
   */
   ,decode(NVL( ppvsch.milestone_flag, 'N' ),'N',l_no,l_yes)
   ,ppvsch.critical_flag
   /* 4275236 : Perf Enhancement - Replaced with  Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
   */
   ,decode(NVL( ppvsch.critical_flag, 'N' ),'N',l_no,l_yes)
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type , 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
--   ,ppc.PROGRESS_COMMENT Bug 5580992
--   ,ppc.DESCRIPTION Bug 5580992
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_PRIORITY_CODE' ,ppe.priority_code)
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type),'Y',l_yes,l_no)
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_start_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   ,papf.work_telephone
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
*/
   ,decode(pt.chargeable_flag,'Y',l_yes,l_no)
   ,pt.chargeable_flag
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
*/
   ,decode(pt.billable_flag,'Y',l_yes,l_no)
   ,pt.billable_flag
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
*/
   ,decode(pt.receive_project_invoice_flag,'Y',l_yes,l_no)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
*/
   ,decode(ppvsch.actual_finish_date,NULL,l_no,l_yes)
   ,ppe.CREATION_DATE
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id),'Y',l_yes,l_no)
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,pps3.PROJECT_STATUS_NAME
   ,ppe5.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                        -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,pt.address_id
   ,addr.address1
   ,addr.address2
   ,addr.address3
   ,addr.address4|| decode(addr.address4,null,null,', ')|| addr.city||', '||nvl(addr.state,addr.province)||', ' ||addr.county
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
   ,decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', tt.PERCENT_COMP_ENABLE_FLAG, 'N')
   ,decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', tt.REMAIN_EFFORT_ENABLE_FLAG, 'N')
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE', NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                         -- Fix for Bug # 4319171.
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
                                        -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,ppe5.name
   ,ppe5.element_number
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
   ,ppwa.lifecycle_version_id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,ppeph.name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                   , null, null, null) Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                     ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , 'N')  Lowest_Task -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                , ppru.estimated_remaining_effort
                , ppru.eqpmt_etc_effort
                , null
                , ppru.subprj_ppl_etc_effort
                , ppru.subprj_eqpmt_etc_effort
                , null
                , null
                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                 , ppru.eqpmt_act_effort_to_date
                                 , null
                                 , ppru.subprj_ppl_act_effort
                                 , ppru.subprj_eqpmt_act_effort
                                 , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) Estimate_At_Completion_Effort
   ,nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING'))) Variance_At_Completion_Effort
   ,ppru.earned_value -(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                       , ppru.eqpmt_act_cost_to_date_pc
                   , ppru.oth_act_cost_to_date_pc
                   , null
                   , null
                   , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) Estimate_At_Completion_Cost
   ,NVL(ppru.earned_value,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),2) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),2) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppe.proj_element_id,
                                                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')))) Variance_At_Completion_Cost
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
                                         (
                                           (
                                                     (nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value
                                           )/decode(
                                (
                                 (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/* Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index */
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                          ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                      pppa.task_weight_basis_code,
                                          ppe.baseline_start_date,
                                          ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      pppa.task_weight_basis_code,
                                                                          ppe.baseline_start_date,
                                                                      ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                                                       ppru.object_id,
                                                                       ppe.proj_element_id,
                                                                       ppru.as_of_date,
                                                                       ppv.parent_structure_version_id,
                                                                       pppa.task_weight_basis_code,
                                                                                                                                           ppe.baseline_start_date,
                                                                                                                               ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',
 (nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))
 ,0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
            ,0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
    -- Bug Fix 5150944. NAMBURI
    --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,DECODE(ppa.structure_sharing_code,'SPLIT_MAPPING',PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code)) Mapped_Financial_Task
   ,PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,pt.gen_etc_source_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                   , ppru.ppl_etc_cost_pc
                   , ppru.eqpmt_etc_cost_pc
                   , ppru.oth_etc_cost_pc
                   , ppru.subprj_ppl_etc_cost_pc
                   , ppru.subprj_eqpmt_etc_cost_pc
                   , ppru.subprj_oth_etc_cost_pc
                   , null
                   , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                , ppru.eqpmt_act_cost_to_date_pc
                                , ppru.oth_act_cost_to_date_pc
                                , ppru.subprj_ppl_act_cost_pc
                                , ppru.subprj_eqpmt_act_cost_pc
                                , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                        -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   ,ppru.BASE_PERCENT_COMPLETE --Bug 4416432 Issue 2
,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    --,ra_addresses_all addr
     ,HZ_CUST_ACCT_SITES_ALL S
     ,HZ_PARTY_SITES PS
     ,HZ_LOCATIONS addr
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,pa_work_types_tl pwt
    ,pa_task_types tt
    ,pa_project_statuses pps3
    ,pa_page_layouts ppl
    ,pa_progress_rollup ppru
    -----,pa_percent_completes ppc Bug 5580992
    ,pa_project_statuses pps
    ,pa_project_statuses pps5
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,pa_proj_workplan_attr ppwa
    ,pa_proj_element_versions ppev6
    ,pa_proj_progress_attr pppa
    ,pa_proj_element_versions ppv2
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pa_proj_elements ppeph
    ,pa_proj_element_versions ppevph
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND ppe.object_type = 'PA_TASKS'
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id (+)
 AND pwt.language (+) = userenv('lang')
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.status_code = pps3.PROJECT_STATUS_CODE (+)
 AND pps3.STATUS_TYPE (+) = 'TASK'
 --AND pt.address_id = addr.address_id (+)
      AND pt.ADDRESS_ID = S.CUST_ACCT_SITE_ID(+)
     AND PS.PARTY_SITE_ID(+) = S.PARTY_SITE_ID
     AND addr.LOCATION_ID(+) = PS.LOCATION_ID
 AND ppe.task_progress_entry_page_id = ppl.page_id (+)
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 -- Begin fix for Bug # 4499065.
 AND ppru.current_flag (+) <> 'W'   -----= 'Y' (changed to <> 'W' condition)
 AND ppru.object_version_id(+) = ppv.element_version_id
 AND nvl(ppru.as_of_date, trunc(sysdate)) = (select /*+  INDEX (ppr2 pa_progress_rollup_u2)*/ nvl(max(ppr2.as_of_date),trunc(sysdate))  --Bug 7644130
                                           from pa_progress_rollup ppr2
                                           where
                                           ppr2.object_id = ppv.proj_element_id
                                           and ppr2.proj_element_id = ppv.proj_element_id
                                           and ppr2.object_version_id = ppv.element_version_id
                                           and ppr2.project_id = ppv.project_id
                                           and ppr2.object_type = 'PA_TASKS'
                                           and ppr2.structure_type = 'WORKPLAN'
                                           and ppr2.structure_version_id is null
                                           and ppr2.current_flag <> 'W')
 -- End fix for Bug # 4499065.
 AND ppru.structure_version_id(+) IS NULL
 AND NVL(ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id Bug 5580992
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+) = ppru.object_id Bug 5580992
 ---AND ppc.date_computed (+) = ppru.as_of_date Bug 5580992
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND ppe.project_id <> 0
 AND ppv.parent_structure_version_id = ppev6.element_version_id (+)
 AND ppev6.proj_element_id = ppwa.proj_element_id (+)
 AND ppev6.project_id = pppa.project_id (+)
 AND 'PA_STRUCTURES' = pppa.object_type (+)
 AND ppev6.proj_element_id = pppa.object_id (+)
 AND ppwa.current_phase_version_id = ppevph.element_version_id (+)
 AND ppevph.proj_element_id = ppeph.proj_element_id (+)
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+) > 0
 AND pfxat.txn_currency_code(+) is null
 AND pppa.structure_type(+) = 'WORKPLAN'
 ---and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4190747. Bug 5580992
 ---and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4190747. Bug 5580992
 ---and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4216980. Bug 5580992
 AND ppa.project_id = p_project_id
 AND ppv.parent_structure_version_id = p_structure_version_id
 and ppv.wbs_level <= p_wbs_display_depth;

 --Bug 5580992. This block will select the progress comment/description from pa_process_completes
 --update the same in PA_STRUCTURES_TASKS_TMP. This is done to remove the reference to
 --pa_percent_completes in above select and hence improve its performance. Please refer to bug
 --for more details.
 l_rowid_tbl.delete;
 l_pc_tbl.delete;
 l_desc_tbl.delete;
 rec_count :=0;
 FOR rec IN (SELECT rowid, project_id, proj_element_id, as_of_date FROM PA_STRUCTURES_TASKS_TMP) LOOP


    BEGIN

        l_tmp_pc   := NULL;
        l_tmp_desc := NULL;
        SELECT ppc.progress_comment ,ppc.description
        INTO   l_tmp_pc ,l_tmp_desc
        FROM   pa_percent_completes ppc
        WHERE  ppc.project_id=rec.project_id
        AND    ppc.object_id  = rec.proj_element_id
        AND    ppc.object_type  = 'PA_TASKS'
        AND    ppc.date_computed  = rec.as_of_date
        and    ppc.current_flag  = 'Y' -- Fix for Bug # 4190747.
        and    ppc.structure_type  = 'WORKPLAN' -- Fix for Bug # 4216980.
        and    ppc.published_flag  = 'Y'; -- Fix for Bug # 4190747.

        rec_count             := rec_count+1;
        l_rowid_tbl(rec_count):= rec.rowid;
        l_pc_tbl(rec_count)   := l_tmp_pc;
        l_desc_tbl(rec_count) := l_tmp_desc;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    END;

 END LOOP;

 FORALL zz IN 1..l_rowid_tbl.COUNT

    UPDATE PA_STRUCTURES_TASKS_TMP
    SET    Progress_comments        =l_pc_tbl(zz)
          ,Progress_brief_overview  =l_desc_tbl(zz)
    WHERE  rowid=l_rowid_tbl(zz);

 --Bug 5580992. End of changes for stamping Progress_comments and Progress_brief_overview
 --in PA_STRUCTURES_TASKS_TMP


-- ************************************************************************************************************************
--  if p_task_version_id is passed in, populate all the immediate child task records for the given task version.
-- ************************************************************************************************************************

elsif (p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
    --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppa.project_id
   ,ppv.display_sequence + p_sequence_offset   --bug 4448499  adjust the display sequnece of sub-project tasks with the offset.
   ,ppvsch.milestone_flag
   /* 4275236 : Perf Enhancement - Replaced with  Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
   */
   ,decode(NVL( ppvsch.milestone_flag, 'N' ),'N',l_no,l_yes)
   ,ppvsch.critical_flag
   /* 4275236 : Perf Enhancement - Replaced with  Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
   */
   ,decode(NVL( ppvsch.critical_flag, 'N' ),'N',l_no,l_yes)
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type , 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null  ---ppc.PROGRESS_COMMENT
   ,null  ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_PRIORITY_CODE' ,ppe.priority_code)
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type),'Y',l_yes,l_no)
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_start_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   ,papf.work_telephone
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
*/
   ,decode(pt.chargeable_flag,'Y',l_yes,l_no)
   ,pt.chargeable_flag
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
*/
   ,decode(pt.billable_flag,'Y',l_yes,l_no)
   ,pt.billable_flag
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
*/
   ,decode(pt.receive_project_invoice_flag,'Y',l_yes,l_no)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
*/
   ,decode(ppvsch.actual_finish_date,NULL,l_no,l_yes)
   ,ppe.CREATION_DATE
/*4275236 : Replaced the function call with Local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id),'Y',l_yes,l_no)
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,pps3.PROJECT_STATUS_NAME
   ,ppe5.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                        -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,pt.address_id
   ,addr.address1
   ,addr.address2
   ,addr.address3
   ,addr.address4|| decode(addr.address4,null,null,', ')|| addr.city||', '||nvl(addr.state,addr.province)||', ' ||addr.county
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
   ,decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', tt.PERCENT_COMP_ENABLE_FLAG, 'N')
   ,decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', tt.REMAIN_EFFORT_ENABLE_FLAG, 'N')
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE', NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                         -- Fix for Bug # 4319171.
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
                                        -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,ppe5.name
   ,ppe5.element_number
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
   ,ppwa.lifecycle_version_id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,ppeph.name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                   , null, null, null) Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                     ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , 'N')  Lowest_Task -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                , ppru.estimated_remaining_effort
                , ppru.eqpmt_etc_effort
                , null
                , ppru.subprj_ppl_etc_effort
                , ppru.subprj_eqpmt_etc_effort
                , null
                , null
                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                 , ppru.eqpmt_act_effort_to_date
                                 , null
                                 , ppru.subprj_ppl_act_effort
                                 , ppru.subprj_eqpmt_act_effort
                                 , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) Estimate_At_Completion_Effort
   ,nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING'))) Variance_At_Completion_Effort
   ,ppru.earned_value -(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                       , ppru.eqpmt_act_cost_to_date_pc
                   , ppru.oth_act_cost_to_date_pc
                   , null
                   , null
                   , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) Estimate_At_Completion_Cost
   ,NVL(ppru.earned_value,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),2) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),2) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppe.proj_element_id,
                                                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')))) Variance_At_Completion_Cost
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
 (((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/* Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index */
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                          ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                      pppa.task_weight_basis_code,
                                          ppe.baseline_start_date,
                                          ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      pppa.task_weight_basis_code,
                                                                          ppe.baseline_start_date,
                                                                      ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                                                       ppru.object_id,
                                                                       ppe.proj_element_id,
                                                                       ppru.as_of_date,
                                                                       ppv.parent_structure_version_id,
                                                                       pppa.task_weight_basis_code,
                                                                                                                                           ppe.baseline_start_date,
                                                                                                                               ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',
 (nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))
 ,0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
            ,0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
    -- Bug Fix 5150944. NAMBURI
    --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,DECODE(ppa.structure_sharing_code,'SPLIT_MAPPING',PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code)) Mapped_Financial_Task
   ,PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,pt.gen_etc_source_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                   , ppru.ppl_etc_cost_pc
                   , ppru.eqpmt_etc_cost_pc
                   , ppru.oth_etc_cost_pc
                   , ppru.subprj_ppl_etc_cost_pc
                   , ppru.subprj_eqpmt_etc_cost_pc
                   , ppru.subprj_oth_etc_cost_pc
                   , null
                   , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                , ppru.eqpmt_act_cost_to_date_pc
                                , ppru.oth_act_cost_to_date_pc
                                , ppru.subprj_ppl_act_cost_pc
                                , ppru.subprj_eqpmt_act_cost_pc
                                , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                        -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   ,ppru.BASE_PERCENT_COMPLETE --Bug 4416432 Issue 2
,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0)  PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    --,ra_addresses_all addr
     ,HZ_CUST_ACCT_SITES_ALL S
     ,HZ_PARTY_SITES PS
     ,HZ_LOCATIONS addr
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,pa_work_types_tl pwt
    ,pa_task_types tt
    ,pa_project_statuses pps3
    ,pa_page_layouts ppl
    ,pa_progress_rollup ppru
    -----,pa_percent_completes ppc
    ,pa_project_statuses pps
    ,pa_project_statuses pps5
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,pa_proj_workplan_attr ppwa
    ,pa_proj_element_versions ppev6
    ,pa_proj_progress_attr pppa
    ,pa_proj_element_versions ppv2
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pa_proj_elements ppeph
    ,pa_proj_element_versions ppevph
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND ppe.object_type = 'PA_TASKS'
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id (+)
 AND pwt.language (+) = userenv('lang')
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.status_code = pps3.PROJECT_STATUS_CODE (+)
 AND pps3.STATUS_TYPE (+) = 'TASK'
 --AND pt.address_id = addr.address_id (+)
      AND pt.ADDRESS_ID = S.CUST_ACCT_SITE_ID(+)
     AND PS.PARTY_SITE_ID(+) = S.PARTY_SITE_ID
     AND addr.LOCATION_ID(+) = PS.LOCATION_ID
 AND ppe.task_progress_entry_page_id = ppl.page_id (+)
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 -- Begin fix for Bug # 4499065.
 AND ppru.current_flag (+) <> 'W'   -----= 'Y' (changed to <> 'W' condition)
 AND ppru.object_version_id(+) = ppv.element_version_id
 AND nvl(ppru.as_of_date, trunc(sysdate)) = (select /*+  INDEX (ppr2 pa_progress_rollup_u2)*/ nvl(max(ppr2.as_of_date),trunc(sysdate))  --Bug 7644130
                                           from pa_progress_rollup ppr2
                                           where
                                           ppr2.object_id = ppv.proj_element_id
                                           and ppr2.proj_element_id = ppv.proj_element_id
                                           and ppr2.object_version_id = ppv.element_version_id
                                           and ppr2.project_id = ppv.project_id
                                           and ppr2.object_type = 'PA_TASKS'
                                           and ppr2.structure_type = 'WORKPLAN'
                                           and ppr2.structure_version_id is null
                                           and ppr2.current_flag <> 'W')
 -- End fix for Bug # 4499065.
 AND ppru.structure_version_id(+) IS NULL
 AND NVL(ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+) = ppru.object_id
 ---AND ppc.date_computed (+) = ppru.as_of_date
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND ppe.project_id <> 0
 AND ppv.parent_structure_version_id = ppev6.element_version_id (+)
 AND ppev6.proj_element_id = ppwa.proj_element_id (+)
 AND ppev6.project_id = pppa.project_id (+)
 AND 'PA_STRUCTURES' = pppa.object_type (+)
 AND ppev6.proj_element_id = pppa.object_id (+)
 AND ppwa.current_phase_version_id = ppevph.element_version_id (+)
 AND ppevph.proj_element_id = ppeph.proj_element_id (+)
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+) > 0
 AND pfxat.txn_currency_code(+) is null
 AND pppa.structure_type(+) = 'WORKPLAN'
 ---and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4190747.
 ---and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4190747.
 ---and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4216980.
 AND ppa.project_id = p_project_id
 AND ppv.parent_structure_version_id = p_structure_version_id
 and por.object_id_from1 = p_task_version_id;

end if;

-- Bug # 4875311.

--bug 4448499
--count the number of tasks beign inserted:
global_sub_proj_task_count :=  global_sub_proj_task_count + SQL%ROWCOUNT;
--bug 4448499


/*4275236 : If Workplan Cost is not enabled,Update the Values of Cost Columns as Empty
  We are not using decode() in insert statement because it resulted in very poor performance
*/


IF pa_fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id) <> 'Y' THEN

UPDATE pa_structures_tasks_tmp
set raw_cost = null,burdened_cost=null,planned_cost=null,Percent_Spent_Cost=null,Percent_Complete_Cost=null,
    Actual_Cost = null,Baseline_Cost=null,Estimate_At_Completion_Cost=null,
    Planned_Cost_Per_Unit=null,Actual_Cost_Per_Unit=null,Variance_At_Completion_Cost=null,
    ETC_Cost =null
    ,PLANNED_BASELINE_COST_VAR = NULL -- Added for bug 5090355
where project_id = p_project_id
  and parent_structure_version_id=p_structure_version_id;

END IF;

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_PUBLISHED_RECORDS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_PUBLISHED_RECORDS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END INSERT_PUBLISHED_RECORDS;


procedure INSERT_WORKING_RECORDS
(
    p_api_version           IN      NUMBER      := 1.0,
    p_init_msg_list         IN      VARCHAR2    := FND_API.G_TRUE,
    p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
    p_validate_only         IN      VARCHAR2    := FND_API.G_TRUE,
    p_debug_mode            IN      VARCHAR2    := 'N',
    p_project_id            IN      NUMBER,
    p_structure_version_id  IN      NUMBER,
    p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_sequence_offset     IN      NUMBER := 0,   --bug 4448499
    p_wbs_display_depth             IN              NUMBER       := -1, -- Bug # 4875311.
    p_task_version_id               IN              NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, -- Bug # 4875311.
    x_return_status         OUT   NOCOPY   VARCHAR2,
    x_msg_count             OUT   NOCOPY   NUMBER,
    x_msg_data              OUT   NOCOPY   VARCHAR2
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'INSERT_WORKING_RECORDS'   ;
   l_api_version                   CONSTANT NUMBER      := 1.0                            ;
   l_return_status                 VARCHAR2(1)                                       ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID                   ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID                  ;
   g1_debug_mode            VARCHAR2(1)                                    ;

   /*4275236: Perf Enhancements*/
   l_yes                    FND_LOOKUPS.MEANING%TYPE;
   l_no                     FND_LOOKUPS.MEANING%TYPE;

  -- Bug Fix 5609629.
  -- Caching the wp_version_enable_flag in a local variable in order to avoid the function call
  -- during the insert statements. This will avoid the multiple executions of the same select.
  -- The project id is passed as a parameter to the pa_workplan_attr_utils.check_wp_versioning_enabled
  -- As the project id is not going to change during the insert statement records we can safely cache
  -- the value in a local variable and use that during the insert statment.

  l_versioning_enabled_flag pa_proj_workplan_attr.wp_enable_version_flag%TYPE;

  -- End of Bug Fix 5609629


BEGIN
    g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORDS', x_Msg => 'ENTERED', x_Log_Level=> 3);
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;


    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORDS', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*4275236: Perf Enhancements*/
    l_yes := PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO','Y');
    l_no  := PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO','N');

-- Bug # 4875311.

    -- Bug Fix 5609629
    -- Caching the versioning_enabled_flag attribute value locally.
    l_versioning_enabled_flag := pa_workplan_attr_utils.check_wp_versioning_enabled(p_project_id);
    -- End of Bug Fix 5609629

-- ************************************************************************************************************************
-- if only p_structure_version_id is passed in, populate all task records for the given structure version.
-- ************************************************************************************************************************

if ((p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and (p_wbs_display_depth = -1)) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
    --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppa.project_id
   ,ppv.display_sequence  + p_sequence_offset   --bug 4448499
   ,ppvsch.milestone_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
*/
   ,decode(ppvsch.milestone_flag,'Y',l_yes,l_no)
   ,ppvsch.critical_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
*/
   ,decode(ppvsch.critical_flag,'Y',l_yes,l_no)
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type , 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code)
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_PRIORITY_CODE' ,ppe.priority_code)
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type),'Y',l_yes,l_no)
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_start_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   ,papf.work_telephone
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
*/
   ,decode(pt.chargeable_flag,'Y',l_yes,l_no)
   ,pt.chargeable_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
*/
   ,decode(pt.billable_flag,'Y',l_yes,l_no)
   ,pt.billable_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
*/
   ,decode(pt.receive_project_invoice_flag,'Y',l_yes,l_no)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id)  -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
*/
   ,decode(ppvsch.actual_finish_date,NULL,l_no,l_yes)
   ,ppe.CREATION_DATE
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id),'Y',l_yes,l_no)
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,pps3.PROJECT_STATUS_NAME
   ,ppe5.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,pt.address_id
   ,addr.address1
   ,addr.address2
   ,addr.address3
   ,addr.address4|| decode(addr.address4,null,null,', ')|| addr.city||', '||nvl(addr.state,addr.province)||', ' ||addr.county
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
   ,decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', tt.PERCENT_COMP_ENABLE_FLAG, 'N')
   ,decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', tt.REMAIN_EFFORT_ENABLE_FLAG, 'N')
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   ,pa_progress_utils.calc_wetc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                , ppru.ppl_act_effort_to_date
                , ppru.eqpmt_act_effort_to_date
                , null
                , null
                , null
                , null
                , null) estimated_remaining_effort -- Fix for Bug # 4319171.
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
                                    -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,ppe5.name
   ,ppe5.element_number
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
   ,ppwa.lifecycle_version_id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,ppeph.name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
  ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , null, null, null) Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   -- Begin Bug # 4546322
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                    , ppru.eqpmt_act_effort_to_date
                                    , null
                                    , null
                                    , null
                                    , null)
                                             , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours
                                                      , pfxat.equipment_hours
                                                      , null)
                                      , ppru.estimated_remaining_effort
                                      , ppru.eqpmt_etc_effort
                                      , null
                                      , null
                                      , null
                                      , null
                                      , null
                                      , pa_progress_utils.calc_act
                                            (ppru.ppl_act_effort_to_date
                                                                                 , ppru.eqpmt_act_effort_to_date
                                                                                 , null
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                    , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                    , null
                                    , null
                                    , null)
                         , pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                                                          , ppru.ppl_etc_cost_pc
                                      , ppru.eqpmt_etc_cost_pc
                                      , ppru.oth_etc_cost_pc
                                      , null
                                      , null
                                      , null
                                      , null
                                      , pa_progress_utils.calc_act
                                            (ppru.ppl_act_cost_to_date_pc
                                                                                 , ppru.eqpmt_act_cost_to_date_pc
                                                                                 , ppru.oth_act_cost_to_date_pc
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Cost
   -- End Bug # 4546322.
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , 'N')  Lowest_Task -- Fix for Bug # 4279419.  -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
  , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING')) Estimate_At_Completion_Cost
   ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppe.proj_element_id,
                                                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING'))) Variance_At_Completion_Cost
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index*/
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                          ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                      pppa.task_weight_basis_code,
                                          ppe.baseline_start_date,
                                          ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      pppa.task_weight_basis_code,
                                                                          ppe.baseline_start_date,
                                                              ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                                                       ppru.object_id,
                                                                       ppe.proj_element_id,
                                                                       ppru.as_of_date,
                                                                       ppv.parent_structure_version_id,
                                                                       pppa.task_weight_basis_code,
                                                                                                                                           ppe.baseline_start_date,
                                                                                                                               ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
               0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
              0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
    -- Bug Fix 5150944. NAMBURI
    --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,DECODE(ppa.structure_sharing_code,'SPLIT_MAPPING',PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code)) Mapped_Financial_Task
   ,PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,pt.gen_etc_source_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   ,ppru.BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
  ,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
 , nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    --,ra_addresses_all addr
     ,HZ_CUST_ACCT_SITES_ALL S
     ,HZ_PARTY_SITES PS
     ,HZ_LOCATIONS addr
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,pa_work_types_tl pwt
    ,pa_task_types tt
    ,pa_project_statuses pps3
    ,pa_page_layouts ppl
    ,pa_progress_rollup ppru
    -----,pa_percent_completes ppc
    ,pa_project_statuses pps
    ,pa_project_statuses pps5
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,pa_proj_workplan_attr ppwa
    ,pa_proj_element_versions ppev6
    ,pa_proj_progress_attr pppa
    ,pa_proj_element_versions ppv2
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pa_proj_elements ppeph
    ,pa_proj_element_versions ppevph
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code <> 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND ppe.object_type = 'PA_TASKS'
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id (+)
 AND pwt.language (+) = userenv('lang')
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.status_code = pps3.PROJECT_STATUS_CODE (+)
 AND pps3.STATUS_TYPE (+) = 'TASK'
 --AND pt.address_id = addr.address_id (+)
      AND pt.ADDRESS_ID = S.CUST_ACCT_SITE_ID(+)
     AND PS.PARTY_SITE_ID(+) = S.PARTY_SITE_ID
     AND addr.LOCATION_ID(+) = PS.LOCATION_ID
 AND ppe.task_progress_entry_page_id = ppl.page_id (+)
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppv.parent_structure_version_id = ppru.structure_version_id (+)
 AND NVL(ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+) = ppru.object_id
 ---AND ppc.date_computed (+) = ppru.as_of_date
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND ppe.project_id <> 0
 AND ppv.parent_structure_version_id = ppev6.element_version_id (+)
 AND ppev6.proj_element_id = ppwa.proj_element_id (+)
 AND ppev6.project_id = pppa.project_id (+)
 AND 'PA_STRUCTURES' = pppa.object_type (+)
 AND ppev6.proj_element_id = pppa.object_id (+)
 AND ppwa.current_phase_version_id = ppevph.element_version_id (+)
 AND ppevph.proj_element_id = ppeph.proj_element_id (+)
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0
 AND pfxat.txn_currency_code(+) is null
 AND pppa.structure_type(+) = 'WORKPLAN'
 AND ppa.project_id = p_project_id
 ---and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4627329.
 ---and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4627329.
 ---and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4627329.
 and ppv.parent_structure_version_id = p_structure_version_id;

-- ************************************************************************************************************************
-- if p_structure_version_id and p_wbs_display_depth are passed in, populate all task records for the structure version until the depth.
-- ************************************************************************************************************************

elsif ((p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and ( p_wbs_display_depth <> -1)) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
 , PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
 , PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
    --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppa.project_id
   ,ppv.display_sequence  + p_sequence_offset   --bug 4448499
   ,ppvsch.milestone_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
*/
   ,decode(ppvsch.milestone_flag,'Y',l_yes,l_no)
   ,ppvsch.critical_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
*/
   ,decode(ppvsch.critical_flag,'Y',l_yes,l_no)
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type , 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code)
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_PRIORITY_CODE' ,ppe.priority_code)
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type),'Y',l_yes,l_no)
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_start_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   ,papf.work_telephone
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
*/
   ,decode(pt.chargeable_flag,'Y',l_yes,l_no)
   ,pt.chargeable_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
*/
   ,decode(pt.billable_flag,'Y',l_yes,l_no)
   ,pt.billable_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
*/
   ,decode(pt.receive_project_invoice_flag,'Y',l_yes,l_no)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id)  -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
*/
   ,decode(ppvsch.actual_finish_date,NULL,l_no,l_yes)
   ,ppe.CREATION_DATE
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id),'Y',l_yes,l_no)
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,pps3.PROJECT_STATUS_NAME
   ,ppe5.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,pt.address_id
   ,addr.address1
   ,addr.address2
   ,addr.address3
   ,addr.address4|| decode(addr.address4,null,null,', ')|| addr.city||', '||nvl(addr.state,addr.province)||', ' ||addr.county
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
   ,decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', tt.PERCENT_COMP_ENABLE_FLAG, 'N')
   ,decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', tt.REMAIN_EFFORT_ENABLE_FLAG, 'N')
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   ,pa_progress_utils.calc_wetc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                , ppru.ppl_act_effort_to_date
                , ppru.eqpmt_act_effort_to_date
                , null
                , null
                , null
                , null
                , null) estimated_remaining_effort -- Fix for Bug # 4319171.
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
                                    -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,ppe5.name
   ,ppe5.element_number
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
   ,ppwa.lifecycle_version_id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,ppeph.name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
  ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , null, null, null) Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   -- Begin Bug # 4546322
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                    , ppru.eqpmt_act_effort_to_date
                                    , null
                                    , null
                                    , null
                                    , null)
                                             , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours
                                                      , pfxat.equipment_hours
                                                      , null)
                                      , ppru.estimated_remaining_effort
                                      , ppru.eqpmt_etc_effort
                                      , null
                                      , null
                                      , null
                                      , null
                                      , null
                                      , pa_progress_utils.calc_act
                                            (ppru.ppl_act_effort_to_date
                                                                                 , ppru.eqpmt_act_effort_to_date
                                                                                 , null
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                    , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                    , null
                                    , null
                                    , null)
                         , pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                                                          , ppru.ppl_etc_cost_pc
                                      , ppru.eqpmt_etc_cost_pc
                                      , ppru.oth_etc_cost_pc
                                      , null
                                      , null
                                      , null
                                      , null
                                      , pa_progress_utils.calc_act
                                            (ppru.ppl_act_cost_to_date_pc
                                                                                 , ppru.eqpmt_act_cost_to_date_pc
                                                                                 , ppru.oth_act_cost_to_date_pc
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Cost
   -- End Bug # 4546322.
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , 'N')  Lowest_Task -- Fix for Bug # 4279419.  -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
  , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING')) Estimate_At_Completion_Cost
   ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppe.proj_element_id,
                                                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING'))) Variance_At_Completion_Cost
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index*/
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                          ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                      pppa.task_weight_basis_code,
                                          ppe.baseline_start_date,
                                          ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      pppa.task_weight_basis_code,
                                                                          ppe.baseline_start_date,
                                                              ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                                                       ppru.object_id,
                                                                       ppe.proj_element_id,
                                                                       ppru.as_of_date,
                                                                       ppv.parent_structure_version_id,
                                                                       pppa.task_weight_basis_code,
                                                                                                                                           ppe.baseline_start_date,
                                                                                                                               ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
               0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
              0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
    -- Bug Fix 5150944. NAMBURI
    --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,DECODE(ppa.structure_sharing_code,'SPLIT_MAPPING',PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code)) Mapped_Financial_Task
   ,PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,pt.gen_etc_source_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   ,ppru.BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) -(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    --,ra_addresses_all addr
     ,HZ_CUST_ACCT_SITES_ALL S
     ,HZ_PARTY_SITES PS
     ,HZ_LOCATIONS addr
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,pa_work_types_tl pwt
    ,pa_task_types tt
    ,pa_project_statuses pps3
    ,pa_page_layouts ppl
    ,pa_progress_rollup ppru
    -----,pa_percent_completes ppc
    ,pa_project_statuses pps
    ,pa_project_statuses pps5
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,pa_proj_workplan_attr ppwa
    ,pa_proj_element_versions ppev6
    ,pa_proj_progress_attr pppa
    ,pa_proj_element_versions ppv2
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pa_proj_elements ppeph
    ,pa_proj_element_versions ppevph
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code <> 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND ppe.object_type = 'PA_TASKS'
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id (+)
 AND pwt.language (+) = userenv('lang')
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.status_code = pps3.PROJECT_STATUS_CODE (+)
 AND pps3.STATUS_TYPE (+) = 'TASK'
 --AND pt.address_id = addr.address_id (+)
      AND pt.ADDRESS_ID = S.CUST_ACCT_SITE_ID(+)
     AND PS.PARTY_SITE_ID(+) = S.PARTY_SITE_ID
     AND addr.LOCATION_ID(+) = PS.LOCATION_ID
 AND ppe.task_progress_entry_page_id = ppl.page_id (+)
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppv.parent_structure_version_id = ppru.structure_version_id (+)
 AND NVL(ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+) = ppru.object_id
 ---AND ppc.date_computed (+) = ppru.as_of_date
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND ppe.project_id <> 0
 AND ppv.parent_structure_version_id = ppev6.element_version_id (+)
 AND ppev6.proj_element_id = ppwa.proj_element_id (+)
 AND ppev6.project_id = pppa.project_id (+)
 AND 'PA_STRUCTURES' = pppa.object_type (+)
 AND ppev6.proj_element_id = pppa.object_id (+)
 AND ppwa.current_phase_version_id = ppevph.element_version_id (+)
 AND ppevph.proj_element_id = ppeph.proj_element_id (+)
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0
 AND pfxat.txn_currency_code(+) is null
 AND pppa.structure_type(+) = 'WORKPLAN'
 AND ppa.project_id = p_project_id
 ---and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4627329.
 ---and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4627329.
 ---and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4627329.
 and ppv.parent_structure_version_id = p_structure_version_id
 and ppv.wbs_level <= p_wbs_display_depth;

-- ************************************************************************************************************************
-- if p_task_version_id is passed in, populate all the immediate child task records for the given task version.
-- ************************************************************************************************************************

elsif (p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
    --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppa.project_id
   ,ppv.display_sequence  + p_sequence_offset   --bug 4448499
   ,ppvsch.milestone_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
*/
   ,decode(ppvsch.milestone_flag,'Y',l_yes,l_no)
   ,ppvsch.critical_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
*/
   ,decode(ppvsch.critical_flag,'Y',l_yes,l_no)
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type , 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code)
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_PRIORITY_CODE' ,ppe.priority_code)
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type),'Y',l_yes,l_no)
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_start_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   ,papf.work_telephone
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
*/
   ,decode(pt.chargeable_flag,'Y',l_yes,l_no)
   ,pt.chargeable_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
*/
   ,decode(pt.billable_flag,'Y',l_yes,l_no)
   ,pt.billable_flag
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
*/
   ,decode(pt.receive_project_invoice_flag,'Y',l_yes,l_no)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id)  -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
*/
   ,decode(ppvsch.actual_finish_date,NULL,l_no,l_yes)
   ,ppe.CREATION_DATE
/*4275236: Replaced the Function Call with local variable
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
*/
   ,decode(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id),'Y',l_yes,l_no)
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,pps3.PROJECT_STATUS_NAME
   ,ppe5.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,pt.address_id
   ,addr.address1
   ,addr.address2
   ,addr.address3
   ,addr.address4|| decode(addr.address4,null,null,', ')|| addr.city||', '||nvl(addr.state,addr.province)||', ' ||addr.county
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
   ,decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', tt.PERCENT_COMP_ENABLE_FLAG, 'N')
   ,decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', tt.REMAIN_EFFORT_ENABLE_FLAG, 'N')
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   ,pa_progress_utils.calc_wetc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                , ppru.ppl_act_effort_to_date
                , ppru.eqpmt_act_effort_to_date
                , null
                , null
                , null
                , null
                , null) estimated_remaining_effort -- Fix for Bug # 4319171.
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
                                    -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,ppe5.name
   ,ppe5.element_number
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
   ,ppwa.lifecycle_version_id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,ppeph.name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
  ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , null, null, null) Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   -- Begin Bug # 4546322
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                    , ppru.eqpmt_act_effort_to_date
                                    , null
                                    , null
                                    , null
                                    , null)
                                             , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours
                                                      , pfxat.equipment_hours
                                                      , null)
                                      , ppru.estimated_remaining_effort
                                      , ppru.eqpmt_etc_effort
                                      , null
                                      , null
                                      , null
                                      , null
                                      , null
                                      , pa_progress_utils.calc_act
                                            (ppru.ppl_act_effort_to_date
                                                                                 , ppru.eqpmt_act_effort_to_date
                                                                                 , null
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                    , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                    , null
                                    , null
                                    , null)
                         , pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                                                          , ppru.ppl_etc_cost_pc
                                      , ppru.eqpmt_etc_cost_pc
                                      , ppru.oth_etc_cost_pc
                                      , null
                                      , null
                                      , null
                                      , null
                                      , pa_progress_utils.calc_act
                                            (ppru.ppl_act_cost_to_date_pc
                                                                                 , ppru.eqpmt_act_cost_to_date_pc
                                                                                 , ppru.oth_act_cost_to_date_pc
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Cost
   -- End Bug # 4546322.
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , 'N')  Lowest_Task -- Fix for Bug # 4279419.  -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
  , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING')) Estimate_At_Completion_Cost
   ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppe.proj_element_id,
                                                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING'))) Variance_At_Completion_Cost
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
 (((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index*/
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                          ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                      pppa.task_weight_basis_code,
                                          ppe.baseline_start_date,
                                          ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      pppa.task_weight_basis_code,
                                                                          ppe.baseline_start_date,
                                                              ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                                                       ppru.object_id,
                                                                       ppe.proj_element_id,
                                                                       ppru.as_of_date,
                                                                       ppv.parent_structure_version_id,
                                                                       pppa.task_weight_basis_code,
                                                                                                                                           ppe.baseline_start_date,
                                                                                                                               ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
               0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
              0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
    -- Bug Fix 5150944. NAMBURI
    --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,DECODE(ppa.structure_sharing_code,'SPLIT_MAPPING',PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code)) Mapped_Financial_Task
   ,PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,pt.gen_etc_source_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   ,ppru.BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
 ,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))  PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
 ,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    --,ra_addresses_all addr
     ,HZ_CUST_ACCT_SITES_ALL S
     ,HZ_PARTY_SITES PS
     ,HZ_LOCATIONS addr
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,pa_work_types_tl pwt
    ,pa_task_types tt
    ,pa_project_statuses pps3
    ,pa_page_layouts ppl
    ,pa_progress_rollup ppru
    -----,pa_percent_completes ppc
    ,pa_project_statuses pps
    ,pa_project_statuses pps5
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,pa_proj_workplan_attr ppwa
    ,pa_proj_element_versions ppev6
    ,pa_proj_progress_attr pppa
    ,pa_proj_element_versions ppv2
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pa_proj_elements ppeph
    ,pa_proj_element_versions ppevph
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code <> 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND ppe.object_type = 'PA_TASKS'
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id (+)
 AND pwt.language (+) = userenv('lang')
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.status_code = pps3.PROJECT_STATUS_CODE (+)
 AND pps3.STATUS_TYPE (+) = 'TASK'
 --AND pt.address_id = addr.address_id (+)
      AND pt.ADDRESS_ID = S.CUST_ACCT_SITE_ID(+)
     AND PS.PARTY_SITE_ID(+) = S.PARTY_SITE_ID
     AND addr.LOCATION_ID(+) = PS.LOCATION_ID
 AND ppe.task_progress_entry_page_id = ppl.page_id (+)
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppv.parent_structure_version_id = ppru.structure_version_id (+)
 AND NVL(ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+) = ppru.object_id
 ---AND ppc.date_computed (+) = ppru.as_of_date
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND ppe.project_id <> 0
 AND ppv.parent_structure_version_id = ppev6.element_version_id (+)
 AND ppev6.proj_element_id = ppwa.proj_element_id (+)
 AND ppev6.project_id = pppa.project_id (+)
 AND 'PA_STRUCTURES' = pppa.object_type (+)
 AND ppev6.proj_element_id = pppa.object_id (+)
 AND ppwa.current_phase_version_id = ppevph.element_version_id (+)
 AND ppevph.proj_element_id = ppeph.proj_element_id (+)
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0
 AND pfxat.txn_currency_code(+) is null
 AND pppa.structure_type(+) = 'WORKPLAN'
 AND ppa.project_id = p_project_id
 ---and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4627329.
 ---and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4627329.
 ---and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4627329.
 and ppv.parent_structure_version_id = p_structure_version_id
 and por.object_id_from1 = p_task_version_id;

end if;

-- Bug # 4875311.

--bug 4448499
--count the number of tasks beign inserted:
global_sub_proj_task_count :=  global_sub_proj_task_count + SQL%ROWCOUNT;
--bug 4448499


/*4275236 : If Workplan Cost is not enabled,Update the Values of Cost Columns as Empty
  We are not using decode() in insert statement because it resulted in very poor performance
*/

IF pa_fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id) <> 'Y' THEN

UPDATE pa_structures_tasks_tmp
set raw_cost = null,burdened_cost=null,planned_cost=null,Percent_Spent_Cost=null,Percent_Complete_Cost=null,
    Actual_Cost = null,Baseline_Cost=null,Estimate_At_Completion_Cost=null,
    Planned_Cost_Per_Unit=null,Actual_Cost_Per_Unit=null,Variance_At_Completion_Cost=null,
    ETC_Cost =null
     , PLANNED_BASELINE_COST_VAR = NULL --Added for bug 5090355
where project_id = p_project_id
  and parent_structure_version_id=p_structure_version_id;

END IF;

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_WORKING_RECORDS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_WORKING_RECORDS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END INSERT_WORKING_RECORDS;


procedure INSERT_SUBPROJECTS
(
    p_api_version           IN      NUMBER      := 1.0,
    p_init_msg_list         IN      VARCHAR2    := FND_API.G_TRUE,
    p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
    p_validate_only         IN      VARCHAR2    := FND_API.G_TRUE,
    p_debug_mode            IN      VARCHAR2    := 'N',
        p_calling_page_name             IN              VARCHAR2,
    p_project_id            IN      NUMBER,
    p_structure_version_id  IN      NUMBER,
        p_parent_project_id IN      NUMBER,
    p_wbs_display_depth             IN              NUMBER          := -1, -- Bug # 4875311.
    x_return_status         OUT   NOCOPY   VARCHAR2,
    x_msg_count             OUT   NOCOPY   NUMBER,
    x_msg_data              OUT   NOCOPY   VARCHAR2
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'INSERT_SUBPROJECTS'   ;
   l_api_version                   CONSTANT NUMBER      := 1.0                            ;
   l_return_status                 VARCHAR2(1)                                       ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID                   ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID                  ;
   g1_debug_mode            VARCHAR2(1)                                    ;

    cursor get_structures IS
      select por1.object_id_to1, por1.object_id_to2
            ,display_sequence, por1.object_id_from2       --bug 4448499
        from pa_object_relationships por1
             ,pa_proj_element_versions ppv   --bug 4448499
       where por1.relationship_type = 'LW'
         and ppv.element_version_id = por1.object_id_from1  --bug 4448499
         and por1.object_id_from1 IN (SELECT ppevs.element_version_id
                                 FROM pa_proj_elements ppes, pa_proj_element_versions ppevs
                                 WHERE ppes.project_id = ppevs.project_id
                                 AND ppes.proj_element_id = ppevs.proj_element_id
                                 AND ppes.link_task_flag = 'Y'
                                 AND ppes.object_type = 'PA_TASKS'
                                 AND ppes.project_id= p_project_id
                                 AND ppevs.parent_structure_version_id = p_structure_version_id)
      order by display_sequence  --bug 4448499
      ;

--bug 4448499   Get the updated display sequence of the parent linked task.
-- Bug 6156686

     CURSOR cur_get_parent_disp( c_subproject_id NUMBER, c_subproj_struc_ver_id NUMBER )
     IS
     SELECT a.display_sequence
       FROM pa_structures_tasks_tmp a,
            pa_object_relationships b
      WHERE b.object_id_to1=c_subproj_struc_ver_id
        AND b.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
        AND b.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
        AND b.relationship_type = 'S'
        AND a.element_version_id = b.object_id_from1;

    l_immediate_parent_proj_id NUMBER;
    l_sub_proj_str_disp_seq    NUMBER;
--bug 4448499

    l_struc_ver_id NUMBER;
    l_project_id NUMBER;

  -- Bug Fix 5609629.
  -- Caching the wp_version_enable_flag in a local variable in order to avoid the function call
  -- during the insert statements. This will avoid the multiple executions of the same select.
  -- The project id is passed as a parameter to the pa_workplan_attr_utils.check_wp_versioning_enabled
  -- As the project id is not going to change during the insert statement records we can safely cache
  -- the value in a local variable and use that during the insert statment.

  l_versioning_enabled_flag pa_proj_workplan_attr.wp_enable_version_flag%TYPE;

  -- End of Bug Fix 5609629

BEGIN
    g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'ENTERED', x_Log_Level=> 3);
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;


    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
    END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --check if projects has subprojects
        OPEN get_structures;
        FETCH get_structures into l_struc_ver_id, l_project_id
              ,l_sub_proj_str_disp_seq, l_immediate_parent_proj_id; --bug 4448499
        IF get_structures%NOTFOUND THEN
          CLOSE get_structures;
          return;
        END IF;
        CLOSE get_structures;
        --end check

-- Begin fix for Bug # 4485192.

-- This fix deletes any sub-project records that exist in the temp table: pa_structures_tasks_v
-- before they are populated again. When a sub-project is common to multiple parent projects and
-- the user navigates between the parent projects, this fix serves to remove the sub-project
-- records populated in the context of the previously accessed parent project, because they are
-- re-populated in the context of the currently accessed parent project.

delete from pa_structures_tasks_tmp pstt
where pstt.project_id in (select  por1.object_id_to2
                  from pa_object_relationships por1
                           ,pa_proj_element_versions ppv
                  where por1.relationship_type = 'LW'
                  and ppv.element_version_id = por1.object_id_from1
                  and por1.object_id_from1 IN (SELECT ppevs.element_version_id
                                               FROM pa_proj_elements ppes
                                , pa_proj_element_versions ppevs
                                               WHERE ppes.project_id = ppevs.project_id
                                               AND ppes.proj_element_id = ppevs.proj_element_id
                                               AND ppes.link_task_flag = 'Y'
                                               AND ppes.object_type = 'PA_TASKS'
                                               AND ppes.project_id= p_project_id
                                               AND ppevs.parent_structure_version_id = p_structure_version_id));


-- End fix for Bug # 4485192.


    -- Bug Fix 5609629
    -- Caching the versioning_enabled_flag attribute value locally.
    l_versioning_enabled_flag := pa_workplan_attr_utils.check_wp_versioning_enabled(p_project_id);
    -- End of Bug Fix 5609629


-- bug 4416432: insert working structures
INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, current_working_flag -- Fix for Bug # Bug # 3745252.
, current_flag -- Fix for Bug # 3745252.
, BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
    --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,to_char( ppvs.version_number )
   ,ppvs.name
   ,ppe.description
   ,ppe.object_type
   ,por.object_id_to1
   ,ppe.proj_element_id
   ,ppv1.project_id
   ,ppv3.display_sequence
   ,'N' milestone_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', 'N')
   ,'N' critical_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', 'N')
   ,por2.object_id_from1
   ,por2.object_type_from
   ,por2.relationship_type
   ,por2.relationship_subtype
   ,'Y' summary_element_flag
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code)
   ,PPS.PROJECT_STATUS_NAME
   ,null  ----ppc.PROGRESS_COMMENT
   ,null  ----ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv1.parent_structure_version_id
   , 0 -- ppv1.wbs_level -- Fix for Bug # 4279419.
   ,'0'
   ,ppe.record_version_number
   ,ppv1.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   , decode(ppe.object_type, 'PA_STRUCTURES', ppvs.status_code, ppe.status_code) status_code
                                    -- Fix for Bug # 3745252.
   ,to_char(null)
   ,ppe.priority_code
   ,to_char(null)
   ,ppe.carrying_out_organization_id
   ,to_char(null)
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
--   ,to_number(NULL) 4479775
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp ) -- Bug 4479775
   ,to_number(null)
   ,to_number(null)
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,to_char(null)
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por2.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv1.element_version_id, ppv1.object_type)
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv1.element_version_id, ppv1.object_type))
   ,to_number(null)
   ,to_number(null)
   ,papf.work_telephone
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_number(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_date(null)
   ,to_date(null)
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   ,'N'
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,ppe.CREATION_DATE
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO','N')
   ,ppe.TYPE_ID
   ,to_char(null)
   ,ppe.STATUS_CODE
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,to_number(null)
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,to_number(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,pa_progress_utils.calc_wetc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.ppl_act_effort_to_date
                                , ppru.eqpmt_act_effort_to_date
                                , null
                                , null
                                , null
                                , null
                                , null) estimated_remaining_effort -- Fix for Bug # 4319171.
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv1.project_id, ppv1.parent_structure_version_id) -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_number(null)
   ,ppv1.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv1.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,to_char(null)
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , null, null, null) Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv1.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                     ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv1.prg_group, null  -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv1.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , ' ') Lowest_Task -- Fix for Bug # 4279419.--4284056 changed from 'Y' to ' ' -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_wetc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.ppl_act_effort_to_date
                                , ppru.eqpmt_act_effort_to_date
                                , null
                                , null
                                , null
                                , null
                                , null) etc_effort -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
     +nvl(ppru.eqpmt_act_effort_to_date,0)
     +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)
                    +nvl(pfxat.equipment_hours,0))
                                       ,ppru.estimated_remaining_effort
                       ,ppru.eqpmt_etc_effort,null
                                       ,ppru.subprj_ppl_etc_effort
                       ,ppru.subprj_eqpmt_etc_effort
                       ,null
                       ,null
                                       ,(nvl(ppru.ppl_act_effort_to_date,0)
                     +nvl(ppru.eqpmt_act_effort_to_date,0)
                                 +nvl(ppru.subprj_ppl_act_effort,0)
                     +nvl(ppru.subprj_eqpmt_act_effort,0))
                       ,'WORKING')) Estimate_At_Completion_Effort -- Fix for Bug # 4485364.
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +PA_PROGRESS_UTILS.derive_etc_values((NVL(pfxat.labor_hours,0)+NVL(pfxat.equipment_hours,0))
                                             ,ppru.ppl_act_effort_to_date
                                             ,ppru.eqpmt_act_effort_to_date
                                             ,null,null,null,null,null))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
      +nvl(ppru.ppl_act_cost_to_date_pc,0)
      +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
      +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                        ,ppru.ppl_etc_cost_pc
                                        ,ppru.eqpmt_etc_cost_pc
                                        ,ppru.oth_etc_cost_pc
                                ,ppru.subprj_ppl_etc_cost_pc
                    ,ppru.subprj_eqpmt_etc_cost_pc
                                    ,ppru.subprj_oth_etc_cost_pc,null
                                ,(nvl(ppru.oth_act_cost_to_date_pc,0)
                      +nvl(ppru.ppl_act_cost_to_date_pc,0)
                                      +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
                      +nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                                  +nvl(ppru.subprj_ppl_act_cost_pc,0)
                      +nvl(ppru.subprj_eqpmt_act_cost_pc,0))
                    , 'WORKING')) Estimate_At_Completion_Cost -- Fix for Bug # 4485364.
   ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)
            +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),2) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),2) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv1.proj_element_id,
                                   ppru.as_of_date,
                                   ppv1.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0))  Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppe.proj_element_id,
                                                                   ppru.as_of_date,
                                   ppv1.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +PA_PROGRESS_UTILS.derive_etc_values(pfxat.prj_brdn_cost
                                             ,ppru.ppl_act_cost_to_date_pc
                                             ,ppru.eqpmt_act_cost_to_date_pc
                                             ,ppru.oth_act_cost_to_date_pc
                                             ,null,null,null,null))) Variance_At_Completion_Cost
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))),
    0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
*/
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                          ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv1.parent_structure_version_id,
                      pppa.task_weight_basis_code,
                                          ppe.baseline_start_date,
                                          ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv1.parent_structure_version_id,
                                      pppa.task_weight_basis_code,
                                                                          ppe.baseline_start_date,
                                                              ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                                                       ppru.object_id,
                                                                       ppe.proj_element_id,
                                                                       ppru.as_of_date,
                                                                       ppv1.parent_structure_version_id,
                                                                       pppa.task_weight_basis_code,
                                                                                                                                           ppe.baseline_start_date,
                                                                                                                               ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
          0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
          0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv1.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,to_char ( null )
   ,to_char ( null )
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv1.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   , ppvs.current_working_flag -- Fix for Bug # 3745252.
   , ppvs.current_flag -- Fix for Bug # 3745252.
   , ppru.BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
 ,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) -(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
 ,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM
     pa_proj_elem_ver_structure ppvs
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_projects_all ppa
    ,pa_page_layouts ppl
    ,pa_project_statuses pps
    ,pa_proj_element_versions ppv2
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv3
    ,pa_proj_element_versions ppv1
    ,pa_object_relationships por
    ,pa_object_relationships por2
    ,pji_fm_xbs_accum_tmp1 pfxat
    ----,pa_percent_completes ppc
    ,pa_progress_rollup ppru
    ,pa_proj_progress_attr pppa
where
    por.object_id_from1 in ( SELECT ppevs.element_version_id
                               FROM pa_proj_elements ppes, pa_proj_element_versions ppevs
                              WHERE ppes.project_id = ppevs.project_id
                                AND ppes.proj_element_id = ppevs.proj_element_id
                                AND ppes.link_task_flag = 'Y'
                                AND ppes.object_type = 'PA_TASKS'
                                AND ppes.project_id= p_project_id
                                AND ppevs.parent_structure_version_id = p_structure_version_id
                                )
AND por.relationship_type          in ( 'LW' )
AND por.object_id_to1                  = ppv1.element_version_id
AND ppv1.proj_element_id               = ppe.proj_element_id
AND por.object_id_from1                = ppv3.element_version_id
AND por.object_id_from1                = por2.object_id_to1
AND ppe.task_progress_entry_page_id    = ppl.page_id (+)
AND ppv1.element_version_id            = ppvs.element_version_id (+)
AND ppv1.project_id                    = ppvs.project_id (+)
AND ppv1.element_version_id            = ppvsch.element_version_id (+)
AND ppv1.project_id                    = ppvsch.project_id (+)
AND ppe.manager_person_id              = papf.person_id(+)
AND ppv2.element_version_id            = por2.object_id_from1
AND ppe.project_id                     = ppa.project_id
AND pfxat.project_id (+)               = ppv1.project_id
AND pfxat.project_element_id (+)       = ppv1.proj_element_id
AND pfxat.struct_version_id (+)        = ppv1.parent_structure_version_id
AND pfxat.calendar_type(+)             = 'A'
AND pfxat.plan_version_id (+)          > 0
AND pfxat.txn_currency_code(+) is null
AND ppv1.project_id                    = ppru.project_id(+)
AND ppv1.proj_element_id               = ppru.object_id(+)
AND ppv1.object_type                   = ppru.object_type(+)
AND ppru.structure_type (+)            = 'WORKPLAN'
AND ppvs.status_code = 'STRUCTURE_WORKING' -- Fix for Bug # 4416432, Issue # 7.
AND ppv1.parent_structure_version_id   = ppru.structure_version_id (+)  -- Fix for Bug # 4416432, Issue # 7.
AND ppru.current_flag(+) = 'Y' --  Bug # 4416432, Issue # 18
AND NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code ) = pps.PROJECT_STATUS_CODE(+)
---AND ppc.project_id (+)                 = ppru.project_id
---AND ppc.object_type (+)                = ppru.object_type
---AND ppc.object_id (+)                  = ppru.object_id
---AND ppc.date_computed (+)              = ppru.as_of_date
---AND ppc.structure_type (+)             = ppru.structure_type
AND pppa.project_id (+)                = ppe.project_id
AND pppa.object_type (+)               = 'PA_STRUCTURES'
AND pppa.object_id (+)                 = ppe.proj_element_id
AND pppa.structure_type(+)             = 'WORKPLAN'
-- Begin fix for Bug # 4416432, Issue # 7.
UNION ALL
SELECT
    --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
    /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,to_char( ppvs.version_number )
   ,ppvs.name
   ,ppe.description
   ,ppe.object_type
   ,por.object_id_to1
   ,ppe.proj_element_id
   ,ppv1.project_id
   ,ppv3.display_sequence
   ,'N' milestone_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', 'N')
   ,'N' critical_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', 'N')
   ,por2.object_id_from1
   ,por2.object_type_from
   ,por2.relationship_type
   ,por2.relationship_subtype
   ,'Y' summary_element_flag
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code)
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv1.parent_structure_version_id
   , 0 -- ppv1.wbs_level -- Fix for Bug # 4279419.
   ,'0'
   ,ppe.record_version_number
   ,ppv1.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   , decode(ppe.object_type, 'PA_STRUCTURES', ppvs.status_code, ppe.status_code) status_code
                                    -- Fix for Bug # 3745252.
   ,to_char(null)
   ,ppe.priority_code
   ,to_char(null)
   ,ppe.carrying_out_organization_id
   ,to_char(null)
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
--   ,to_number(NULL) 4479775
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp ) -- 4479775
   ,to_number(null)
   ,to_number(null)
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,to_char(null)
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por2.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv1.element_version_id, ppv1.object_type)
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv1.element_version_id, ppv1.object_type))
   ,to_number(null)
   ,to_number(null)
   ,papf.work_telephone
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_number(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_date(null)
   ,to_date(null)
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   ,'N'
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,ppe.CREATION_DATE
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO','N')
   ,ppe.TYPE_ID
   ,to_char(null)
   ,ppe.STATUS_CODE
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,to_number(null)
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,to_number(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                                                                 -- Fix for Bug # 4319171.
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv1.project_id, ppv1.parent_structure_version_id) -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_char(null)
   ,to_number(null)
   ,ppv1.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv1.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,to_char(null)
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , null, null, null) Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv1.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                     ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv1.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv1.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , ' ') Lowest_Task -- Fix for Bug # 4279419.--4284056 changed from 'Y' to ' ' -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
     +nvl(ppru.eqpmt_act_effort_to_date,0)
     +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)
                                        +nvl(pfxat.equipment_hours,0))
                                       ,ppru.estimated_remaining_effort
                                       ,ppru.eqpmt_etc_effort,null
                                       ,ppru.subprj_ppl_etc_effort
                                       ,ppru.subprj_eqpmt_etc_effort
                                       ,null
                                       ,null
                                       ,(nvl(ppru.ppl_act_effort_to_date,0)
                                         +nvl(ppru.eqpmt_act_effort_to_date,0)
                                         +nvl(ppru.subprj_ppl_act_effort,0)
                                         +nvl(ppru.subprj_eqpmt_act_effort,0))
                                       ,'PUBLISH')) Estimate_At_Completion_Effort -- Fix for Bug # 4485364.
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +PA_PROGRESS_UTILS.derive_etc_values((NVL(pfxat.labor_hours,0)+NVL(pfxat.equipment_hours,0))
                                             ,ppru.ppl_act_effort_to_date
                                             ,ppru.eqpmt_act_effort_to_date
                                             ,null,null,null,null,null))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
     +nvl(ppru.ppl_act_cost_to_date_pc,0)
     +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
     +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                        ,ppru.ppl_etc_cost_pc
                                        ,ppru.eqpmt_etc_cost_pc
                                        ,ppru.oth_etc_cost_pc
                                        ,ppru.subprj_ppl_etc_cost_pc
                                        ,ppru.subprj_eqpmt_etc_cost_pc
                                        ,ppru.subprj_oth_etc_cost_pc,null
                                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)
                                          +nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
                                          +nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                                          +nvl(ppru.subprj_ppl_act_cost_pc,0)
                                          +nvl(ppru.subprj_eqpmt_act_cost_pc,0))
                                        , 'PUBLISH')) Estimate_At_Completion_Cost -- Fix for Bug # 4485364.
   ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)
            +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),2) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),2) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv1.proj_element_id,
                                   ppru.as_of_date,
                                   ppv1.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0))  Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppe.proj_element_id,
                                                                   ppru.as_of_date,
                                   ppv1.parent_structure_version_id,
                                   pppa.task_weight_basis_code,
                                                                   ppe.baseline_start_date,
                                                       ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +PA_PROGRESS_UTILS.derive_etc_values(pfxat.prj_brdn_cost
                                             ,ppru.ppl_act_cost_to_date_pc
                                             ,ppru.eqpmt_act_cost_to_date_pc
                                             ,ppru.oth_act_cost_to_date_pc
                                             ,null,null,null,null))) Variance_At_Completion_Cost
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))),
    0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
*/
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value) / decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                          ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv1.parent_structure_version_id,
                      pppa.task_weight_basis_code,
                                          ppe.baseline_start_date,
                                          ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv1.parent_structure_version_id,
                                      pppa.task_weight_basis_code,
                                                                          ppe.baseline_start_date,
                                                              ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                                                       ppru.object_id,
                                                                       ppe.proj_element_id,
                                                                       ppru.as_of_date,
                                                                       ppv1.parent_structure_version_id,
                                                                       pppa.task_weight_basis_code,
                                                                                                                                           ppe.baseline_start_date,
                                                                                                                               ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
          0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
          0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv1.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,to_char ( null )
   ,to_char ( null )
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv1.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   , ppvs.current_working_flag -- Fix for Bug # 3745252.
   , ppvs.current_flag -- Fix for Bug # 3745252.
   , ppru.BASE_PERCENT_COMPLETE -- Bug 4416432 Issue 2
,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))  PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM
     pa_proj_elem_ver_structure ppvs
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_projects_all ppa
    ,pa_page_layouts ppl
    ,pa_project_statuses pps
    ,pa_proj_element_versions ppv2
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv3
    ,pa_proj_element_versions ppv1
    ,pa_object_relationships por
    ,pa_object_relationships por2
    ,pji_fm_xbs_accum_tmp1 pfxat
    ----,pa_percent_completes ppc
    ,pa_progress_rollup ppru
    ,pa_proj_progress_attr pppa
where
    por.object_id_from1 in ( SELECT ppevs.element_version_id
                               FROM pa_proj_elements ppes, pa_proj_element_versions ppevs
                              WHERE ppes.project_id = ppevs.project_id
                                AND ppes.proj_element_id = ppevs.proj_element_id
                                AND ppes.link_task_flag = 'Y'
                                AND ppes.object_type = 'PA_TASKS'
                                AND ppes.project_id= p_project_id
                                AND ppevs.parent_structure_version_id = p_structure_version_id
                                )
AND por.relationship_type          in ( 'LW' )
AND por.object_id_to1                  = ppv1.element_version_id
AND ppv1.proj_element_id               = ppe.proj_element_id
AND por.object_id_from1                = ppv3.element_version_id
AND por.object_id_from1                = por2.object_id_to1
AND ppe.task_progress_entry_page_id    = ppl.page_id (+)
AND ppv1.element_version_id            = ppvs.element_version_id (+)
AND ppv1.project_id                    = ppvs.project_id (+)
AND ppv1.element_version_id            = ppvsch.element_version_id (+)
AND ppv1.project_id                    = ppvsch.project_id (+)
AND ppe.manager_person_id              = papf.person_id(+)
AND ppv2.element_version_id            = por2.object_id_from1
AND ppe.project_id                     = ppa.project_id
AND pfxat.project_id (+)               = ppv1.project_id
AND pfxat.project_element_id (+)       = ppv1.proj_element_id
AND pfxat.struct_version_id (+)        = ppv1.parent_structure_version_id
AND pfxat.calendar_type(+)             = 'A'
AND pfxat.plan_version_id (+)          > 0
AND pfxat.txn_currency_code(+) is null
AND ppv1.project_id                    = ppru.project_id(+)
AND ppv1.proj_element_id               = ppru.object_id(+)
AND ppv1.object_type                   = ppru.object_type(+)
AND ppru.structure_type (+)            = 'WORKPLAN'
AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
AND ppru.structure_version_id (+) is null
-- Begin fix for Bug # 4499065.
AND ppru.current_flag(+) <> 'W'  --- = 'Y' (changed to <> 'W' condition) Bug # 4416432, Issue # 18
AND ppru.object_version_id(+) = ppv1.element_version_id
AND nvl(ppru.as_of_date, trunc(sysdate)) = (select /*+  INDEX (ppr2 pa_progress_rollup_u2)*/ nvl(max(ppr2.as_of_date),trunc(sysdate))  --Bug 7644130
                                           from pa_progress_rollup ppr2
                                           where
                                           ppr2.object_id = ppv1.proj_element_id
                                           and ppr2.proj_element_id = ppv1.proj_element_id
                                           and ppr2.object_version_id = ppv1.element_version_id
                                           and ppr2.project_id = ppv1.project_id
                                           and ppr2.object_type = 'PA_STRUCTURES'
                                           and ppr2.structure_type = 'WORKPLAN'
                                           and ppr2.structure_version_id is null
                                           and ppr2.current_flag <> 'W')
-- End fix for Bug # 4499065.
AND NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code ) = pps.PROJECT_STATUS_CODE(+)
---AND ppc.project_id (+)                 = ppru.project_id
---AND ppc.object_type (+)                = ppru.object_type
---AND ppc.object_id (+)                  = ppru.object_id
---AND ppc.date_computed (+)              = ppru.as_of_date
---AND ppc.structure_type (+)             = ppru.structure_type
AND pppa.project_id (+)                = ppe.project_id
AND pppa.object_type (+)               = 'PA_STRUCTURES'
AND pppa.object_id (+)                 = ppe.proj_element_id
AND pppa.structure_type(+)             = 'WORKPLAN';
-- End fix for Bug # 4416432, Issue # 7.

--AND ppa.project_id = p_project_id

--code to populate tasks for subprojects
  BEGIN
    OPEN get_structures;
    LOOP
      FETCH get_structures into l_struc_ver_id, l_project_id
      ,l_sub_proj_str_disp_seq, l_immediate_parent_proj_id;   --bug 4448499
      EXIT WHEN get_structures%NOTFOUND;

      --bug 4448499
      IF p_calling_page_name = 'GANTT_REGION'
      THEN

        OPEN cur_get_parent_disp( l_project_id, l_struc_ver_id );
        FETCH cur_get_parent_disp INTO l_sub_proj_str_disp_seq;
        CLOSE cur_get_parent_disp;

        global_sequence_number := global_sequence_number + l_sub_proj_str_disp_seq + get_structures%ROWCOUNT; --add rowcount to
        --move the sub-project record rowcount places ahead. This is required if there are multiple sub-projects originating
        --from the same linked task.

        --update the structure record with the global_sequnece
        Update pa_structures_tasks_tmp
          set display_sequence = global_sequence_number
         where element_version_id = l_struc_ver_id
           and project_id= l_project_id
         ;
      END IF;

      IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'global_sequence_number: '||global_sequence_number, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'l_sub_proj_str_disp_seq: '||l_sub_proj_str_disp_seq, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'Before global_sub_proj_task_count: '||global_sub_proj_task_count, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'Before calling Populate_structures_tmp_tab recursively:', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'l_project_id='||l_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'p_parent_project_id='||p_parent_project_id, x_Log_Level=> 3);
      END IF;
      --bug 4448499

      --insert tasks by calling populate_structures_tmp_tab
      Populate_structures_tmp_tab(p_project_id            => l_project_id,
        p_structure_version_id  => l_struc_ver_id,
        p_parent_project_id => p_parent_project_id,
        p_calling_page_name     => p_calling_page_name,
        p_sequence_offset       => global_sequence_number,   --bug 4448499
        p_wbs_display_depth     => p_wbs_display_depth, -- Bug # 4875311.
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

      --bug 4448499
      IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'After calling Populate_structures_tmp_tab recursively for project:'||l_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_SUBPROJECTS', x_Msg => 'After global_sub_proj_task_count: '||global_sub_proj_task_count, x_Log_Level=> 3);
      END IF;

     /* IF p_calling_page_name = 'GANTT_REGION'
      THEN

          --Update all the tasks of the immediate parent project to move them relative to all sub-projects and their sub-tasks that were added before these tasks.
          UPDATE pa_structures_tasks_tmp
            SET display_sequence = display_sequence + global_sequence_number + global_sub_proj_task_count
          WHERE project_id = l_immediate_parent_proj_id
            AND display_sequence > l_sub_proj_str_disp_seq
            AND element_version_id <> l_struc_ver_id;

       --Move the next sub-proj structure after the last task of previous sub-proj structure is inserted
       select max(display_sequence) + 1 into global_sequence_number
              from pa_structures_tasks_tmp
       where project_id = l_immediate_parent_proj_id;
      END IF; */ --bug 7434683
      --bug 4448499

    END LOOP;
    CLOSE get_structures;
  END;
--end code to populate tasks for subprojects
--end bug 4197654

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_SUBPROJECTS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_SUBPROJECTS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END INSERT_SUBPROJECTS;


-------
-----SINGLE RECORD APIs to poulate published and working records
-------

procedure INSERT_PUBLISHED_RECORD
(
    p_api_version           IN      NUMBER      := 1.0,
    p_init_msg_list         IN      VARCHAR2    := FND_API.G_TRUE,
    p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
    p_validate_only         IN      VARCHAR2    := FND_API.G_TRUE,
    p_debug_mode            IN      VARCHAR2    := 'N',
    p_project_id            IN      NUMBER,
    p_structure_version_id  IN      NUMBER,
    p_task_version_id  IN      NUMBER,
        p_parent_project_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    x_return_status         OUT  NOCOPY    VARCHAR2,
    x_msg_count             OUT  NOCOPY    NUMBER,
    x_msg_data              OUT  NOCOPY    VARCHAR2
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'INSERT_PUBLISHED_RECORD'   ;
   l_api_version                   CONSTANT NUMBER      := 1.0                            ;
   l_return_status                 VARCHAR2(1)                                       ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID                   ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID                  ;
   g1_debug_mode            VARCHAR2(1)                                    ;

  -- Bug Fix 5609629.
  -- Caching the wp_version_enable_flag in a local variable in order to avoid the function call
  -- during the insert statements. This will avoid the multiple executions of the same select.
  -- The project id is passed as a parameter to the pa_workplan_attr_utils.check_wp_versioning_enabled
  -- As the project id is not going to change during the insert statement records we can safely cache
  -- the value in a local variable and use that during the insert statment.

  l_versioning_enabled_flag pa_proj_workplan_attr.wp_enable_version_flag%TYPE;

  -- End of Bug Fix 5609629

BEGIN
    g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORD', x_Msg => 'ENTERED', x_Log_Level=> 3);
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;


    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_PUBLISHED_RECORD', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug Fix 5609629
    -- Caching the versioning_enabled_flag attribute value locally.
    l_versioning_enabled_flag := pa_workplan_attr_utils.check_wp_versioning_enabled(p_project_id);
    -- End of Bug Fix 5609629

--Populate published versions records first.
INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
)
SELECT
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppa.project_id
   ,ppv.display_sequence
   ,ppvsch.milestone_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
   ,ppvsch.critical_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type , 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ----ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_PRIORITY_CODE' ,ppe.priority_code)
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_start_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   ,papf.work_telephone
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
   ,pt.chargeable_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
   ,pt.billable_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,null --PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,ppe.CREATION_DATE
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,pps3.PROJECT_STATUS_NAME
   ,ppe5.phase_code
   ,pps5.project_status_name
   ,null --NVL(pfxat.labor_hours,0) + NVL(pfxat.equipment_hours,0)
   ,por.WEIGHTING_PERCENTAGE
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,pt.address_id
   ,addr.address1
   ,addr.address2
   ,addr.address3
   ,addr.address4|| decode(addr.address4,null,null,', ')|| addr.city||', '||nvl(addr.state,addr.province)||', ' ||addr.county
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
   ,decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', tt.PERCENT_COMP_ENABLE_FLAG, 'N')
   ,decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', tt.REMAIN_EFFORT_ENABLE_FLAG, 'N')
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE', NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   ,null --pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
         --               ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
         --               ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
         --               ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
         --                +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) estimated_remaining_effort
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
                                    -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,ppe5.name
   ,ppe5.element_number
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
   ,ppwa.lifecycle_version_id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,ppeph.name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,null --NVL(pfxat.equipment_hours,0)
   ,null --pfxat.prj_raw_cost
   ,null --pfxat.prj_brdn_cost
   ,null --NVL(pfxat.prj_brdn_cost,0)
   ,nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0) Actual_Effort
   ,NVL(ppru.eqpmt_act_effort_to_date,0)
   ,null --PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,null --PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
           --                             (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                --       ) percent_Spent_Effort
   ,null --PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
           --                             +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
             --                           nvl(pfxat.prj_brdn_cost,0)
                --       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                     ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , 'N')  Lowest_Task -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,null --NVL(pfxat.base_equip_hours,0) + NVL(pfxat.base_labor_hours,0) Baseline_effort
   ,null --pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
           --             ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
             --           ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
               --         ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                 --        +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) ETC_EFFORT
   ,null --nvl(ppru.ppl_act_effort_to_date,0)
        --+nvl(ppru.eqpmt_act_effort_to_date,0)
        --+pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
          --              ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
            --            ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
              --          ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                --         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) Estimate_At_Completion_Effort
   ,null --nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)
       -- -(nvl(ppru.ppl_act_effort_to_date,0)
         --+nvl(ppru.eqpmt_act_effort_to_date,0)
         --+pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
           --             ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
             --           ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
               --         ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                 --        +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING'))) Variance_At_Completion_Effort
   ,ppru.earned_value -(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,nvl(ppru.oth_act_cost_to_date_pc,0)
          +nvl(ppru.ppl_act_cost_to_date_pc,0)
          +nvl(ppru.eqpmt_act_cost_to_date_pc,0) Actual_Cost
   ,null --pfxat.prj_base_brdn_cost
   ,null --nvl(ppru.oth_act_cost_to_date_pc,0)
        --+nvl(ppru.ppl_act_cost_to_date_pc,0)
        --+nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        --+pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
          --                               ,ppru.ppl_etc_cost_pc
            --                             ,ppru.eqpmt_etc_cost_pc
              --                           ,ppru.oth_etc_cost_pc
                --         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                  --              ,ppru.subprj_oth_etc_cost_pc,null
                    --    ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                      --           +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                        -- +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) Estimate_At_Completion_Cost
   ,NVL(ppru.earned_value,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),2) ETC_Work_Quantity
   ,null --pa_currency.round_trans_currency_amt((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),2) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,null Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,null Earned_Value_Schedule_Variance
   ,null --((nvl(pfxat.prj_base_brdn_cost,0))
      -- -(nvl(ppru.oth_act_cost_to_date_pc,0)
        --+nvl(ppru.ppl_act_cost_to_date_pc,0)
        --+nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    --+pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
      --                                   ,ppru.ppl_etc_cost_pc
        --                                 ,ppru.eqpmt_etc_cost_pc
          --                               ,ppru.oth_etc_cost_pc
            --           ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
              --                  ,ppru.subprj_oth_etc_cost_pc,null
                --        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                  --               +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                    --     +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')))) Variance_At_Completion_Cost
   ,null --round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    --+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    --+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)
    --+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)
    --+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
   ,null Budgeted_Cost_Of_Work_Sch
   ,null Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
         0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
         0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
    -- Bug Fix 5150944. NAMBURI
    --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,DECODE(ppa.structure_sharing_code,'SPLIT_MAPPING',PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code)) Mapped_Financial_Task
   ,null --PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,pt.gen_etc_source_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,null --pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
           --                              ,ppru.ppl_etc_cost_pc
             --                            ,ppru.eqpmt_etc_cost_pc
               --                          ,ppru.oth_etc_cost_pc
                 --        ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                   --             ,ppru.subprj_oth_etc_cost_pc,null
                     --   ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                       --          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         --+nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), decode(ppwa.wp_enable_version_flag,'Y','PUBLISH','WORKING')) ETC_Cost
   ,ppru.PROGRESS_ROLLUP_ID
FROM pa_proj_elem_ver_structure ppvs
    --,ra_addresses_all addr
     ,HZ_CUST_ACCT_SITES_ALL S
     ,HZ_PARTY_SITES PS
     ,HZ_LOCATIONS addr
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,pa_work_types_tl pwt
    ,pa_task_types tt
    ,pa_project_statuses pps3
    ,pa_page_layouts ppl
    ,pa_progress_rollup ppru
    ----,pa_percent_completes ppc
    ,pa_project_statuses pps
    ,pa_project_statuses pps5
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,pa_proj_workplan_attr ppwa
    ,pa_proj_element_versions ppev6
    ,pa_proj_progress_attr pppa
    ,pa_proj_element_versions ppv2
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pa_proj_elements ppeph
    ,pa_proj_element_versions ppevph
    --,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND ppe.object_type = 'PA_TASKS'
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id (+)
 AND pwt.language (+) = userenv('lang')
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.status_code = pps3.PROJECT_STATUS_CODE (+)
 AND pps3.STATUS_TYPE (+) = 'TASK'
 --AND pt.address_id = addr.address_id (+)
      AND pt.ADDRESS_ID = S.CUST_ACCT_SITE_ID(+)
     AND PS.PARTY_SITE_ID(+) = S.PARTY_SITE_ID
     AND addr.LOCATION_ID(+) = PS.LOCATION_ID
 AND ppe.task_progress_entry_page_id = ppl.page_id (+)
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppru.current_flag (+) = 'Y'
 AND ppru.structure_version_id(+) IS NULL
 AND NVL(ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code) = pps.PROJECT_STATUS_CODE(+)
 ----AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ----AND ppc.object_id (+) = ppru.object_id
 ----AND ppc.date_computed (+) = ppru.as_of_date
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND ppe.project_id <> 0
 AND ppv.parent_structure_version_id = ppev6.element_version_id (+)
 AND ppev6.proj_element_id = ppwa.proj_element_id (+)
 AND ppev6.project_id = pppa.project_id (+)
 AND 'PA_STRUCTURES' = pppa.object_type (+)
 AND ppev6.proj_element_id = pppa.object_id (+)
 AND ppwa.current_phase_version_id = ppevph.element_version_id (+)
 AND ppevph.proj_element_id = ppeph.proj_element_id (+)
 --AND pfxat.project_id (+)= ppv.project_id
 --AND pfxat.project_element_id (+)=ppv.proj_element_id
 --AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 --AND pfxat.calendar_type(+) = 'A'
 --AND pfxat.plan_version_id (+) > 0
 --AND pfxat.txn_currency_code(+) is null
 AND pppa.structure_type(+) = 'WORKPLAN'
 AND ppa.project_id= p_project_id
 AND ppv.parent_structure_version_id = p_structure_version_id
 AND ppv.element_version_id=p_task_version_id
 ----and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4219811.
 ----and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4219811.
 ----and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4216980.
 ;

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_PUBLISHED_RECORD',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_PUBLISHED_RECORD',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END INSERT_PUBLISHED_RECORD;


procedure INSERT_WORKING_RECORD
(
    p_api_version           IN      NUMBER      := 1.0,
    p_init_msg_list         IN      VARCHAR2    := FND_API.G_TRUE,
    p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
    p_validate_only         IN      VARCHAR2    := FND_API.G_TRUE,
    p_debug_mode            IN      VARCHAR2    := 'N',
    p_project_id            IN      NUMBER,
      p_structure_version_id        IN      NUMBER,
    p_task_version_id             IN      NUMBER,
        p_parent_project_id                 IN              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    x_return_status         OUT   NOCOPY   VARCHAR2,
    x_msg_count             OUT   NOCOPY   NUMBER,
    x_msg_data              OUT   NOCOPY   VARCHAR2
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'INSERT_WORKING_RECORD'   ;
   l_api_version                   CONSTANT NUMBER      := 1.0                            ;
   l_return_status                 VARCHAR2(1)                                       ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID                   ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID                  ;
   g1_debug_mode            VARCHAR2(1)                                    ;

  -- Bug Fix 5609629.
  -- Caching the wp_version_enable_flag in a local variable in order to avoid the function call
  -- during the insert statements. This will avoid the multiple executions of the same select.
  -- The project id is passed as a parameter to the pa_workplan_attr_utils.check_wp_versioning_enabled
  -- As the project id is not going to change during the insert statement records we can safely cache
  -- the value in a local variable and use that during the insert statment.

  l_versioning_enabled_flag pa_proj_workplan_attr.wp_enable_version_flag%TYPE;

  -- End of Bug Fix 5609629

BEGIN
    g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORD', x_Msg => 'ENTERED', x_Log_Level=> 3);
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;


    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_WORKING_RECORD', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug Fix 5609629
    -- Caching the versioning_enabled_flag attribute value locally.
    l_versioning_enabled_flag := pa_workplan_attr_utils.check_wp_versioning_enabled(p_project_id);
    -- End of Bug Fix 5609629


INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
)
SELECT
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppa.project_id
   ,ppv.display_sequence
   ,ppvsch.milestone_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.milestone_flag, 'N' ))
   ,ppvsch.critical_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', NVL( ppvsch.critical_flag, 'N' ))
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type, 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code)
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_PRIORITY_CODE' ,ppe.priority_code)
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(NULL)
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,ppe.pm_source_code
   ,ppe.pm_source_reference
   ,PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO', PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_start_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   -- ,PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
                                        -- Fix for Bug # 4447949.
   , decode(ppv.object_type, 'PA_STRUCTURES', null, (trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)))
                                        -- Fix for Bug # 4447949.
   ,papf.work_telephone
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
   ,pt.chargeable_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
   ,pt.billable_flag
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,null --PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,ppvsch.last_update_date
   ,to_date(NULL)
   ,ppa.BASELINE_AS_OF_DATE
   ,ppru.LAST_UPDATE_DATE
   ,ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,trunc(sysdate) - trunc(ppvsch.actual_finish_date)
   ,decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,ppe.CREATION_DATE
   ,PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,pps3.PROJECT_STATUS_NAME
   ,ppe5.phase_code
   ,pps5.project_status_name
   ,null --NVL(pfxat.labor_hours,0) + NVL(pfxat.equipment_hours,0)
   ,por.WEIGHTING_PERCENTAGE
   ,ppvsch.duration
   ,pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
   ,pt.address_id
   ,addr.address1
   ,addr.address2
   ,addr.address3
   ,addr.address4|| decode(addr.address4,null,null,', ')|| addr.city||', '||nvl(addr.state,addr.province)||', ' ||addr.county
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
   ,decode(pppa.PERCENT_COMP_ENABLE_FLAG, 'Y', tt.PERCENT_COMP_ENABLE_FLAG, 'N')
   ,decode(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', tt.REMAIN_EFFORT_ENABLE_FLAG, 'N')
   ,ppe.task_progress_entry_page_id
   ,ppl.page_name
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   ,null --PA_PROGRESS_UTILS.derive_etc_values((NVL(pfxat.labor_hours,0)+NVL(pfxat.equipment_hours,0))
           --                         ,ppru.ppl_act_effort_to_date
             --                       ,ppru.eqpmt_act_effort_to_date
               --                     ,null,null,null,null,null) estimated_remaining_effort
   -- ,PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
                                        -- Fix for Bug # 4447949.
   , decode(ppvs.status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N') -- Fix for Bug # 4447949.
   ,ppru.CUMULATIVE_WORK_QUANTITY
   -- Bug Fix 5609629
   -- Replaced the following function call with local variable.
   -- pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   , l_versioning_enabled_flag
   -- End of Bug Fix 5609629
   ,ppe.phase_version_id
   ,ppe5.name
   ,ppe5.element_number
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
   ,ppwa.lifecycle_version_id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,ppeph.name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,null --NVL(pfxat.equipment_hours,0)
   ,null --pfxat.prj_raw_cost
   ,null --pfxat.prj_brdn_cost
   ,null --NVL(pfxat.prj_brdn_cost,0)
   ,nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0) Actual_Effort
   ,NVL(ppru.eqpmt_act_effort_to_date,0)
   ,null --PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,null --PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
           --                             (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                --       ) percent_Spent_Effort
   ,null --PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
           --                             +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
             --                           nvl(pfxat.prj_brdn_cost,0)
                --       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                     ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,DECODE(PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id),'Y','N','N','Y')
                                    Lowest_Task -- Fix for Bug # 4490532.
   -- , 'N') Lowest_Task -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,null --NVL(pfxat.base_equip_hours,0) + NVL(pfxat.base_labor_hours,0) Baseline_effort
   ,null --pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
           --             ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
             --           ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
               --         ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                 --        +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING') ETC_EFFORT
   ,null --(nvl(ppru.ppl_act_effort_to_date,0)
        --+nvl(ppru.eqpmt_act_effort_to_date,0)
        --+pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
          --              ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
            --            ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
              --          ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                --         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING')) Estimate_At_Completion_Effort
   ,null --((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -- -(nvl(ppru.ppl_act_effort_to_date,0)
         --+nvl(ppru.eqpmt_act_effort_to_date,0)
         --+pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
           --             ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
             --           ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
               --         ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                 --        +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
          +nvl(ppru.ppl_act_cost_to_date_pc,0)
          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)) Actual_Cost
   ,null --pfxat.prj_base_brdn_cost
   ,null --(nvl(ppru.oth_act_cost_to_date_pc,0)
        --+nvl(ppru.ppl_act_cost_to_date_pc,0)
        --+nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        --+pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
          --                               ,ppru.ppl_etc_cost_pc
            --                             ,ppru.eqpmt_etc_cost_pc
              --                           ,ppru.oth_etc_cost_pc
                --         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                  --              ,ppru.subprj_oth_etc_cost_pc,null
                    --    ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                      --           +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                        -- +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING')) Estimate_At_Completion_Cost
   ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,null --pa_currency.round_trans_currency_amt((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
   ,null Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,null Earned_Value_Schedule_Variance
   ,null --((nvl(pfxat.prj_base_brdn_cost,0))
      -- -(nvl(ppru.oth_act_cost_to_date_pc,0)
        --+nvl(ppru.ppl_act_cost_to_date_pc,0)
        --+nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    --+pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
      --                                   ,ppru.ppl_etc_cost_pc
        --                                 ,ppru.eqpmt_etc_cost_pc
          --                               ,ppru.oth_etc_cost_pc
            --           ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
              --                  ,ppru.subprj_oth_etc_cost_pc,null
                --        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                  --               +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                    --     +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING'))) Variance_At_Completion_Cost
   ,null --round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    --+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    --+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    --+nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    --+nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    --+nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
   ,null  Budgeted_Cost_Of_Work_Sch
   ,null  Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
 ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
       0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
       0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
    -- Bug Fix 5150944. NAMBURI
    --   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,DECODE(ppa.structure_sharing_code,'SPLIT_MAPPING',PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code)) Mapped_Financial_Task
   ,to_char(null)--PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,pt.gen_etc_source_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,null --pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
           --                              ,ppru.ppl_etc_cost_pc
             --                            ,ppru.eqpmt_etc_cost_pc
               --                          ,ppru.oth_etc_cost_pc
                 --        ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                   --             ,ppru.subprj_oth_etc_cost_pc,null
                     --   ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                       --          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         --+nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)), 'WORKING') ETC_Cost
   ,ppru.PROGRESS_ROLLUP_ID
FROM pa_proj_elem_ver_structure ppvs
    --,ra_addresses_all addr
     ,HZ_CUST_ACCT_SITES_ALL S
     ,HZ_PARTY_SITES PS
     ,HZ_LOCATIONS addr
    ,pa_proj_elem_ver_schedule ppvsch
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,pa_work_types_tl pwt
    ,pa_task_types tt
    ,pa_project_statuses pps3
    ,pa_page_layouts ppl
    ,pa_progress_rollup ppru
    ----,pa_percent_completes ppc
    ,pa_project_statuses pps
    ,pa_project_statuses pps5
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,pa_proj_workplan_attr ppwa
    ,pa_proj_element_versions ppev6
    ,pa_proj_progress_attr pppa
    ,pa_proj_element_versions ppv2
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pa_proj_elements ppeph
    ,pa_proj_element_versions ppevph
    --,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code <> 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND ppe.object_type = 'PA_TASKS'
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id (+)
 AND pwt.language (+) = userenv('lang')
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.status_code = pps3.PROJECT_STATUS_CODE (+)
 AND pps3.STATUS_TYPE (+) = 'TASK'
 --AND pt.address_id = addr.address_id (+)
      AND pt.ADDRESS_ID = S.CUST_ACCT_SITE_ID(+)
     AND PS.PARTY_SITE_ID(+) = S.PARTY_SITE_ID
     AND addr.LOCATION_ID(+) = PS.LOCATION_ID
 AND ppe.task_progress_entry_page_id = ppl.page_id (+)
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppv.parent_structure_version_id = ppru.structure_version_id (+)
 AND NVL(ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+) = ppru.object_id
 ---AND ppc.date_computed (+) = ppru.as_of_date
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND ppe.project_id <> 0
 AND ppv.parent_structure_version_id = ppev6.element_version_id (+)
 AND ppev6.proj_element_id = ppwa.proj_element_id (+)
 AND ppev6.project_id = pppa.project_id (+)
 AND 'PA_STRUCTURES' = pppa.object_type (+)
 AND ppev6.proj_element_id = pppa.object_id (+)
 AND ppwa.current_phase_version_id = ppevph.element_version_id (+)
 AND ppevph.proj_element_id = ppeph.proj_element_id (+)
 --AND pfxat.project_id (+)= ppv.project_id
 --AND pfxat.project_element_id (+)=ppv.proj_element_id
 --AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 --AND pfxat.calendar_type(+) = 'A'
 --AND pfxat.plan_version_id (+)> 0
 --AND pfxat.txn_currency_code(+) is null
 AND pppa.structure_type(+) = 'WORKPLAN'
 AND ppa.project_id = p_project_id
 AND ppv.parent_structure_version_id = p_structure_version_id
 AND ppv.element_version_id = p_task_version_id
 ---and ppc.current_flag (+) = 'Y' -- Fix for Bug # 4627329.
 ---and ppc.published_flag (+) = 'Y' -- Fix for Bug # 4627329.
 ---and ppc.structure_type (+) = ppru.structure_type -- Fix for Bug # 4627329.
 ;

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_WORKING_RECORD',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_WORKING_RECORD',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END INSERT_WORKING_RECORD;

procedure INSERT_UPD_WORKING_RECORDS
(
        p_api_version                   IN              NUMBER          := 1.0,
        p_init_msg_list                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_commit                        IN              VARCHAR2        := FND_API.G_FALSE,
        p_validate_only                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_debug_mode                    IN              VARCHAR2        := 'N',
        p_project_id                    IN              NUMBER,
        p_structure_version_id          IN              NUMBER,
        p_parent_project_id                 IN              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        p_wbs_display_depth             IN              NUMBER   := -1, -- Bug # 4875311.
        p_task_version_id               IN              NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, -- Bug # 4875311.
        x_return_status                 OUT        NOCOPY      VARCHAR2,
        x_msg_count                     OUT        NOCOPY      NUMBER,
        x_msg_data                      OUT        NOCOPY      VARCHAR2
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'INSERT_UPD_WORKING_RECORDS'   ;
   l_api_version                   CONSTANT NUMBER      := 1.0                  ;
   l_return_status                 VARCHAR2(1)                                  ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID         ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID        ;
   g1_debug_mode            VARCHAR2(1)                                    ;

-- Bug Fix 5611760. Performance changes.
-- obtaining the task_weight_basis_code from the pa_proj_progress_attr table
-- as it is not available in the pa_progress_rollup table thus causing the
-- get_bcws function to get the same for every call.

   l_task_weight_basis_code        pa_proj_progress_attr.task_weight_basis_code%TYPE;
   l_structure_type pa_proj_progress_attr.structure_type%TYPE := 'WORKPLAN';

   CURSOR c_task_weight_basis_code IS
   SELECT task_weight_basis_code
     FROM pa_proj_progress_attr pppa
    WHERE pppa.project_id = p_project_id
      AND pppa.structure_type = l_structure_type;

-- End of Bug fix 5611760.

-- Bug Fix 5611634

l_check_edit_task_ok VARCHAR2(1);

-- End of Fix for bug 5611634.


BEGIN
        g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_UPD_WORKING_RECORDS', x_Msg => 'ENTERED', x_Log_Level=> 3);
        END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
                FND_MSG_PUB.initialize;
        END IF;


        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_UPD_WORKING_RECORDS', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
        END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Bug # 4875311.

-- ************************************************************************************************************************
-- if only p_structure_version_id is passed in, populate all task records for the given structure version.
-- ************************************************************************************************************************

-- Bug Fix 5611760.
-- Storing the task_weight_basis_code in a local variable and use that in the get_bcws call as the same
-- is not available in the pa_progress_rollup table and that is causing the same a performance issue as
-- the functiona get_bcws is getting the value for every call.

   OPEN c_task_weight_basis_code;
   FETCH c_task_weight_basis_code INTO l_task_weight_basis_code;
   CLOSE c_task_weight_basis_code;

-- End of Fix 5611760.

-- Bug Fix 5611634
l_check_edit_task_ok  := PA_PROJ_ELEMENTS_UTILS.Check_Edit_Task_Ok(p_project_id, p_structure_version_id, PA_PROJ_ELEMENTS_UTILS.GetGlobalStrucVerId);
-- End of Fix for bug 5611634.


if ((p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and (p_wbs_display_depth = -1)) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
----------------------------
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
-------------------------
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
----------------------
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
-------------------------------
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
---------------------------
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
----------------------------
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
-----------------------------
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
-------------------------
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
-------------------------
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
-----------------------------
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, EDIT_FLAG
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
 --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/
/*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppe.project_id
   ,ppv.display_sequence
   ,ppvsch.milestone_flag
   ,fl1.meaning
   ,ppvsch.critical_flag
   ,fl2.meaning
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type, 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null    ---ppc.PROGRESS_COMMENT
   ,null    ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
------------------------------- 1
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,fl3.meaning
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(null)  -- Report Version ID
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
---------------------------------------------
   ,null -- not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,null -- not populating as not needed in VO ppe.pm_source_code
   ,null -- -- not populating as not needed in VO ppe.pm_source_reference
   ,null --  not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
   ,null
/*    not populating as not needed in VO
PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',
PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
   ,papf.work_telephone
   ,lu1.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
   ,fl4.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
   ,pt.chargeable_flag
   ,fl5.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
   ,pt.billable_flag
   ,fl6.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,to_date(null) -- not needed in VO ppvsch.last_update_date
   ,to_date(NULL) -- not needed in VO
   ,to_date(NULL) -- not needed in VO ppa.BASELINE_AS_OF_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,null -- not needed in VO trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,null-- not needed in VO trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_finish_date)
----------------------------------------------------------
   ,null -- not needed in VO decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,null -- not needed in VO ppe.CREATION_DATE
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,null -- Populating Task Status Name as NULL
   ,ppe.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,null -- not needed in VO ppvsch.duration
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
--------------------------------------------------------------------------------
   ,pt.address_id
   ,null--addr.address1
   ,null--addr.address2
   ,null--addr.address3
   ,null
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
  , tt.PERCENT_COMP_ENABLE_FLAG
  , tt.REMAIN_EFFORT_ENABLE_FLAG
   ,to_number(null)  -- not needed in VO TASK_PROGRESS_ENTRY_PAGE_ID
   ,null -- not needed in VO page_name
--------------------------------------------------------------
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                                                                 -- Fix for Bug # 4319171.
   ,null -- not needed in VO PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
   ,ppru.CUMULATIVE_WORK_QUANTITY
   ,null -- not needed in VO pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   ,ppe.phase_version_id
   ,pps5.project_status_name
   ,null --Phase Short Name
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
--------------------------------------------------------------------
   ,to_number(null) -- lifecycle version id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,null --current phase name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , ppru.subprj_ppl_act_effort, ppru.subprj_eqpmt_act_effort, null)
                                Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   -- Begin Bug # 4546322
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                                        , ppru.eqpmt_act_effort_to_date
                                                                        , null
                                                                        , null
                                                                        , null
                                                                        , null)
                                             , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours
                                                                                                      , pfxat.equipment_hours
                                                                                                      , null)
                                                                          , ppru.estimated_remaining_effort
                                                                          , ppru.eqpmt_etc_effort
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , pa_progress_utils.calc_act
                                            (ppru.ppl_act_effort_to_date
                                                                                 , ppru.eqpmt_act_effort_to_date
                                                                                 , null
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                                        , ppru.eqpmt_act_cost_to_date_pc
                                                                        , ppru.oth_act_cost_to_date_pc
                                                                        , null
                                                                        , null
                                                                        , null)
                                             , pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                                                                          , ppru.ppl_etc_cost_pc
                                                                          , ppru.eqpmt_etc_cost_pc
                                                                          , ppru.oth_etc_cost_pc
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , pa_progress_utils.calc_act
                                            (ppru.ppl_act_cost_to_date_pc
                                                                                 , ppru.eqpmt_act_cost_to_date_pc
                                                                                 , ppru.oth_act_cost_to_date_pc
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Cost
   -- End Bug # 4546322.
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
-----------------------------------------------------------------------------------
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   ,null --Lowest task
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
----------------------------------------------------------------------------------
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING')) Estimate_At_Completion_Cost
 --------------------------------------------------------------------------------------
 ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
     ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   -- Bug Fix 56117760
                                   -- ppru.task_wt_basis_code,
                                   l_task_weight_basis_code,
                                   -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                        ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                           ppru.object_id,
                                           ppe.proj_element_id,
                                           ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   -- Bug Fix 56117760
                                   -- ppru.task_wt_basis_code,
                                   l_task_weight_basis_code,
                                   -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                        ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING'))) Variance_At_Completion_Cost
---------------------------------------------------------------
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
*/
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                           ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                      -- Bug Fix 56117760
                      -- ppru.task_wt_basis_code,
                      l_task_weight_basis_code,
                      -- End of Bug Fix 56117760
                           ppe.baseline_start_date,
                           ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                               ppe.baseline_start_date,
                                            ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,
                                               nvl(pa_progress_utils.get_bcws(ppa.project_id,ppru.object_id,
                                ppe.proj_element_id,ppru.as_of_date,
                                ppv.parent_structure_version_id,
                                   -- Bug Fix 56117760
                                   -- ppru.task_wt_basis_code,
                                   l_task_weight_basis_code,
                                   -- End of Bug Fix 56117760
                                                                ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
   ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
      0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
      0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
---------------------------------------------------------------------
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,null -- not used in VO PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,null -- not used in VO pt.gen_etc_source_code
   ,null -- not used in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   -- Bug Fix 5611634.
   --,PA_PROJ_ELEMENTS_UTILS.Check_Edit_Task_Ok(ppe.project_id, ppv.parent_structure_version_id, PA_PROJ_ELEMENTS_UTILS.GetGlobalStrucVerId)
   ,l_check_edit_task_ok
   -- End of Bug Fix 5611634.
 ,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    ,pa_proj_elem_ver_schedule ppvsch
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,pa_lookups fl3
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_element_versions ppv2
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,fnd_lookups fl1
    ,fnd_lookups fl2
    ,fnd_lookups fl4
    ,fnd_lookups fl5
    ,fnd_lookups fl6
    ,pa_lookups lu1
    ,pa_work_types_tl pwt
    ,pa_progress_rollup ppru
    ,pa_project_statuses pps
    ----,pa_percent_completes ppc
    ,pa_project_statuses pps5
    ,pa_task_types tt
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppe.project_id = ppv.project_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code <> 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.priority_code = fl3.lookup_code(+)
 AND fl3.lookup_type(+) = 'PA_TASK_PRIORITY_CODE'
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id(+)
 AND pwt.language (+) = userenv('lang')
 AND NVL( ppvsch.milestone_flag, 'N' ) = fl1.lookup_code
 AND fl1.lookup_type = 'YES_NO'
 AND NVL( ppvsch.critical_flag, 'N' ) = fl2.lookup_code
 AND fl2.lookup_type = 'YES_NO'
 AND pt.chargeable_flag = fl4.lookup_code(+)
 AND fl4.lookup_type(+) = 'YES_NO'
 AND pt.billable_flag = fl5.lookup_code(+)
 AND fl5.lookup_type(+) = 'YES_NO'
 AND pt.receive_project_invoice_flag = fl6.lookup_code(+)
 AND fl6.lookup_type(+) = 'YES_NO'
 AND pt.service_type_code = lu1.lookup_code(+)
 AND lu1.lookup_type (+) = 'SERVICE TYPE'
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppv.parent_structure_version_id = ppru.structure_version_id (+)
 AND NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code ) = pps.PROJECT_STATUS_CODE(+)
 ----AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ----AND ppc.object_id (+)= ppru.object_id
 ----AND ppc.date_computed (+)= ppru.as_of_date
 ----AND ppc.structure_type (+)=ppru.structure_type
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.project_id <> 0
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0 AND pfxat.txn_currency_code(+) is null
 AND ppa.project_id = p_project_id
 and ppv.parent_structure_version_id = p_structure_version_id;

-- ************************************************************************************************************************
-- if p_structure_version_id and p_wbs_display_depth are passed in, populate all task records for the structure version until the depth.
-- ************************************************************************************************************************

elsif ((p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and ( p_wbs_display_depth <> -1)) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
----------------------------
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
-------------------------
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
----------------------
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
-------------------------------
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
---------------------------
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
----------------------------
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
-----------------------------
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
-------------------------
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
-------------------------
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
-----------------------------
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, EDIT_FLAG
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
 --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/
 /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppe.project_id
   ,ppv.display_sequence
   ,ppvsch.milestone_flag
   ,fl1.meaning
   ,ppvsch.critical_flag
   ,fl2.meaning
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type, 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null    ---ppc.PROGRESS_COMMENT
   ,null    ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
------------------------------- 1
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,fl3.meaning
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(null)  -- Report Version ID
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
---------------------------------------------
   ,null -- not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,null -- not populating as not needed in VO ppe.pm_source_code
   ,null -- -- not populating as not needed in VO ppe.pm_source_reference
   ,null --  not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
   ,null
/*    not populating as not needed in VO
PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',
PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
   ,papf.work_telephone
   ,lu1.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
   ,fl4.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
   ,pt.chargeable_flag
   ,fl5.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
   ,pt.billable_flag
   ,fl6.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,to_date(null) -- not needed in VO ppvsch.last_update_date
   ,to_date(NULL) -- not needed in VO
   ,to_date(NULL) -- not needed in VO ppa.BASELINE_AS_OF_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,null -- not needed in VO trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,null-- not needed in VO trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_finish_date)
----------------------------------------------------------
   ,null -- not needed in VO decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,null -- not needed in VO ppe.CREATION_DATE
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,null -- Populating Task Status Name as NULL
   ,ppe.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,null -- not needed in VO ppvsch.duration
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
--------------------------------------------------------------------------------
   ,pt.address_id
   ,null--addr.address1
   ,null--addr.address2
   ,null--addr.address3
   ,null
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
  , tt.PERCENT_COMP_ENABLE_FLAG
  , tt.REMAIN_EFFORT_ENABLE_FLAG
   ,to_number(null)  -- not needed in VO TASK_PROGRESS_ENTRY_PAGE_ID
   ,null -- not needed in VO page_name
--------------------------------------------------------------
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                                                                 -- Fix for Bug # 4319171.
   ,null -- not needed in VO PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
   ,ppru.CUMULATIVE_WORK_QUANTITY
   ,null -- not needed in VO pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   ,ppe.phase_version_id
   ,pps5.project_status_name
   ,null --Phase Short Name
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
--------------------------------------------------------------------
   ,to_number(null) -- lifecycle version id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,null --current phase name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , ppru.subprj_ppl_act_effort, ppru.subprj_eqpmt_act_effort, null)
                                Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   -- Begin Bug # 4546322
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                                        , ppru.eqpmt_act_effort_to_date
                                                                        , null
                                                                        , null
                                                                        , null
                                                                        , null)
                                             , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours
                                                                                                      , pfxat.equipment_hours
                                                                                                      , null)
                                                                          , ppru.estimated_remaining_effort
                                                                          , ppru.eqpmt_etc_effort
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , pa_progress_utils.calc_act
                                            (ppru.ppl_act_effort_to_date
                                                                                 , ppru.eqpmt_act_effort_to_date
                                                                                 , null
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                                        , ppru.eqpmt_act_cost_to_date_pc
                                                                        , ppru.oth_act_cost_to_date_pc
                                                                        , null
                                                                        , null
                                                                        , null)
                                             , pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                                                                          , ppru.ppl_etc_cost_pc
                                                                          , ppru.eqpmt_etc_cost_pc
                                                                          , ppru.oth_etc_cost_pc
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , pa_progress_utils.calc_act
                                            (ppru.ppl_act_cost_to_date_pc
                                                                                 , ppru.eqpmt_act_cost_to_date_pc
                                                                                 , ppru.oth_act_cost_to_date_pc
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Cost
   -- End Bug # 4546322.
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
-----------------------------------------------------------------------------------
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   ,null --Lowest task
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
----------------------------------------------------------------------------------
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING')) Estimate_At_Completion_Cost
 --------------------------------------------------------------------------------------
 ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
     ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   -- Bug Fix 56117760
                                   -- ppru.task_wt_basis_code,
                                   l_task_weight_basis_code,
                                   -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                        ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                           ppru.object_id,
                                           ppe.proj_element_id,
                                           ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                   -- Bug Fix 56117760
                                   -- ppru.task_wt_basis_code,
                                   l_task_weight_basis_code,
                                   -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                        ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING'))) Variance_At_Completion_Cost
---------------------------------------------------------------
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
*/
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                           ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                           ppe.baseline_start_date,
                           ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                               ppe.baseline_start_date,
                                            ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,
                                               nvl(pa_progress_utils.get_bcws(ppa.project_id,ppru.object_id,
                                ppe.proj_element_id,ppru.as_of_date,
                                ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                                    ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
   ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
      0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
      0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
---------------------------------------------------------------------
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,null -- not used in VO PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,null -- not used in VO pt.gen_etc_source_code
   ,null -- not used in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   -- Bug Fix 5611634.
   --,PA_PROJ_ELEMENTS_UTILS.Check_Edit_Task_Ok(ppe.project_id, ppv.parent_structure_version_id, PA_PROJ_ELEMENTS_UTILS.GetGlobalStrucVerId)
   ,l_check_edit_task_ok
   -- End of Bug Fix 5611634.
,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    ,pa_proj_elem_ver_schedule ppvsch
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,pa_lookups fl3
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_element_versions ppv2
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,fnd_lookups fl1
    ,fnd_lookups fl2
    ,fnd_lookups fl4
    ,fnd_lookups fl5
    ,fnd_lookups fl6
    ,pa_lookups lu1
    ,pa_work_types_tl pwt
    ,pa_progress_rollup ppru
    ,pa_project_statuses pps
    ----,pa_percent_completes ppc
    ,pa_project_statuses pps5
    ,pa_task_types tt
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppe.project_id = ppv.project_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code <> 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.priority_code = fl3.lookup_code(+)
 AND fl3.lookup_type(+) = 'PA_TASK_PRIORITY_CODE'
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id(+)
 AND pwt.language (+) = userenv('lang')
 AND NVL( ppvsch.milestone_flag, 'N' ) = fl1.lookup_code
 AND fl1.lookup_type = 'YES_NO'
 AND NVL( ppvsch.critical_flag, 'N' ) = fl2.lookup_code
 AND fl2.lookup_type = 'YES_NO'
 AND pt.chargeable_flag = fl4.lookup_code(+)
 AND fl4.lookup_type(+) = 'YES_NO'
 AND pt.billable_flag = fl5.lookup_code(+)
 AND fl5.lookup_type(+) = 'YES_NO'
 AND pt.receive_project_invoice_flag = fl6.lookup_code(+)
 AND fl6.lookup_type(+) = 'YES_NO'
 AND pt.service_type_code = lu1.lookup_code(+)
 AND lu1.lookup_type (+) = 'SERVICE TYPE'
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppv.parent_structure_version_id = ppru.structure_version_id (+)
 AND NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code ) = pps.PROJECT_STATUS_CODE(+)
 ----AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ----AND ppc.object_id (+)= ppru.object_id
 ----AND ppc.date_computed (+)= ppru.as_of_date
 ----AND ppc.structure_type (+)=ppru.structure_type
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.project_id <> 0
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0 AND pfxat.txn_currency_code(+) is null
 AND ppa.project_id = p_project_id
 and ppv.parent_structure_version_id = p_structure_version_id
 and ppv.wbs_level <= p_wbs_display_depth;

-- ************************************************************************************************************************
-- if p_task_version_id is passed in, populate all the immediate child task records for the given task version.
-- ************************************************************************************************************************

elsif (p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
----------------------------
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
-------------------------
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
----------------------
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
-------------------------------
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
---------------------------
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
----------------------------
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
-----------------------------
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
-------------------------
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
-------------------------
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
-----------------------------
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, EDIT_FLAG
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
 --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/
 /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppe.project_id
   ,ppv.display_sequence
   ,ppvsch.milestone_flag
   ,fl1.meaning
   ,ppvsch.critical_flag
   ,fl2.meaning
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type, 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null    ---ppc.PROGRESS_COMMENT
   ,null    ---ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
------------------------------- 1
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,fl3.meaning
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(null)  -- Report Version ID
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
---------------------------------------------
   ,null -- not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,null -- not populating as not needed in VO ppe.pm_source_code
   ,null -- -- not populating as not needed in VO ppe.pm_source_reference
   ,null --  not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
   ,null
/*    not populating as not needed in VO
PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',
PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
   ,papf.work_telephone
   ,lu1.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
   ,fl4.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
   ,pt.chargeable_flag
   ,fl5.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
   ,pt.billable_flag
   ,fl6.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,to_date(null) -- not needed in VO ppvsch.last_update_date
   ,to_date(NULL) -- not needed in VO
   ,to_date(NULL) -- not needed in VO ppa.BASELINE_AS_OF_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,null -- not needed in VO trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,null-- not needed in VO trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_finish_date)
----------------------------------------------------------
   ,null -- not needed in VO decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,null -- not needed in VO ppe.CREATION_DATE
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,null -- Populating Task Status Name as NULL
   ,ppe.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,null -- not needed in VO ppvsch.duration
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
--------------------------------------------------------------------------------
   ,pt.address_id
   ,null--addr.address1
   ,null--addr.address2
   ,null--addr.address3
   ,null
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
  , tt.PERCENT_COMP_ENABLE_FLAG
  , tt.REMAIN_EFFORT_ENABLE_FLAG
   ,to_number(null)  -- not needed in VO TASK_PROGRESS_ENTRY_PAGE_ID
   ,null -- not needed in VO page_name
--------------------------------------------------------------
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                                                                 -- Fix for Bug # 4319171.
   ,null -- not needed in VO PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
   ,ppru.CUMULATIVE_WORK_QUANTITY
   ,null -- not needed in VO pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   ,ppe.phase_version_id
   ,pps5.project_status_name
   ,null --Phase Short Name
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
--------------------------------------------------------------------
   ,to_number(null) -- lifecycle version id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,null --current phase name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , ppru.subprj_ppl_act_effort, ppru.subprj_eqpmt_act_effort, null)
                                Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                       ) percent_Spent_Cost
   -- Begin Bug # 4546322
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                                        , ppru.eqpmt_act_effort_to_date
                                                                        , null
                                                                        , null
                                                                        , null
                                                                        , null)
                                             , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours
                                                                                                      , pfxat.equipment_hours
                                                                                                      , null)
                                                                          , ppru.estimated_remaining_effort
                                                                          , ppru.eqpmt_etc_effort
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , pa_progress_utils.calc_act
                                            (ppru.ppl_act_effort_to_date
                                                                                 , ppru.eqpmt_act_effort_to_date
                                                                                 , null
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value(pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                                        , ppru.eqpmt_act_cost_to_date_pc
                                                                        , ppru.oth_act_cost_to_date_pc
                                                                        , null
                                                                        , null
                                                                        , null)
                                             , pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                                                                          , ppru.ppl_etc_cost_pc
                                                                          , ppru.eqpmt_etc_cost_pc
                                                                          , ppru.oth_etc_cost_pc
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , null
                                                                          , pa_progress_utils.calc_act
                                            (ppru.ppl_act_cost_to_date_pc
                                                                                 , ppru.eqpmt_act_cost_to_date_pc
                                                                                 , ppru.oth_act_cost_to_date_pc
                                                                                 , null
                                                                                 , null
                                                                                 , null)))  Percent_Complete_Cost
   -- End Bug # 4546322.
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
-----------------------------------------------------------------------------------
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   ,null --Lowest task
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
----------------------------------------------------------------------------------
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'WORKING'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING')) Estimate_At_Completion_Cost
 --------------------------------------------------------------------------------------
 ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                             nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
     ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                   ppv.proj_element_id,
                                   ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                        ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                           ppru.object_id,
                                           ppe.proj_element_id,
                                           ppru.as_of_date,
                                   ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                        ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
    +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                ,ppru.subprj_oth_etc_cost_pc,null
                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                 +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'WORKING'))) Variance_At_Completion_Cost
---------------------------------------------------------------
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
    +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
    +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
    +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
*/
   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
   ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                           ppru.object_id,
                      ppe.proj_element_id,
                      ppru.as_of_date,
                      ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                           ppe.baseline_start_date,
                           ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                      ppe.proj_element_id,
                                      ppru.as_of_date,
                                      ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                               ppe.baseline_start_date,
                                            ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,
                                               nvl(pa_progress_utils.get_bcws(ppa.project_id,ppru.object_id,
                                ppe.proj_element_id,ppru.as_of_date,
                                ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                                    ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
   ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
      0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
      0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
---------------------------------------------------------------------
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,null -- not used in VO PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,null -- not used in VO pt.gen_etc_source_code
   ,null -- not used in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   -- Bug Fix 5611634.
   --,PA_PROJ_ELEMENTS_UTILS.Check_Edit_Task_Ok(ppe.project_id, ppv.parent_structure_version_id, PA_PROJ_ELEMENTS_UTILS.GetGlobalStrucVerId)
   ,l_check_edit_task_ok
   -- End of Bug Fix 5611634.
 ,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    ,pa_proj_elem_ver_schedule ppvsch
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,pa_lookups fl3
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_element_versions ppv2
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,fnd_lookups fl1
    ,fnd_lookups fl2
    ,fnd_lookups fl4
    ,fnd_lookups fl5
    ,fnd_lookups fl6
    ,pa_lookups lu1
    ,pa_work_types_tl pwt
    ,pa_progress_rollup ppru
    ,pa_project_statuses pps
    ----,pa_percent_completes ppc
    ,pa_project_statuses pps5
    ,pa_task_types tt
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppe.project_id = ppv.project_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code <> 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.priority_code = fl3.lookup_code(+)
 AND fl3.lookup_type(+) = 'PA_TASK_PRIORITY_CODE'
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id(+)
 AND pwt.language (+) = userenv('lang')
 AND NVL( ppvsch.milestone_flag, 'N' ) = fl1.lookup_code
 AND fl1.lookup_type = 'YES_NO'
 AND NVL( ppvsch.critical_flag, 'N' ) = fl2.lookup_code
 AND fl2.lookup_type = 'YES_NO'
 AND pt.chargeable_flag = fl4.lookup_code(+)
 AND fl4.lookup_type(+) = 'YES_NO'
 AND pt.billable_flag = fl5.lookup_code(+)
 AND fl5.lookup_type(+) = 'YES_NO'
 AND pt.receive_project_invoice_flag = fl6.lookup_code(+)
 AND fl6.lookup_type(+) = 'YES_NO'
 AND pt.service_type_code = lu1.lookup_code(+)
 AND lu1.lookup_type (+) = 'SERVICE TYPE'
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppv.parent_structure_version_id = ppru.structure_version_id (+)
 AND NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code ) = pps.PROJECT_STATUS_CODE(+)
 ----AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ----AND ppc.object_id (+)= ppru.object_id
 ----AND ppc.date_computed (+)= ppru.as_of_date
 ----AND ppc.structure_type (+)=ppru.structure_type
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.project_id <> 0
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0 AND pfxat.txn_currency_code(+) is null
 AND ppa.project_id = p_project_id
 and ppv.parent_structure_version_id = p_structure_version_id
 and por.object_id_from1 = p_task_version_id;

end if;

-- Bug # 4875311.

IF pa_fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id) <> 'Y' THEN

UPDATE pa_structures_tasks_tmp
set raw_cost = null,burdened_cost=null,planned_cost=null,Percent_Spent_Cost=null,Percent_Complete_Cost=null,
    Actual_Cost = null,Baseline_Cost=null,Estimate_At_Completion_Cost=null,
    Planned_Cost_Per_Unit=null,Actual_Cost_Per_Unit=null,Variance_At_Completion_Cost=null,
    ETC_Cost =null
    , PLANNED_BASELINE_COST_VAR = NULL  --Added for bug 5090355
where project_id = p_project_id
  and parent_structure_version_id=p_structure_version_id;

END IF;

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_UPD_WORKING_RECORDS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_UPD_WORKING_RECORDS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END INSERT_UPD_WORKING_RECORDS;

procedure INSERT_UPD_PUBLISHED_RECORDS
(
        p_api_version                   IN              NUMBER          := 1.0,
        p_init_msg_list                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_commit                        IN              VARCHAR2        := FND_API.G_FALSE,
        p_validate_only                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_debug_mode                    IN              VARCHAR2        := 'N',
        p_project_id                    IN              NUMBER,
        p_structure_version_id          IN              NUMBER,
        p_parent_project_id                 IN              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        p_wbs_display_depth             IN              NUMBER   := -1, -- Bug # 4875311.
        p_task_version_id               IN              NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, -- Bug # 4875311.
        x_return_status                 OUT       NOCOPY       VARCHAR2,
        x_msg_count                     OUT       NOCOPY       NUMBER,
        x_msg_data                      OUT       NOCOPY       VARCHAR2
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'INSERT_UPD_PUBLISHED_RECORDS'   ;
   l_api_version                   CONSTANT NUMBER      := 1.0                  ;
   l_return_status                 VARCHAR2(1)                                  ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID         ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID        ;
   g1_debug_mode            VARCHAR2(1)                                    ;

-- Bug Fix 5611760. Performance changes.
-- obtaining the task_weight_basis_code from the pa_proj_progress_attr table
-- as it is not available in the pa_progress_rollup table thus causing the
-- get_bcws function to get the same for every call.

   l_task_weight_basis_code        pa_proj_progress_attr.task_weight_basis_code%TYPE;
   l_structure_type pa_proj_progress_attr.structure_type%TYPE := 'WORKPLAN';

   CURSOR c_task_weight_basis_code IS
   SELECT task_weight_basis_code
     FROM pa_proj_progress_attr pppa
    WHERE pppa.project_id = p_project_id
      AND pppa.structure_type = l_structure_type;

  -- End of Bug Fix 5609629

-- Bug Fix 5611634

l_check_edit_task_ok VARCHAR2(1);

-- End of Fix for bug 5611634.


BEGIN
        g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id,l_login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_UPD_PUBLISHED_RECORDS', x_Msg => 'ENTERED', x_Log_Level=> 3);
        END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
                FND_MSG_PUB.initialize;
        END IF;


        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROJ_STRUCTURE_PUB.INSERT_UPD_PUBLISHED_RECORDS', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
        END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Bug # 4875311.

-- ************************************************************************************************************************
-- if only p_structure_version_id is passed in, populate all task records for the given structure version.
-- ************************************************************************************************************************

-- Bug Fix 5611760.
-- Storing the task_weight_basis_code in a local variable and use that in the get_bcws call as the same
-- is not available in the pa_progress_rollup table and that is causing the same a performance issue as
-- the functiona get_bcws is getting the value for every call.

   OPEN c_task_weight_basis_code;
   FETCH c_task_weight_basis_code INTO l_task_weight_basis_code;
   CLOSE c_task_weight_basis_code;

-- End of Fix 5611760.

-- Bug Fix 5611634
l_check_edit_task_ok  := PA_PROJ_ELEMENTS_UTILS.Check_Edit_Task_Ok(p_project_id, p_structure_version_id, PA_PROJ_ELEMENTS_UTILS.GetGlobalStrucVerId);
-- End of Fix for bug 5611634.


if ((p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and (p_wbs_display_depth = -1)) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
----------------------------
----------------------------
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
-------------------------
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
---------------------------
----------------------
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
-------------------------------
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
---------------------------
---------------------------
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
----------------------------
----------------------------
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
-----------------------------
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
-------------------------
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
-------------------------
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
-----------------------------
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, EDIT_FLAG
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
 --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/
 /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppe.project_id
   ,ppv.display_sequence
   ,ppvsch.milestone_flag
   ,fl1.meaning
   ,ppvsch.critical_flag
   ,fl2.meaning
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type, 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ----ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
------------------------------- 1
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,fl3.meaning
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(null)  -- Report Version ID
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
--------------------------------------------- 2
   ,null -- not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,null -- not populating as not needed in VO ppe.pm_source_code
   ,null -- -- not populating as not needed in VO ppe.pm_source_reference
   ,null --  not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
   ,null
/*    not populating as not needed in VO
PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',
PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
   ,papf.work_telephone
   ,lu1.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
   ,fl4.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
   ,pt.chargeable_flag
   ,fl5.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
   ,pt.billable_flag
   ,fl6.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,to_date(null) -- not needed in VO ppvsch.last_update_date
   ,to_date(NULL) -- not needed in VO
   ,to_date(NULL) -- not needed in VO ppa.BASELINE_AS_OF_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,null -- not needed in VO trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,null-- not needed in VO trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_finish_date)
---------------------------------------------- 3
   ,null -- not needed in VO decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,null -- not needed in VO ppe.CREATION_DATE
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,null -- Populating Task Status Name as NULL
   ,ppe.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,null -- not needed in VO ppvsch.duration
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
--------------------------------------------------------------------------------
   ,pt.address_id
   ,null--addr.address1
   ,null--addr.address2
   ,null--addr.address3
   ,null
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
  , tt.PERCENT_COMP_ENABLE_FLAG
  , tt.REMAIN_EFFORT_ENABLE_FLAG
   ,to_number(null)  -- not needed in VO TASK_PROGRESS_ENTRY_PAGE_ID
   ,null -- not needed in VO page_name
------------------------------------------------ 5
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                                                                 -- Fix for Bug # 4319171.
   ,null -- not needed in VO PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
   ,ppru.CUMULATIVE_WORK_QUANTITY
   ,null -- not needed in VO pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   ,ppe.phase_version_id
   ,pps5.project_status_name
   ,null --Phase Short Name
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
--------------------------------------------------------------------
   ,to_number(null) -- lifecycle version id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,null --current phase name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , ppru.subprj_ppl_act_effort, ppru.subprj_eqpmt_act_effort, null)
                                                                Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                                       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                                         ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
----------------------------------------------------------------- 7
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   ,null --Lowest task
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
----------------------------------------------------------------------------------
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'PUBLISH')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'PUBLISH'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                        ,ppru.subprj_oth_etc_cost_pc,null
                                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                         +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'PUBLISH')) Estimate_At_Completion_Cost
 --------------------------------------------------------------------------------------
 ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                 nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
     ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppv.proj_element_id,
                                                                   ppru.as_of_date,
                                                                   ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                           ppru.object_id,
                                           ppe.proj_element_id,
                                           ppru.as_of_date,
                                                                   ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                        ,ppru.subprj_oth_etc_cost_pc,null
                                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                         +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'PUBLISH'))) Variance_At_Completion_Cost
---------------------------------------------------------------

   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
        +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
 */  ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                           ppru.object_id,
                                          ppe.proj_element_id,
                                          ppru.as_of_date,
                                          ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                           ppe.baseline_start_date,
                           ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                                                          ppe.proj_element_id,
                                                                          ppru.as_of_date,
                                                                          ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                               ppe.baseline_start_date,
                                                        ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,
                                               nvl(pa_progress_utils.get_bcws(ppa.project_id,ppru.object_id,
                                                                ppe.proj_element_id,ppru.as_of_date,
                                                                ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                                                ppe.baseline_start_date,
                                                                ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
    ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
       0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
       0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
---------------------------------------------------------------------
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,null -- not used in VO PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,null -- not used in VO pt.gen_etc_source_code
   ,null -- not used in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   -- Bug Fix 5611634.
   --,PA_PROJ_ELEMENTS_UTILS.Check_Edit_Task_Ok(ppe.project_id, ppv.parent_structure_version_id, PA_PROJ_ELEMENTS_UTILS.GetGlobalStrucVerId)
   ,l_check_edit_task_ok
   -- End of Bug Fix 5611634.
 ,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))  PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    ,pa_proj_elem_ver_schedule ppvsch
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,pa_lookups fl3
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_element_versions ppv2
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,fnd_lookups fl1
    ,fnd_lookups fl2
    ,fnd_lookups fl4
    ,fnd_lookups fl5
    ,fnd_lookups fl6
    ,pa_lookups lu1
    ,pa_work_types_tl pwt
    ,pa_progress_rollup ppru
    ,pa_project_statuses pps
    ----,pa_percent_completes ppc
    ,pa_project_statuses pps5
    ,pa_task_types tt
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppe.project_id = ppv.project_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.priority_code = fl3.lookup_code(+)
 AND fl3.lookup_type(+) = 'PA_TASK_PRIORITY_CODE'
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id(+)
 AND pwt.language (+) = userenv('lang')
 AND NVL( ppvsch.milestone_flag, 'N' ) = fl1.lookup_code
 AND fl1.lookup_type = 'YES_NO'
 AND NVL( ppvsch.critical_flag, 'N' ) = fl2.lookup_code
 AND fl2.lookup_type = 'YES_NO'
 AND pt.chargeable_flag = fl4.lookup_code(+)
 AND fl4.lookup_type(+) = 'YES_NO'
 AND pt.billable_flag = fl5.lookup_code(+)
 AND fl5.lookup_type(+) = 'YES_NO'
 AND pt.receive_project_invoice_flag = fl6.lookup_code(+)
 AND fl6.lookup_type(+) = 'YES_NO'
 AND pt.service_type_code = lu1.lookup_code(+)
 AND lu1.lookup_type (+) = 'SERVICE TYPE'
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppru.structure_version_id is null
 AND NVL( ppru.current_flag (+), 'N' ) = 'Y'
 AND NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code ) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+)= ppru.object_id
 ---AND ppc.date_computed (+)= ppru.as_of_date
 ---AND ppc.structure_type (+)=ppru.structure_type
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.project_id <> 0
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0
 AND pfxat.txn_currency_code(+) is null
 AND  ppa.project_id = p_project_id
 ---and ppc.current_flag (+) = 'Y' -- Copied from  Fix for Bug # 4190747. : Confirmed with Satish
 ---and ppc.published_flag (+) = 'Y' -- Copied from Fix for Bug # 4190747. : Confirmed with Satish
 and ppv.parent_structure_version_id = p_structure_version_id;

-- ************************************************************************************************************************
-- if p_structure_version_id and p_wbs_display_depth are passed in, populate all task records for the structure version until the depth.
-- ************************************************************************************************************************

elsif ((p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and ( p_wbs_display_depth <> -1)) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
----------------------------
----------------------------
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
-------------------------
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
---------------------------
----------------------
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
-------------------------------
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
---------------------------
---------------------------
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
----------------------------
----------------------------
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
-----------------------------
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
-------------------------
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
-------------------------
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
-----------------------------
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, EDIT_FLAG
, PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
 --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/
 /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppe.project_id
   ,ppv.display_sequence
   ,ppvsch.milestone_flag
   ,fl1.meaning
   ,ppvsch.critical_flag
   ,fl2.meaning
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type, 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ----ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
------------------------------- 1
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,fl3.meaning
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(null)  -- Report Version ID
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
--------------------------------------------- 2
   ,null -- not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,null -- not populating as not needed in VO ppe.pm_source_code
   ,null -- -- not populating as not needed in VO ppe.pm_source_reference
   ,null --  not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
   ,null
/*    not populating as not needed in VO
PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',
PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
   ,papf.work_telephone
   ,lu1.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
   ,fl4.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
   ,pt.chargeable_flag
   ,fl5.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
   ,pt.billable_flag
   ,fl6.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,to_date(null) -- not needed in VO ppvsch.last_update_date
   ,to_date(NULL) -- not needed in VO
   ,to_date(NULL) -- not needed in VO ppa.BASELINE_AS_OF_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,null -- not needed in VO trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,null-- not needed in VO trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_finish_date)
---------------------------------------------- 3
   ,null -- not needed in VO decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,null -- not needed in VO ppe.CREATION_DATE
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,null -- Populating Task Status Name as NULL
   ,ppe.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,null -- not needed in VO ppvsch.duration
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
--------------------------------------------------------------------------------
   ,pt.address_id
   ,null--addr.address1
   ,null--addr.address2
   ,null--addr.address3
   ,null
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
  , tt.PERCENT_COMP_ENABLE_FLAG
  , tt.REMAIN_EFFORT_ENABLE_FLAG
   ,to_number(null)  -- not needed in VO TASK_PROGRESS_ENTRY_PAGE_ID
   ,null -- not needed in VO page_name
------------------------------------------------ 5
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                                                                 -- Fix for Bug # 4319171.
   ,null -- not needed in VO PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
   ,ppru.CUMULATIVE_WORK_QUANTITY
   ,null -- not needed in VO pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   ,ppe.phase_version_id
   ,pps5.project_status_name
   ,null --Phase Short Name
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
--------------------------------------------------------------------
   ,to_number(null) -- lifecycle version id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,null --current phase name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , ppru.subprj_ppl_act_effort, ppru.subprj_eqpmt_act_effort, null)
                                                                Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                                       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                                         ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
----------------------------------------------------------------- 7
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   ,null --Lowest task
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
----------------------------------------------------------------------------------
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'PUBLISH')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'PUBLISH'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                        ,ppru.subprj_oth_etc_cost_pc,null
                                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                         +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'PUBLISH')) Estimate_At_Completion_Cost
 --------------------------------------------------------------------------------------
 ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                 nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
     ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppv.proj_element_id,
                                                                   ppru.as_of_date,
                                                                   ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                           ppru.object_id,
                                           ppe.proj_element_id,
                                           ppru.as_of_date,
                                                                   ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                        ,ppru.subprj_oth_etc_cost_pc,null
                                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                         +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'PUBLISH'))) Variance_At_Completion_Cost
---------------------------------------------------------------

   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
        +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
 */  ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                           ppru.object_id,
                                          ppe.proj_element_id,
                                          ppru.as_of_date,
                                          ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                           ppe.baseline_start_date,
                           ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                                                          ppe.proj_element_id,
                                                                          ppru.as_of_date,
                                                                          ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                               ppe.baseline_start_date,
                                                        ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,
                                               nvl(pa_progress_utils.get_bcws(ppa.project_id,ppru.object_id,
                                                                ppe.proj_element_id,ppru.as_of_date,
                                                                ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                                                ppe.baseline_start_date,
                                                                ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
    ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
       0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
       0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
---------------------------------------------------------------------
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,null -- not used in VO PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,null -- not used in VO pt.gen_etc_source_code
   ,null -- not used in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   -- Bug Fix 5611634.
   --,PA_PROJ_ELEMENTS_UTILS.Check_Edit_Task_Ok(ppe.project_id, ppv.parent_structure_version_id, PA_PROJ_ELEMENTS_UTILS.GetGlobalStrucVerId)
   ,l_check_edit_task_ok
   -- End of Bug Fix 5611634.
,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
 ,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    ,pa_proj_elem_ver_schedule ppvsch
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,pa_lookups fl3
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_element_versions ppv2
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,fnd_lookups fl1
    ,fnd_lookups fl2
    ,fnd_lookups fl4
    ,fnd_lookups fl5
    ,fnd_lookups fl6
    ,pa_lookups lu1
    ,pa_work_types_tl pwt
    ,pa_progress_rollup ppru
    ,pa_project_statuses pps
    ----,pa_percent_completes ppc
    ,pa_project_statuses pps5
    ,pa_task_types tt
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppe.project_id = ppv.project_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.priority_code = fl3.lookup_code(+)
 AND fl3.lookup_type(+) = 'PA_TASK_PRIORITY_CODE'
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id(+)
 AND pwt.language (+) = userenv('lang')
 AND NVL( ppvsch.milestone_flag, 'N' ) = fl1.lookup_code
 AND fl1.lookup_type = 'YES_NO'
 AND NVL( ppvsch.critical_flag, 'N' ) = fl2.lookup_code
 AND fl2.lookup_type = 'YES_NO'
 AND pt.chargeable_flag = fl4.lookup_code(+)
 AND fl4.lookup_type(+) = 'YES_NO'
 AND pt.billable_flag = fl5.lookup_code(+)
 AND fl5.lookup_type(+) = 'YES_NO'
 AND pt.receive_project_invoice_flag = fl6.lookup_code(+)
 AND fl6.lookup_type(+) = 'YES_NO'
 AND pt.service_type_code = lu1.lookup_code(+)
 AND lu1.lookup_type (+) = 'SERVICE TYPE'
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppru.structure_version_id is null
 AND NVL( ppru.current_flag (+), 'N' ) = 'Y'
 AND NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code ) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+)= ppru.object_id
 ---AND ppc.date_computed (+)= ppru.as_of_date
 ---AND ppc.structure_type (+)=ppru.structure_type
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.project_id <> 0
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0
 AND pfxat.txn_currency_code(+) is null
 AND  ppa.project_id = p_project_id
 ---and ppc.current_flag (+) = 'Y' -- Copied from  Fix for Bug # 4190747. : Confirmed with Satish
 ---and ppc.published_flag (+) = 'Y' -- Copied from Fix for Bug # 4190747. : Confirmed with Satish
 and ppv.parent_structure_version_id = p_structure_version_id
 and ppv.wbs_level <= p_wbs_display_depth;

-- ************************************************************************************************************************
-- if p_task_version_id is passed in, populate all the immediate child task records for the given task version.
-- ************************************************************************************************************************

elsif (p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) then

INSERT INTO pa_structures_tasks_tmp
(
  parent_project_id
, element_Number
, element_Name
, description
, Object_Type
, element_version_id
, proj_element_id
, project_id
, display_sequence
, milestone_flag
, milestone_flag_meaning
, critical_flag
, critical_flag_meaning
, parent_element_version_id
, parent_object_type
, relationship_type
, relationship_subtype
, summary_element_flag
, Progress_status_code
, Progress_status_meaning
, Progress_comments
, Progress_brief_overview
, Scheduled_Start_Date
, Scheduled_Finish_Date
, Task_Manager_Id
, Task_Manager
, parent_structure_version_id
, wbs_level
, wbs_number
, ELEM_REC_VER_NUMBER
, ELEM_VER_REC_VER_NUMBER
, ELEM_VER_SCH_REC_VER_NUMBER
, PARENT_VER_REC_VER_NUMBER
----------------------------
----------------------------
, status_icon_active_ind
, percent_complete_id
, status_icon_ind
, Status_code
, Status_code_meaning
, Priority_code
, priority_Description
, Organization_id
, Organization_name
, Include_in_Proj_Prog_Rpt
, ESTIMATED_START_DATE
, ESTIMATED_FINISH_DATE
, ACTUAL_START_DATE
, ACTUAL_FINISH_DATE
, COMPLETED_PERCENTAGE
, object_relationship_id
, OBJECT_REC_VER_NUMBER
, pev_schedule_id
, LATEST_EFF_PUBLISHED_FLAG
, project_number
, project_name
, parent_element_id
, structure_type_class_code
, published_date
, link_task_flag
, display_parent_version_id
, as_of_date
, report_version_id
, baseline_start_date
, baseline_finish_date
, sch_bsl_start_var
, sch_bsl_finish_var
, est_sch_start_var
, est_sch_finish_var
, act_sch_start_var
, act_sch_finish_var
-------------------------
, pm_source_name
, pm_source_code
, pm_source_reference
, active_task_flag
, active_task_meaning
, days_to_sch_start
, days_to_sch_finish
, work_telephone
, service_type_meaning
, service_type_code
, work_type_name
, work_type_id
, chargeable_meaning
, chargeable_flag
, billable_meaning
, billable_flag
, receive_project_invoice_m
, receive_project_invoice_flag
, transaction_ctrl_start_date
, transaction_ctrl_finish_date
, prior_percent_complete
, schedule_as_of_date
, transaction_as_of_date
, baseline_as_of_date
, estimate_as_of_date
, actual_as_of_date
, financial_task_flag
, days_to_estimate_start
, days_to_estimate_finish
, days_since_act_start
, days_since_act_finish
---------------------------
----------------------
, finished_task_flag
, finished_task_meaning
, task_creation_date
, lowest_task_meaning
, task_type_id
, task_type
, task_status_code
, task_status_meaning
, phase_code
, phase_code_meaning
, planned_effort
, WEIGHTING_PERCENTAGE
, scheduled_duration_days
, baseline_duration_days
, estimated_duration_days
, actual_duration_days
-------------------------------
, address_id
, address1
, address2
, address3
, address4
, WQ_item_code
, WQ_item_meaning
, WQ_UOM_code
, WQ_UOM_meaning
, wq_planned_quantity
, ACTUAL_WQ_ENTRY_CODE
, ACTUAL_WQ_ENTRY_MEANING
, PROG_ENTRY_ENABLE_FLAG
, PERCENT_COMP_ENABLE_FLAG
, REMAIN_EFFORT_ENABLE_FLAG
, TASK_PROGRESS_ENTRY_PAGE_ID
, PAGE_NAME
---------------------------
---------------------------
, BASE_PERCENT_COMP_DERIV_CODE
, BASE_PERCENT_COMP_DERIV_M
, WQ_ENABLE_FLAG
, PROG_ENTRY_REQ_FLAG
, estimated_remaining_effort
, struct_published_flag
, actual_work_quantity
, versioning_enabled_flag
, phase_version_id
, phase_name
, short_phase_name
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
----------------------------
----------------------------
, lifecycle_version_id
, task_unpub_ver_status_code
, open_issues
, open_change_documents
, child_element_flag
, days_until_scheduled_finish
, current_phase_name
, open_change_requests
, open_change_orders
, planned_equip_effort
, raw_cost
, burdened_cost
, planned_cost
, actual_effort
, actual_equip_effort
, Predecessors
, Percent_Spent_Effort
, Percent_Spent_Cost
, Percent_Complete_Effort
, Percent_Complete_Cost
, Actual_Duration
, Remaining_Duration
-----------------------------
, Constraint_Type
, constraint_type_code
, Constraint_Date
, Early_Start_Date
, Early_Finish_Date
, Late_Start_Date
, Late_Finish_Date
, Free_Slack
, Total_Slack
, Lowest_Task
, Estimated_Baseline_Start
, Estimated_Baseline_Finish
, Planned_Baseline_Start
, Planned_Baseline_Finish
, Baseline_Effort
-------------------------
, ETC_Effort
, Estimate_At_Completion_Effort
, Variance_At_Completion_Effort
, Effort_Variance
, Effort_Variance_Percent
, Actual_Cost
, Baseline_Cost
, Estimate_At_Completion_Cost
-------------------------
, Cost_Variance
, Cost_Variance_Percent
, ETC_Work_Quantity
, Planned_Cost_Per_Unit
, Actual_Cost_Per_Unit
, Work_Quantity_Variance
, Work_Quantity_Variance_Percent
, Earned_Value
, Schedule_Variance
, Earned_Value_Cost_Variance
, Earned_Value_Schedule_Variance
, Variance_At_Completion_Cost
-----------------------------
, To_Complete_Performance_Index
, Budgeted_Cost_Of_Work_Sch
, Schedule_Performance_Index
, Cost_Performance_Index
, Mapped_Financial_Task
, Deliverables
, Etc_Source_Code
, Etc_Source_Name
, Wf_Item_Type
, Wf_Process
, Wf_Start_Lead_Days
, Enable_Wf_Flag
, Mapped_Fin_Task_Name
, ETC_Cost
, PROGRESS_ROLLUP_ID
, EDIT_FLAG
 , PLANNED_BASELINE_EFFORT_VAR -- Bug 5090355
, PLANNED_BASELINE_COST_VAR -- Bug 5090355
)
SELECT
 --Bug 7644130 /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/
 /*+ INDEX(pfxat pji_fm_xbs_accum_tmp1_n1)*/  --Bug 7644130
    p_parent_project_id
   ,decode( ppe.object_type, 'PA_TASKS', ppe.element_number, 'PA_STRUCTURES', to_char( ppvs.version_number ) )
   ,decode( ppe.object_type, 'PA_TASKS', ppe.name, 'PA_STRUCTURES', ppvs.name )
   ,ppe.description
   ,ppe.object_type
   ,ppv.element_version_id
   ,ppe.proj_element_id
   ,ppe.project_id
   ,ppv.display_sequence
   ,ppvsch.milestone_flag
   ,fl1.meaning
   ,ppvsch.critical_flag
   ,fl2.meaning
   ,por.object_id_from1
   ,por.object_type_from
   ,por.relationship_type
   ,por.relationship_subtype
   -- ,decode(ppv.prg_group, null -- Fix for Bug # 4490532.
   ,decode(ppe.object_type, 'PA_STRUCTURES', 'Y'
           , 'PA_TASKS', PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ppv.element_version_id))
                            summary_element_flag -- Fix for Bug # 4490532.
   -- , 'Y') -- Fix for Bug # 4279419. -- Fix for Bug # 4490532.
   ,NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code )
   ,PPS.PROJECT_STATUS_NAME
   ,null   ---ppc.PROGRESS_COMMENT
   ,null   ----ppc.DESCRIPTION
   ,ppvsch.scheduled_start_date
   ,ppvsch.scheduled_finish_date
   ,ppe.manager_person_id
   ,papf.FULL_NAME
   ,ppv.parent_structure_version_id
   ,ppv.wbs_level
   ,ppv.wbs_number
   ,ppe.record_version_number
   ,ppv.record_version_number
   ,ppvsch.record_version_number
   ,ppv2.record_version_number
   ,pps.status_icon_active_ind
   ,ppru.percent_complete_id
------------------------------- 1
   ,pps.status_icon_ind
   ,ppe.status_code
   ,pps2.project_status_name
   ,ppe.priority_code
   ,fl3.meaning
   ,ppe.carrying_out_organization_id
   ,hou.name
   ,ppe.inc_proj_progress_flag
   ,ppvsch.estimated_start_date
   ,ppvsch.estimated_finish_date
   ,ppvsch.actual_start_date
   ,ppvsch.actual_finish_date
   ,NVL( ppru.COMPLETED_PERCENTAGE, ppru.eff_rollup_percent_comp )
   ,por.object_relationship_id
   ,por.record_version_number
   ,ppvsch.pev_schedule_id
   ,ppvs.LATEST_EFF_PUBLISHED_FLAG
   ,ppa.segment1
   ,ppa.name
   ,ppv2.proj_element_id
   ,pst.structure_type_class_code
   ,ppvs.published_date
   ,ppe.link_task_flag
   ,por.object_id_from1
   ,ppru.as_of_date
   ,to_number(null)  -- Report Version ID
   ,ppe.baseline_start_date
   ,ppe.baseline_finish_date
   ,ppvsch.scheduled_start_date - ppe.baseline_start_date
   ,ppvsch.scheduled_finish_date - ppe.baseline_finish_date
   ,ppvsch.estimated_start_date - ppvsch.scheduled_start_date
   ,ppvsch.estimated_finish_date - ppvsch.scheduled_finish_date
   ,ppvsch.actual_start_date - ppvsch.scheduled_start_date
   ,ppvsch.actual_finish_date - ppvsch.scheduled_finish_date
--------------------------------------------- 2
   ,null -- not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PM_PRODUCT_CODE', ppe.pm_source_code)
   ,null -- not populating as not needed in VO ppe.pm_source_code
   ,null -- -- not populating as not needed in VO ppe.pm_source_reference
   ,null --  not populating as not needed in VO PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type)
   ,null
/*    not populating as not needed in VO
PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',
PA_PROJ_ELEMENTS_UTILS.IS_ACTIVE_TASK(ppv.element_version_id, ppv.object_type))
*/
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_START(ppv.element_version_id, ppv.object_type)
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.Get_DAYS_TO_FINISH(ppv.element_version_id, ppv.object_type)
   ,papf.work_telephone
   ,lu1.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('SERVICE TYPE',pt.service_type_code)
   ,pt.service_type_code
   ,pwt.name
   ,pt.work_type_id
   ,fl4.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.chargeable_flag)
   ,pt.chargeable_flag
   ,fl5.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.billable_flag)
   ,pt.billable_flag
   ,fl6.meaning -- PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',pt.receive_project_invoice_flag)
   ,pt.receive_project_invoice_flag
   ,decode(ppe.task_status,NULL,pt.start_date,ppvsch.scheduled_start_date) start_date
   ,decode(ppe.task_status,NULL,pt.completion_date,ppvsch.scheduled_finish_date) completion_date
   ,PA_PROGRESS_UTILS.GET_PRIOR_PERCENT_COMPLETE(ppa.project_id,ppe.proj_element_id,ppru.as_of_date)
   ,to_date(null) -- not needed in VO ppvsch.last_update_date
   ,to_date(NULL) -- not needed in VO
   ,to_date(NULL) -- not needed in VO ppa.BASELINE_AS_OF_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   ,to_date(null) -- not needed in VO ppru.LAST_UPDATE_DATE
   -- ,PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(ppe.proj_element_id) -- Fix for Bug # 4447949.
   , decode(ppe.proj_element_id, pt.task_id, 'Y', 'N') -- Fix for Bug # 4447949.
   ,null -- not needed in VO trunc(ppvsch.estimated_start_date) - trunc(sysdate)
   ,null-- not needed in VO trunc(ppvsch.estimated_finish_date) - trunc(sysdate)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_start_date)
   ,null -- not needed in VO trunc(sysdate) - trunc(ppvsch.actual_finish_date)
---------------------------------------------- 3
   ,null -- not needed in VO decode(ppvsch.actual_finish_date, NULL, 'N', 'Y')
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',decode(ppvsch.actual_finish_date, NULL, 'N', 'Y'))
   ,null -- not needed in VO ppe.CREATION_DATE
   ,null -- not needed in VO PA_PROJ_ELEMENTS_UTILS.GET_FND_LOOKUP_MEANING('YES_NO',PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ppv.element_version_id))
   ,ppe.TYPE_ID
   ,tt.task_type
   ,ppe.STATUS_CODE
   ,null -- Populating Task Status Name as NULL
   ,ppe.phase_code
   ,pps5.project_status_name
   ,pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours) planned_effort
                                                                                -- Fix for Bug # 4319171.
   ,por.WEIGHTING_PERCENTAGE
   ,null -- not needed in VO ppvsch.duration
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppe.baseline_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.estimated_duration)
   ,null -- not needed in VO pa_proj_elements_utils.convert_hr_to_days(ppvsch.actual_duration)
--------------------------------------------------------------------------------
   ,pt.address_id
   ,null--addr.address1
   ,null--addr.address2
   ,null--addr.address3
   ,null
   ,ppe.wq_item_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_WQ_WORK_ITEMS',ppe.wq_item_code)
   ,ppe.wq_uom_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('UNIT',ppe.wq_uom_code)
   ,ppvsch.wq_planned_quantity
   ,ppe.wq_actual_entry_code
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_ACTUAL_WQ_ENTRY_CODE',ppe.wq_actual_entry_code)
   ,tt.prog_entry_enable_flag
  , tt.PERCENT_COMP_ENABLE_FLAG
  , tt.REMAIN_EFFORT_ENABLE_FLAG
   ,to_number(null)  -- not needed in VO TASK_PROGRESS_ENTRY_PAGE_ID
   ,null -- not needed in VO page_name
------------------------------------------------ 5
   ,NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code)
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_PERCENT_COMP_DERIV_CODE',NVL(ppe.base_percent_comp_deriv_code,tt.base_percent_comp_deriv_code))
   ,tt.wq_enable_flag
   ,tt.prog_entry_req_flag
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) estimated_remaining_effort
                                                                                 -- Fix for Bug # 4319171.
   ,null -- not needed in VO PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(ppv.project_id, ppv.parent_structure_version_id)
   ,ppru.CUMULATIVE_WORK_QUANTITY
   ,null -- not needed in VO pa_workplan_attr_utils.check_wp_versioning_enabled(ppe.project_id)
   ,ppe.phase_version_id
   ,pps5.project_status_name
   ,null --Phase Short Name
   ,pt.attribute_category
   ,pt.attribute1
   ,pt.attribute2
   ,pt.attribute3
   ,pt.attribute4
   ,pt.attribute5
   ,pt.attribute6
   ,pt.attribute7
   ,pt.attribute8
   ,pt.attribute9
   ,pt.attribute10
--------------------------------------------------------------------
   ,to_number(null) -- lifecycle version id
   ,ppv.TASK_UNPUB_VER_STATUS_CODE
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'ISSUE')
   ,to_number(null)
   ,PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(ppv.element_version_id)
   ,trunc(ppvsch.scheduled_finish_date) - trunc(sysdate)
   ,null --current phase name
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_REQUEST')
   ,pa_control_items_utils.get_open_control_items(ppe.project_id,ppe.object_Type,ppe.proj_element_id,'CHANGE_ORDER')
   ,pfxat.equipment_hours planned_equip_effort -- Fix for Bug # 4319171.
   ,pfxat.prj_raw_cost raw_cost
   ,pfxat.prj_brdn_cost burdened_cost
   ,pfxat.prj_brdn_cost planned_cost -- Fix for Bug # 4319171.
   ,pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date, ppru.eqpmt_act_effort_to_date, null
                               , ppru.subprj_ppl_act_effort, ppru.subprj_eqpmt_act_effort, null)
                                                                Actual_Effort -- Fix for Bug # 4319171.
   ,ppru.eqpmt_act_effort_to_date actual_equip_effort -- Fix for Bug # 4319171.
   ,PA_RELATIONSHIP_UTILS.DISPLAY_PREDECESSORS(ppv.element_version_id) Predecessors
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                        (nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                                       ) percent_Spent_Effort
   ,PA_PROGRESS_UTILS.Percent_Spent_Value ((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                        nvl(pfxat.prj_brdn_cost,0)
                                       ) percent_Spent_Cost
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
                                         (nvl(ppru.estimated_remaining_effort,0)+nvl(ppru.eqpmt_etc_effort,0))
                                         ) Percent_Complete_Effort
   ,PA_PROGRESS_UTILS.Percent_Complete_Value((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                          +nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
                                          (nvl(ppru.oth_etc_cost_pc,0)+nvl(ppru.ppl_etc_cost_pc,0)+nvl(ppru.eqpmt_etc_cost_pc,0))
                                         ) Percent_Complete_Cost
   ,trunc(ppru.actual_finish_date) - trunc(ppru.actual_start_date) Actual_Duration
   ,trunc(ppvsch.SCHEDULED_FINISH_DATE) - trunc(sysdate) Remaining_Duration
----------------------------------------------------------------- 7
   ,PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING ( 'PA_SCHEDULE_CONSTRAINT_TYPE',ppvsch.constraint_type_code ) Constraint_Type
   ,ppvsch.constraint_type_code
   ,ppvsch.Constraint_Date
   ,ppvsch.Early_Start_Date
   ,ppvsch.Early_Finish_Date
   ,ppvsch.Late_Start_Date
   ,ppvsch.Late_Finish_Date
   ,ppvsch.Free_Slack
   ,ppvsch.Total_Slack
   ,null --Lowest task
   /* Bug Fix 5466645
   --   ,to_number ( null ) Estimated_Baseline_Start
   --   ,to_number ( null ) Estimated_Baseline_Finish
   */
   , (ppvsch.ESTIMATED_START_DATE - ppe.BASELINE_START_DATE) Estimated_Baseline_Start
   , (ppvsch.ESTIMATED_FINISH_DATE - ppe.BASELINE_FINISH_DATE) Estimated_Baseline_Finish
   ,to_number ( null ) Planned_Baseline_Start
   ,to_number ( null ) Planned_Baseline_Finish
   ,pa_progress_utils.calc_plan(pfxat.base_equip_hours, pfxat.base_labor_hours, null) Baseline_effort
                                                                       -- Fix for Bug # 4319171.
----------------------------------------------------------------------------------
   , pa_progress_utils.calc_etc(pa_progress_utils.calc_plan(pfxat.labor_hours, pfxat.equipment_hours, null)
                                , ppru.estimated_remaining_effort
                                , ppru.eqpmt_etc_effort
                                , null
                                , ppru.subprj_ppl_etc_effort
                                , ppru.subprj_eqpmt_etc_effort
                                , null
                                , null
                                , pa_progress_utils.calc_act(ppru.ppl_act_effort_to_date
                                                             , ppru.eqpmt_act_effort_to_date
                                                             , null
                                                             , ppru.subprj_ppl_act_effort
                                                             , ppru.subprj_eqpmt_act_effort
                                                             , null)) ETC_EFFORT -- Fix for Bug # 4319171.
   ,(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0)
        +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'PUBLISH')) Estimate_At_Completion_Effort
   ,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
       -(nvl(ppru.ppl_act_effort_to_date,0)
         +nvl(ppru.eqpmt_act_effort_to_date,0)
         +pa_progress_utils.sum_etc_values((nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0))
                        ,ppru.estimated_remaining_effort,ppru.eqpmt_etc_effort,null
                        ,ppru.subprj_ppl_etc_effort,ppru.subprj_eqpmt_etc_effort,null,null
                        ,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)
                         +nvl(ppru.subprj_ppl_act_effort,0)+nvl(ppru.subprj_eqpmt_act_effort,0)),'PUBLISH'))) Variance_At_Completion_Effort
   ,((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                          nvl(ppru.eqpmt_act_effort_to_date,0)))
   ,round((((ppru.earned_value)-(nvl(ppru.ppl_act_effort_to_date,0)+
                           nvl(ppru.eqpmt_act_effort_to_date,0)))/(DECODE(ppru.earned_value,0,1,ppru.earned_value))),2)
   ,pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                               , ppru.eqpmt_act_cost_to_date_pc
                               , ppru.oth_act_cost_to_date_pc
                               , null
                               , null
                               , null) Actual_Cost  -- Fix for Bug # 4319171.
   ,pfxat.prj_base_brdn_cost baseline_cost
   ,(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                        ,ppru.subprj_oth_etc_cost_pc,null
                                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                         +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'PUBLISH')) Estimate_At_Completion_Cost
 --------------------------------------------------------------------------------------
 ,((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                 nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                 nvl(ppru.eqpmt_act_cost_to_date_pc,0)))
   ,round((((NVL(ppru.earned_value,0))-(nvl(ppru.oth_act_cost_to_date_pc,0)+
                                  nvl(ppru.ppl_act_cost_to_date_pc,0)+
                                  nvl(ppru.eqpmt_act_cost_to_date_pc,0)))/(DECODE(NVL(ppru.earned_value,0),0,1,NVL(ppru.earned_value,0)))),2)
   ,round((NVL(ppvsch.wq_planned_quantity,0) -  NVL(CUMULATIVE_WORK_QUANTITY,0)),5) ETC_Work_Quantity
   ,pa_currency.round_trans_currency_amt1((nvl(pfxat.prj_brdn_cost,0)/decode(nvl(cumulative_work_quantity,0),0,1,nvl(cumulative_work_quantity,0))),ppa.project_currency_code)  Planned_Cost_Per_Unit -- 4195352
   ,pa_currency.round_trans_currency_amt1((NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
           NVL(ppru.ppl_act_cost_to_date_pc,0)+
           NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)/DECODE(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0),0,1,ppru.CUMULATIVE_WORK_QUANTITY)),ppa.project_currency_code) Actual_Cost_Per_Unit -- 4195352
   ,round((NVL(NVL(ppru.CUMULATIVE_WORK_QUANTITY,0)-NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0)),5) Work_Quantity_Variance
   ,round((((ppru.CUMULATIVE_WORK_QUANTITY-ppvsch.WQ_PLANNED_QUANTITY)/DECODE(NVL(ppvsch.WQ_PLANNED_QUANTITY,0),0,1,ppvsch.WQ_PLANNED_QUANTITY))*100),2) Work_Quantity_Variance_Percent
   ,ppru.earned_value  Earned_Value
     ,(nvl(ppru.earned_value,0)-nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                   ppru.object_id,
                                                                   ppv.proj_element_id,
                                                                   ppru.as_of_date,
                                                                   ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0)) Schedule_Variance
   ,(NVL(ppru.earned_value,0)-NVL((NVL(ppru.oth_act_cost_to_date_pc,0)+
                                    NVL(ppru.ppl_act_cost_to_date_pc,0)+
                                    NVL(ppru.eqpmt_act_cost_to_date_pc,0)),0)) Earned_Value_Cost_Variance
   ,(NVL(ppru.earned_value,0)-NVL(pa_progress_utils.get_bcws(ppa.project_id,
                                           ppru.object_id,
                                           ppe.proj_element_id,
                                           ppru.as_of_date,
                                                                   ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                           ppe.baseline_start_date,
                                                    ppe.baseline_finish_date,ppa.project_currency_code),0)) Earned_Value_Schedule_Variance
   ,((nvl(pfxat.prj_base_brdn_cost,0))
      -(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)
        +nvl(ppru.eqpmt_act_cost_to_date_pc,0)
        +pa_progress_utils.sum_etc_values(pfxat.prj_brdn_cost
                                         ,ppru.ppl_etc_cost_pc
                                         ,ppru.eqpmt_etc_cost_pc
                                         ,ppru.oth_etc_cost_pc
                                         ,ppru.subprj_ppl_etc_cost_pc,ppru.subprj_eqpmt_etc_cost_pc
                                        ,ppru.subprj_oth_etc_cost_pc,null
                                        ,(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)
                                         +nvl(ppru.eqpmt_act_cost_to_date_pc,0)+nvl(ppru.subprj_oth_act_cost_to_date_pc,0)
                                         +nvl(ppru.subprj_ppl_act_cost_pc,0)+nvl(ppru.subprj_eqpmt_act_cost_pc,0)),'PUBLISH'))) Variance_At_Completion_Cost
---------------------------------------------------------------

   ,round(
         decode (ppru.task_wt_basis_code,'EFFORT',
(((nvl(pfxat.base_labor_hours,0) +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                 -(nvl(ppru.ppl_act_effort_to_date,0)  +nvl(ppru.eqpmt_act_effort_to_date,0))
                                )
                                ,0,1,(nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))
                                      -(nvl(ppru.ppl_act_effort_to_date,0) +nvl(ppru.eqpmt_act_effort_to_date,0))
                                         )
                                       ) --End of Effort Value

       /*Cost Starts here*/
,(nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode(nvl(pfxat.prj_base_brdn_cost,0)
         -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       ,
       0,1,nvl(pfxat.prj_base_brdn_cost,0)
           -(nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))
       )
      /*Computation of Cost Value ends here*/
                 ) -- End of Decode Before Round
,2)
To_Complete_Performance_Index
/*  Bug 4343962 : CPI,TCPI columns blanked out in WP,Update WBS,Update Tasks Page if method is Manual / Duration
   ,round((decode (ppru.task_wt_basis_code,'COST',((nvl(pfxat.prj_base_brdn_cost,0)-ppru.earned_value)/decode((nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))),0,1,(nvl(pfxat.prj_base_brdn_cost,0)-(nvl(ppru.oth_act_cost_to_date_pc,0)
        +nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),'EFFORT',(((nvl(pfxat.base_labor_hours,0)
        +nvl(pfxat.base_equip_hours,0))-ppru.earned_value)/decode(((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0))),0,1,((nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0))-(nvl(ppru.ppl_act_effort_to_date,0)
        +nvl(ppru.eqpmt_act_effort_to_date,0))))))),2) To_Complete_Performance_Index
 */  ,(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                           ppru.object_id,
                                          ppe.proj_element_id,
                                          ppru.as_of_date,
                                          ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                           ppe.baseline_start_date,
                           ppe.baseline_finish_date,ppa.project_currency_code),0))  Budgeted_Cost_Of_Work_Sch
   ,round((nvl(ppru.earned_value,0)/decode(nvl(pa_progress_utils.get_bcws(ppa.project_id,
                                                                          ppru.object_id,
                                                                          ppe.proj_element_id,
                                                                          ppru.as_of_date,
                                                                          ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                               ppe.baseline_start_date,
                                                        ppe.baseline_finish_date,ppa.project_currency_code),0),0,1,
                                               nvl(pa_progress_utils.get_bcws(ppa.project_id,ppru.object_id,
                                                                ppe.proj_element_id,ppru.as_of_date,
                                                                ppv.parent_structure_version_id,
                                      -- Bug Fix 56117760
                                      -- ppru.task_wt_basis_code,
                                      l_task_weight_basis_code,
                                      -- End of Bug Fix 56117760
                                                                ppe.baseline_start_date,
                                                                ppe.baseline_finish_date,ppa.project_currency_code),0))),2) Schedule_Performance_Index
 /*Bug 4343962 : Included Fix similar to 4327703 */
    ,round(decode(ppru.task_wt_basis_code,'EFFORT',(nvl(ppru.earned_value,0)/decode((nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0)),
       0,1,(nvl(ppru.ppl_act_effort_to_date,0)+nvl(ppru.eqpmt_act_effort_to_date,0))))
      , (nvl(ppru.earned_value,0)/decode((nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0)),
       0,1, (nvl(ppru.oth_act_cost_to_date_pc,0)+nvl(ppru.ppl_act_cost_to_date_pc,0)+nvl(ppru.eqpmt_act_cost_to_date_pc,0))))),2) cost_performance_index
---------------------------------------------------------------------
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_ID(ppv.element_version_id,ppa.structure_sharing_code) Mapped_Financial_Task
   ,null -- not used in VO PA_DELIVERABLE_UTILS.GET_ASSOCIATED_DELIVERABLES (ppe.proj_element_id)
   ,null -- not used in VO pt.gen_etc_source_code
   ,null -- not used in VO PA_PROJ_ELEMENTS_UTILS.GET_PA_LOOKUP_MEANING('PA_TASK_LVL_ETC_SRC', pt.gen_etc_source_code)
   ,ppe.wf_item_type
   ,ppe.wf_process
   ,ppe.wf_start_lead_days
   ,ppe.enable_wf_flag
   ,null -- not used in VO PA_PROJ_STRUC_MAPPING_UTILS.GET_MAPPED_FIN_TASK_NAME(ppv.element_version_id,ppa.structure_sharing_code)
   ,pa_progress_utils.calc_etc(pfxat.prj_brdn_cost
                               , ppru.ppl_etc_cost_pc
                               , ppru.eqpmt_etc_cost_pc
                               , ppru.oth_etc_cost_pc
                               , ppru.subprj_ppl_etc_cost_pc
                               , ppru.subprj_eqpmt_etc_cost_pc
                               , ppru.subprj_oth_etc_cost_pc
                               , null
                               , pa_progress_utils.calc_act(ppru.ppl_act_cost_to_date_pc
                                                            , ppru.eqpmt_act_cost_to_date_pc
                                                            , ppru.oth_act_cost_to_date_pc
                                                            , ppru.subprj_ppl_act_cost_pc
                                                            , ppru.subprj_eqpmt_act_cost_pc
                                                            , ppru.subprj_oth_act_cost_to_date_pc)) etc_cost
                                                                                -- Fix for Bug # 4319171.
   ,ppru.PROGRESS_ROLLUP_ID
   -- Bug Fix 5611634.
   --,PA_PROJ_ELEMENTS_UTILS.Check_Edit_Task_Ok(ppe.project_id, ppv.parent_structure_version_id, PA_PROJ_ELEMENTS_UTILS.GetGlobalStrucVerId)
   ,l_check_edit_task_ok
   -- End of Bug Fix 5611634.
 ,nvl(pfxat.labor_hours,0)+nvl(pfxat.equipment_hours,0) - (nvl(pfxat.base_labor_hours,0)+nvl(pfxat.base_equip_hours,0)) PLANNED_BASELINE_EFFORT_VAR -- Added  for bug 5090355
,nvl(pfxat.prj_brdn_cost,0) - nvl(pfxat.prj_base_brdn_cost,0) PLANNED_BASELINE_COST_VAR -- Added  for bug 5090355
FROM pa_proj_elem_ver_structure ppvs
    ,pa_proj_elem_ver_schedule ppvsch
    ,pa_proj_elements ppe5
    ,pa_proj_element_versions ppv5
    ,per_all_people_f papf
    ,pa_project_statuses pps2
    ,pa_lookups fl3
    ,hr_all_organization_units_tl hou
    ,pa_projects_all ppa
    ,pa_proj_element_versions ppv2
    ,pa_proj_structure_types ppst
    ,pa_structure_types pst
    ,fnd_lookups fl1
    ,fnd_lookups fl2
    ,fnd_lookups fl4
    ,fnd_lookups fl5
    ,fnd_lookups fl6
    ,pa_lookups lu1
    ,pa_work_types_tl pwt
    ,pa_progress_rollup ppru
    ,pa_project_statuses pps
    ----,pa_percent_completes ppc
    ,pa_project_statuses pps5
    ,pa_task_types tt
    ,pa_tasks pt
    ,pa_proj_elements ppe
    ,pa_proj_element_versions ppv
    ,pa_object_relationships por
    ,pji_fm_xbs_accum_tmp1 pfxat
WHERE
     ppe.proj_element_id = ppv.proj_element_id
 AND ppe.project_id = ppv.project_id
 AND ppv.parent_structure_version_id = ppvs.element_version_id
 AND ppv.project_id = ppvs.project_id
 AND ppvs.status_code = 'STRUCTURE_PUBLISHED'
 AND ppv.element_version_id = ppvsch.element_version_id (+)
 AND ppv.project_id = ppvsch.project_id (+)
 AND ppv.element_version_id = por.object_id_to1
 AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
 AND ppe.manager_person_id = papf.person_id(+)
 AND SYSDATE BETWEEN papf.effective_start_date(+) AND papf.effective_end_date (+)
 AND ppe.status_code = pps2.PROJECT_STATUS_CODE(+)
 AND ppe.priority_code = fl3.lookup_code(+)
 AND fl3.lookup_type(+) = 'PA_TASK_PRIORITY_CODE'
 AND ppe.carrying_out_organization_id = hou.organization_id (+)
 AND userenv('LANG') = hou.language (+)
 AND ppe.project_id = ppa.project_id
 AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
 AND por.object_id_from1 = ppv2.element_version_id(+)
 AND ppe.proj_element_id = ppst.proj_element_id(+)
 AND pst.structure_type_id(+) = ppst.structure_type_id
 AND por.relationship_type = 'S'
 AND (ppe.link_task_flag <> 'Y' or ppe.task_status is not null)
 AND ppv.proj_element_id = pt.task_id (+)
 AND pt.work_type_id = pwt.work_type_id(+)
 AND pwt.language (+) = userenv('lang')
 AND NVL( ppvsch.milestone_flag, 'N' ) = fl1.lookup_code
 AND fl1.lookup_type = 'YES_NO'
 AND NVL( ppvsch.critical_flag, 'N' ) = fl2.lookup_code
 AND fl2.lookup_type = 'YES_NO'
 AND pt.chargeable_flag = fl4.lookup_code(+)
 AND fl4.lookup_type(+) = 'YES_NO'
 AND pt.billable_flag = fl5.lookup_code(+)
 AND fl5.lookup_type(+) = 'YES_NO'
 AND pt.receive_project_invoice_flag = fl6.lookup_code(+)
 AND fl6.lookup_type(+) = 'YES_NO'
 AND pt.service_type_code = lu1.lookup_code(+)
 AND lu1.lookup_type (+) = 'SERVICE TYPE'
 AND ppv.project_id = ppru.project_id(+)
 AND ppv.proj_element_id = ppru.object_id(+)
 AND ppv.object_type = ppru.object_type (+)
 AND ppru.structure_type (+) = 'WORKPLAN'
 AND ppru.structure_version_id is null
 AND NVL( ppru.current_flag (+), 'N' ) = 'Y'
 AND NVL( ppru.PROGRESS_STATUS_CODE, ppru.eff_rollup_prog_stat_code ) = pps.PROJECT_STATUS_CODE(+)
 ---AND ppc.project_id (+) = ppru.project_id
 AND 'PA_TASKS' = ppru.object_type (+)
 ---AND ppc.object_id (+)= ppru.object_id
 ---AND ppc.date_computed (+)= ppru.as_of_date
 ---AND ppc.structure_type (+)=ppru.structure_type
 AND PPE.PHASE_VERSION_ID = PPV5.ELEMENT_VERSION_ID (+)
 AND PPV5.PROJ_ELEMENT_ID = PPE5.PROJ_ELEMENT_ID (+)
 AND PPE5.PHASE_CODE      = PPS5.PROJECT_STATUS_CODE (+)
 AND tt.task_type_id = ppe.type_id
 AND tt.object_type = 'PA_TASKS'
 AND ppe.project_id <> 0
 AND pfxat.project_id (+)= ppv.project_id
 AND pfxat.project_element_id (+)=ppv.proj_element_id
 AND pfxat.struct_version_id (+)=ppv.parent_structure_version_id
 AND pfxat.calendar_type(+) = 'A'
 AND pfxat.plan_version_id (+)> 0
 AND pfxat.txn_currency_code(+) is null
 AND  ppa.project_id = p_project_id
 ---and ppc.current_flag (+) = 'Y' -- Copied from  Fix for Bug # 4190747. : Confirmed with Satish
 ---and ppc.published_flag (+) = 'Y' -- Copied from Fix for Bug # 4190747. : Confirmed with Satish
 and ppv.parent_structure_version_id = p_structure_version_id
 and por.object_id_from1 = p_task_version_id;

end if;

-- Bug # 4875311.

IF pa_fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id) <> 'Y' THEN

UPDATE pa_structures_tasks_tmp
set raw_cost = null,burdened_cost=null,planned_cost=null,Percent_Spent_Cost=null,Percent_Complete_Cost=null,
    Actual_Cost = null,Baseline_Cost=null,Estimate_At_Completion_Cost=null,
    Planned_Cost_Per_Unit=null,Actual_Cost_Per_Unit=null,Variance_At_Completion_Cost=null,
    ETC_Cost =null
    , PLANNED_BASELINE_COST_VAR = NULL --Added for bug 5090355
where project_id = p_project_id
  and parent_structure_version_id=p_structure_version_id;

END IF;

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_UPD_PUBLISHED_RECORDS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'INSERT_UPD_PUBLISHED_RECORDS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END INSERT_UPD_PUBLISHED_RECORDS;

-- Bug # 4875311.

procedure populate_pji_tab_for_plan_prj
(p_api_version                  IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
 ,p_project_element_id          IN      NUMBER          DEFAULT NULL
 ,p_structure_version_id        IN      NUMBER          DEFAULT NULL
 ,p_baselined_str_ver_id        IN      NUMBER          DEFAULT NULL
 ,p_structure_type              IN      VARCHAR2        := 'WORKPLAN'
 ,p_populate_tmp_tab_flag       IN      VARCHAR2        := 'Y'
 ,p_program_rollup_flag         IN      VARCHAR2        := 'Y'
 ,p_calling_context             IN      VARCHAR2        := 'ROLLUP'
 ,p_as_of_date                  IN      DATE            := null
 ,p_wbs_display_depth           IN      NUMBER          := -1
 ,p_structure_flag              IN      VARCHAR2        := 'Y'
 ,x_return_status               OUT     NOCOPY		VARCHAR2
 ,x_msg_count                   OUT     NOCOPY		NUMBER
 ,x_msg_data                    OUT     NOCOPY		VARCHAR2)
is
   l_api_name           CONSTANT   VARCHAR2(30)    := 'populate_pji_tab_for_plan';
   l_api_version        CONSTANT   NUMBER          := p_api_version;
   l_user_id                       NUMBER          := FND_GLOBAL.USER_ID;
   l_login_id                      NUMBER          := FND_GLOBAL.LOGIN_ID;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_baselined_str_ver_id          NUMBER; -- FPM Dev CR 7
   l_structure_version_id          NUMBER; -- Bug 3627315
   l_plan_version_id               NUMBER; -- Bug 3627315
   l_wbs_display_depth             NUMBER;
   l_delete_flag                   VARCHAR2(1);
begin

        IF (p_commit = FND_API.G_TRUE) THEN
                savepoint plan_qtys;
        END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --bug 4290593
        IF p_populate_tmp_tab_flag = 'N' AND PA_PROJ_STRUCTURE_UTILS.CHECK_PJI_TEMP_TAB_POPULATED(p_project_id) = 'Y'
        THEN
           return;
        END IF;
        --end bug 4290593

        -- FPM Dev CR 7 : Passing null if baseline structure version id is -1
        IF p_baselined_str_ver_id = -1 THEN
                l_baselined_str_ver_id := null;
        ELSE
                l_baselined_str_ver_id := p_baselined_str_ver_id;
        END IF;

        l_plan_version_id := null;

        l_wbs_display_depth := p_wbs_display_depth;

        if (p_structure_flag = 'Y') then
                l_delete_flag := 'Y';
        else
                l_delete_flag := 'N';
        end if;

         BEGIN
                  PJI_FM_XBS_ACCUM_UTILS.populate_updatewbs_data
                    (p_project_id               => p_project_id,
                    p_struct_ver_id             => p_structure_version_id,
                    p_base_struct_ver_id        => l_baselined_str_ver_id,
                    p_plan_version_id           => l_plan_version_id,
                    p_as_of_date                => p_as_of_date,
                    p_delete_flag               => l_delete_flag,
                    p_project_element_id        => p_project_element_id,
                    p_level                     => l_wbs_display_depth,
                    p_structure_flag            => p_structure_flag,
                    x_return_status             => l_return_status,
                    x_msg_code                  => l_msg_data);
        EXCEPTION
           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                            p_procedure_name => 'POPULATE_PJI_TAB_FOR_PLAN_PRJ',
                            p_error_text     => SUBSTRB('Call of PJI_FM_XBS_ACCUM_UTILS.populate_updatewbs_data Failed. SQLERRM='||SQLERRM,1,120));
                RAISE FND_API.G_EXC_ERROR;
        END;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => l_msg_data);
                x_msg_data := l_msg_data;
                x_return_status := 'E';
                x_msg_count := l_msg_count;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;
exception
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to plan_qtys;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to plan_qtys;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'populate_pji_tab_for_plan_prj',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to plan_qtys;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_STRUCTURE_PUB',
                              p_procedure_name => 'populate_pji_tab_for_plan_prj',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
      raise;
end populate_pji_tab_for_plan_prj;

-- Bug # 4875311.

end PA_PROJ_STRUCTURE_PUB;


/
