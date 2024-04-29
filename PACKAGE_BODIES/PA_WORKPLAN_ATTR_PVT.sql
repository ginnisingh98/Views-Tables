--------------------------------------------------------
--  DDL for Package Body PA_WORKPLAN_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORKPLAN_ATTR_PVT" AS
/* $Header: PAPRWPVB.pls 120.1.12010000.2 2009/07/22 12:27:38 gboomina ship $ */

-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_WORKPLAN_ATTR_PVT';


-- API name		: Create_Proj_Workplan_Attrs
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
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
-- p_approver_source_id            IN NUMBER     Required
-- p_approver_source_type          IN NUMBER     Required
-- p_default_display_lvl           IN NUMBER     Required
-- p_enable_wp_version_flag        IN VARCHAR2   Required
-- p_auto_pub_upon_creation_flag   IN VARCHAR2   Required
-- p_auto_sync_txn_date_flag       IN VARCHAR2   Required
-- p_txn_date_sync_buf_days        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_use_task_schedule_flag        IN VARCHAR2   Optional
-- p_lifecycle_version_id          IN NUMBER     := FND_API.G_MISS_NUM
-- p_current_phase_version_id      IN NUMBER     := FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE CREATE_PROJ_WORKPLAN_ATTRS
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_approval_reqd_flag            IN VARCHAR2
  ,p_auto_publish_flag             IN VARCHAR2
  ,p_approver_source_id            IN NUMBER
  ,p_approver_source_type          IN NUMBER
  ,p_default_display_lvl           IN NUMBER
  ,p_enable_wp_version_flag        IN VARCHAR2
  ,p_auto_pub_upon_creation_flag   IN VARCHAR2
  ,p_auto_sync_txn_date_flag       IN VARCHAR2
  ,p_txn_date_sync_buf_days        IN NUMBER     := FND_API.G_MISS_NUM
  ,p_lifecycle_version_id          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_phase_version_id      IN NUMBER     := FND_API.G_MISS_NUM
--bug 3325803: FP M
  ,p_allow_lowest_tsk_dep_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_schedule_third_party_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_third_party_schedule_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_auto_rollup_subproj_flag      IN VARCHAR2   := FND_API.G_MISS_CHAR
--bug 3325803: FP M
  -- gboomina added from MC-07 bug 8586393 - start
  ,p_use_task_schedule_flag        IN VARCHAR2 := FND_API.G_MISS_CHAR
  -- gboomina added from MC-07 bug 8586393 - end
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_data                          VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_msg_index_out                 NUMBER;
   l_dummy                         VARCHAR2(1);

   l_auto_publish_flag             VARCHAR2(1);
   l_approver_source_id            NUMBER;
   l_approver_source_type          NUMBER;
   l_txn_date_sync_buf_days        NUMBER;
   l_lifecycle_version_id          NUMBER;
   l_current_phase_version_id      NUMBER;
--bug 3325803: FP M
   l_allow_lowest_tsk_dep_flag     VARCHAR2(1);
   l_schedule_third_party_flag     VARCHAR2(1);
   l_third_party_schedule_code     VARCHAR2(30);
   l_auto_rollup_subproj_flag      VARCHAR2(1);
--bug 3325803: FP M

   -- gboomina added from MC-07 bug 8586393 - start
   l_use_task_schedule_flag         VARCHAR2(1);

   CURSOR c2(p_project_id IN NUMBER) IS
   SELECT use_task_schedule_flag
   FROM PA_PROJ_WORKPLAN_ATTR
   WHERE PROJECT_ID IN
   (SELECT created_from_project_id
    FROM pa_projects_all
    WHERE project_id = p_project_id);
   -- gboomina added from MC-07 bug 8586393 - end

