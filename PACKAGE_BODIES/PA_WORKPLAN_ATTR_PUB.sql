--------------------------------------------------------
--  DDL for Package Body PA_WORKPLAN_ATTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORKPLAN_ATTR_PUB" AS
/* $Header: PAPRWPPB.pls 120.4.12010000.2 2009/07/22 12:26:55 gboomina ship $ */

-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_WORKPLAN_ATTR_PUB';


-- API name		: Create_Proj_Workplan_Attrs
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_proj_element_id               IN NUMBER     Required
-- p_approval_reqd_flag            IN VARCHAR2   Required
-- p_auto_publish_flag             IN VARCHAR2   Required
-- p_approver_source_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_source_type          IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_name                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_default_display_lvl           IN NUMBER     Required
-- p_enable_wp_version_flag        IN VARCHAR2   Required
-- p_lifecycle_id                  IN NUMBER	 Optional Default = FND_API.G_MISS_NUM
-- p_lifecycle_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_current_lifecycle_phase_id    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_current_lifecycle_phase       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_auto_pub_upon_creation_flag   IN VARCHAR2   Required
-- p_auto_sync_txn_date_flag       IN VARCHAR2   Required
-- p_txn_date_sync_buf_days        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE CREATE_PROJ_WORKPLAN_ATTRS
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_approval_reqd_flag            IN VARCHAR2
  ,p_auto_publish_flag             IN VARCHAR2
  ,p_approver_source_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_approver_source_type          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_approver_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_default_display_lvl           IN NUMBER
  ,p_enable_wp_version_flag        IN VARCHAR2
  ,p_lifecycle_id	           IN NUMBER     := FND_API.G_MISS_NUM
  ,p_lifecycle_name	           IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_current_lifecycle_phase_id	   IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_lifecycle_phase	   IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_auto_pub_upon_creation_flag   IN VARCHAR2
  ,p_auto_sync_txn_date_flag       IN VARCHAR2
  ,p_txn_date_sync_buf_days        IN NUMBER     := FND_API.G_MISS_NUM
--bug 3325803: FP M
  ,p_allow_lowest_tsk_dep_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_schedule_third_party_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_third_party_schedule_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_auto_rollup_subproj_flag      IN VARCHAR2   := FND_API.G_MISS_CHAR
--bug 3325803: FP M
--FP M: Workflow attributes
  -- gboomina Bug 8586393 - start
  ,p_use_task_schedule_flag        IN  VARCHAR2  := FND_API.G_MISS_CHAR
  -- gboomina Bug 8586393 - end
  ,p_enable_wf_flag                IN  VARCHAR2  := 'N'
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Create_Proj_Workplan_Attrs';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_data                          VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_msg_index_out                 NUMBER;

   l_approver_source_id            NUMBER;
   l_approver_source_type          NUMBER;
   l_lifecycle_id	           NUMBER		:= NULL;
   l_current_lifecycle_phase_id    NUMBER;
