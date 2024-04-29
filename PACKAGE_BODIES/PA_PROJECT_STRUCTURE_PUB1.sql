--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_STRUCTURE_PUB1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_STRUCTURE_PUB1" as
/*$Header: PAXSTCPB.pls 120.8.12010000.3 2010/04/28 06:08:57 sugupta ship $*/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJECT_STRUCTURE_PUB1';

FUNCTION CHECK_ACTION_ALLOWED
( p_action           IN VARCHAR2
 ,p_version_id       IN NUMBER
 ,p_status_code      IN VARCHAR2
) RETURN VARCHAR2
IS
/* Bug 2680486 -- Performance changes, Added c_project_id in the following cursor parameter and added condition accordingly */
CURSOR get_user_locked_status_csr(c_version_id NUMBER, c_user_id NUMBER, c_project_id NUMBER)
IS
SELECT 'Y'
FROM  PA_PROJ_ELEM_VER_STRUCTURE pevs,
      FND_USER fu
WHERE pevs.element_version_id = c_version_id
AND   pevs.lock_status_code = 'LOCKED'
AND   fu.user_id = c_user_id
AND   pevs.locked_by_person_id = fu.employee_id
AND   pevs.project_id = c_project_id;

/* Bug 2680486 -- Performance changes, Added c_project_id in the following cursor parameter and added condition accordingly */

CURSOR get_locked_status_csr(c_version_id NUMBER, c_project_id NUMBER)
IS
SELECT 'Y'
FROM  PA_PROJ_ELEM_VER_STRUCTURE
WHERE element_version_id = c_version_id
AND   lock_status_code = 'LOCKED'
AND   project_id = c_project_id;

CURSOR get_published_status_csr(c_version_id NUMBER, c_project_id NUMBER)
IS
SELECT 'Y'
FROM PA_PROJ_ELEM_VER_STRUCTURE
WHERE element_version_id = c_version_id
AND   published_date is not null
AND   project_id = c_project_id;

CURSOR get_project_id_csr(c_version_id NUMBER)
IS
SELECT project_id
FROM PA_PROJ_ELEMENT_VERSIONS
WHERE element_version_id = c_version_id;

x_ret_code      VARCHAR2(1) := fnd_api.g_false;
l_dummy         VARCHAR2(1) := null;
l_project_id    NUMBER;
l_ret_code      VARCHAR2(250);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_user_id       NUMBER;
l_approval_opt  VARCHAR2(1);
BEGIN
  l_user_id := pa_project_structure_pub1.GetGlobalUserId();
  if l_user_id is null then
    return fnd_api.g_false;
  end if;

/* Bug 2680486 -- Performance changes -- Added the following cursor call to get the project_id,
                  which will be used in further queries to improve performance */
  OPEN get_project_id_csr(p_version_id);
  FETCH get_project_id_csr INTO l_project_id;
  CLOSE get_project_id_csr;


  if p_action = 'EDIT_TASK' then
    if p_status_code = 'STRUCTURE_WORKING' then
      OPEN get_user_locked_status_csr(p_version_id, l_user_id, l_project_id);
      FETCH get_user_locked_status_csr INTO l_dummy;
      if get_user_locked_status_csr%FOUND then
        x_ret_code := fnd_api.g_true;
      else
        x_ret_code := fnd_api.g_false;
      end if;
      CLOSE get_user_locked_status_csr;
    else
      x_ret_code := fnd_api.g_false;
    end if;
  elsif p_action = 'EDIT_TASK_STRUCT' then
    if p_status_code = 'STRUCTURE_WORKING' then
      OPEN get_user_locked_status_csr(p_version_id, l_user_id, l_project_id);
      FETCH get_user_locked_status_csr INTO l_dummy;
      if get_user_locked_status_csr%FOUND then
        x_ret_code := fnd_api.g_true;
      else
        x_ret_code := fnd_api.g_false;
      end if;
      CLOSE get_user_locked_status_csr;
    else
      x_ret_code := fnd_api.g_false;
    end if;
  elsif p_action = 'PUBLISH' then
  /* Bug 2680486 -- Performance changes -- Commented the following cursor call. Now it is getting call at the top */
/*    OPEN get_project_id_csr(p_version_id);
    FETCH get_project_id_csr INTO l_project_id;
    CLOSE get_project_id_csr;
*/

    l_approval_opt := PA_PROJECT_STRUCTURE_UTILS.get_approval_option(l_project_id);

    if l_approval_opt = 'N' then
      if p_status_code = 'STRUCTURE_WORKING' then
        OPEN get_locked_status_csr(p_version_id,l_project_id);
        FETCH get_locked_status_csr INTO l_dummy;
        if get_locked_status_csr%FOUND then
          OPEN get_user_locked_status_csr(p_version_id, l_user_id,l_project_id);
          FETCH get_user_locked_status_csr INTO l_dummy;
          if get_user_locked_status_csr%NOTFOUND then
            x_ret_code := fnd_api.g_false;
          else
            x_ret_code := fnd_api.g_true;
          end if;
          CLOSE get_user_locked_status_csr;
        else
          x_ret_code := fnd_api.g_true;
        end if;
        CLOSE get_locked_status_csr;
      else
        x_ret_code := fnd_api.g_false;
      end if;
    else
      if p_status_code = 'STRUCTURE_APPROVED' then
        OPEN get_locked_status_csr(p_version_id,l_project_id);
        FETCH get_locked_status_csr INTO l_dummy;
        if get_locked_status_csr%FOUND then
          OPEN get_user_locked_status_csr(p_version_id, l_user_id,l_project_id);
          FETCH get_user_locked_status_csr INTO l_dummy;
          if get_user_locked_status_csr%NOTFOUND then
            x_ret_code := fnd_api.g_false;
          else
            x_ret_code := fnd_api.g_true;
          end if;
          CLOSE get_user_locked_status_csr;
        else
          x_ret_code := fnd_api.g_true;
        end if;
        CLOSE get_locked_status_csr;
      else
        x_ret_code := fnd_api.g_false;
      end if;
    end if;
  elsif p_action = 'REWORK' then
    if p_status_code in ('STRUCTURE_SUBMITTED', 'STRUCTURE_APPROVED', 'STRUCTURE_REJECTED') then
      x_ret_code := fnd_api.g_true;
    else
      x_ret_code := fnd_api.g_false;
    end if;
  elsif p_action = 'LOCK' then
    if p_status_code = 'STRUCTURE_WORKING' then
      OPEN get_locked_status_csr(p_version_id,l_project_id);
      FETCH get_locked_status_csr INTO l_dummy;
      if get_locked_status_csr%FOUND then
        x_ret_code := fnd_api.g_false;
      else
        x_ret_code := fnd_api.g_true;
      end if;
    else
      x_ret_code := fnd_api.g_false;
    end if;
  elsif p_action = 'UNLOCK' then
    if p_status_code = 'STRUCTURE_WORKING' then
      OPEN get_user_locked_status_csr(p_version_id, l_user_id,l_project_id);
      FETCH get_user_locked_status_csr INTO l_dummy;
      if get_user_locked_status_csr%FOUND then
        CLOSE get_user_locked_status_csr;
        x_ret_code := fnd_api.g_true;
      else
        CLOSE get_user_locked_status_csr;

        OPEN get_locked_status_csr(p_version_id,l_project_id);
        FETCH get_locked_status_csr INTO l_dummy;
        if get_locked_status_csr%FOUND then

/* Bug 2680486 -- Performance changes -- Commented the following query. We have obtained project_id at the top itself.*/
/*          SELECT project_id
          INTO   l_project_id
          FROM   PA_PROJ_ELEM_VER_STRUCTURE
          WHERE  element_version_id = p_version_id;
*/

          PA_SECURITY_PVT.check_user_privilege
          ( 'PA_UNLOCK_ANY_STRUCTURE'
           ,'PA_PROJECTS'
           ,l_project_id
           ,l_ret_code
           ,l_return_status
           ,l_msg_count
           ,l_msg_data);

          if l_ret_code = fnd_api.g_true then
            x_ret_code := fnd_api.g_true;
          else
            x_ret_code := fnd_api.g_false;
          end if;
        else
          x_ret_code := fnd_api.g_false;
        end if;
      end if;
    else
      x_ret_code := fnd_api.g_false;
    end if;
  elsif p_action = 'OBSOLETE' then
    OPEN get_published_status_csr(p_version_id,l_project_id);
    FETCH get_published_status_csr INTO l_dummy;
    if get_published_status_csr%FOUND then
      x_ret_code := fnd_api.g_true;
    else
      x_ret_code := fnd_api.g_false;
    end if;
    CLOSE get_published_status_csr;
  end if;

  return x_ret_code;

EXCEPTION
WHEN OTHERS THEN
  x_ret_code :=  fnd_api.g_false;
  return x_ret_code;

END CHECK_ACTION_ALLOWED;


PROCEDURE SetGlobalUserId ( p_user_id NUMBER )
IS
BEGIN
  pa_project_structure_pub1.global_user_id := p_user_id;
END SetGlobalUserId;


FUNCTION GetGlobalUserId RETURN NUMBER
IS
BEGIN
  RETURN (  pa_project_structure_pub1.global_user_id  );
END GetGlobalUserId;


-- API name                      : Create_Structure
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id	 IN	 NUMBER
--   p_structure_number	 IN	 VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_name	 IN	 VARCHAR2
--   p_calling_flag	 IN	 VARCHAR2 := 'WORKPLAN'
--   p_structure_description	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_structure_id	 OUT	 NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_number                  IN  VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_name                    IN  VARCHAR2
   ,p_calling_flag                      IN  VARCHAR2 := 'WORKPLAN'
   ,p_structure_description             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_approval_reqd_flag            IN VARCHAR2 := 'N'
   ,p_auto_publish_flag             IN VARCHAR2 := 'N'
   ,p_approver_source_id            IN NUMBER   := FND_API.G_MISS_NUM
   ,p_approver_source_type          IN NUMBER   := FND_API.G_MISS_NUM
   ,p_default_display_lvl           IN NUMBER   := 0
   ,p_enable_wp_version_flag        IN VARCHAR2 := 'N'
   ,p_auto_pub_upon_creation_flag   IN VARCHAR2 := 'N'
   ,p_auto_sync_txn_date_flag       IN VARCHAR2 := 'N'
   ,p_txn_date_sync_buf_days        IN NUMBER   := FND_API.G_MISS_NUM
--LDENG
   ,p_lifecycle_version_id          IN NUMBER   := FND_API.G_MISS_NUM
   ,p_current_phase_version_id      IN NUMBER   := FND_API.G_MISS_NUM
