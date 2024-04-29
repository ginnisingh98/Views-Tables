--------------------------------------------------------
--  DDL for Package Body FPA_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_SECURITY_PVT" as
 /* $Header: FPAVSECB.pls 120.4 2005/08/18 11:50:33 appldev noship $ */

 G_PKG_NAME    CONSTANT VARCHAR2(200) := 'FPA_SECURITY_PVT';
 G_APP_NAME    CONSTANT VARCHAR2(3)   :=  FPA_UTILITIES_PVT.G_APP_NAME;
 G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
 L_API_NAME    CONSTANT VARCHAR2(35)  := 'SECURITY_PVT';

/* ***************************************************************
Desc: Verify if a grant exists for a given portfolio and a role
parameters:
***************************************************************** */

PROCEDURE Get_Grant(p_project_role_id  IN NUMBER,
                    p_instance_type     IN FND_GRANTS.INSTANCE_TYPE%TYPE,
                    p_instance_set_name IN FND_OBJECT_INSTANCE_SETS.INSTANCE_SET_NAME%TYPE,
                    p_grantee_type      IN FND_GRANTS.GRANTEE_TYPE%TYPE,
                    p_grantee_key       IN FND_GRANTS.GRANTEE_KEY%TYPE,
                    x_instance_set_id   OUT NOCOPY NUMBER,
                    x_grant_id          OUT NOCOPY FND_GRANTS.GRANT_GUID%TYPE,
                    x_ret_code          OUT NOCOPY VARCHAR2) IS

 cursor grants_csr (p_menu_id           IN NUMBER,
                    p_instance_type     IN FND_GRANTS.INSTANCE_TYPE%TYPE,
                    p_instance_set_id   IN NUMBER,
                    p_instance_set_name IN FND_OBJECT_INSTANCE_SETS.INSTANCE_SET_NAME%TYPE,
                    p_grantee_type      IN FND_GRANTS.GRANTEE_TYPE%TYPE,
                    p_grantee_key       IN FND_GRANTS.GRANTEE_KEY%TYPE) IS

    select 'T', grant_guid
    from fnd_grants
    where grantee_key = p_grantee_key
        and grantee_type = 'USER'
        and instance_set_id = p_instance_set_id
        and grantee_type  = p_grantee_type
        and instance_type = p_instance_type
        and menu_id       = p_menu_id;

 l_instance_set_id NUMBER := null;
 l_menu_id         NUMBER := null;
 l_grant_exists    VARCHAR2(1);
 l_grant_id        FND_GRANTS.GRANT_GUID%TYPE := null;

BEGIN

  l_grant_exists   := FND_API.G_FALSE;

 l_instance_set_id := PA_SECURITY_PVT.Get_Instance_Set_Id(p_instance_set_name);
 x_instance_set_id := l_instance_set_id;
 l_menu_id := PA_SECURITY_PVT.get_menu_id_for_role(p_project_role_id);

 open grants_csr(l_menu_id,
                 p_instance_type,
                 l_instance_set_id,
                 p_instance_set_name,
                 p_grantee_type,
                 p_grantee_key);

 fetch grants_csr into l_grant_exists, l_grant_id;
 close grants_csr;

 x_ret_code := l_grant_exists;
 x_grant_id := l_grant_id;

EXCEPTION
  WHEN OTHERS THEN
    if grants_csr%ISOPEN then
       close grants_csr;
    end if;
    x_instance_set_id := l_instance_set_id;
    x_ret_code := l_grant_exists;
    x_grant_id := null;
    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.String(
                FND_LOG.LEVEL_PROCEDURE,
                'FPA_SECURITY_PVT.Get_Grant',
                x_instance_set_id||','||x_ret_code||','||x_ret_code);
        raise;
    end if;
END Get_Grant;


FUNCTION Check_User_Previlege(
   p_privilege      IN  VARCHAR2,
   p_object_name    IN  VARCHAR2,
   p_object_id      IN  NUMBER,
   p_person_id      IN  NUMBER) RETURN VARCHAR2 IS

g_key FND_GRANTS.GRANTEE_KEY%TYPE;
l_ret_code VARCHAR2(1) := null;

BEGIN
/*  Changes for ATG mandate for deprecated parameter
    if(p_person_id is null) then
        g_key := PA_SECURITY_PVT.Get_Grantee_Key('USER');
    else
        g_key := PA_SECURITY_PVT.Get_Grantee_Key('PERSON',p_person_id, 'Y');
    end if;
                    */
/*
    if (not fnd_function.test(p_privilege)) then
      return FND_API.G_FALSE;
    end if;
    */



    l_ret_code := FND_DATA_SECURITY.Check_Function(
                        p_api_version        => 1.0,
                        p_function           => p_privilege,
                        p_object_name        => p_object_name,
                        p_instance_pk1_value => p_object_id,
                        p_instance_pk2_value => NULL,
                        p_instance_pk3_value => NULL,
                        p_instance_pk4_value => NULL,
                        p_instance_pk5_value => NULL);
                        -- Changes for ATG mandate for deprecated parameter
                        --,
                        --p_user_name          => g_key);

    return l_ret_code;

EXCEPTION
   WHEN OTHERS THEN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.String(
               FND_LOG.LEVEL_PROCEDURE,
               'FPA_SECURITY_PVT.Check_User_Previlege',
               p_privilege||','||p_object_name||','||p_object_id);
    end if;
   return 'U';
END Check_User_Previlege;


