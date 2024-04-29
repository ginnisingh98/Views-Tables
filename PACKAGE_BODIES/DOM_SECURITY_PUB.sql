--------------------------------------------------------
--  DDL for Package Body DOM_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_SECURITY_PUB" AS
/* $Header: DOMDATASECB.pls 120.15 2006/11/08 14:01:40 ysireesh noship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'DOM_SECURITY_PUB' ;
    G_CURRENT_LOGIN_ID         NUMBER := FND_GLOBAL.Login_Id;
    G_CURRENT_USER_ID          NUMBER := FND_GLOBAL.User_Id;
    G_OCS_ROLE                         VARCHAR2(30) := 'Reviewer';
    TYPE DYNAMIC_CUR IS REF CURSOR;

/*
-- Test Debug
  PROCEDURE Write_Debug
  (
      p_api_name           IN  VARCHAR2,
      p_debug_message      IN  VARCHAR2
  )
  IS

  BEGIN

      IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
           DOM_LOG.LOG_STR(G_PKG_NAME, p_api_name, null, p_debug_message);
      END IF ;

  EXCEPTION
      WHEN OTHERS THEN
              NULL:

  END Write_Debug;
*/

PROCEDURE Grant_Document_Role
(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_object_name           IN  VARCHAR2,
   p_pk1_value             IN  VARCHAR2,
   p_pk2_value             IN  VARCHAR2,
   p_pk3_value             IN  VARCHAR2,
   p_pk4_value             IN  VARCHAR2,
   p_pk5_value             IN  VARCHAR2,
   p_party_ids             IN  FND_TABLE_OF_NUMBER,
   p_role_id               IN  NUMBER,
   p_start_date            IN  DATE := SYSDATE,
   p_end_date              IN  DATE := NULL,
   p_api_caller            IN  VARCHAR2 := NULL,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
 )
IS

    l_api_name         CONSTANT VARCHAR2(50) := 'Grant_Document_Role';
    l_grant_guid       FND_GRANTS.GRANT_GUID%TYPE ;
    l_grant_exist       VARCHAR2(10);
    l_return_status    VARCHAR2(3) ;
    l_role_name        FND_MENUS.MENU_NAME%TYPE;
    l_pk4_value         VARCHAR2(50);
BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT menu_name
      INTO l_role_name
      FROM fnd_menus
      WHERE menu_id = p_role_id;

    FOR lcount in p_party_ids.first .. p_party_ids.last LOOP

    IF p_pk1_value IS NOT NULL THEN

        EGO_SECURITY_PUB.grant_role_guid
                  ( p_api_version        => 1.0 ,
                    p_role_name          => l_role_name ,
                    p_object_name        => p_object_name  ,
                    p_instance_type      => 'INSTANCE' ,
                    p_instance_set_id    => NULL ,
                    p_instance_pk1_value => p_pk1_value ,
                    p_instance_pk2_value => p_pk2_value ,
                    p_instance_pk3_value => '*NULL*' ,
                    p_instance_pk4_value => '*NULL*' ,
                    p_instance_pk5_value => '*NULL*' ,
                    p_party_id           => p_party_ids(lcount) ,
                    p_start_date         => NVL(p_start_date,SYSDATE) ,
                    p_end_date           => p_end_date ,
                    x_return_status      => l_return_status ,
                    x_errorcode          => x_msg_data ,
                    x_grant_guid         => l_grant_guid
                    );

        if(l_grant_guid is not null) THEN
                if(p_pk4_value is null OR p_pk4_value = '-1') THEN
                        l_pk4_value := '*NULL*';
                else
                        l_pk4_value := p_pk4_value;
                end if;

                update FND_GRANTS
                set parameter1 = p_pk3_value,
                parameter2 = p_pk4_value
                where grant_guid = l_grant_guid;
        end if;

     END IF;

    END LOOP;

 --Grant Access to Files of that document.
        Grant_Attachments_OCSRole
        (
          p_api_version         => 1.0,
          p_init_msg_list         => NULL,
          p_commit              => FND_API.G_TRUE,
          p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
          p_entity_name          =>  p_object_name,
          p_pk1_value             => p_pk1_value,
          p_pk2_value             => p_pk2_value,
          p_pk3_value             => NULL,
          p_pk4_value             => NULL,
          p_pk5_value              => NULL,
          p_ocs_role              => G_OCS_ROLE,
          p_party_ids             => p_party_ids,
          p_api_caller            => NULL,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          x_return_status         => x_return_status
      );

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    --
    -- returns T if the action is success
    -- and  F on failure
    --
    IF ( l_return_status = FND_API.G_TRUE OR    l_return_status = FND_API.G_FALSE )
    THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF ;