--END LDENG
   ,p_progress_cycle_id             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_wq_enable_flag                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_remain_effort_enable_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_percent_comp_enable_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_next_progress_update_date     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_action_set_id                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_structure_id                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
   l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_STRUCTURE';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_structure_id                  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;


  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_structure;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;


    PA_PROJECT_STRUCTURE_PVT1.Create_Structure(
    p_api_version                     => p_api_version
   ,p_init_msg_list                   => p_init_msg_list
   ,p_commit                          => p_commit
   ,p_validate_only                   => p_validate_only
   ,p_validation_level                => p_validation_level
   ,p_calling_module                  => p_calling_module
   ,p_debug_mode                      => p_debug_mode
   ,p_max_msg_count                   => p_max_msg_count
   ,p_project_id                      => p_project_id
   ,p_structure_number                => p_structure_number
   ,p_structure_name                  => p_structure_name
   ,p_calling_flag                    => p_calling_flag
   ,p_structure_description           => p_structure_description
   ,p_attribute_category              => p_attribute_category
   ,p_attribute1                      => p_attribute1
   ,p_attribute2                      => p_attribute2
   ,p_attribute3                      => p_attribute3
   ,p_attribute4                      => p_attribute4
   ,p_attribute5                      => p_attribute5
   ,p_attribute6                      => p_attribute6
   ,p_attribute7                      => p_attribute7
   ,p_attribute8                      => p_attribute8
   ,p_attribute9                      => p_attribute9
   ,p_attribute10                     => p_attribute10
   ,p_attribute11                     => p_attribute11
   ,p_attribute12                     => p_attribute12
   ,p_attribute13                     => p_attribute13
   ,p_attribute14                     => p_attribute14
   ,p_attribute15                     => p_attribute15
   ,p_approval_reqd_flag          => p_approval_reqd_flag
   ,p_auto_publish_flag           => p_auto_publish_flag
   ,p_approver_source_id          => p_approver_source_id
   ,p_approver_source_type        => p_approver_source_type
   ,p_default_display_lvl         => p_default_display_lvl
   ,p_enable_wp_version_flag      => p_enable_wp_version_flag
   ,p_auto_pub_upon_creation_flag => p_auto_pub_upon_creation_flag
   ,p_auto_sync_txn_date_flag     => p_auto_sync_txn_date_flag
   ,p_txn_date_sync_buf_days      => p_txn_date_sync_buf_days
--LDENG
   ,p_lifecycle_version_id         => p_lifecycle_version_id
   ,p_current_phase_version_id     => p_current_phase_version_id
--END LDENG
   ,p_progress_cycle_id           => p_progress_cycle_id
   ,p_wq_enable_flag              => p_wq_enable_flag
   ,p_remain_effort_enable_flag   => p_remain_effort_enable_flag
   ,p_percent_comp_enable_flag    => p_percent_comp_enable_flag
   ,p_next_progress_update_date   => p_next_progress_update_date
   ,p_action_set_id               => p_action_set_id
   ,x_structure_id                    => l_structure_id
   ,x_return_status                   => l_return_status
   ,x_msg_count                       => l_msg_count
   ,x_msg_data                        => l_msg_data
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_structure_id := l_structure_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'CREATE_STRUCTURE',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'CREATE_STRUCTURE',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END CREATE_STRUCTURE;


-- API name                      : Create_Structure_Version
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_id                      IN  NUMBER
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_structure_version_id  OUT  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Structure_Version
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_id                      IN  NUMBER
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_structure_version_id              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
   l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_STRUCTURE_VERSION';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_structure_version_id          PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE_VERSION');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_structure_version;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version(
    p_api_version           => p_api_version
   ,p_init_msg_list         => p_init_msg_list
   ,p_commit                => p_commit
   ,p_validate_only         => p_validate_only
   ,p_validation_level      => p_validation_level
   ,p_calling_module        => p_calling_module
   ,p_debug_mode            => p_debug_mode
   ,p_max_msg_count         => p_max_msg_count
   ,p_structure_id          => p_structure_id
   ,p_attribute_category    => p_attribute_category
   ,p_attribute1            => p_attribute1
   ,p_attribute2            => p_attribute2
   ,p_attribute3            => p_attribute3
   ,p_attribute4            => p_attribute4
   ,p_attribute5            => p_attribute5
   ,p_attribute6            => p_attribute6
   ,p_attribute7            => p_attribute7
   ,p_attribute8            => p_attribute8
   ,p_attribute9            => p_attribute9
   ,p_attribute10           => p_attribute10
   ,p_attribute11           => p_attribute11
   ,p_attribute12           => p_attribute12
   ,p_attribute13           => p_attribute13
   ,p_attribute14           => p_attribute14
   ,p_attribute15           => p_attribute15
   ,x_structure_version_id  => l_structure_version_id
   ,x_return_status         => l_return_status
   ,x_msg_count             => l_msg_count
   ,x_msg_data              => l_msg_data
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_structure_version_id := l_structure_version_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE_VERSION END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure_version;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'CREATE_STRUCTURE_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'CREATE_STRUCTURE_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END CREATE_STRUCTURE_VERSION;


-- API name                      : Create_Structure_Version_Attr
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id	IN	NUMBER
--   p_structure_version_name	IN	VARCHAR2
--   p_structure_version_desc	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date	IN	DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_latest_eff_published_flag	IN	VARCHAR2 := 'N'
--   p_published_flag	IN	VARCHAR2 := 'N'
--   p_locked_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_struct_version_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_baseline_current_flag	IN	VARCHAR2 := 'N'
--   p_baseline_original_flag	IN	VARCHAR2 := 'N'
--   x_pev_structure_id	OUT	NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Structure_Version_Attr
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_structure_version_name            IN  VARCHAR2
   ,p_structure_version_desc            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date                    IN  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_latest_eff_published_flag         IN  VARCHAR2 := 'N'
   ,p_published_flag                    IN  VARCHAR2 := 'N'
   ,p_locked_status_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_struct_version_status_code        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_current_flag             IN  VARCHAR2 := 'N'
   ,p_baseline_original_flag	         IN  VARCHAR2 := 'N'
   ,p_change_reason_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_pev_structure_id                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
   l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_STRUCTURE_VERSION_ATTR';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_pev_structure_id              PA_PROJ_ELEM_VER_STRUCTURE.PEV_STRUCTURE_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE_VERSION_ATTR');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE_VERSION_ATTR begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_structure_version_attr;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr(
    p_api_version                  => p_api_version
   ,p_init_msg_list                => p_init_msg_list
   ,p_commit                       => p_commit
   ,p_validate_only                => p_validate_only
   ,p_validation_level             => p_validation_level
   ,p_calling_module               => p_calling_module
   ,p_debug_mode                   => p_debug_mode
   ,p_max_msg_count                => p_max_msg_count
   ,p_structure_version_id         => p_structure_version_id
   ,p_structure_version_name       => p_structure_version_name
   ,p_structure_version_desc       => p_structure_version_desc
   ,p_effective_date               => p_effective_date
   ,p_latest_eff_published_flag    => p_latest_eff_published_flag
   ,p_published_flag               => p_published_flag
   ,p_locked_status_code           => p_locked_status_code
   ,p_struct_version_status_code   => p_struct_version_status_code
   ,p_baseline_current_flag        => p_baseline_current_flag
   ,p_baseline_original_flag	     => p_baseline_original_flag
   ,p_change_reason_code           => p_change_reason_code
   ,x_pev_structure_id             => l_pev_structure_id
   ,x_return_status                => l_return_status
   ,x_msg_count                    => l_msg_count
   ,x_msg_data                     => l_msg_data
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_pev_structure_id := l_pev_structure_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE_VERSION_ATTR END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure_version_attr;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure_version_attr;
      end if;

      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'CREATE_STRUCTURE_VERSION_ATTR',
                              p_error_text     => x_msg_data); -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_structure_version_attr;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'CREATE_STRUCTURE_VERSION_ATTR',
                              p_error_text     => x_msg_data); -- 4537865
      raise;
  END CREATE_STRUCTURE_VERSION_ATTR;


-- API name                      : Update_Structure
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_id	 IN	 NUMBER
--   p_structure_number	 IN	 VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_name	 IN	 VARCHAR2
--   p_description	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_record_version_number  IN  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Update_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_id                      IN  NUMBER
   ,p_structure_number                  IN  VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_name                    IN  VARCHAR2
   ,p_description                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
   l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_STRUCTURE';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

   l_dummy                         VARCHAR2(1);


  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.UPDATE_STRUCTURE');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.UPDATE_STRUCTURE begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_structure;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Lock row
    IF( p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENTS
        where proj_element_id = p_structure_id
        and record_version_number = p_record_version_number
        for update of record_version_number NOWAIT;
      EXCEPTION
        WHEN TIMEOUT_ON_RESOURCE THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
          l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          IF SQLCODE = -54 then
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
             l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
          ELSE
             raise;
          END IF;
      END;
    ELSE
      --check record_version_number
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENTS
        where proj_element_id = p_structure_id
        and record_version_number = p_record_version_number;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;

    --check if there is error
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;
    PA_PROJECT_STRUCTURE_PVT1.Update_Structure(
    p_api_version            => p_api_version
   ,p_init_msg_list          => p_init_msg_list
   ,p_commit                 => p_commit
   ,p_validate_only          => p_validate_only
   ,p_validation_level       => p_validation_level
   ,p_calling_module         => p_calling_module
   ,p_debug_mode             => p_debug_mode
   ,p_max_msg_count          => p_max_msg_count
   ,p_structure_id           => p_structure_id
   ,p_structure_number       => p_structure_number
   ,p_structure_name         => p_structure_name
   ,p_description            => p_description
   ,p_attribute_category     => p_attribute_category
   ,p_attribute1             => p_attribute1
   ,p_attribute2             => p_attribute2
   ,p_attribute3             => p_attribute3
   ,p_attribute4             => p_attribute4
   ,p_attribute5             => p_attribute5
   ,p_attribute6             => p_attribute6
   ,p_attribute7             => p_attribute7
   ,p_attribute8             => p_attribute8
   ,p_attribute9             => p_attribute9
   ,p_attribute10            => p_attribute10
   ,p_attribute11            => p_attribute11
   ,p_attribute12            => p_attribute12
   ,p_attribute13            => p_attribute13
   ,p_attribute14            => p_attribute14
   ,p_attribute15            => p_attribute15
   ,p_record_version_number  => p_record_version_number
   ,x_return_status          => x_return_status
   ,x_msg_count              => x_msg_count
   ,x_msg_data               => x_msg_data
    );

    -- 4537865 : Wrong check was made against l_return_status. Corrected it to x_return_status
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.UPDATE_STRUCTURE end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'UPDATE_STRUCTURE',
                              p_error_text     => x_msg_data); -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure;
      end if;

      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'UPDATE_STRUCTURE',
                              p_error_text     => x_msg_data);  -- 4537865
      raise;
  END UPDATE_STRUCTURE;


-- API name                      : Update_Structure_Version_Attr
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_pev_structure_id	      IN 	NUMBER
--   p_structure_version_name	IN	VARCHAR2
--   p_structure_version_desc	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date	IN	DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_latest_eff_published_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_locked_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_struct_version_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_baseline_current_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_baseline_original_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_record_version_number  IN    NUMBER
--   p_current_working_ver_flag          IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Update_Structure_Version_Attr
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_pev_structure_id	                IN  NUMBER
   ,p_structure_version_name            IN  VARCHAR2
   ,p_structure_version_desc            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date                    IN  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_latest_eff_published_flag         IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_locked_status_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_struct_version_status_code        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_current_flag             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_original_flag            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_change_reason_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_record_version_number             IN  NUMBER
    --FP M changes bug 3301192
   ,p_current_working_ver_flag          IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --end FP M changes bug 3301192
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Structure_Version_Attr';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.Update_Structure_Version_Attr');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.UPDATE_STRUCTURE_VERSION_ATTR begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_structure_version_attr;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Lock row

    --check if there is error