FUNCTION Check_Privilege(
   p_privilege      IN  VARCHAR2,
   p_object_name    IN  VARCHAR2,
   p_object_id      IN  NUMBER,
   p_person_id      IN  NUMBER) RETURN VARCHAR2 IS

g_key FND_GRANTS.GRANTEE_KEY%TYPE;
l_ret_code VARCHAR2(1) := null;

BEGIN
    /* Changes for ATG mandate for deprecated parameter
    if(p_person_id is null) then
        g_key := PA_SECURITY_PVT.Get_Grantee_Key('USER');
    else
        g_key := PA_SECURITY_PVT.Get_Grantee_Key('PERSON',p_person_id, 'Y');
    end if;
     */
/*
    if (not fnd_function.test(p_privilege)) then
      return FND_API.G_FALSE;
    end if;
    */



    l_ret_code := FND_DATA_SECURITY.Check_Function(
                        p_api_version        => 1.0,
                        p_function           => p_privilege,
                        p_object_name        => p_object_name,
                        p_instance_pk1_value => p_object_id,
                        p_instance_pk2_value => NULL,
                        p_instance_pk3_value => NULL,
                        p_instance_pk4_value => NULL,
                        p_instance_pk5_value => NULL);
                        -- Changes for ATG mandate for deprecated parameter
                        -- ,
                        -- p_user_name          => g_key);

    if(l_ret_code = 'T') then
        return 'X';
    else
        return null;
    end if;

EXCEPTION
   WHEN OTHERS THEN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.String(
               FND_LOG.LEVEL_PROCEDURE,
               'FPA_SECURITY_PVT.Check_User_Previlege',
               p_privilege||','||p_object_name||','||p_object_id);
    end if;
   return 'U';
END Check_Privilege;



FUNCTION Get_Owner(
   p_portfolio_id   IN  NUMBER) RETURN NUMBER IS

l_person_id NUMBER := null;

BEGIN

    select
        pp.resource_source_id into l_person_id
    from pa_project_parties pp, pa_project_role_types_b rlt
    where pp.object_type = 'PJP_PORTFOLIO'
    and   pp.object_id = p_portfolio_id
    and   PP.project_role_id = rlt.project_role_id
    and   rlt.project_role_type = G_OWNER;

    return l_person_id;

EXCEPTION
   WHEN OTHERS THEN
   return null;
END Get_Owner;



FUNCTION Get_Role(
   p_project_role_id   IN  PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_ID%TYPE)
RETURN VARCHAR2 IS

l_role VARCHAR2(200) := null;
BEGIN
    select
        project_role_type into l_role
    from pa_project_role_types_b
    where project_role_id = p_project_role_id;

    return l_role;
EXCEPTION
   WHEN OTHERS THEN
   return null;
END Get_Role;

FUNCTION Get_Role_Id(
   p_project_role   IN PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_TYPE%TYPE)
RETURN PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_ID%TYPE IS

l_role_id PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_ID%TYPE := null;

BEGIN
    select
        project_role_id into l_role_id
    from pa_project_role_types_b
    where project_role_type = p_project_role;

    return l_role_id;
EXCEPTION
   WHEN OTHERS THEN
   return null;
END Get_Role_Id;


PROCEDURE Grant_Role
(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2,
  p_project_role_id   IN  NUMBER,
  p_object_name       IN  VARCHAR2,
  p_object_set        IN  VARCHAR2,
  p_party_id          IN  NUMBER,
  p_source_type       IN  VARCHAR2,
  x_grant_guid        OUT NOCOPY RAW,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Grant_Role';
  l_api_version            CONSTANT NUMBER    := 1.0;
  l_msg_log                VARCHAR2(2000) := null;
----------------------------------------------------------------------------

 l_exists VARCHAR2(1);
 l_grant_id RAW(16);
 l_instance_set_id NUMBER;
 l_grantee_key FND_GRANTS.GRANTEE_KEY%TYPE;
 l_secured_role_menu FND_MENUS.MENU_NAME%TYPE;
 l_success VARCHAR2(1);
 l_error_code NUMBER;
 l_role    VARCHAR2(100);

 BEGIN

      l_return_status      := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
      l_exists             := 'F';

      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
      x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering fpa_security_pvt.grant_role',
              x_return_status => x_return_status);

        -- check if activity started successfully
      if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;

    l_grantee_key:= PA_SECURITY_PVT.Get_Grantee_Key(
                                  p_source_type,
                                  p_party_id,
                                  'Y');

    Get_Grant(p_project_role_id    => p_project_role_id,
              p_instance_type      => 'SET',
              p_instance_set_name  => p_object_set,
              p_grantee_type       => 'USER',
              p_grantee_key        => l_grantee_key,
              x_instance_set_id    => l_instance_set_id,
              x_grant_id           => l_grant_id,
              x_ret_code           => l_exists);

  if(l_exists = FND_API.G_TRUE) then

    FPA_UTILITIES_PVT.END_ACTIVITY(
                   p_api_name     => l_api_name,
                   p_pkg_name     => G_PKG_NAME,
                   p_msg_log      => null,
                   x_msg_count    => x_msg_count,
                   x_msg_data     => x_msg_data);

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    return;

  end if;

  l_secured_role_menu := PA_SECURITY_PVT.Get_Menu_Name(p_project_role_id);

  if l_secured_role_menu is null then
     x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
     FPA_UTILITIES_PVT.SET_MESSAGE(
                  p_app_name => g_app_name
                , p_msg_name => 'PA_INVALID_PROJECT_ROLE');