BEGIN

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PVT.Create_Proj_Workplan_Attrs BEGIN');
   end if;

   -- gboomina added from MC-07 bug 8586393 - start
   IF (p_use_task_schedule_flag <> FND_API.G_MISS_CHAR) THEN
     --if values is passed as parameter
     l_use_task_schedule_flag := p_use_task_schedule_flag;
   ELSE
     --get value from parent project or template
     OPEN c2(p_project_id);
     FETCH c2 INTO l_use_task_schedule_flag;
     CLOSE C2;
   END IF;
   -- gboomina added from MC-07 bug 8586393 - end

   if p_commit = FND_API.G_TRUE then
      savepoint create_proj_workplan_attrs_pvt;
   end if;

   if p_approval_reqd_flag <> 'Y' then
     l_auto_publish_flag := 'N';
     l_approver_source_id := NULL;
     l_approver_source_type := NULL;
   else
     l_auto_publish_flag := p_auto_publish_flag;
     l_approver_source_id := p_approver_source_id;
     l_approver_source_type := p_approver_source_type;
   end if;

   if p_txn_date_sync_buf_days = FND_API.G_MISS_NUM THEN
     l_txn_date_sync_buf_days := NULL;
   else
     l_txn_date_sync_buf_days := p_txn_date_sync_buf_days;
   end if;

   If p_lifecycle_version_id = FND_API.G_MISS_NUM THEN
     l_lifecycle_version_id := NULL;
   else
     l_lifecycle_version_id := p_lifecycle_version_id;
   end if;

   IF p_current_phase_version_id = FND_API.G_MISS_NUM THEN
     l_current_phase_version_id := NULL;
   else
     l_current_phase_version_id := p_current_phase_version_id;
   end if;

--bug 3325803: FP M
   IF (p_allow_lowest_tsk_dep_flag = FND_API.G_MISS_CHAR) THEN
     l_allow_lowest_tsk_dep_flag := 'N';
   ELSE
     l_allow_lowest_tsk_dep_flag := p_allow_lowest_tsk_dep_flag;
   END IF;

   IF (p_schedule_third_party_flag = FND_API.G_MISS_CHAR) THEN
     l_schedule_third_party_flag := 'N';
   ELSE
     l_schedule_third_party_flag := p_schedule_third_party_flag;
   END IF;

   IF (p_third_party_schedule_code = FND_API.G_MISS_CHAR) THEN
     l_third_party_schedule_code := NULL;
   ELSE
     l_third_party_schedule_code := p_third_party_schedule_code;
   END IF;

   IF (p_auto_rollup_subproj_flag = FND_API.G_MISS_CHAR) THEN
     --l_auto_rollup_subproj_flag := 'N';
     l_auto_rollup_subproj_flag := 'Y';
   ELSE
     l_auto_rollup_subproj_flag := p_auto_rollup_subproj_flag;
   END IF;
--end bug 3325803

   if p_validate_only <> FND_API.G_TRUE then
      INSERT INTO PA_PROJ_WORKPLAN_ATTR (
        project_id
       ,proj_element_id
       ,wp_approval_reqd_flag
       ,wp_auto_publish_flag
       ,wp_approver_source_id
       ,wp_approver_source_type
       ,wp_default_display_lvl
       ,wp_enable_version_flag
       ,auto_pub_upon_creation_flag
       ,auto_sync_txn_date_flag
       ,txn_date_sync_buf_days
       ,record_version_number
       ,last_update_date
       ,last_updated_by
       ,creation_date
       ,created_by
       ,last_update_login
       ,lifecycle_version_id
       ,current_phase_version_id
       ,schedule_third_party_flag
       ,allow_lowest_tsk_dep_flag
       ,auto_rollup_subproj_flag
       ,third_party_schedule_code
       ,source_object_id
       ,source_object_type
       ,use_task_schedule_flag) -- gboomina added for bug 8586393
      VALUES (
        p_project_id
       ,p_proj_element_id
       ,p_approval_reqd_flag
       ,l_auto_publish_flag
       ,l_approver_source_id
       ,l_approver_source_type
       ,p_default_display_lvl
       ,p_enable_wp_version_flag
       ,p_auto_pub_upon_creation_flag
       ,p_auto_sync_txn_date_flag
       ,l_txn_date_sync_buf_days
       ,1
       ,SYSDATE
       ,FND_GLOBAL.USER_ID
       ,SYSDATE
       ,FND_GLOBAL.USER_ID
       ,FND_GLOBAL.LOGIN_ID
       ,l_lifecycle_version_id
       ,l_current_phase_version_id
       ,l_schedule_third_party_flag
       ,l_allow_lowest_tsk_dep_flag
       ,l_auto_rollup_subproj_flag
       ,l_third_party_schedule_code
       ,p_project_id
       ,'PA_PROJECTS'
       ,l_use_task_schedule_flag); -- gboomina added for bug 8586393
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PVT.Create_Proj_Workplan_Attrs END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_proj_workplan_attrs_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_proj_workplan_attrs_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PVT',
                              p_procedure_name => 'Create_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_proj_workplan_attrs_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PVT',
                              p_procedure_name => 'Create_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END CREATE_PROJ_WORKPLAN_ATTRS;


