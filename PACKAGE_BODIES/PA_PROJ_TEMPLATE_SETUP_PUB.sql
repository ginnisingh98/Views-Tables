--------------------------------------------------------
--  DDL for Package Body PA_PROJ_TEMPLATE_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_TEMPLATE_SETUP_PUB" AS
/* $Header: PATMSTPB.pls 120.3 2005/08/22 05:53:44 sunkalya noship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJ_TEMPLATE_SETUP_PUB';

-- API name                      : Create_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_number              IN VARCHAR2
--p_project_name                  IN VARCHAR2
--p_project_type                  IN VARCHAR2
--p_organization_id         IN NUMBER
--p_organization_name           IN VARCHAR2
--p_effective_from_date         IN DATE
--p_effective_to_date           IN DATE
--p_description               IN VARCHAR2

PROCEDURE Create_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_number       IN    VARCHAR2,
 p_project_name       IN    VARCHAR2,
 p_project_type       IN    VARCHAR2,
 p_organization_id  IN    NUMBER      := -9999,
 p_organization_name    IN    VARCHAR2    := 'JUNK_CHARS',
 p_effective_from_date  IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_effective_to_date    IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_description        IN    VARCHAR2    := 'JUNK_CHARS',
 p_security_level     IN    NUMBER := 0,
-- anlee
-- Project Long Name changes
 p_long_name          IN    VARCHAR2  DEFAULT NULL,
-- End of changes
 p_operating_unit_id  IN    NUMBER, -- 4363092 MOAC changes
 x_template_id        OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Create_Project_Template';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;
    -- added for Bug fix: 4537865
    l_new_organization_id	   NUMBER;
    -- added for Bug fix: 4537865
   l_organization_name             hr_all_organization_units_tl.name%TYPE; --Bug 2931569
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PUB.Create_Project_Template');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Create_Project_Template begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Create_Project_Template;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN
      --Check Carrying out organization name and Carrying out organization Id
      IF ((p_organization_name <> 'JUNK_CHARS' ) AND
          (p_organization_name IS NOT NULL)) OR
         ((p_organization_id <> -9999 ) AND
          (p_organization_id IS NOT NULL)) THEN
        --dbms_output.put_line( 'Before Check_OrgName_Or_Id' );

        IF p_organization_id = -9999
        THEN
           l_organization_id := FND_API.G_MISS_NUM;
        ELSE
           l_organization_id := p_organization_id;
        END IF;

        IF p_organization_name = 'JUNK_CHARS'
        THEN
           l_organization_name := FND_API.G_MISS_CHAR;
        ELSE
           l_organization_name := p_organization_name;
        END IF;

        pa_hr_org_utils.Check_OrgName_Or_Id
            (p_organization_id      => l_organization_id
             ,p_organization_name   => l_organization_name
             ,p_check_id_flag       => 'Y'
           --,x_organization_id     => l_organization_id		* commented for Bug: 4537865
             ,x_organization_id	    => l_new_organization_id		-- added for Bug fix: 4537865
             ,x_return_status       => l_return_status
             ,x_error_msg_code      => l_error_msg_code);

        -- added for Bug fix: 4537865
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_organization_id := l_new_organization_id;
	END IF;
         -- added for Bug fix: 4537866

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;

      END IF; --End Name-Id Conversion
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

    --dbms_output.put_line( 'Before calling PA_PROJ_TEMPLATE_SETUP_PVT.Create_Project_Template ' );

    PA_PROJ_TEMPLATE_SETUP_PVT.Create_Project_Template(
         p_api_version         => p_api_version
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validate_only     => p_validate_only
        ,p_validation_level  => p_validation_level
        ,p_calling_module    => p_calling_module
        ,p_debug_mode          => p_debug_mode
        ,p_max_msg_count     => p_max_msg_count
        ,p_project_number      => p_project_number
        ,p_project_name        => p_project_name
        ,p_project_type        => p_project_type
        ,p_organization_id   => l_organization_id
        ,p_effective_from_date => p_effective_from_date
        ,p_effective_to_date     => p_effective_to_date
        ,p_description         => p_description
        ,p_security_level      => p_security_level
-- anlee
-- Project Long Name changes
        ,p_long_name           => p_long_name
-- End of changes
        ,p_operating_unit_id   => p_operating_unit_id -- 4363092 MOAC changes
        ,x_template_id         => x_template_id
        ,x_return_status     => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data        => l_msg_data );

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
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Create_Project_Template END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Create_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Create_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Create_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Create_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Create_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Create_Project_Template;

-- API name                      : Update_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_number              IN VARCHAR2
--p_project_name                  IN VARCHAR2
--p_project_type                  IN VARCHAR2
--p_organization_id         IN NUMBER
--p_organization_name           IN VARCHAR2
--p_effective_from_date         IN DATE
--p_effective_to_date           IN DATE
--p_description               IN VARCHAR2
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Update_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_project_number       IN    VARCHAR2    := 'JUNK_CHARS',
 p_project_name       IN    VARCHAR2    := 'JUNK_CHARS',
 p_project_type       IN    VARCHAR2    := 'JUNK_CHARS',
 p_organization_id  IN    NUMBER      := -9999,
 p_organization_name    IN    VARCHAR2    := 'JUNK_CHARS',
 p_effective_from_date  IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_effective_to_date    IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_description        IN    VARCHAR2    := 'JUNK_CHARS',
 p_security_level     IN    NUMBER := 0,
-- anlee
-- Project Long Name changes
 p_long_name          IN    VARCHAR2  DEFAULT NULL,
-- End of changes
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Project_Template';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;
   -- added for Bug: 4537865
   l_new_organization_id	   NUMBER;
    -- added for Bug: 4537865
   l_organization_name             hr_all_organization_units_tl.name%TYPE; --Bug 2931569

   l_dummy_char                    VARCHAR2(1);
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PUB.Update_Project_Template');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Update_Project_Template begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Update_Project_Template;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN
      --Check Carrying out organization name and Carrying out organization Id
      IF ((p_organization_name <> 'JUNK_CHARS' ) AND
          (p_organization_name IS NOT NULL)) OR
         ((p_organization_id <> -9999 ) AND
          (p_organization_id IS NOT NULL)) THEN
        --dbms_output.put_line( 'Before Check_OrgName_Or_Id' );

        IF p_organization_id = -9999
        THEN
           l_organization_id := FND_API.G_MISS_NUM;
        ELSE
           l_organization_id := p_organization_id;
        END IF;

        IF p_organization_name = 'JUNK_CHARS'
        THEN
           l_organization_name := FND_API.G_MISS_CHAR;
        ELSE
           l_organization_name := p_organization_name;
        END IF;

        pa_hr_org_utils.Check_OrgName_Or_Id
            (p_organization_id      => l_organization_id
             ,p_organization_name   => l_organization_name
             ,p_check_id_flag       => 'Y'
           --,x_organization_id     => l_organization_id		* commented for Bug fix: 4537865
             ,x_organization_id     => l_new_organization_id		-- added for Bug fix: 4537865
             ,x_return_status       => l_return_status
             ,x_error_msg_code      => l_error_msg_code);
         -- added for Bug fix: 4537865
		 IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		 l_organization_id := l_new_organization_id;
		 END IF;
          -- added for Bug fix: 4537865
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;

      END IF; --End Name-Id Conversion
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

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_projects_all
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_projects_all
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    --dbms_output.put_line( 'Before calling PA_PROJ_TEMPLATE_SETUP_PVT.Update_Project_Template ' );

    PA_PROJ_TEMPLATE_SETUP_PVT.Update_Project_Template(
         p_api_version         => p_api_version
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validate_only     => p_validate_only
        ,p_validation_level  => p_validation_level
        ,p_calling_module    => p_calling_module
        ,p_debug_mode          => p_debug_mode
        ,p_max_msg_count     => p_max_msg_count
        ,p_project_id          => p_project_id
        ,p_project_number      => p_project_number
        ,p_project_name        => p_project_name
        ,p_project_type        => p_project_type
        ,p_organization_id   => l_organization_id
        ,p_effective_from_date => p_effective_from_date
        ,p_effective_to_date     => p_effective_to_date
        ,p_description         => p_description
        ,p_security_level      => p_security_level
-- anlee
-- Project Long Name changes
        ,p_long_name             => p_long_name
-- End of changes
        ,p_record_version_number => p_record_version_number
        ,x_return_status     => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data        => l_msg_data );

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
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Update_Project_Template END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Update_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Update_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Update_Project_Template;

-- API name                      : Delete_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Delete_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Project_Template';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;
   l_dummy_char                    VARCHAR2(1);
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Project_Template');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Project_Template begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Delete_Project_Template;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_projects_all
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_projects_all
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Project_Template(
         p_api_version         => p_api_version
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validate_only     => p_validate_only
        ,p_validation_level  => p_validation_level
        ,p_calling_module    => p_calling_module
        ,p_debug_mode          => p_debug_mode
        ,p_max_msg_count     => p_max_msg_count
        ,p_project_id          => p_project_id
        ,p_record_version_number => p_record_version_number
        ,x_return_status     => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data        => l_msg_data );

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
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Project_Template END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Delete_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Delete_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Delete_Project_Template;


-- API name                      : Add_Project_Options
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
-- p_option_code          IN    VARCHAR
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--
PROCEDURE Add_Project_Options(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_option_code          IN    VARCHAR2,
 p_action               IN    VARCHAR2 := 'ENABLE',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Add_Project_Options';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PUB.Add_Project_Options');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Add_Project_Options');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Add_Project_Options;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_PROJ_TEMPLATE_SETUP_PVT.Add_Project_Options(
         p_api_version         => p_api_version
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validate_only     => p_validate_only
        ,p_validation_level  => p_validation_level
        ,p_calling_module    => p_calling_module
        ,p_debug_mode          => p_debug_mode
        ,p_max_msg_count     => p_max_msg_count
        ,p_project_id          => p_project_id
        ,p_option_code         => p_option_code
        ,p_action              => p_action
        ,x_return_status     => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data        => l_msg_data );

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
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Add_Project_Options END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Add_Project_Options',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Add_Project_Options',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Add_Project_Options;


-- API name                      : Delete_Project_Options
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
-- p_option_code          IN    VARCHAR2,
-- p_record_version_number IN   NUMBER,
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Delete_Project_Options(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_option_code          IN    VARCHAR2,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Project_Options';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Project_Options');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Project_Options');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Delete_Project_Options;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Project_Options(
         p_api_version         => p_api_version
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validate_only     => p_validate_only
        ,p_validation_level  => p_validation_level
        ,p_calling_module    => p_calling_module
        ,p_debug_mode          => p_debug_mode
        ,p_max_msg_count     => p_max_msg_count
        ,p_project_id          => p_project_id
        ,p_option_code         => p_option_code
        ,x_return_status     => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data        => l_msg_data );

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
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Project_Options END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Delete_Project_Options',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Delete_Project_Options',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Delete_Project_Options;

-- API name                      : Add_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
-- p_option_code          IN    VARCHAR2,
-- p_record_version_number IN   NUMBER,
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Add_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER  ,
 p_sort_order         IN    NUMBER  ,
 p_field_name         IN    VARCHAR2    := 'JUNK_CHARS',
 p_field_meaning          IN    VARCHAR2    := 'JUNK_CHARS',
 p_specification          IN    VARCHAR2    := 'JUNK_CHARS',
 p_limiting_value         IN    VARCHAR2    := 'JUNK_CHARS',
 p_prompt               IN  VARCHAR2    ,
 p_required_flag          IN    VARCHAR2    := 'N',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Add_Quick_Entry_Field';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;
   l_field_name                    VARCHAR2(80);
   l_limiting_value                VARCHAR2(80);
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PUB.Add_Quick_Entry_Field');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Add_Quick_Entry_Field');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Add_Quick_Entry_Field;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_sort_order IS NULL
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_ORDER_REQ' );
        x_msg_data := 'PA_SETUP_ORDER_REQ';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF (  p_field_name IS NOT NULL AND p_field_name <> 'JUNK_CHARS' )
    THEN
        l_field_name := p_field_name;
    ELSIF (  p_field_meaning IS NOT NULL AND p_field_meaning <> 'JUNK_CHARS' )
    THEN
        PA_PROJ_TEMPLATE_SETUP_UTILS.Get_Field_name(
                        p_field_name_meaning     => p_field_meaning
                       ,x_field_name             => l_field_name
                       ,x_return_status        => l_return_status
                       ,x_error_msg_code         => l_error_msg_code
                    );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;
    ELSE
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_FIELD_NAME_REQ' );
        x_msg_data := 'PA_SETUP_FIELD_NAME_REQ';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF p_prompt IS NULL
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_PROMPT_REQ' );
        x_msg_data := 'PA_SETUP_PROMPT_REQ';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_limiting_value IS NOT NULL AND p_limiting_value <> 'JUNK_CHARS' )
    THEN
        l_limiting_value := p_limiting_value;
    ELSIF (  p_specification IS NOT NULL AND p_specification <> 'JUNK_CHARS' )
    THEN
        PA_PROJ_TEMPLATE_SETUP_UTILS.Get_limiting_value(
                        p_field_name             => l_field_name
                       ,p_specification          => p_specification
                       ,x_limiting_value         => l_limiting_value
                       ,x_return_status        => l_return_status
                       ,x_error_msg_code         => l_error_msg_code
                    );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;
    ELSE
       l_limiting_value := null;
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

    PA_PROJ_TEMPLATE_SETUP_PVT.Add_Quick_Entry_Field(
         p_api_version         => p_api_version
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validate_only     => p_validate_only
        ,p_validation_level  => p_validation_level
        ,p_calling_module    => p_calling_module
        ,p_debug_mode          => p_debug_mode
        ,p_max_msg_count     => p_max_msg_count
        ,p_project_id          => p_project_id
        ,p_sort_order          => p_sort_order
        ,p_field_name          => l_field_name
        ,p_limiting_value    => l_limiting_value
        ,p_prompt                => p_prompt
        ,p_required_flag     => p_required_flag
        ,x_return_status     => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data        => l_msg_data );

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
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Add_Quick_Entry_Field END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Add_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Add_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Add_Quick_Entry_Field;

-- API name                      : Update_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
-- p_option_code          IN    VARCHAR2,
-- p_record_version_number IN   NUMBER,
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Update_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER  ,
 p_row_id               IN    VARCHAR2    ,
 p_sort_order         IN    NUMBER  ,
 p_field_name         IN    VARCHAR2    := 'JUNK_CHARS',
 p_field_meaning          IN    VARCHAR2    := 'JUNK_CHARS',
 p_specification          IN    VARCHAR2    := 'JUNK_CHARS',
 p_limiting_value         IN    VARCHAR2    := 'JUNK_CHARS',
 p_prompt               IN  VARCHAR2    ,
 p_required_flag          IN    VARCHAR2    := 'N',
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Quick_Entry_Field';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;

   l_field_name                    VARCHAR2(80);
   l_field_name2                   VARCHAR2(80);
   l_limiting_value                VARCHAR2(80);
   l_dummy_char                    VARCHAR2(1);

   CURSOR cur_pa_overrides
   IS
     SELECT field_name
       FROM pa_project_copy_overrides
      WHERE rowid = p_row_id;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PUB.Update_Quick_Entry_Field');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Update_Quick_Entry_Field');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Update_Quick_Entry_Field;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_sort_order IS NULL
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_ORDER_REQ' );
        x_msg_data := 'PA_SETUP_ORDER_REQ';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF (  p_field_name IS NOT NULL AND p_field_name <> 'JUNK_CHARS' )
    THEN
        l_field_name := p_field_name;
    ELSIF (  p_field_meaning IS NOT NULL AND p_field_meaning <> 'JUNK_CHARS' )
    THEN
        PA_PROJ_TEMPLATE_SETUP_UTILS.Get_Field_name(
                        p_field_name_meaning     => p_field_meaning
                       ,x_field_name             => l_field_name
                       ,x_return_status        => l_return_status
                       ,x_error_msg_code         => l_error_msg_code
                    );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;
    ELSE
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_FIELD_NAME_REQ' );
        x_msg_data := 'PA_SETUP_FIELD_NAME_REQ';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    OPEN cur_pa_overrides;
    FETCH cur_pa_overrides INTO l_field_name2;
    CLOSE cur_pa_overrides;

    IF (l_field_name2 = 'SEGMENT1' OR l_field_name2 = 'NAME') AND
        l_field_name <> l_field_name2
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_CANT_MODFY_OVER' );
        x_msg_data := 'PA_SETUP_CANT_MODFY_OVER';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF p_prompt IS NULL
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_PROMPT_REQ' );
        x_msg_data := 'PA_SETUP_PROMPT_REQ';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_limiting_value IS NOT NULL AND p_limiting_value <> 'JUNK_CHARS' )
    THEN
        l_limiting_value := p_limiting_value;
    ELSIF (  p_specification IS NOT NULL AND p_specification <> 'JUNK_CHARS' )
    THEN
        PA_PROJ_TEMPLATE_SETUP_UTILS.Get_limiting_value(
                        p_field_name             => l_field_name
                       ,p_specification          => p_specification
                       ,x_limiting_value         => l_limiting_value
                       ,x_return_status        => l_return_status
                       ,x_error_msg_code         => l_error_msg_code
                    );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;
    ELSE
       l_limiting_value := null;
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

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_project_copy_overrides
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           AND rowid = p_row_id
           FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_project_copy_overrides
           WHERE project_id             = p_project_id
           AND rowid = p_row_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    PA_PROJ_TEMPLATE_SETUP_PVT.Update_Quick_Entry_Field(
         p_api_version         => p_api_version
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validate_only     => p_validate_only
        ,p_validation_level  => p_validation_level
        ,p_calling_module    => p_calling_module
        ,p_debug_mode          => p_debug_mode
        ,p_max_msg_count     => p_max_msg_count
        ,p_project_id          => p_project_id
        ,p_row_id              => p_row_id
        ,p_sort_order          => p_sort_order
        ,p_field_name          => l_field_name
        ,p_limiting_value    => l_limiting_value
        ,p_prompt                => p_prompt
        ,p_required_flag     => p_required_flag
        ,p_record_version_number => p_record_version_number
        ,x_return_status     => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data        => l_msg_data );

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
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Update_Quick_Entry_Field END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Update_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Update_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Update_Quick_Entry_Field;


-- API name                      : Delete_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_id  IN  NUMBER  No  Not Null
--p_field_name  IN  VARCHAR2    No      FND_API.G_MISS_CHAR
--p_record_version_number   IN  NUMBER  No  not null
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Delete_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER,
 p_row_id               IN    VARCHAR2,
 p_record_version_number IN NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Quick_Entry_Field';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;
   l_dummy_char                    VARCHAR2(1);
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Quick_Entry_Field');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Quick_Entry_Field');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Delete_Quick_Entry_Field;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_project_copy_overrides
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           AND rowid = p_row_id
           FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_project_copy_overrides
           WHERE project_id             = p_project_id
           AND rowid = p_row_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Quick_Entry_Field(
         p_api_version         => p_api_version
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validate_only     => p_validate_only
        ,p_validation_level  => p_validation_level
        ,p_calling_module    => p_calling_module
        ,p_debug_mode          => p_debug_mode
        ,p_max_msg_count     => p_max_msg_count
        ,p_project_id          => p_project_id
        ,p_row_id              => p_row_id
        ,p_record_version_number => p_record_version_number
        ,x_return_status     => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data        => l_msg_data );

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
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PUB.Delete_Quick_Entry_Field END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Delete_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PUB',
                              p_procedure_name => 'Delete_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Delete_Quick_Entry_Field;


END PA_PROJ_TEMPLATE_SETUP_PUB;

/