EXCEPTION
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            (
              G_PKG_NAME,
              l_api_name
            );
    END IF;

END Grant_Document_Role ;


PROCEDURE Revoke_Document_Role
(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_object_name           IN  VARCHAR2,
   p_pk1_value             IN  VARCHAR2,
   p_pk2_value             IN  VARCHAR2,
   p_pk3_value             IN  VARCHAR2,
   p_pk4_value             IN  VARCHAR2,
   p_pk5_value             IN  VARCHAR2,
   p_party_ids             IN  FND_TABLE_OF_NUMBER,
   p_role_id               IN  NUMBER,
   p_api_caller            IN  VARCHAR2 := NULL,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
 )
IS

    l_api_name         CONSTANT VARCHAR2(50) := 'Revoke_Document_Role';
    l_return_status    VARCHAR2(1) ;
    l_error_code       NUMBER(1) ;
    l_role_name        FND_MENUS.MENU_NAME%TYPE;
    l_role_ids         FND_ARRAY_OF_NUMBER_25;
    l_object_id       NUMBER ;
    lcount1           NUMBER;
    l_ocs_role_to_revoke VARCHAR2(30);
    l_grantee_key             fnd_grants.grantee_key%TYPE;
    l_grantee_type            fnd_grants.grantee_type%TYPE;

  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;

BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     SELECT object_id
      INTO l_object_id
      FROM fnd_objects
      WHERE obj_name = p_object_name;

    FOR lcount in p_party_ids.first .. p_party_ids.last LOOP

  -- If Role is not passed, query up all the roles obtained to the user
    -- for this pks.
       OPEN get_party_type (cp_party_id => p_party_ids(lcount));
       FETCH get_party_type INTO l_grantee_type;
       CLOSE get_party_type;

       IF (l_grantee_type = 'PERSON') THEN
          l_grantee_type := 'USER';
          l_grantee_key := 'HZ_PARTY:' || p_party_ids(lcount);
       ELSIF (l_grantee_type = 'GROUP') THEN
          l_grantee_type := 'GROUP';
          l_grantee_key :='HZ_GROUP:' || p_party_ids(lcount);
      END IF;

    if p_role_id is not null then
      SELECT menu_name
      INTO l_role_name
      FROM fnd_menus
      WHERE menu_id = p_role_id;

        FND_GRANTS_PKG.delete_grant(
                       p_grantee_type          => l_grantee_type,
                       p_grantee_key           => l_grantee_key,
                       p_object_name           => p_object_name,
                       p_instance_type         => 'INSTANCE',
                       p_instance_set_id       => NULL,
                       p_instance_pk1_value    => p_pk1_value,
                       p_instance_pk2_value    => p_pk2_value,
                       p_instance_pk3_value    => NULL,
                       p_instance_pk4_value    => NULL,
                       p_instance_pk5_value    => NULL,
                       p_menu_name             => l_role_name,
                       p_program_name          => NULL,
                       p_program_tag           => NULL,
                       x_success               => l_return_status,
                       x_errcode               => l_error_code
                      );
   end if;

    if p_role_id is NULL THEN

    -- Get all User Roles on this entity
         Get_User_Roles
                          (
                           p_object_id    => l_object_id,
                           p_document_id =>   p_pk1_value,
                           p_revision_id              => p_pk2_value,
                           p_change_id => p_pk3_value,
                           p_change_line_id => p_pk4_value,
                           p_party_id => p_party_ids(lcount),
                           x_role_ids => l_role_ids
                         ) ;

    FOR lcount1 in  l_role_ids.first  .. l_role_ids.last  LOOP

    if l_role_ids(lcount1) is not null then

      SELECT menu_name
      INTO l_role_name
      FROM fnd_menus
      WHERE menu_id = l_role_ids(lcount1);

        FND_GRANTS_PKG.delete_grant(
                       p_grantee_type          => l_grantee_type,
                       p_grantee_key           => l_grantee_key,
                       p_object_name           => p_object_name,
                       p_instance_type         => 'INSTANCE',
                       p_instance_set_id       => NULL,
                       p_instance_pk1_value    => p_pk1_value,
                       p_instance_pk2_value    => p_pk2_value,
                       p_instance_pk3_value    => NULL,
                       p_instance_pk4_value    => NULL,
                       p_instance_pk5_value    => NULL,
                       p_menu_name             => l_role_name,
                       p_program_name          => NULL,
                       p_program_tag           => NULL,
                       x_success               => l_return_status,
                       x_errcode               => l_error_code
                      );

    end if;
    END LOOP;

    end if;

    END LOOP;

    --Revoke Access from the Files of that document.
    Revoke_Attachments_OCSRole
    (
          p_api_version          => 1.0,
          p_init_msg_list        => NULL,
          p_commit               => FND_API.G_TRUE,
          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
          p_entity_name         => p_object_name,
          p_pk1_value           => p_pk1_value,
          p_pk2_value           => p_pk2_value,
          p_pk3_value           => NULL,
          p_pk4_value           => NULL,
          p_pk5_value           => NULL,
          p_ocs_role             => l_ocs_role_to_revoke,
          p_party_ids            => p_party_ids,
          p_api_caller            => NULL,
          x_msg_count          => x_msg_count,
          x_msg_data            => x_msg_data,
          x_return_status        => x_return_status
    );


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    --
    -- returns T if the action is success
    -- and  F on failure
    --
    IF ( l_return_status = FND_API.G_TRUE OR
         l_return_status = FND_API.G_FALSE )
    THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF ;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            (
              G_PKG_NAME,
              l_api_name
            );
    END IF;

