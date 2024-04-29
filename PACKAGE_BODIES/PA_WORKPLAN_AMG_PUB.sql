--------------------------------------------------------
--  DDL for Package Body PA_WORKPLAN_AMG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORKPLAN_AMG_PUB" AS
/* $Header: PAPMWKPB.pls 115.3 2002/12/21 01:01:15 mwasowic noship $*/
-- =========================================================================
/* valid p_stautus_code are: STRUCTURE_PUBLISHED, STRUCTURE_SUBMITTED, STRUCTURE_WORKING */
PROCEDURE change_structure_status
(p_api_version_number           IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := 'F'
, p_commit                      IN      VARCHAR2        := 'F'
, p_return_status               OUT NOCOPY     VARCHAR2
, p_msg_count                   OUT NOCOPY     NUMBER
, p_msg_data                    OUT NOCOPY     VARCHAR2
, p_structure_version_id        IN      NUMBER
, p_pa_project_id               IN      NUMBER
, p_status_code                 IN      VARCHAR2
, p_published_struct_ver_id     OUT NOCOPY     NUMBER

)IS

cursor version_info IS
     select record_version_number
      from pa_proj_elem_ver_structure
      where element_version_id = p_structure_version_id
      and project_id           = p_pa_project_id;

cursor struct_info is
      select pev_structure_id
      from pa_proj_elem_ver_structure
      where element_version_id = p_structure_version_id
      and project_id           = p_pa_project_id;



l_structure_id                  NUMBER                 := 0;
l_api_version_number            CONSTANT NUMBER        := G_API_VERSION_NUMBER;
l_api_name                      CONSTANT VARCHAR2(30)  := 'change_structure_status';
l_module_name                   VARCHAR2(80);
l_responsibility_id             NUMBER                 := 0;
l_user_id                       NUMBER                 := 0;
l_record_version_number         NUMBER                 := 0;
l_function_allowed              VARCHAR2(1)            := 'N';

BEGIN
        SAVEPOINT change_structure_status;
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME)  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF  FND_API.to_boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;
       l_responsibility_id := FND_GLOBAL.Resp_id;
       l_user_id           := FND_GLOBAL.User_id;

       pa_security.initialize (x_user_id        => l_user_id,
                               x_calling_module => l_module_name);

       PA_INTERFACE_UTILS_PUB.g_project_id := p_pa_project_id;

       PA_PM_FUNCTION_SECURITY_PUB.check_function_security
          (p_api_version_number => p_api_version_number,
          p_responsibility_id   => l_responsibility_id,
          p_function_name       => 'PA_PM_UPDATE_PROJECT',
          p_msg_count           => p_msg_count,
          p_msg_data            => p_msg_data,
          p_return_status       => p_return_status,
          p_function_allowed    => l_function_allowed );

        IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_function_allowed is NULL OR l_function_allowed = 'N' THEN
           FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
           FND_MSG_PUB.add;
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN version_info;
        FETCH version_info INTO l_record_version_number;
        IF version_info%NOTFOUND THEN
           RAISE NO_DATA_FOUND;
        END IF;
        CLOSE version_info;

        IF p_status_code is not NULL and p_status_code = 'STRUCTURE_PUBLISHED' THEN
          PA_PROJECT_STRUCTURE_PUB1.PUBLISH_STRUCTURE(
            p_api_version                      => p_api_version_number
           ,p_init_msg_list                    => p_init_msg_list
           ,p_commit                           => p_commit
           ,p_validate_only                    => 'N'
           ,p_calling_module                   => 'AMG'
           ,p_responsibility_id                => l_responsibility_id
           ,p_structure_version_id             => p_structure_version_id
           --,p_publish_structure_ver_name       => p_publish_structure_ver_name
           --,p_structure_ver_desc               => p_structure_ver_desc
           --,p_effective_date                   => p_effective_date
           --,p_original_baseline_flag           => p_original_baseline_flag
           --,p_current_baseline_flag            => p_current_baseline_flag
           ,x_published_struct_ver_id          => p_published_struct_ver_id
           ,x_return_status                    => p_return_status
           ,x_msg_count                        => p_msg_count
           ,x_msg_data                         => p_msg_data);
        ELSE
           IF p_status_code is not  NULL and p_status_code = 'STRUCTURE_SUBMITTED' THEN
                OPEN struct_info;
                FETCH struct_info into l_structure_id;
                IF (struct_info%NOTFOUND) THEN
                    CLOSE struct_info;
                RAISE NO_DATA_FOUND;
                END IF;
                CLOSE struct_info;

              pa_project_structure_pub1.submit_workplan
               (
                p_api_version                       => p_api_version_number
               ,p_init_msg_list                     => p_init_msg_list
               ,p_commit                            => p_commit
               ,p_validate_only                     =>  FND_API.G_FALSE
               ,p_calling_module                    =>  'AMG'
               ,p_project_id                        => p_pa_project_id
               ,p_structure_id                      => l_structure_id
               ,p_structure_version_id              => p_structure_version_id
               ,p_responsibility_id                 => l_responsibility_id
               ,x_return_status                     => p_return_status
               ,x_msg_count                         => p_msg_count
               ,x_msg_data                          => p_msg_data
               );
           ELSE
              PA_PROJECT_STRUCTURE_PVT1.CHANGE_WORKPLAN_STATUS
                (
                p_api_version                  => p_api_version_number
               ,p_init_msg_list               => p_init_msg_list
               ,p_commit                      => p_commit
               ,p_project_id                  => p_pa_project_id
               ,p_structure_version_id        => p_structure_version_id
               ,p_status_code                 => p_status_code
               ,p_record_version_number       => l_record_version_number
               ,x_return_status               => p_return_status
               ,x_msg_count                   => p_msg_count
               ,x_msg_data                    => p_msg_data
               );
           END IF;
        END IF;

        IF  FND_API.to_boolean(p_commit) THEN
            IF (p_return_status is NOT NULL and p_return_status = 'S') THEN
                COMMIT;
            END IF;
        END IF;