--     l_msg_log := p_portfolio_party_id;
     raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;
  l_instance_set_id := PA_SECURITY_PVT.Get_Instance_Set_Id(p_object_set);


  x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

  FND_GRANTS_PKG.Grant_Function(
                p_api_version           =>  l_api_version,
                p_menu_name             =>  l_secured_role_menu,
                p_object_name           =>  p_object_name,
                p_instance_type         =>  'SET',
                p_instance_set_id       =>  l_instance_set_id,
                p_grantee_type          => 'USER',
                p_grantee_key           =>  l_grantee_key,
                p_parameter1            =>  p_project_role_id,
                p_parameter2            =>  p_party_id,
                p_start_date            =>  sysdate,
                p_end_date              =>  null,
                x_grant_guid            =>  l_grant_id,
                x_success               =>  l_success,
                x_errorcode             =>  l_error_code);


  if l_success <> FND_API.G_TRUE then
     if l_error_code > 0 then
            x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
          else
            x_return_status := FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR;
     end if;
  end if;

         -- check if activity started successfully
 if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
     l_msg_log := l_secured_role_menu||','||to_char(l_grant_id);
     raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
 elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
     l_msg_log := l_secured_role_menu||','||l_grant_id;
     raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
 end if;

 FPA_UTILITIES_PVT.END_ACTIVITY(
                p_api_name     => l_api_name,
                p_pkg_name     => G_PKG_NAME,
                p_msg_log      => null,
                x_msg_count    => x_msg_count,
                x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Grant_Role;


FUNCTION Get_Party_Name(p_person_id IN NUMBER)
         RETURN VARCHAR2 IS
l_party_name VARCHAR2(200) := null;
  begin
   SELECT FULL_NAME
   INTO   l_party_name
   FROM   PER_ALL_PEOPLE_F PPF
   WHERE  PERSON_ID = p_person_id;
   return l_party_name;
  EXCEPTION
     WHEN OTHERS THEN
       return null;
END Get_Party_Name;


/* ***************************************************************
Desc: Call to revoke role when deleting a portfolio party
parameters:
***************************************************************** */

PROCEDURE Revoke_Role(
     p_api_version        IN  NUMBER,
     p_init_msg_list      IN  VARCHAR2,
     p_project_role_id    IN  NUMBER,
--     p_project_party_id   IN  NUMBER,
     p_object_name        IN  VARCHAR2,
--     p_object_key_type    IN  VARCHAR2,
     p_object_key         IN  NUMBER,
     p_party_id           IN  NUMBER,
     p_source_type        IN  VARCHAR2,
--     x_revoked            OUT NOCOPY VARCHAR2,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2) IS

 cursor parties_csr (p_project_role_id           IN NUMBER,
                     p_party_id                  IN NUMBER) IS
    select 'T'
    from pa_project_parties
    where project_role_id = p_project_role_id
        and object_type   = 'PJP_PORTFOLIO'
        and resource_type_id = 101
        and resource_source_id = p_party_id
        and rownum=1;


   -- standard parameters
   l_return_status          VARCHAR2(1);
   l_api_name               CONSTANT VARCHAR2(30) := 'Revoke_Role';
   l_api_version            CONSTANT NUMBER    := 1.0;
   l_msg_log                VARCHAR2(2000) := null;
----------------------------------------------------------------------------

  l_object_id   NUMBER;
  l_object_key_type VARCHAR2(8);
  l_grant_id    FND_GRANTS.GRANT_GUID%TYPE;
  l_grantee_key FND_GRANTS.GRANTEE_KEY%TYPE;
  l_user        VARCHAR2(200);
  l_success     VARCHAR2(1);
  l_error_code  NUMBER;
  l_instance_set_id NUMBER;
  l_exists      VARCHAR2(1);

  BEGIN
--        l_return_status  := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering fpa_security_pvt.grant_role',
              x_return_status => x_return_status);

        -- check if activity started successfully
        if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    open parties_csr(p_project_role_id,
                     p_party_id);

    fetch parties_csr into l_exists;
    close parties_csr;

    if(l_exists = FND_API.G_TRUE) then

        FPA_UTILITIES_PVT.END_ACTIVITY(
                p_api_name     => l_api_name,
                p_pkg_name     => G_PKG_NAME,
                p_msg_log      => null,
                x_msg_count    => x_msg_count,
                x_msg_data     => x_msg_data);

        return;

    end if;

    l_grantee_key:= PA_SECURITY_PVT.Get_Grantee_Key(
                                    p_source_type,
                                    p_party_id,
                                    'Y');

    l_exists := null;

    Get_Grant(p_project_role_id    => p_project_role_id,
              p_instance_type      => 'SET',
              p_instance_set_name  => p_object_name,
              p_grantee_type       => 'USER',
              p_grantee_key        => l_grantee_key,
              x_instance_set_id    => l_instance_set_id,
              x_grant_id           => l_grant_id,
              x_ret_code           => l_exists);

    if(l_exists = FND_API.G_FALSE) then
        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
        l_user := Get_party_Name(p_party_id);
         FPA_UTILITIES_PVT.SET_MESSAGE(
                          p_app_name => g_app_name
                        , p_msg_name => 'FPA_SEC_NO_GRANT'
                        , p_token1   => 'USER'
                         ,p_token1_value => l_user);

        l_msg_log := 'FPA_SEC_NO_GRANT '||l_grantee_key||','||p_project_role_id;
        raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;


    FND_GRANTS_PKG.Revoke_Grant(
           p_api_version => p_api_version,
           p_grant_guid  => l_grant_id,
           x_success     => l_success,
           x_errorcode   => l_error_code);

   if l_success <> FND_API.G_TRUE then