END Revoke_Document_Role ;


PROCEDURE Grant_Attachments_OCSRole
(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_entity_name           IN  VARCHAR2,
   p_pk1_value             IN  VARCHAR2,
   p_pk2_value             IN  VARCHAR2,
   p_pk3_value             IN  VARCHAR2,
   p_pk4_value             IN  VARCHAR2,
   p_pk5_value             IN  VARCHAR2,
   p_ocs_role              IN  VARCHAR2,
   p_party_ids             IN  FND_TABLE_OF_NUMBER,
   p_api_caller            IN  VARCHAR2 := NULL,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
)
IS
    l_api_name        CONSTANT VARCHAR2(50) := 'Grant_Attachments_OCSRole';
    l_return_status    VARCHAR2(1) ;
    l_error_code      NUMBER(1) ;
    l_role_name       FND_MENUS.MENU_NAME%TYPE;
    l_user_name       VARCHAR2(30);
    l_service_url       VARCHAR2(100);
    l_user_login       VARCHAR2(30);
    l_protocol         VARCHAR2(30);
    l_party_type      hz_parties.party_type%TYPE;
   get_attachments           DYNAMIC_CUR;
    l_dynamic_sql              VARCHAR2(32767);
    l_media_id        NUMBER;
    l_node_id    NUMBER;
    l_created_by  NUMBER;
    l_file_type     VARCHAR2(10);
    l_entity_name  VARCHAR2(30);
    l_rows NUMBER;

  BEGIN

  l_entity_name :=  p_entity_name;

  l_dynamic_sql :=   ' SELECT media_id, dm_node, A.created_by, dm_type' ||
                                ' FROM FND_DOCUMENTS D, FND_ATTACHED_DOCUMENTS A' ||
                                ' WHERE  A.DOCUMENT_ID = D.DOCUMENT_ID  ' ||
                                ' AND A.ENTITY_NAME = :entity_name ' ||
                                ' AND A.PK1_VALUE   =  :pk1_value ';

