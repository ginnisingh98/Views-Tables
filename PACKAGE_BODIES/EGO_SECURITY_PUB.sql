--------------------------------------------------------
--  DDL for Package Body EGO_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_SECURITY_PUB" AS
/* $Header: EGOPSECB.pls 120.3 2006/04/13 04:51:31 ninaraya noship $ */
/*---------------------------------------------------------------------------+
 | This package contains public API for Applications Security                |
 +---------------------------------------------------------------------------*/

  G_PKG_NAME    CONSTANT VARCHAR2(30):= 'EGO_SECURITY_PUB';

 --Private - check_override_datasec
  ------------------------------------
 -- FUNCTION check_override_datasec
 --  (
 --    p_party_id       in   NUMBER
 -- ) RETURN BOOLEAN
 -- IS
 --    l_dummy   VARCHAR2(1) :='';
 --   CURSOR  check_override_function(cp_party_id  NUMBER)
 --   IS
 --     SELECT  'X'
 --     FROM fnd_form_functions functions,
 --        fnd_user users,
 --        fnd_menu_entries role_privileges,
 --          fnd_responsibility resp,
 --        fnd_user_resp_groups user_resps
 --     WHERE users.customer_id=cp_party_id
 --     AND user_resps.start_date<= sysdate
 --     AND nvl( user_resps.end_date,sysdate+1 ) >= sysdate
 --     AND users.user_id=user_resps.user_id
 --     AND resp.responsibility_id=user_resps.responsibility_id
 --     AND resp.menu_id=role_privileges.menu_id
 --     AND role_privileges.function_id=functions.function_id
 --     AND functions.function_name = 'EGO_OVERRIDE_DATASEC';
 -- BEGIN
 --    OPEN  check_override_function(cp_party_id =>p_party_id);
 --    FETCH check_override_function INTO l_dummy;
 --    IF(check_override_function%FOUND) THEN
 --        CLOSE check_override_function;
 --        RETURN TRUE;
 --    ELSE
 --        CLOSE check_override_function;
 --        RETURN FALSE;
 --    END IF;
 -- END check_override_datasec;
------------------------------------------



   --1. Grant Role
  ------------------------------------
  PROCEDURE grant_role
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_instance_set_id       IN  NUMBER,
   p_instance_pk1_value    IN  VARCHAR2,
   p_instance_pk2_value    IN  VARCHAR2,
   p_instance_pk3_value    IN  VARCHAR2,
   p_instance_pk4_value    IN  VARCHAR2,
   p_instance_pk5_value    IN  VARCHAR2,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER
  )
  IS

  x_grant_guid         fnd_grants.grant_guid%TYPE;
  l_grantee_type       hz_parties.party_type%TYPE;
  l_instance_type      fnd_grants.instance_type%TYPE;
  l_grantee_key        fnd_grants.grantee_key%TYPE;
  l_dummy              VARCHAR2(1);
  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;

  CURSOR check_fnd_grant_exist (cp_grantee_key       VARCHAR2,
                               cp_grantee_type            VARCHAR2,
                               cp_menu_name               VARCHAR2,
                               cp_object_name             VARCHAR2,
                               cp_instance_type           VARCHAR2,
                               cp_instance_pk1_value      VARCHAR2,
                               cp_instance_pk2_value      VARCHAR2,
                               cp_instance_pk3_value      VARCHAR2,
                               cp_instance_pk4_value      VARCHAR2,
                               cp_instance_pk5_value      VARCHAR2,
                               cp_instance_set_id         NUMBER,
                               cp_start_date              DATE,
                               cp_end_date                DATE) IS

        SELECT 'X'
        FROM fnd_grants grants,
             fnd_objects obj,
             fnd_menus menus
        WHERE grants.grantee_key=cp_grantee_key
        AND  grants.grantee_type=cp_grantee_type
        AND  grants.menu_id=menus.menu_id
        AND  menus.menu_name=cp_menu_name
        AND  grants.object_id = obj.object_id
        AND obj.obj_name=cp_object_name
        AND grants.instance_type=cp_instance_type
        AND ((grants.instance_pk1_value=cp_instance_pk1_value )
            OR((grants.instance_pk1_value = '*NULL*') AND (cp_instance_pk1_value IS NULL)))
        AND ((grants.instance_pk2_value=cp_instance_pk2_value )
            OR((grants.instance_pk2_value = '*NULL*') AND (cp_instance_pk2_value IS NULL)))
        AND ((grants.instance_pk3_value=cp_instance_pk3_value )
            OR((grants.instance_pk3_value = '*NULL*') AND (cp_instance_pk3_value IS NULL)))
        AND ((grants.instance_pk4_value=cp_instance_pk4_value )
            OR((grants.instance_pk4_value = '*NULL*') AND (cp_instance_pk4_value IS NULL)))
        AND ((grants.instance_pk5_value=cp_instance_pk5_value )
            OR((grants.instance_pk5_value = '*NULL*') AND (cp_instance_pk5_value IS NULL)))
        AND ((grants.instance_set_id=cp_instance_set_id )
            OR((grants.instance_set_id IS NULL ) AND (cp_instance_set_id IS NULL)))
        AND (((grants.start_date<=cp_start_date )
            AND (( grants.end_date IS NULL) OR (cp_start_date <=grants.end_date )))
        OR ((grants.start_date >= cp_start_date )
            AND (( cp_end_date IS NULL)  OR (cp_end_date >=grants.start_date))));



  BEGIN
       IF( p_instance_type <> 'INSTANCE') THEN
          l_instance_type:='SET';
       ELSE
          l_instance_type:=p_instance_type;
       END IF;
       OPEN get_party_type (cp_party_id =>p_party_id);
       FETCH get_party_type INTO l_grantee_type;
       CLOSE get_party_type;
       IF(  p_party_id = -1000) THEN
          l_grantee_type :='GLOBAL';
          l_grantee_key:='HZ_GLOBAL:'||p_party_id;
       ELSIF (l_grantee_type ='PERSON') THEN
          l_grantee_type:='USER';
          l_grantee_key:='HZ_PARTY:'||p_party_id;
       ELSIF (l_grantee_type ='GROUP') THEN
          l_grantee_type:='GROUP';
          l_grantee_key:='HZ_GROUP:'||p_party_id;
       ELSIF (l_grantee_type ='ORGANIZATION') THEN
          l_grantee_type:='COMPANY';
          l_grantee_key:='HZ_COMPANY:'||p_party_id;
       ELSE
           null;
       END IF;

       OPEN check_fnd_grant_exist(cp_grantee_key  => l_grantee_key,
                      cp_grantee_type       => l_grantee_type,
                      cp_menu_name          => p_role_name,
                      cp_object_name        => p_object_name,
                      cp_instance_type      => l_instance_type,
                      cp_instance_pk1_value => p_instance_pk1_value,
                      cp_instance_pk2_value => p_instance_pk2_value,
                      cp_instance_pk3_value => p_instance_pk3_value,
                      cp_instance_pk4_value => p_instance_pk4_value,
                      cp_instance_pk5_value => p_instance_pk5_value,
                      cp_instance_set_id    => p_instance_set_id,
                      cp_start_date         => p_start_date,
                      cp_end_date           => p_end_date);

       FETCH check_fnd_grant_exist INTO l_dummy;
       IF( check_fnd_grant_exist%NOTFOUND) THEN
         fnd_grants_pkg.grant_function(
              p_api_version        => 1.0,
              p_menu_name          => p_role_name ,
              p_object_name        => p_object_name,
              p_instance_type      => l_instance_type,
              p_instance_set_id    => p_instance_set_id,
              p_instance_pk1_value => p_instance_pk1_value,
              p_instance_pk2_value => p_instance_pk2_value,
              p_instance_pk3_value => p_instance_pk3_value,
              p_instance_pk4_value => p_instance_pk4_value,
              p_instance_pk5_value => p_instance_pk5_value,
              p_grantee_type       => l_grantee_type,
              p_grantee_key        => l_grantee_key,
              p_start_date         => p_start_date,
              p_end_date           => p_end_date,
              p_program_name       => null,
              p_program_tag        => null,
              x_grant_guid         => x_grant_guid,
              x_success            => x_return_status,
              x_errorcode          => x_errorcode
          );
        ELSE
          x_return_status:='F';
        END IF;

        CLOSE check_fnd_grant_exist;

  END grant_role;