-- API name             : Update_Proj_Workplan_Attrs
-- Type                 : Private
-- Pre-reqs             : None.
-- Parameters           :
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- p_proj_element_id               IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- p_approval_reqd_flag            IN VARCHAR2   Required Default = FND_API.G_MISS_NUM
-- p_auto_publish_flag             IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_approver_source_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_source_type          IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_default_display_lvl           IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- p_enable_wp_version_flag        IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_auto_pub_upon_creation_flag   IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_auto_sync_txn_date_flag       IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_txn_date_sync_buf_days        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_lifecycle_version_id          IN NUMBER     := FND_API.G_MISS_NUM
-- p_current_phase_version_id      IN NUMBER     := FND_API.G_MISS_NUM
-- p_record_version_number         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_use_task_schedule_flag        IN NUMBER     Optional
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional


PROCEDURE UPDATE_PROJ_WORKPLAN_ATTRS
(
   p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_proj_element_id               IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_approval_reqd_flag            IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_auto_publish_flag             IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_approver_source_id            IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_approver_source_type          IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_default_display_lvl           IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_enable_wp_version_flag        IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_auto_pub_upon_creation_flag   IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_auto_sync_txn_date_flag       IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_txn_date_sync_buf_days        IN NUMBER     := FND_API.G_MISS_NUM
  ,p_lifecycle_version_id          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_phase_version_id      IN NUMBER     := FND_API.G_MISS_NUM
--bug 3325803: FP M
  ,p_allow_lowest_tsk_dep_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_schedule_third_party_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_third_party_schedule_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_auto_rollup_subproj_flag      IN VARCHAR2   := FND_API.G_MISS_CHAR
--bug 3325803: FP M
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  -- gboomina added for bug 8586393 - start
  ,p_use_task_schedule_flag        IN VARCHAR2   := FND_API.G_MISS_CHAR
  -- gboomina added for bug 8586393 - end
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_data                          VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_msg_index_out                 NUMBER;
   l_dummy                         VARCHAR2(1);
   l_clear_phase_flag              VARCHAR2(1);

   l_auto_publish_flag             VARCHAR2(1);
   l_approver_source_id            NUMBER;
   l_approver_source_type          NUMBER;
   l_txn_date_sync_buf_days        NUMBER;
--LDENG
   l_lifecycle_version_id          NUMBER;
   l_current_phase_version_id      NUMBER;
--END LDENG

--mrajput
   l_is_lifecycle_tracking         VARCHAR2(1);
   l_delete_ok			   VARCHAR2(1);
   l_current_sequence		   NUMBER;
   l_change_sequence		   NUMBER;
   l_curr_phase_id		   NUMBER;
   l_future_phase_id               NUMBER;
   l_lifecycle_id		   NUMBER;
   l_policy_code                   VARCHAR2(30);
   l_phase_change_code             VARCHAR2(30);

--bug 3325803: FP M
   l_allow_lowest_tsk_dep_flag     VARCHAR2(1);
   l_schedule_third_party_flag     VARCHAR2(1);
   l_third_party_schedule_code     VARCHAR2(30);
   l_auto_rollup_subproj_flag      VARCHAR2(1);
--bug 3325803: FP M

   -- gboomina added for bug 8586393 - start
      l_use_task_schedule_flag        VARCHAR2(1);
   -- gboomina added for bug 8586393 - end

   CURSOR c_current_display_sequence
   IS
   SELECT display_sequence,proj_element_id
   FROM   pa_proj_element_versions
   WHERE  element_version_id = l_current_phase_version_id;

   CURSOR c_change_display_sequence
   IS
   SELECT display_sequence,proj_element_id
   FROM   pa_proj_element_versions
   WHERE  element_version_id = p_current_phase_version_id;

-- End mrajput
  l_error_message VARCHAR(32); -- Bug 2760719

   CURSOR c_get_struc_versions
   IS
   select element_version_id
   from pa_proJ_elem_ver_structure
   where project_id = p_project_id
   AND proj_element_id = p_proj_element_id;
   l_structure_version_id NUMBER;
   l_dep_in_summary  VARCHAR2(1);

BEGIN


   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PVT.Update_Proj_Workplan_Attrs BEGIN');
   end if;

   if (p_commit = FND_API.G_TRUE) then
      savepoint update_proj_workplan_attrs_pvt;
   end if;

--LDENG
   l_clear_phase_flag := 'N';
   l_lifecycle_version_id := NULL;
   l_current_phase_version_id := NULL;
--END LDENG

-- mrajput added.
-- 18 Nov 2002. For Product Lifecycle Management through Bug2665633.
-- bug 3325803: Added new attributes
  SELECT LIFECYCLE_VERSION_ID, CURRENT_PHASE_VERSION_ID,
         schedule_third_party_flag, allow_lowest_tsk_dep_flag,
         auto_rollup_subproj_flag, third_party_schedule_code
         INTO l_lifecycle_version_id, l_current_phase_version_id,
         l_schedule_third_party_flag, l_allow_lowest_tsk_dep_flag,
         l_auto_rollup_subproj_flag, l_third_party_schedule_code
         FROM pa_proj_workplan_attr
         WHERE proj_element_id = p_proj_element_id
         AND record_version_number = p_record_version_number;



	  PA_EGO_WRAPPER_PUB.check_lc_tracking_project(
		p_api_version		=> 1.0				,
		p_project_id		=> p_project_id			,
		x_is_lifecycle_tracking	=> l_is_lifecycle_tracking	,
		x_return_status		=> l_return_status		,
		x_errorcode		=> l_error_msg_code		,
		x_msg_count		=> l_msg_count			,
		x_msg_data		=> l_msg_data );


IF l_is_lifecycle_tracking = FND_API.G_TRUE THEN
  IF( p_lifecycle_version_id IS NOT NULL ) and (p_lifecycle_version_id <> FND_API.G_MISS_NUM) AND (l_lifecycle_version_id  IS NOT NULL) AND (l_lifecycle_version_id <> p_lifecycle_version_id) THEN

/* Bug2760719 -- Added code to populate error message */

	      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name         => 'PA_LCYL_TRACKING_PROJ');


	      l_msg_count := FND_MSG_PUB.count_msg;

	      IF l_msg_count > 0 THEN
		      x_msg_count := l_msg_count;
		      IF x_msg_count = 1 THEN
		         x_msg_data := l_msg_data;
		      END IF;

		      raise FND_API.G_EXC_ERROR;
   	      END IF;
  END IF;