IF (p_entity_name = 'DOM_DOCUMENT_REVISION') THEN

        l_dynamic_sql := l_dynamic_sql || ' AND A.PK2_VALUE = :pk2_value';

        l_entity_name := 'DOM_DOCUMENT_VERSION';

        OPEN get_attachments FOR l_dynamic_sql
        USING IN l_entity_name,
                     IN p_pk1_value,
                     IN p_pk2_value;

ELSE

        OPEN get_attachments FOR l_dynamic_sql
        USING IN l_entity_name,
                     IN p_pk1_value;

END IF;

LOOP

      FETCH get_attachments  INTO l_media_id, l_node_id, l_created_by, l_file_type;
      EXIT WHEN get_attachments%NOTFOUND;

     FOR lcount in p_party_ids.first .. p_party_ids.last
     LOOP

          SELECT service_url, protocol
          INTO l_service_url, l_protocol
          FROM DOM_REPOSITORIES WHERE id = l_node_id;

          SELECT user_name INTO l_user_name
          FROM FND_USER where person_party_id = p_party_ids(lcount);

          SELECT party_type INTO l_party_type
          FROM hz_parties
          WHERE party_id = p_party_ids(lcount);

          IF(l_party_type = 'PERSON') THEN
              l_party_type := 'USER';
          END IF;

          --Get the Attachment created by user login.
          -- This is required to make WS connection while trying to grant role to the user.
          SELECT user_name INTO l_user_login
          FROM fnd_user
          WHERE user_id = l_created_by;

          IF (l_protocol = 'WEBSERVICES') THEN

                    DOM_WS_INTERFACE_PUB.Grant_Attachments_OCSRole (
                       p_api_version        => p_api_version,
                       p_service_url        => l_service_url,
                       p_family_id              => l_media_id,
                       p_role                   => p_ocs_role,
                       p_user_name          => l_user_name,
                       p_user_login          => l_user_login,
                       x_return_status      => x_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data
                   );

/*
                  l_rows := Check_For_Duplicate_Grant
                                                  (
                                                       p_entity_name         => l_entity_name,
                                                       p_pk1_value           => p_pk1_value,
                                                       p_pk2_value           => p_pk2_value,
                                                       p_pk3_value           => p_pk3_value,
                                                       p_pk4_value           => p_pk4_value,
                                                       p_pk5_value          =>  p_pk5_value,
                                                       p_file_id                => l_media_id,
                                                       p_repos_id            => l_node_id,
                                                       p_party_id             => p_party_ids(lcount)
                                                  );
                  IF(l_rows = 0) THEN
                  */

                        -- Insert to DOM_FOLDER_FILE_MEMBERSHIPS
                        -- Required while revoking roles.
                        INSERT INTO DOM_FOLDER_FILE_MEMBERSHIPS
                        (
                           REPOSITORY_ID,
                           REPOSITORY_ITEM_ID,
                           REPOSITORY_ITEM_TYPE,
                           ENTITY_NAME,
                           PK1_VALUE,
                           PK2_VALUE,
                           PK3_VALUE,
                           PK4_VALUE,
                           PK5_VALUE,
                           PARTY_TYPE,
                           PARTY_ID,
                           OFO_ROLE,
                           CREATED_BY,
                           CREATION_DATE,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_DATE,
                           LAST_UPDATE_LOGIN
                        )
                        VALUES
                        (
                           l_node_id,                                                     --REPOSITORY_ID
                           l_media_id,                                                   --REPOSITORY_ITEM_ID
                           l_file_type,                                                     --REPOSITORY_ITEM_TYPE
                           l_entity_name,                                               --ENTITY_NAME
                           p_pk1_value,                                                 --PK1_VALUE
                           p_pk2_value,                                                 --PK2_VALUE
                           p_pk3_value,                                                 --PK3_VALUE
                           p_pk4_value,                                                 --PK4_VALUE
                           p_pk5_value,                                                 --PK5_VALUE
                           l_party_type,                                                 --PARTY_TYPE
                           p_party_ids(lcount),                                       --PARTY_ID
                           p_ocs_role,                                                   --OFO_ROLE
                           NVL(p_api_caller, g_current_user_id),            --CREATED_BY
                           SYSDATE,                                                   --CREATION_DATE
                           NVL(p_api_caller, g_current_user_id),            --LAST_UPDATED_BY
                           SYSDATE,                                                   --LAST_UPDATE_DATE
                           g_current_login_id                                         --LAST_UPDATE_LOGIN
                        );