BEGIN
   pa_debug.init_err_stack('PA_WORKPLAN_ATTR_PUB.Create_Proj_Workplan_Attrs');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PUB.Create_Proj_Workplan_Attrs BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint create_proj_workplan_attrs;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Performing ID validations and conversions...');
   end if;

   if ((p_approver_name <> FND_API.G_MISS_CHAR) AND (p_approver_name is not NULL)) OR
      ((p_approver_source_id <> FND_API.G_MISS_NUM) AND (p_approver_source_id is not NULL)) then
      PA_WORKPLAN_ATTR_UTILS.CHECK_APPROVER_NAME_OR_ID
      ( p_approver_source_id   => p_approver_source_id
       ,p_approver_source_type => p_approver_source_type
       ,p_approver_name        => p_approver_name
       ,p_check_id_flag        => 'Y'
       ,x_approver_source_id   => l_approver_source_id
       ,x_approver_source_type => l_approver_source_type
       ,x_return_status        => l_return_status
       ,x_error_msg_code       => l_error_msg_code);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
      end if;
   end if;

   If (l_approver_source_id is not null and p_approval_reqd_flag = 'N') then
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PS_APPROVER_ERR');
   End If;

   if ((p_lifecycle_name <> FND_API.G_MISS_CHAR) AND (p_lifecycle_name is not NULL)) OR
      ((p_lifecycle_id <> FND_API.G_MISS_NUM) AND (p_lifecycle_id is not NULL)) then
      PA_WORKPLAN_ATTR_UTILS.CHECK_LIFECYCLE_NAME_OR_ID
      ( p_lifecycle_id   			=> p_lifecycle_id
       ,p_lifecycle_name 			=> p_lifecycle_name
       ,p_check_id_flag        			=> 'Y'
       ,x_lifecycle_id   			=> l_lifecycle_id
       ,x_return_status        			=> l_return_status
       ,x_error_msg_code       			=> l_error_msg_code);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
      end if;
   end if;

   if ((p_current_lifecycle_phase_id <> FND_API.G_MISS_NUM) AND (p_current_lifecycle_phase_id is not NULL)) OR
      ((p_current_lifecycle_phase <> FND_API.G_MISS_NUM) AND (p_current_lifecycle_phase is not NULL)) then
      PA_WORKPLAN_ATTR_UTILS.CHECK_LIFECYCLE_PHASE_NAME_ID
      ( p_lifecycle_id   			=> l_lifecycle_id
       ,p_current_lifecycle_phase_id 		=> p_current_lifecycle_phase_id
       ,p_current_lifecycle_phase        	=> p_current_lifecycle_phase
       ,p_check_id_flag        			=> 'Y'
       ,x_current_lifecycle_phase_id 		=> l_current_lifecycle_phase_id
       ,x_return_status        			=> l_return_status
       ,x_error_msg_code       			=> l_error_msg_code);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
      end if;
   end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;


   PA_WORKPLAN_ATTR_PVT.CREATE_PROJ_WORKPLAN_ATTRS
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_proj_element_id           => p_proj_element_id
    ,p_approval_reqd_flag        => p_approval_reqd_flag
    ,p_auto_publish_flag         => p_auto_publish_flag
    ,p_approver_source_id        => l_approver_source_id
    ,p_approver_source_type      => l_approver_source_type
    ,p_default_display_lvl       => p_default_display_lvl
    ,p_enable_wp_version_flag    => p_enable_wp_version_flag
    ,p_auto_pub_upon_creation_flag => p_auto_pub_upon_creation_flag
    ,p_auto_sync_txn_date_flag   => p_auto_sync_txn_date_flag
    ,p_txn_date_sync_buf_days    => p_txn_date_sync_buf_days
    ,p_lifecycle_version_id    	 => l_lifecycle_id
    ,p_current_phase_version_id  => l_current_lifecycle_phase_id
--bug 3325803
    ,p_allow_lowest_tsk_dep_flag => p_allow_lowest_tsk_dep_flag
    ,p_schedule_third_party_flag => p_schedule_third_party_flag
    ,p_third_party_schedule_code => p_third_party_schedule_code
    ,p_auto_rollup_subproj_flag  => p_auto_rollup_subproj_flag
--end bug 3325803
    -- gboomina Bug 8586393 - start
    ,p_use_task_schedule_flag    => p_use_task_schedule_flag
    -- gboomina Bug 8586393 - end
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data );

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PUB.Create_Proj_Workplan_Attrs END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PUB',
                              p_procedure_name => 'Create_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PUB',
                              p_procedure_name => 'Create_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END CREATE_PROJ_WORKPLAN_ATTRS;


-- API name             : Update_Proj_Workplan_Attrs
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- p_approval_reqd_flag            IN VARCHAR2   Required Default = FND_API.G_MISS_NUM
-- p_auto_publish_flag             IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_approver_source_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_source_type          IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_name                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_default_display_lvl           IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- p_enable_wp_version_flag        IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_lifecycle_id                  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_lifecycle_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_current_lifecycle_phase_id    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_current_lifecycle_phase       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_auto_pub_upon_creation_flag   IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_auto_sync_txn_date_flag       IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_txn_date_sync_buf_days        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_record_version_number         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
--bug 3325803: FP M
-- p_allow_lowest_tsk_dep_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
-- p_schedule_third_party_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
-- p_third_party_schedule_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
---p_auto_rollup_subproj_flag      IN VARCHAR2   := FND_API.G_MISS_CHAR
--bug 3325803: FP M
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional


PROCEDURE UPDATE_PROJ_WORKPLAN_ATTRS
(
   p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_proj_element_id               IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_approval_reqd_flag            IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_auto_publish_flag             IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_approver_source_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_approver_source_type          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_approver_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_default_display_lvl           IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_enable_wp_version_flag        IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_lifecycle_id                  IN NUMBER     := FND_API.G_MISS_NUM
  ,p_lifecycle_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_current_lifecycle_phase_id    IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_lifecycle_phase       IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_auto_pub_upon_creation_flag   IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_auto_sync_txn_date_flag       IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_txn_date_sync_buf_days        IN NUMBER     := FND_API.G_MISS_NUM
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
--bug 3325803: FP M
  ,p_allow_lowest_tsk_dep_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_schedule_third_party_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_third_party_schedule_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_auto_rollup_subproj_flag      IN VARCHAR2   := FND_API.G_MISS_CHAR
--bug 3325803: FP M
--FP M: Workflow attributes
  -- gboomina Bug 8586393 - start
  ,p_use_task_schedule_flag        IN  VARCHAR2  := FND_API.G_MISS_CHAR
  -- gboomina Bug 8586393 - end
  ,p_enable_wf_flag                IN  VARCHAR2  := 'N'
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Proj_Workplan_Attrs';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_data                          VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_msg_index_out                 NUMBER;

   l_approver_source_id            NUMBER;
   l_approver_source_type          NUMBER;
   l_lifecycle_id	           NUMBER      := NULL;
   l_current_lifecycle_phase_id    NUMBER;
BEGIN
   pa_debug.init_err_stack('PA_WORKPLAN_ATTR_PUB.Update_Proj_Workplan_Attrs');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PUB.Update_Proj_Workplan_Attrs BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_proj_workplan_attrs;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Performing ID validations and conversions...');
   end if;

   if ((p_approver_name <> FND_API.G_MISS_CHAR) AND (p_approver_name is not NULL)) OR
      ((p_approver_source_id <> FND_API.G_MISS_NUM) AND (p_approver_source_id is not NULL)) then
      PA_WORKPLAN_ATTR_UTILS.CHECK_APPROVER_NAME_OR_ID
      ( p_approver_source_id   => p_approver_source_id
       ,p_approver_source_type => p_approver_source_type
       ,p_approver_name        => p_approver_name
       ,p_check_id_flag        => 'Y'
       ,x_approver_source_id   => l_approver_source_id
       ,x_approver_source_type => l_approver_source_type
       ,x_return_status        => l_return_status
       ,x_error_msg_code       => l_error_msg_code);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
      end if;
   end if;

   -- Start of Bug fix 5678706
   IF p_enable_wp_version_flag = 'N' AND
      (l_approver_source_id is not null OR
       p_approval_reqd_flag = 'Y' OR
       p_approver_name IS NOT NULL OR
       p_auto_publish_flag = 'Y' OR
       p_auto_pub_upon_creation_flag = 'Y') THEN

	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			     ,p_msg_name       => 'PA_PS_VERSN_DISABLED');
   END IF;
   -- End Of Bug fix 5678706

   If (l_approver_source_id is not null and p_approval_reqd_flag = 'N') then
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PS_APPROVER_ERR');
   End If;

   -- For bug 2593130
   if (p_auto_publish_flag = 'Y' and p_approval_reqd_flag = 'N') then
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PS_AUTO_PUB_INVALID');
   End If;
   -- End of bug fix

   if ((p_lifecycle_name <> FND_API.G_MISS_CHAR) AND (p_lifecycle_name is not NULL)) OR
      ((p_lifecycle_id <> FND_API.G_MISS_NUM) AND (p_lifecycle_id is not NULL)) then

      PA_WORKPLAN_ATTR_UTILS.CHECK_LIFECYCLE_NAME_OR_ID
      ( p_lifecycle_id   			=> p_lifecycle_id
       ,p_lifecycle_name 			=> p_lifecycle_name
       ,p_check_id_flag        			=> 'Y'
       ,x_lifecycle_id   			=> l_lifecycle_id
       ,x_return_status        			=> l_return_status
       ,x_error_msg_code       			=> l_error_msg_code);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
      end if;
   end if;

   if ((p_current_lifecycle_phase_id <> FND_API.G_MISS_NUM) AND (p_current_lifecycle_phase_id is not NULL)) OR
      ((p_current_lifecycle_phase <> FND_API.G_MISS_CHAR) AND (p_current_lifecycle_phase is not NULL)) then

      PA_WORKPLAN_ATTR_UTILS.CHECK_LIFECYCLE_PHASE_NAME_ID
      ( p_lifecycle_id   			=> l_lifecycle_id
       ,p_current_lifecycle_phase_id 		=> p_current_lifecycle_phase_id
       ,p_current_lifecycle_phase        	=> p_current_lifecycle_phase
       ,p_check_id_flag        			=> 'Y'
       ,x_current_lifecycle_phase_id 		=> l_current_lifecycle_phase_id
       ,x_return_status        			=> l_return_status
       ,x_error_msg_code       			=> l_error_msg_code);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
      end if;
   end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   PA_WORKPLAN_ATTR_PVT.UPDATE_PROJ_WORKPLAN_ATTRS
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_proj_element_id           => p_proj_element_id
    ,p_approval_reqd_flag        => p_approval_reqd_flag
    ,p_auto_publish_flag         => p_auto_publish_flag
    ,p_approver_source_id        => l_approver_source_id
    ,p_approver_source_type      => l_approver_source_type
    ,p_default_display_lvl       => p_default_display_lvl
    ,p_enable_wp_version_flag    => p_enable_wp_version_flag
    ,p_auto_pub_upon_creation_flag => p_auto_pub_upon_creation_flag
    ,p_auto_sync_txn_date_flag   => p_auto_sync_txn_date_flag
    ,p_txn_date_sync_buf_days    => p_txn_date_sync_buf_days
    ,p_lifecycle_version_id    	 => l_lifecycle_id
    ,p_current_phase_version_id  => l_current_lifecycle_phase_id