-------------------------------------------------------------
   --1 a. Grant Privilege
  ------------------------------------
  PROCEDURE grant_role
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_object_key            IN  NUMBER,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER
  )
  IS
    -- Start OF comments
    -- API name  : Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant a Role on object instances to a Party.
    --             If this operation fails then the grant is not
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  l_instance_set_id    fnd_grants.instance_set_id%TYPE;
  l_instance_pk1_value fnd_grants.instance_pk1_value%TYPE;
  BEGIN
      IF( p_instance_type ='SET') THEN
         l_instance_set_id:=p_object_key;
         l_instance_pk1_value:= null;
       ELSE
         l_instance_set_id:=null;
         l_instance_pk1_value:= to_char(p_object_key);
       END IF;
       grant_role
       (
         p_api_version         => p_api_version,
         p_role_name           => p_role_name,
         p_object_name         => p_object_name,
         p_instance_type       => p_instance_type,
         p_instance_set_id     => l_instance_set_id,
         p_instance_pk1_value  => l_instance_pk1_value,
         p_instance_pk2_value  => null,
         p_instance_pk3_value  => null,
         p_instance_pk4_value  => null,
         p_instance_pk5_value  => null,
         p_party_id            => p_party_id,
         p_start_date          => p_start_date,
         p_end_date            => p_end_date,
         x_return_status       => x_return_status,
         x_errorcode           => x_errorcode
       );

   END grant_role;
---------------------------------------------------------------------
  ------------------------------------
   --11. Grant Role
  ------------------------------------
  PROCEDURE grant_role_guid
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_instance_set_id       IN  NUMBER,
   p_instance_pk1_value    IN  VARCHAR2,
   p_instance_pk2_value    IN  VARCHAR2,
   p_instance_pk3_value    IN  VARCHAR2,
   p_instance_pk4_value    IN  VARCHAR2,
   p_instance_pk5_value    IN  VARCHAR2,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER,
   x_grant_guid            OUT NOCOPY RAW
  )
  IS

  --x_grant_guid         fnd_grants.grant_guid%TYPE;
  l_grantee_type       hz_parties.party_type%TYPE;
  l_instance_type      fnd_grants.instance_type%TYPE;
  l_grantee_key        fnd_grants.grantee_key%TYPE;
  l_dummy              VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(4000);
  CURSOR get_party_type (cp_party_id NUMBER) IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;

  CURSOR check_fnd_grant_exist (cp_grantee_key       VARCHAR2,
                               cp_grantee_type            VARCHAR2,
                               cp_menu_name               VARCHAR2,
                               cp_object_name             VARCHAR2,
                               cp_instance_type           VARCHAR2,
                               cp_instance_pk1_value      VARCHAR2,
                               cp_instance_pk2_value      VARCHAR2,
                               cp_instance_pk3_value      VARCHAR2,
                               cp_instance_pk4_value      VARCHAR2,
                               cp_instance_pk5_value      VARCHAR2,
                               cp_instance_set_id         NUMBER,
                               cp_start_date              DATE,
                               cp_end_date                DATE) IS

        SELECT 'X'
        FROM fnd_grants grants,
             fnd_objects obj,
             fnd_menus menus
        WHERE grants.grantee_key=cp_grantee_key
        AND  grants.grantee_type=cp_grantee_type
        AND  grants.menu_id=menus.menu_id
        AND  menus.menu_name=cp_menu_name
        AND  grants.object_id = obj.object_id
        AND obj.obj_name=cp_object_name
        AND grants.instance_type=cp_instance_type
        AND ((grants.instance_pk1_value=cp_instance_pk1_value )
            OR((grants.instance_pk1_value = '*NULL*') AND (cp_instance_pk1_value IS NULL)))
        AND ((grants.instance_pk2_value=cp_instance_pk2_value )
            OR((grants.instance_pk2_value = '*NULL*') AND (cp_instance_pk2_value IS NULL)))
        AND ((grants.instance_pk3_value=cp_instance_pk3_value )
            OR((grants.instance_pk3_value = '*NULL*') AND (cp_instance_pk3_value IS NULL)))
        AND ((grants.instance_pk4_value=cp_instance_pk4_value )
            OR((grants.instance_pk4_value = '*NULL*') AND (cp_instance_pk4_value IS NULL)))
        AND ((grants.instance_pk5_value=cp_instance_pk5_value )
            OR((grants.instance_pk5_value = '*NULL*') AND (cp_instance_pk5_value IS NULL)))
        AND ((grants.instance_set_id=cp_instance_set_id )
            OR((grants.instance_set_id IS NULL ) AND (cp_instance_set_id IS NULL)))
        AND (((grants.start_date<=cp_start_date )
            AND (( grants.end_date IS NULL) OR (cp_start_date <=grants.end_date )))
        OR ((grants.start_date >= cp_start_date )
            AND (( cp_end_date IS NULL)  OR (cp_end_date >=grants.start_date))));

    v_start_date DATE := sysdate;

  BEGIN
       if (p_start_date IS NULL) THEN
      v_start_date := sysdate;
       else
      v_start_date := p_start_date;
       end if;

       IF( p_instance_type <> 'INSTANCE') THEN
          l_instance_type:='SET';
       ELSE
          l_instance_type:=p_instance_type;
       END IF;
       OPEN get_party_type (cp_party_id =>p_party_id);
       FETCH get_party_type INTO l_grantee_type;
       CLOSE get_party_type;
       IF(  p_party_id = -1000) THEN
          l_grantee_type :='GLOBAL';
          l_grantee_key:='HZ_GLOBAL:'||p_party_id;
       ELSIF (l_grantee_type ='PERSON') THEN
          l_grantee_type:='USER';
          l_grantee_key:='HZ_PARTY:'||p_party_id;
       ELSIF (l_grantee_type ='GROUP') THEN
          l_grantee_type:='GROUP';
          l_grantee_key:='HZ_GROUP:'||p_party_id;
       ELSIF (l_grantee_type ='ORGANIZATION') THEN
          l_grantee_type:='COMPANY';
          l_grantee_key:='HZ_COMPANY:'||p_party_id;
       ELSE
           null;
       END IF;

       OPEN check_fnd_grant_exist(cp_grantee_key  => l_grantee_key,
                      cp_grantee_type       => l_grantee_type,
                      cp_menu_name          => p_role_name,
                      cp_object_name        => p_object_name,
                      cp_instance_type      => l_instance_type,
                      cp_instance_pk1_value => p_instance_pk1_value,
                      cp_instance_pk2_value => p_instance_pk2_value,
                      cp_instance_pk3_value => p_instance_pk3_value,
                      cp_instance_pk4_value => p_instance_pk4_value,
                      cp_instance_pk5_value => p_instance_pk5_value,
                      cp_instance_set_id    => p_instance_set_id,
                      cp_start_date         => v_start_date,
                      cp_end_date           => p_end_date);

       FETCH check_fnd_grant_exist INTO l_dummy;
       IF( check_fnd_grant_exist%NOTFOUND) THEN
         fnd_grants_pkg.grant_function(
              p_api_version        => 1.0,
              p_menu_name          => p_role_name ,
              p_object_name        => p_object_name,
              p_instance_type      => l_instance_type,
              p_instance_set_id    => p_instance_set_id,
              p_instance_pk1_value => p_instance_pk1_value,
              p_instance_pk2_value => p_instance_pk2_value,
              p_instance_pk3_value => p_instance_pk3_value,
              p_instance_pk4_value => p_instance_pk4_value,
              p_instance_pk5_value => p_instance_pk5_value,
              p_grantee_type       => l_grantee_type,
              p_grantee_key        => l_grantee_key,
              p_start_date         => v_start_date,
              p_end_date           => p_end_date,
              p_program_name       => null,
              p_program_tag        => null,
              x_grant_guid         => x_grant_guid,
              x_success            => x_return_status,
              x_errorcode          => x_errorcode
              );
          -- added for 5151106
          IF x_return_status = FND_API.G_TRUE AND l_grantee_type = 'COMPANY' THEN
            EGO_PARTY_PUB.setup_enterprise_user
                        (p_company_id     => p_party_id
                        ,x_return_status  => x_return_status
                        ,x_msg_count      => l_msg_count
                        ,x_msg_data       => l_msg_data
                        );
            IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := FND_API.G_TRUE;
            ELSE
              x_return_status := FND_API.G_FALSE;
            END IF;
            IF x_return_status = FND_API.G_FALSE THEN
              -- add message to fnd_stack
              fnd_message.Set_Name('EGO','EGO_GENERIC_MSG_TEXT');
              fnd_message.set_token('MESSAGE', l_msg_data);
              fnd_msg_pub.Add;
            END IF;
          END IF;
        ELSE
          -- add message to fnd_stack for Bug 3352200
	  FND_MSG_PUB.INITIALIZE;
	  fnd_message.Set_Name('EGO','EGO_DUPLICATE_ROLE_FOR_GRANTEE');
	  fnd_msg_pub.Add;
          -- end add message to fnd_stack for Bug 3352200
          x_return_status:='F';
        END IF;

        CLOSE check_fnd_grant_exist;

  END grant_role_guid;