--     x_revoked := FND_API.G_FALSE;
     if l_error_code > 0 then
            x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
          else
            x_return_status := FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR;
     end if;
   end if;

         -- check if activity started successfully
  if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
      l_msg_log := 'fpa_security_pvt.revoke_grant '||l_grant_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
  elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
      l_msg_log := 'fpa_security_pvt.revoke_grant '||l_grant_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;

  --x_revoked := FND_API.G_TRUE;

  FPA_UTILITIES_PVT.END_ACTIVITY(
            p_api_name     => l_api_name,
            p_pkg_name     => G_PKG_NAME,
            p_msg_log      => null,
            x_msg_count    => x_msg_count,
            x_msg_data     => x_msg_data);


EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);
 END Revoke_Role;


 FUNCTION check_user(p_person_id IN NUMBER,
                     p_portfolio_id IN NUMBER)
 RETURN BOOLEAN IS
   l_flag varchar2(1) := FND_API.G_FALSE;
   cursor PORTFOLIO_USER_CSR(P_PERSON_ID IN VARCHAR2,
                             P_PORTFOLIO_ID IN NUMBER) is
   SELECT 'T'
       FROM PA_PROJECT_PARTIES
       WHERE OBJECT_TYPE = 'PJP_PORTFOLIO'
         AND OBJECT_ID = P_PORTFOLIO_ID
         AND RESOURCE_SOURCE_ID = P_PERSON_ID;

   BEGIN
     open  PORTFOLIO_USER_CSR(p_person_id, p_portfolio_id);
     fetch PORTFOLIO_USER_CSR into l_flag;
     close PORTFOLIO_USER_CSR;
     if(l_flag = FND_API.G_TRUE) then
         return true;
     else
         return false;
     end if;
 END check_user;

 PROCEDURE Create_Portfolio_User(
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2,
  p_object_id             IN PA_PROJECT_PARTIES.OBJECT_ID%TYPE,
  p_instance_set_name     IN VARCHAR2,
  p_project_role_id       IN PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_ID%TYPE,
  p_party_id              IN NUMBER,
  p_start_date_active     IN DATE,
  p_end_date_active       IN DATE,
  x_portfolio_party_id    OUT NOCOPY PA_PROJECT_PARTIES.PROJECT_PARTY_ID%TYPE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) IS

 l_project_party_id       NUMBER;
 l_resource_id            NUMBER;
 l_start_date_active      DATE;
 l_end_date_active        DATE;
 l_wf_item_type           VARCHAR2(30);
 l_wf_type                VARCHAR2(30);
 l_wf_party_process       VARCHAR2(30);
 l_assignment_id          NUMBER;
 l_grant_id               RAW(16);
 l_user                   VARCHAR2(200);
 l_role                   VARCHAR2(200);
 -- standard parameters
 l_return_status          VARCHAR2(1);
 l_api_name               CONSTANT VARCHAR2(30) := 'Create_Portfolio_User';
 l_api_version            CONSTANT NUMBER    := 1.0;
 l_msg_log                VARCHAR2(2000) := null;
----------------------------------------------------------------------------

BEGIN

  l_return_status       := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
  l_end_date_active     := p_end_date_active;

  if p_start_date_active is null then
     l_start_date_active := sysdate;
  else
     l_start_date_active := p_start_date_active;
  end if;


        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering fpa_security_pvt.create_portfolio_user',
              x_return_status => x_return_status);

        -- check if activity started successfully
        if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;