--    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--      x_msg_count := FND_MSG_PUB.count_msg;
--      IF x_msg_count = 1 then
--        pa_interface_utils_pub.get_messages
--         (p_encoded        => FND_API.G_TRUE,
--          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
--          p_data           => l_data,
--          p_msg_index_out  => l_msg_index_out);
--         x_msg_data := l_data;
--      END IF;
--      raise FND_API.G_EXC_ERROR;
--    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Update_Structure_Version_Attr(
    p_api_version                => p_api_version
   ,p_init_msg_list              => p_init_msg_list
   ,p_commit                     => p_commit
   ,p_validate_only              => p_validate_only
   ,p_validation_level           => p_validation_level
   ,p_calling_module             => p_calling_module
   ,p_debug_mode                 => p_debug_mode
   ,p_max_msg_count              => p_max_msg_count
   ,p_pev_structure_id	         => p_pev_structure_id
   ,p_structure_version_name     => p_structure_version_name
   ,p_structure_version_desc	   => p_structure_version_desc
   ,p_effective_date	         => p_effective_date
   ,p_latest_eff_published_flag  => p_latest_eff_published_flag
   ,p_locked_status_code	   => p_locked_status_code
   ,p_struct_version_status_code => p_struct_version_status_code
   ,p_baseline_current_flag	   => p_baseline_current_flag
   ,p_baseline_original_flag     => p_baseline_original_flag
   ,p_change_reason_code         => p_change_reason_code
   ,p_record_version_number      => p_record_version_number
   ,p_current_working_ver_flag   => p_current_working_ver_flag
   ,x_return_status              => x_return_status
   ,x_msg_count                  => x_msg_count
   ,x_msg_data                   => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.UPDATE_STRUCTURE_VERSION_ATTR END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_version_attr;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_version_attr;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'Update_Structure_Version_Attr',
                              p_error_text     => x_msg_data) ;  -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_version_attr;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'Update_Structure_Version_Attr',
                              p_error_text     => x_msg_data); -- 4537865
      raise;
  END Update_Structure_Version_Attr;