-------------------------------------------------------------
   --11 a. Grant Privilege
  ------------------------------------
  PROCEDURE grant_role_guid
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_object_key            IN  NUMBER,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER,
   x_grant_guid            OUT NOCOPY RAW
  )
  IS
    -- Start OF comments
    -- API name  : Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant a Role on object instances to a Party.
    --             If this operation fails then the grant is not
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  l_instance_set_id    fnd_grants.instance_set_id%TYPE;
  l_instance_pk1_value fnd_grants.instance_pk1_value%TYPE;
  v_start_date  DATE := sysdate;

  BEGIN
      IF( p_instance_type ='SET') THEN
         l_instance_set_id:=p_object_key;
         l_instance_pk1_value:= null;
       ELSE
         l_instance_set_id:=null;
         l_instance_pk1_value:= to_char(p_object_key);
       END IF;

       if (p_start_date IS NULL) THEN
      v_start_date := sysdate;
       else
      v_start_date := p_start_date;
       end if;

       grant_role_guid
       (
         p_api_version         => p_api_version,
         p_role_name           => p_role_name,
         p_object_name         => p_object_name,
         p_instance_type       => p_instance_type,
         p_instance_set_id     => l_instance_set_id,
         p_instance_pk1_value  => l_instance_pk1_value,
         p_instance_pk2_value  => null,
         p_instance_pk3_value  => null,
         p_instance_pk4_value  => null,
         p_instance_pk5_value  => null,
         p_party_id            => p_party_id,
         p_start_date          => v_start_date,
         p_end_date            => p_end_date,
         x_return_status       => x_return_status,
         x_errorcode           => x_errorcode,
         x_grant_guid          => x_grant_guid
       );

   END grant_role_guid;