--                 END IF;

          END IF;

        END LOOP;

  END LOOP;

  CLOSE get_attachments;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    --
    -- returns T if the action is success
    -- and  F on failure
    --
    IF ( l_return_status = FND_API.G_TRUE OR
         l_return_status = FND_API.G_FALSE )
    THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF ;

--    dbms_output.put_line('value: '||x_return_status);

EXCEPTION

    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            (
              G_PKG_NAME,
              l_api_name
            );
    END IF;

END Grant_Attachments_OCSRole;

PROCEDURE Grant_Attachment_Access
(
   p_api_version           IN   NUMBER,
   p_attached_document_id  IN   NUMBER := NULL,
   p_source_media_id       IN   NUMBER,
   p_repository_id         IN   NUMBER,
   p_ocs_role              IN   VARCHAR2,
   p_party_ids             IN   FND_TABLE_OF_NUMBER,
   p_submitted_by          IN   NUMBER,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2,
   x_return_status         OUT  NOCOPY VARCHAR2
)
IS
    l_api_name        CONSTANT VARCHAR2(50) := 'Grant_Attachment_Access';
    l_return_status   VARCHAR2(1) ;
    l_user_name       VARCHAR2(30);
    l_service_url     VARCHAR2(100);
    l_user_login      VARCHAR2(30);
    l_protocol        VARCHAR2(30);

cursor get_user_name(cp_user_id number)
IS
select user_name
from fnd_user
where user_id=cp_user_id;

cursor get_user_name_from_party(cp_party_id number)
IS
SELECT user_name
FROM FND_USER
where person_party_id = cp_party_id ;

BEGIN

  	open get_user_name(p_submitted_by);
	  fetch get_user_name into l_user_login;
	  close get_user_name;

     FOR lcount in p_party_ids.first .. p_party_ids.last
     LOOP

          SELECT service_url, protocol
          INTO l_service_url, l_protocol
          FROM DOM_REPOSITORIES WHERE id = p_repository_id;

          FOR rec IN get_user_name_from_party(p_party_ids(lcount))
          LOOP
             IF (l_protocol = 'WEBSERVICES') THEN

                      DOM_WS_INTERFACE_PUB.Grant_Attachments_OCSRole
                      (
                        p_api_version        => p_api_version,
                        p_service_url        => l_service_url,
                        p_family_id          => p_source_media_id,
                        p_role               => p_ocs_role,
                        p_user_name          => rec.user_name,
                        p_user_login         => l_user_login,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data
                      );
              END IF;

          END LOOP;

    END LOOP;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --
    -- returns T if the action is success
    -- and  F on failure
    --
    IF ( l_return_status = FND_API.G_TRUE OR
         l_return_status = FND_API.G_FALSE )
    THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF ;

--    dbms_output.put_line('value: '||x_return_status);

EXCEPTION

    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            (
              G_PKG_NAME,
              l_api_name
            );
    END IF;

END Grant_Attachment_Access;