/*
  if (check_user(p_party_id, p_object_id)) then
      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
      l_user := Get_party_Name(p_party_id);
      FPA_UTILITIES_PVT.SET_MESSAGE(
                      p_app_name => g_app_name
                    , p_msg_name => 'FPA_SEC_USER_EXISTS'
                    , p_token1   => 'USER'
                     ,p_token1_value => l_user);
      l_msg_log := 'FPA_SEC_USER_EXISTS'||p_party_id||','||p_object_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;
*/
  if (Get_Role(p_project_role_id) = G_OWNER AND Get_Owner(p_object_id) is not null) then
      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
      l_role := PA_SECURITY_PVT.get_proj_role_name(p_project_role_id);
      FPA_UTILITIES_PVT.SET_MESSAGE(
                        p_app_name => g_app_name
                      , p_msg_name => 'FPA_SEC_OWNER_ROLE_EXISTS'
                      , p_token1   => 'ROLE'
                       ,p_token1_value => l_role);
      l_msg_log := 'FPA_SEC_OWNER_ROLE_EXISTS'||p_project_role_id||','||p_object_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;

  PA_PROJECT_PARTIES_PVT.Create_Project_Party(
               p_commit                => FND_API.G_FALSE,
               p_validate_only         => FND_API.G_FALSE,
               p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
               p_debug_Mode            => 'N',
               p_object_ID             => p_object_id,
               p_object_Type           => G_PORTFOLIO,
               p_resource_Type_ID      => 101,
               p_project_Role_ID       => p_project_role_id,
               p_resource_Source_ID    => p_party_id,
               p_start_Date_Active     => l_start_date_active,
               p_scheduled_Flag        => 'N',
               p_calling_Module        => 'FORM',
               p_project_ID            => NULL,
               p_project_End_Date      => NULL,
               p_end_Date_Active       => l_end_date_active,
               x_project_Party_ID      => x_portfolio_party_id,
               x_resource_ID           => l_resource_id,
               x_assignment_ID         => l_assignment_id,
               x_WF_Type               => l_wf_type,
               x_WF_Item_Type          => l_wf_item_type,
               x_WF_Process            => l_wf_party_process,
               x_Return_Status         => x_return_status,
               x_Msg_Count             => x_msg_count,
               x_Msg_Data              => x_msg_data);

  if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
      l_msg_log := p_object_id||','||p_project_role_id||','||p_party_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
  elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
      l_msg_log := p_object_id||','||p_project_role_id||','||p_party_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;

  Grant_Role(p_api_version  => p_api_version,
         p_init_msg_list    => p_init_msg_list,
         p_project_role_id  => p_project_role_id,
         p_object_name      => G_PORTFOLIO,
         p_object_set       => p_instance_set_name,
         p_party_id         => p_party_id,
         p_source_type      => 'PERSON',
         x_grant_guid       => l_grant_id,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data);


   if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
      l_msg_log := p_object_id||','||p_project_role_id||','||p_party_id||','||l_grant_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
  elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
      l_msg_log := p_object_id||','||p_project_role_id||','||p_party_id||','||l_grant_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;

  FPA_UTILITIES_PVT.END_ACTIVITY(
              p_api_name     => l_api_name,
              p_pkg_name     => G_PKG_NAME,
              p_msg_log      => null,
              x_msg_count    => x_msg_count,
              x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Create_Portfolio_User;



PROCEDURE Update_Portfolio_User
(
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2,
  p_portfolio_party_id    IN PA_PROJECT_PARTIES.PROJECT_PARTY_ID%TYPE,
  p_project_role_id       IN PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_ID%TYPE,
  p_start_date_active     IN DATE,
  p_end_date_active       IN DATE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) IS

 -- standard parameters
 l_return_status          VARCHAR2(1);
 l_api_name               CONSTANT VARCHAR2(30) := 'Update_Portfolio_User';
 l_api_version            CONSTANT NUMBER    := 1.0;
 l_msg_log                VARCHAR2(2000) := null;
 ----------------------------------------------------------------------------

 CURSOR update_rec_csr (p_project_party_id IN NUMBER) IS
 select
    object_id,
    object_type,
    project_id,
    resource_id,
    resource_type_id,
    resource_source_id,
    project_role_id,
    start_date_active,
    end_date_active,
    scheduled_flag,
    record_version_number,
    grant_id
 from pa_project_parties
 where project_party_id = p_project_party_id;

l_wf_type              VARCHAR2(250);
l_wf_item_type         VARCHAR2(250);
l_wf_process           VARCHAR2(250);
l_assignment_id        NUMBER;

l_object_id             NUMBER;
l_object_type           VARCHAR2(30);
l_project_id            NUMBER;
l_resource_id           NUMBER;
l_resource_type_id      NUMBER;
l_resource_source_id    NUMBER;
l_project_role_id       NUMBER;
l_revoke_role_id        NUMBER;
l_start_date_active     DATE;
l_end_date_active       DATE;
l_scheduled_flag        VARCHAR2(1);
l_record_version_number NUMBER;
l_grant_id              RAW(16);
l_revoked               VARCHAR2(1);
l_user                  VARCHAR2(200);

l_project_party_id   NUMBER := p_portfolio_party_id;
x_call_overlap       VARCHAR2(1) := 'Y';
x_assignment_action  VARCHAR2(20) := 'NOACTION';

BEGIN

  l_return_status       := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
  x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

  x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
                p_api_name      => l_api_name,
                p_pkg_name      => G_PKG_NAME,
                p_init_msg_list => p_init_msg_list,
                l_api_version   => l_api_version,
                p_api_version   => p_api_version,
                p_api_type      => G_API_TYPE,
                p_msg_log       => 'Entering fpa_security_pvt.update_portfolio_user',
                x_return_status => x_return_status);

 -- check if activity started successfully
 if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
    l_msg_log := 'start_activity';
    raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
 elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
    l_msg_log := 'start_activity';
    raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
 end if;


 open update_rec_csr(p_portfolio_party_id);
 fetch update_rec_csr into
      l_object_id,
      l_object_type,
      l_project_id,
      l_resource_id,
      l_resource_type_id,
      l_resource_source_id,
      l_project_role_id,
      l_start_date_active,
      l_end_date_active,
      l_scheduled_flag,
      l_record_version_number,
      l_grant_id;
 close update_rec_csr;

 if(p_project_role_id <> l_project_role_id) then
    if (Get_Role(p_project_role_id) = G_OWNER AND Get_Owner(l_object_id) is not null) then
        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
        l_user := Get_party_Name(p_project_role_id);
        FPA_UTILITIES_PVT.SET_MESSAGE(
                        p_app_name => g_app_name
                      , p_msg_name => 'FPA_SEC_OWNER_ROLE_EXISTS'
                      , p_token1   => 'USER'
                       ,p_token1_value => l_user);
        l_msg_log := 'FPA_SEC_OWNER_ROLE_EXISTS'||p_project_role_id||','||l_object_id;
        raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;
 end if;