---------------------------------------------------------------------


  --2. Revoke Grant
  --------------------------
  PROCEDURE revoke_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_errorcode      OUT NOCOPY NUMBER
  )
  IS
    -- Start OF comments
    -- API name  : Revoke
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Revoke a Party's role on object instances.
    --             If this operation fails then the revoke is
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

   l_grant_guid   fnd_grants.grant_guid%TYPE;
   CURSOR get_grant_guid(cp_grant_id VARCHAR2)
   IS
     SELECT grant_guid
     FROM fnd_grants
     WHERE grant_guid=HEXTORAW(cp_grant_id);

   BEGIN
      OPEN get_grant_guid(cp_grant_id=>p_grant_guid);
      FETCH get_grant_guid INTO l_grant_guid;
      CLOSE get_grant_guid;

      fnd_grants_pkg.revoke_grant(
        p_api_version  => p_api_version,
        p_grant_guid   => l_grant_guid  ,
        x_success      => x_return_status,
        x_errorcode    => x_errorcode
      );

  END revoke_grant;
  ----------------------------------------------------------------------------



  --3. Check User Privilege
  ------------------------------------
  FUNCTION check_user_privilege
  (
   p_api_version    IN  NUMBER,
   p_privilege      IN  VARCHAR2,
   p_object_name    IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_user_id        IN  NUMBER
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
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_privilege        IN  VARCHAR2 (required)
    --             name of the privilege (function name)
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the privilege should be checked
    --
    --             p_object_key       IN  NUMBER (required)
    --             object key to an instance
    --
    --             p_user_id         IN  NUMBER (required)
    --             user for whom the privilege is checked
    --
    --     OUT  :
    --             RETURN
    --                   FND_API.G_TRUE  privilege EXISTS
    --                   FND_API.G_FALSE NO privilege
    --                   FND_API.G_RET_STS_ERROR if error
    --             FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --

    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.


   l_party_id               NUMBER;


   CURSOR get_party_id(cp_user_id  NUMBER) IS
        SELECT customer_id
        FROM fnd_user
        WHERE user_id=cp_user_id;

  BEGIN

     OPEN get_party_id (cp_user_id => p_user_id);
     FETCH get_party_id INTO l_party_id;
     CLOSE get_party_id;
     RETURN check_party_privilege ( p_api_version => p_api_version,
                                    p_privilege   => p_privilege,
                                    p_object_name => p_object_name,
                                    p_object_key  => p_object_key,
                                    p_party_id    => l_party_id);



  END check_user_privilege;
  ----------------------------------------------------------------------------

 --3.b.1 Check Party Privilege
  ------------------------------------
  FUNCTION check_party_privilege
  (
   p_api_version    IN  NUMBER,
   p_privilege      IN  VARCHAR2,
   p_object_name    IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER
 )
 RETURN VARCHAR2
 IS
  BEGIN
   return check_party_privilege
   (  p_api_version        => p_api_version,
      p_privilege          => p_privilege,
      p_object_name        => p_object_name,
      p_instance_pk1_value => to_char(p_object_key),
      p_instance_pk2_value => null,
      p_instance_pk3_value => null,
      p_instance_pk4_value => null,
      p_instance_pk5_value => null,
      p_party_id           => p_party_id
   );

 END check_party_privilege;
----------------------------------------------------

  --3.b.2 Check Party Privilege
  ------------------------------------
  FUNCTION check_party_privilege
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
    -- API name  : check_party_privilege
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
   --  IF(check_override_datasec(p_party_id)) THEN
   --    RETURN 'T';
   --  END IF;
         IF(  p_party_id = -1000) THEN
           l_grantee_key:='HZ_GLOBAL:'||p_party_id;
         ELSE
           l_grantee_key:='HZ_PARTY:'||p_party_id;
         END IF;
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
  END check_party_privilege;
  ----------------------------------------------------------------------------


  --4. Get Privileges
  ------------------------------------
  PROCEDURE get_privileges
  (
   p_api_version    IN  NUMBER,
   p_object_name      IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_user_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privilege_tbl  OUT NOCOPY EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE
   )
   IS

    -- Start OF comments
    -- API name  : get_privileges
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get the list of privileges user has on the object instance
    --             If this operation fails then the get is not
    --             done and error code is returned.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
      l_party_id     NUMBER;



      CURSOR get_party_id(cp_user_id  NUMBER) IS
          SELECT customer_id
          FROM fnd_user
          WHERE user_id=cp_user_id;
  BEGIN

     OPEN get_party_id (cp_user_id => p_user_id);
     FETCH get_party_id INTO l_party_id;
     CLOSE get_party_id;

      get_party_privileges  ( p_api_version   => p_api_version,
                              p_object_name   => p_object_name,
                              p_object_key    => p_object_key ,
                              p_party_id      => l_party_id,
                              x_return_status => x_return_status,
                              x_privilege_tbl => x_privilege_tbl);

  END get_privileges;
  ----------------------------------------------------------------------------

  --4 b.1 Get Privileges
  ------------------------------------
  PROCEDURE get_party_privileges
  (
   p_api_version    IN  NUMBER,
   p_object_name    IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privilege_tbl  OUT NOCOPY EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE
   ) IS
    -- Start OF comments
    -- API name  : get_privileges
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get the list of privileges user has on the object instance
    --             If this operation fails then the get is not
    --             done and error code is returned.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  BEGIN
    get_party_privileges
    (
      p_api_version        => p_api_version,
      p_object_name        => p_object_name,
      p_instance_pk1_value => to_char(p_object_key),
      p_instance_pk2_value => null,
      p_instance_pk3_value => null,
      p_instance_pk4_value => null,
      p_instance_pk5_value => null,
      p_party_id           => p_party_id,
      x_return_status      => x_return_status,
      x_privilege_tbl      => x_privilege_tbl
    );
  END get_party_privileges;

 ------------------------------------


  --4 b.2 get_party_privileges
  ------------------------------------
  PROCEDURE get_party_privileges
  (
   p_api_version        IN  NUMBER,
   p_object_name        IN  VARCHAR2,
   p_instance_pk1_value IN  VARCHAR2,
   p_instance_pk2_value IN  VARCHAR2,
   p_instance_pk3_value IN  VARCHAR2,
   p_instance_pk4_value IN  VARCHAR2,
   p_instance_pk5_value IN  VARCHAR2,
   p_party_id           IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_privilege_tbl      OUT NOCOPY EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE
   )
   IS

  --x_functions_tbl        EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE;

  l_grantee_key   fnd_grants.GRANTEE_KEY%TYPE;
  l_grantee_type  fnd_grants.GRANTEE_TYPE%TYPE;
  l_index         INTEGER;
  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;

  CURSOR get_object_privileges(cp_object_name VARCHAR2) IS
     select function_name
      from fnd_form_functions privs,
         fnd_objects obj
      where obj.obj_name=cp_object_name
      AND obj.object_id=privs.object_id;


  BEGIN
    -- IF(check_override_datasec(p_party_id)) THEN
    --    l_index:=0;
    --    x_return_status:='T';
    --    FOR rec IN get_object_privileges(cp_object_name => p_object_name) LOOP
    --      x_privilege_tbl(l_index):=rec.function_name;
    --      l_index:=l_index+1;
    --    END LOOP;
    --    RETURN ;
    -- END IF;

     IF(  p_party_id = -1000) THEN
           l_grantee_key:='HZ_GLOBAL:'||p_party_id;
         ELSE
           l_grantee_key:='HZ_PARTY:'||p_party_id;
     END IF;
     EGO_DATA_SECURITY.get_functions(
        p_api_version        => p_api_version,
        p_object_name        => p_object_name,
        p_instance_pk1_value => p_instance_pk1_value ,
        p_instance_pk2_value => p_instance_pk2_value,
        p_instance_pk3_value => p_instance_pk3_value,
        p_instance_pk4_value => p_instance_pk4_value,
        p_instance_pk5_value => p_instance_pk5_value,
        p_user_name          => l_grantee_key,
        x_return_status      => x_return_status,
        x_privilege_tbl      => x_privilege_tbl
     );

  END get_party_privileges;
  ----------------------------------------------------------------------------
--5. Get instances
-----------------------------------------------
  PROCEDURE get_instances_with_privilege
  (
   p_api_version       IN  NUMBER,
   p_privilege         IN  VARCHAR2,
   p_object_name       IN  VARCHAR2,
   p_party_id          IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_object_key_tbl    OUT NOCOPY ID_TBL_TYPE
  )
  IS
  x_object_key_tbl_fnd        EGO_DATA_SECURITY.EGO_INSTANCE_TABLE_TYPE;
  l_grantee_key               FND_GRANTS.grantee_key%TYPE;


  BEGIN


   IF(  p_party_id = -1000) THEN
           l_grantee_key:='HZ_GLOBAL:'||p_party_id;
   ELSE
           l_grantee_key:='HZ_PARTY:'||p_party_id;
   END IF;

  EGO_DATA_SECURITY.get_instances
  (
    p_api_version    => p_api_version,
    p_function       => p_privilege,
    p_object_name    => p_object_name,
    p_user_name      => l_grantee_key,
    x_return_status  => x_return_status,
    x_object_key_tbl => x_object_key_tbl_fnd
  );

   IF ( x_object_key_tbl_fnd.count >0) THEN
       FOR i IN x_object_key_tbl_fnd.first .. x_object_key_tbl_fnd.last LOOP
          x_object_key_tbl(i) :=x_object_key_tbl_fnd(i).PK1_VALUE;
       END LOOP;
     END IF;
    null;
   END get_instances_with_privilege;

---------------------------------------------------------------------
--6. get_instances_with_privilege_d
------------------------------------------------
 PROCEDURE get_instances_with_privilege_d
  (
   p_api_version      IN  NUMBER,
   p_privilege        IN  VARCHAR2,
   p_object_name      IN  VARCHAR2,
   p_party_id         IN  NUMBER,
   p_delimiter        IN  VARCHAR2 DEFAULT ',',
   x_return_status    OUT NOCOPY VARCHAR2,
   x_object_string    OUT NOCOPY VARCHAR2
  )
  IS
    -- Start OF comments
    -- API name  : get_instances_with_privilege_d
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get the list of instances on whcih the user has privilege
    --             If this operation fails then the get is not
    --             done and error code is returned. It is same as get_instances_with_privilege, but it         --             gives the output as comma delimited object_instances.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
      x_object_key_tbl  ID_TBL_TYPE ;


   BEGIN
      x_object_string:='';
      get_instances_with_privilege(
                                 p_api_version,
                                 p_privilege,
                                 p_object_name,
                                 p_party_id,
                                 x_return_status,
                     x_object_key_tbl);

   IF ( x_object_key_tbl.count > 0) THEN
      FOR i IN x_object_key_tbl.first .. x_object_key_tbl.last LOOP
         x_object_string:=x_object_string || x_object_key_tbl(i) || p_delimiter;
      END LOOP;
      x_object_string := RTRIM(x_object_string,p_delimiter);
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  END get_instances_with_privilege_d;
  ----------------------------------------------------------------------------

  --7.a. Get the list of predicates Strings on whcih user has privilege
  --------------------------------------------------------
  FUNCTION get_security_predicate
  (
   p_api_version          IN  NUMBER,
   p_user_id              IN  NUMBER,
   p_privilege            IN  VARCHAR2,
   p_object_name            IN  VARCHAR2,
   p_grant_type           IN  VARCHAR2 DEFAULT 'UNIVERSAL'
  ) RETURN VARCHAR2
  IS
    -- Start OF comments
    -- API name  : get_security_predicate
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
        l_api_name           CONSTANT VARCHAR2(30)  := 'get_security_predicate';
        l_pk1_column       fnd_objects.PK1_COLUMN_NAME%TYPE;

    CURSOR get_db_object (cp_object_name VARCHAR2) IS
        SELECT PK1_COLUMN_NAME
        FROM fnd_objects
        WHERE OBJ_NAME=cp_object_name;

  BEGIN

       OPEN get_db_object(p_object_name);
       FETCH get_db_object INTO l_pk1_column;
       CLOSE get_db_object;



       RETURN get_security_predicate(p_api_version=>p_api_version,
                                                     p_user_id =>p_user_id,
                                                     p_privilege =>p_privilege,
                                                     p_object_name =>p_object_name,
                                                     p_aliased_pk_column=>l_pk1_column,
                                                     p_grant_type => p_grant_type);


  END get_security_predicate;
------------------------------------------------------------------------------------

  --7.b. Get the list of predicates Strings on which user has privilege
  FUNCTION get_security_predicate
  (
   p_api_version          IN  NUMBER,
   p_user_id              IN  NUMBER,
   p_privilege            IN  VARCHAR2,
   p_object_name            IN  VARCHAR2,
   p_aliased_pk_column    IN  VARCHAR2,
   p_grant_type           IN  VARCHAR2 DEFAULT 'UNIVERSAL'
  ) RETURN VARCHAR2
  IS
    -- Start OF comments
    -- API name  : get_security_predicate
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Returns    the predicates belong to a user with a given privilege.


    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
   l_party_id   NUMBER;
   CURSOR get_party_id(cp_user_id  NUMBER) IS
        SELECT customer_id
        FROM fnd_user
        WHERE user_id=cp_user_id;

  BEGIN

     OPEN get_party_id (cp_user_id => p_user_id);
     FETCH get_party_id INTO l_party_id;
     CLOSE get_party_id;


     RETURN  get_party_security_predicate (
                       p_api_version => p_api_version,
                       p_party_id    => l_party_id,
                       p_privilege   => p_privilege,
                       p_object_name => p_object_name,
                       p_aliased_pk_column => p_aliased_pk_column,
                       p_grant_type  => p_grant_type);

  END get_security_predicate;
------------------------------------------------------------------------------------

 --7.c.1 Get the list of predicates Strings on whcih user has privilege
--------------------------------------
  FUNCTION get_party_security_predicate
  (
   p_api_version          IN  NUMBER,
   p_party_id             IN  NUMBER,
   p_privilege            IN  VARCHAR2,
   p_object_name          IN  VARCHAR2,
   p_aliased_pk_column    IN  VARCHAR2,
   p_grant_type           IN  VARCHAR2 DEFAULT 'UNIVERSAL'
  ) RETURN VARCHAR2
 IS

  x_return_status    VARCHAR2(1);
  BEGIN
    RETURN get_party_security_predicate
    (
       p_api_version         => p_api_version,
       p_party_id            => p_party_id,
       p_privilege           => p_privilege,
       p_object_name         => p_object_name,
       p_aliased_pk_column   => p_aliased_pk_column,
       p_pk2_alias           => null,
       p_pk3_alias           => null,
       p_pk4_alias           => null,
       p_pk5_alias           => null,
       p_grant_type          => p_grant_type,
       x_return_status       => x_return_status
    );
  END get_party_security_predicate;
----------------------------------------------------------------

 --7.c.2 Get the list of predicates Strings on whcih user has privilege
--------------------------------------
  FUNCTION get_party_security_predicate
  (
   p_api_version          IN  NUMBER,
   p_party_id             IN  NUMBER,
   p_privilege            IN  VARCHAR2,
   p_object_name          IN  VARCHAR2,
   p_aliased_pk_column    IN  VARCHAR2,
   p_pk2_alias            IN  VARCHAR2,
   p_pk3_alias            IN  VARCHAR2,
   p_pk4_alias            IN  VARCHAR2,
   p_pk5_alias            IN  VARCHAR2,
   p_grant_type           IN  VARCHAR2 DEFAULT 'UNIVERSAL',
   x_return_status        OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2
  IS
    -- Start OF comments
    -- API name  : get_security_predicate
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Returns  the predicates belong to a party with a given privilege.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

  l_grantee_key   fnd_grants.grantee_key%TYPE;
  l_grantee_type  fnd_grants.grantee_type%TYPE;
  x_predicate     VARCHAR2(32000);


  BEGIN
    --  IF(check_override_datasec(p_party_id)) THEN
    --   RETURN ' 1=1 ';
    -- END IF;
     IF(  p_party_id = -1000) THEN
        l_grantee_key:='HZ_GLOBAL:'||p_party_id;
     ELSE
        l_grantee_key:='HZ_PARTY:'||p_party_id;
     END IF;

     EGO_DATA_SECURITY.get_security_predicate
     (
        p_api_version         => p_api_version,
        p_function            => p_privilege,
        p_object_name         => p_object_name,
        p_grant_instance_type => p_grant_type,
        p_user_name           => l_grantee_key,
        p_statement_type      => 'OTHER',
        p_pk1_alias           => p_aliased_pk_column,
        p_pk2_alias           => p_pk2_alias,
        p_pk3_alias           => p_pk3_alias,
        p_pk4_alias           => p_pk4_alias,
        p_pk5_alias           => p_pk5_alias,
        x_predicate           => x_predicate,
        x_return_status       => x_return_status
     );
   RETURN x_predicate;
 END get_party_security_predicate;
------------------------------------------------------------------------------------


  --8.a Get Privileges as comma delimited string
------------------------------------
PROCEDURE get_privileges_d
  (
   p_api_version    IN  NUMBER,
   p_object_name    IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_user_id        IN  NUMBER,
   p_delimiter      IN  VARCHAR2 DEFAULT ',',
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privileges_string  OUT NOCOPY VARCHAR2
  )IS

   -- Start OF comments
   -- API name  : get_security_predicate
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : It returns all previleges as a string seperating the privileges with comma.

   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments

    l_api_version           CONSTANT NUMBER := 1.0;
    l_privilege_tbl   EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE ;

  BEGIN
     get_privileges(p_api_version,
            p_object_name,
            p_object_key ,
            p_user_id ,
            x_return_status,
            l_privilege_tbl);
     x_privileges_string:='';
     IF ( l_privilege_tbl.count >0) THEN
       FOR i IN l_privilege_tbl.first .. l_privilege_tbl.last LOOP

          x_privileges_string :=x_privileges_string ||l_privilege_tbl(i) || p_delimiter;
       END LOOP;
       -- strip off the trailing ', '
         x_privileges_string := substr(x_privileges_string, 1,
                              length(x_privileges_string) - length(p_delimiter));
     END IF;


  END  get_privileges_d;
------------------------------------------------------------------------------------

 --8.b Get Privileges as comma delimited string
------------------------------------
PROCEDURE get_party_privileges_d
  (
   p_api_version    IN  NUMBER,
   p_object_name    IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER,
   p_delimiter      IN  VARCHAR2 DEFAULT ',',
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privileges_string  OUT NOCOPY VARCHAR2
  )IS

   -- Start OF comments
   -- API name  : get_security_predicate
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : It returns all previleges as a string seperating the privileges with comma.

   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments

  BEGIN
    get_party_privileges_d
    (
       p_api_version        => p_api_version,
       p_object_name        => p_object_name,
       p_pk1_value          => to_char(p_object_key),
       p_pk2_value          => null,
       p_pk3_value          => null,
       p_pk4_value          => null,
       p_pk5_value          => null,
       p_party_id           => p_party_id,
       p_delimiter          => p_delimiter,
       x_return_status      => x_return_status,
       x_privileges_string  => x_privileges_string
    );

  END  get_party_privileges_d;
------------------------------------------------------------------------------------

 --8.c Get Privileges as comma delimited string
------------------------------------
PROCEDURE get_party_privileges_d
  (
   p_api_version    IN  NUMBER,
   p_object_name    IN  VARCHAR2,
   p_pk1_value      IN  VARCHAR2,
   p_pk2_value      IN  VARCHAR2,
   p_pk3_value      IN  VARCHAR2,
   p_pk4_value      IN  VARCHAR2,
   p_pk5_value      IN  VARCHAR2,
   p_party_id       IN  NUMBER,
   p_delimiter      IN  VARCHAR2 DEFAULT ',',
   x_return_status  OUT NOCOPY VARCHAR2,
   x_privileges_string  OUT NOCOPY VARCHAR2
  )IS

   -- Start OF comments
   -- API name  : get_security_predicate
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : It returns all previleges as a string seperating the privileges with comma.

   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments

    l_api_version           CONSTANT NUMBER := 1.0;
    l_privilege_tbl   EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE ;

  BEGIN
    get_party_privileges
    (
       p_api_version         => p_api_version,
       p_object_name         => p_object_name,
       p_instance_pk1_value  => p_pk1_value,
       p_instance_pk2_value  => p_pk2_value,
       p_instance_pk3_value  => p_pk3_value,
       p_instance_pk4_value  => p_pk4_value,
       p_instance_pk5_value  => p_pk5_value,
       p_party_id            => p_party_id,
       x_return_status       => x_return_status,
       x_privilege_tbl       => l_privilege_tbl
    );

     x_privileges_string:='';
     IF ( l_privilege_tbl.count >0) THEN
       FOR i IN l_privilege_tbl.first .. l_privilege_tbl.last LOOP
          x_privileges_string :=x_privileges_string ||l_privilege_tbl(i) || p_delimiter;
       END LOOP;
       -- strip off the trailing ', '
         x_privileges_string := substr(x_privileges_string, 1,
                              length(x_privileges_string) - length(p_delimiter));
     END IF;


  END  get_party_privileges_d;
------------------------------------------------------------------------------------


 --9. Set end date to a grant
  ------------------------------------
  PROCEDURE set_grant_date
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
  )IS
   -- Start OF comments
   -- API name : SET_GRANT_DATE
   -- TYPE : Public
   -- Pre-reqs : None
   -- FUNCTION :sets start date and end date to a grant
   --
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments

  --x_success  VARCHAR2(2);
  l_dummy              VARCHAR2(1);
  l_grant_guid   fnd_grants.grant_guid%TYPE;
   CURSOR get_grant_guid(cp_grant_id VARCHAR2,
                         cp_start_date DATE,
                         cp_end_date DATE)
   IS
     SELECT g1.grant_guid
     FROM fnd_grants g1, fnd_grants g2
     WHERE g1.grant_guid=HEXTORAW(cp_grant_id)
      AND g2.grant_guid<>HEXTORAW(cp_grant_id)
      AND g1.object_id=g2.object_id
      AND g1.menu_id=g2.menu_id
      AND g1.instance_type=g2.instance_type
      -- 3729803
      -- query must take care of instance sets as well
      AND NVL(g1.instance_set_id,-1) = NVL(g2.instance_set_id,-1)
      AND g1.instance_pk1_value=g2.instance_pk1_value
      AND g1.grantee_type=g2.grantee_type
      AND g1.grantee_key=g2.grantee_key
      AND (
            ((g2.start_date<=cp_start_date )
            AND (( g2.end_date IS NULL) OR (cp_start_date<=g2.end_date )))
        OR ((g2.start_date >= cp_start_date )
            AND (( cp_end_date IS NULL)  OR (cp_end_date>=g2.start_date)))
      );

   BEGIN
      OPEN get_grant_guid(cp_grant_id=>p_grant_guid,
                          cp_start_date=>p_start_date,
                          cp_end_date=>p_end_date);
      FETCH get_grant_guid INTO l_grant_guid;

      IF( get_grant_guid%NOTFOUND) THEN
           fnd_grants_pkg.update_grant (
              p_api_version => p_api_version,
              p_grant_guid  => HEXTORAW(p_grant_guid),
              p_start_date  => p_start_date,
              p_end_date    => p_end_date,
              x_success     => x_return_status
           );
      ELSE
            x_return_status:='F';

      END IF;

      CLOSE get_grant_guid;

  END set_grant_date;
  ----------------------------------------------------------------------------

/*
 --12. Check_Instance_In_Set
 ----------------------------
FUNCTION check_instance_in_set
 (
   p_api_version          IN  NUMBER,
   p_instance_set_id      IN  NUMBER,
   p_instance_pk1_value   IN  VARCHAR2
 ) return VARCHAR2
IS
  l_instance_set_name    fnd_object_instance_sets.instance_set_name%TYPE;
  CURSOR get_instance_set_name (cp_instance_set_id NUMBER)
  IS
    SELECT instance_set_name
    FROM fnd_object_instance_sets
    WHERE instance_set_id=cp_instance_set_id ;

BEGIN
  OPEN get_instance_set_name(cp_instance_set_id=>p_instance_set_id);
  FETCH get_instance_set_name INTO l_instance_set_name;
  CLOSE get_instance_set_name;
  RETURN EGO_DATA_SECURITY.check_instance_in_set
  (
     p_api_version        => p_api_version ,
     p_instance_set_name  => l_instance_set_name,
     p_instance_pk1_value => p_instance_pk1_value,
     p_instance_pk2_value => null,
     p_instance_pk3_value => null,
     p_instance_pk4_value => null,
     p_instance_pk5_value => null
  );

END check_instance_in_set;
-------------------------------------------------------------
*/

 --12. Check_Instance_In_Set
 ------------------------
 FUNCTION check_instance_in_set
 (
   p_api_version    IN  NUMBER,
   p_object_name      IN  VARCHAR2,
   p_instance_set_id IN NUMBER,
   p_instance_id    IN  NUMBER,
   p_party_person_id  IN  NUMBER
 )
 RETURN VARCHAR2
IS

     l_api_version          CONSTANT NUMBER := 1.0;
     l_api_name          CONSTANT VARCHAR2(30)  := 'check_instance_in_set';

      l_sysdate              DATE := Sysdate;

      l_dynamic_sql           VARCHAR2(32767);
      l_pk1_column            fnd_objects.PK1_COLUMN_NAME%TYPE;
      l_instance_flag         BOOLEAN   DEFAULT TRUE;
      l_instance_set_flag     BOOLEAN   DEFAULT TRUE;
      l_set_predicate         VARCHAR2(32767);
      l_db_object_name        fnd_objects.DATABASE_OBJECT_NAME%TYPE;
      l_db_pk_column          fnd_objects.PK1_COLUMN_NAME%TYPE;
      l_result                VARCHAR2(1);
      l_dummy                  VARCHAR2(1);


      TYPE  DYNAMIC_CUR IS REF CURSOR;
      instance_sets_cur DYNAMIC_CUR;


    CURSOR predicate_c (cp_object_name     VARCHAR2,
                            cp_instance_set_id NUMBER)
        IS
        SELECT DISTINCT obj.pk1_column_name, obj.database_object_name, sets.predicate
          FROM fnd_objects obj,
          fnd_object_instance_sets sets
        WHERE obj.obj_name = cp_object_name
        AND   obj.object_id = sets.object_id
        AND   sets.instance_set_id = cp_instance_set_id;



 BEGIN
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                        p_api_version,
                        l_api_name ,
                        G_PKG_NAME)
       THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

           -- Step 1.
         OPEN predicate_c (p_object_name, p_instance_set_id);
         FETCH predicate_c into l_db_pk_column, l_db_object_name, l_set_predicate;
         CLOSE predicate_c;
         l_set_predicate := REPLACE(l_set_predicate, 'EGO_SCTX.GET_PARTY_PERSON_ID()', p_party_person_id);
         --l_set_predicate := REPLACE(l_set_predicate, 'EGO_SCTX.GET_USER_ID()', p_user_id);

         IF( length(l_set_predicate ) >0) THEN

              l_dynamic_sql :=  ' SELECT ''X'' FROM sys.dual WHERE EXISTS ' ||
                                 '( SELECT ' || l_db_pk_column || ' FROM ' || l_db_object_name ||
                                 ' WHERE ' || l_db_pk_column || ' = ' || p_instance_id ||
                                 ' AND ' || l_set_predicate || ')';

              OPEN instance_sets_cur FOR l_dynamic_sql;
              FETCH instance_sets_cur  INTO l_dummy;
              IF(instance_sets_cur%NOTFOUND) THEN
                 CLOSE instance_sets_cur;
                 RETURN FND_API.G_FALSE;
              ELSE
                 CLOSE instance_sets_cur;
                 RETURN FND_API.G_TRUE;
              END IF;
         ELSE
              --no predicate for the set; universal set
              RETURN FND_API.G_TRUE;
         END IF;
   EXCEPTION
       WHEN OTHERS THEN
        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME ,
                        l_api_name
                );
        END IF;
   RETURN FND_API.G_FALSE;

 END check_instance_in_set;
