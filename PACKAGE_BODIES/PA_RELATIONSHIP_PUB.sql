--------------------------------------------------------
--  DDL for Package Body PA_RELATIONSHIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RELATIONSHIP_PUB" as
/*$Header: PAXRELPB.pls 120.6.12010000.5 2009/06/15 13:50:14 kmaddi ship $*/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_RELATIONSHIP_PUB';

-- API name                      : Create_Relationship
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
--   p_project_id_from                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_name_from                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_id_from                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_name_from               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_version_id_from         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_name_from       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_name_from                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_project_id_to                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_name_to                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_id_to                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_name_to                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_version_id_to           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_name_to         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_name_to                      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_type                    IN  VARCHAR2
--   p_initiating_element                IN  VARCHAR2
--   p_link_to_latest_structure_ver      IN  VARCHAR2    := 'N'
--   p_relationship_type                 IN  VARCHAR2
--   p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_object_relationship_id            OUT  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Relationship
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id_from                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_name_from                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_id_from                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_name_from               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_version_id_from         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_name_from       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_name_from                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_project_id_to                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_name_to                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_id_to                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_name_to                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_version_id_to           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_name_to         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_name_to                      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_type                    IN  VARCHAR2
   ,p_initiating_element                IN  VARCHAR2
   ,p_link_to_latest_structure_ver      IN  VARCHAR2    := 'N'
   ,p_relationship_type                 IN  VARCHAR2
   ,p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_weighting_percentage              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_object_relationship_id            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_RELATIONSHIP';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

    l_object_relationship_id        NUMBER;

    l_project_id_from               NUMBER;
    l_structure_id_from             NUMBER;
    l_struc_ver_id_from             NUMBER;
    l_task_ver_id_from              NUMBER;
    l_project_id_to                 NUMBER;
    l_structure_id_to               NUMBER;
    l_struc_ver_id_to               NUMBER;
    l_task_ver_id_to                NUMBER;

  BEGIN
    pa_debug.init_err_stack ('PA_RELATIONSHIP_PUB.CREATE_RELATIONSHIP');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.CREATE_RELATIONSHIP begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_relationship;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;


    --name to id conversion
    IF ((p_project_name_from <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_project_name_from IS NOT NULL)) OR
       ((p_project_id_from <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_project_id_from IS NOT NULL)) THEN
      PA_PROJ_ELEMENTS_UTILS.Project_Name_Or_Id(
        p_project_name              => p_project_name_from
       ,p_project_id                => p_project_id_from
       ,p_check_id_flag             => PA_STARTUP.G_Check_ID_Flag
       ,x_project_id                => l_project_id_from
       ,x_return_status             => l_return_status
       ,x_error_msg_code            => l_error_msg_code
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    END IF;


    IF ((p_project_name_to <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_project_name_to IS NOT NULL)) OR
       ((p_project_id_to <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_project_id_to IS NOT NULL)) THEN
      PA_PROJ_ELEMENTS_UTILS.Project_Name_Or_Id(
        p_project_name              => p_project_name_to
       ,p_project_id                => p_project_id_to
       ,p_check_id_flag             => PA_STARTUP.G_Check_ID_Flag
       ,x_project_id                => l_project_id_to
       ,x_return_status             => l_return_status
       ,x_error_msg_code            => l_error_msg_code
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    END IF;

    IF ((p_structure_name_from <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_structure_name_from IS NOT NULL)) OR
       ((p_structure_id_from <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_structure_id_from IS NOT NULL)) THEN
      PA_PROJECT_STRUCTURE_UTILS.Structure_Name_Or_Id(
        p_project_id                => l_project_id_from
       ,p_structure_id              => p_structure_id_from
       ,p_structure_name            => p_structure_name_from
       ,p_check_id_flag             => PA_STARTUP.G_Check_ID_Flag
       ,x_structure_id              => l_structure_id_from
       ,x_return_status             => l_return_status
       ,x_error_message_code        => l_error_msg_code
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    END IF;

    IF ((p_structure_name_to <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_structure_name_to IS NOT NULL)) OR
       ((p_structure_id_to <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_structure_id_to IS NOT NULL)) THEN
      PA_PROJECT_STRUCTURE_UTILS.Structure_Name_Or_Id(
        p_project_id                => l_project_id_to
       ,p_structure_id              => p_structure_id_to
       ,p_structure_name            => p_structure_name_to
       ,p_check_id_flag             => PA_STARTUP.G_Check_ID_Flag
       ,x_structure_id              => l_structure_id_to
       ,x_return_status             => l_return_status
       ,x_error_message_code        => l_error_msg_code
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    END IF;

    IF ((p_structure_version_name_from <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_structure_version_name_from IS NOT NULL)) OR
       ((p_structure_version_id_from <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_structure_version_id_from IS NOT NULL)) THEN
--      error_msg('name -> '||p_structure_version_name_from);
--      error_msg('id -> '||p_structure_version_id_from);
      PA_PROJECT_STRUCTURE_UTILS.Structure_Version_Name_Or_Id
      (
        p_structure_id                => l_structure_id_from
       ,p_structure_version_name      => p_structure_version_name_from
       ,p_structure_version_id        => p_structure_version_id_from
       ,p_check_id_flag               => PA_STARTUP.G_Check_ID_Flag
       ,x_structure_version_id        => l_struc_ver_id_from
       ,x_return_status               => l_return_status
       ,x_error_message_code          => l_error_msg_code
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--        error_msg('structure version from ');
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    END IF;

    IF ((p_structure_version_name_to <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_structure_version_name_to IS NOT NULL)) OR
       ((p_structure_version_id_to <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_structure_version_id_to IS NOT NULL)) THEN
      PA_PROJECT_STRUCTURE_UTILS.Structure_Version_Name_Or_Id
      (
        p_structure_id                => l_structure_id_to
       ,p_structure_version_name      => p_structure_version_name_to
       ,p_structure_version_id        => p_structure_version_id_to
       ,p_check_id_flag               => PA_STARTUP.G_Check_ID_Flag
       ,x_structure_version_id        => l_struc_ver_id_to
       ,x_return_status              => l_return_status
       ,x_error_message_code         => l_error_msg_code
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--        error_msg('structure version to ');
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    END IF;

    IF ((p_task_name_from <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_task_name_from IS NOT NULL)) OR
       ((p_task_version_id_from <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_task_version_id_from IS NOT NULL)) THEN
      PA_PROJ_ELEMENTS_UTILS.TASK_VER_NAME_OR_ID(
        p_task_name            => p_task_name_from
       ,p_task_version_id      => p_task_version_id_from
       ,p_structure_version_id => l_struc_ver_id_from
       ,p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag
       ,x_task_version_id      => l_task_ver_id_from
       ,x_return_status        => l_return_status
       ,x_error_msg_code       => l_error_msg_code
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    END IF;

    IF ((p_task_name_to <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_task_name_to IS NOT NULL)) OR
       ((p_task_version_id_to <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_task_version_id_to IS NOT NULL)) THEN
      PA_PROJ_ELEMENTS_UTILS.TASK_VER_NAME_OR_ID(
        p_task_name            => p_task_name_to
       ,p_task_version_id      => p_task_version_id_to
       ,p_structure_version_id => l_struc_ver_id_to
       ,p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag
       ,x_task_version_id      => l_task_ver_id_to
       ,x_return_status        => l_return_status
       ,x_error_msg_code       => l_error_msg_code
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    END IF;

    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0 THEN
      If x_msg_count > 1 then
       pa_interface_utils_pub.get_messages
       (p_encoded        => FND_API.G_TRUE,
        p_msg_index      => 1,
        p_msg_count      => l_msg_count,
        p_msg_data       => l_msg_data,
        p_data           => l_data,
        p_msg_index_out  => l_msg_index_out);
       x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;


    PA_RELATIONSHIP_PVT.Create_Relationship(
    p_api_version                  => p_api_version
   ,p_init_msg_list                => p_init_msg_list
   ,p_commit                       => p_commit
   ,p_validate_only                => p_validate_only
   ,p_validation_level             => p_validation_level
   ,p_calling_module               => p_calling_module
   ,p_debug_mode                   => p_debug_mode
   ,p_max_msg_count                => p_max_msg_count
   ,p_project_id_from              => l_project_id_from
   ,p_structure_id_from            => l_structure_id_from
   ,p_structure_version_id_from    => l_struc_ver_id_from
   ,p_task_version_id_from         => l_task_ver_id_from
   ,p_project_id_to                => l_project_id_to
   ,p_structure_id_to              => l_structure_id_to
   ,p_structure_version_id_to      => l_struc_ver_id_to
   ,p_task_version_id_to           => l_task_ver_id_to
   ,p_structure_type               => p_structure_type
   ,p_initiating_element           => p_initiating_element
   ,p_link_to_latest_structure_ver => p_link_to_latest_structure_ver
   ,p_relationship_type            => p_relationship_type
   ,p_relationship_subtype         => p_relationship_subtype
   ,p_lag_day                      => p_lag_day
   ,p_priority                     => p_priority
   ,p_weighting_percentage         => p_weighting_percentage
   ,x_object_relationship_id       => l_object_relationship_id
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
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_object_relationship_id := l_object_relationship_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.CREATE_RELATIONSHIP END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_relationship;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_relationship;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PUB',
                              p_procedure_name => 'CREATE_RELATIONSHIP',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_relationship;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_PUB',
                              p_procedure_name => 'CREATE_RELATIONSHIP',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END CREATE_RELATIONSHIP;



-- API name                      : Delete_Relationship
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
--   p_object_relationship_id            IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Relationship
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'DELETE_RELATIONSHIP';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

  BEGIN
    pa_debug.init_err_stack ('PA_RELATIONSHIP_PUB.DELETE_RELATIONSHIP');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.DELETE_RELATIONSHIP begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_relationship;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_RELATIONSHIP_PVT.Delete_Relationship(
    p_api_version               => p_api_version
   ,p_init_msg_list             => p_init_msg_list
   ,p_commit                    => p_commit
   ,p_validate_only             => p_validate_only
   ,p_validation_level          => p_validation_level
   ,p_calling_module            => p_calling_module
   ,p_debug_mode                => p_debug_mode
   ,p_max_msg_count             => p_max_msg_count
   ,p_object_relationship_id    => p_object_relationship_id
   ,p_record_version_number     => p_record_version_number
   ,x_return_status             => l_return_status
   ,x_msg_count                 => l_msg_count
   ,x_msg_data                  => l_msg_data
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_relationship;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_relationship;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PUB',
                              p_procedure_name => 'DELETE_RELATIONSHIP',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_relationship;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_PUB',
                              p_procedure_name => 'DEKETE_RELATIONSHIP',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END;


-- API name                      : Create_Dependency
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
--   p_src_proj_id                       IN  NUMBER      := NULL
--   p_src_task_ver_id                   IN  NUMBER      := NULL
--   p_dest_proj_name                    IN  VARCHAR2    := NULL
--   p_dest_proj_id                      IN  NUMBER      := NULL
--   P_dest_task_name                    IN  VARCHAR2    := NULL
--   P_dest_task_id                      IN  NUMBER      := NULL
--   P_type                              IN  VARCHAR2    := 'FS'
--   P_lag_days                          IN  NUMBER      := 0
--   p_comments                          IN  VARCHAR2    := NULL
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--

  procedure Create_dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_src_proj_id                       IN  NUMBER      := NULL
   ,p_src_task_ver_id                   IN  NUMBER      := NULL
   ,p_dest_proj_name                    IN  VARCHAR2    := NULL
   ,p_dest_proj_id                      IN  NUMBER      := NULL
   ,p_dest_task_name                    IN  VARCHAR2    := NULL
   ,p_dest_task_ver_id                  IN  NUMBER      := NULL
   ,p_type                              IN  VARCHAR2    := 'FS'
   ,p_lag_days                          IN  NUMBER      := 0
   ,p_comments                          IN  VARCHAR2    := NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_DEPENDENCY';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

    l_dest_proj_id                  NUMBER;
    l_dest_task_ver_id              NUMBER;
    l_structure_ver_id              NUMBER;

    l_work_structure_ver_id         NUMBER;       /* working structure version */
    l_lp_structure_ver_id           NUMBER;       /* latest published structrue version */
    l_src_proj_ve                   VARCHAR2(1);   /* source project versioning enabled flag */
    l_dest_proj_ve                  VARCHAR2(1);   /* destination project versioning enabled flag */
    l_work_dest_task_ver_id         NUMBER;       /* destination working task version */


    CURSOR get_src_str_ver_id
    IS
      SELECT parent_structure_version_id
        FROM  pa_proj_element_versions
       WHERE project_id = p_src_proj_id
         AND element_version_id = p_src_task_ver_id
         AND object_type = 'PA_TASKS';

  BEGIN
    pa_debug.init_err_stack ('PA_RELATIONSHIP_PUB.CREATE_DEPENDENCY');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.CREATE_DEPENDENCY begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_dependency;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_src_proj_id IS NULL
    THEN
       PA_UTILS.ADD_MESSAGE( 'PA', 'PA_PS_SRC_PROJ_NULL');
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_src_task_ver_id IS NULL
    THEN
       PA_UTILS.ADD_MESSAGE( 'PA', 'PA_PS_SRC_TASK_VER_NULL');
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    --project name to id conversion
    IF ((p_dest_proj_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_dest_proj_name IS NOT NULL)) OR
       ((p_dest_proj_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_dest_proj_id IS NOT NULL)) THEN
      PA_PROJ_ELEMENTS_UTILS.Project_Name_Or_Id(
        p_project_name              => p_dest_proj_name
       ,p_project_id                => p_dest_proj_id
       ,p_check_id_flag             => PA_STARTUP.G_Check_ID_Flag
       ,x_project_id                => l_dest_proj_id
       ,x_return_status             => l_return_status
       ,x_error_msg_code            => l_error_msg_code
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    ELSE
       --Throw a message and stop further processing
       PA_UTILS.ADD_MESSAGE( 'PA', 'PA_PS_DEST_PROJ_NULL');
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    --If the dependency is created within the structure then get the structure ver of the
    --source task otherwise get the structure ver as follows
    --  get latest publsihed struccture ver id
    --  if latest publsihed is not avialable then get the current working version.
    IF p_src_proj_id = l_dest_proj_id
    THEN
       OPEN get_src_str_ver_id;
       FETCH get_src_str_ver_id INTO l_structure_ver_id;
       CLOSE get_src_str_ver_id;

       IF l_structure_ver_id IS NULL
       THEN
           PA_UTILS.ADD_MESSAGE( 'PA', 'PA_PS_SRC_PROJ_TSK_INV');
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSE
       l_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(l_dest_proj_id);
       IF l_structure_ver_id IS NULL
       THEN
         l_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_current_working_ver_id(l_dest_proj_id);
       END IF;
    END IF;

    --task name to id conversion
    IF ((p_dest_task_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_dest_task_name IS NOT NULL)) OR
       ((p_dest_task_ver_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_dest_task_ver_id IS NOT NULL)) THEN

        PA_PROJ_ELEMENTS_UTILS.task_Ver_Name_Or_Id
               (
        p_task_name                        => p_dest_task_name
       ,p_task_version_id                  => p_dest_task_ver_id
       ,p_structure_version_id             => l_structure_ver_id
       ,p_check_id_flag                    => PA_STARTUP.G_Check_ID_Flag
       ,x_task_version_id                  => l_dest_task_ver_id
       ,x_return_status                    => l_return_status
       ,x_error_msg_code                   => l_error_msg_code
       ) ;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
      END IF;
    ELSE
       --Throw a message and stop further processing
       PA_UTILS.ADD_MESSAGE( 'PA', 'PA_PS_DEST_TASK_NULL');
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    --Call private create dependency API here.

    PA_RELATIONSHIP_PVT.Create_Dependency
               (
             p_api_version                      => p_api_version
            ,p_init_msg_list                    => p_init_msg_list
            ,p_commit                           => p_commit
            ,p_validate_only                    => p_validate_only
            ,p_validation_level                 => p_validation_level
            ,p_calling_module                   => p_calling_module
            ,p_debug_mode                       => p_debug_mode
            ,p_max_msg_count                    => p_max_msg_count
            ,p_src_proj_id                      => p_src_proj_id
            ,p_src_task_ver_id                  => p_src_task_ver_id
            ,p_dest_proj_id                     => l_dest_proj_id
            ,p_dest_task_ver_id                 => l_dest_task_ver_id
            ,p_type                             => p_type
            ,p_lag_days                         => p_lag_days
            ,p_comments                         => p_comments
            ,x_return_status                    => l_return_status
            ,x_msg_count                        => l_msg_count
            ,x_msg_data                         => l_msg_data
            );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
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
      pa_debug.debug('PA_RELATIONSHIP_PUB.CREATE_DEPENDENCY END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PUB',
                              p_procedure_name => 'CREATE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_PUB',
                              p_procedure_name => 'CREATE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Create_Dependency;

-- API name                      : Update_Dependency
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
--   p_task_version_id                   IN  NUMBER      := NULL
--   p_type                              IN  VARCHAR2    := NULL
--   p_lag_days                          IN  NUMBER      := NULL
--   p_comments                          IN  VARCHAR2    := NULL
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--

  procedure Update_dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id                   IN  NUMBER      := NULL
   ,p_src_task_version_id               IN  NUMBER      := NULL
   ,p_type                              IN  VARCHAR2    := NULL
   ,p_lag_days                          IN  NUMBER      := NULL
   ,p_comments                          IN  VARCHAR2    := NULL
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_DEPENDENCY';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);
  BEGIN
    pa_debug.init_err_stack ('PA_RELATIONSHIP_PUB.UPDATE_DEPENDENCY');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.UPDATE_DEPENDENCY begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_dependency;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Call private update dependency API here.
    PA_RELATIONSHIP_PVT.Update_Dependency
               (
             p_api_version                      => p_api_version
            ,p_init_msg_list                    => p_init_msg_list
            ,p_commit                           => p_commit
            ,p_validate_only                    => p_validate_only
            ,p_validation_level                 => p_validation_level
            ,p_calling_module                   => p_calling_module
            ,p_debug_mode                       => p_debug_mode
            ,p_max_msg_count                    => p_max_msg_count
            ,p_task_version_id                  => p_task_version_id
            ,p_src_task_version_id              => p_src_task_version_id
            ,p_type                             => p_type
            ,p_lag_days                         => p_lag_days
            ,p_comments                         => p_comments
            ,p_record_version_number            => p_record_version_number
            ,x_return_status                    => l_return_status
            ,x_msg_count                        => l_msg_count
            ,x_msg_data                         => l_msg_data
            );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
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
      pa_debug.debug('PA_RELATIONSHIP_PUB.UPDATE_DEPENDENCY END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PUB',
                              p_procedure_name => 'UPDATE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_PUB',
                              p_procedure_name => 'UPDATE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Update_Dependency;

-- API name                      : Delete_Dependency
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
--   p_object_relationship_id            IN  NUMBER      := NULL
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--

  procedure Delete_Dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER      := NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'DELETE_DEPENDENCY';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);
  BEGIN
    pa_debug.init_err_stack ('PA_RELATIONSHIP_PUB.DELETE_DEPENDENCY');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.DELETE_DEPENDENCY begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_dependency;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Call private delete dependency API here.

    PA_RELATIONSHIP_PVT.Delete_Dependency
               (
             p_api_version                      => p_api_version
            ,p_init_msg_list                    => p_init_msg_list
            ,p_commit                           => p_commit
            ,p_validate_only                    => p_validate_only
            ,p_validation_level                 => p_validation_level
            ,p_calling_module                   => p_calling_module
            ,p_debug_mode                       => p_debug_mode
            ,p_max_msg_count                    => p_max_msg_count
            ,p_object_relationship_id           => p_object_relationship_id
            ,x_return_status                    => l_return_status
            ,x_msg_count                        => l_msg_count
            ,x_msg_data                         => l_msg_data
            );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
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
      pa_debug.debug('PA_RELATIONSHIP_PUB.DELETE_DEPENDENCY END');
    END IF;
  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PUB',
                              p_procedure_name => 'DELETE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_dependency;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_PUB',
                              p_procedure_name => 'DELETE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Delete_Dependency;


-- API name                      : Create_Subproject_Association
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
--   p_src_proj_id                       IN  NUMBER
--   p_task_ver_id                       IN  NUMBER
--   p_dest_proj_id                      IN  NUMBER      := NULL
--   p_dest_proj_name                    IN  VARCHAR2
--   p_comment                           IN  VARCHAR2
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka             -Created
--
--  FPM bug 3450684
--
PROCEDURE create_subproject_association(
                   p_api_version               IN  NUMBER      := 1.0
                  ,p_init_msg_list             IN  VARCHAR2    := FND_API.G_TRUE
                  ,p_commit                    IN  VARCHAR2    := FND_API.G_FALSE
                  ,p_validate_only             IN  VARCHAR2    := FND_API.G_TRUE
                  ,p_validation_level          IN  VARCHAR2    := 100
                  ,p_calling_module            IN  VARCHAR2    := 'SELF_SERVICE'
                  ,p_debug_mode                IN  VARCHAR2    := 'N'
                  ,p_max_msg_count             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                  ,p_src_proj_id               IN  NUMBER
                  ,p_task_ver_id               IN  NUMBER
                  ,p_dest_proj_id              IN  NUMBER
                  ,p_dest_proj_name            IN  VARCHAR2    := NULL
                  ,p_comment                   IN  VARCHAR2
                  ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_msg_data                  OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
--
--
--    Project_id         = p_src_proj_id
--    Task_Version_Id    = p_src_task_version_id
--    subProject_id      = p_dest_proj_id
--    subPorject_Name    = p_dest_proj_name
--    Comments           = p_comments
--
--
    l_api_version     CONSTANT NUMBER      := 1.0;
    l_api_name        CONSTANT VARCHAR(30) := 'CREATE_SUBPROJECT_ASSOCIATION';
    l_error_msg_code  VARCHAR2(250);
    l_data            VARCHAR2(250);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(250);
    l_msg_index_out   NUMBER;
    l_return_status   VARCHAR2(1);

    l_dest_proj_id    NUMBER:=0;
    l_src_proj_id     NUMBER:=0;
BEGIN
--
    pa_debug.init_err_stack ('PA_RELATIONSHIP_PUB.CREATE_SUBPROJECT_ASSOCIATION');
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.CREATE_SUBPROJECT_ASSOCIATION begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_subproject_association;
    END IF;
--
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--
    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;
--
--
--  For destination Project
    IF ((p_dest_proj_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       (p_dest_proj_name IS NOT NULL)) OR
       ((p_dest_proj_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
       (p_dest_proj_id IS NOT NULL)) THEN
       PA_PROJ_ELEMENTS_UTILS.Project_Name_Or_Id(
        p_project_name              => p_dest_proj_name
       ,p_project_id                => p_dest_proj_id
       ,p_check_id_flag             => PA_STARTUP.G_Check_ID_Flag
       ,x_project_id                => l_dest_proj_id
       ,x_return_status             => l_return_status
       ,x_error_msg_code            => l_error_msg_code
       );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
       END IF;
    ELSE
       --Throw a message and stop further processing
       PA_UTILS.ADD_MESSAGE( 'PA', 'PA_PS_DEST_PROJ_NULL');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
--
--
    PA_RELATIONSHIP_PVT.create_subproject_association(
                          p_api_version       =>  p_api_version,
                          p_init_msg_list     =>  p_init_msg_list,
                          p_validate_only     =>  p_validate_only,
                          p_validation_level  =>  p_validation_level,
                          p_calling_module    =>  p_calling_module,
                          p_commit            =>  p_commit,
                          p_debug_mode        =>  p_debug_mode,
                          p_max_msg_count     =>  p_max_msg_count,
                          p_src_proj_id       =>  p_src_proj_id,
                          p_task_ver_id       =>  p_task_ver_id,
		          p_dest_proj_id      =>  l_dest_proj_id,
                          p_dest_proj_name    =>  p_dest_proj_name,
                          p_comment           =>  p_comment,
                          x_return_status     =>  l_return_status,
                          x_msg_count         =>  x_msg_count,
                          x_msg_data          =>  x_msg_data);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 then
           pa_interface_utils_pub.get_messages
             (p_encoded        => FND_API.G_TRUE,
              p_msg_index      => 1,
              p_msg_count      => l_msg_count,
              p_msg_data       => l_msg_data,
              p_data           => l_data,
              p_msg_index_out  => l_msg_index_out);
              x_msg_data := l_data;
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;
--
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.CREATE_SUBPROJECT_ASSOCIATION END');
    END IF;
--
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_subproject_association;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_subproject_association;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PUB',
                              p_procedure_name => 'CREATE_SUBPROJECT_ASSOCIATION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_subproject_association;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_PUB',
                              p_procedure_name => 'CREATE_SUBPROJECT_ASSOCIATION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END create_subproject_association;
--
--
--
-- API name                      : Update_Subproject_Association
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_api_version                 IN  NUMBER      := 1.0
-- p_init_msg_list               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_object_relationship_id      IN  NUMBER
-- p_record_version_number       IN  NUMBER
-- p_comment                     IN  VARCHAR2
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
--
Procedure Update_Subproject_Association(p_api_version            IN  NUMBER      := 1.0,
                                        p_init_msg_list          IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validate_only          IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level       IN  VARCHAR2    := 100,
                                        p_calling_module         IN  VARCHAR2    := 'SELF_SERVICE',
                                        p_max_msg_count          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_commit                 IN  VARCHAR2    := FND_API.G_FALSE,
                                        p_debug_mode             IN  VARCHAR2    := 'N',
                                        p_object_relationship_id IN  NUMBER,
                                        p_record_version_number  IN  NUMBER,
                                        p_comment                IN  VARCHAR2,
                                        x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
--
    l_api_version     CONSTANT NUMBER      := 1.0;
    l_api_name        CONSTANT VARCHAR(30) := 'UPDATE_SUBPROJECT_ASSOCIATION';
    l_error_msg_code  VARCHAR2(250);
    l_data            VARCHAR2(250);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(250);
    l_msg_index_out   NUMBER;
    l_return_status   VARCHAR2(1);
--
    l_dest_proj_id    NUMBER:=0;
    l_src_proj_id     NUMBER:=0;
--
BEGIN
--
    pa_debug.init_err_stack ('PA_RELATIONSHIP_PUB.DELETE_SUBPROJECT_ASSOCIATION');
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.UPDATE_SUBPROJECT_ASSOCIATION begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Update_Subproject_Association;
    END IF;
--
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--
    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;
--
--
    PA_RELATIONSHIP_PVT.Update_Subproject_Association
                (p_api_version            =>  p_api_version,
                 p_init_msg_list          =>  p_init_msg_list,
                 p_validate_only          =>  p_validate_only,
                 p_validation_level       =>  p_validation_level,
                 p_calling_module         =>  p_calling_module,
                 p_max_msg_count          =>  p_max_msg_count,
                 p_commit                 =>  p_commit,
                 p_debug_mode             =>  p_debug_mode,
                 p_object_relationship_id =>  p_object_relationship_id,
                 p_record_version_number  =>  p_record_version_number,
                 p_comment                =>  p_comment,
                 x_return_status          =>  l_return_status,
                 x_msg_count              =>  x_msg_count,
                 x_msg_data               =>  x_msg_data);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 then
           pa_interface_utils_pub.get_messages
             (p_encoded        => FND_API.G_TRUE,
              p_msg_index      => 1,
              p_msg_count      => l_msg_count,
              p_msg_data       => l_msg_data,
              p_data           => l_data,
              p_msg_index_out  => l_msg_index_out);
              x_msg_data := l_data;
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;
--
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.UPDATE_SUBPROJECT_ASSOCIATION END');
    END IF;
--
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Subproject_Association;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Subproject_Association;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PUB',
                              p_procedure_name => 'UPDATE_SUBPROJECT_ASSOCIATION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Subproject_Association;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_PUB',
                              p_procedure_name => 'UPDATE_SUBPROJECT_ASSOCIATION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Update_Subproject_Association;
--
--
--
-- API name                      : Delete_SubProject_Association
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_object_relationships_id     IN  NUMBER
-- p_record_version_number       IN  NUMBER
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
--
Procedure Delete_SubProject_Association(p_api_version             IN  NUMBER      := 1.0,
                                        p_init_msg_list           IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_commit                  IN  VARCHAR2    := FND_API.G_FALSE,
                                        p_validate_only           IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level        IN  VARCHAR2    := 100,
                                        p_calling_module          IN  VARCHAR2    := 'SELF_SERVICE',
                                        p_debug_mode              IN  VARCHAR2    := 'N',
                                        p_max_msg_count           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_object_relationships_id IN NUMBER,
                                        p_record_version_number   IN  NUMBER,
                                        x_return_status           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count               OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data                OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
--
    l_api_version     CONSTANT NUMBER      := 1.0;
    l_api_name        CONSTANT VARCHAR(30) := 'DELETE_SUBPROJECT_ASSOCIATION';
    l_error_msg_code  VARCHAR2(250);
    l_data            VARCHAR2(250);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(250);
    l_msg_index_out   NUMBER;
    l_return_status   VARCHAR2(1);
--
    l_dest_proj_id    NUMBER:=0;
    l_src_proj_id     NUMBER:=0;
--
BEGIN
--
    pa_debug.init_err_stack ('PA_RELATIONSHIP_PUB.DELETE_SUBPROJECT_ASSOCIATION');
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.UPDATE_SUBPROJECT_ASSOCIATION begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Delete_SubProject_Association;
    END IF;
--
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--
    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;
--
--
    PA_RELATIONSHIP_PVT.Delete_SubProject_Association(
                 p_commit                  =>  p_commit,
                 p_validate_only           =>  p_validate_only,
                 p_validation_level        =>  p_validation_level,
                 p_calling_module          =>  p_calling_module,
                 p_debug_mode              =>  p_debug_mode,
                 p_max_msg_count           =>  p_max_msg_count,
                 p_object_relationships_id =>  p_object_relationships_id,
                 p_record_version_number   =>  p_record_version_number,
                 x_return_status           =>  l_return_status,
                 x_msg_count               =>  x_msg_count,
                 x_msg_data                =>  x_msg_data);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 then
           pa_interface_utils_pub.get_messages
             (p_encoded        => FND_API.G_TRUE,
              p_msg_index      => 1,
              p_msg_count      => l_msg_count,
              p_msg_data       => l_msg_data,
              p_data           => l_data,
              p_msg_index_out  => l_msg_index_out);
              x_msg_data := l_data;
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;
--
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PUB.DELETE_SUBPROJECT_ASSOCIATION END');
    END IF;
--
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_SubProject_Association;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_SubProject_Association;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PUB',
                              p_procedure_name => 'DELETE_SUBPROJECT_ASSOCIATION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_SubProject_Association;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_PUB',
                              p_procedure_name => 'DELETE_SUBPROJECT_ASSOCIATION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Delete_SubProject_Association;
--
--


  -- -----------------------------------------------------
  -- function UPDATE_PROGRAM_GROUPS
  --
  -- p_operation_type = 'ADD'  ==> This API must be called after the
  --                               association row has been added in
  --                               PA_OBJECT_RELATIONSHIPS
  --
  -- p_operation_type = 'DROP' ==> This API must be called before the
  --                               association row has been removed
  --                               from PA_OBJECT_RELATIONSHIPS
  --
  -- After this API looks up the association information it calls the
  -- other API UPDATE_PROGRAM_GROUPS with the relevant parameters.
  --
  --   History
  --   12-MAR-2004  SVERMETT  Created
  --
  -- -----------------------------------------------------
  function UPDATE_PROGRAM_GROUPS (p_object_relationship_id in number,
                                  p_operation_type in varchar2)
           return number is

    l_parent_task_version_id     number;
    l_parent_group               number;
    l_parent_level               number;
    l_parent_project             number;
    l_child_structure_version_id number;
    l_child_group                number;
    l_child_level                number;
    l_child_project              number;
    l_relationship_type          varchar2(10);

  begin

    select
      PARENT_TASK_VERSION_ID,
      PARENT_GROUP,
      PARENT_LEVEL,
      PARENT_PROJECT,
      CHILD_STRUCTURE_VERSION_ID,
      CHILD_GROUP,
      CHILD_LEVEL,
      CHILD_PROJECT,
      RELATIONSHIP_TYPE
    into
      l_parent_task_version_id,
      l_parent_group,
      l_parent_level,
      l_parent_project,
      l_child_structure_version_id,
      l_child_group,
      l_child_level,
      l_child_project,
      l_relationship_type
    from
      (
      select /*+ index(rel, PA_OBJECT_RELATIONSHIPS_U1)
                 index(ver1, PA_PROJ_ELEMENT_VERSIONS_N3)
                 index(ver2, PA_PROJ_ELEMENT_VERSIONS_N3) */
        rel.OBJECT_ID_FROM1   PARENT_TASK_VERSION_ID,
        ver1.PRG_GROUP        PARENT_GROUP,
        ver1.PRG_LEVEL        PARENT_LEVEL,
        rel.OBJECT_ID_FROM2   PARENT_PROJECT,
        rel.OBJECT_ID_TO1     CHILD_STRUCTURE_VERSION_ID,
        ver2.PRG_GROUP        CHILD_GROUP,
        ver2.PRG_LEVEL        CHILD_LEVEL,
        rel.OBJECT_ID_TO2     CHILD_PROJECT,
        rel.RELATIONSHIP_TYPE RELATIONSHIP_TYPE
      from
        PA_OBJECT_RELATIONSHIPS  rel,
        PA_PROJ_ELEMENT_VERSIONS ver1,
        PA_PROJ_ELEMENT_VERSIONS ver2
      where
        rel.OBJECT_RELATIONSHIP_ID = p_object_relationship_id and
        ver1.PROJECT_ID            = rel.OBJECT_ID_FROM2      and
        ver1.OBJECT_TYPE           = 'PA_STRUCTURES'          and
        ver2.PROJECT_ID            = rel.OBJECT_ID_TO2        and
        ver2.OBJECT_TYPE           = 'PA_STRUCTURES'
      group by
        rel.OBJECT_ID_FROM1,
        ver1.PRG_GROUP,
        ver1.PRG_LEVEL,
        rel.OBJECT_ID_FROM2,
        rel.OBJECT_ID_TO1,
        ver2.PRG_GROUP,
        ver2.PRG_LEVEL,
        rel.OBJECT_ID_TO2,
        rel.RELATIONSHIP_TYPE
      order by
        ver1.PRG_GROUP,
        ver1.PRG_LEVEL,
        ver2.PRG_GROUP,
        ver2.PRG_LEVEL
      )
    where
      ROWNUM = 1;

  return UPDATE_PROGRAM_GROUPS (l_parent_task_version_id,
                                l_parent_group,
                                l_parent_level,
                                l_parent_project,
                                l_child_structure_version_id,
                                l_child_group,
                                l_child_level,
                                l_child_project,
                                l_relationship_type,
                                p_operation_type);

  end UPDATE_PROGRAM_GROUPS;


  -- -----------------------------------------------------
  -- function UPDATE_PROGRAM_GROUPS
  --
  -- return:  0 = successful level / group propagation
  -- return: -1 = cycle exists during 'ADD' operation type
  -- return: -2 = association does not exist during 'DROP' operation
  --
  -- ***  This API assumes that initially no associations exist and
  -- ***  that associations are added one at a time in serial.
  --
  --   History
  --   12-MAR-2004  SVERMETT  Created
  --   24-JUN-2005  SVERMETT  Modified to support the relaxed acyclic rule
  --                          (old) acyclic rule:
  --                              No cycle may exist in a program hierarchy.
  --                          (new) relaxed acyclic rule:
  --                              A project may not roll up into a program
  --                              via more than one path.
  --
  -- -----------------------------------------------------
  function UPDATE_PROGRAM_GROUPS (p_parent_task_version_id     in number,
                                  p_parent_group               in number,
                                  p_parent_level               in number,
                                  p_parent_project             in number,
                                  p_child_structure_version_id in number,
                                  p_child_group                in number,
                                  p_child_level                in number,
                                  p_child_project              in number,
                                  p_relationship_type          in varchar2,
                                  p_operation_type             in varchar2)
           return number is

    l_parent_structure_version_id number;
    l_program_group               number;
    l_parent_group                number;
    l_parent_level                number;
    l_parent_project              number;
    l_child_group                 number;
    l_child_level                 number;
    l_child_project               number;
    l_level_adjustment            number;
    l_count                       number;

    l_actual_task_version_id      number;

    l_last_update_date            date;
    l_last_updated_by             number;
    l_creation_date               date;
    l_created_by                  number;
    l_last_update_login           number;

    l_new_assoc_parent            number;
    l_new_assoc_child             number;

    --Bug 6778370
    l_hier_count                  number;
    l_subgrp_exist                varchar2(1);

  begin

    savepoint UPDATE_PROGRAM_GROUPS;

    l_parent_group   := p_parent_group;
    l_parent_level   := p_parent_level;
    l_parent_project := p_parent_project;
    l_child_group    := p_child_group;
    l_child_level    := p_child_level;
    l_child_project  := p_child_project;

    l_new_assoc_parent := null;
    l_new_assoc_child  := null;

    if (l_parent_group is not null) then

      update PA_PROJ_ELEMENT_VERSIONS
      set    PRG_GROUP = l_parent_group,
             PRG_LEVEL = l_parent_level
      where  OBJECT_TYPE = 'PA_STRUCTURES' and
             PROJECT_ID = l_parent_project and
             (PRG_GROUP is null or PRG_LEVEL is null);

    end if;

    if (l_child_group is not null) then

      update PA_PROJ_ELEMENT_VERSIONS
      set    PRG_GROUP = l_child_group,
             PRG_LEVEL = l_child_level
      where  OBJECT_TYPE = 'PA_STRUCTURES' and
             PROJECT_ID = l_child_project and
             (PRG_GROUP is null or PRG_LEVEL is null);

    end if;

    select OBJECT_ID_FROM1
    into   l_actual_task_version_id
    from   PA_OBJECT_RELATIONSHIPS
    where  OBJECT_TYPE_FROM  = 'PA_TASKS'               and
           OBJECT_TYPE_TO    = 'PA_TASKS'               and
           RELATIONSHIP_TYPE = 'S'                      and
           OBJECT_ID_TO1     = p_parent_task_version_id;

    if (p_operation_type = 'ADD') then

      if (l_parent_group = l_child_group) then

        update PA_PROJ_ELEMENT_VERSIONS
        set    PRG_GROUP = l_parent_group,
               PRG_LEVEL = l_parent_level,
               PRG_COUNT = nvl(PRG_COUNT, 0) + 1
        where  ELEMENT_VERSION_ID in (p_parent_task_version_id,
                                      l_actual_task_version_id) and
               OBJECT_TYPE = 'PA_TASKS';

        if (l_parent_level < l_child_level) then

          -- check if LF or LW link already exists

          select PARENT_STRUCTURE_VERSION_ID
          into   l_parent_structure_version_id
          from   PA_PROJ_ELEMENT_VERSIONS
          where  ELEMENT_VERSION_ID = p_parent_task_version_id;

          select count(*)
          into   l_count
          from   PA_OBJECT_RELATIONSHIPS
          where  RELATIONSHIP_TYPE   = p_relationship_type                and
                 OBJECT_TYPE_FROM    = 'PA_TASKS'                         and
                 OBJECT_TYPE_TO      = 'PA_STRUCTURES'                    and
                 OBJECT_ID_FROM2     = l_parent_project                   and
                 OBJECT_ID_TO2       = l_child_project                    and
                 OBJECT_ID_FROM1 in (select
                                       ver.ELEMENT_VERSION_ID
                                     from
                                       PA_PROJ_ELEMENT_VERSIONS ver
                                     where
                                       ver.PARENT_STRUCTURE_VERSION_ID
                                         = l_parent_structure_version_id) and
                 OBJECT_ID_TO1       = p_child_structure_version_id       and
                 not(OBJECT_ID_FROM1 = p_parent_task_version_id and
                     OBJECT_ID_TO1   = p_child_structure_version_id)      and
                 ROWNUM              = 1;

          if (l_count > 0) then
            rollback to UPDATE_PROGRAM_GROUPS;
            return -1;
          end if;

          select count(*)
          into   l_count
          from   PA_OBJECT_RELATIONSHIPS
          where  RELATIONSHIP_TYPE   in ('LF', 'LW')                  and
                 OBJECT_TYPE_FROM    =  'PA_TASKS'                    and
                 OBJECT_TYPE_TO      =  'PA_STRUCTURES'               and
                 OBJECT_ID_FROM2     =  l_parent_project              and
                 OBJECT_ID_TO2       =  l_child_project               and
                 not(OBJECT_ID_FROM1 =  p_parent_task_version_id and
                     OBJECT_ID_TO1   =  p_child_structure_version_id) and
                 ROWNUM              =  1;

        elsif (l_parent_level >= l_child_level) then

          l_count := 0;

        end if;

        if (l_count = 0) then

          -- represent program group hierarchy in the form of a directed graph

          insert into PA_PROJ_LEVELS_TMP
          (
            FROM_ID,
            TO_ID,
            FROM_LEVEL,
            TO_LEVEL,
            DIRECTION,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6
          )
          select /*+ ordered
                     index(ver, PA_PROJ_ELEMENT_VERSIONS_N5)
                     index(rel, PA_OBJECT_RELATIONSHIPS_U2) use_nl(rel) */
            distinct
            decode(invert.INVERT_ID, 'DOWN', rel.OBJECT_ID_FROM2,
                                     'UP',   rel.OBJECT_ID_TO2)   FROM_ID,
            decode(invert.INVERT_ID, 'DOWN', rel.OBJECT_ID_TO2,
                                     'UP',   rel.OBJECT_ID_FROM2) TO_ID,
            -1                                                    FROM_LEVEL,
            -1                                                    TO_LEVEL,
            decode(invert.INVERT_ID, 'DOWN', 'D',
                                     'UP',   'U')                 DIRECTION,
            decode(invert.INVERT_ID,
                   'DOWN',
                   decode(rel.OBJECT_ID_FROM2,
                          l_parent_project,
                          decode(OBJECT_ID_TO2,
                                 l_child_project,
                                 'NEW_ASSOCIATION_DOWN',
                                 'X'),
                          'X'),
                   'UP',
                   decode(rel.OBJECT_ID_FROM2,
                          l_parent_project,
                          decode(OBJECT_ID_TO2,
                                 l_child_project,
                                 'NEW_ASSOCIATION_UP',
                                 'X'),
                          'X'),
                   'X')                                           ATTRIBUTE1,
            null                                                  ATTRIBUTE2,
            null                                                  ATTRIBUTE3,
            null                                                  ATTRIBUTE4,
            null                                                  ATTRIBUTE5,
            null                                                  ATTRIBUTE6
          from
            PA_PROJ_ELEMENT_VERSIONS ver,
            PA_OBJECT_RELATIONSHIPS rel,
            pa_proj_structure_types ppst,
	    pa_proj_elem_ver_structure ppevs,
            pa_projects_all ppa,
            (
              select 'DOWN' INVERT_ID from dual union all
              select 'UP'   INVERT_ID from dual
            ) invert
          where
            ver.OBJECT_TYPE        = 'PA_TASKS'             and
            ver.PRG_GROUP          = l_parent_group         and
            ppa.project_id         = ver.project_id         and
            rel.OBJECT_TYPE_FROM   = 'PA_TASKS'             and
            rel.OBJECT_ID_FROM1    = ver.ELEMENT_VERSION_ID and
            rel.OBJECT_TYPE_TO     = 'PA_STRUCTURES'        and
            rel.RELATIONSHIP_TYPE in ('LF', 'LW')
	    AND ver.parent_structure_version_id = ppevs.element_version_id
	    AND ppevs.proj_element_id = ppst.proj_element_id
	    AND ( (ppst.structure_type_id = 1 and (ppevs.latest_eff_published_flag = 'Y' or ppevs.status_code = 'STRUCTURE_WORKING') )
	 or ( ppst.structure_type_id = 6 and ppa.structure_sharing_code not in ('SHARE_FULL', 'SHARE_PARTIAL' ) )); -- added last two conditions for bug 7409918


          select
            count(*)
          into
            l_count
          from
            (
            select
              FROM_ID,
              TO_ID
            from
              PA_PROJ_LEVELS_TMP
            group by
              FROM_ID,
              TO_ID
            having
              count(*) > 1
            );

          if (l_count > 0) then
            rollback to UPDATE_PROGRAM_GROUPS;
            return -1;
          end if;

          -- check relaxed acyclic rule

          begin

          for leaf_node in
          (
            select
              distinct
              tmp1.TO_ID PROJECT_ID
            from
              PA_PROJ_LEVELS_TMP tmp1
            start with
              tmp1.ATTRIBUTE1 = 'NEW_ASSOCIATION_DOWN'
            connect by
              tmp1.DIRECTION = 'D' and
              tmp1.FROM_ID = prior tmp1.TO_ID and
              tmp1.TO_ID <> prior tmp1.FROM_ID
            minus
            select
              distinct
              tmp2.FROM_ID PROJECT_ID
            from
              PA_PROJ_LEVELS_TMP tmp2
            where
              tmp2.DIRECTION = 'D'
          ) loop

            select
              count(*)
            into
              l_count
            from
              (
              select
                tmp3.TO_ID
              from
                PA_PROJ_LEVELS_TMP tmp3
              start with
                tmp3.FROM_ID = leaf_node.PROJECT_ID
              connect by
                tmp3.DIRECTION = 'U' and
                tmp3.FROM_ID = prior tmp3.TO_ID and
                tmp3.TO_ID <> prior tmp3.FROM_ID
              group by
                tmp3.TO_ID
              having
                count(*) > 1
              )
            where
              ROWNUM = 1;

            if (l_count > 0) then
              rollback to UPDATE_PROGRAM_GROUPS;
              return -1;
            end if;

          end loop;

          exception when others then

            rollback to UPDATE_PROGRAM_GROUPS;
            return -1;

          end;

        end if;

        if (l_parent_level >= l_child_level) then

          -- adjust hierarchy levels

          update
            PA_PROJ_LEVELS_TMP tmp4
          set
            tmp4.FROM_LEVEL = 1
          where
            tmp4.FROM_LEVEL <> 1 and
            tmp4.FROM_ID in
            (
            select
              tmp3.PROJECT_ID
            from
              (
              select
                tmp2.PROJECT_ID,
                tmp2.PROJECT_LEVEL
              from
                (
                select
                  distinct
                  tmp1.TO_ID PROJECT_ID,
                  LEVEL PROJECT_LEVEL
                from
                  PA_PROJ_LEVELS_TMP tmp1
                start with
                  tmp1.DIRECTION = 'U'
                connect by
                  tmp1.DIRECTION = 'U' and
                  tmp1.FROM_ID = prior tmp1.TO_ID and
                  tmp1.TO_ID <> prior tmp1.FROM_ID
                ) tmp2
              order by
                tmp2.PROJECT_LEVEL desc
              ) tmp3
            where
              ROWNUM = 1
            );

          l_count := sql%rowcount;

          update
            PA_PROJ_LEVELS_TMP
          set
            TO_LEVEL = 1
          where
            TO_LEVEL <> 1 and
            TO_ID in
            (
            select
              tmp1.FROM_ID
            from
              PA_PROJ_LEVELS_TMP tmp1
            where
              tmp1.FROM_LEVEL = 1
            );

          while (l_count > 0) loop

            l_count := 0;

            update
              PA_PROJ_LEVELS_TMP tmp
            set
              tmp.TO_LEVEL = tmp.FROM_LEVEL + 1
            where
              tmp.FROM_LEVEL     <> -1  and
              tmp.TO_LEVEL       <> -1  and
              tmp.DIRECTION      =  'D' and
              tmp.FROM_LEVEL + 1 >  tmp.TO_LEVEL;

            l_count := l_count + sql%rowcount;

            update
              PA_PROJ_LEVELS_TMP tmp
            set
              tmp.TO_LEVEL = decode(tmp.DIRECTION,
                                    'U', tmp.FROM_LEVEL - 1,
                                    'D', tmp.FROM_LEVEL + 1)
            where
              tmp.FROM_LEVEL <> -1 and
              tmp.TO_LEVEL = -1;

            l_count := l_count + sql%rowcount;

            update
              PA_PROJ_LEVELS_TMP tmp2
            set
              tmp2.TO_LEVEL =
              (
                select
                  max(tmp1.TO_LEVEL)
                from
                  PA_PROJ_LEVELS_TMP tmp1
                where
                  tmp1.TO_ID = tmp2.TO_ID
              )
            where
              tmp2.TO_LEVEL <>
              (
                select
                  max(tmp1.TO_LEVEL)
                from
                  PA_PROJ_LEVELS_TMP tmp1
                where
                  tmp1.TO_ID = tmp2.TO_ID
              );

            update
              PA_PROJ_LEVELS_TMP tmp2
            set
              tmp2.FROM_LEVEL =
              (
                select
                  tmp1.TO_LEVEL
                from
                  PA_PROJ_LEVELS_TMP tmp1
                where
                  tmp1.TO_ID = tmp2.FROM_ID and
                  tmp1.TO_LEVEL <> -1 and
                  ROWNUM = 1
              )
            where
              tmp2.FROM_LEVEL <>
              (
                select
                  tmp1.TO_LEVEL
                from
                  PA_PROJ_LEVELS_TMP tmp1
                where
                  tmp1.TO_ID = tmp2.FROM_ID and
                  tmp1.TO_LEVEL <> -1 and
                  ROWNUM = 1
              );

          end loop;

          update
            PA_PROJ_ELEMENT_VERSIONS ver
          set
            ver.PRG_LEVEL =
            (
            select
              tmp.TO_LEVEL
            from
              PA_PROJ_LEVELS_TMP tmp
            where
              tmp.TO_ID = ver.PROJECT_ID and
              tmp.TO_LEVEL <> -1 and
              ROWNUM = 1
            )
          where
            ver.OBJECT_TYPE in ('PA_STRUCTURES', 'PA_TASKS') and
            ver.PRG_GROUP = l_parent_group and
            ver.PROJECT_ID in
            (
            select
              distinct
              tmp.TO_ID
            from
              PA_PROJ_LEVELS_TMP tmp
            ) and
            ver.PRG_LEVEL <>
            (
            select
              tmp.TO_LEVEL
            from
              PA_PROJ_LEVELS_TMP tmp
            where
              tmp.TO_ID = ver.PROJECT_ID and
              tmp.TO_LEVEL <> -1 and
              ROWNUM = 1
            );

        end if;

      else -- l_parent_group <> l_child_group

        if (l_parent_group is null) then
          l_parent_level := 1;
          l_new_assoc_parent := l_parent_project;
        end if;

        if (l_child_group is null) then
          l_child_level := 1;
          l_new_assoc_child := l_child_project;
        end if;

        if (l_parent_level < l_child_level) then

          l_level_adjustment := l_child_level - l_parent_level - 1;

          update PA_PROJ_ELEMENT_VERSIONS
          set    PRG_GROUP = l_child_group,
                 PRG_LEVEL = l_child_level - 1,
                 PRG_COUNT = nvl(PRG_COUNT, 0) + 1
          where  ELEMENT_VERSION_ID in (p_parent_task_version_id,
                                        l_actual_task_version_id) and
                 OBJECT_TYPE = 'PA_TASKS';

          if (l_parent_group is null) then

            l_parent_group := l_child_group;

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_child_group,
                   PRG_LEVEL = l_parent_level + l_level_adjustment
            where  PROJECT_ID = l_parent_project and
                   OBJECT_TYPE = 'PA_STRUCTURES';

          else

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_child_group,
                   PRG_LEVEL = PRG_LEVEL + l_level_adjustment
            where  OBJECT_TYPE in ('PA_STRUCTURES', 'PA_TASKS') and
                   PRG_GROUP = l_parent_group;

          end if;

        elsif (l_parent_level >= l_child_level) then

          l_level_adjustment := l_parent_level - l_child_level + 1;

          if (l_parent_group is null and l_child_group is null) then

            select PA_PROJ_ELEMENT_VERSIONS_S1.NEXTVAL
            into   l_parent_group
            from   DUAL;

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_parent_group,
                   PRG_LEVEL = l_parent_level,
                   PRG_COUNT = nvl(PRG_COUNT, 0) + 1
            where  ELEMENT_VERSION_ID in (p_parent_task_version_id,
                                          l_actual_task_version_id) and
                   OBJECT_TYPE = 'PA_TASKS';

            l_child_group := l_parent_group;

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_parent_group,
                   PRG_LEVEL = decode(PROJECT_ID, l_parent_project,
                                                  l_parent_level,
                                                  l_child_level +
                                                  l_level_adjustment)
            where  PROJECT_ID in (l_parent_project,
                                  l_child_project) and
                   OBJECT_TYPE = 'PA_STRUCTURES';

          elsif (l_child_group is null) then

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_parent_group,
                   PRG_LEVEL = l_parent_level,
                   PRG_COUNT = nvl(PRG_COUNT, 0) + 1
            where  ELEMENT_VERSION_ID in (p_parent_task_version_id,
                                          l_actual_task_version_id) and
                   OBJECT_TYPE = 'PA_TASKS';

            l_child_group := l_parent_group;

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_parent_group,
                   PRG_LEVEL = l_child_level + l_level_adjustment
            where  PROJECT_ID = l_child_project and
                   OBJECT_TYPE = 'PA_STRUCTURES';

          elsif (l_parent_group is null) then

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_child_group,
                   PRG_LEVEL = PRG_LEVEL + l_level_adjustment
            where  PRG_GROUP = l_child_group and
                   OBJECT_TYPE in ('PA_STRUCTURES', 'PA_TASKS');

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_child_group,
                   PRG_LEVEL = l_child_level + l_level_adjustment - 1,
                   PRG_COUNT = nvl(PRG_COUNT, 0) + 1
            where  ELEMENT_VERSION_ID in (p_parent_task_version_id,
                                          l_actual_task_version_id) and
                   OBJECT_TYPE = 'PA_TASKS';

            l_parent_group := l_child_group;

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_child_group,
                   PRG_LEVEL = l_child_level + l_level_adjustment - 1
            where  PROJECT_ID = l_parent_project and
                   OBJECT_TYPE = 'PA_STRUCTURES';

          else

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_parent_group,
                   PRG_LEVEL = l_parent_level,
                   PRG_COUNT = nvl(PRG_COUNT, 0) + 1
            where  ELEMENT_VERSION_ID in (p_parent_task_version_id,
                                          l_actual_task_version_id) and
                   OBJECT_TYPE = 'PA_TASKS';

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_GROUP = l_parent_group,
                   PRG_LEVEL = PRG_LEVEL + l_level_adjustment
            where  OBJECT_TYPE in ('PA_STRUCTURES', 'PA_TASKS') and
                   PRG_GROUP = l_child_group;

          end if;

        end if;

      end if;

    elsif (p_operation_type = 'DROP') then

      if (l_parent_group      is null or
          l_parent_level      is null or
          l_parent_project    is null or
          l_child_group       is null or
          l_child_level       is null or
          l_child_project     is null or
          p_relationship_type is null or
          l_parent_group      <> l_child_group) then
        rollback to UPDATE_PROGRAM_GROUPS;
        return -2;
      end if;

      -- represent program group hierarchy in the form of a directed graph

      insert into PA_PROJ_LEVELS_TMP
      (
        FROM_ID,
        TO_ID,
        FROM_LEVEL,
        TO_LEVEL,
        DIRECTION,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6
      )
      select /*+ ordered
                 index(ver, PA_PROJ_ELEMENT_VERSIONS_N5)
                 index(rel, PA_OBJECT_RELATIONSHIPS_U2) use_nl(rel) */
        decode(invert.INVERT_ID, 'DOWN', rel.OBJECT_ID_FROM2,
                                 'UP',   rel.OBJECT_ID_TO2)   FROM_ID,
        decode(invert.INVERT_ID, 'DOWN', rel.OBJECT_ID_TO2,
                                 'UP',   rel.OBJECT_ID_FROM2) TO_ID,
        -1                                                    FROM_LEVEL,
        -1                                                    TO_LEVEL,
        decode(invert.INVERT_ID, 'DOWN', 'D',
                                 'UP',   'U')                 DIRECTION,
        decode(invert.INVERT_ID,
               'DOWN',
               decode(rel.OBJECT_ID_FROM2,
                      l_parent_project,
                      decode(OBJECT_ID_TO2,
                             l_child_project,
                             'DROPPED_ASSOCIATION_DOWN',
                             'X'),
                      'X'),
               'UP',
                   decode(rel.OBJECT_ID_FROM2,
                      l_parent_project,
                      decode(OBJECT_ID_TO2,
                             l_child_project,
                             'DROPPED_ASSOCIATION_UP',
                             'X'),
                      'X'),
               'X')                                           ATTRIBUTE1,
        count(*)                                              ATTRIBUTE2,
        'X'                                                   ATTRIBUTE3,
        null                                                  ATTRIBUTE4,
        null                                                  ATTRIBUTE5,
        null                                                  ATTRIBUTE6
      from
        PA_PROJ_ELEMENT_VERSIONS ver,
        PA_OBJECT_RELATIONSHIPS rel,
        (
          select 'DOWN' INVERT_ID from dual union all
          select 'UP'   INVERT_ID from dual
        ) invert
      where
        ver.OBJECT_TYPE        = 'PA_TASKS'             and
        ver.PRG_GROUP          = l_parent_group         and
        rel.OBJECT_TYPE_FROM   = 'PA_TASKS'             and
        rel.OBJECT_ID_FROM1    = ver.ELEMENT_VERSION_ID and
        rel.OBJECT_TYPE_TO     = 'PA_STRUCTURES'        and
        rel.RELATIONSHIP_TYPE in ('LF', 'LW')
      group by
        decode(invert.INVERT_ID, 'DOWN', rel.OBJECT_ID_FROM2,
                                 'UP',   rel.OBJECT_ID_TO2),
        decode(invert.INVERT_ID, 'DOWN', rel.OBJECT_ID_TO2,
                                 'UP',   rel.OBJECT_ID_FROM2),
        decode(invert.INVERT_ID, 'DOWN', 'D',
                                 'UP',   'U'),
        decode(invert.INVERT_ID,
               'DOWN',
               decode(rel.OBJECT_ID_FROM2,
                      l_parent_project,
                      decode(OBJECT_ID_TO2,
                             l_child_project,
                             'DROPPED_ASSOCIATION_DOWN',
                             'X'),
                      'X'),
               'UP',
                   decode(rel.OBJECT_ID_FROM2,
                      l_parent_project,
                      decode(OBJECT_ID_TO2,
                             l_child_project,
                             'DROPPED_ASSOCIATION_UP',
                             'X'),
                      'X'),
               'X');

      update PA_PROJ_ELEMENT_VERSIONS
      set    PRG_GROUP = decode(PRG_COUNT, 1, null, PRG_GROUP),
             PRG_LEVEL = decode(PRG_COUNT, 1, null, PRG_LEVEL),
             PRG_COUNT = decode(PRG_COUNT, 1, null, PRG_COUNT - 1)
      where  ELEMENT_VERSION_ID in (p_parent_task_version_id,
                                    l_actual_task_version_id) and
             OBJECT_TYPE = 'PA_TASKS';

      select
        tmp.ATTRIBUTE2
      into
        l_count
      from
        PA_PROJ_LEVELS_TMP tmp
      where
        tmp.ATTRIBUTE1 = 'DROPPED_ASSOCIATION_DOWN';

      if (l_count = 1) then

        -- check whether or not removing this association divides the group

        update
          PA_PROJ_LEVELS_TMP tmp2
        set
          tmp2.ATTRIBUTE3 = 'CHILD_SUBGROUP'
        where
          tmp2.ATTRIBUTE1 not in ('DROPPED_ASSOCIATION_DOWN',
                                  'DROPPED_ASSOCIATION_UP') and
          tmp2.ATTRIBUTE3 <> 'CHILD_SUBGROUP' and
           ( TMP2.FROM_ID in (select TMP1.TO_ID from PA_PROJ_LEVELS_TMP TMP1 WHERE TMP1.ATTRIBUTE1 = 'DROPPED_ASSOCIATION_DOWN')
 	             or
 	             TMP2.TO_ID  in (select TMP1.TO_ID from PA_PROJ_LEVELS_TMP TMP1 WHERE TMP1.ATTRIBUTE1 = 'DROPPED_ASSOCIATION_DOWN')
 	            );
 	         /* commented for bug     6778370
          exists
          (
          select
            1
          from
            PA_PROJ_LEVELS_TMP tmp1
          where
            tmp1.ATTRIBUTE1 = 'DROPPED_ASSOCIATION_DOWN' and
            (tmp2.FROM_ID = tmp1.TO_ID or
             tmp2.TO_ID = tmp1.TO_ID)
          );   */

        while (sql%rowcount > 0) loop

          update
            PA_PROJ_LEVELS_TMP tmp2
          set
            tmp2.ATTRIBUTE3 = 'CHILD_SUBGROUP'
          where
            tmp2.ATTRIBUTE1 not in ('DROPPED_ASSOCIATION_DOWN',
                                    'DROPPED_ASSOCIATION_UP') and
            tmp2.ATTRIBUTE3 <> 'CHILD_SUBGROUP' and
             ( tmp2.FROM_ID in (select tmp1.TO_ID from PA_PROJ_LEVELS_TMP tmp1 where tmp1.ATTRIBUTE3 = 'CHILD_SUBGROUP')
 	                or
 	               tmp2.TO_ID in (select tmp1.TO_ID from PA_PROJ_LEVELS_TMP tmp1 where tmp1.ATTRIBUTE3 = 'CHILD_SUBGROUP')
 	             );
 	              /*  commented for bug         6778370
            exists
            (
            select
              1
            from
              PA_PROJ_LEVELS_TMP tmp1
            where
              tmp1.ATTRIBUTE3 = 'CHILD_SUBGROUP' and
              (tmp2.FROM_ID = tmp1.TO_ID or
               tmp2.TO_ID = tmp1.TO_ID)
            ); */

        end loop;

        select
          count(*)
        into
          l_count
        from
          PA_PROJ_LEVELS_TMP tmp
        where
          tmp.TO_ID = l_parent_project and
          tmp.ATTRIBUTE3 = 'CHILD_SUBGROUP' and
          ROWNUM = 1;

        if (l_count > 0) then

          -- This is the last association between the two projects but the
          -- group will not be divided into two sub-groups.

          if (l_parent_level = l_child_level - 1) then

            --Bug 6778370
            -- adjust hierarchy levels
						l_hier_count := 0 ;
						select /*+  NO_USE_NL(tmp, tmp1) */ count(*)
						into l_hier_count
						from PA_PROJ_LEVELS_TMP tmp
						where tmp.TO_ID in
						       (select tmp1.from_id
						            from PA_PROJ_LEVELS_TMP tmp1
						             where tmp1.DIRECTION = 'U' and
						             tmp1.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_UP'
						       )
						 and tmp.DIRECTION = 'U'
						 and tmp.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_UP'
						 and rownum = 1;

						If l_hier_count >0 then


            update
              PA_PROJ_LEVELS_TMP tmp4
            set
              tmp4.FROM_LEVEL = 1
            where
              tmp4.FROM_LEVEL <> 1 and
              tmp4.FROM_ID =
              (
              select
                tmp3.PROJECT_ID
              from
                (
                select
                  tmp2.PROJECT_ID,
                  tmp2.PROJECT_LEVEL
                from
                  (
                  select
                    distinct
                    tmp1.TO_ID PROJECT_ID,
                    LEVEL PROJECT_LEVEL
                  from
                    PA_PROJ_LEVELS_TMP tmp1
                  start with
                    tmp1.DIRECTION = 'U' and
                    tmp1.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_UP'
                    and  exists  /* bug         6778370 */
 	                     (
 	                         select 1 from
 	                         PA_PROJ_LEVELS_TMP tmp5
 	                         where tmp1.to_id = tmp5.from_id and
 	                         tmp5.DIRECTION = 'U' and
 	                         tmp5.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_UP'
 	                     )
                  connect by
                    tmp1.DIRECTION = 'U' and
                    tmp1.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_UP' and
                    tmp1.FROM_ID = prior tmp1.TO_ID and
                    tmp1.TO_ID <> prior tmp1.FROM_ID
                  ) tmp2
                order by
                  tmp2.PROJECT_LEVEL desc
                ) tmp3
              where
                ROWNUM = 1
              );

            else  /* bug         6778370 */
               update
                 PA_PROJ_LEVELS_TMP tmp4
                 set
                 tmp4.FROM_LEVEL = 1
                 where
                 tmp4.FROM_LEVEL <> 1 and
                 tmp4.FROM_ID = (  select tmp1.to_id from
                                         PA_PROJ_LEVELS_TMP tmp1
                                         where tmp1.DIRECTION = 'U' and
                                         tmp1.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_UP' and
                                         rownum = 1
                                 );

 	          end if;

            l_count := sql%rowcount;

            update
              PA_PROJ_LEVELS_TMP
            set
              TO_LEVEL = 1
            where
              TO_LEVEL <> 1 and
              TO_ID in
              (
              select
                tmp1.FROM_ID
              from
                PA_PROJ_LEVELS_TMP tmp1
              where
                tmp1.FROM_LEVEL = 1
              );

            while (l_count > 0) loop

              l_count := 0;

              update
                PA_PROJ_LEVELS_TMP tmp
              set
                tmp.TO_LEVEL = tmp.FROM_LEVEL + 1
              where
                tmp.FROM_LEVEL     <> -1                         and
                tmp.TO_LEVEL       <> -1                         and
                tmp.DIRECTION      =  'D'                        and
                tmp.ATTRIBUTE1     <> 'DROPPED_ASSOCIATION_DOWN' and
                tmp.FROM_LEVEL + 1 >  tmp.TO_LEVEL;

              l_count := l_count + sql%rowcount;

              update
                PA_PROJ_LEVELS_TMP tmp
              set
                tmp.TO_LEVEL = decode(tmp.DIRECTION,
                                      'U', tmp.FROM_LEVEL - 1,
                                      'D', tmp.FROM_LEVEL + 1)
              where
                tmp.FROM_LEVEL <> -1                       and
                tmp.TO_LEVEL   =  -1                       and
                tmp.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_UP' and
                tmp.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_DOWN';

              l_count := l_count + sql%rowcount;

              update
                PA_PROJ_LEVELS_TMP tmp2
              set
                tmp2.TO_LEVEL =
                nvl((
                  select
                    max(tmp1.TO_LEVEL)
                  from
                    PA_PROJ_LEVELS_TMP tmp1
                  where
                    tmp1.TO_ID = tmp2.TO_ID
                ),tmp2.TO_LEVEL)
              where
                tmp2.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_UP' and
                tmp2.ATTRIBUTE1 <> 'DROPPED_ASSOCIATION_DOWN' and
                 tmp2.TO_LEVEL is not null;
                  /* tmp2.TO_LEVEL  <>
                (
                  select
                    max(tmp1.TO_LEVEL)
                  from
                    PA_PROJ_LEVELS_TMP tmp1
                  where
                    tmp1.TO_ID = tmp2.TO_ID
                ); commented for bug 6778370*/

              update
                PA_PROJ_LEVELS_TMP tmp2
              set
                tmp2.FROM_LEVEL =
                nvl((
                  select
                    tmp1.TO_LEVEL
                  from
                    PA_PROJ_LEVELS_TMP tmp1
                  where
                    tmp1.TO_ID = tmp2.FROM_ID and
                    tmp1.TO_LEVEL <> -1 and
                    ROWNUM = 1
                ),tmp2.FROM_LEVEL)
              where
                tmp2.ATTRIBUTE1  <> 'DROPPED_ASSOCIATION_UP' and
                tmp2.ATTRIBUTE1  <> 'DROPPED_ASSOCIATION_DOWN' and
                tmp2.FROM_LEVEL is not null;
                /*
                tmp2.FROM_LEVEL <>
                (
                  select
                    tmp1.TO_LEVEL
                  from
                    PA_PROJ_LEVELS_TMP tmp1
                  where
                    tmp1.TO_ID = tmp2.FROM_ID and
                    tmp1.TO_LEVEL <> -1 and
                    ROWNUM = 1
                ); commented for bug 6778370 */

            end loop;

            update
              PA_PROJ_ELEMENT_VERSIONS ver
            set
              ver.PRG_LEVEL =
              (
              select
                tmp.TO_LEVEL
              from
                PA_PROJ_LEVELS_TMP tmp
              where
                tmp.TO_ID = ver.PROJECT_ID and
                tmp.TO_LEVEL <> -1 and
                ROWNUM = 1
              )
            where
              ver.OBJECT_TYPE in ('PA_STRUCTURES', 'PA_TASKS') and
              ver.PRG_GROUP = l_parent_group and
              ver.PROJECT_ID in
              (
              select
                distinct
                tmp.TO_ID
              from
                PA_PROJ_LEVELS_TMP tmp
              ) and
              ver.PRG_LEVEL <>
              (
              select
                tmp.TO_LEVEL
              from
                PA_PROJ_LEVELS_TMP tmp
              where
                tmp.TO_ID = ver.PROJECT_ID and
                tmp.TO_LEVEL <> -1 and
                ROWNUM = 1
              );

          end if;

        elsif (l_count = 0) then

          -- This is the last association between the two projects and the
          -- group will be divided into two sub-groups.

          select PA_PROJ_ELEMENT_VERSIONS_S1.NEXTVAL
          into   l_child_group
          from   DUAL;

          -- stamp the newly created program group
          -- Bug 6778370
					begin
					   select 'Y' into l_subgrp_exist
					   from dual
					   where exists ( select 1 from PA_PROJ_LEVELS_TMP tmp
					                   where
					                    ATTRIBUTE1 = 'DROPPED_ASSOCIATION_DOWN' or
					                    tmp.ATTRIBUTE3 = 'CHILD_SUBGROUP');
					   EXCEPTION WHEN NO_DATA_FOUND THEN
					           l_subgrp_exist := 'N';
					end;

					-- Bug 6778370
					If nvl(l_subgrp_exist,'N') = 'Y' then

	          update PA_PROJ_ELEMENT_VERSIONS ver
	          set    ver.PRG_GROUP = l_child_group
	          where  ver.OBJECT_TYPE in ('PA_STRUCTURES', 'PA_TASKS') and
	                 ver.PRG_GROUP = l_parent_group and
	                 ver.PROJECT_ID in
	                 (
	                 select
	                   tmp.TO_ID
	                 from
	                   PA_PROJ_LEVELS_TMP tmp
	                 where
	                   ATTRIBUTE1 = 'DROPPED_ASSOCIATION_DOWN' or
	                   ATTRIBUTE3 = 'CHILD_SUBGROUP'
	                 );
					 end if;
          -- readjust program levels so the new groups have shallowest level 1

          select   PRG_GROUP,
                   PRG_LEVEL
          into     l_program_group,
                   l_level_adjustment
          from     (select   PRG_GROUP,
                             PRG_LEVEL - 1 PRG_LEVEL
                    from     (select   PRG_GROUP,
                                       min(PRG_LEVEL) PRG_LEVEL
                              from     PA_PROJ_ELEMENT_VERSIONS
                              where    OBJECT_TYPE = 'PA_STRUCTURES' and
                                       PRG_GROUP in (l_parent_group,
                                                     l_child_group)
                              group by PRG_GROUP)
                    order by PRG_LEVEL desc)
          where    ROWNUM = 1;

          if (l_level_adjustment > 0) then

            update PA_PROJ_ELEMENT_VERSIONS
            set    PRG_LEVEL = PRG_LEVEL - l_level_adjustment
            where  OBJECT_TYPE in ('PA_STRUCTURES', 'PA_TASKS') and
                   PRG_GROUP = l_program_group;

          end if;

        end if;

      end if;

    end if;

    delete from PA_PROJ_LEVELS_TMP;

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    insert into PA_PJI_PROJ_EVENTS_LOG
    (
      EVENT_TYPE,
      EVENT_ID,
      EVENT_OBJECT,
      OPERATION_TYPE,
      STATUS,
      ATTRIBUTE1,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN
    )
    values
    (
      'PRG_CHANGE',
      PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
      l_parent_group,
      'I',
      'X',
      l_child_group,
      l_last_update_date,
      l_last_updated_by,
      l_creation_date,
      l_created_by,
      l_last_update_login
    );

    if (l_new_assoc_parent is not null) then

      insert into PA_PJI_PROJ_EVENTS_LOG
      (
        EVENT_TYPE,
        EVENT_ID,
        EVENT_OBJECT,
        OPERATION_TYPE,
        STATUS,
        ATTRIBUTE1,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      values
      (
        'PRG_CHANGE',
        PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
        -1,
        'I',
        'X',
        l_new_assoc_parent,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      );

    end if;

    if (l_new_assoc_child is not null) then

      insert into PA_PJI_PROJ_EVENTS_LOG
      (
        EVENT_TYPE,
        EVENT_ID,
        EVENT_OBJECT,
        OPERATION_TYPE,
        STATUS,
        ATTRIBUTE1,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      values
      (
        'PRG_CHANGE',
        PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
        -1,
        'I',
        'X',
        l_new_assoc_child,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      );

    end if;

    return 0;

    exception when others then

      rollback to UPDATE_PROGRAM_GROUPS;

      raise;

  end UPDATE_PROGRAM_GROUPS;

end PA_RELATIONSHIP_PUB;

/