END IF;

--END mrajput

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT LIFECYCLE_VERSION_ID, CURRENT_PHASE_VERSION_ID
         INTO l_lifecycle_version_id, l_current_phase_version_id
         FROM pa_proj_workplan_attr
         WHERE proj_element_id = p_proj_element_id
         AND record_version_number = p_record_version_number
         FOR UPDATE OF record_version_number NOWAIT;
      EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            if SQLCODE = -54 then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
               raise;
            end if;
      END;
   else
      BEGIN
         SELECT LIFECYCLE_VERSION_ID, CURRENT_PHASE_VERSION_ID
         INTO l_lifecycle_version_id, l_current_phase_version_id
         FROM pa_proj_workplan_attr
         WHERE proj_element_id = p_proj_element_id
         AND record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            raise;
      END;
   end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_approval_reqd_flag <> 'Y' then
     l_auto_publish_flag := 'N';
     l_approver_source_id := NULL;
     l_approver_source_type := NULL;
   else
     l_auto_publish_flag := p_auto_publish_flag;
     l_approver_source_id := p_approver_source_id;
     l_approver_source_type := p_approver_source_type;
   end if;

   if p_txn_date_sync_buf_days = FND_API.G_MISS_NUM THEN
     l_txn_date_sync_buf_days := NULL;
   else
     l_txn_date_sync_buf_days := p_txn_date_sync_buf_days;
   end if;