---------------------------------------------------------

 --13. check_duplicate_grant
 ------------------------
 FUNCTION check_duplicate_grant
  (
   p_role_name            IN  VARCHAR2,
   p_object_name      IN  VARCHAR2,
   p_object_key_type      IN  VARCHAR2,
   p_object_key           IN  NUMBER,
   p_party_id             IN  NUMBER,
   p_start_date           IN  DATE,
   p_end_date             IN  DATE
 ) RETURN VARCHAR2
   IS
    -- Start OF comments
    -- API name  : check_duplicate_grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : checks for duplicate grant

    -- Parameters:
    --     IN    : p_role_name      IN  VARCHAR2(Required)
    --             Role Name
    --
    --     IN    :p_object_name     IN  VARCHAR2(Required)
    --            Object name
    --     IN    :p_object_key_type  IN  VARCHAR2(Required)
    --            Object Key Type
    --
    --     IN    :p_object_key      IN  NUMBER,
    --            Object Key
    --
    --     IN    :p_party_id         IN  NUMBER,
    --            party id
    --
    --     IN    :p_start_date     IN  DATE,
    --            Start date
    --
    --     IN    :p_end date       IN  DATE,
    --            End date
    --
    --     OUT  :
    --             RETURN
    --                   FND_API.G_TRUE  IF this grant already exist (duplicate grant)
    --                   FND_API.G_FALSE NO IF it is not Duplicate grant
    --                   FND_API.G_RET_STS_ERROR if error
    --               FND_API.G_RET_STS_UNEXP_ERROR if unexpected error

    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments


  l_party_id           NUMBER;
  l_role_id            NUMBER;

   CURSOR get_role_id(cp_role_name VARCHAR2)  IS
      SELECT menu_id
      FROM fnd_menus
      WHERE menu_name =cp_role_name;

  CURSOR check_for_duplicate (cp_grantee_key       VARCHAR2,
                               cp_grantee_type            VARCHAR2,
                               cp_menu_name               VARCHAR2,
                               cp_object_name             VARCHAR2,
                               cp_instance_type           VARCHAR2,
                               cp_instance_pk1_value      VARCHAR2,
                               cp_instance_pk2_value      VARCHAR2,
                               cp_instance_pk3_value      VARCHAR2,
                               cp_instance_pk4_value      VARCHAR2,
                               cp_instance_pk5_value      VARCHAR2,
                               cp_instance_set_id         NUMBER,
                               cp_start_date              DATE,
                               cp_end_date                DATE) IS

        SELECT 'X'
        FROM fnd_grants grants,
             fnd_objects obj,
             fnd_menus menus
        WHERE grants.grantee_key=cp_grantee_key
        AND  grants.grantee_type=cp_grantee_type
        AND  grants.menu_id=menus.menu_id
        AND  menus.menu_name=cp_menu_name
        AND  grants.object_id = obj.object_id
        AND obj.obj_name=cp_object_name
        AND grants.instance_type=cp_instance_type
        AND ((grants.instance_pk1_value=cp_instance_pk1_value )
            OR((grants.instance_pk1_value = '*NULL*') AND (cp_instance_pk1_value IS NULL)))
        AND ((grants.instance_pk2_value=cp_instance_pk2_value )
            OR((grants.instance_pk2_value = '*NULL*') AND (cp_instance_pk2_value IS NULL)))
        AND ((grants.instance_pk3_value=cp_instance_pk3_value )
            OR((grants.instance_pk3_value = '*NULL*') AND (cp_instance_pk3_value IS NULL)))
        AND ((grants.instance_pk4_value=cp_instance_pk4_value )
            OR((grants.instance_pk4_value = '*NULL*') AND (cp_instance_pk4_value IS NULL)))
        AND ((grants.instance_pk5_value=cp_instance_pk5_value )
            OR((grants.instance_pk5_value = '*NULL*') AND (cp_instance_pk5_value IS NULL)))
        AND ((grants.instance_set_id=cp_instance_set_id )
            OR((grants.instance_set_id IS NULL ) AND (cp_instance_set_id IS NULL)))
        AND (((grants.start_date<=cp_start_date )
            AND (( grants.end_date IS NULL) OR (cp_start_date <=grants.end_date )))
        OR ((grants.start_date >= cp_start_date )
            AND (( cp_end_date IS NULL)  OR (cp_end_date >=grants.start_date))));

  l_grantee_type       hz_parties.party_type%TYPE;
  l_grantee_key        fnd_grants.grantee_key%TYPE;
  l_instance_set_id    fnd_grants.instance_set_id%TYPE;
  l_instance_pk1_value  fnd_grants.instance_pk1_value%TYPE;
  l_dummy              VARCHAR2(1);
  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;