-- l_start_date_active := p_start_date_active;
  if p_start_date_active is null then
     l_start_date_active := sysdate;
  else
     l_start_date_active := p_start_date_active;
  end if;

 l_end_date_active   := p_end_date_active;

/*
NOT ABLE TO UPDATE USING BELOW CALL WITH VALIDATIONS AS ROLE ID IS IGNORED FOR UPDATE
WHEN "PA_INSTALL.IS_PRM_LICENSED()" IS 'Y'. NEED TO FIND OUT DETAILS ON THE
PROFILE OPTION IF BELOW CALL WITH VALIDATIONS CAN BE USED.
*/

/*
 PA_PROJECT_PARTIES_PVT.UPDATE_PROJECT_PARTY(
                    p_commit                => FND_API.G_FALSE,
                    p_validate_only         => FND_API.G_FALSE,
                    p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                    p_debug_mode            => 'N',
                    p_object_id             => l_object_id,
                    p_object_type           => l_object_type,
                    p_project_role_id       => p_project_role_id,
                    p_resource_type_id      => l_resource_type_id,
                    p_resource_source_id    => l_resource_source_id,
                    p_resource_id           => l_resource_id,
                    p_start_date_active     => l_start_date_active,
                    p_scheduled_flag        => l_scheduled_flag,
                    p_record_version_number => l_record_version_number,
                    p_calling_module        => 'FORM',
                    p_project_id            => null,
                    p_project_end_date      => l_end_date_active,
                    p_project_party_id      => p_portfolio_party_id,
                    p_assignment_id         => 0,
                    p_assign_record_version_number => null,
                    p_end_date_active       => l_end_date_active,
                    x_assignment_id         => l_assignment_id,
                    x_wf_type               => l_wf_type,
                    x_wf_item_type          => l_wf_item_type,
                    x_wf_process            => l_wf_process,
                    x_return_status         => l_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data);

   if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
      l_msg_log := p_portfolio_party_id||','||l_project_role_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
  elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
      l_msg_log := p_portfolio_party_id||','||l_project_role_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;
  x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
                    */

  pa_project_parties_utils.validate_project_party(
                            FND_API.G_VALID_LEVEL_FULL,
                            'N',
                            l_object_id,
                            l_object_type,
                            p_project_role_id,
                            l_resource_type_id,
                            l_resource_source_id,
                            l_start_date_active,
                            NVL(l_scheduled_flag, 'N'),
                            l_record_version_number,
                            'FORM',
                            'UPDATE',
                            l_object_id,
                            l_end_date_active,
                            l_end_date_active,
                            l_project_party_id,
                            x_call_overlap,
                            x_assignment_action,
                            x_return_status);

   if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
      l_msg_log := p_portfolio_party_id||','||l_project_role_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
  elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
      l_msg_log := p_portfolio_party_id||','||l_project_role_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;

  UPDATE pa_project_parties SET
        project_role_id    = p_project_role_id,
        start_date_active  = l_start_date_active,
        end_date_active    = l_end_date_active,
        last_update_date   = sysdate,
        last_updated_by    = fnd_global.user_id,
        last_update_login  = fnd_global.login_id
  WHERE project_party_id = p_portfolio_party_id;

  Revoke_Role(p_api_version      => l_api_version,
              p_init_msg_list    => p_init_msg_list,
              p_project_role_id  => l_project_role_id,
              p_object_name      => G_PORTFOLIO_SET_ALL,
              p_object_key       => l_object_id,
              p_party_id         => l_resource_source_id,
              p_source_type      => 'PERSON',
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);

   if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
      l_msg_log := p_portfolio_party_id||','||l_project_role_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
  elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
      l_msg_log := p_portfolio_party_id||','||l_project_role_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;


    Grant_Role(p_api_version       => p_api_version,
               p_init_msg_list     => p_init_msg_list,
               p_project_role_id   => p_project_role_id,
               p_object_name       => G_PORTFOLIO,
               p_object_set        => G_PORTFOLIO_SET_ALL,
               p_party_id          => l_resource_source_id,
               p_source_type       => 'PERSON',
               x_grant_guid        => l_grant_id,
               x_return_status     => x_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data);

     if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
        l_msg_log := p_portfolio_party_id||','||l_resource_source_id||','||l_project_role_id;
        raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
        l_msg_log := p_portfolio_party_id||','||l_resource_source_id||','||l_project_role_id;
        raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

  -- end if;

  FPA_UTILITIES_PVT.END_ACTIVITY(
                p_api_name     => l_api_name,
                p_pkg_name     => G_PKG_NAME,
                p_msg_log      => l_msg_log,
                x_msg_count    => x_msg_count,
                x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END Update_Portfolio_User;


  PROCEDURE Update_Portfolio_Owner
  (
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2,
    p_portfolio_id          IN NUMBER,
    p_person_id             IN NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2) IS

   -- standard parameters
   l_return_status          VARCHAR2(1);
   l_api_name               CONSTANT VARCHAR2(30) := 'Update_Portfolio_Owner';
   l_api_version            CONSTANT NUMBER    := 1.0;
   l_msg_log                VARCHAR2(2000) := null;
   ----------------------------------------------------------------------------
   CURSOR owner_rec_csr (p_portfolio_id IN NUMBER) IS

    select
        pp.project_party_id,
        pp.resource_source_id,
        pp.project_role_id
    from pa_project_parties pp, pa_project_role_types_b rlt
    where pp.object_type = 'PJP_PORTFOLIO'
    and   pp.object_id = p_portfolio_id
    and   PP.project_role_id = rlt.project_role_id
    and   rlt.project_role_type = G_OWNER;


  l_wf_type              VARCHAR2(250);
  l_wf_item_type         VARCHAR2(250);
  l_wf_process           VARCHAR2(250);
  l_assignment_id        NUMBER;

  l_project_party_id     NUMBER;
  l_resource_source_id   NUMBER;
  l_project_role_id      NUMBER;
  l_grant_id             RAW(16);
  l_user                 VARCHAR2(200);

  BEGIN

    l_return_status       := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
                  p_api_name      => l_api_name,
                  p_pkg_name      => G_PKG_NAME,
                  p_init_msg_list => p_init_msg_list,
                  l_api_version   => l_api_version,
                  p_api_version   => p_api_version,
                  p_api_type      => G_API_TYPE,
                  p_msg_log       => 'Entering fpa_security_pvt.update_portfolio_owner',
                  x_return_status => x_return_status);

   -- check if activity started successfully
   if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
      l_msg_log := 'start_activity';
      raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
   elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
      l_msg_log := 'start_activity';
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
   end if;


   open owner_rec_csr(p_portfolio_id);
   fetch owner_rec_csr into
        l_project_party_id,
        l_resource_source_id,
        l_project_role_id;
   close owner_rec_csr;


   if(p_person_id = l_resource_source_id) then
        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        FPA_UTILITIES_PVT.END_ACTIVITY(
                      p_api_name     => l_api_name,
                      p_pkg_name     => G_PKG_NAME,
                      p_msg_log      => 'Exiting fpa_security_pvt.update_portfolio_owner',
                      x_msg_count    => x_msg_count,
                      x_msg_data     => x_msg_data);
   end if;


    /*
   if(p_person_id <> l_resource_source_id) then
      if (check_user(p_person_id, p_portfolio_id)) then
           x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
           l_user := Get_party_Name(p_person_id);
           FPA_UTILITIES_PVT.SET_MESSAGE(
                           p_app_name => g_app_name
                         , p_msg_name => 'FPA_SEC_USER_EXISTS'
                         , p_token1   => 'USER'
                          ,p_token1_value => l_user);
           l_msg_log := 'FPA_SEC_USER_EXISTS'||p_person_id||','||p_portfolio_id;
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;
   end if;
   */

  /*

   PA_PROJECT_PARTIES_PVT.UPDATE_PROJECT_PARTY(
                      p_commit                => FND_API.G_FALSE,
                      p_validate_only         => FND_API.G_FALSE,
                      p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                      p_debug_mode            => 'N',
                      p_object_id             => l_object_id,
                      p_object_type           => l_object_type,
                      p_project_role_id       => p_project_role_id,
                      p_resource_type_id      => l_resource_type_id,
                      p_resource_source_id    => l_resource_source_id,
                      p_resource_id           => l_resource_id,
                      p_start_date_active     => l_start_date_active,
                      p_scheduled_flag        => l_scheduled_flag,
                      p_record_version_number => l_record_version_number,
                      p_calling_module        => 'FORM',
                      p_project_id            => null,
                      p_project_end_date      => l_end_date_active,
                      p_project_party_id      => p_portfolio_party_id,
                      p_assignment_id         => 0,
                      p_assign_record_version_number => null,
                      p_end_date_active       => l_end_date_active,
                      x_assignment_id         => l_assignment_id,
                      x_wf_type               => l_wf_type,
                      x_wf_item_type          => l_wf_item_type,
                      x_wf_process            => l_wf_process,
                      x_return_status         => l_return_status,
                      x_msg_count             => x_msg_count,
                      x_msg_data              => x_msg_data);

     if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
        l_msg_log := p_portfolio_party_id||','||l_project_role_id;
        raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
        l_msg_log := p_portfolio_party_id||','||l_project_role_id;
        raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;
    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

                      */

  /*
  NOT ABLE TO UPDATE USING ABOVE CALL WITH VALIDATIONS AS ROLE ID IS IGNORED FOR UPDATE
  WHEN "PA_INSTALL.IS_PRM_LICENSED()" IS 'Y'. NEED TO FIND OUT DETAILS ON THE
  PROFILE OPTION IF ABOVE CALL WITH VALIDATIONS CAN BE USED.
  */

     UPDATE pa_project_parties SET
          resource_source_id = p_person_id
     WHERE project_party_id  = l_project_party_id;

    Revoke_Role(p_api_version      => l_api_version,
                p_init_msg_list    => p_init_msg_list,
                p_project_role_id  => l_project_role_id,
                p_object_name      => G_PORTFOLIO_SET_ALL,
                p_object_key       => p_portfolio_id,
                p_party_id         => l_resource_source_id,
                p_source_type      => 'PERSON',
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data);

     if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
        l_msg_log := l_project_party_id||','||l_resource_source_id;
        raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
        l_msg_log := l_project_party_id||','||l_resource_source_id;
        raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;


      Grant_Role(p_api_version       => p_api_version,
                 p_init_msg_list     => p_init_msg_list,
                 p_project_role_id   => l_project_role_id,
                 p_object_name       => G_PORTFOLIO,
                 p_object_set        => G_PORTFOLIO_SET_ALL,
                 p_party_id          => p_person_id,
                 p_source_type       => 'PERSON',
                 x_grant_guid        => l_grant_id,
                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data);

       if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
          l_msg_log := l_project_role_id||','||p_person_id;
          raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
          l_msg_log := l_project_role_id||','||p_person_id;
          raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;

    -- end if;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                  p_api_name     => l_api_name,
                  p_pkg_name     => G_PKG_NAME,
                  p_msg_log      => l_msg_log,
                  x_msg_count    => x_msg_count,
                  x_msg_data     => x_msg_data);

  EXCEPTION
        when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
           x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => G_PKG_NAME,
              p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
              p_msg_log   => l_msg_log,
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => G_API_TYPE);

        when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
           x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => G_PKG_NAME,
              p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
              p_msg_log   => l_msg_log,
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => G_API_TYPE);

        when OTHERS then
           x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => G_PKG_NAME,
              p_exc_name  => 'OTHERS',
              p_msg_log   => l_msg_log||SQLERRM,
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => G_API_TYPE);

    END Update_Portfolio_Owner;