-- API name                      : Delete_Structure_Version
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id              IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--
--  25-May-07   Ram Namburi       6046307 Enhanced this to delete published structure versions
--                                using this AMG API.
--  10-Jul-07    kkorada          Bug # 6023347: Added a new parameter p_calling_from in Delete_Structure_Version procedure


  procedure Delete_Structure_Version
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_calling_from                      IN  VARCHAR2    := 'XYZ' ---Added for bug 6023347
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Structure_Version';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;

    l_dummy                VARCHAR2(1);
    l_error_message_code   VARCHAR2(250);

    CURSOR get_struc_ver IS
           select pev.project_id, pe.proj_element_id, pe.record_version_number,
                  pev.element_version_id, pev.record_version_number,
                  pevs.pev_structure_id, pevs.record_version_number,
                  pevsh.pev_schedule_id, pevsh.record_version_number,
                  pevsh.rowid
             from pa_proj_elements pe,
                  pa_proj_element_versions pev,
                  pa_proj_elem_ver_structure pevs,
                  pa_proj_elem_ver_schedule pevsh
            where pev.element_version_id = p_structure_version_id and
                  pev.proj_element_id = pe.proj_element_id and
                  pev.project_id = pevs.project_id and
                  pev.element_version_id = pevs.element_version_id and
                  pev.project_id = pevsh.project_id (+) and
                  pev.element_version_id = pevsh.element_version_id (+);

    CURSOR is_last_version(p_structure_id NUMBER) IS
           select 'N'
             from pa_proj_element_versions
            where proj_element_id = p_structure_id;

    CURSOR get_top_tasks IS
           select v.element_version_id
             from pa_proj_element_versions v,
                  pa_object_relationships r
            where v.element_version_id = r.object_id_to1
              and r.object_id_from1 = p_structure_version_id
              and r.object_type_from = 'PA_STRUCTURES';

    cursor sel_wp_attr(c_proj_element_id NUMBER) IS
      select record_version_number
        from pa_proj_workplan_attr
       where proj_element_id = c_proj_element_id;

    l_project_id          PA_PROJ_ELEMENT_VERSIONS.PROJECT_ID%TYPE;
    l_proj_element_id     PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
    l_pe_rvn              PA_PROJ_ELEMENTS.RECORD_VERSION_NUMBER%TYPE;
    l_element_version_id  PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
    l_pev_rvn             PA_PROJ_ELEMENT_VERSIONS.RECORD_VERSION_NUMBER%TYPE;
    l_pev_structure_id    PA_PROJ_ELEM_VER_STRUCTURE.PEV_STRUCTURE_ID%TYPE;
    l_pevs_rvn            PA_PROJ_ELEM_VER_STRUCTURE.RECORD_VERSION_NUMBER%TYPE;
    l_pev_schedule_id     PA_PROJ_ELEM_VER_SCHEDULE.PEV_SCHEDULE_ID%TYPE;
    l_pevsh_rvn           PA_PROJ_ELEM_VER_SCHEDULE.RECORD_VERSION_NUMBER%TYPE;
    l_pevsh_rowid         VARCHAR2(255);

    l_task_version_id     PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
    l_task_rvn            PA_PROJ_ELEMENT_VERSIONS.RECORD_VERSION_NUMBER%TYPE;
    l_wp_attr_rvn         PA_PROJ_WORKPLAN_ATTR.RECORD_VERSION_NUMBER%TYPE;

    l_parent_struc_ver_id PA_PROJ_ELEMENT_VERSIONS.PARENT_STRUCTURE_VERSION_ID%TYPE;
    l_structure_type      pa_structure_types.STRUCTURE_TYPE_CLASS_CODE%TYPE; --Amit

     -- SWM/IPM enhancement merger into R12.
     -- Bug 6046307
     l_strucutre_status   PA_PROJ_ELEM_VER_STRUCTURE.STATUS_CODE%TYPE;
     l_str SYSTEM.PA_NUM_TBL_TYPE;
     l_rvn SYSTEM.PA_NUM_TBL_TYPE;
     i           BINARY_INTEGER := 0;


  BEGIN
    pa_debug.init_err_stack('PA_PROJECT_STRUCTURE_PUB1.Delete_Structure_Version');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.DELETE_STRUCTURE_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_structure_version;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('get structure version_info');
    END IF;

    --Delete logic
    --Get structure version information
    OPEN get_struc_ver;
    FETCH get_struc_ver INTO l_project_id,
                             l_proj_element_id,
                             l_pe_rvn,
                             l_element_version_id,
                             l_pev_rvn,
                             l_pev_structure_id,
                             l_pevs_rvn,
                             l_pev_schedule_id,
                             l_pevsh_rvn,
                             l_pevsh_rowid;
    IF (get_struc_ver%NOTFOUND) THEN
      CLOSE get_struc_ver;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE get_struc_ver;

   -- SWM/IPM enhancement merger into R12.
   -- Bug 6046307
   -- Exisint code deletes working structure versions only. In order to delete published versions
   -- we need to branch the code and call the newly created API DELETE_PUBLISHED_STRUCTURE_VER
   -- If the version is working then go with the existing code and if the version is published
   -- use the new API.

   -- Though we are deleting a single version here the delete published version was designed for deletion
   -- of multiple versions. So the AMG API also can be enhanced in the future to delete multiple
   -- structure versions in one shot.

   -- The only issue here is the p_commit parameter. Even if the end user wants to commit the changes
   -- by passing the p_commit as true I do not see any changes which commits the data.
   -- The following piece of code doesnt issue a commit, so I am leaving the commit responsiblity
   -- to the Delete_Structure_Version API.
   -- Ideally there should be a commit statement at the end basing on the p_commit parameter value.
   --
   -- This should be treated as a bug and should be taken care of.

   IF l_strucutre_status = 'STRUCTURE_PUBLISHED' THEN
   i := i+1;
   l_str := SYSTEM.PA_NUM_TBL_TYPE(1);
   l_rvn := SYSTEM.PA_NUM_TBL_TYPE(1);

   l_str(1) := p_structure_version_id;
   l_rvn(1) := p_record_version_number;

   PA_PROJECT_STRUCTURE_PUB1.DELETE_PUBLISHED_STRUCTURE_VER(
   p_api_version                      => p_api_version
   ,p_init_msg_list                    => p_init_msg_list
   ,p_project_id                       => l_project_id
   ,p_structure_version_id_tbl         => l_str
   ,p_record_version_number_tbl        => l_rvn
   ,x_return_status                    => l_return_status
   ,x_msg_count                        => l_msg_count
   ,x_msg_data                         => l_msg_data);

   -- Checking the return status.
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count = 1 then
   pa_interface_utils_pub.get_messages
   (p_encoded        => FND_API.G_TRUE,
   p_msg_index      => 1,
   p_data           => l_data,
   p_msg_index_out  => l_msg_index_out);
   x_msg_data := l_data;
   END IF;
   raise FND_API.G_EXC_ERROR;
   END IF;


   ELSE  -- Not a published structure version. Going with the existing regular flow.

    --Check delete structure version ok
    PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(l_project_id,
                                                             p_structure_version_id,
                                                             l_return_status,
                                                             l_error_message_code);
    IF (l_return_status <> 'S') THEN
      PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
      x_msg_data := l_error_message_code;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 4369486 : Added this check : If this is the  last working structure version,we wont be allowed to delete it.

    IF ('N' = PA_PROJECT_STRUCTURE_UTILS.check_del_work_struc_ver_ok(p_structure_version_id)) THEN
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_DEL_WK_STRUC_VER_ERR');
      x_msg_data := 'PA_PS_DEL_WK_STRUC_VER_ERR';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
   -- End of Code Change for 4369486

    --NO ERROR, call delete_task
    --select all top level tasks
    OPEN get_top_tasks;
    LOOP
      FETCH get_top_tasks into l_task_version_id;
      EXIT WHEN get_top_tasks%NOTFOUND;
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('deleting task version '||to_char(l_task_version_id));
      END IF;

      --Get record version number for task, as it will change everytime
      --a task is deleted.
      select record_version_number, parent_structure_version_id
      into l_task_rvn, l_parent_struc_ver_id
      from pa_proj_element_versions
      where element_version_id = l_task_version_id;

      PA_TASK_PUB1.DELETE_TASK_VERSION(p_commit => 'N',
                                       p_debug_mode => p_debug_mode,
                                       p_structure_version_id => l_parent_struc_ver_id,
                                       p_task_version_id => l_task_version_id,
                                       p_record_version_number => l_task_rvn,
                                       p_called_from_api => 'DELETE_STRUCTURE_VERSION',  -- Bug 3056077
				       p_calling_from => p_calling_from,  -- Bug 6023347
                                       x_return_status => l_return_status,
                                       x_msg_count => l_msg_count,
                                       x_msg_data => l_msg_data);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 then
           pa_interface_utils_pub.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
        END IF;
        CLOSE get_top_tasks;
        raise FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE get_top_tasks;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('done deleting tasks');
    END IF;
    --If all tasks are deleted, delete schedule if workplan
    --Check if this is workplan

    -- Amit : Added IF condition below
    IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN') = 'Y') THEN
	l_structure_type := 'WORKPLAN';
    ELSE
      	l_structure_type := 'FINANCIAL';
    END IF;

    If (l_structure_type = 'WORKPLAN') THEN
       --Structure type exists. Delete from schedule table
       IF (p_debug_mode = 'Y') THEN
         pa_debug.debug('WORKPLAN type');
       END IF;
       PA_PROJ_ELEMENT_SCH_PKG.Delete_Row(l_pevsh_rowid);

    END IF;

    --check for errors.
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('del structure version attr');
    END IF;
    --Delete structure version attribute
    PA_PROJECT_STRUCTURE_PVT1.Delete_Structure_Version_Attr(
                        p_commit => p_commit,
                        p_debug_mode => p_debug_mode,
                        p_pev_structure_id => l_pev_structure_id,
                        p_record_version_number => l_pevs_rvn,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;


    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('del structure version');
    END IF;

    --Delete structure version
    PA_PROJECT_STRUCTURE_PVT1.Delete_Structure_Version(
                        p_commit => p_commit,
                        p_debug_mode => p_debug_mode,
                        p_structure_version_id => l_element_version_id,
                        p_record_version_number => l_pev_rvn,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;


    --Delete structure if this is the last version
    OPEN is_last_version(l_proj_element_id);
    FETCH is_last_version into l_dummy;
    IF is_last_version%NOTFOUND THEN
      --We are deleting the last version. Delete structure
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('delete non-versioned structure');
      END IF;

      IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(l_proj_element_id, 'WORKPLAN') = 'Y') THEN
        --delete workplan attribute
        OPEN sel_wp_attr(l_proj_element_id);
        FETCH sel_wp_attr into l_wp_attr_rvn;
        CLOSE sel_wp_attr;

        PA_WORKPLAN_ATTR_PUB.DELETE_PROJ_WORKPLAN_ATTRS(
          p_validate_only => FND_API.G_FALSE
         ,p_project_id => l_project_id
         ,p_proj_element_id => l_proj_element_id
         ,p_record_version_number => l_wp_attr_rvn
         ,x_return_status => l_return_status
         ,x_msg_count => l_msg_count
         ,x_msg_data => l_msg_data
        );

        --Check error
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF x_msg_count = 1 then
             pa_interface_utils_pub.get_messages
             (p_encoded        => FND_API.G_TRUE,
              p_msg_index      => 1,
              p_data           => l_data,
              p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
          END IF;
          raise FND_API.G_EXC_ERROR;
        END IF;

        PA_PROGRESS_PUB.DELETE_PROJ_PROG_ATTR(
          p_validate_only        => FND_API.G_FALSE
         ,p_project_id           => l_project_id
         ,P_OBJECT_TYPE          => 'PA_STRUCTURES'
         ,p_object_id            => l_proj_element_id
	 ,p_structure_type        => l_structure_type --Amit
         ,x_return_status        => l_return_status
         ,x_msg_count            => l_msg_count
         ,x_msg_data             => l_msg_data
        );

        --Check error
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF x_msg_count = 1 then
             pa_interface_utils_pub.get_messages
             (p_encoded        => FND_API.G_TRUE,
              p_msg_index      => 1,
              p_data           => l_data,
              p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
          END IF;
          raise FND_API.G_EXC_ERROR;
        END IF;

      END IF;

      select record_version_number into l_pe_rvn
      from pa_proj_elements where proj_element_id = l_proj_element_id;
      PA_PROJECT_STRUCTURE_PVT1.Delete_Structure(
                        p_commit => p_commit,
                        p_debug_mode => p_debug_mode,
                        p_structure_id => l_proj_element_id,
                        p_record_version_number => l_pe_rvn,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data);

    END IF;
    CLOSE is_last_version;

    --Check error
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.DELETE_STRUCTURE_VERSION end');
    END IF;

  END IF; --  End of IF l_strucutre_status = 'STRUCTURE_PUBLISHED' THEN

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
        rollback to delete_structure_version;
      end if;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
        rollback to delete_structure_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'Delete_Structure_Version',
                              p_error_text     => x_msg_data); -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_structure_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'Delete_Structure_Version',
                              p_error_text     => x_msg_data); -- 4537865
      raise;
  END DELETE_STRUCTURE_VERSION;


-- API name                      : Publish_Structure
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_responsibility_id                 IN  NUMBER      := 0
--   p_structure_version_id              IN  NUMBER
--   p_publish_structure_ver_name        IN  VARCHAR2
--   p_structure_ver_desc                IN  VARCHAR2	   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_original_baseline_flag            IN  VARCHAR2	   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_current_baseline_flag             IN  VARCHAR2	   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_published_struct_ver_id           OUT  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Publish_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_responsibility_id                 IN  NUMBER      := 0
   ,p_user_id                           IN  NUMBER      := NULL
   ,p_structure_version_id              IN  NUMBER
   ,p_publish_structure_ver_name        IN  VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_ver_desc                IN  VARCHAR2	  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_original_baseline_flag            IN  VARCHAR2	  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_current_baseline_flag             IN  VARCHAR2	  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_pub_prog_flag                     IN  VARCHAR2 DEFAULT 'Y'  -- Added for FP_M changes 3420093
   ,x_published_struct_ver_id           OUT  NOCOPY NUMBER	 --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'Publish_Structure';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);--Bug 5059828. Changed the precision to 2000
    l_data                          VARCHAR2(2000);--Bug 5059828. Changed the precision to 2000
    l_msg_index_out                 NUMBER;
    l_project_id                    NUMBER;
    l_record_version_number         NUMBER;
    l_conc_req_id                   NUMBER;  -- Bug 8347243

    cursor c2(c_project_id NUMBER, c_structure_version_id NUMBER) IS
      select record_version_number
        from pa_proj_elem_ver_structure
       where project_id = c_project_id
         and element_version_id = c_structure_version_id;

    CURSOR c1 IS
      select project_id
        from pa_proj_element_versions
       where element_version_id = p_structure_version_id;

  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.PUBLISH_STRUCTURE');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.PUBLISH_STRUCTURE begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint publish_structure;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Check if this structure can be published (ie, if linked structures are published)
	    IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.Check_Publish_Struc_Ver_Ok(p_structure_version_id)) THEN
	      PA_UTILS.ADD_MESSAGE('PA','PA_PS_OTHER_WORKING_LOCKED');
	      x_msg_data := 'PA_PS_OTHER_WORKING_LOCKED';
	      RAISE FND_API.G_EXC_ERROR;
	    END IF;


	    --Call private API
	    PA_PROJECT_STRUCTURE_PVT1.Publish_Structure(
	    p_api_version                      => p_api_version
	   ,p_init_msg_list                    => p_init_msg_list
	   ,p_commit                           => p_commit
	   ,p_validate_only                    => p_validate_only
	   ,p_validation_level                 => p_validation_level
	   ,p_calling_module                   => p_calling_module
	   ,p_debug_mode                       => p_debug_mode
	   ,p_max_msg_count                    => p_max_msg_count
	   ,p_responsibility_id                => p_responsibility_id
	   ,p_user_id                          => p_user_id
	   ,p_structure_version_id             => p_structure_version_id
	   ,p_publish_structure_ver_name       => p_publish_structure_ver_name
	   ,p_structure_ver_desc               => p_structure_ver_desc
	   ,p_effective_date                   => p_effective_date
	   ,p_original_baseline_flag           => p_original_baseline_flag
	   ,p_current_baseline_flag            => p_current_baseline_flag
	   ,p_pub_prog_flag                    => p_pub_prog_flag
	   ,x_published_struct_ver_id          => x_published_struct_ver_id
	   ,x_return_status                    => l_return_status
	   ,x_msg_count                        => l_msg_count
	   ,x_msg_data                         => l_msg_data
	    );

	--    error_msg('public --> '||l_return_status||l_msg_count||l_msg_data);

	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      x_msg_count := FND_MSG_PUB.count_msg;
	      IF x_msg_count = 1 then
		 pa_interface_utils_pub.get_messages
		 (p_encoded        => FND_API.G_TRUE,
		  p_msg_index      => 1,
	--          p_msg_count      => l_msg_count,
	--          p_msg_data       => l_msg_data,
		  p_data           => l_data,
		  p_msg_index_out  => l_msg_index_out);
		 x_msg_data := l_data;
	--         error_msg('public --> '||x_msg_data||', '||l_msg_data);
	      END IF;
	      raise FND_API.G_EXC_ERROR;
	    END IF;

	    -- Bug 8347243 : Workflow notification here should happen only in ONLINE mode. For CONCURRENT mode
	    -- workflow notification will be initiated from PA_PROJ_TASK_STRUC_PUB.PROCESS_WBS_UPDATES_CONC
	    -- We will get concurrent id here to determine if this is ONLINE or CONCURRENT mode

	    OPEN c1;
	    FETCH c1 into l_project_id;
	    CLOSE c1;

	    -- Bug 8347243
	    select conc_request_id INTO l_conc_req_id
	    from pa_proj_elem_ver_structure
	    where element_version_id = p_structure_version_id
	    and project_id = l_project_id;

	  IF l_conc_req_id is null THEN  -- Bug 8347243 --Bug#9628640

	    --start workflow

	    OPEN c2(l_project_id, x_published_struct_ver_id);
	    FETCH c2 into l_record_version_number;
	    CLOSE c2;

	-- FP M : 3491609 : Project Execution Workflow
	    PA_PROJECT_STRUCTURE_PVT1.change_workplan_status
	    (
	      p_project_id              => l_project_id
	     ,p_structure_version_id    => x_published_struct_ver_id
	     ,p_status_code             => 'STRUCTURE_PUBLISHED'
	     ,p_record_version_number   => l_record_version_number
	     ,x_return_status           => l_return_status
	     ,x_msg_count               => l_msg_count
	     ,x_msg_data                => l_msg_data
	    );

	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      x_msg_count := FND_MSG_PUB.count_msg;
	      IF x_msg_count = 1 then
		 pa_interface_utils_pub.get_messages
		 (p_encoded        => FND_API.G_TRUE,
		  p_msg_index      => 1,
	--          p_msg_count      => l_msg_count,
	--          p_msg_data       => l_msg_data,
		  p_data           => l_data,
		  p_msg_index_out  => l_msg_index_out);
		 x_msg_data := l_data;
	--         error_msg('public --> '||x_msg_data||', '||l_msg_data);
	      END IF;
	      raise FND_API.G_EXC_ERROR;
	    END IF;

	-- FP M : 3491609 : Project Execution Workflow
	     PA_WORKPLAN_WORKFLOW.START_PROJECT_EXECUTION_WF
	       (
		 p_project_id    => l_project_id
		,x_msg_count     => l_msg_count
		,x_msg_data      => l_msg_data
		,x_return_status => l_return_status
	       ) ;

	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      x_msg_count := FND_MSG_PUB.count_msg;
	      IF x_msg_count = 1 then
		 pa_interface_utils_pub.get_messages
		 (p_encoded        => FND_API.G_TRUE,
		  p_msg_index      => 1,
		  p_data           => l_data,
		  p_msg_index_out  => l_msg_index_out);
		 x_msg_data := l_data;
	      END IF;
	      raise FND_API.G_EXC_ERROR;
	    END IF;

	-- FP M : 3491609 : Project Execution Workflow
	    x_return_status := FND_API.G_RET_STS_SUCCESS;

	  END IF;  -- Bug 8347243

	    IF (p_commit = FND_API.G_TRUE) THEN
	      COMMIT;
	    END IF;

	    IF (p_debug_mode = 'Y') THEN
	      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.PUBLISH_STRUCTURE end');
	    END IF;

	  EXCEPTION
	    when FND_API.G_EXC_ERROR then
	      if p_commit = FND_API.G_TRUE then
		 rollback to publish_structure;
	      end if;
	      x_return_status := FND_API.G_RET_STS_ERROR;

	      x_published_struct_ver_id := NULL ; -- 4537865
	    when FND_API.G_EXC_UNEXPECTED_ERROR then
	      if p_commit = FND_API.G_TRUE then
		 rollback to publish_structure;
	      end if;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      -- 4537865
	      x_msg_count := 1 ;
	      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
	      x_published_struct_ver_id := NULL ;
	      -- 4537865

	      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
				      p_procedure_name => 'PUBLISH_STRUCTURE',
				      p_error_text     => x_msg_data); -- 4537865
	    when OTHERS then
	      if p_commit = FND_API.G_TRUE then
		 rollback to publish_structure;
	      end if;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      -- 4537865
	      x_msg_count := 1 ;
	      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
	      x_published_struct_ver_id := NULL ;
	      -- 4537865

	      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
				      p_procedure_name => 'PUBLISH_STRUCTURE',
				      p_error_text     => x_msg_data); -- 4537865
	      raise;
	 END Publish_Structure;


	-- API name                      : Copy_Structure
	-- Type                          : Public Procedure
	-- Pre-reqs                      : None
	-- Return Value                  : N/A
	-- Parameters
	--   p_api_version                       IN  NUMBER      := 1.0
	--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
	--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
	--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
	--   p_validation_level                  IN  VARCHAR2    := 100
	--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
	--   p_debug_mode                        IN  VARCHAR2    := 'N'
	--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
	--   p_src_project_id                    IN  NUMBER
	--   p_dest_project_id                   IN  NUMBER
	--   p_delta                             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
	--   x_return_status                     OUT  VARCHAR2
	--   x_msg_count                         OUT  NUMBER
	--   x_msg_data                          OUT  VARCHAR2
	--
	--  History
	--
	--  25-JUN-01   HSIU             -Created
	--
	--


	  procedure Copy_Structure
	  (
	   p_api_version                       IN  NUMBER      := 1.0
	   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
	   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
	   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
	   ,p_validation_level                  IN  VARCHAR2    := 100
	   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
	   ,p_debug_mode                        IN  VARCHAR2    := 'N'
	   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
	   ,p_src_project_id                    IN  NUMBER
	   ,p_dest_project_id                   IN  NUMBER
	-- anlee
	-- Dates changes
	   ,p_delta                             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
	-- End of changes
	   ,p_copy_task_flag                    IN  VARCHAR2    := 'Y'
	   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
	   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	  )
	  IS
	  l_api_name                      CONSTANT VARCHAR(30) := 'COPY_STRUCTURE';
	  l_api_version                   CONSTANT NUMBER      := 1.0;

	  l_return_status                 VARCHAR2(1);
	  l_msg_count                     NUMBER;
	  l_msg_data                      VARCHAR2(250);
	  l_data                          VARCHAR2(250);
	  l_msg_index_out                 NUMBER;
	BEGIN

	  pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.COPY_STRUCTURE');

	  IF (p_debug_mode = 'Y') THEN
	    pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.COPY_STRUCTURE begin');
	  END IF;

	  IF (p_commit = FND_API.G_TRUE) THEN
	    savepoint copy_structure;
	  END IF;

	  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
	    FND_MSG_PUB.initialize;
	  END IF;

	  PA_PROJECT_STRUCTURE_PVT1.Copy_Structure
	  ( p_commit                => FND_API.G_FALSE
	   ,p_validate_only         => p_validate_only
	   ,p_validation_level      => p_validation_level
	   ,p_calling_module        => p_calling_module
	   ,p_debug_mode            => p_debug_mode
	   ,p_max_msg_count         => p_max_msg_count
	   ,p_src_project_id        => p_src_project_id
	   ,p_dest_project_id       => p_dest_project_id
	-- anlee
	-- Dates changes
	   ,p_delta                 => p_delta
	-- End of changes
	   ,p_copy_task_flag        => p_copy_task_flag
	   ,x_return_status         => l_return_status
	   ,x_msg_count             => l_msg_count
	   ,x_msg_data              => l_msg_data);

	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    x_msg_count := FND_MSG_PUB.count_msg;
	    IF x_msg_count = 1 then
	      pa_interface_utils_pub.get_messages
	      (p_encoded        => FND_API.G_TRUE,
	       p_msg_index      => 1,
	--       p_msg_count      => l_msg_count,
	--       p_msg_data       => l_msg_data,
	       p_data           => l_data,
	       p_msg_index_out  => l_msg_index_out);
	      x_msg_data := l_data;
	    END IF;
	    raise FND_API.G_EXC_ERROR;
	  END IF;

	  x_return_status := FND_API.G_RET_STS_SUCCESS;

	  IF (p_commit = FND_API.G_TRUE) THEN
	    COMMIT;
	  END IF;

	  IF (p_debug_mode = 'Y') THEN
	    pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.COPY_STRUCTURE END');
	  END IF;

	EXCEPTION
	  when FND_API.G_EXC_ERROR then
	    if p_commit = FND_API.G_TRUE then
	      rollback to copy_structure;
	    end if;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	  when FND_API.G_EXC_UNEXPECTED_ERROR then
	    if p_commit = FND_API.G_TRUE then
	      rollback to copy_structure;
	    end if;
	      -- 4537865
	      x_msg_count := 1 ;
	      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
	      -- 4537865
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
				    p_procedure_name => 'COPY_STRUCTURE',
				    p_error_text     => x_msg_data);  -- 4537865
	  when OTHERS then
	    if p_commit = FND_API.G_TRUE then
	      rollback to copy_structure;
	    end if;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      -- 4537865
	      x_msg_count := 1 ;
	      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
	      -- 4537865
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                            p_procedure_name => 'COPY_STRUCTURE',
                            p_error_text     => x_msg_data);  -- 4537865
    raise;
  END Copy_Structure;