BEGIN


      IF( p_object_key_type ='SET') THEN
         l_instance_set_id:=p_object_key;
         l_instance_pk1_value:= null;
       ELSE
         l_instance_set_id:=null;
         l_instance_pk1_value:= to_char(p_object_key);
       END IF;
       OPEN get_party_type (cp_party_id =>p_party_id);
       FETCH get_party_type INTO l_grantee_type;
       CLOSE get_party_type;
       IF(  p_party_id = -1000) THEN
          l_grantee_type :='GLOBAL';
          l_grantee_key:='HZ_GLOBAL:'||p_party_id;
       ELSIF (l_grantee_type ='PERSON') THEN
          l_grantee_type:='USER';
          l_grantee_key:='HZ_PARTY:'||p_party_id;
       ELSIF (l_grantee_type ='GROUP') THEN
          l_grantee_type:='GROUP';
          l_grantee_key:='HZ_GROUP:'||p_party_id;
       ELSIF (l_grantee_type ='ORGANIZATION') THEN
          l_grantee_type:='COMPANY';
          l_grantee_key:='HZ_COMPANY:'||p_party_id;
       ELSE
           null;
       END IF;

     OPEN check_for_duplicate(cp_grantee_key  => l_grantee_key,
                      cp_grantee_type       => l_grantee_type,
                      cp_menu_name          => p_role_name,
                      cp_object_name        => p_object_name,
                      cp_instance_type      => p_object_key_type,
                      cp_instance_pk1_value => l_instance_pk1_value,
                      cp_instance_pk2_value => null,
                      cp_instance_pk3_value => null,
                      cp_instance_pk4_value => null,
                      cp_instance_pk5_value => null,
                      cp_instance_set_id    => l_instance_set_id,
                      cp_start_date         => p_start_date,
                      cp_end_date           => p_end_date);
       FETCH check_for_duplicate  INTO l_dummy;
       IF( check_for_duplicate%NOTFOUND) THEN
           CLOSE  check_for_duplicate ;
           RETURN FND_API.G_FALSE;
       ELSE
           CLOSE  check_for_duplicate ;
           RETURN FND_API.G_TRUE;
       END IF;