PROCEDURE Revoke_Attachments_OCSRole
(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_entity_name           IN  VARCHAR2,
   p_pk1_value             IN  VARCHAR2,
   p_pk2_value             IN  VARCHAR2,
   p_pk3_value             IN  VARCHAR2,
   p_pk4_value             IN  VARCHAR2,
   p_pk5_value             IN  VARCHAR2,
   p_ocs_role              IN  VARCHAR2,
   p_party_ids             IN  FND_TABLE_OF_NUMBER,
   p_api_caller            IN  VARCHAR2 := NULL,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
)
IS

    l_api_name        CONSTANT VARCHAR2(50) := 'Revoke_Attachments_OCSRole';
    l_return_status    VARCHAR2(1) ;
    l_error_code      NUMBER(1) ;
    l_role_name       FND_MENUS.MENU_NAME%TYPE;
    l_user_name       VARCHAR2(30);
    l_service_url       VARCHAR2(100);
    l_user_login       VARCHAR2(30);
    l_protocol        VARCHAR2(30);
    get_attachments           DYNAMIC_CUR;
    l_dynamic_sql              VARCHAR2(32767);
    l_media_id        NUMBER;
    l_node_id    NUMBER;
    l_created_by  NUMBER;
    l_file_type     VARCHAR2(10);
    l_ocs_role_to_revoke  VARCHAR2(30);
    l_entity_name      VARCHAR2(30);
    l_party_type             hz_parties.party_type%TYPE;
    l_rows NUMBER := 0;

BEGIN

    l_entity_name := p_entity_name;

    l_dynamic_sql :=   ' SELECT media_id, dm_node, A.created_by, dm_type' ||
                                ' FROM FND_DOCUMENTS D, FND_ATTACHED_DOCUMENTS A' ||
                                ' WHERE  A.DOCUMENT_ID = D.DOCUMENT_ID  ' ||
                                ' AND A.ENTITY_NAME = :entity_name ' ||
                                ' AND A.PK1_VALUE   =  :pk1_value ';

    IF (p_entity_name = 'DOM_DOCUMENT_REVISION') THEN

        l_dynamic_sql := l_dynamic_sql || ' AND A.PK2_VALUE = :pk2_value';

        l_entity_name := 'DOM_DOCUMENT_VERSION';

        OPEN get_attachments FOR l_dynamic_sql
        USING IN l_entity_name,
                     IN p_pk1_value,
                     IN p_pk2_value;

ELSE

        OPEN get_attachments FOR l_dynamic_sql
        USING IN l_entity_name,
                     IN p_pk1_value;

END IF;

LOOP

      FETCH get_attachments  INTO l_media_id, l_node_id, l_created_by, l_file_type;
      EXIT WHEN get_attachments%NOTFOUND;

      FOR lcount in p_party_ids.first .. p_party_ids.last
      LOOP

             l_rows := Check_For_Duplicate_Grant
                                                  (
                                                       p_entity_name         => l_entity_name,
                                                       p_pk1_value           => p_pk1_value,
                                                       p_pk2_value           => p_pk2_value,
                                                       p_pk3_value           => p_pk3_value,
                                                       p_pk4_value           => p_pk4_value,
                                                       p_pk5_value          =>  p_pk5_value,
                                                       p_file_id                => l_media_id,
                                                       p_repos_id            => l_node_id,
                                                       p_party_id             => p_party_ids(lcount)
                                                  );

if( l_rows <= 1) then
    l_ocs_role_to_revoke := G_OCS_ROLE;