-- API name                      : Copy_Structure_Version
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id              IN  NUMBER
--   p_new_struct_ver_name               IN  VARCHAR2
--   p_new_struct_ver_desc               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_new_struct_ver_id                 OUT  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Copy_Structure_Version
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_new_struct_ver_name               IN  VARCHAR2
   ,p_new_struct_ver_desc               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_change_reason_code                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_new_struct_ver_id                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
  l_api_name                      CONSTANT VARCHAR(30) := 'COPY_STRUCTURE_VERSION';
  l_api_version                   CONSTANT NUMBER      := 1.0;

  l_new_struct_ver_id             PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_data                          VARCHAR2(250);
  l_msg_index_out                 NUMBER;
BEGIN

  pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.COPY_STRUCTURE_VERSION');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.COPY_STRUCTURE_VERSION begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint copy_structure_version;
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  PA_PROJECT_STRUCTURE_PVT1.Copy_Structure_Version_bulk
  ( p_commit                => FND_API.G_FALSE
   ,p_validate_only         => p_validate_only
   ,p_validation_level      => p_validation_level
   ,p_calling_module        => p_calling_module
   ,p_debug_mode            => p_debug_mode
   ,p_max_msg_count         => p_max_msg_count
   ,p_structure_version_id  => p_structure_version_id
   ,p_new_struct_ver_name   => p_new_struct_ver_name
   ,p_new_struct_ver_desc   => p_new_struct_ver_desc
   ,p_change_reason_code    => p_change_reason_code
   ,x_new_struct_ver_id     => l_new_struct_ver_id
   ,x_return_status         => l_return_status
   ,x_msg_count             => l_msg_count
   ,x_msg_data              => l_msg_data);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count = 1 then
      pa_interface_utils_pub.get_messages
      (p_encoded        => FND_API.G_TRUE,
       p_msg_index      => 1,
--       p_msg_count      => l_msg_count,
--       p_msg_data       => l_msg_data,
       p_data           => l_data,
       p_msg_index_out  => l_msg_index_out);
      x_msg_data := l_data;
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

  x_new_struct_ver_id := l_new_struct_ver_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.COPY_STRUCTURE_VERSION END');
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_new_struct_ver_id := NULL ;  -- 4537865
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      x_new_struct_ver_id := NULL ;
      -- 4537865
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                            p_procedure_name => 'COPY_STRUCTURE_VERSION',
                            p_error_text     => x_msg_data); -- 4537865
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      x_new_struct_ver_id := NULL ;
      -- 4537865
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                            p_procedure_name => 'COPY_STRUCTURE_VERSION',
                            p_error_text     => x_msg_data); -- 4537865
    raise;
  END Copy_Structure_Version;


procedure SUBMIT_WORKPLAN
(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_id                      IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,p_responsibility_id                 IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
    l_api_name                      CONSTANT VARCHAR(30) := 'SUBMIT_WORKPLAN';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_project_id                    NUMBER;
BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.SUBMIT_WORKPLAN');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.SUBMIT_WORKPLAN begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint submit_workplan;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Check if this structure can be published (ie, if linked structures are published)
    IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.Check_Publish_Struc_Ver_Ok(p_structure_version_id)) THEN
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_OTHER_WORKING_LOCKED');
      x_msg_data := 'PA_PS_OTHER_WORKING_LOCKED';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.SUBMIT_WORKPLAN(
      p_api_version            => p_api_version
     ,p_commit                 => p_commit
     ,p_validate_only          => p_validate_only
     ,p_validation_level       => p_validation_level
     ,p_calling_module         => p_calling_module
     ,p_debug_mode             => p_debug_mode
     ,p_max_msg_count          => p_max_msg_count
     ,p_project_id             => p_project_id
     ,p_structure_id           => p_structure_id
     ,p_structure_version_id   => p_structure_version_id
     ,p_responsibility_id      => p_responsibility_id
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data
    );

    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0) THEN
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

     --call private API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.SUBMIT_WORKPLAN end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to submit_workplan;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to submit_workplan;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'SUBMIT_WORKPLAN',
                              p_error_text     => x_msg_data); -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to submit_workplan;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'SUBMIT_WORKPLAN',
                              p_error_text     => x_msg_data);  -- 4537865
      raise;
END SUBMIT_WORKPLAN;


  PROCEDURE rework_workplan
  (
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'REWORK_WORKPLAN';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_project_id                    NUMBER;
  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.REWORK_WORKPLAN');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.REWORK_WORKPLAN begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint rework_workplan;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.REWORK_WORKPLAN(
      p_api_version           => 1.0
     ,p_commit                => p_commit
     ,p_validate_only         => p_validate_only
     ,p_validation_level      => p_validation_level
     ,p_calling_module        => p_calling_module
     ,p_debug_mode            => p_debug_mode
     ,p_max_msg_count         => p_max_msg_count
     ,p_project_id            => p_project_id
     ,p_structure_version_id  => p_structure_version_id
     ,p_record_version_number => p_record_version_number
     ,x_return_status         => x_return_status
     ,x_msg_count             => x_msg_count
     ,x_msg_data              => x_msg_data
    );

    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0) THEN
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.REWORK_WORKPLAN end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to rework_workplan;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to rework_workplan;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'REWORK_WORKPLAN',
                              p_error_text     => x_msg_data); -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to rework_workplan;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'REWORK_WORKPLAN',
                              p_error_text     =>  x_msg_data); -- 4537865
      raise;
  END rework_workplan;


-- API name                      : update_structures_setup_attr
-- Type                             : Update API
-- Pre-reqs                       : None
-- Return Value                 : Update_structures_setup_attr
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_workplan_enabled_flag IN VARCHAR2
--  p_financial_enabled_flag IN VARCHAR2
--  p_sharing_enabled_flag IN VARCHAR2
    --FP M changes bug 3301192
--    p_deliverables_enabled_flag       IN VARCHAR2
--    p_sharing_option_code             IN VARCHAR2
    --End FP M changes bug 3301192