EXCEPTION
      WHEN OTHERS THEN
      RETURN FND_API.G_RET_STS_ERROR;


END check_duplicate_grant;
---------------------------------------------------------


 --14. check_duplicate_item_grant
 ------------------------
 FUNCTION check_duplicate_item_grant
  (
   p_role_id              IN  NUMBER,
   p_object_id        IN  NUMBER,
   p_object_key_type      IN  VARCHAR2,
   p_object_key           IN  NUMBER,
   p_party_id             IN  NUMBER,
   p_start_date           IN  DATE,
   p_end_date             IN  DATE
 ) RETURN VARCHAR2
   IS
    -- Start OF comments
    -- API name  : check_duplicate_item_grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : checks for duplicate grant

    -- Parameters:
    --     IN    : p_role_name      IN  VARCHAR2(Required)
    --             Role Name
    --
    --     IN    :p_object_name     IN  VARCHAR2(Required)
    --            Object name
    --     IN    :p_object_key_type  IN  VARCHAR2(Required)
    --            Object Key Type
    --
    --     IN    :p_object_key      IN  NUMBER,
    --            Object Key
    --
    --     IN    :p_party_id         IN  NUMBER,
    --            party id
    --
    --     IN    :p_start_date     IN  DATE,
    --            Start date
    --
    --     IN    :p_end date       IN  DATE,
    --            End date
    --
    --     OUT  :
    --             RETURN
    --                   FND_API.G_TRUE  IF this grant already exist (duplicate grant)
    --                   FND_API.G_FALSE NO IF it is not Duplicate grant
    --                   FND_API.G_RET_STS_ERROR if error
    --               FND_API.G_RET_STS_UNEXP_ERROR if unexpected error

    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments


  l_party_id           NUMBER;
  l_role_id            NUMBER;

  CURSOR check_for_duplicate (cp_grantee_key           VARCHAR2,
                               cp_grantee_type         VARCHAR2,
                               cp_menu_id              NUMBER,
                               cp_object_id            NUMBER,
                               cp_instance_type        VARCHAR2,
                               cp_instance_pk1_value   VARCHAR2,
                               cp_instance_set_id      NUMBER,
                               cp_start_date           DATE,
                               cp_end_date             DATE) IS
        SELECT 'X'
        FROM fnd_grants grants
        WHERE grants.grantee_key=cp_grantee_key
        AND  grants.grantee_type=cp_grantee_type
        AND  grants.menu_id=cp_menu_id
        AND  grants.object_id = cp_object_id
        AND grants.instance_type=cp_instance_type
        AND ((grants.instance_pk1_value=cp_instance_pk1_value )
            OR((grants.instance_pk1_value = '*NULL*') AND (cp_instance_pk1_value IS NULL)))
        AND ((grants.instance_set_id=cp_instance_set_id )
            OR((grants.instance_set_id IS NULL ) AND (cp_instance_set_id IS NULL)))
        AND (((grants.start_date<=cp_start_date )
            AND (( grants.end_date IS NULL) OR (cp_start_date <=grants.end_date )))
        OR ((grants.start_date >= cp_start_date )
            AND (( cp_end_date IS NULL)  OR (cp_end_date >=grants.start_date))));

  l_grantee_type       hz_parties.party_type%TYPE;
  l_grantee_key        fnd_grants.grantee_key%TYPE;
  l_instance_set_id    fnd_grants.instance_set_id%TYPE;
  l_instance_pk1_value  fnd_grants.instance_pk1_value%TYPE;
  l_dummy              VARCHAR2(1);

  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;