end if;

              SELECT service_url, protocol
              INTO l_service_url, l_protocol
              FROM DOM_REPOSITORIES WHERE id = l_node_id ;

              SELECT user_name INTO l_user_name
              FROM FND_USER where person_party_id = p_party_ids(lcount);

              --Get the Attachment created by user login.
              -- This is required to make WS connection while trying to grant role to the user.
              SELECT user_name INTO l_user_login
              FROM fnd_user
              WHERE user_id = l_created_by ;

              SELECT party_type INTO l_party_type
              FROM hz_parties
              WHERE party_id = p_party_ids(lcount);

              IF(l_party_type = 'PERSON') THEN
                  l_party_type := 'USER';
              END IF;

          IF(l_ocs_role_to_revoke IS NOT NULL) THEN

              IF (l_protocol = 'WEBSERVICES') THEN

                        DOM_WS_INTERFACE_PUB.Remove_Attachments_OCSRole
                        (
                           p_api_version        => p_api_version,
                           p_service_url        => l_service_url,
                           p_family_id              => l_media_id,
                           p_role                   => l_ocs_role_to_revoke,
                           p_user_name          => l_user_name,
                           p_user_login          => l_user_login,
                           x_return_status      => x_return_status,
                           x_msg_count                  => x_msg_count,
                           x_msg_data                   => x_msg_data
                       );

              END IF;

         END IF;

          -- Delete from
          DELETE FROM DOM_FOLDER_FILE_MEMBERSHIPS
          WHERE REPOSITORY_ID = l_node_id
          AND REPOSITORY_ITEM_ID = l_media_id
          AND REPOSITORY_ITEM_TYPE = l_file_type
          AND ENTITY_NAME = l_entity_name
          AND (  (PK1_VALUE=p_pk1_value ) OR ( (PK1_VALUE IS NULL) AND (p_pk1_value  IS NULL))  )
          AND (  (PK2_VALUE=p_pk2_value ) OR ( (PK2_VALUE IS NULL) AND (p_pk2_value IS NULL)))
          AND (  (PK3_VALUE=p_pk3_value ) OR ( (PK3_VALUE IS NULL) AND (p_pk3_value  IS NULL))  )
          AND (  (PK4_VALUE=p_pk4_value ) OR ( (PK4_VALUE IS NULL) AND (p_pk4_value IS NULL)))
          AND (  (PK5_VALUE=p_pk5_value ) OR ( (PK5_VALUE IS NULL) AND (p_pk5_value  IS NULL))  )
          AND PARTY_TYPE = l_party_type
          AND PARTY_ID =  p_party_ids(lcount)
          AND OFO_ROLE = G_OCS_ROLE ;

                      --
        END LOOP;



END LOOP;

CLOSE get_attachments;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    --
    -- returns T if the action is success
    -- and  F on failure
    --
    IF ( l_return_status = FND_API.G_TRUE OR
         l_return_status = FND_API.G_FALSE )
    THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF ;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            (
              G_PKG_NAME,
              l_api_name
            );
    END IF;

END Revoke_Attachments_OCSRole;



 PROCEDURE     Get_User_Roles
  (
   p_object_id            IN  NUMBER,
   p_document_id      IN NUMBER,
   p_revision_id          IN NUMBER,
   p_change_id            IN NUMBER,
   p_change_line_id   IN  NUMBER,
   p_party_id             IN  NUMBER,
   x_role_ids             OUT NOCOPY FND_ARRAY_OF_NUMBER_25
 )
   IS
  l_party_id           NUMBER;

  CURSOR get_user_roles      (
                               cp_object_id            NUMBER,
                               cp_document_id      VARCHAR2,
                               cp_revision_id      VARCHAR2,
                               cp_change_id      VARCHAR2,
                               cp_change_line_id      VARCHAR2) IS
        SELECT grants.menu_id menu_id
        FROM fnd_grants grants
        WHERE grants.object_id = cp_object_id
        AND ((grants.instance_pk1_value=cp_document_id )
            OR((grants.instance_pk1_value = '*NULL*') AND (cp_document_id  IS NULL)))
        AND ((grants.instance_pk2_value=cp_revision_id )
            OR((grants.instance_pk2_value = '*NULL*') AND (cp_revision_id IS NULL)))
        AND ((grants.parameter1=cp_change_id )
            OR((grants.parameter1 IS NULL)  AND (cp_change_id IS NULL)))
        AND ((grants.parameter2=cp_change_line_id )
            OR((grants.parameter2 IS NULL)  AND (cp_change_line_id IS  NULL))
        );

  l_grantee_type             hz_parties.party_type%TYPE;
  l_grantee_key             fnd_grants.grantee_key%TYPE;
  l_instance_set_id       fnd_grants.instance_set_id%TYPE;
  l_instance_pk1_value  fnd_grants.instance_pk1_value%TYPE;
  l_dummy                 VARCHAR2(1);
  l_index                     INTEGER;

  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;

BEGIN

       l_index := 0;

       OPEN get_party_type (cp_party_id =>p_party_id);
       FETCH get_party_type INTO l_grantee_type;
       CLOSE get_party_type;

      x_role_ids := FND_ARRAY_OF_NUMBER_25();

      FOR rec IN  get_user_roles
                  (
                      cp_object_id          => p_object_id,
                      cp_document_id => p_document_id,
                      cp_revision_id => p_revision_id,
                      cp_change_id => p_change_id,
                      cp_change_line_id => P_change_line_id
                  )
       LOOP
            x_role_ids.extend(l_index+1);
            x_role_ids(l_index+1) := rec.menu_id;
            l_index := l_index + 1;
       END LOOP;