--  p_sys_program_flag  IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--  p_allow_multi_prog_rollup IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--  x_return_status OUT VARCHAR2
--  x_msg_count OUT NUMBER
--  x_msg_data  OUT VARCHAR2
--
--  History
--
--  26-JUL-02   HSIU             -Created
--  30-Mar-04   JYAN             added p_sys_program_flag and p_allow_multi_prog_rollup
--
  PROCEDURE update_structures_setup_attr
  (  p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id IN NUMBER
    ,p_workplan_enabled_flag IN VARCHAR2
    ,p_financial_enabled_flag IN VARCHAR2
    ,p_sharing_enabled_flag IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --FP M changes bug 3301192
    ,p_deliverables_enabled_flag       IN VARCHAR2
    ,p_sharing_option_code             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --End FP M changes bug 3301192
    ,p_sys_program_flag  IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_allow_multi_prog_rollup IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_STRUCTURES_SETUP_ATTR';
    l_api_version                   CONSTANT NUMBER      := 1.0;
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;

  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.update_structures_setup_attr');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.update_structures_setup_attr begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_struc_setup_attr_pub;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.UPDATE_STRUCTURES_SETUP_ATTR(
     p_api_version      => p_api_version
    ,p_init_msg_list    => p_init_msg_list
    ,p_commit           => p_commit
    ,p_validate_only    => p_validate_only
    ,p_validation_level => p_validation_level
    ,p_calling_module   => p_calling_module
    ,p_debug_mode       => p_debug_mode
    ,p_max_msg_count    => p_max_msg_count
    ,p_project_id       => p_project_id
    ,p_workplan_enabled_flag => p_workplan_enabled_flag
    ,p_financial_enabled_flag => p_financial_enabled_flag
    ,p_sharing_enabled_flag => 'N' --p_sharing_enabled_flag
    ,p_deliverables_enabled_flag => p_deliverables_enabled_flag
    ,p_sharing_option_code  => p_sharing_option_code
    ,p_sys_program_flag => p_sys_program_flag
    ,p_allow_multi_prog_rollup => p_allow_multi_prog_rollup
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data  => x_msg_data
    );

    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0) THEN
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.UPDATE_STRUCTURES_SETUP_ATTR end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_struc_setup_attr_pub;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_struc_setup_attr_pub;
      end if;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'update_structures_setup_attr',
                              p_error_text     => x_msg_data);   -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_struc_setup_attr_pub;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'update_structures_setup_attr',
                              p_error_text     => x_msg_data);   -- 4537865
      raise;
  END update_structures_setup_attr;


  PROCEDURE update_workplan_versioning
  ( p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_proj_element_id  IN  NUMBER
    ,p_enable_wp_version_flag IN VARCHAR2
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'update_workplan_versioning';
    l_api_version                   CONSTANT NUMBER      := 1.0;
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;

  BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.update_structures_setup_attr');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.update_structures_setup_attr begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_wp_versioning_pub;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.update_workplan_versioning(
      p_api_version            => p_api_version
     ,p_init_msg_list          => p_init_msg_list
     ,p_commit                 => p_commit
     ,p_validate_only          => p_validate_only
     ,p_validation_level       => p_validation_level
     ,p_calling_module         => p_calling_module
     ,p_debug_mode             => p_debug_mode
     ,p_max_msg_count          => p_max_msg_count
     ,p_proj_element_id        => p_proj_element_id
     ,p_enable_wp_version_flag => p_enable_wp_version_flag
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data
    );

    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0) THEN
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.UPDATE_WORKPLAN_VERSIONING end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_wp_versioning_pub;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_wp_versioning_pub;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'update_workplan_versioning',
                              p_error_text     => x_msg_data);    -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_wp_versioning_pub;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'update_workplan_versioning',
                              p_error_text     => x_msg_data);    -- 4537865
      raise;
  END update_workplan_versioning;

-- API name                      : Delete_Working_Struc_Ver
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id              IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  17-DEC-02   HSIU             -Created
--
--


  procedure Delete_Working_Struc_Ver
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Working_Struc_Ver';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_message_code            VARCHAR2(30);

    CURSOR c1 IS
      select project_id
        from pa_proj_element_versions
       where element_version_id = p_structure_version_id;
    l_project_id                    NUMBER;

  BEGIN
    pa_debug.init_err_stack('PA_PROJECT_STRUCTURE_PUB1.Delete_Working_Struc_Ver');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.DELETE_WORKINGSTRUC_VER begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_working_struc_ver;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    OPEN c1;
    FETCH c1 into l_project_id;
    CLOSE c1;

    --Check if locked
    PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                                  l_project_id
                                 ,p_structure_version_id
                                 ,l_return_status
                                 ,l_error_message_code);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
      x_msg_data := l_error_message_code;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Check if it is ok to delete working version
    IF ('N' = PA_PROJECT_STRUCTURE_UTILS.check_del_work_struc_ver_ok(p_structure_version_id)) THEN
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_DEL_WK_STRUC_VER_ERR');
      x_msg_data := 'PA_PS_DEL_WK_STRUC_VER_ERR';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Delete_Struc_Ver_Wo_Val(p_commit => 'N',
                            p_debug_mode => p_debug_mode,
                            p_structure_version_id => p_structure_version_id,
                            p_record_version_number => p_record_version_number,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.DELETE_STRUCTURE_VERSION end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
        rollback to delete_working_struc_ver;
      end if;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
        rollback to delete_working_struc_ver;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'Delete_Working_Struc_Ver',
                              p_error_text     => x_msg_data);  -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_working_struc_ver;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'Delete_Working_Struc_Ver',
                              p_error_text     => x_msg_data);  -- 4537865
      raise;
  END DELETE_WORKING_STRUC_VER;

 procedure ENABLE_FINANCIAL_STRUCTURE
  (
    p_api_version                       IN  NUMBER   := 1.0
   ,p_init_msg_list                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_validation_level                  IN  NUMBER   := 100
   ,p_calling_module                    IN  VARCHAR2 := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2 := 'N'
   ,p_max_msg_count                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_proj_element_id                   IN  NUMBER
   ,p_approval_reqd_flag                IN  VARCHAR2 DEFAULT 'N'
   ,p_auto_publish_flag                 IN  VARCHAR2 DEFAULT 'N'
   ,p_approver_source_id                IN  NUMBER DEFAULT NULL
   ,p_approver_source_type              IN  NUMBER DEFAULT NULL
   ,p_default_display_lvl               IN  NUMBER DEFAULT 0
   ,p_enable_wp_version_flag            IN  VARCHAR2 DEFAULT 'N'
   ,p_auto_pub_upon_creation_flag       IN  VARCHAR2 DEFAULT 'N'
   ,p_auto_sync_txn_date_flag           IN  VARCHAR2 DEFAULT 'N'
   ,p_txn_date_sync_buf_days            IN  NUMBER DEFAULT NULL
   ,p_lifecycle_version_id              IN  NUMBER DEFAULT NULL
   ,p_current_phase_version_id          IN  NUMBER DEFAULT NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )

IS

   l_api_name                      CONSTANT VARCHAR(30) := 'ENABLE_FINANCIAL_STRUCTURE';
   l_api_version                   CONSTANT NUMBER      := 1.0;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

   l_proj_progress_attr_id	   NUMBER;

BEGIN

    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.ENABLE_FINANCIAL_STRUCTURE');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.ENABLE_FINANCIAL_STRUCTURE begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint ENABLE_FINANCIAL_STRUCTURE;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

   PA_WORKPLAN_ATTR_PVT.CREATE_PROJ_WORKPLAN_ATTRS(
    p_commit                      => p_commit
   ,p_validate_only               => p_validate_only
   ,p_validation_level            => p_validation_level
   ,p_calling_module              => p_calling_module
   ,p_debug_mode                  => p_debug_mode
   ,p_max_msg_count               => p_max_msg_count
   ,p_project_id                  => p_project_id
   ,p_proj_element_id             => p_proj_element_id
   ,p_approval_reqd_flag          => p_approval_reqd_flag
   ,p_auto_publish_flag           => p_auto_publish_flag
   ,p_approver_source_id          => p_approver_source_id
   ,p_approver_source_type        => p_approver_source_type
   ,p_default_display_lvl         => p_default_display_lvl
   ,p_enable_wp_version_flag      => p_enable_wp_version_flag
   ,p_auto_pub_upon_creation_flag => p_auto_pub_upon_creation_flag
   ,p_auto_sync_txn_date_flag     => p_auto_sync_txn_date_flag
   ,p_txn_date_sync_buf_days      => p_txn_date_sync_buf_days
   ,p_lifecycle_version_id        => p_lifecycle_version_id
   ,p_current_phase_version_id    => p_current_phase_version_id
   ,x_return_status               => l_return_status
   ,x_msg_count                   => x_msg_count
   ,x_msg_data                    => x_msg_data
   );

   -- 4537865 : This was missing earlier
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;
  -- End : 4537865
 PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
  p_api_version				=> l_api_version
 ,p_init_msg_list       		=> p_init_msg_list
 ,p_commit              		=> p_commit
 ,p_validate_only       		=> p_validate_only
 ,p_validation_level    		=> p_validation_level
 ,p_calling_module      		=> p_calling_module
 ,p_debug_mode          		=> p_debug_mode
 ,p_max_msg_count       		=> p_max_msg_count
 ,p_project_id          		=> p_project_id
 ,P_OBJECT_TYPE         		=> 'PA_STRUCTURES'
 ,P_OBJECT_ID           		=> p_proj_element_id
 ,P_PROGRESS_CYCLE_ID   		=> to_number(null)
 ,P_WQ_ENABLE_FLAG      		=> 'N'
 ,P_REMAIN_EFFORT_ENABLE_FLAG   	=> 'N'
 ,P_PERCENT_COMP_ENABLE_FLAG    	=> 'Y'
 ,P_NEXT_PROGRESS_UPDATE_DATE   	=> to_date(null)
 ,p_TASK_WEIGHT_BASIS_CODE      	=> 'COST'
 ,X_PROJ_PROGRESS_ATTR_ID       	=> l_proj_progress_attr_id
 ,P_ALLOW_COLLAB_PROG_ENTRY     	=> 'N'
 ,P_ALLW_PHY_PRCNT_CMP_OVERRIDES 	=> 'Y'
 ,p_structure_type                      => 'FINANCIAL' --Amit
 ,x_return_status            		=> l_return_status
 ,x_msg_count        			=> l_msg_count
 ,x_msg_data               		=> l_msg_data
);

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.ENABLE_FINANCIAL_STRUCTURE END');
    END IF;

EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to ENABLE_FINANCIAL_STRUCTURE;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to ENABLE_FINANCIAL_STRUCTURE;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'ENABLE_FINANCIAL_STRUCTURE',
                              p_error_text     => x_msg_data);  -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to ENABLE_FINANCIAL_STRUCTURE;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'ENABLE_FINANCIAL_STRUCTURE',
                              p_error_text     => x_msg_data);   -- 4537865
      raise;

END ENABLE_FINANCIAL_STRUCTURE;



 procedure DISABLE_FINANCIAL_STRUCTURE
  (
    p_api_version                       IN  NUMBER   := 1.0
   ,p_init_msg_list                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_validation_level                  IN  NUMBER := 100
   ,p_calling_module                    IN  VARCHAR2 := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2 := 'N'
   ,p_max_msg_count                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )

IS

   CURSOR C1 IS
      SELECT task_id
      FROM pa_tasks
      WHERE project_id = p_project_id
        AND top_task_id = task_id
        AND parent_task_id is NULL;

   l_task_id                       NUMBER;
   l_parent_structure_id           NUMBER;
   l_parent_structure_version_id   NUMBER;
   l_record_version_number         PA_PROJ_ELEMENT_VERSIONS.RECORD_VERSION_NUMBER%TYPE;
   l_rowid                         VARCHAR2(255);
   l_check_sharing_enabled         VARCHAR(1);
   l_proj_element_id               NUMBER;
   l_api_name                      CONSTANT VARCHAR(30) := 'DISABLE_FINANCIAL_STRUCTURE';
   l_api_version                   CONSTANT NUMBER      := 1.0;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

   l_err_code                           NUMBER                 := 0;
   l_err_stack                          VARCHAR2(630);
   l_err_stage                          VARCHAR2(80);

   CURSOR get_struc_ver_info(c_structure_id NUMBER) IS
     SELECT element_version_id, record_version_number
     FROM pa_proj_element_versions
     where proj_element_id = c_structure_id
     and project_id = p_project_id;

BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DISABLE_FINANCIAL_STRUCTURE;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

   l_check_sharing_enabled := PA_PROJECT_STRUCTURE_UTILS.CHECK_SHARING_ENABLED(p_project_id);

   /* hsiu: added, 3305199 */
   select a.proj_element_id into l_parent_structure_id
   from pa_proj_elements a, pa_proj_structure_types b, pa_structure_types c
   where a.proj_element_id = b.proj_element_id
   and a.project_id = p_project_id
   and b.structure_type_id = c.structure_type_id
   and c.structure_type = 'FINANCIAL';
   /* hsiu: changes end, 3305199 */

   OPEN C1;
 LOOP
    FETCH C1 into l_task_id;
    EXIT when C1%NOTFOUND;

    PA_TASK_UTILS.CHECK_DELETE_TASK_OK(x_task_id     => l_task_id,
                                         x_err_code    => l_err_code,
                                         x_err_stage   => l_err_stage,
                                         x_err_stack   => l_err_stack);
    IF (l_err_code <> 0) THEN
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_CANT_DIS_FN_STR');
        x_msg_data := 'PA_PS_CANT_DIS_FN_STR';
        raise FND_API.G_EXC_ERROR; --Bug No 3517852 SMukka Stop processing and come out of the loop
    ELSE

	/* Amit : Moved the below code outside loop
	select rowid into l_rowid from pa_proj_progress_attr
	where project_id = p_project_id
	and object_id = l_task_id ;


	PA_PROJ_PROGRESS_ATTR_PKG.delete_row(l_rowid);
	*/

        IF (l_check_sharing_enabled = 'Y') THEN
               PA_PROJECT_CORE.DELETE_TASK(x_task_id              => l_task_id,
                                          x_validate_flag        => 'N',
                                          x_err_code             => l_err_code,
                                          x_err_stage            => l_err_stage,
                                          x_err_stack            => l_err_stack);

                UPDATE PA_PROJ_ELEMENT_VERSIONS
                SET FINANCIAL_TASK_FLAG = 'N'
                WHERE PROJECT_ID = p_project_id
                AND PROJ_ELEMENT_ID = l_task_id;
        ELSE
		PA_PROJ_TASK_STRUC_PUB.DELETE_TASK_STRUCTURE(p_calling_module => 'PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE',
                                                             p_project_id => p_project_id,
                                                             p_task_id => l_task_id,
                                                             x_msg_count => l_msg_count,
                                                             x_msg_data => l_msg_data,
                                                             x_return_status => l_return_status);

/* hsiu: 3305199
                SELECT B.PROJ_ELEMENT_ID INTO l_proj_element_id FROM PA_PROJECTS_ALL A,PA_PROJ_STRUCTURE_TYPES B,PA_PROJ_ELEMENTS C
                WHERE A.PROJECT_ID = C.PROJECT_ID
                  AND B.PROJ_ELEMENT_ID = C.PROJ_ELEMENT_ID
                  AND B.PROJ_STRUCTURE_TYPE_ID = 6
                  AND A.PROJECT_ID = P_PROJECT_ID;

		PA_WORKPLAN_ATTR_PVT.DELETE_PROJ_WORKPLAN_ATTRS(p_project_id => p_project_id,
                                                                p_proj_element_id => l_proj_element_id,
                                                                x_msg_count => l_msg_count,
                                                                x_msg_data => l_msg_data,
                                                                x_return_status => l_return_status);
   end changes hsiu 3305199 */
	END IF;
    END IF;
 END LOOP;
    CLOSE C1;

/* hsiu commented 3305199
   SELECT parent_structure_id, parent_structure_version_id into l_parent_structure_id, l_parent_structure_version_id
   FROM PA_STRUCT_TASK_WBS_V
   WHERE task_id = l_task_id;
*/

	select rowid into l_rowid from pa_proj_progress_attr
	where project_id = p_project_id
--	and object_id = l_task_id Amit
	and object_id = l_parent_structure_id --Amit
	AND structure_type = 'FINANCIAL'; --Amit

	PA_PROJ_PROGRESS_ATTR_PKG.delete_row(l_rowid);

   SELECT rowid into l_rowid
   FROM pa_proj_structure_types
   WHERE proj_element_id = l_parent_structure_id
   and STRUCTURE_TYPE_ID = 6;

   PA_PROJ_STRUCTURE_TYPES_PKG.delete_row(l_rowid);

   IF (l_check_sharing_enabled <> 'Y') THEN

        select record_version_number
        INTO l_record_version_number
        from pa_proj_workplan_attr
        where proj_element_id = l_parent_structure_id;

		PA_WORKPLAN_ATTR_PVT.DELETE_PROJ_WORKPLAN_ATTRS(p_validate_only => FND_API.G_FALSE,
                                                                p_project_id => p_project_id,
                                                                p_proj_element_id => l_parent_structure_id,
                                                                p_record_version_number => l_record_version_number,
                                                                x_msg_count => l_msg_count,
                                                                x_msg_data => l_msg_data,
                                                                x_return_status => l_return_status);
   END IF;

/* hsiu commented 3305199
   SELECT record_version_number into l_record_version_number
   FROM pa_proj_element_versions
   WHERE element_version_id = l_parent_structure_version_id;
*/

/*Introducing the following IF CLAUSE For Bug 3938654
  In case of SHARED Case ,What is happening is :
  The 'Only' Structure Version ID that is avaiable(which is shared by both WP and Financial structures)
  is  retrieved by the Cursor get_struc_ver_info , and the Structure Version corresponding to the ID
  is getting deleted .
  It means indirectly the WP structure is also getting deleted .This should not happen .
*/

  IF (l_check_sharing_enabled <> 'Y') THEN -- For Bug 3938654
--hsiu: 3305199
   open get_struc_ver_info(l_parent_structure_id);
   LOOP
     FETCH get_struc_ver_info INTO l_parent_structure_version_id, l_record_version_number;
     EXIT WHEN get_Struc_ver_info%NOTFOUND;

     PA_PROJECT_STRUCTURE_PUB1.DELETE_STRUCTURE_VERSION(
      p_structure_version_id => l_parent_structure_version_id
     ,p_record_version_number => l_record_version_number
     ,x_return_status => l_return_status
     ,x_msg_count => l_msg_count
     ,x_msg_data => l_msg_data
     );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
       END IF;
       raise FND_API.G_EXC_ERROR;
     END IF;
   END LOOP;
   CLOSE get_struc_ver_info;
--hsiu chagnes end: 3305199
  END IF ; --IF CLAUSE introduced for Bug 3938654

/* hsiu 3305199
   SELECT record_version_number into l_record_version_number
   FROM pa_proj_elements
   WHERE proj_element_id = l_parent_structure_id;

   PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUCTURE(
   p_structure_id => l_parent_structure_id
   ,p_record_version_number => l_record_version_number
   ,x_return_status => l_return_status
   ,x_msg_count => l_msg_count
   ,x_msg_data => l_msg_data
);

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;
*/

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE END');
    END IF;

     EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to DISABLE_FINANCIAL_STRUCTURE;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to DISABLE_FINANCIAL_STRUCTURE;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'DISABLE_FINANCIAL_STRUCTURE',
                              p_error_text     => x_msg_data); -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to DISABLE_FINANCIAL_STRUCTURE;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'DISABLE_FINANCIAL_STRUCTURE',
                              p_error_text     => x_msg_data); -- 4537865
      raise;

END DISABLE_FINANCIAL_STRUCTURE;



-- API name                      : Clear_Financial_Flag
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id                        IN  NUMBER
--   p_task_version_id                   IN  NUMBER
--   p_structure_version_id              IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--  02-JAN-04   Rakesh Raghavan             - Created

procedure CLEAR_FINANCIAL_FLAG
  (
    p_api_version                       IN  NUMBER   := 1.0
   ,p_init_msg_list                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_validation_level                  IN  NUMBER := 100
   ,p_calling_module                    IN  VARCHAR2 := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2 := 'N'
   ,p_max_msg_count                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_task_version_id                   IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
IS
   l_return_status                 VARCHAR2(1);
   l_api_name                      CONSTANT VARCHAR(30) := 'CLEAR_FINANCIAL_FLAG';
   l_api_version                   CONSTANT NUMBER      := 1.0;
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
BEGIN

    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.CLEAR_FINANCIAL_FLAG');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CLEAR_FINANCIAL_FLAG begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CLEAR_FINANCIAL_FLAG;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

   IF (p_structure_version_id IS NOT NULL) THEN
	UPDATE PA_PROJ_ELEMENT_VERSIONS
	SET FINANCIAL_TASK_FLAG = 'N'
	WHERE PROJECT_ID = p_project_id
	  AND PARENT_STRUCTURE_VERSION_ID = p_structure_version_id;
   END IF;

   IF (p_task_version_id is NOT NULL) THEN
	UPDATE PA_PROJ_ELEMENT_VERSIONS
	SET FINANCIAL_TASK_FLAG='N'
	WHERE PROJECT_ID = p_project_id
	  AND ELEMENT_VERSION_ID = p_task_version_id;
   END IF;

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CLEAR_FINANCIAL_FLAG END');
    END IF;

EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to CLEAR_FINANCIAL_FLAG;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to CLEAR_FINANCIAL_FLAG;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'CLEAR_FINANCIAL_FLAG',
                              p_error_text     => x_msg_data);  -- 4537865
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to CLEAR_FINANCIAL_FLAG;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'CLEAR_FINANCIAL_FLAG',
                              p_error_text     => x_msg_data);  -- 4537865
      raise;

END CLEAR_FINANCIAL_FLAG;
--
-- API name                      : Update_Sch_Dirty_Flag
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id                        IN  NUMBER
--   p_structure_version_id              IN  NUMBER
--   p_dirty_flag                        IN  VARCHAR2
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
-- History
-- 23-MAR-04   Srikanth Mukka           - Created
--
PROCEDURE Update_Sch_Dirty_Flag
  (
    p_api_version                       IN  NUMBER   := 1.0
   ,p_init_msg_list                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_validation_level                  IN  NUMBER   := 100
   ,p_calling_module                    IN  VARCHAR2 := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2 := 'N'
   ,p_max_msg_count                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,p_dirty_flag                        IN  VARCHAR2 := 'N'
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
--
    l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_SCH_DIRTY_FLAG';
    l_api_version                   CONSTANT NUMBER      := 1.0;
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
--
BEGIN
    pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PUB1.update_sch_dirty_flag');
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.update_sch_dirty_flag begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_sch_dirty_flag_pub;
    END IF;
--
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--
    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;
--
    PA_PROJECT_STRUCTURE_PVT1.Update_Sch_Dirty_Flag(
           p_project_id           =>p_project_id
          ,p_structure_version_id =>p_structure_version_id
          ,p_dirty_flag           =>p_dirty_flag
          ,x_return_status        =>x_return_status
          ,x_msg_count            =>x_msg_count
          ,x_msg_data             =>x_msg_data
    );
--
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0) THEN
      IF x_msg_count = 1 THEN
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
--
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.UPDATE_SCH_DIRTY_FLAG end');
    END IF;