/* ***************************************************************
Desc: Call to delete portfolio user and the the grant for the role.
parameters:
      p_portfolio_party_id -> pa_project_parties.project_party_id.
***************************************************************** */

PROCEDURE Delete_Portfolio_User
(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2,
  p_portfolio_party_id    IN  PA_PROJECT_PARTIES.PROJECT_PARTY_ID%TYPE,
  p_instance_set_name     IN  VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) IS

  CURSOR project_parties_csr (p_portfolio_party_id in number) IS
  SELECT project_role_id, resource_source_id, object_id
  FROM   pa_project_parties
  WHERE  project_party_id = p_portfolio_party_id;

  CURSOR verify_delete_csr (p_portfolio_party_id in number) IS
  SELECT 'T'
  FROM   pa_project_parties
  WHERE  project_party_id = p_portfolio_party_id;


  l_role_id      number;
  l_object_id    number;
  l_party_id     number;
  l_instance_set_id number;
  l_exists       varchar2(1);
  l_revoked      varchar2(1);
  l_grant_id     raw(16);
  l_user         varchar2(200);

 -- standard parameters
 l_return_status          VARCHAR2(1);
 l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Portfolio_User';
 l_api_version            CONSTANT NUMBER    := 1.0;
 l_msg_log                VARCHAR2(2000) := null;