--mrajput
-- 18 Nov 2002. For Product Lifecycle Management through Bug2665633.
 IF (l_is_lifecycle_tracking = FND_API.G_TRUE ) THEN

-- changes for bug 2808582
      	OPEN  c_current_display_sequence;
	FETCH c_current_display_sequence into l_current_sequence,l_curr_phase_id;
        CLOSE c_current_display_sequence;

	OPEN  c_change_display_sequence;
	FETCH c_change_display_sequence into l_change_sequence,l_future_phase_id;
        CLOSE c_change_display_sequence;

-- IF (l_current_phase_version_id is not NULL) and (p_current_phase_version_id <> FND_API.G_MISS_NUM) THEN
--changes for bug 2742365

-- Changes for Bug 2760719 , Added condition so that it considers the case of nulling out the phase

  IF (p_current_phase_version_id <> FND_API.G_MISS_NUM  OR p_current_phase_version_id is null ) THEN
    IF ((l_current_phase_version_id IS NOT NULL ) AND (l_current_phase_version_id <> p_current_phase_version_id) AND (p_current_phase_version_id IS NOT NULL)
       OR
       ((l_current_phase_version_id IS NOT NULL ) AND (p_current_phase_version_id IS NULL)))THEN

/*  commented for bug 2808582
      	OPEN  c_current_display_sequence;
	FETCH c_current_display_sequence into l_current_sequence,l_curr_phase_id;
        CLOSE c_current_display_sequence;

	OPEN  c_change_display_sequence;
	FETCH c_change_display_sequence into l_change_sequence,l_future_phase_id;
        CLOSE c_change_display_sequence; */

	IF(l_change_sequence > l_current_sequence) THEN
		l_phase_change_code := 'PROMOTE';
	ELSE
		l_phase_change_code := 'DEMOTE';
        END IF;

	 BEGIN
		select proj_element_id into l_lifecycle_id
		from pa_proj_element_versions
		where element_version_id = l_lifecycle_version_id;
          EXCEPTION
	  WHEN OTHERS THEN
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	 END;