EXCEPTION

      WHEN NO_DATA_FOUND THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_NO_DATA_FOUND'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

       WHEN FND_API.G_EXC_ERROR THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
           ROLLBACK TO change_structure_status;
           FND_MSG_PUB.Count_And_Get(p_count => p_msg_count
                                    ,p_data  => p_msg_data);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           ROLLBACK TO change_structure_status;
           FND_MSG_PUB.Count_And_Get(p_count => p_msg_count
                                    ,p_data  => p_msg_data);

       WHEN OTHERS THEN
           p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           ROLLBACK TO change_structure_status;

           IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_And_Get(p_count => p_msg_count
                                    ,p_data  => p_msg_data);


END change_structure_status;

PROCEDURE baseline_structure
(p_api_version_number           IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := 'F'
, p_commit                      IN      VARCHAR2        := 'F'
, p_return_status               OUT NOCOPY     VARCHAR2
, p_msg_count                   OUT NOCOPY     NUMBER
, p_msg_data                    OUT NOCOPY     VARCHAR2
, p_structure_version_id        IN      NUMBER
, p_pa_project_id               IN      NUMBER

)IS
cursor version_info IS
     select pev_structure_id, record_version_number,name
            from PA_proj_elem_ver_structure
            where element_version_id   = p_structure_version_id
            and   project_id           = p_pa_project_id;

l_api_version_number            CONSTANT NUMBER        := G_API_VERSION_NUMBER;
l_api_name                      CONSTANT VARCHAR2(30)  := 'baseline_structure';
l_module_name                   VARCHAR2(80);
l_responsibility_id             NUMBER                 := 0;
l_user_id                       NUMBER                 := 0;
l_function_allowed              VARCHAR2(1)            := 'N';
l_record_version_number         pa_proj_elem_ver_structure.record_version_number%type;
l_name                          pa_proj_elem_ver_structure.name%type;
l_structure_id                  pa_proj_elem_ver_structure.pev_structure_id%type;



str version_info%ROWTYPE;
BEGIN

        SAVEPOINT change_structure_status;
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME)  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF  FND_API.to_boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;
       l_responsibility_id := FND_GLOBAL.Resp_id;
       l_user_id           := FND_GLOBAL.User_id;

       pa_security.initialize (x_user_id        => l_user_id,
                               x_calling_module => l_module_name);

       PA_INTERFACE_UTILS_PUB.g_project_id := p_pa_project_id;

       PA_PM_FUNCTION_SECURITY_PUB.check_function_security
          (p_api_version_number => p_api_version_number,
          p_responsibility_id   => l_responsibility_id,
          p_function_name       => 'PA_PM_UPDATE_PROJECT',
          p_msg_count           => p_msg_count,
          p_msg_data            => p_msg_data,
          p_return_status       => p_return_status,
          p_function_allowed    => l_function_allowed );

        IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_function_allowed is NULL OR l_function_allowed = 'N' THEN
           FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
           FND_MSG_PUB.add;
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN version_info;
        FETCH version_info INTO str;
        IF version_info%NOTFOUND THEN
           RAISE NO_DATA_FOUND;
        END IF;
        l_record_version_number := str.record_version_number;
        l_name                  := str.name;
        l_structure_id          := str.pev_structure_id;
        CLOSE version_info;

        PA_PROJECT_STRUCTURE_PUB1.Update_Structure_Version_Attr
            (
            p_api_version                 => p_api_version_number
            ,p_init_msg_list               => p_init_msg_list
            ,p_commit                      => p_commit
            ,p_calling_module              => 'AMG'
        --    ,p_project_id                  => p_project_id
        --    ,p_structure_version_id        => p_structure_version_id
            ,p_pev_structure_id            => l_structure_id
            ,p_baseline_current_flag       => 'Y'
            ,p_structure_version_name      => l_name
            ,p_record_version_number       => l_record_version_number
            ,x_return_status               => p_return_status
            ,x_msg_count                   => p_msg_count
            ,x_msg_data                    => p_msg_data
            );

        IF  FND_API.to_boolean(p_commit) THEN
            IF (p_return_status is NOT NULL and p_return_status = 'S') THEN
                COMMIT;
            END IF;
        END IF;

EXCEPTION

      WHEN NO_DATA_FOUND THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_NO_DATA_FOUND'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

       WHEN FND_API.G_EXC_ERROR THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
           ROLLBACK TO change_structure_status;
           FND_MSG_PUB.Count_And_Get(p_count => p_msg_count
                                    ,p_data  => p_msg_data);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           ROLLBACK TO change_structure_status;
           FND_MSG_PUB.Count_And_Get(p_count => p_msg_count
                                    ,p_data  => p_msg_data);

       WHEN OTHERS THEN
           p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           ROLLBACK TO change_structure_status;

           IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_And_Get(p_count => p_msg_count
                                    ,p_data  => p_msg_data);

END baseline_structure;

END PA_WORKPLAN_AMG_PUB;

/