----------------------------------------------------------------------------
 BEGIN
        l_exists        := FND_API.G_FALSE;

        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering fpa_security_pvt.delete_portfolio_user',
              x_return_status => x_return_status);

        -- check if activity started successfully
        if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

    open  project_parties_csr(p_portfolio_party_id => p_portfolio_party_id);
    fetch project_parties_csr into l_role_id, l_party_id, l_object_id;
    if project_parties_csr%NOTFOUND then
      close project_parties_csr;
      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
      l_user := Get_party_Name(l_party_id);
      FPA_UTILITIES_PVT.SET_MESSAGE(
                      p_app_name => g_app_name
                    , p_msg_name => 'FPA_SEC_DELETE_FAILED'
                    , p_token1   => 'USER'
                     ,p_token1_value => l_user);
      l_msg_log := 'FPA_SEC_DELETE_FAILED'||p_portfolio_party_id;
      raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;
    close project_parties_csr;
--  l_grant_id := pa_project_parties_utils.get_grant_id(
--                                         p_project_party_id => p_portfolio_party_id);

    PA_PROJECT_PARTIES_PKG.Delete_Row(x_project_id => null,
                                      x_project_party_id => p_portfolio_party_id,
                                      x_record_version_number => null);

  -- no return status verifying delete ?

  open verify_delete_csr(p_portfolio_party_id);
  fetch verify_delete_csr into l_exists;
  close verify_delete_csr;


  if(l_exists = FND_API.G_TRUE) then
     x_return_status := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
     l_user := Get_party_Name(l_party_id);
     FPA_UTILITIES_PVT.SET_MESSAGE(
                      p_app_name => g_app_name
                    , p_msg_name => 'FPA_SEC_DELETE_FAILED'
                    , p_token1   => 'USER'
                     ,p_token1_value => l_user);
     l_msg_log := 'FPA_SEC_DELETE_FAILED '||p_portfolio_party_id;
     raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
  end if;

  l_instance_set_id := pa_security_pvt.get_instance_set_id(p_instance_set_name);

  Revoke_Role(p_api_version      => l_api_version,
              p_init_msg_list    => p_init_msg_list,
              p_project_role_id  => l_role_id,
              p_object_name      => G_PORTFOLIO_SET_ALL,
              p_object_key       => l_object_id,
              p_party_id         => l_party_id,
              p_source_type      => 'PERSON',
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);

           -- check if activity started successfully
 if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
     l_msg_log := p_portfolio_party_id||','||l_role_id||','||l_instance_set_id||','||l_party_id;
     raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
 elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
     l_msg_log := p_portfolio_party_id||','||l_role_id||','||l_instance_set_id||','||l_party_id;
     raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
 end if;

 FPA_UTILITIES_PVT.END_ACTIVITY(
            p_api_name     => l_api_name,
            p_pkg_name     => G_PKG_NAME,
            p_msg_log      => 'end fpa_security_pvt.Delete_Portfolio_User',
            x_msg_count    => x_msg_count,
            x_msg_data     => x_msg_data);


EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLCODE||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END Delete_Portfolio_User;

end FPA_SECURITY_PVT;

/