--hsiu
--bug 3254091
       IF (p_validation_level > 50) THEN
         PA_EGO_WRAPPER_PUB.get_policy_for_phase_change(
		p_api_version		=> 1.0				,
                p_project_id            => p_project_id                 , --Bug 2800909
		p_current_phase_id	=> l_curr_phase_id		,
		p_future_phase_id	=> l_future_phase_id		,
		p_phase_change_code	=> l_phase_change_code		,
		p_lifecycle_id		=> l_lifecycle_id		,
		x_policy_code		=> l_policy_code		,
		x_return_status		=> l_return_status		,
		x_error_message		=> l_error_message		, -- Bug 2760719
		x_errorcode		=> l_error_msg_code		,
		x_msg_count		=> l_msg_count			,
		x_msg_data		=> l_msg_data );

   /* Bug2760719 -- Added code to populate error message */

	IF l_policy_code IN ('CHANGE_ORDER_REQUIRED','NOT_ALLOWED') THEN  -- bug 3423005
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'EGO',
                                 p_msg_name       => l_error_message);
	END IF;

	IF l_policy_code IN ('CHANGE_ORDER_REQUIRED','NOT_ALLOWED') OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN -- bug 3423005
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
		  If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		  End if;
		End if;
	        RAISE  FND_API.G_EXC_ERROR;
	 END IF;
  end if;
--end bug 3254091

       END IF;

  END IF;
END IF;
---END mrajput

--LDENG
   IF (l_lifecycle_version_id is not NULL) and (p_lifecycle_version_id <> FND_API.G_MISS_NUM or p_lifecycle_version_id is null) THEN
         IF(p_lifecycle_version_id is null or l_lifecycle_version_id <> p_lifecycle_version_id) THEN
   	l_clear_phase_flag := 'Y';
      END IF;
   END IF;

   If p_lifecycle_version_id <> FND_API.G_MISS_NUM or p_lifecycle_version_id is null THEN
     l_lifecycle_version_id := p_lifecycle_version_id;
   end if;

   IF p_current_phase_version_id <> FND_API.G_MISS_NUM or p_current_phase_version_id is null THEN
     l_current_phase_version_id := p_current_phase_version_id;
   end if;
--END LDENG

   IF (p_enable_wp_version_flag <>
       PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id)) THEN
     PA_PROJECT_STRUCTURE_PUB1.update_workplan_versioning(
       p_proj_element_id => p_proj_element_id
      ,p_enable_wp_version_flag => p_enable_wp_version_flag
      ,x_return_status => l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data => l_msg_data
     );

     l_msg_count := FND_MSG_PUB.count_msg;
     if l_msg_count > 0 then
        x_msg_count := l_msg_count;
        if x_msg_count = 1 then
           x_msg_data := l_msg_data;
        end if;
        raise FND_API.G_EXC_ERROR;
     end if;
   END IF;

--bug 3305199: FP M
/*** bug 3305199: lowest task dep check ****/
   IF (p_allow_lowest_tsk_dep_flag = 'Y') THEN
     --check each structure version to see if dependency exists in summary level task
     OPEN c_get_struc_versions;
     LOOP
       FETCH c_get_struc_versions INTO l_structure_version_id;
       EXIT WHEN c_get_struc_versions%NOTFOUND;
       l_dep_in_summary :=  PA_PROJECT_STRUCTURE_UTILS.Check_Struct_Has_Dep(l_structure_version_id);

       IF (l_dep_in_summary = 'Y') THEN
         CLOSE c_get_struc_versions;
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name => 'PA_DEP_ON_SUMM_TSK');
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           x_msg_count := l_msg_count;
           IF x_msg_count = 1 THEN
             x_msg_data := l_msg_data;
           END IF;
           raise FND_API.G_EXC_ERROR;
         END IF;
       END IF;

     END LOOP;
     CLOSE c_get_struc_versions;
   END IF;