--
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF p_commit = FND_API.G_TRUE THEN
         ROLLBACK TO update_sch_dirty_flag_pub;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF p_commit = FND_API.G_TRUE THEN
         ROLLBACK TO update_sch_dirty_flag_pub;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'update_sch_dirty_flag',
                              p_error_text     => x_msg_data);  -- 4537865
    WHEN OTHERS THEN
      IF p_commit = FND_API.G_TRUE THEN
         ROLLBACK TO update_sch_dirty_flag_pub;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'update_sch_dirty_flag',
                              p_error_text     => x_msg_data);  -- 4537865
      RAISE;
END update_sch_dirty_flag;

--
--
-- API name                      : 	DELETE_PUBLISHED_STRUCTURE_VERSION
-- Tracking Bug                  : 4925192
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_api_version                      IN  NUMBER      := 1.0
--   ,p_init_msg_list                    IN  VARCHAR2    := FND_API.G_TRUE
--   ,p_structure_version_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE
--   ,p_record_version_number_tbl        IN  SYSTEM.PA_NUM_TBL_TYPE
--   ,x_return_status                    OUT  NOCOPY VARCHAR2
--   ,x_msg_count                        OUT  NOCOPY NUMBER
--   ,x_msg_data                         OUT  NOCOPY VARCHAR2
--
--  History
--
--  17-NOV-06   Ram Namburi             -Created
--
--  Purpose:
--
--  This API will delete a published structure version
--    1. It calls the delete validation API to see if deletion is okay.
--    2. Then it calls the Progress API to roll up the progress to the next higher
--       later versions
--    3. Then it calls the actual delete API.
--
/*
-- ######################################################################################
SAMPLE CODE FOR DELETE MULTIPLE VERSIONS:


FOR i in p_structure_version_id_tbl.FIRST..p_structure_version_id_tbl.LAST LOOP -- Call the validation API
-- If Y is returned then proceed with the
-- progress rollup and
-- actual deletion.
-- l_structure_version_rec := p_structure_version_in_tbl(i);
l_val_return_status := PA_PROJECT_STRUCTURE_UTILS.check_del_pub_struc_ver_ok(p_structure_version_id_tbl(i));

IF (l_val_return_status = 'Y') then

if (l_validation_failed <> 'Y'))THEN

-- Call Progress rollup API

BEGIN

pa_progress_pvt.UPD_PROG_RECS_STR_DELETE(
p_project_id => p_project_id,
p_str_ver_id_to_del => p_structure_version_id_tbl(i),
x_return_status => l_return_status,
x_msg_count => l_msg_count,
x_msg_data => l_msg_data);
IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
NULL;
END IF;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;


BEGIN
-- Call the actual delete API
PA_PROJECT_STRUCTURE_PUB1.delete_working_struc_ver(
p_api_version => 1.0,
p_structure_version_id => p_structure_version_id_tbl(i),
p_record_version_number => p_record_version_number_tbl(i),
x_return_status => l_return_status,
x_msg_count => l_msg_count,
x_msg_data => l_msg_data);
IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
NULL;
END IF;
EXCEPTION
WHEN OTHERS THEN
l_validation_failed := 'Y'

-- < store: message data in local tbl variable.
-- store: ver name of p_structure_version_id_tbl(i) in local tbl.
-- store: ver number of p_structure_version_id_tbl(i) in local tbl > --
NULL;
END;

end if; -- if (l_validation_failed <> 'Y'))THEN

ELSE
l_validation_failed := 'Y';

-- < read message from stack into local tbl variable.
-- store: ver name of p_structure_version_id_tbl(i) in local tbl.
-- store: ver number of p_structure_version_id_tbl(i) in local tbl > --
END IF;
END LOOP;
IF l_validation_failed = 'Y' THEN
-- Return Status will be error so the caller
-- can read from the error stack
x_return_status := FND_API.G_RET_STS_ERROR;

-- clear FND stack of all previously pop messages.

-- populate generic error message
-- < loop thorugh the local tbl variable with messages.
-- pop message with ver name and ver number tokens using the new 'TOKEN : MESG'
-- end loop>

END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

IF p_commit = FND_API.G_TRUE THEN

ROLLBACK TO DELETE_PUBLISHED_STRUCTURE_VER;

END IF;
x_return_status := FND_API.G_RET_STS_ERROR;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
IF p_commit = FND_API.G_TRUE THEN
ROLLBACK TO DELETE_PUBLISHED_STRUCTURE_VER;
END IF;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_PUB1',
p_procedure_name => 'DELETE_PUBLISHED_STRUCTURE_VER',
p_error_text => SUBSTRB(SQLERRM,1,240));
WHEN OTHERS THEN
IF p_commit = FND_API.G_TRUE THEN

ROLLBACK TO DELETE_PUBLISHED_STRUCTURE_VER;

END IF;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_PUB1',
p_procedure_name => 'DELETE_PUBLISHED_STRUCTURE_VER',
p_error_text => SUBSTRB(SQLERRM,1,240));
RAISE;

END DELETE_PUBLISHED_STRUCTURE_VER;

-- ######################################################################################

*/


procedure DELETE_PUBLISHED_STRUCTURE_VER
  (
    p_api_version                      IN  NUMBER      := 1.0
   ,p_init_msg_list                    IN  VARCHAR2    := FND_API.G_TRUE
   ,p_project_id                       IN  NUMBER
   ,p_structure_version_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE
   ,p_record_version_number_tbl        IN  SYSTEM.PA_NUM_TBL_TYPE
   ,x_return_status                    OUT  NOCOPY VARCHAR2
   ,x_msg_count                        OUT  NOCOPY NUMBER
   ,x_msg_data                         OUT  NOCOPY VARCHAR2
  ) IS

  l_api_name      CONSTANT  VARCHAR2(30)     := 'DELETE_PUBLISHED_STRUCTURE_VER';
  l_validation_failed VARCHAR2(1) := 'N';
  l_val_return_status VARCHAR2(1);

  l_return_status  VARCHAR2(1);
  l_msg_data       VARCHAR2(2000);
  l_msg_count      NUMBER;
--  i                NUMBER;
--  l_structure_version_rec structure_version_in_rec_type;

  BEGIN

    -- SAVEPOINT DELETE_PUBLISHED_STRUCTURE_VER;

    --l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    --  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( 1.0  ,
                                         p_api_version  ,
                                         l_api_name     ,
                                         G_PKG_NAME         )    THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize the message table Unconditionally.

    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN

      FND_MSG_PUB.initialize;
    END IF;

    --  Set API return status to success
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    -- Actual Processing starts here.
    -- Start looping through the passed in values.

    FOR i in p_structure_version_id_tbl.FIRST..p_structure_version_id_tbl.LAST LOOP      -- Call the validation API

      -- If Y is returned then proceed with the
      -- progress rollup and
      -- actual deletion.
      l_val_return_status := PA_PROJECT_STRUCTURE_UTILS.check_del_pub_struc_ver_ok(p_structure_version_id_tbl(i),p_project_id);
      IF l_val_return_status = 'Y' THEN
        -- Call Progress rollup API

        pa_progress_pvt.UPD_PROG_RECS_STR_DELETE(
                                  p_project_id         => p_project_id,
                                  p_str_ver_id_to_del  => p_structure_version_id_tbl(i),
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          x_msg_data := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Call the actual delete API
        PA_PROJECT_STRUCTURE_PUB1.delete_working_struc_ver(
                                  p_api_version        => 1.0,
                                  p_structure_version_id => p_structure_version_id_tbl(i),
                                  p_record_version_number => p_record_version_number_tbl(i),
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          x_msg_data := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSE
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

  x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_PUB1',
  p_procedure_name => 'DELETE_PUBLISHED_STRUCTURE_VER',
  p_error_text => SUBSTRB(SQLERRM,1,240));

  WHEN OTHERS THEN

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_PUB1',
  p_procedure_name => 'DELETE_PUBLISHED_STRUCTURE_VER',
  p_error_text => SUBSTRB(SQLERRM,1,240));

  RAISE;

END DELETE_PUBLISHED_STRUCTURE_VER;


--  History
--  03-May-06   Ram Namburi             - Created
--  Purpose:
--     This is used to enable the program on a project. In forms we are not allowing the user to create a link
--     all the times, and if the program is not enabled then we enable that on the fly so the link creation is
--     possible. This is needed otherwise users need to go to SS page to enable program on the project and come
--     back to forms to create links. In order to remove this dependency we are now calling this API from forms
--     as we couldnt directly call the update_structures_setup_attr.
--     This wrapper will call the update_structures_setup_attr with other parameters.
--
PROCEDURE enable_program_flag(
    p_project_id                       IN  NUMBER
   ,x_return_status                    OUT NOCOPY VARCHAR2
   ,x_msg_count                        OUT NOCOPY NUMBER
   ,x_msg_data                         OUT NOCOPY VARCHAR2
                             )  IS

l_data                          VARCHAR2(250);
l_msg_index_out                 NUMBER;

l_wp_enabled 		VARCHAR2(1)		:= NULL;
l_fin_enabled   	VARCHAR2(1)		:= NULL;
l_delv_enabled  	VARCHAR2(1)		:= NULL;
l_share_code            VARCHAR2(30)            := NULL;

BEGIN

    l_wp_enabled := PA_PROJECT_STRUCTURE_UTILS.Check_workplan_enabled(p_project_id);
    l_fin_enabled := PA_PROJECT_STRUCTURE_UTILS.Check_financial_enabled(p_project_id);
    l_delv_enabled := PA_PROJECT_STRUCTURE_UTILS.Check_deliverable_enabled(p_project_id);
    l_share_code := PA_PROJECT_STRUCTURE_UTILS.Get_Structure_sharing_code(p_project_id);

    PA_PROJECT_STRUCTURE_PUB1.UPDATE_STRUCTURES_SETUP_ATTR(
     p_api_version      => 1.0
    ,p_init_msg_list    => 'T'
    ,p_commit           => 'F'
    --,p_validate_only    => 'T'
    --,p_validation_level => p_validation_level
    --,p_calling_module   => p_calling_module
    ,p_debug_mode       => 'N'
    --,p_max_msg_count    => p_max_msg_count
    ,p_project_id       => p_project_id
    ,p_workplan_enabled_flag => l_wp_enabled
    ,p_financial_enabled_flag => l_fin_enabled
    ,p_deliverables_enabled_flag => l_delv_enabled
    ,p_sharing_option_code  =>  l_share_code
    ,p_sys_program_flag => 'Y'
    ,p_allow_multi_prog_rollup => 'N'
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data  => x_msg_data
    );

    x_msg_count := FND_MSG_PUB.count_msg;

    IF (x_msg_count > 0) THEN

      IF x_msg_count = 1 THEN

         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'enable_program_flag',
                              p_error_text     => x_msg_data);
    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1 ;
      x_msg_data :=  SUBSTRB(SQLERRM,1,240);
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PUB1',
                              p_procedure_name => 'enable_program_flag',
                              p_error_text     => x_msg_data);
      RAISE;

END enable_program_flag;
--
--
end PA_PROJECT_STRUCTURE_PUB1;

/