--bug 3325803: FP M
    ,p_allow_lowest_tsk_dep_flag => p_allow_lowest_tsk_dep_flag
    ,p_schedule_third_party_flag => p_schedule_third_party_flag
    ,p_third_party_schedule_code => p_third_party_schedule_code
    ,p_auto_rollup_subproj_flag  => p_auto_rollup_subproj_flag
--bug 3325803: FP M
    -- gboomina Bug 8586393 - start
    ,p_use_task_schedule_flag    => p_use_task_schedule_flag
    -- gboomina Bug 8586393 - end
    ,p_record_version_number     => p_record_version_number
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data );

     --FP M:3491609:Project Execution Workflow
         update pa_proj_elements
            set enable_wf_flag = p_enable_wf_flag
           where proj_element_id = p_proj_element_id ;
     --FP M:3491609:Project Execution Workflow

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PUB.Update_Proj_Workplan_Attrs END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PUB',
                              p_procedure_name => 'Update_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PUB',
                              p_procedure_name => 'Update_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_PROJ_WORKPLAN_ATTRS;

-- API name		: Update_Structure_Name
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_proj_element_id               IN NUMBER     Required
-- p_structure_name                IN VARCHAR2   Required
-- p_record_version_number         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE UPDATE_STRUCTURE_NAME
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_proj_element_id               IN NUMBER
  ,p_structure_name                IN VARCHAR2
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Structure_Name';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_data                          VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_msg_index_out                 NUMBER;
BEGIN
   pa_debug.init_err_stack('PA_WORKPLAN_ATTR_PUB.Update_Structure_Name');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PUB.Update_Structure_Name BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_structure_name;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Performing ID validations and conversions...');
   end if;

   If p_structure_name is null then
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PS_STRUC_NAME_REQ');
   End If;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   PA_WORKPLAN_ATTR_PVT.UPDATE_STRUCTURE_NAME
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_proj_element_id           => p_proj_element_id
    ,p_structure_name            => p_structure_name
    ,p_record_version_number     => p_record_version_number
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data );

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PUB.Update_Structure_Name END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_name;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_name;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PUB',
                              p_procedure_name => 'Update_Structure_Name',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_name;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PUB',
                              p_procedure_name => 'Update_Structure_Name',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_STRUCTURE_NAME;


-- API name		: Delete_Proj_Workplan_Attrs
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_proj_element_id               IN NUMBER     Required
-- p_record_version_number         IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE DELETE_PROJ_WORKPLAN_ATTRS
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Proj_Workplan_Attrs';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_data                          VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_msg_index_out                 NUMBER;
BEGIN
   pa_debug.init_err_stack('PA_WORKPLAN_ATTR_PUB.Delete_Proj_Workplan_Attrs');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PUB.Delete_Proj_Workplan_Attrs BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint delete_proj_workplan_attrs;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   PA_WORKPLAN_ATTR_PVT.DELETE_PROJ_WORKPLAN_ATTRS
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_proj_element_id           => p_proj_element_id
    ,p_record_version_number     => p_record_version_number
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PUB.Delete_Proj_Workplan_Attrs END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PUB',
                              p_procedure_name => 'Delete_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_proj_workplan_attrs;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PUB',
                              p_procedure_name => 'Delete_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_PROJ_WORKPLAN_ATTRS;


END PA_WORKPLAN_ATTR_PUB;

/