/*** bug 3305199 ****/

   IF (p_allow_lowest_tsk_dep_flag <> FND_API.G_MISS_CHAR) THEN
     l_allow_lowest_tsk_dep_flag := p_allow_lowest_tsk_dep_flag;
   END IF;

   --gboomina added for Bug 8586393 - start
   IF (p_use_task_schedule_flag <> FND_API.G_MISS_CHAR) THEN
     l_use_task_schedule_flag := p_use_task_schedule_flag;
   END IF;
   --gboomina added for Bug 8586393 - end

   IF (p_schedule_third_party_flag <> FND_API.G_MISS_CHAR) THEN
     l_schedule_third_party_flag := p_schedule_third_party_flag;
   END IF;

   IF (l_schedule_third_party_flag = 'N') THEN
     --clear schedule dirty flag
     update pa_proj_elem_ver_structure
        set SCHEDULE_DIRTY_FLAG = 'N'
      WHERE project_id = p_project_id and proj_element_id = p_proj_element_id;
   END IF;

   IF (p_third_party_schedule_code <> FND_API.G_MISS_CHAR) THEN
     l_third_party_schedule_code := p_third_party_schedule_code;
   END IF;

   IF (p_auto_rollup_subproj_flag <> FND_API.G_MISS_CHAR) THEN
     l_auto_rollup_subproj_flag := p_auto_rollup_subproj_flag;
   END IF;
--end bug 3325803

   if p_validate_only <> FND_API.G_TRUE then
--added condition to specify proj_element_id
  /*
    Modified this update for task progress bug 3420093. Added decodes with default values in following columns
    wp_approval_reqd_flag,wp_auto_publish_flag,wp_default_display_lvl,wp_enable_version_flag,auto_pub_upon_creation_flag,
    auto_sync_txn_date_flag.
  */
  --bug 3905167: added nvl for p_default_display_lvl.
      UPDATE PA_PROJ_WORKPLAN_ATTR
      SET wp_approval_reqd_flag        = decode( p_approval_reqd_flag, FND_API.G_MISS_CHAR, wp_approval_reqd_flag, p_approval_reqd_flag ),
          wp_auto_publish_flag         = decode( l_auto_publish_flag, FND_API.G_MISS_CHAR, wp_auto_publish_flag, l_auto_publish_flag ),
          wp_approver_source_id        = l_approver_source_id,
          wp_approver_source_type      = l_approver_source_type,
          wp_default_display_lvl       = decode( p_default_display_lvl, FND_API.G_MISS_NUM, wp_default_display_lvl, nvl(p_default_display_lvl,0)),
          wp_enable_version_flag       = decode( p_enable_wp_version_flag, FND_API.G_MISS_CHAR, wp_enable_version_flag, p_enable_wp_version_flag),
          auto_pub_upon_creation_flag  = decode( p_auto_pub_upon_creation_flag, FND_API.G_MISS_CHAR, auto_pub_upon_creation_flag, p_auto_pub_upon_creation_flag ),
          auto_sync_txn_date_flag      = decode( p_auto_sync_txn_date_flag, FND_API.G_MISS_CHAR, auto_sync_txn_date_flag, p_auto_sync_txn_date_flag ),
          txn_date_sync_buf_days       = l_txn_date_sync_buf_days,
          lifecycle_version_id         = l_lifecycle_version_id,
          current_phase_version_id     = l_current_phase_version_id,
          schedule_third_party_flag    = l_schedule_third_party_flag,
          allow_lowest_tsk_dep_flag    = l_allow_lowest_tsk_dep_flag,
          auto_rollup_subproj_flag     = l_auto_rollup_subproj_flag,
          third_party_schedule_code    = l_third_party_schedule_code,
          record_version_number        = p_record_version_number + 1,
          last_update_date             = SYSDATE,
          last_updated_by              = FND_GLOBAL.USER_ID,
          last_update_login            = FND_GLOBAL.LOGIN_ID,
          --gboomina added for Bug 8586393 - start
          use_task_schedule_flag       = l_use_task_schedule_flag
          --gboomina added for Bug 8586393 - end
      WHERE project_id = p_project_id and proj_element_id = p_proj_element_id;