BEGIN


      IF( p_object_key_type ='SET') THEN
         l_instance_set_id:=p_object_key;
         l_instance_pk1_value:= null;
       ELSE
         l_instance_set_id:=null;
         l_instance_pk1_value:= to_char(p_object_key);
       END IF;
       OPEN get_party_type (cp_party_id =>p_party_id);
       FETCH get_party_type INTO l_grantee_type;
       CLOSE get_party_type;
       IF(  p_party_id = -1000) THEN
          l_grantee_type :='GLOBAL';
          l_grantee_key:='HZ_GLOBAL:'||p_party_id;
       ELSIF (l_grantee_type ='PERSON') THEN
          l_grantee_type:='USER';
          l_grantee_key:='HZ_PARTY:'||p_party_id;
       ELSIF (l_grantee_type ='GROUP') THEN
          l_grantee_type:='GROUP';
          l_grantee_key:='HZ_GROUP:'||p_party_id;
       ELSIF (l_grantee_type ='ORGANIZATION') THEN
          l_grantee_type:='COMPANY';
          l_grantee_key:='HZ_COMPANY:'||p_party_id;
       ELSE
           null;
       END IF;

     OPEN check_for_duplicate(cp_grantee_key  => l_grantee_key,
                      cp_grantee_type       => l_grantee_type,
                      cp_menu_id            => p_role_id,
                      cp_object_id          => p_object_id,
                      cp_instance_type      => p_object_key_type,
                      cp_instance_pk1_value => l_instance_pk1_value,
                      cp_instance_set_id    => l_instance_set_id,
                      cp_start_date         => p_start_date,
                      cp_end_date           => p_end_date);
       FETCH check_for_duplicate  INTO l_dummy;
       IF( check_for_duplicate%NOTFOUND) THEN
           CLOSE  check_for_duplicate ;
           RETURN FND_API.G_FALSE;
       ELSE
           CLOSE  check_for_duplicate ;
           RETURN FND_API.G_TRUE;
       END IF;

EXCEPTION
      WHEN OTHERS THEN
      RETURN FND_API.G_RET_STS_ERROR;


END check_duplicate_item_grant;
---------------------------------------------------------

--14. creat_instance_set
 ------------------------
 FUNCTION create_instance_set
 (
   p_instance_set_name      IN  VARCHAR2,
   p_object_name        IN  VARCHAR2,
   p_predicate              IN  VARCHAR2,
   p_display_name           IN  VARCHAR2,
   p_description            IN  VARCHAR2
 )
 RETURN NUMBER
IS

     l_api_version          CONSTANT NUMBER := 1.0;
     l_api_name          CONSTANT VARCHAR2(30)  := 'check_instance_in_set';

      l_instance_set_id       NUMBER;




    CURSOR get_set_c (cp_instance_set_name     VARCHAR2)
        IS
        SELECT instance_set_id
        FROM fnd_object_instance_sets
        WHERE instance_set_name = cp_instance_set_name;


 BEGIN

           -- Step 1.
         OPEN get_set_c (p_instance_set_name);
         FETCH get_set_c into l_instance_set_id;

         IF(get_set_c%NOTFOUND) THEN
            CLOSE get_set_c;

            FND_OBJECT_INSTANCE_SETS_PKG.LOAD_ROW
        (
        X_INSTANCE_SET_NAME   => p_instance_set_name,
        X_OWNER               => 'ORACLE',
        X_OBJECT_NAME         => p_object_name,
        X_PREDICATE           => p_predicate,
        X_DISPLAY_NAME        => p_display_name,
        X_DESCRIPTION         => p_description,
        X_CUSTOM_MODE         => 'NO_FORCE'
        );

           ELSE
             CLOSE get_set_c;
             RETURN l_instance_set_id;
         END IF;

         -- step 2
         OPEN get_set_c (p_instance_set_name);
         FETCH get_set_c into l_instance_set_id;

         IF(get_set_c%NOTFOUND) THEN
            CLOSE get_set_c;
        RETURN -1;
         ELSE
             CLOSE get_set_c;
             RETURN l_instance_set_id;
         END IF;

   EXCEPTION
       WHEN OTHERS THEN
        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME ,
                        l_api_name
                );
        END IF;
   RETURN -1;

 END create_instance_set;
---------------------------------------------------------


END EGO_SECURITY_PUB;

/