EXCEPTION
      WHEN OTHERS THEN
           NULL;

END get_user_roles;


FUNCTION  Check_For_Duplicate_Grant
  (
   p_entity_name            IN  VARCHAR2,
   p_pk1_value      IN VARCHAR2,
   p_pk2_value          IN VARCHAR2,
   p_pk3_value            IN VARCHAR2,
   p_pk4_value     IN  VARCHAR2,
   p_pk5_value     IN  VARCHAR2,
   p_file_id                IN  NUMBER,
   p_repos_id            IN NUMBER,
   p_party_id             IN  NUMBER
 )
RETURN NUMBER
IS

  l_party_type             hz_parties.party_type%TYPE;
  l_count    NUMBER := 0;

  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;

BEGIN

       OPEN get_party_type (cp_party_id =>p_party_id);
       FETCH get_party_type INTO l_party_type;
       CLOSE get_party_type;

        IF(l_party_type = 'PERSON') THEN
              l_party_type := 'USER';
        END IF;

        SELECT count(*) INTO l_count
        FROM DOM_FOLDER_FILE_MEMBERSHIPS
        WHERE REPOSITORY_ITEM_ID = p_file_id
        AND REPOSITORY_ID = p_repos_id
        AND PARTY_ID = p_party_id
        AND PARTY_TYPE = l_party_type
        AND entity_name = p_entity_name;
--        AND (  (pk1_value=p_pk1_value ) OR ( (pk1_value IS NULL) AND (p_pk1_value  IS NULL))  )
--        AND (  (pk2_value=p_pk2_value ) OR ( (pk2_value IS NULL) AND (p_pk2_value IS NULL)))
--        AND (  (pk3_value=p_pk3_value ) OR ( (pk3_value IS NULL) AND (p_pk3_value  IS NULL))  )
--        AND (  (pk4_value=p_pk4_value ) OR ( (pk4_value IS NULL) AND (p_pk4_value IS NULL)))
--        AND (  (pk5_value=p_pk5_value ) OR ( (pk5_value IS NULL) AND (p_pk5_value  IS NULL))  );

RETURN l_count;

EXCEPTION
      WHEN OTHERS THEN
             RETURN l_count;

END Check_For_Duplicate_Grant;


FUNCTION check_user_privilege
  (
   p_api_version        IN  NUMBER,
   p_privilege          IN  VARCHAR2,
   p_object_name        IN  VARCHAR2,
   p_instance_pk1_value IN  VARCHAR2,
   p_instance_pk2_value IN  VARCHAR2,
   p_instance_pk3_value IN  VARCHAR2,
   p_instance_pk4_value IN  VARCHAR2,
   p_instance_pk5_value IN  VARCHAR2,
   p_party_id           IN  NUMBER
 )
 RETURN VARCHAR2
 IS
    -- Start OF comments
    -- API name  : check_user_privilege
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : check a user's privilege on  object instance(s)
    --             If this operation fails then the check is not
    --             done and error code is returned.

    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments


  l_grantee_key   fnd_grants.GRANTEE_KEY%TYPE;
  l_grantee_type  fnd_grants.GRANTEE_TYPE%TYPE;

 BEGIN
         l_grantee_key := 'HZ_PARTY:'||p_party_id;

         RETURN  EGO_DATA_SECURITY.check_function
                 (
                    p_api_version        => p_api_version,
                    p_function           => p_privilege,
                    p_object_name        => p_object_name,
                    p_instance_pk1_value => p_instance_pk1_value,
                    p_instance_pk2_value => p_instance_pk2_value,
                    p_instance_pk3_value => p_instance_pk3_value,
                    p_instance_pk4_value => p_instance_pk4_value,
                    p_instance_pk5_value => p_instance_pk5_value,
                    p_user_name          => l_grantee_key
                 );
  END check_user_privilege;


END DOM_SECURITY_PUB;

/