--mrajput
-- 18 Nov 2002. For Product Lifecycle Management through Bug2665633.
---changes for bug2742365
 IF (l_is_lifecycle_tracking = FND_API.G_TRUE) THEN

    PA_EGO_WRAPPER_PUB.sync_phase_change(
		p_api_version		=> 1.0			,
		p_project_id		=> p_project_id		,
		p_lifecycle_id		=> l_lifecycle_id	,
		p_phase_id		=> l_future_phase_id	,
		p_effective_date	=> sysdate		,
		p_commit		=> p_commit		,
		x_errorcode		=> l_error_msg_code	,
		x_msg_count		=> l_msg_count		,
		x_return_status 	=> l_return_status	,
		x_msg_data		=> l_msg_data );

/* Bug 2760719 -- Added code to show the error message */

		 l_msg_count := FND_MSG_PUB.count_msg;
		 if l_msg_count > 0 then
		      x_msg_count := l_msg_count;
		      if x_msg_count = 1 then
		         x_msg_data := l_msg_data;
		      end if;
		      raise FND_API.G_EXC_ERROR;
		  end if;
END IF;


-- END mrajput

--LDENG
      IF (l_clear_phase_flag = 'Y') THEN
        UPDATE PA_PROJ_ELEMENTS
        SET phase_version_id = null
        WHERE project_id = p_project_id
	AND phase_version_id IS NOT NULL;
      end if;
--END LDENG
  end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PVT.Update_Proj_Workplan_Attrs END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_proj_workplan_attrs_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_proj_workplan_attrs_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PVT',
                              p_procedure_name => 'Update_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_proj_workplan_attrs_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PVT',
                              p_procedure_name => 'Update_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_PROJ_WORKPLAN_ATTRS;


-- API name		: Update_Structure_Name
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
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
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
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
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_data                          VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_msg_index_out                 NUMBER;
   l_dummy                         VARCHAR2(1);
BEGIN

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PVT.Update_Structure_Name BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_structure_name_pvt;
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_proj_elements
         WHERE proj_element_id = p_proj_element_id
         FOR UPDATE OF record_version_number NOWAIT;
      EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            if SQLCODE = -54 then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
               raise;
            end if;
      END;
   else
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_proj_elements
         WHERE proj_element_id = p_proj_element_id;
      EXCEPTION
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            raise;
      END;
   end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      UPDATE PA_PROJ_ELEMENTS
      SET name                         = p_structure_name,
          record_version_number        = record_version_number + 1,
          last_update_date             = SYSDATE,
          last_updated_by              = FND_GLOBAL.USER_ID,
          last_update_login            = FND_GLOBAL.LOGIN_ID
      WHERE proj_element_id = p_proj_element_id;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PVT.Update_Structure_Name END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_name_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_name_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PVT',
                              p_procedure_name => 'Update_Structure_Name',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_name_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PVT',
                              p_procedure_name => 'Update_Structure_Name',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_STRUCTURE_NAME;


-- API name		: Delete_Proj_Workplan_Attrs
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
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
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
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
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_rowid                         VARCHAR2(250);
   l_dummy                         VARCHAR2(1);

BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PVT.Delete_Proj_Workplan_Attrs BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint delete_proj_workplan_attrs_pvt;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Locking record...');
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_proj_workplan_attr
         WHERE proj_element_id = p_proj_element_id
         AND record_version_number = p_record_version_number
         FOR UPDATE OF record_version_number NOWAIT;
      EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            if SQLCODE = -54 then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
               raise;
            end if;
      END;
   else
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_proj_workplan_attr
         WHERE proj_element_id = p_proj_element_id
         AND record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            raise;
      END;
   end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_validate_only <> FND_API.G_TRUE then

      DELETE FROM PA_PROJ_WORKPLAN_ATTR
      WHERE proj_element_id = p_proj_element_id;

   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_WORKPLAN_ATTR_PVT.Delete_Proj_Workplan_Attrs END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_proj_workplan_attrs_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_proj_workplan_attrs_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_ATTR_PVT',
                              p_procedure_name => 'Delete_Proj_Workplan_Attrs',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_PROJ_WORKPLAN_ATTRS;

END PA_WORKPLAN_ATTR_PVT;

/
