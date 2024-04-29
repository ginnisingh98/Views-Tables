--------------------------------------------------------
--  DDL for Package Body AMV_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_USER_PVT" AS
/*  $Header: amvvusrb.pls 120.1 2005/06/29 10:43:09 appldev ship $ */
-- * * * USER BLOCK API * * *
--
-- NAME
--   AMV_USER_PVT
--
-- HISTORY
--   11/04/1999        PWU        CREATED
--
--   06/30/2000        SHITIJ VATSA   UPDATED
--
--   12/26/2002		KALYAN 	      Modified pls refer the bug# 2709045,272331
--
--                     (svatsa)       Made the following changes for Territory Privilege Integration
--                                    1. Modified the API Get_RoleIDArray to support Territory Intg
--                                    2. Modified the API Get_Role to support Territory Intg
--
--	12/21/00		MADESAI	MODIFIED DELETE_GROUP API to add code to delete
--                            from amv_c_channels when a Group is deleted.
--
--	8/20/03		SHARMA	replaced email by username in find resource proc
--
--
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMV_USER_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'amvvusrb.pls';
--
G_RESOURCE_ROLE_CODE CONSTANT VARCHAR2(30) := 'RS_INDIVIDUAL';
G_GROUP_ROLE_CODE    CONSTANT VARCHAR2(30) := 'RS_GROUP';
-- Debug mode
G_DEBUG boolean := FALSE;
--G_DEBUG boolean := TRUE;
--
--
TYPE    CursorType    IS REF CURSOR;
--
--
----------------------------- Private Portinon ---------------------------------
--------------------------------------------------------------------------------
FUNCTION Get_RoleId
(
    p_role_code  VARCHAR2
) return NUMBER;
PROCEDURE Add_Access_Helper
(
    p_access_obj          IN  AMV_ACCESS_OBJ_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_access_id           OUT NOCOPY NUMBER
);
PROCEDURE Update_Access_Helper
(
    p_access_obj          IN  AMV_ACCESS_OBJ_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2
);
--------------------------------------------------------------------------------
FUNCTION Get_RoleId
(
    p_role_code  VARCHAR2
) return NUMBER AS
--
CURSOR  Get_MES_Role_Id_csr (p_role_code IN VARCHAR2) IS
Select
    role_id
From jtf_rs_roles_vl
Where role_code = p_role_code
And   role_type_code = G_MES_ROLE_TYPE_NAME
;
l_role_id   number := FND_API.G_MISS_NUM;
BEGIN
     OPEN  Get_MES_Role_Id_csr(p_role_code);
     FETCH Get_MES_Role_Id_csr INTO l_role_id;
     CLOSE Get_MES_Role_Id_csr;
     return  l_role_id;
END Get_RoleId;
--------------------------------------------------------------------------------
FUNCTION Get_Role(p_resource_id IN NUMBER, p_resource_type IN VARCHAR2)
RETURN STRING AS
l_return_str    VARCHAR2(7) := '';
l_temp          NUMBER;

CURSOR check_role_csr(p_role_code IN VARCHAR2) IS
Select
     rol.role_id
From jtf_rs_roles_vl rol, jtf_rs_role_relations_vl rel
Where rol.role_id = rel.role_id
And rel.role_resource_id = p_resource_id
And rel.role_resource_type = p_resource_type
And rol.role_type_code = G_MES_ROLE_TYPE_NAME
And rol.role_code = p_role_code;

BEGIN
   OPEN check_role_csr(G_ADMINISTRTOR_CODE);
   FETCH check_role_csr INTO l_temp;
   IF (check_role_csr%FOUND) THEN
      l_return_str := l_return_str || 'T';
   ELSE
      l_return_str := l_return_str || 'F';
   END IF;
   CLOSE check_role_csr;

   OPEN check_role_csr(G_CAN_PUBLISH_CODE);
   FETCH check_role_csr INTO l_temp;
   IF (check_role_csr%FOUND) THEN
      l_return_str := l_return_str || 'T';
   ELSE
      l_return_str := l_return_str || 'F';
   END IF;
   CLOSE check_role_csr;

   OPEN check_role_csr(G_CAN_APPROVE_CODE);
   FETCH check_role_csr INTO l_temp;
   IF (check_role_csr%FOUND) THEN
      l_return_str := l_return_str || 'T';
   ELSE
      l_return_str := l_return_str || 'F';
   END IF;
   CLOSE check_role_csr;

   OPEN check_role_csr(G_CAN_SETUP_CHANNEL_CODE);
   FETCH check_role_csr INTO l_temp;
   IF (check_role_csr%FOUND) THEN
      l_return_str := l_return_str || 'T';
   ELSE
      l_return_str := l_return_str || 'F';
   END IF;
   CLOSE check_role_csr;

   OPEN check_role_csr(G_CAN_SETUP_CATEGORY_CODE);
   FETCH check_role_csr INTO l_temp;
   IF (check_role_csr%FOUND) THEN
      l_return_str := l_return_str || 'T';
   ELSE
      l_return_str := l_return_str || 'F';
   END IF;
   CLOSE check_role_csr;

   OPEN check_role_csr(G_CAN_SETUP_DIST_CODE);
   FETCH check_role_csr INTO l_temp;
   IF (check_role_csr%FOUND) THEN
      l_return_str := l_return_str || 'T';
   ELSE
      l_return_str := l_return_str || 'F';
   END IF;
   CLOSE check_role_csr;

-- Begin : Territory Integration
-- 07/06/2000 svatsa
   OPEN check_role_csr(G_CAN_SETUP_TERRITORY_CODE);
   FETCH check_role_csr INTO l_temp;
   IF (check_role_csr%FOUND) THEN
      l_return_str := l_return_str || 'T';
   ELSE
      l_return_str := l_return_str || 'F';
   END IF;
   CLOSE check_role_csr;
-- End : Territory Integration

   RETURN l_return_str;
--dbms_output.put_line('l_return_str'||l_return_str);
EXCEPTION
    WHEN OTHERS THEN
       l_return_str := 'FFFFFFF';
       RETURN l_return_str;
END Get_Role;
--------------------------------------------------------------------------------
PROCEDURE Get_RoleIDArray
(p_role_code_array IN  VARCHAR2,
 x_role_id_varray  OUT NOCOPY AMV_NUMBER_VARRAY_TYPE
) AS
l_str     VARCHAR2(1);
l_index   NUMBER := 1;
BEGIN
    x_role_id_varray := AMV_NUMBER_VARRAY_TYPE();
    l_str := substr(p_role_code_array, 1, 1);
    IF (l_str = 'T') THEN
       x_role_id_varray.extend;
       x_role_id_varray(l_index) := Get_RoleId(G_ADMINISTRTOR_CODE);
       l_index := l_index + 1;
    END IF;
    l_str := substr(p_role_code_array, 2, 1);
    IF (l_str = 'T') THEN
       x_role_id_varray.extend;
       x_role_id_varray(l_index) := Get_RoleId(G_CAN_PUBLISH_CODE);
       l_index := l_index + 1;
    END IF;
    l_str := substr(p_role_code_array, 3, 1);
    IF (l_str = 'T') THEN
       x_role_id_varray.extend;
       x_role_id_varray(l_index) := Get_RoleId(G_CAN_APPROVE_CODE);
       l_index := l_index + 1;
    END IF;
    l_str := substr(p_role_code_array, 4, 1);
    IF (l_str = 'T') THEN
       x_role_id_varray.extend;
       x_role_id_varray(l_index) := Get_RoleId(G_CAN_SETUP_CHANNEL_CODE);
       l_index := l_index + 1;
    END IF;
    l_str := substr(p_role_code_array, 5, 1);
    IF (l_str = 'T') THEN
       x_role_id_varray.extend;
       x_role_id_varray(l_index) := Get_RoleId(G_CAN_SETUP_CATEGORY_CODE);
       l_index := l_index + 1;
    END IF;
    l_str := substr(p_role_code_array, 6, 1);
    IF (l_str = 'T') THEN
       x_role_id_varray.extend;
       x_role_id_varray(l_index) := Get_RoleId(G_CAN_SETUP_DIST_CODE);
       l_index := l_index + 1;
    END IF;

    -- Begin : Territory Integration
    -- 06/30/2000 svatsa
    l_str := substr(p_role_code_array, 7, 1);
    IF (l_str = 'T') THEN
       x_role_id_varray.extend;
       x_role_id_varray(l_index) := Get_RoleId(G_CAN_SETUP_TERRITORY_CODE);
       l_index := l_index + 1;
    END IF;
    -- End : Territory Integration

END Get_RoleIDArray;
--------------------------------------------------------------------------------
PROCEDURE Add_Access_Helper
(
    p_access_obj      IN  AMV_ACCESS_OBJ_TYPE,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_access_id       OUT NOCOPY NUMBER
) AS
--
l_api_name             CONSTANT VARCHAR2(30) := 'Add_Access_helper';
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_access_id            NUMBER;
l_date                 DATE;
l_access_obj           AMV_ACCESS_OBJ_TYPE;
--
CURSOR Get_IDandDate_csr is
Select amv_u_access_s.nextval, sysdate
From   Dual;
--
BEGIN
    SAVEPOINT  Add_Access_helper_PVT;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
        l_current_resource_id := -1;
    END IF;
    OPEN  Get_IDandDate_csr;
    FETCH Get_IDandDate_csr INTO l_access_id, l_date;
    CLOSE Get_IDandDate_csr;
    l_access_obj := p_access_obj;
    -- Maybe we add more checking on the passed object and make some change.
    Insert into amv_u_access
    (
       ACCESS_ID,
       OBJECT_VERSION_NUMBER,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       ACCESS_TO_TABLE_CODE,
       ACCESS_TO_TABLE_RECORD_ID,
       USER_OR_GROUP_ID,
       USER_OR_GROUP_TYPE,
       EFFECTIVE_START_DATE,
       EXPIRATION_DATE,
       CAN_VIEW_FLAG,
       CAN_CREATE_FLAG,
       CAN_DELETE_FLAG,
       CAN_UPDATE_FLAG,
       CAN_CREATE_DIST_RULE_FLAG,
       CHL_APPROVER_FLAG,
       CHL_REQUIRED_FLAG,
       CHL_REQUIRED_NEED_NOTIF_FLAG
    )
    values
    (
       l_access_id,
       1, --OBJECT_VERSION_NUMBER
       l_date,
       l_current_user_id,
       l_date,
       l_current_user_id,
       l_current_login_id,
       l_access_obj.ACCESS_TO_TABLE_CODE,
       l_access_obj.ACCESS_TO_TABLE_RECORD_ID,
       l_access_obj.USER_OR_GROUP_ID,
       l_access_obj.USER_OR_GROUP_TYPE,
       l_access_obj.EFFECTIVE_START_DATE,
       l_access_obj.EXPIRATION_DATE,
       l_access_obj.CAN_VIEW_FLAG,
       l_access_obj.CAN_CREATE_FLAG,
       l_access_obj.CAN_DELETE_FLAG,
       l_access_obj.CAN_UPDATE_FLAG,
       l_access_obj.CAN_CREATE_DIST_RULE_FLAG,
       l_access_obj.CHL_APPROVER_FLAG,
       l_access_obj.CHL_REQUIRED_FLAG,
       l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG
    );
    x_access_id   := l_access_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO  Add_Access_helper_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
END Add_Access_helper;
--------------------------------------------------------------------------------
PROCEDURE Update_Access_helper
(
    p_access_obj          IN  AMV_ACCESS_OBJ_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2
) AS
--
l_api_name             CONSTANT VARCHAR2(30) := 'Update_Access_helper';
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_access_id            NUMBER;
l_access_obj           AMV_ACCESS_OBJ_TYPE;
--
BEGIN
    SAVEPOINT  Update_Access_helper_PVT;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
        l_current_resource_id := -1;
    END IF;
    l_access_obj := p_access_obj;
    -- Maybe we add more checking on the passed object and make some change.
    Update amv_u_access
    Set LAST_UPDATE_DATE  = sysdate,
        LAST_UPDATED_BY   = l_current_user_id,
        LAST_UPDATE_LOGIN = l_current_login_id,
        OBJECT_VERSION_NUMBER = object_version_number + 1,
        EFFECTIVE_START_DATE = decode(l_access_obj.effective_start_date,
                                  FND_API.G_MISS_DATE, EFFECTIVE_START_DATE,
                                  l_access_obj.effective_start_date),
        EXPIRATION_DATE = decode(l_access_obj.expiration_date,
                                FND_API.G_MISS_DATE, EXPIRATION_DATE,
                                l_access_obj.expiration_date),
        CAN_VIEW_FLAG = decode(l_access_obj.can_view_flag,
                               FND_API.G_MISS_CHAR, CAN_VIEW_FLAG,
                               l_access_obj.can_view_flag),
        CAN_CREATE_FLAG = decode(l_access_obj.can_create_flag,
                               FND_API.G_MISS_CHAR, CAN_CREATE_FLAG,
                               l_access_obj.can_create_flag),
        CAN_DELETE_FLAG = decode(l_access_obj.can_delete_flag,
                               FND_API.G_MISS_CHAR, CAN_DELETE_FLAG,
                               l_access_obj.can_delete_flag),
        CAN_UPDATE_FLAG = decode(l_access_obj.can_update_flag,
                               FND_API.G_MISS_CHAR, CAN_UPDATE_FLAG,
                               l_access_obj.can_update_flag),
        CAN_CREATE_DIST_RULE_FLAG  =
                           decode(l_access_obj.can_create_dist_rule_flag,
                           FND_API.G_MISS_CHAR, CAN_CREATE_DIST_RULE_FLAG,
                           l_access_obj.can_create_dist_rule_flag),
        CHL_APPROVER_FLAG = decode(l_access_obj.chl_approver_flag,
                               FND_API.G_MISS_CHAR, CHL_APPROVER_FLAG,
                               l_access_obj.chl_approver_flag),
        CHL_REQUIRED_FLAG = decode(l_access_obj.chl_required_flag,
                               FND_API.G_MISS_CHAR, CHL_REQUIRED_FLAG,
                               l_access_obj.chl_required_flag),
        CHL_REQUIRED_NEED_NOTIF_FLAG =
                          decode(l_access_obj.chl_required_need_notif_flag,
                          FND_API.G_MISS_CHAR, CHL_REQUIRED_NEED_NOTIF_FLAG,
                          l_access_obj.chl_required_need_notif_flag)
    where access_id = l_access_obj.access_id
    ;--and object_version_number = l_access_obj.access_id.object_version_number;
    IF (SQL%NOTFOUND) THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.Set_Name('AMV', 'AMV_INVALID_ACCESS_ID');
          FND_MESSAGE.Set_Token('ACCESS_ID', TO_CHAR(l_access_obj.access_id) );
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO  Update_Access_helper_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
        END IF;
END Update_Access_helper;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Get_ResourceId
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    x_resource_id         OUT NOCOPY NUMBER
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ResourceId';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    IF (p_user_id = l_current_user_id) THEN
       x_resource_id := l_current_resource_id;
    ELSE
       AMV_UTILITY_PVT.Get_ResourceId
       (
          p_user_id      => p_user_id,
          x_resource_id  => x_resource_id
       );
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_ResourceId;
--------------------------------------------------------------------------------
PROCEDURE Find_Resource
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_last_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_first_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj   IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj    OUT NOCOPY AMV_RETURN_OBJ_TYPE,
    x_resource_obj_array   OUT NOCOPY AMV_RESOURCE_OBJ_VARRAY
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Find_Resource';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_cursor             CursorType;
l_sql_statement      VARCHAR2(2000);
l_sql_statement2     VARCHAR2(2000);
l_where_clause       VARCHAR2(2000);
l_total_count        NUMBER := 1;
l_fetch_count        NUMBER := 0;
l_start_with         NUMBER;
l_total_record_count NUMBER;
--
l_resource_id        NUMBER;
l_person_id          NUMBER;
l_user_name          VARCHAR2(80);
l_resource_name      VARCHAR2(80);
l_first_name         VARCHAR2(40);
l_last_name          VARCHAR2(40);
l_search             VARCHAR2(2000);
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
        l_current_resource_id := -1;
    END IF;
    -- Now create SQL statement and find the results:
    IF (p_group_id IS NULL OR p_group_id = FND_API.G_MISS_NUM) THEN
       l_sql_statement :=
          'Select ' ||
              'r.source_id, ' ||
              'r.resource_id, ' ||
              's.user_name, ' ||
	      'r.resource_name, ' ||
              'r.first_name, ' ||
              'r.last_name ' ||
              'From  amv_rs_all_res_extns_vl r,  jtf_rs_resource_extns s ';
       l_sql_statement2 :=
          'Select count(*) ' ||
              'From  amv_rs_all_res_extns_vl r, jtf_rs_resource_extns s ';
       l_where_clause := 'Where s.resource_id = r.resource_id ';
    ELSE
       l_sql_statement :=
          'Select ' ||
              'r.source_id, ' ||
              'r.resource_id, ' ||
              's.user_name, ' ||
	      'r.resource_name, ' ||
              'r.first_name, ' ||
              'r.last_name ' ||
              'From  amv_rs_all_res_extns_vl r, jtf_rs_group_members m, jtf_rs_resource_extns s  ';
       l_sql_statement2 :=
          'Select count(*) ' ||
              'From  amv_rs_all_res_extns_vl r, jtf_rs_group_members m, jtf_rs_resource_extns s  ';
       l_where_clause :=
         'Where m.resource_id = r.resource_id ' ||
         'And s.resource_id = r.resource_id ' ||
         'And m.delete_flag <> ''Y'' ' ||
         'And m.group_id = ' || p_group_id || ' ';
       IF (p_check_effective_date = FND_API.G_TRUE) THEN
           l_sql_statement  := l_sql_statement  || ', jtf_rs_groups_vl g ';
           l_sql_statement2 := l_sql_statement2 || ', jtf_rs_groups_vl g ';
           l_where_clause := l_where_clause ||
               'And g.group_id = ' || p_group_id || ' ' ||
               --'And r.start_date_active < sysdate ' ||
               --'And nvl(r.end_date_active, sysdate+1) > sysdate ' ||
               'And g.start_date_active < sysdate ' ||
               'And nvl(g.end_date_active, sysdate+1) > sysdate ';
       END IF;
    END IF;
    IF (p_user_name IS NOT NULL AND p_user_name <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
          'And ( upper(s.user_name) Like upper(''' || p_user_name || ''') ' ||
           'OR upper(r.resource_name) Like upper(''' || p_user_name || ''')' ||
           'OR upper(r.first_name) Like upper(''' || p_user_name || ''') ' ||
           'OR upper(r.last_name) Like upper(''' || p_user_name || ''') ) ';
    END IF;


    l_sql_statement := l_sql_statement ||
         l_where_clause || 'ORDER BY r.last_name, r.first_name ';
    l_sql_statement2 := l_sql_statement2 || l_where_clause;

    IF (G_DEBUG = TRUE) THEN
         AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(l_sql_statement);
    END IF;
    --Execute the SQL statements to get the total count:
    IF (p_subset_request_obj.return_total_count_flag = FND_API.G_TRUE) THEN
        OPEN  l_cursor FOR l_sql_statement2;
        FETCH l_cursor INTO l_total_record_count;
        CLOSE l_cursor;
    END IF;


    --Execute the SQL statements to get records
    l_start_with := p_subset_request_obj.start_record_position;
    x_resource_obj_array := AMV_RESOURCE_OBJ_VARRAY();
    OPEN l_cursor FOR l_sql_statement;
    LOOP
       FETCH l_cursor INTO
           l_person_id,
           l_resource_id,
           l_user_name,
	   l_resource_name,
           l_first_name,
           l_last_name;
       EXIT WHEN l_cursor%NOTFOUND;
       IF (l_start_with <= l_total_count AND
           l_fetch_count < p_subset_request_obj.records_requested) THEN
          l_fetch_count := l_fetch_count + 1;
          x_resource_obj_array.extend;
          x_resource_obj_array(l_fetch_count).resource_id := l_resource_id;
          x_resource_obj_array(l_fetch_count).person_id := l_person_id;
          x_resource_obj_array(l_fetch_count).user_name := l_user_name;

	/* Check for null first/last name. If null, use resource_name */
        IF (l_first_name IS NULL OR l_last_name IS NULL) THEN
          x_resource_obj_array(l_fetch_count).first_name := l_resource_name;
          x_resource_obj_array(l_fetch_count).last_name := '';
	ELSE
          x_resource_obj_array(l_fetch_count).first_name := l_first_name;
          x_resource_obj_array(l_fetch_count).last_name := l_last_name;
	END IF;

       END IF;
       IF (l_fetch_count >= p_subset_request_obj.records_requested) THEN
          exit;
       END IF;
       l_total_count := l_total_count + 1;
    END LOOP;
   CLOSE l_cursor;

   x_subset_return_obj.returned_record_count := l_fetch_count;
   x_subset_return_obj.next_record_position := p_subset_request_obj.start_record_position + l_fetch_count;
   x_subset_return_obj.total_record_count := l_total_record_count;

/*
   x_subset_return_obj := AMV_RETURN_OBJ_TYPE
      (
         l_fetch_count,
         p_subset_request_obj.start_record_position + l_fetch_count,
         l_total_record_count
      );
*/
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Find_Resource;
--------------------------------------------------------------------------------
PROCEDURE Find_Resource
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id          IN  NUMBER   := FND_API.G_MISS_NUM,
    p_resource_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj   IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj    OUT NOCOPY AMV_RETURN_OBJ_TYPE,
    x_resource_obj_array   OUT NOCOPY AMV_RESOURCE_OBJ_VARRAY,
    x_role_code_varray     OUT NOCOPY AMV_CHAR_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Find_Resource';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_cursor             CursorType;
l_sql_statement      VARCHAR2(2000);
l_sql_statement2     VARCHAR2(2000);
l_where_clause       VARCHAR2(2000);
l_total_count        NUMBER := 1;
l_fetch_count        NUMBER := 0;
l_start_with         NUMBER;
l_total_record_count NUMBER;
--
l_resource_id        NUMBER;
l_person_id          NUMBER;
l_user_name          VARCHAR2(80);
l_resource_name      VARCHAR2(80);
l_first_name         VARCHAR2(40);
l_last_name          VARCHAR2(40);
l_search             VARCHAR2(2000);
--
BEGIN
--dbms_output.put_line('Enter : Find_Resource');
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
        l_current_resource_id := -1;
    END IF;
    -- Now create SQL statement and find the results:
    l_sql_statement :=
        'Select ' ||
          'r.source_id, ' ||
          'r.resource_id, ' ||
          'r.email user_name, ' ||
          'r.resource_name, ' ||
	  'r.first_name, ' ||
          'r.last_name ' ||
          'From  amv_rs_all_res_extns_vl r ';
    l_sql_statement2 :=
      'Select count(*) ' ||fnd_global.local_chr(10)||
         'From  amv_rs_all_res_extns_vl r ';
    --l_where_clause := 'Where r.start_date_active < sysdate ' ||
    --        'And nvl(r.end_date_active, sysdate+1) > sysdate ';
    IF ( p_resource_id = FND_API.G_MISS_NUM ) THEN
        l_where_clause :=
        'Where ( upper(r.email) Like upper(''' || p_resource_name ||''') ' ||
        'OR upper(r.resource_name) Like upper('''||p_resource_name||''') ' ||
        'OR upper(r.first_name) Like upper(''' || p_resource_name || ''') ' ||
        'OR upper(r.last_name) Like upper(''' || p_resource_name || ''') ) ';
    ELSE
        l_where_clause := 'Where resource_id = ' || p_resource_id || ' ';

    END IF;
    l_sql_statement := l_sql_statement ||fnd_global.local_chr(10)||
                       l_where_clause  ||fnd_global.local_chr(10)|| 'ORDER BY r.last_name, r.first_name ';

    l_sql_statement2 := l_sql_statement2 ||fnd_global.local_chr(10)||l_where_clause;
    IF (G_DEBUG = TRUE) THEN
         AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(l_sql_statement);
    END IF;
    --Execute the SQL statements to get the total count:
--dbms_output.put_line('l_sql_statement2 : '||l_sql_statement2);
    IF (p_subset_request_obj.return_total_count_flag = FND_API.G_TRUE) THEN
        OPEN  l_cursor FOR l_sql_statement2;
        FETCH l_cursor INTO l_total_record_count;
        CLOSE l_cursor;
    END IF;
    --Execute the SQL statements to get records

    l_start_with := p_subset_request_obj.start_record_position;
    x_resource_obj_array := AMV_RESOURCE_OBJ_VARRAY();
    x_role_code_varray := AMV_CHAR_VARRAY_TYPE();
--dbms_output.put_line('l_sql_statement : '||l_sql_statement);


    OPEN l_cursor FOR l_sql_statement;
--dbms_output.put_line('Opened cursor');
    LOOP
--dbms_output.put_line('Fetch cursor');
       FETCH l_cursor INTO
           l_person_id,
           l_resource_id,
           l_user_name,
	   l_resource_name,
           l_first_name,
           l_last_name;
       EXIT WHEN l_cursor%NOTFOUND;
       IF (l_start_with <= l_total_count AND
           l_fetch_count < p_subset_request_obj.records_requested) THEN
--dbms_output.put_line('Inside IF cursor');
          l_fetch_count := l_fetch_count + 1;
          x_resource_obj_array.extend;
          x_resource_obj_array(l_fetch_count).resource_id := l_resource_id;
          x_resource_obj_array(l_fetch_count).person_id := l_person_id;
          x_resource_obj_array(l_fetch_count).user_name := l_user_name;

        /* Check for null first/last name. If null, use resource_name */
        IF (l_first_name IS NULL OR l_last_name IS NULL) THEN
          x_resource_obj_array(l_fetch_count).first_name := l_resource_name;
          x_resource_obj_array(l_fetch_count).last_name := '';
	ELSE
          x_resource_obj_array(l_fetch_count).first_name := l_first_name;
          x_resource_obj_array(l_fetch_count).last_name := l_last_name;
	END IF;

          --Get the user roles:
          x_role_code_varray.extend;
--dbms_output.put_line('Getting Role');
          x_role_code_varray(l_fetch_count) := Get_Role(l_resource_id, G_RESOURCE_ROLE_CODE);
--dbms_output.put_line('x_role_code_varray(l_fetch_count)'||x_role_code_varray(l_fetch_count));
       END IF;
       IF (l_fetch_count >= p_subset_request_obj.records_requested) THEN
          exit;
       END IF;
       l_total_count := l_total_count + 1;
--dbms_output.put_line('Fetching Again');
    END LOOP;
   CLOSE l_cursor;
--dbms_output.put_line('Closed cursor');
   x_subset_return_obj.returned_record_count := l_fetch_count;
   x_subset_return_obj.next_record_position := p_subset_request_obj.start_record_position + l_fetch_count;
   x_subset_return_obj.total_record_count := l_total_record_count;

/*
   x_subset_return_obj := AMV_RETURN_OBJ_TYPE
      (
         l_fetch_count,
         p_subset_request_obj.start_record_position + l_fetch_count,
         l_total_record_count
      );
*/
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
--dbms_output.put_line('Exit : Find_Resource');
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Find_Resource;
--------------------------------------------------------------------------------
-------------------------- RESOURCE and GROUP ROLE HELPER ----------------------
--------------------------------------------------------------------------------
PROCEDURE Add_AssignRoleHelper
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_resource_type       IN  VARCHAR2,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_AssignRoleHelper';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_role_id              NUMBER;
l_role_code            VARCHAR2(30);
l_temp                 NUMBER;
l_date                 DATE;
--
CURSOR  Check_ResourceRole_csr IS
Select role_relate_id
From  jtf_rs_role_relations_vl
Where role_id = l_role_id
And   role_resource_id = p_resource_id
And   role_resource_type = p_resource_type
;
--
BEGIN

    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_AssignRoleHelper_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    --
    IF (p_role_id = FND_API.G_MISS_NUM) THEN
        l_role_id := get_roleid(p_role_code);
    ELSE
        l_role_id := p_role_id;
    END IF;
    OPEN  Check_ResourceRole_csr;
    FETCH Check_ResourceRole_csr INTO l_temp;
    IF (Check_ResourceRole_csr%NOTFOUND) THEN
        CLOSE Check_ResourceRole_csr;
        IF (p_role_id = FND_API.G_MISS_NUM) THEN
            l_role_id := null;
        ELSE
            l_role_id := p_role_id;
        END IF;
        IF (p_role_code = FND_API.G_MISS_CHAR) THEN
            l_role_code := null;
        ELSE
            l_role_code := p_role_code;
        END IF;


        jtf_rs_role_relate_pub.create_resource_role_relate
        (
            p_api_version        => p_api_version,
            p_commit             => p_commit,
            p_role_resource_type => p_resource_type,
            p_role_resource_id   => p_resource_id,
            p_role_id            => l_role_id,
            p_role_code          => l_role_code,
            p_start_date_active  => sysdate,
            p_end_date_active    => null,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_role_relate_id     => l_temp
        );


    ELSE
        CLOSE Check_ResourceRole_csr;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_AssignRoleHelper_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_AssignRoleHelper_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_AssignRoleHelper_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_AssignRoleHelper;
--------------------------------------------------------------------------------
PROCEDURE Remove_RoleHelper
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_resource_type       IN  VARCHAR2,
    p_role_id             IN  NUMBER
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Remove_RoleHelper';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_role_relate_id       NUMBER;
l_version              NUMBER;
--
CURSOR  Check_ResourceRole_csr IS
Select
      role_relate_id,
      object_version_number
From  jtf_rs_role_relations
Where role_id = p_role_id
And   role_resource_id = p_resource_id
And   role_resource_type = p_resource_type
And   delete_flag <> 'Y'
--And   role_type_code = G_MES_ROLE_TYPE_NAME
;
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Remove_RoleHelper_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    OPEN   Check_ResourceRole_csr;
    FETCH  Check_ResourceRole_csr INTO l_role_relate_id, l_version;
    IF (Check_ResourceRole_csr%NOTFOUND) THEN
       CLOSE Check_ResourceRole_csr;
       IF (p_resource_type = G_RESOURCE_ROLE_CODE) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_RESOURCE_NOT_HAS_ROLE');
               FND_MESSAGE.Set_Token('P_RESOURCE_ID', TO_CHAR(p_resource_id) );
               FND_MESSAGE.Set_Token('P_ROLE_ID', TO_CHAR(p_role_id) );
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
       ELSIF (p_resource_type = G_GROUP_ROLE_CODE) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_GROUP_NOT_HAS_ROLE');
               FND_MESSAGE.Set_Token('P_GROUP_ID', TO_CHAR(p_resource_id) );
               FND_MESSAGE.Set_Token('P_ROLE_ID', TO_CHAR(p_role_id) );
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    CLOSE Check_ResourceRole_csr;
    jtf_rs_role_relate_pub.delete_resource_role_relate
    (
         p_api_version        => p_api_version,
         p_commit             => p_commit,
         p_role_relate_id     => l_role_relate_id,
         p_object_version_num => l_version,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data
    );
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Remove_RoleHelper_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Remove_RoleHelper_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Remove_RoleHelper_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Remove_RoleHelper;
--------------------------------------------------------------------------------
-------------------------- RESOURCE ROLE ------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Add_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
) IS
BEGIN
    Add_AssignRoleHelper
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        p_validation_level  => p_validation_level,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_resource_id       => p_resource_id,
        p_resource_type     => G_RESOURCE_ROLE_CODE,
        p_role_id           => p_role_id,
        p_role_code         => p_role_code
    );
END Add_ResourceRole;
--------------------------------------------------------------------------------
PROCEDURE Add_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ResourceRole';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_return_status        VARCHAR2(1);
l_admin_flag           VARCHAR2(1);
l_count                NUMBER;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_ResourceRole_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the resource id is valid
    IF (AMV_UTILITY_PVT.IS_RESOURCEIDVALID(p_resource_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_RESOURCE_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_resource_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (p_role_id_varray IS NULL) THEN
        l_count := 0;
    ELSE
       l_count := p_role_id_varray.count;
    END IF;
    FOR i IN 1..l_count LOOP
        Add_ResourceRole
        (
            p_api_version         => p_api_version,
            p_commit              => p_commit,
            p_validation_level    => p_validation_level,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_check_login_user    => FND_API.G_FALSE,
            p_resource_id         => p_resource_id,
            p_role_id             => p_role_id_varray(i)
        );
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
               x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_ResourceRole;
--------------------------------------------------------------------------------
PROCEDURE Remove_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
)  AS
l_role_id         number;
BEGIN
    IF (p_role_id = FND_API.G_MISS_NUM) THEN
        l_role_id := Get_RoleId(p_role_code);
    ELSE
        l_role_id := p_role_id;
    END IF;
    Remove_RoleHelper
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_resource_id         => p_resource_id,
        p_resource_type       => G_RESOURCE_ROLE_CODE,
        p_role_id             => l_role_id
    );
END Remove_ResourceRole;
--------------------------------------------------------------------------------
PROCEDURE Remove_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE := NULL
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Remove_ResourceRole';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_count                NUMBER;
l_return_status        VARCHAR2(1);
l_role_id_varray       AMV_NUMBER_VARRAY_TYPE;
l_role_code_varray     AMV_CHAR_VARRAY_TYPE;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Remove_ResourceRole_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the resource id is valid
    IF (AMV_UTILITY_PVT.IS_RESOURCEIDVALID(p_resource_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_RESOURCE_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_resource_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (p_role_id_varray IS NULL OR p_role_id_varray.count = 0) THEN
       Get_ResourceRoles
       (
           p_api_version          => p_api_version,
           x_return_status        => l_return_status,
           x_msg_count            => x_msg_count,
           x_msg_data             => x_msg_data,
           p_check_login_user     => FND_API.G_FALSE,
           p_resource_id          => p_resource_id,
           x_role_id_varray       => l_role_id_varray,
           x_role_code_varray     => l_role_code_varray
       );
       IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_count := l_role_id_varray.count;
       ELSE
          l_count := 0;
          x_return_status := l_return_status;
       END IF;
    ELSE
       l_count := p_role_id_varray.count;
       l_role_id_varray := p_role_id_varray;
    END IF;

    FOR i IN 1..l_count LOOP
        Remove_ResourceRole
        (
           p_api_version        => p_api_version,
           p_commit             => p_commit,
           p_validation_level   => p_validation_level,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_check_login_user   => FND_API.G_FALSE,
           p_resource_id        => p_resource_id,
           p_role_id            => l_role_id_varray(i),
           p_role_code          => null
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Remove_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Remove_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Remove_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Remove_ResourceRole;
--------------------------------------------------------------------------------
PROCEDURE Replace_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_code           IN  VARCHAR2
) AS
l_role_id_array          AMV_NUMBER_VARRAY_TYPE;
BEGIN
   Get_RoleIDArray (p_role_code, l_role_id_array);
   Replace_ResourceRole
   (
    p_api_version       => p_api_version,
    p_init_msg_list     => p_init_msg_list,
    p_commit            => p_commit,
    p_validation_level  => p_validation_level,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_check_login_user  => p_check_login_user,
    p_resource_id       => p_resource_id,
    p_role_id_varray    => l_role_id_array
    );
END Replace_ResourceRole;
--------------------------------------------------------------------------------
PROCEDURE Replace_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Replace_ResourceRole';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_count                NUMBER;
l_temp                 NUMBER;
l_return_status        VARCHAR2(1);
l_date                 DATE;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Replace_ResourceRole_Pvt;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --Remove the existing roles
    Remove_ResourceRole
    (
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
	--commit parameter was not passed before,refer bug#270945,2727331
	p_commit           => p_commit,
        p_validation_level => p_validation_level,
        x_return_status    => l_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_check_login_user => p_check_login_user,
        p_resource_id      => p_resource_id,
        p_role_id_varray   => null
    );
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- Add new roles:
    Add_ResourceRole
    (
        p_api_version      => p_api_version,
        p_commit           => p_commit,
        p_validation_level => p_validation_level,
        x_return_status    => l_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_check_login_user => FND_API.G_FALSE,
        p_resource_id      => p_resource_id,
        p_role_id_varray   => p_role_id_varray
    );
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Replace_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Replace_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Replace_ResourceRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Replace_ResourceRole;
--------------------------------------------------------------------------------
PROCEDURE Get_ResourceRoles
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id          IN  NUMBER   := FND_API.G_MISS_NUM,
    x_role_id_varray       OUT NOCOPY AMV_NUMBER_VARRAY_TYPE,
    x_role_code_varray     OUT NOCOPY AMV_CHAR_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ResourceRoles';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_count                NUMBER := 0;
--
CURSOR Get_ResourceRole_csr IS
Select
     rol.role_code,
     rol.role_id
From  jtf_rs_role_relations_vl rel, jtf_rs_roles_vl rol
Where rel.role_resource_id = p_resource_id
And   rel.role_resource_type = G_RESOURCE_ROLE_CODE
And   rel.role_id = rol.role_id
And   rol.role_type_code = G_MES_ROLE_TYPE_NAME
Order by rol.role_code;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_role_id_varray   := AMV_NUMBER_VARRAY_TYPE();
    x_role_code_varray := AMV_CHAR_VARRAY_TYPE();
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the resource id is valid
    IF (AMV_UTILITY_PVT.IS_RESOURCEIDVALID(p_resource_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_RESOURCE_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_resource_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    FOR csr1 IN  Get_ResourceRole_csr LOOP
       l_count := l_count + 1;
       x_role_id_varray.extend;
       x_role_code_varray.extend;
       x_role_id_varray(l_count) := csr1.role_id;
       x_role_code_varray(l_count) := csr1.role_code;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_ResourceRoles;
--------------------------------------------------------------------------------
PROCEDURE Check_ResourceRole
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id          IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_id              IN  NUMBER,
    p_group_usage          IN VARCHAR2 := G_MES_GROUP_USAGE,
    p_include_group_flag   IN  VARCHAR2 := FND_API.G_TRUE,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag          OUT NOCOPY VARCHAR2
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Check_ResourceRole';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_resource_id          NUMBER;
l_temp                 NUMBER;
--
CURSOR Get_ResourceRole_csr(p_res_id IN NUMBER) IS
Select
     role_relate_id
From  jtf_rs_role_relations_vl
Where role_id = p_role_id
And   role_resource_id = p_res_id
And   role_resource_type = G_RESOURCE_ROLE_CODE
;
--
CURSOR Get_ResourceRole2_csr(p_res_id IN NUMBER) IS
Select rel.role_relate_id
From  jtf_rs_role_relations_vl rel
,     jtf_rs_resource_extns res
Where rel.role_id = p_role_id
And   rel.role_resource_id = p_res_id
And   rel.role_resource_type = G_RESOURCE_ROLE_CODE
And   res.resource_id = rel.role_resource_id
And   rel.start_date_active < sysdate
And   nvl(rel.end_date_active, sysdate+1) > sysdate
And   res.start_date_active < sysdate
And   nvl(res.end_date_active, sysdate+1) > sysdate
;
--
CURSOR Get_GroupRole_csr(p_res_id IN NUMBER) IS
Select
     1
From  dual
Where exists
   (
     select r.role_id
     from jtf_rs_group_members m, jtf_rs_role_relations_vl r,
          jtf_rs_group_usages usg
     where m.resource_id = p_res_id
     and   m.delete_flag <> 'Y'
     and   m.group_id = r.role_resource_id
     and   r.role_resource_type = G_GROUP_ROLE_CODE
     and   r.role_id = p_role_id
     and   m.group_id = usg.group_id
     and   usg.usage = p_group_usage
   );
--
CURSOR Get_GroupRole2_csr(p_res_id IN NUMBER) IS
Select
     1
From  dual
Where exists
   (
     select r.role_id
     from  jtf_rs_group_members m, jtf_rs_role_relations_vl r,
           jtf_rs_groups_vl g, jtf_rs_group_usages usg
     where m.resource_id = p_res_id
     and   m.delete_flag <> 'Y'
     and   m.group_id = r.role_resource_id
     and   r.role_id = p_role_id
     and   r.role_resource_type = G_GROUP_ROLE_CODE
     --and   r.role_type_code = G_MES_ROLE_TYPE_NAME
     and   r.start_date_active < sysdate
     and   nvl(r.end_date_active, sysdate+1) > sysdate
     and   g.group_id = m.group_id
     and   g.start_date_active < sysdate
     and   nvl(g.end_date_active, sysdate+1) > sysdate
     and   usg.group_id = g.group_id
     and   usg.usage = p_group_usage
   )
;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_result_flag := FND_API.G_FALSE;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    --
    IF (p_resource_id IS NULL OR p_resource_id = FND_API.G_MISS_NUM) THEN
        l_resource_id := l_current_resource_id;
    ELSE
        l_resource_id := p_resource_id;
        -- Check if the resource id is valid
        IF (AMV_UTILITY_PVT.IS_RESOURCEIDVALID(p_resource_id) <> TRUE) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_INVALID_RESOURCE_ID');
               FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_resource_id, -1) ) );
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    IF (p_check_effective_date = FND_API.G_TRUE) THEN
        OPEN  Get_ResourceRole2_csr(l_resource_id);
        FETCH Get_ResourceRole2_csr INTO l_temp;
        IF (Get_ResourceRole2_csr%FOUND) THEN
           x_result_flag := FND_API.G_TRUE;
        ELSE
           x_result_flag := FND_API.G_FALSE;
        END IF;
        CLOSE Get_ResourceRole2_csr;
    ELSE
        OPEN  Get_ResourceRole_csr(l_resource_id);
        FETCH Get_ResourceRole_csr INTO l_temp;
        IF (Get_ResourceRole_csr%FOUND) THEN
           x_result_flag := FND_API.G_TRUE;
        ELSE
           x_result_flag := FND_API.G_FALSE;
        END IF;
        CLOSE Get_ResourceRole_csr;
    END IF;

    IF ( x_result_flag = FND_API.G_FALSE AND
        p_include_group_flag = FND_API.G_TRUE ) THEN
        IF (p_check_effective_date = FND_API.G_TRUE) THEN
            OPEN  Get_GroupRole2_csr(l_resource_id);
            FETCH Get_GroupRole2_csr INTO l_temp;
            IF (Get_GroupRole2_csr%FOUND) THEN
                x_result_flag := FND_API.G_TRUE;
            END IF;
            CLOSE Get_GroupRole2_csr;
        ELSE
            OPEN  Get_GroupRole_csr(l_resource_id);
            FETCH Get_GroupRole_csr INTO l_temp;
            IF (Get_GroupRole_csr%FOUND) THEN
                x_result_flag := FND_API.G_TRUE;
            END IF;
            CLOSE Get_GroupRole_csr;
        END IF;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Check_ResourceRole;
--------------------------------------------------------------------------------
PROCEDURE Is_Administrator
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY VARCHAR2
)  AS
l_role_id    number;
BEGIN
  l_role_id := Get_RoleId(G_ADMINISTRTOR_CODE);
  Check_ResourceRole
  (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    p_check_login_user => p_check_login_user,
    p_resource_id => p_resource_id,
    p_role_id => l_role_id,
    p_include_group_flag => p_include_group_flag,
    p_check_effective_date => FND_API.G_TRUE,
    x_result_flag => x_result_flag
  );
END  Is_Administrator;
--------------------------------------------------------------------------------
PROCEDURE Can_PublishContent
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY VARCHAR2
)  AS
l_role_id    number;
BEGIN
  Is_Administrator
  (
    p_api_version,
    p_init_msg_list,
    p_validation_level,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_check_login_user,
    p_resource_id,
    p_include_group_flag,
    x_result_flag
  );
  IF (x_result_flag <> FND_API.G_TRUE) THEN
     l_role_id := Get_RoleId(G_CAN_PUBLISH_CODE);
     Check_ResourceRole
     (
       p_api_version => p_api_version,
       p_init_msg_list => p_init_msg_list,
       p_validation_level => p_validation_level,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data,
       p_check_login_user => p_check_login_user,
       p_resource_id => p_resource_id,
       p_role_id => l_role_id,
       p_include_group_flag => p_include_group_flag,
       p_check_effective_date => FND_API.G_TRUE,
       x_result_flag => x_result_flag
     );
  END IF;
END  Can_PublishContent;
--------------------------------------------------------------------------------
PROCEDURE Can_ApproveContent
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY VARCHAR2
)  AS
l_role_id    number;
BEGIN
  Is_Administrator
  (
    p_api_version,
    p_init_msg_list,
    p_validation_level,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_check_login_user,
    p_resource_id,
    p_include_group_flag,
    x_result_flag
  );
  IF (x_result_flag <> FND_API.G_TRUE) THEN
     l_role_id := Get_RoleId(G_CAN_APPROVE_CODE);
     Check_ResourceRole
     (
       p_api_version => p_api_version,
       p_init_msg_list => p_init_msg_list,
       p_validation_level => p_validation_level,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data,
       p_check_login_user => p_check_login_user,
       p_resource_id => p_resource_id,
       p_role_id => l_role_id,
       p_include_group_flag => p_include_group_flag,
       p_check_effective_date => FND_API.G_TRUE,
       x_result_flag => x_result_flag
     );
  END IF;
END  Can_ApproveContent;
--------------------------------------------------------------------------------
PROCEDURE Can_SetupChannel
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY VARCHAR2
)  AS
l_role_id    number;
BEGIN
  Is_Administrator
  (
    p_api_version,
    p_init_msg_list,
    p_validation_level,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_check_login_user,
    p_resource_id,
    p_include_group_flag,
    x_result_flag
  );
  IF (x_result_flag <> FND_API.G_TRUE) THEN
     l_role_id := Get_RoleId(G_CAN_SETUP_CHANNEL_CODE);
     Check_ResourceRole
     (
       p_api_version => p_api_version,
       p_init_msg_list => p_init_msg_list,
       p_validation_level => p_validation_level,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data,
       p_check_login_user => p_check_login_user,
       p_resource_id => p_resource_id,
       p_role_id => l_role_id,
       p_include_group_flag => p_include_group_flag,
       p_check_effective_date => FND_API.G_TRUE,
       x_result_flag => x_result_flag
     );
  END IF;
END  Can_SetupChannel;
--------------------------------------------------------------------------------
PROCEDURE Can_SetupCategory
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY VARCHAR2
)  AS
l_role_id    number;
BEGIN
  Is_Administrator
  (
    p_api_version,
    p_init_msg_list,
    p_validation_level,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_check_login_user,
    p_resource_id,
    p_include_group_flag,
    x_result_flag
  );
  IF (x_result_flag <> FND_API.G_TRUE) THEN
     l_role_id := Get_RoleId(G_CAN_SETUP_CATEGORY_CODE);
     Check_ResourceRole
     (
       p_api_version => p_api_version,
       p_init_msg_list => p_init_msg_list,
       p_validation_level => p_validation_level,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data,
       p_check_login_user => p_check_login_user,
       p_resource_id => p_resource_id,
       p_role_id => l_role_id,
       p_include_group_flag => p_include_group_flag,
       p_check_effective_date => FND_API.G_TRUE,
       x_result_flag => x_result_flag
     );
  END IF;
END  Can_SetupCategory;
--------------------------------------------------------------------------------
PROCEDURE Can_SetupDistRule
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY VARCHAR2
)  AS
l_role_id    number;
BEGIN
  Is_Administrator
  (
    p_api_version,
    p_init_msg_list,
    p_validation_level,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_check_login_user,
    p_resource_id,
    p_include_group_flag,
    x_result_flag
  );
  IF (x_result_flag <> FND_API.G_TRUE) THEN
     l_role_id := Get_RoleId(G_CAN_SETUP_DIST_CODE);
     Check_ResourceRole
     (
       p_api_version => p_api_version,
       p_init_msg_list => p_init_msg_list,
       p_validation_level => p_validation_level,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data,
       p_check_login_user => p_check_login_user,
       p_resource_id => p_resource_id,
       p_role_id => l_role_id,
       p_include_group_flag => p_include_group_flag,
       p_check_effective_date => FND_API.G_TRUE,
       x_result_flag => x_result_flag
     );
  END IF;
END  Can_SetupDistRule;
--------------------------------------------------------------------------------
---------------------------------- GROUP ROLE  ---------------------------------
--------------------------------------------------------------------------------
PROCEDURE Add_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
) AS
BEGIN
    Add_AssignRoleHelper
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        p_validation_level  => p_validation_level,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_resource_id       => p_group_id,
        p_resource_type     => G_GROUP_ROLE_CODE,
        p_role_id           => p_role_id,
        p_role_code         => p_role_code
    );
END Add_GroupRole;
--------------------------------------------------------------------------------
PROCEDURE Add_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_GroupRole';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_return_status        VARCHAR2(1);
l_admin_flag           VARCHAR2(1);
l_count                NUMBER;
--
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_GroupRole_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the group id is valid
    IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF (p_role_id_varray IS NULL) THEN
        l_count := 0;
    ELSE
       l_count := p_role_id_varray.count;
    END IF;
    FOR i IN 1..l_count LOOP
        Add_GroupRole
        (
            p_api_version         => p_api_version,
            p_commit              => p_commit,
            p_validation_level    => p_validation_level,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_check_login_user    => FND_API.G_FALSE,
            p_group_id            => p_group_id,
            p_role_id             => p_role_id_varray(i)
        );
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
               x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_GroupRole;
--------------------------------------------------------------------------------
PROCEDURE Remove_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
)  AS
l_role_id         number;
BEGIN
    IF (p_role_id = FND_API.G_MISS_NUM) THEN
        l_role_id := Get_RoleId(p_role_code);
    ELSE
        l_role_id := p_role_id;
    END IF;
    Remove_RoleHelper
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        p_validation_level  => p_validation_level,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_resource_id       => p_group_id,
        p_resource_type     => G_GROUP_ROLE_CODE,
        p_role_id           => l_role_id
    );
END Remove_GroupRole;
--------------------------------------------------------------------------------
PROCEDURE Remove_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Remove_GroupRole';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_count                NUMBER;
l_return_status        VARCHAR2(1);
l_role_id_varray       AMV_NUMBER_VARRAY_TYPE;
l_role_code_varray     AMV_CHAR_VARRAY_TYPE;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Remove_GroupRole_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the Group id is valid
    IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (p_role_id_varray IS NULL OR p_role_id_varray.count = 0) THEN
       Get_GroupRoles
       (
           p_api_version          => p_api_version,
           x_return_status        => l_return_status,
           x_msg_count            => x_msg_count,
           x_msg_data             => x_msg_data,
           p_check_login_user     => FND_API.G_FALSE,
           p_group_id             => p_group_id,
           p_check_effective_date => FND_API.G_FALSE,
           x_role_id_varray       => l_role_id_varray,
           x_role_code_varray     => l_role_code_varray
       );
       IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_count := l_role_id_varray.count;
       ELSE
          l_count := 0;
          x_return_status := l_return_status;
       END IF;
    ELSE
       l_count := p_role_id_varray.count;
       l_role_id_varray := p_role_id_varray;
    END IF;
    FOR i IN 1..l_count LOOP
        Remove_GroupRole
        (
           p_api_version        => p_api_version,
           p_commit             => p_commit,
           p_validation_level   => p_validation_level,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_check_login_user   => FND_API.G_FALSE,
           p_group_id           => p_group_id,
           p_role_id            => l_role_id_varray(i),
           p_role_code          => null
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Remove_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Remove_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Remove_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Remove_GroupRole;
--------------------------------------------------------------------------------
PROCEDURE Replace_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_code           IN  VARCHAR2
) AS
l_role_id_array          AMV_NUMBER_VARRAY_TYPE;
BEGIN
   Get_RoleIDArray (p_role_code, l_role_id_array);
   Replace_GroupRole
   (
    p_api_version       => p_api_version,
    p_init_msg_list     => p_init_msg_list,
    p_commit            => p_commit,
    p_validation_level  => p_validation_level,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_check_login_user  => p_check_login_user,
    p_group_id          => p_group_id,
    p_role_id_varray    => l_role_id_array
    );
END Replace_GroupRole;
--------------------------------------------------------------------------------
PROCEDURE Replace_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Replace_GroupRole';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_count                NUMBER;
l_temp                 NUMBER;
l_return_status        VARCHAR2(1);
l_date                 DATE;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Replace_GroupRole_Pvt;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --Remove the existing roles
    --Remove the existing roles
    Remove_GroupRole
    (
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_validation_level => p_validation_level,
        x_return_status    => l_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_check_login_user => p_check_login_user,
        p_group_id         => p_group_id,
        p_role_id_varray   => null
    );
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    Add_GroupRole
    (
        p_api_version      => p_api_version,
        p_commit           => p_commit,
        p_validation_level => p_validation_level,
        x_return_status    => l_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_check_login_user => FND_API.G_FALSE,
        p_group_id         => p_group_id,
        p_role_id_varray   => p_role_id_varray
    );
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Replace_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Replace_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Replace_GroupRole_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Replace_GroupRole;
--------------------------------------------------------------------------------
PROCEDURE Get_GroupRoles
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id             IN  NUMBER,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    x_role_id_varray       OUT NOCOPY AMV_NUMBER_VARRAY_TYPE,
    x_role_code_varray     OUT NOCOPY AMV_CHAR_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_GroupRoles';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_count                NUMBER := 0;
--
CURSOR Get_GroupRole_csr IS
Select
     rol.role_code,
     rol.role_id
From  jtf_rs_role_relations_vl rel, jtf_rs_roles_vl rol
Where rol.role_id = rel.role_id
And   rel.role_resource_id = p_group_id
And   rel.role_resource_type = G_GROUP_ROLE_CODE
And   rol.role_type_code = G_MES_ROLE_TYPE_NAME
Order by rol.role_code;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_role_id_varray   := AMV_NUMBER_VARRAY_TYPE();
    x_role_code_varray := AMV_CHAR_VARRAY_TYPE();
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the group id is valid
    IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    FOR csr1 IN  Get_GroupRole_csr LOOP
       l_count := l_count + 1;
       x_role_id_varray.extend;
       x_role_code_varray.extend;
       x_role_id_varray(l_count) := csr1.role_id;
       x_role_code_varray(l_count) := csr1.role_code;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_GroupRoles;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Check_GroupRole
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id             IN  NUMBER,
    p_role_id              IN  NUMBER,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag          OUT NOCOPY VARCHAR2
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Check_GroupRole';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_temp                 NUMBER;
--
CURSOR Get_GroupRole_csr IS
Select
     role_relate_id
From  jtf_rs_role_relations_vl
Where role_id = p_role_id
And   role_resource_id = p_group_id
And   role_resource_type = G_GROUP_ROLE_CODE
;
--
CURSOR Get_GroupRole2_csr IS
Select
     r.role_relate_id
From  jtf_rs_role_relations_vl r, jtf_rs_groups_vl g
Where r.role_id = p_role_id
And   r.role_resource_id = p_group_id
And   r.role_resource_type = G_GROUP_ROLE_CODE
And   r.start_date_active < sysdate
And   nvl(r.end_date_active, sysdate-1) < sysdate
And   g.group_id = p_group_id
And   g.start_date_active < sysdate
And   nvl(g.end_date_active, sysdate-1) < sysdate;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_result_flag := FND_API.G_FALSE;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Check if the resource id is valid
    IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (p_check_effective_date = FND_API.G_TRUE) THEN
        OPEN  Get_GroupRole2_csr;
        FETCH Get_GroupRole2_csr INTO l_temp;
        IF (Get_GroupRole2_csr%FOUND) THEN
           x_result_flag := FND_API.G_TRUE;
        ELSE
           x_result_flag := FND_API.G_FALSE;
        END IF;
        CLOSE Get_GroupRole2_csr;
    ELSE
        OPEN  Get_GroupRole_csr;
        FETCH Get_GroupRole_csr INTO l_temp;
        IF (Get_GroupRole_csr%FOUND) THEN
           x_result_flag := FND_API.G_TRUE;
        ELSE
           x_result_flag := FND_API.G_FALSE;
        END IF;
        CLOSE Get_GroupRole_csr;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Check_GroupRole;
--------------------------------------------------------------------------------
---------------------------------------- GROUP ---------------------------------
--------------------------------------------------------------------------------
PROCEDURE Add_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_name          IN  VARCHAR2,
    p_group_desc          IN  VARCHAR2 := NULL,
    p_group_usage         IN  VARCHAR2,
    p_email_address       IN  VARCHAR2 := NULL,
    p_start_date          IN  DATE     := NULL,
    p_end_date            IN  DATE     := NULL,
    x_group_id            OUT NOCOPY NUMBER
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_Group';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_group_id             NUMBER;
l_usage_id             NUMBER;
l_group_number         NUMBER;
l_channel_id           NUMBER;
l_channel_record       AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE;
l_start_date           DATE;
l_end_date             DATE;
l_group_desc           VARCHAR2(2000);
l_email_address        VARCHAR2(2000);
--
CURSOR Check_Group_csr IS
Select g.group_id
From  jtf_rs_groups_vl g, jtf_rs_group_usages usg
Where g.group_name = p_group_name
And   g.start_date_active < sysdate
And   nvl(g.end_date_active, sysdate+1) > sysdate
And   usg.group_id = g.group_id
And   usg.usage = p_group_usage
;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_Group_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );

    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the group name is unique
    OPEN  Check_Group_csr;
    FETCH Check_Group_csr INTO l_group_id;
    IF (Check_Group_csr%FOUND) THEN
       CLOSE Check_Group_csr;
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_DUPLICATE_GROUP_NAME');
           FND_MESSAGE.Set_Token('NAME', p_group_name );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    ELSE
       CLOSE Check_Group_csr;
    END IF;
    IF (p_start_date is null OR p_start_date = FND_API.G_MISS_DATE) THEN
       l_start_date := sysdate;
    ELSE
       l_start_date := p_start_date;
    END IF;
    IF (p_end_date is null OR p_end_date = FND_API.G_MISS_DATE) THEN
       l_end_date := null;
    ELSE
       l_end_date := p_end_date;
    END IF;
    IF (p_group_desc is null OR p_group_desc = FND_API.G_MISS_CHAR) THEN
       l_group_desc := null;
    ELSE
       l_group_desc := p_group_desc;
    END IF;
    IF (p_email_address is null OR p_email_address = FND_API.G_MISS_CHAR) THEN
       l_email_address := null;
    ELSE
       l_email_address := p_email_address;
    END IF;
    jtf_rs_groups_pub.create_resource_group
    (
       p_api_version        => 1.0,
       p_commit             => FND_API.G_FALSE,
       p_group_name         => p_group_name,
       p_group_desc         => l_group_desc,
       p_email_address      => l_email_address,
       p_start_date_active  => l_start_date,
       p_end_date_active    => l_end_date,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data,
       x_group_id           => x_group_id,
       x_group_number       => l_group_number
    );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- Add group usage.
   jtf_rs_group_usages_pub.create_group_usage
   (
      p_api_version        => 1.0,
      p_group_id           => x_group_id,
      p_group_number       => l_group_number,
      p_usage              => p_group_usage,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_group_usage_id     => l_usage_id
   );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- create group channel

    l_channel_record.channel_id := FND_API.G_MISS_NUM;
    l_channel_record.object_version_number := FND_API.G_MISS_NUM;
    l_channel_record.channel_name := FND_API.G_MISS_CHAR;
    l_channel_record.description := FND_API.G_MISS_CHAR;
    l_channel_record.channel_type := 'GROUP';
    l_channel_record.channel_category_id := FND_API.G_MISS_NUM;
    l_channel_record.status := 'ACTIVE';
    l_channel_record.owner_user_id := l_current_resource_id;
    l_channel_record.default_approver_user_id := l_current_resource_id;
    l_channel_record.effective_start_date := l_start_date;
    l_channel_record.expiration_date := l_end_date;
    l_channel_record.access_level_type := 'PRIVATE';
    l_channel_record.pub_need_approval_flag := FND_API.G_MISS_CHAR;
    l_channel_record.sub_need_approval_flag := FND_API.G_MISS_CHAR;
    l_channel_record.match_on_all_criteria_flag := FND_API.G_MISS_CHAR;
    l_channel_record.match_on_keyword_flag := FND_API.G_MISS_CHAR;
    l_channel_record.match_on_author_flag := FND_API.G_MISS_CHAR;
    l_channel_record.match_on_perspective_flag := FND_API.G_MISS_CHAR;
    l_channel_record.match_on_item_type_flag := FND_API.G_MISS_CHAR;
    l_channel_record.match_on_content_type_flag := FND_API.G_MISS_CHAR;
    l_channel_record.match_on_time_flag := FND_API.G_MISS_CHAR;
    l_channel_record.application_id := 520;
    l_channel_record.external_access_flag := FND_API.G_MISS_CHAR;
    l_channel_record.item_match_count := FND_API.G_MISS_NUM;
    l_channel_record.last_match_time := FND_API.G_MISS_DATE;
    l_channel_record.notification_interval_type := FND_API.G_MISS_CHAR;
    l_channel_record.last_notification_time := FND_API.G_MISS_DATE;
    l_channel_record.attribute_category := FND_API.G_MISS_CHAR;
    l_channel_record.attribute1 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute2 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute3 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute4 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute5 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute6 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute7 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute8 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute9 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute10 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute11 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute12 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute13 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute14 := FND_API.G_MISS_CHAR;
    l_channel_record.attribute15 := FND_API.G_MISS_CHAR;

/*
   l_channel_record := AMV_CHANNEL_OBJ_TYPE
      (
         FND_API.G_MISS_NUM, --CHANNEL_ID
         FND_API.G_MISS_NUM, --OBJECT_VERSION_NUMBER
         FND_API.G_MISS_CHAR, --CHANNEL_NAME
         FND_API.G_MISS_CHAR, --DESCRIPTION
         'GROUP', --CHANNEL_TYPE
         FND_API.G_MISS_NUM, --CHANNEL_CATEGORY_ID
         'ACTIVE', --STATUS
         l_current_resource_id, --OWNER_USER_ID
         l_current_resource_id, --DEFAULT_APPROVER_USER_ID
         l_start_date, --EFFECTIVE_START_DATE
         l_end_date,   --EXPIRATION_DATE
         'PRIVATE', --ACCESS_LEVEL_TYPE
         FND_API.G_MISS_CHAR, --PUB_NEED_APPROVAL_FLAG
         FND_API.G_MISS_CHAR, --SUB_NEED_APPROVAL_FLAG
         FND_API.G_MISS_CHAR, --MATCH_ON_ALL_CRITERIA_FLAG
         FND_API.G_MISS_CHAR, --MATCH_ON_KEYWORD_FLAG
         FND_API.G_MISS_CHAR, --MATCH_ON_AUTHOR_FLAG
         FND_API.G_MISS_CHAR, --MATCH_ON_PERSPECTIVE_FLAG
         FND_API.G_MISS_CHAR, --MATCH_ON_ITEM_TYPE_FLAG
         FND_API.G_MISS_CHAR, --MATCH_ON_CONTENT_TYPE_FLAG
         FND_API.G_MISS_CHAR, --MATCH_ON_TIME_FLAG
         520,
         FND_API.G_MISS_CHAR, --EXTERNAL_ACCESS_FLAG
         FND_API.G_MISS_NUM, --ITEM_MATCH_COUNT
         FND_API.G_MISS_DATE, --LAST_MATCH_TIME
         FND_API.G_MISS_CHAR, --NOTIFICATION_INTERVAL_TYPE
         FND_API.G_MISS_DATE, --LAST_NOTIFICATION_TIME
         FND_API.G_MISS_CHAR, --ATTRIBUTE_CATEGORY
         FND_API.G_MISS_CHAR, --ATTRIBUTE1
         FND_API.G_MISS_CHAR, --ATTRIBUTE2
         FND_API.G_MISS_CHAR, --ATTRIBUTE3
         FND_API.G_MISS_CHAR, --ATTRIBUTE4
         FND_API.G_MISS_CHAR, --ATTRIBUTE5
         FND_API.G_MISS_CHAR, --ATTRIBUTE6
         FND_API.G_MISS_CHAR, --ATTRIBUTE7
         FND_API.G_MISS_CHAR, --ATTRIBUTE8
         FND_API.G_MISS_CHAR, --ATTRIBUTE9
         FND_API.G_MISS_CHAR, --ATTRIBUTE10
         FND_API.G_MISS_CHAR, --ATTRIBUTE11
         FND_API.G_MISS_CHAR, --ATTRIBUTE12
         FND_API.G_MISS_CHAR, --ATTRIBUTE13
         FND_API.G_MISS_CHAR, --ATTRIBUTE14
         FND_API.G_MISS_CHAR  --ATTRIBUTE15
      );
*/
    amv_channel_pvt.Add_GroupChannel
    (
       p_api_version        => p_api_version,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data,
       p_check_login_user   => p_check_login_user,
       p_group_id           => x_group_id,
       p_channel_record     => l_channel_record,
       x_channel_id         => l_channel_id
    );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_Group;
--------------------------------------------------------------------------------
PROCEDURE Update_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_new_group_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_new_group_desc      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_usage         IN  VARCHAR2 := G_MES_GROUP_USAGE,
    p_email_address       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_new_start_date      IN  DATE     := FND_API.G_MISS_DATE,
    p_new_end_date        IN  DATE     := FND_API.G_MISS_DATE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Update_Group';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_group_id             NUMBER;
l_group_number         VARCHAR2(30) := null; -- dummy
l_object_version_num   NUMBER;
l_channel_id           NUMBER;
--
CURSOR Get_Version_csr IS
Select object_version_number
From  jtf_rs_groups_vl
Where group_id = p_group_id
;
CURSOR Check_Group_csr(p_name IN VARCHAR2) IS
Select g.group_id
From  jtf_rs_groups_vl g, jtf_rs_group_usages usg
Where g.group_name = p_name
And   usg.group_id = g.group_id
And   usg.usage = p_group_usage
;
CURSOR Get_GroupChannelId(p_g_id IN NUMBER) IS
Select subscribing_to_id channel_id
From amv_u_my_channels
Where user_or_group_id = p_g_id
And user_or_group_type = G_GROUP_ARC_TYPE
And subscribing_to_type = G_CHAN_ARC_TYPE
And subscription_reason_type = 'ENFORCED'
;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Update_Group_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the group id is valid
    IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- Check if the group name is unique
    IF (p_new_group_name <> FND_API.G_MISS_CHAR) THEN
        OPEN  Check_Group_csr(p_new_group_name);
        FETCH Check_Group_csr INTO l_group_id;
        IF (Check_Group_csr%FOUND) THEN
           CLOSE Check_Group_csr;
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_DUPLICATE_GROUP_NAME');
               FND_MESSAGE.Set_Token('NAME', p_new_group_name );
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        ELSE
           CLOSE Check_Group_csr;
        END IF;
    END IF;
    OPEN  Get_Version_csr;
    FETCH Get_Version_csr INTO l_object_version_num;
    CLOSE Get_Version_csr;
    jtf_rs_groups_pub.update_resource_group
    (
       p_api_version        => p_api_version,
       p_group_id           => p_group_id,
       p_group_number       => null,
       p_group_name         => p_new_group_name,
       p_group_desc         => p_new_group_desc,
       p_email_address      => p_email_address,
       p_start_date_active  => p_new_start_date,
       p_end_date_active    => p_new_end_date,
       p_object_version_num => l_object_version_num,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data
    );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (p_new_start_date  <> FND_API.G_MISS_DATE OR
        p_new_end_date    <> FND_API.G_MISS_DATE OR
        p_new_group_name  <> FND_API.G_MISS_CHAR) THEN
        OPEN  Get_GroupChannelId(p_group_id);
        FETCH Get_GroupChannelId Into l_channel_id;
        IF (Get_GroupChannelId%FOUND) THEN
            CLOSE Get_GroupChannelId;
            IF (p_new_start_date  <> FND_API.G_MISS_DATE OR
                p_new_end_date    <> FND_API.G_MISS_DATE) THEN
               update amv_c_channels_b set
                   EFFECTIVE_START_DATE = DECODE(p_new_start_date,
                                                 FND_API.G_MISS_DATE,
                                                 EFFECTIVE_START_DATE,
                                                 p_new_start_date),
                   EXPIRATION_DATE = DECODE(p_new_start_date,
                                            FND_API.G_MISS_DATE,
                                            EXPIRATION_DATE,
                                            p_new_start_date),
                   LAST_UPDATE_DATE = sysdate,
                   LAST_UPDATED_BY = l_current_user_id,
                   LAST_UPDATE_LOGIN = l_current_login_id,
                   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
               where CHANNEL_ID = l_channel_id;
            END IF;
            IF (p_new_group_name  <> FND_API.G_MISS_CHAR) THEN
               update amv_c_channels_tl set
                   CHANNEL_NAME = p_new_group_name,
                   LAST_UPDATE_DATE = sysdate,
                   LAST_UPDATED_BY = l_current_user_id,
                   LAST_UPDATE_LOGIN = l_current_login_id,
                   SOURCE_LANG = userenv('LANG')
               where CHANNEL_ID = l_channel_id
               and  userenv('LANG') in (LANGUAGE, SOURCE_LANG);
            END IF;
        ELSE
            CLOSE Get_GroupChannelId;
        END IF;
    END IF;
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Update_Group;
--------------------------------------------------------------------------------
PROCEDURE Delete_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER   := FND_API.G_MISS_NUM,
    p_group_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_Group';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_group_id             NUMBER;
l_channel_id		   NUMBER;
--
CURSOR Get_GroupID_csr(p_name IN VARCHAR2) IS
Select group_id
From jtf_rs_groups_vl
Where group_name = p_name
;
CURSOR Get_ChannelID_csr(p_grp_id IN NUMBER) IS
 SELECT CHANNEL_ID
 FROM AMV_C_CHANNELS_TL
 WHERE LANGUAGE = userenv('LANG') and
	  CHANNEL_NAME = (select group_name from
 jtf_rs_groups_tl where group_id = p_grp_id and language = userenv('LANG'));

--
BEGIN
    SAVEPOINT Delete_Group_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check if the group id is valid
    IF (p_group_id IS NOT NULL AND p_group_id <> FND_API.G_MISS_NUM) THEN
        IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
               FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        ELSE
           l_group_id := p_group_id;
        END IF;
    ELSIF (p_group_name IS NOT NULL AND
           p_group_name <> FND_API.G_MISS_CHAR) THEN
        -- Check if the group name is valid
        OPEN  Get_GroupID_csr(p_group_name);
        FETCH Get_GroupID_csr INTO l_group_id;
        IF (Get_GroupID_csr%NOTFOUND) THEN
           CLOSE Get_GroupID_csr;
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_NAME');
               FND_MESSAGE.Set_Token('NAME', p_group_name );
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        ELSE
           CLOSE Get_GroupID_csr;
        END IF;
    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NO_GROUP_NAME_OR_ID');
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --Now do the job.
    Delete from amv_u_access
    Where user_or_group_id = l_group_id
    And   User_OR_group_type = G_GROUP_ARC_TYPE;
    --
    Delete from amv_u_my_channels
    Where user_or_group_id = l_group_id
    And   User_OR_group_type = G_GROUP_ARC_TYPE;

         -- Remove channel from channels
     OPEN  Get_ChannelID_csr(l_group_id);

	FETCH Get_ChannelID_csr INTO l_channel_id;
	   IF (Get_ChannelID_csr%NOTFOUND) THEN
		 raise no_data_found;
	      CLOSE Get_ChannelID_csr;
	   ELSE
           AMV_C_CHANNELS_PKG.DELETE_ROW(l_channel_id);
           CLOSE Get_ChannelID_csr;
	   END IF;

    Update_Group
      (
         p_api_version         => p_api_version,
         p_init_msg_list       => p_init_msg_list,
         p_commit              => p_commit,
         p_validation_level    => p_validation_level,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data,
         p_check_login_user    => p_check_login_user,
         p_group_id            => l_group_id,
         p_new_group_name      => FND_API.G_MISS_CHAR,
         p_new_group_desc      => FND_API.G_MISS_CHAR,
         p_email_address       => FND_API.G_MISS_CHAR,
         p_new_start_date      => sysdate -2,
         p_new_end_date        => sysdate -1
      );
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_Group_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Delete_Group;
--------------------------------------------------------------------------------
PROCEDURE Get_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    x_group_obj           OUT NOCOPY AMV_GROUP_OBJ_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_GROUP';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
CURSOR Get_GroupObj_csr IS
Select
    group_id,
    group_name,
    object_version_number,
    email_address,
    group_desc,
    start_date_active,
    end_date_active
From  jtf_rs_groups_vl
Where group_id = p_group_id
;
--
l_group_info   Get_GroupObj_csr%ROWTYPE;
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    --
    OPEN  Get_GroupObj_csr;
    FETCH Get_GroupObj_csr INTO l_group_info;
    IF (Get_GroupObj_csr%FOUND) THEN
        CLOSE Get_GroupObj_csr;

        x_group_obj.group_id := l_group_info.group_id;
        x_group_obj.group_name := l_group_info.group_name;
        x_group_obj.object_version_number := l_group_info.object_version_number;
        x_group_obj.email_address := l_group_info.email_address;
        x_group_obj.description := l_group_info.group_desc;
        x_group_obj.effective_start_date := l_group_info.start_date_active;
        x_group_obj.expiration_date := l_group_info.end_date_active;

/*
        x_group_obj :=  AMV_GROUP_OBJ_TYPE
                        (
                           l_group_info.group_id,
                           l_group_info.group_name,
                           l_group_info.object_version_number,
                           l_group_info.email_address,
                           l_group_info.group_desc,
                           l_group_info.start_date_active,
                           l_group_info.end_date_active
                        );
*/
    ELSE
        CLOSE Get_GroupObj_csr;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_Group;
--------------------------------------------------------------------------------
PROCEDURE Find_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_group_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_desc          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_email         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_usage         IN  VARCHAR2,
    p_subset_request_obj  IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj   OUT NOCOPY AMV_RETURN_OBJ_TYPE,
    x_group_obj_array     OUT NOCOPY AMV_GROUP_OBJ_VARRAY
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Find_Group';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_cursor             CursorType;
l_sql_statement      VARCHAR2(2000);
l_sql_statement2     VARCHAR2(2000);
l_where_clause       VARCHAR2(2000);
l_total_count        NUMBER := 1;
l_fetch_count        NUMBER := 0;
l_start_with         NUMBER;
l_total_record_count NUMBER;
--
l_group_id           NUMBER;
l_group_name         VARCHAR2(80);
l_group_version      NUMBER;
l_group_email_addr   VARCHAR2(240);
l_group_desc         VARCHAR2(2000);
l_start_date         DATE;
l_end_date           DATE;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    --
    -- Now create SQL statement and find the results:
    IF (p_resource_id IS NULL OR p_resource_id = FND_API.G_MISS_NUM) THEN
        l_sql_statement :=
           'Select ' ||
               'g.group_id, ' ||
               'g.group_name, ' ||
               'g.object_version_number, ' ||
               'g.email_address, ' ||
               'g.group_desc, ' ||
               'g.start_date_active, ' ||
               'g.end_date_active ' ||
               'From  jtf_rs_groups_vl g, jtf_rs_group_usages usg ';
        l_sql_statement2 :=
           'Select count(*) ' ||
               'From  jtf_rs_groups_vl g, jtf_rs_group_usages usg ';
        l_where_clause := 'Where g.start_date_active < sysdate  ' ||
                          'And nvl(g.end_date_active, sysdate+1) > sysdate ' ||
                          'And usg.group_id = g.group_id ' ||
                          'And usg.usage =  ''' || p_group_usage || ''' ';
    ELSE
        l_sql_statement :=
           'Select ' ||
               'g.group_id, ' ||
               'g.group_name, ' ||
               'g.object_version_number, ' ||
               'g.email_address, ' ||
               'g.group_desc, ' ||
               'g.start_date_active, ' ||
               'g.end_date_active ' ||
               'From  jtf_rs_groups_vl g, jtf_rs_group_members m, ' ||
               '      jtf_rs_group_usages usg ';
        l_sql_statement2 :=
           'Select count(*) ' ||
               'From  jtf_rs_groups_vl g, jtf_rs_group_members m, ' ||
               '      jtf_rs_group_usages usg ';
        l_where_clause := 'Where g.group_id = m.group_id ' ||
                          'And m.delete_flag <> ''Y'' ' ||
                          'And m.resource_id = ' || p_resource_id || ' ' ||
                          'And g.start_date_active < sysdate  ' ||
                          'And nvl(g.end_date_active, sysdate+1) > sysdate ' ||
                          'And usg.group_id = g.group_id ' ||
                          'And usg.usage = ''' || p_group_usage || ''' ';
    END IF;
    IF (p_group_name IS NOT NULL AND
        p_group_name <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And g.group_name like ''' || p_group_name || ''' ';
    END IF;
    IF (p_group_desc IS NOT NULL AND
        p_group_desc <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And g.group_desc Like ''' || p_group_desc || ''' ';
    END IF;
    IF (p_group_email IS NOT NULL AND
        p_group_email <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And g.email_address Like ''' || p_group_email || ''' ';
    END IF;
    l_sql_statement := l_sql_statement ||
         l_where_clause || 'ORDER BY g.group_name ';
    l_sql_statement2 := l_sql_statement2 ||
         l_where_clause;
    IF (G_DEBUG = TRUE) THEN
         AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(l_sql_statement);
    END IF;
    --Execute the SQL statements to get the total count:
    IF (p_subset_request_obj.return_total_count_flag = FND_API.G_TRUE) THEN
        OPEN  l_cursor FOR l_sql_statement2;
        FETCH l_cursor INTO l_total_record_count;
        CLOSE l_cursor;
    END IF;
    --Execute the SQL statements to get records
    l_start_with := p_subset_request_obj.start_record_position;
    x_group_obj_array := AMV_GROUP_OBJ_VARRAY();
    OPEN l_cursor FOR l_sql_statement;
    LOOP
       FETCH l_cursor INTO
           l_group_id,
           l_group_name,
           l_group_version,
           l_group_email_addr,
           l_group_desc,
           l_start_date,
           l_end_date;
       EXIT WHEN l_cursor%NOTFOUND;
       IF (l_start_with <= l_total_count AND
           l_fetch_count < p_subset_request_obj.records_requested) THEN
          l_fetch_count := l_fetch_count + 1;
          x_group_obj_array.extend;
          x_group_obj_array(l_fetch_count).group_id := l_group_id;
          x_group_obj_array(l_fetch_count).group_name := l_group_name;
          x_group_obj_array(l_fetch_count).object_version_number := l_group_version;
          x_group_obj_array(l_fetch_count).email_address := l_group_email_addr;
          x_group_obj_array(l_fetch_count).description := l_group_desc;
          x_group_obj_array(l_fetch_count).effective_start_date := l_start_date;
          x_group_obj_array(l_fetch_count).expiration_date := l_end_date;

/*
          x_group_obj_array(l_fetch_count) :=
            AMV_GROUP_OBJ_TYPE
            (
               l_group_id,
               l_group_name,
               l_group_version,
               l_group_email_addr,
               l_group_desc,
               l_start_date,
               l_end_date
            );
*/
       END IF;
       IF (l_fetch_count >= p_subset_request_obj.records_requested) THEN
          exit;
       END IF;
       l_total_count := l_total_count + 1;
    END LOOP;
    CLOSE l_cursor;

    x_subset_return_obj.returned_record_count := l_fetch_count;
    x_subset_return_obj.next_record_position := p_subset_request_obj.start_record_position + l_fetch_count;
    x_subset_return_obj.total_record_count := l_total_record_count;

/*
    x_subset_return_obj := AMV_RETURN_OBJ_TYPE
      (
         l_fetch_count,
         p_subset_request_obj.start_record_position + l_fetch_count,
         l_total_record_count
      );
*/
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Find_Group;
--------------------------------------------------------------------------------
PROCEDURE Find_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER   := FND_API.G_MISS_NUM,
    p_group_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_usage         IN VARCHAR2,
    p_subset_request_obj  IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj   OUT NOCOPY AMV_RETURN_OBJ_TYPE,
    x_group_obj_array     OUT NOCOPY AMV_GROUP_OBJ_VARRAY,
    x_role_code_varray    OUT NOCOPY AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Find_Group';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_cursor             CursorType;
l_sql_statement      VARCHAR2(2000);
l_sql_statement2     VARCHAR2(2000);
l_where_clause       VARCHAR2(2000);
l_total_count        NUMBER := 1;
l_fetch_count        NUMBER := 0;
l_start_with         NUMBER;
l_total_record_count NUMBER;
--
l_group_id           NUMBER;
l_group_name         VARCHAR2(80);
l_group_version      NUMBER;
l_group_email_addr   VARCHAR2(240);
l_group_desc         VARCHAR2(2000);
l_start_date         DATE;
l_end_date           DATE;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    --
    -- Now create SQL statement and find the results:
    l_sql_statement :=
       'Select ' ||
           'g.group_id, ' ||
           'g.group_name, ' ||
           'g.object_version_number, ' ||
           'g.email_address, ' ||
           'g.group_desc, ' ||
           'g.start_date_active, ' ||
           'g.end_date_active ' ||
           'From  jtf_rs_groups_vl g, jtf_rs_group_usages usg ';
    l_sql_statement2 :=
       'Select count(*) ' ||
           'From  jtf_rs_groups_vl g, jtf_rs_group_usages usg ';
    l_where_clause := 'Where g.start_date_active < sysdate  ' ||
                      'And nvl(g.end_date_active, sysdate+1) > sysdate ' ||
                      'And usg.group_id = g.group_id ' ||
				  'And usg.usage = ''' || p_group_usage || ''' ';
    IF (p_group_id = FND_API.G_MISS_NUM) THEN
        l_where_clause := l_where_clause ||
             'And g.group_name like ''' || p_group_name || ''' ';
    ELSE
        l_where_clause := l_where_clause ||
             'And g.group_id = ' || p_group_id || ' ';
    END IF;
    l_sql_statement := l_sql_statement ||
         l_where_clause || 'ORDER BY g.group_name ';
    l_sql_statement2 := l_sql_statement2 ||
         l_where_clause;
    IF (G_DEBUG = TRUE) THEN
         AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(l_sql_statement);
    END IF;
    --Execute the SQL statements to get the total count:
    IF (p_subset_request_obj.return_total_count_flag = FND_API.G_TRUE) THEN
        OPEN  l_cursor FOR l_sql_statement2;
        FETCH l_cursor INTO l_total_record_count;
        CLOSE l_cursor;
    END IF;
    --Execute the SQL statements to get records
    l_start_with := p_subset_request_obj.start_record_position;
    x_group_obj_array := AMV_GROUP_OBJ_VARRAY();
    x_role_code_varray := AMV_CHAR_VARRAY_TYPE();
    OPEN l_cursor FOR l_sql_statement;
    LOOP
       FETCH l_cursor INTO
           l_group_id,
           l_group_name,
           l_group_version,
           l_group_email_addr,
           l_group_desc,
           l_start_date,
           l_end_date;
       EXIT WHEN l_cursor%NOTFOUND;
       IF (l_start_with <= l_total_count AND
           l_fetch_count < p_subset_request_obj.records_requested) THEN
          l_fetch_count := l_fetch_count + 1;
          x_group_obj_array.extend;
          x_group_obj_array(l_fetch_count).group_id := l_group_id;
          x_group_obj_array(l_fetch_count).group_name := l_group_name;
          x_group_obj_array(l_fetch_count).object_version_number := l_group_version;
          x_group_obj_array(l_fetch_count).email_address := l_group_email_addr;
          x_group_obj_array(l_fetch_count).description := l_group_desc;
          x_group_obj_array(l_fetch_count).effective_start_date := l_start_date;
          x_group_obj_array(l_fetch_count).expiration_date := l_end_date;

/*
          x_group_obj_array(l_fetch_count) :=
            AMV_GROUP_OBJ_TYPE
            (
               l_group_id,
               l_group_name,
               l_group_version,
               l_group_email_addr,
               l_group_desc,
               l_start_date,
               l_end_date
            );
*/

          --Get group roles:
          x_role_code_varray.extend;
          x_role_code_varray(l_fetch_count) :=
              Get_Role(l_group_id, G_GROUP_ROLE_CODE);
       END IF;
       IF (l_fetch_count >= p_subset_request_obj.records_requested) THEN
          exit;
       END IF;
       l_total_count := l_total_count + 1;
    END LOOP;
    CLOSE l_cursor;
    x_subset_return_obj.returned_record_count := l_fetch_count;
    x_subset_return_obj.next_record_position := p_subset_request_obj.start_record_position + l_fetch_count;
    x_subset_return_obj.total_record_count := l_total_record_count;

/*
    x_subset_return_obj := AMV_RETURN_OBJ_TYPE
      (
         l_fetch_count,
         p_subset_request_obj.start_record_position + l_fetch_count,
         l_total_record_count
      );
*/
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Find_Group;
--------------------------------------------------------------------------------
--------------------------- GROUP MEMBERSHIP  ----------------------------------
--------------------------------------------------------------------------------
PROCEDURE Add_GroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_resource_id         IN  NUMBER
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_GroupMember';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_temp                 NUMBER;
--
CURSOR  Check_GroupMember_csr IS
Select group_member_id
From jtf_rs_group_members
Where resource_id = p_resource_id
And   group_id = p_group_id
And   delete_flag <> 'Y';
--
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_GroupMember_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the group id is valid
    IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
     -- Check if the resource id is valid
    IF (AMV_UTILITY_PVT.IS_RESOURCEIDVALID(p_resource_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_RESOURCE_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_resource_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --
    OPEN  Check_GroupMember_csr;
    FETCH  Check_GroupMember_csr INTO l_temp;
    IF (Check_GroupMember_csr%NOTFOUND) THEN
       CLOSE Check_GroupMember_csr;
       jtf_rs_group_members_pub.create_resource_group_members
       (
          p_api_version        => 1.0,
          p_commit             => p_commit,
          p_group_id           => p_group_id,
          p_group_number       => null,
          p_resource_id        => p_resource_id,
          p_resource_number    => null,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          x_group_member_id    => l_temp
       );
    ELSE
        CLOSE Check_groupMember_csr;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_groupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_groupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_groupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_groupMember;
--------------------------------------------------------------------------------
PROCEDURE Add_GroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_resource_id_varray  IN  AMV_NUMBER_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_GroupMember';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(2000);
l_temp                 NUMBER;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_GroupMember_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the group id is valid
    IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    FOR i IN 1..p_resource_id_varray.count LOOP
        Add_GroupMember
          (
              p_api_version         => p_api_version,
              p_commit              => p_commit,
              p_validation_level    => p_validation_level,
              x_return_status       => l_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_check_login_user    => FND_API.G_FALSE,
              p_group_id            => p_group_id,
              p_resource_id         => p_resource_id_varray(i)
          );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_groupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_groupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_groupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_groupMember;
--------------------------------------------------------------------------------
PROCEDURE Remove_GroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_resource_id         IN  NUMBER
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Remove_GroupMember';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_version              NUMBER;
--
CURSOR  Check_GroupMember_csr IS
Select object_version_number
From jtf_rs_group_members
Where resource_id = p_resource_id
And   group_id = p_group_id
And   delete_flag <> 'Y';
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Remove_GroupMember_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    OPEN  Check_GroupMember_csr;
    FETCH  Check_GroupMember_csr INTO l_version;
    IF (Check_GroupMember_csr%FOUND) THEN
       CLOSE Check_GroupMember_csr;
       jtf_rs_group_members_pub.delete_resource_group_members
       (
          p_api_version        => 1.0,
          p_commit             => p_commit,
          p_group_id           => p_group_id,
          p_group_number       => null,
          p_resource_id        => p_resource_id,
          p_resource_number    => null,
          p_object_version_num => l_version,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
       );
    ELSE
        CLOSE Check_groupMember_csr;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Remove_GroupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Remove_GroupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Remove_GroupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Remove_GroupMember;
--------------------------------------------------------------------------------
PROCEDURE Remove_GroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_resource_id_varray  IN  AMV_NUMBER_VARRAY_TYPE
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Remove_GroupMember';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_temp                 NUMBER;
l_count                NUMBER;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Remove_GroupMember_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Check if the group id is valid
    IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(p_group_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
           FND_MESSAGE.Set_Token('ID', TO_CHAR( NVL(p_group_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (p_resource_id_varray IS NULL) THEN
        l_count := 0;
    ELSE
        l_count := p_resource_id_varray.count;
    END IF;
    FOR i IN 1..l_count LOOP
        Remove_GroupMember
        (
            p_api_version         => p_api_version,
            p_commit              => p_commit,
            p_validation_level    => p_validation_level,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_check_login_user    => FND_API.G_FALSE,
            p_resource_id         => p_resource_id_varray(i),
            p_group_id            => p_group_id
        );
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
               x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Remove_GroupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Remove_GroupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Remove_GroupMember_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Remove_GroupMember;
--------------------------------------------------------------------------------
PROCEDURE Check_GroupMember
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id             IN  NUMBER,
    p_resource_id          IN  NUMBER,
    x_result_flag          OUT NOCOPY VARCHAR2
)  AS
l_api_name             CONSTANT VARCHAR2(30) := 'Check_GroupMember';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_temp                 NUMBER;
--
CURSOR  Check_GroupMember_csr IS
Select m.group_member_id
From jtf_rs_group_members m, jtf_rs_groups_vl g
Where m.resource_id = p_resource_id
And   m.group_id = p_group_id
And   m.delete_flag <> 'Y'
And   g.group_id = p_group_id
And   g.start_date_active < sysdate
And   nvl(g.end_date_active, sysdate+1) > sysdate
;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_GroupMember_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_result_flag := FND_API.G_FALSE;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    OPEN  Check_GroupMember_csr;
    FETCH  Check_GroupMember_csr INTO l_temp;
    IF (Check_GroupMember_csr%FOUND) THEN
       x_result_flag := FND_API.G_TRUE;
    END IF;
    CLOSE Check_groupMember_csr;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Check_GroupMember;
--------------------------------------------------------------------------------
----------------------------------   ACCESS   ----------------------------------
--------------------------------------------------------------------------------
PROCEDURE Update_Access
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_access_obj          IN  AMV_ACCESS_OBJ_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Update_Access';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_admin_flag           VARCHAR2(1);
l_access_obj           AMV_ACCESS_OBJ_TYPE := p_access_obj;
l_temp                 NUMBER;
--
CURSOR  Get_AccessId_csr IS
Select access_id
From  amv_u_access
Where user_or_group_id = l_access_obj.user_or_group_id
And   user_or_group_type = l_access_obj.user_or_group_type
And   access_to_table_record_id = l_access_obj.access_to_table_record_id
And   access_to_table_code = l_access_obj.access_to_table_code;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Update_Access_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       -- We might not need this one.
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    IF (l_access_obj.access_id IS NULL) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NULL_ACCESS_OBJ');
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN   Get_AccessId_csr;
    FETCH  Get_AccessId_csr INTO l_temp;
    IF (Get_AccessId_csr%FOUND) THEN
       CLOSE Get_AccessId_csr;
       l_access_obj.access_id := l_temp;
    ELSE
       CLOSE Get_AccessId_csr;
       l_access_obj.access_id := FND_API.G_MISS_NUM;
    END IF;
    IF (l_access_obj.access_id = FND_API.G_MISS_NUM) THEN
        IF (l_access_obj.user_or_group_type = G_GROUP_ARC_TYPE) THEN
           -- Check if the Group id is valid
           IF (AMV_UTILITY_PVT.IS_GROUPIDVALID(l_access_obj.user_or_group_id)
              <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_INVALID_GROUP_ID');
                  FND_MESSAGE.Set_Token('ID',
                     TO_CHAR( NVL(l_access_obj.user_or_group_id,-1)) );
                  FND_MSG_PUB.Add;
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
           END IF;
        ELSIF (l_access_obj.user_or_group_type = G_USER_ARC_TYPE) THEN
           -- Check if the resource id is valid
           IF (AMV_UTILITY_PVT.IS_RESOURCEIDVALID(l_access_obj.user_or_group_id)
               <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_INVALID_RESOURCE_ID');
                  FND_MESSAGE.Set_Token('ID',
                     TO_CHAR( NVL(l_access_obj.user_or_group_id,-1)) );
                  FND_MSG_PUB.Add;
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
           END IF;
        ELSE
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_WRONG_ACCESS_USER_TYPE');
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
        IF (l_access_obj.access_to_table_code = G_ITEM_ARC_TYPE) THEN
           -- Check if the item id is valid
           IF (AMV_UTILITY_PVT.IS_ITEMIDVALID(
                 l_access_obj.access_to_table_record_id) <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_INVALID_ITEM_ID');
                  FND_MESSAGE.Set_Token('ID',
                     TO_CHAR( NVL(l_access_obj.access_to_table_record_id,-1)) );
                  FND_MSG_PUB.Add;
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
           END IF;
        ELSIF (l_access_obj.access_to_table_code = G_CHAN_ARC_TYPE) THEN
           -- Check if the channel id is valid
           IF (AMV_UTILITY_PVT.IS_CHANNELIDVALID(
                 l_access_obj.access_to_table_record_id) <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_INVALID_CHANEL_ID');
                  FND_MESSAGE.Set_Token('ID',
                     TO_CHAR( NVL(l_access_obj.access_to_table_record_id,-1)) );
                  FND_MSG_PUB.Add;
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
           END IF;
        ELSIF (l_access_obj.access_to_table_code = G_CATE_ARC_TYPE) THEN
           -- Check if the category id is valid
           IF (AMV_UTILITY_PVT.IS_CATEGORYIDVALID(
                 l_access_obj.access_to_table_record_id) <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_INVALID_CATEGORY_ID');
                  FND_MESSAGE.Set_Token('ID',
                     TO_CHAR( NVL(l_access_obj.access_to_table_record_id,-1)) );
                  FND_MSG_PUB.Add;
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
           END IF;
        ELSIF (l_access_obj.access_to_table_code = G_APPL_ARC_TYPE) THEN
           -- Check if the application id is valid
           IF (AMV_UTILITY_PVT.IS_APPLIDVALID(
                 l_access_obj.access_to_table_record_id) <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_INVALID_APPLICATION_ID');
                  FND_MESSAGE.Set_Token('ID',
                     TO_CHAR( NVL(l_access_obj.access_to_table_record_id,-1)) );
                  FND_MSG_PUB.Add;
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
           END IF;
        ELSE
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_WRONG_ACCESS_TABLE_TYPE');
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
        IF (l_access_obj.effective_start_date = FND_API.G_MISS_DATE
            OR l_access_obj.effective_start_date IS NULL) THEN
            l_access_obj.effective_start_date := sysdate;
        END IF;
        IF (l_access_obj.expiration_date = FND_API.G_MISS_DATE) THEN
            l_access_obj.expiration_date := null;
        END IF;
        IF (l_access_obj.can_view_flag IS NULL OR
            l_access_obj.can_view_flag <> FND_API.G_TRUE) THEN
            l_access_obj.can_view_flag := FND_API.G_FALSE;
        END IF;
        IF (l_access_obj.can_create_flag IS NULL OR
            l_access_obj.can_create_flag <> FND_API.G_TRUE) THEN
            l_access_obj.can_create_flag := FND_API.G_FALSE;
        END IF;
        IF (l_access_obj.can_delete_flag IS NULL OR
            l_access_obj.can_delete_flag <> FND_API.G_TRUE) THEN
            l_access_obj.can_delete_flag := FND_API.G_FALSE;
        END IF;
        IF (l_access_obj.can_update_flag IS NULL OR
            l_access_obj.can_update_flag <> FND_API.G_TRUE) THEN
            l_access_obj.can_update_flag := FND_API.G_FALSE;
        END IF;
        IF (l_access_obj.can_create_dist_rule_flag IS NULL OR
            l_access_obj.can_create_dist_rule_flag <> FND_API.G_TRUE) THEN
            l_access_obj.can_create_dist_rule_flag := FND_API.G_FALSE;
        END IF;
        IF (l_access_obj.chl_approver_flag IS NULL OR
            l_access_obj.chl_approver_flag <> FND_API.G_TRUE) THEN
            l_access_obj.chl_approver_flag := FND_API.G_FALSE;
        END IF;
        IF (l_access_obj.chl_required_flag IS NULL OR
            l_access_obj.chl_required_flag <> FND_API.G_TRUE) THEN
            l_access_obj.chl_required_flag := FND_API.G_FALSE;
        END IF;
        IF (l_access_obj.chl_required_need_notif_flag IS NULL OR
            l_access_obj.chl_required_need_notif_flag <> FND_API.G_TRUE) THEN
            l_access_obj.chl_required_need_notif_flag := FND_API.G_FALSE;
        END IF;
        --Now let the helper do the real job.
        Add_Access_helper
        (
            p_access_obj     => l_access_obj,
            x_return_status  => x_return_status,
            x_access_id      => l_temp
        );
    ELSE
        IF (l_access_obj.effective_start_date IS NULL) THEN
            l_access_obj.effective_start_date := FND_API.G_MISS_DATE;
        END IF;
        IF (l_access_obj.can_view_flag IS NULL) THEN
            l_access_obj.can_view_flag := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_access_obj.can_create_flag IS NULL) THEN
            l_access_obj.can_create_flag := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_access_obj.can_delete_flag IS NULL) THEN
            l_access_obj.can_delete_flag := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_access_obj.can_update_flag IS NULL) THEN
            l_access_obj.can_update_flag := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_access_obj.can_create_dist_rule_flag IS NULL ) THEN
            l_access_obj.can_create_dist_rule_flag := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_access_obj.chl_approver_flag IS NULL ) THEN
            l_access_obj.chl_approver_flag := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_access_obj.chl_required_flag IS NULL ) THEN
            l_access_obj.chl_required_flag := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_access_obj.chl_required_need_notif_flag IS NULL ) THEN
            l_access_obj.chl_required_need_notif_flag := FND_API.G_MISS_CHAR;
        END IF;
        --Now let the helper do the real job.
        Update_Access_helper
        (
            p_access_obj     => l_access_obj,
            x_return_status  => x_return_status
        );
    END IF;
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_Access_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_Access_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_Access_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Update_Access;
--------------------------------------------------------------------------------
PROCEDURE Update_Access
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_access_obj_array    IN  AMV_ACCESS_OBJ_VARRAY
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Update_Access';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_return_status        VARCHAR2(1);
l_count                NUMBER;
l_admin_flag           VARCHAR2(1);
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Update_Access_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       -- We might not need this one.
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_current_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    IF (p_access_obj_array IS NULL) THEN
        l_count := 0;
    ELSE
       l_count := p_access_obj_array.count;
    END IF;
    FOR i IN 1..l_count LOOP
       Update_Access
       (
           p_api_version         => p_api_version,
           p_commit              => p_commit,
           p_validation_level    => p_validation_level,
           x_return_status       => l_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_access_obj          => p_access_obj_array(i)
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_Access_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_Access_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_Access_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Update_Access;
--------------------------------------------------------------------------------
PROCEDURE Update_ResourceApplAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_application_id      IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_access_obj      AMV_ACCESS_OBJ_TYPE;
BEGIN

   l_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
   l_access_obj.OBJECT_VERSION_NUMBER := 1;
   l_access_obj.ACCESS_TO_TABLE_CODE := p_application_id;
   l_access_obj.ACCESS_TO_TABLE_RECORD_ID := G_APPL_ARC_TYPE;
   l_access_obj.USER_OR_GROUP_ID := p_resource_id;
   l_access_obj.USER_OR_GROUP_TYPE := G_USER_ARC_TYPE;
   l_access_obj.EFFECTIVE_START_DATE := sysdate;
   l_access_obj.EXPIRATION_DATE := null;
   l_access_obj.CAN_VIEW_FLAG := p_access_flag_obj.can_view_flag;
   l_access_obj.CAN_CREATE_FLAG := p_access_flag_obj.can_create_flag;
   l_access_obj.CAN_DELETE_FLAG := p_access_flag_obj.can_delete_flag;
   l_access_obj.CAN_UPDATE_FLAG := p_access_flag_obj.can_update_flag;
   l_access_obj.CAN_CREATE_DIST_RULE_FLAG := p_access_flag_obj.can_create_dist_rule_flag;
   l_access_obj.CHL_APPROVER_FLAG := p_access_flag_obj.chl_approver_flag;
   l_access_obj.CHL_REQUIRED_FLAG := p_access_flag_obj.chl_required_flag;
   l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := p_access_flag_obj.chl_required_need_notif_flag;
/*
   l_access_obj := AMV_ACCESS_OBJ_TYPE
                   (
                     FND_API.G_MISS_NUM,
                     1,
                     p_application_id,
                     G_APPL_ARC_TYPE,
                     p_resource_id,
                     G_USER_ARC_TYPE,
                     sysdate,
                     null,
                     p_access_flag_obj.can_view_flag,
                     p_access_flag_obj.can_create_flag,
                     p_access_flag_obj.can_delete_flag,
                     p_access_flag_obj.can_update_flag,
                     p_access_flag_obj.can_create_dist_rule_flag,
                     p_access_flag_obj.chl_approver_flag,
                     p_access_flag_obj.chl_required_flag,
                     p_access_flag_obj.chl_required_need_notif_flag
                   );
*/
    Update_Access
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_access_obj          => l_access_obj
    );
END Update_ResourceApplAccess;
--------------------------------------------------------------------------------
PROCEDURE Update_ResourceChanAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_channel_id          IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_access_obj      AMV_ACCESS_OBJ_TYPE;
BEGIN
   l_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
   l_access_obj.OBJECT_VERSION_NUMBER := 1;
   l_access_obj.ACCESS_TO_TABLE_CODE := p_channel_id;
   l_access_obj.ACCESS_TO_TABLE_RECORD_ID := G_CHAN_ARC_TYPE;
   l_access_obj.USER_OR_GROUP_ID := p_resource_id;
   l_access_obj.USER_OR_GROUP_TYPE := G_USER_ARC_TYPE;
   l_access_obj.EFFECTIVE_START_DATE := sysdate;
   l_access_obj.EXPIRATION_DATE := null;
   l_access_obj.CAN_VIEW_FLAG := p_access_flag_obj.can_view_flag;
   l_access_obj.CAN_CREATE_FLAG := p_access_flag_obj.can_create_flag;
   l_access_obj.CAN_DELETE_FLAG := p_access_flag_obj.can_delete_flag;
   l_access_obj.CAN_UPDATE_FLAG := p_access_flag_obj.can_update_flag;
   l_access_obj.CAN_CREATE_DIST_RULE_FLAG := p_access_flag_obj.can_create_dist_rule_flag;
   l_access_obj.CHL_APPROVER_FLAG := p_access_flag_obj.chl_approver_flag;
   l_access_obj.CHL_REQUIRED_FLAG := p_access_flag_obj.chl_required_flag;
   l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := p_access_flag_obj.chl_required_need_notif_flag;

/*
   l_access_obj := AMV_ACCESS_OBJ_TYPE
                   (
                     FND_API.G_MISS_NUM,
                     1,
                     p_channel_id,
                     G_CHAN_ARC_TYPE,
                     p_resource_id,
                     G_USER_ARC_TYPE,
                     sysdate,
                     null,
                     p_access_flag_obj.can_view_flag,
                     p_access_flag_obj.can_create_flag,
                     p_access_flag_obj.can_delete_flag,
                     p_access_flag_obj.can_update_flag,
                     p_access_flag_obj.can_create_dist_rule_flag,
                     p_access_flag_obj.chl_approver_flag,
                     p_access_flag_obj.chl_required_flag,
                     p_access_flag_obj.chl_required_need_notif_flag
                   );
*/
    Update_Access
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_access_obj          => l_access_obj
    );
END Update_ResourceChanAccess;
--------------------------------------------------------------------------------
PROCEDURE Update_ResourceCateAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_access_obj      AMV_ACCESS_OBJ_TYPE;
BEGIN
   l_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
   l_access_obj.OBJECT_VERSION_NUMBER := 1;
   l_access_obj.ACCESS_TO_TABLE_CODE := p_category_id;
   l_access_obj.ACCESS_TO_TABLE_RECORD_ID := G_CATE_ARC_TYPE;
   l_access_obj.USER_OR_GROUP_ID := p_resource_id;
   l_access_obj.USER_OR_GROUP_TYPE := G_USER_ARC_TYPE;
   l_access_obj.EFFECTIVE_START_DATE := sysdate;
   l_access_obj.EXPIRATION_DATE := null;
   l_access_obj.CAN_VIEW_FLAG := p_access_flag_obj.can_view_flag;
   l_access_obj.CAN_CREATE_FLAG := p_access_flag_obj.can_create_flag;
   l_access_obj.CAN_DELETE_FLAG := p_access_flag_obj.can_delete_flag;
   l_access_obj.CAN_UPDATE_FLAG := p_access_flag_obj.can_update_flag;
   l_access_obj.CAN_CREATE_DIST_RULE_FLAG := p_access_flag_obj.can_create_dist_rule_flag;
   l_access_obj.CHL_APPROVER_FLAG := p_access_flag_obj.chl_approver_flag;
   l_access_obj.CHL_REQUIRED_FLAG := p_access_flag_obj.chl_required_flag;
   l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := p_access_flag_obj.chl_required_need_notif_flag;

/*
   l_access_obj := AMV_ACCESS_OBJ_TYPE
                   (
                     FND_API.G_MISS_NUM,
                     1,
                     p_category_id,
                     G_CATE_ARC_TYPE,
                     p_resource_id,
                     G_USER_ARC_TYPE,
                     sysdate,
                     null,
                     p_access_flag_obj.can_view_flag,
                     p_access_flag_obj.can_create_flag,
                     p_access_flag_obj.can_delete_flag,
                     p_access_flag_obj.can_update_flag,
                     p_access_flag_obj.can_create_dist_rule_flag,
                     p_access_flag_obj.chl_approver_flag,
                     p_access_flag_obj.chl_required_flag,
                     p_access_flag_obj.chl_required_need_notif_flag
                   );
*/
    Update_Access
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_access_obj          => l_access_obj
    );
END Update_ResourceCateAccess;
--------------------------------------------------------------------------------
PROCEDURE Update_ResourceItemAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_item_id             IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_access_obj      AMV_ACCESS_OBJ_TYPE;
BEGIN
   l_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
   l_access_obj.OBJECT_VERSION_NUMBER := 1;
   l_access_obj.ACCESS_TO_TABLE_CODE := p_item_id;
   l_access_obj.ACCESS_TO_TABLE_RECORD_ID := G_ITEM_ARC_TYPE;
   l_access_obj.USER_OR_GROUP_ID := p_resource_id;
   l_access_obj.USER_OR_GROUP_TYPE := G_USER_ARC_TYPE;
   l_access_obj.EFFECTIVE_START_DATE := sysdate;
   l_access_obj.EXPIRATION_DATE := null;
   l_access_obj.CAN_VIEW_FLAG := p_access_flag_obj.can_view_flag;
   l_access_obj.CAN_CREATE_FLAG := p_access_flag_obj.can_create_flag;
   l_access_obj.CAN_DELETE_FLAG := p_access_flag_obj.can_delete_flag;
   l_access_obj.CAN_UPDATE_FLAG := p_access_flag_obj.can_update_flag;
   l_access_obj.CAN_CREATE_DIST_RULE_FLAG := p_access_flag_obj.can_create_dist_rule_flag;
   l_access_obj.CHL_APPROVER_FLAG := p_access_flag_obj.chl_approver_flag;
   l_access_obj.CHL_REQUIRED_FLAG := p_access_flag_obj.chl_required_flag;
   l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := p_access_flag_obj.chl_required_need_notif_flag;

/*
   l_access_obj := AMV_ACCESS_OBJ_TYPE
                   (
                     FND_API.G_MISS_NUM,
                     1,
                     p_item_id,
                     G_ITEM_ARC_TYPE,
                     p_resource_id,
                     G_USER_ARC_TYPE,
                     sysdate,
                     null,
                     p_access_flag_obj.can_view_flag,
                     p_access_flag_obj.can_create_flag,
                     p_access_flag_obj.can_delete_flag,
                     p_access_flag_obj.can_update_flag,
                     p_access_flag_obj.can_create_dist_rule_flag,
                     p_access_flag_obj.chl_approver_flag,
                     p_access_flag_obj.chl_required_flag,
                     p_access_flag_obj.chl_required_need_notif_flag
                   );
*/
    Update_Access
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_access_obj          => l_access_obj
    );
END Update_ResourceItemAccess;
--------------------------------------------------------------------------------
PROCEDURE Update_GroupApplAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_group_id            IN  NUMBER,
    p_application_id      IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_access_obj      AMV_ACCESS_OBJ_TYPE;
BEGIN
   l_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
   l_access_obj.OBJECT_VERSION_NUMBER := 1;
   l_access_obj.ACCESS_TO_TABLE_CODE := p_application_id;
   l_access_obj.ACCESS_TO_TABLE_RECORD_ID := G_APPL_ARC_TYPE;
   l_access_obj.USER_OR_GROUP_ID := p_group_id;
   l_access_obj.USER_OR_GROUP_TYPE := G_GROUP_ARC_TYPE;
   l_access_obj.EFFECTIVE_START_DATE := sysdate;
   l_access_obj.EXPIRATION_DATE := null;
   l_access_obj.CAN_VIEW_FLAG := p_access_flag_obj.can_view_flag;
   l_access_obj.CAN_CREATE_FLAG := p_access_flag_obj.can_create_flag;
   l_access_obj.CAN_DELETE_FLAG := p_access_flag_obj.can_delete_flag;
   l_access_obj.CAN_UPDATE_FLAG := p_access_flag_obj.can_update_flag;
   l_access_obj.CAN_CREATE_DIST_RULE_FLAG := p_access_flag_obj.can_create_dist_rule_flag;
   l_access_obj.CHL_APPROVER_FLAG := p_access_flag_obj.chl_approver_flag;
   l_access_obj.CHL_REQUIRED_FLAG := p_access_flag_obj.chl_required_flag;
   l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := p_access_flag_obj.chl_required_need_notif_flag;

/*
   l_access_obj := AMV_ACCESS_OBJ_TYPE
                   (
                     FND_API.G_MISS_NUM,
                     1,
                     p_application_id,
                     G_APPL_ARC_TYPE,
                     p_group_id,
                     G_GROUP_ARC_TYPE,
                     sysdate,
                     null,
                     p_access_flag_obj.can_view_flag,
                     p_access_flag_obj.can_create_flag,
                     p_access_flag_obj.can_delete_flag,
                     p_access_flag_obj.can_update_flag,
                     p_access_flag_obj.can_create_dist_rule_flag,
                     p_access_flag_obj.chl_approver_flag,
                     p_access_flag_obj.chl_required_flag,
                     p_access_flag_obj.chl_required_need_notif_flag
                   );
*/
    Update_Access
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_access_obj          => l_access_obj
    );
END Update_GroupApplAccess;
--------------------------------------------------------------------------------
PROCEDURE Update_GroupChanAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_channel_id          IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_access_obj      AMV_ACCESS_OBJ_TYPE;
BEGIN
   l_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
   l_access_obj.OBJECT_VERSION_NUMBER := 1;
   l_access_obj.ACCESS_TO_TABLE_CODE := p_channel_id;
   l_access_obj.ACCESS_TO_TABLE_RECORD_ID := G_CHAN_ARC_TYPE;
   l_access_obj.USER_OR_GROUP_ID := p_group_id;
   l_access_obj.USER_OR_GROUP_TYPE := G_GROUP_ARC_TYPE;
   l_access_obj.EFFECTIVE_START_DATE := sysdate;
   l_access_obj.EXPIRATION_DATE := null;
   l_access_obj.CAN_VIEW_FLAG := p_access_flag_obj.can_view_flag;
   l_access_obj.CAN_CREATE_FLAG := p_access_flag_obj.can_create_flag;
   l_access_obj.CAN_DELETE_FLAG := p_access_flag_obj.can_delete_flag;
   l_access_obj.CAN_UPDATE_FLAG := p_access_flag_obj.can_update_flag;
   l_access_obj.CAN_CREATE_DIST_RULE_FLAG := p_access_flag_obj.can_create_dist_rule_flag;
   l_access_obj.CHL_APPROVER_FLAG := p_access_flag_obj.chl_approver_flag;
   l_access_obj.CHL_REQUIRED_FLAG := p_access_flag_obj.chl_required_flag;
   l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := p_access_flag_obj.chl_required_need_notif_flag;

/*
   l_access_obj := AMV_ACCESS_OBJ_TYPE
                   (
                     FND_API.G_MISS_NUM,
                     1,
                     p_channel_id,
                     G_CHAN_ARC_TYPE,
                     p_group_id,
                     G_GROUP_ARC_TYPE,
                     sysdate,
                     null,
                     p_access_flag_obj.can_view_flag,
                     p_access_flag_obj.can_create_flag,
                     p_access_flag_obj.can_delete_flag,
                     p_access_flag_obj.can_update_flag,
                     p_access_flag_obj.can_create_dist_rule_flag,
                     p_access_flag_obj.chl_approver_flag,
                     p_access_flag_obj.chl_required_flag,
                     p_access_flag_obj.chl_required_need_notif_flag
                   );
*/
    Update_Access
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_access_obj          => l_access_obj
    );
END Update_GroupChanAccess;
--------------------------------------------------------------------------------
PROCEDURE Update_GroupCateAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_access_obj      AMV_ACCESS_OBJ_TYPE;
BEGIN
   l_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
   l_access_obj.OBJECT_VERSION_NUMBER := 1;
   l_access_obj.ACCESS_TO_TABLE_CODE := p_category_id;
   l_access_obj.ACCESS_TO_TABLE_RECORD_ID := G_CATE_ARC_TYPE;
   l_access_obj.USER_OR_GROUP_ID := p_group_id;
   l_access_obj.USER_OR_GROUP_TYPE := G_GROUP_ARC_TYPE;
   l_access_obj.EFFECTIVE_START_DATE := sysdate;
   l_access_obj.EXPIRATION_DATE := null;
   l_access_obj.CAN_VIEW_FLAG := p_access_flag_obj.can_view_flag;
   l_access_obj.CAN_CREATE_FLAG := p_access_flag_obj.can_create_flag;
   l_access_obj.CAN_DELETE_FLAG := p_access_flag_obj.can_delete_flag;
   l_access_obj.CAN_UPDATE_FLAG := p_access_flag_obj.can_update_flag;
   l_access_obj.CAN_CREATE_DIST_RULE_FLAG := p_access_flag_obj.can_create_dist_rule_flag;
   l_access_obj.CHL_APPROVER_FLAG := p_access_flag_obj.chl_approver_flag;
   l_access_obj.CHL_REQUIRED_FLAG := p_access_flag_obj.chl_required_flag;
   l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := p_access_flag_obj.chl_required_need_notif_flag;

/*
   l_access_obj := AMV_ACCESS_OBJ_TYPE
                   (
                     FND_API.G_MISS_NUM,
                     1,
                     p_category_id,
                     G_CATE_ARC_TYPE,
                     p_group_id,
                     G_GROUP_ARC_TYPE,
                     sysdate,
                     null,
                     p_access_flag_obj.can_view_flag,
                     p_access_flag_obj.can_create_flag,
                     p_access_flag_obj.can_delete_flag,
                     p_access_flag_obj.can_update_flag,
                     p_access_flag_obj.can_create_dist_rule_flag,
                     p_access_flag_obj.chl_approver_flag,
                     p_access_flag_obj.chl_required_flag,
                     p_access_flag_obj.chl_required_need_notif_flag
                   );
*/
    Update_Access
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_access_obj          => l_access_obj
    );
END Update_GroupCateAccess;
--------------------------------------------------------------------------------
PROCEDURE Update_GroupItemAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_item_id             IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_access_obj      AMV_ACCESS_OBJ_TYPE;
BEGIN
   l_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
   l_access_obj.OBJECT_VERSION_NUMBER := 1;
   l_access_obj.ACCESS_TO_TABLE_CODE := p_item_id;
   l_access_obj.ACCESS_TO_TABLE_RECORD_ID := G_ITEM_ARC_TYPE;
   l_access_obj.USER_OR_GROUP_ID := p_group_id;
   l_access_obj.USER_OR_GROUP_TYPE := G_GROUP_ARC_TYPE;
   l_access_obj.EFFECTIVE_START_DATE := sysdate;
   l_access_obj.EXPIRATION_DATE := null;
   l_access_obj.CAN_VIEW_FLAG := p_access_flag_obj.can_view_flag;
   l_access_obj.CAN_CREATE_FLAG := p_access_flag_obj.can_create_flag;
   l_access_obj.CAN_DELETE_FLAG := p_access_flag_obj.can_delete_flag;
   l_access_obj.CAN_UPDATE_FLAG := p_access_flag_obj.can_update_flag;
   l_access_obj.CAN_CREATE_DIST_RULE_FLAG := p_access_flag_obj.can_create_dist_rule_flag;
   l_access_obj.CHL_APPROVER_FLAG := p_access_flag_obj.chl_approver_flag;
   l_access_obj.CHL_REQUIRED_FLAG := p_access_flag_obj.chl_required_flag;
   l_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := p_access_flag_obj.chl_required_need_notif_flag;

/*
   l_access_obj := AMV_ACCESS_OBJ_TYPE
                   (
                     FND_API.G_MISS_NUM,
                     1,
                     p_item_id,
                     G_ITEM_ARC_TYPE,
                     p_group_id,
                     G_GROUP_ARC_TYPE,
                     sysdate,
                     null,
                     p_access_flag_obj.can_view_flag,
                     p_access_flag_obj.can_create_flag,
                     p_access_flag_obj.can_delete_flag,
                     p_access_flag_obj.can_update_flag,
                     p_access_flag_obj.can_create_dist_rule_flag,
                     p_access_flag_obj.chl_approver_flag,
                     p_access_flag_obj.chl_required_flag,
                     p_access_flag_obj.chl_required_need_notif_flag
                   );
*/
    Update_Access
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_access_obj          => l_access_obj
    );
END Update_GroupItemAccess;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Get_ChannelAccess
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_or_group_id     IN  NUMBER,
    p_user_or_group_type   IN  VARCHAR2,
    x_channel_name_varray  OUT NOCOPY AMV_CHAR_VARRAY_TYPE,
    x_access_obj_varray    OUT NOCOPY AMV_ACCESS_OBJ_VARRAY
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ChannelAccess';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
l_count                NUMBER;
--
CURSOR Get_ChannelAccess_csr IS
Select
   C.CHANNEL_NAME,
   U.ACCESS_TO_TABLE_RECORD_ID,
   U.ACCESS_ID,
   U.OBJECT_VERSION_NUMBER,
   U.EFFECTIVE_START_DATE,
   U.EXPIRATION_DATE,
   U.CAN_VIEW_FLAG,
   U.CAN_CREATE_FLAG,
   U.CAN_DELETE_FLAG,
   U.CAN_UPDATE_FLAG,
   U.CAN_CREATE_DIST_RULE_FLAG,
   U.CHL_APPROVER_FLAG,
   U.CHL_REQUIRED_FLAG,
   U.CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access u, amv_c_channels_vl c
Where u.user_or_group_id = p_user_or_group_id
And   u.user_or_group_type = p_user_or_group_type
And   access_to_table_code = G_CHAN_ARC_TYPE
And   u.access_to_table_record_id = c.channel_id;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    x_channel_name_varray := AMV_CHAR_VARRAY_TYPE();
    x_access_obj_varray   := AMV_ACCESS_OBJ_VARRAY();
    l_count := 0;
    FOR  cur IN Get_ChannelAccess_csr LOOP
        l_count := l_count + 1;
        x_channel_name_varray.extend;
        x_channel_name_varray(l_count) := cur.CHANNEL_NAME;

        x_access_obj_varray.extend;
        x_access_obj_varray(l_count).ACCESS_ID := cur.ACCESS_ID;
        x_access_obj_varray(l_count).OBJECT_VERSION_NUMBER := cur.OBJECT_VERSION_NUMBER;
        x_access_obj_varray(l_count).ACCESS_TO_TABLE_CODE := G_CHAN_ARC_TYPE;
        x_access_obj_varray(l_count).ACCESS_TO_TABLE_RECORD_ID := cur.ACCESS_TO_TABLE_RECORD_ID;
        x_access_obj_varray(l_count).USER_OR_GROUP_ID := p_user_or_group_id;
        x_access_obj_varray(l_count).USER_OR_GROUP_TYPE := p_user_or_group_type;
        x_access_obj_varray(l_count).EFFECTIVE_START_DATE := cur.EFFECTIVE_START_DATE;
        x_access_obj_varray(l_count).EXPIRATION_DATE := cur.EXPIRATION_DATE;
        x_access_obj_varray(l_count).CAN_VIEW_FLAG := cur.CAN_VIEW_FLAG;
        x_access_obj_varray(l_count).CAN_CREATE_FLAG := cur.CAN_CREATE_FLAG;
        x_access_obj_varray(l_count).CAN_DELETE_FLAG := cur.CAN_DELETE_FLAG;
        x_access_obj_varray(l_count).CAN_UPDATE_FLAG := cur.CAN_UPDATE_FLAG;
        x_access_obj_varray(l_count).CAN_CREATE_DIST_RULE_FLAG := cur.CAN_CREATE_DIST_RULE_FLAG;
        x_access_obj_varray(l_count).CHL_APPROVER_FLAG := cur.CHL_APPROVER_FLAG;
        x_access_obj_varray(l_count).CHL_REQUIRED_FLAG := cur.CHL_REQUIRED_FLAG;
        x_access_obj_varray(l_count).CHL_REQUIRED_NEED_NOTIF_FLAG := cur.CHL_REQUIRED_NEED_NOTIF_FLAG;
/*
        x_access_obj_varray(l_count) := AMV_ACCESS_OBJ_TYPE(
          cur.ACCESS_ID,
          cur.OBJECT_VERSION_NUMBER,
          G_CHAN_ARC_TYPE,
          cur.ACCESS_TO_TABLE_RECORD_ID,
          p_user_or_group_id,
          p_user_or_group_type,
          cur.EFFECTIVE_START_DATE,
          cur.EXPIRATION_DATE,
          cur.CAN_VIEW_FLAG,
          cur.CAN_CREATE_FLAG,
          cur.CAN_DELETE_FLAG,
          cur.CAN_UPDATE_FLAG,
          cur.CAN_CREATE_DIST_RULE_FLAG,
          cur.CHL_APPROVER_FLAG,
          cur.CHL_REQUIRED_FLAG,
          cur.CHL_REQUIRED_NEED_NOTIF_FLAG
          );
*/
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_ChannelAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_AccessPerChannel
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id           IN  NUMBER,
    p_user_or_group_type   IN  VARCHAR2,
    x_name_varray          OUT NOCOPY AMV_CHAR_VARRAY_TYPE,
    x_access_obj_varray    OUT NOCOPY AMV_ACCESS_OBJ_VARRAY
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_AccessPerChannel';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
l_count                NUMBER;
--
CURSOR Get_GroupAccessPerChannel_csr IS
Select
   G.GROUP_NAME NAME,
   U.USER_OR_GROUP_ID,
   U.USER_OR_GROUP_TYPE,
   U.ACCESS_TO_TABLE_RECORD_ID,
   U.ACCESS_TO_TABLE_CODE,
   U.ACCESS_ID,
   U.OBJECT_VERSION_NUMBER,
   U.EFFECTIVE_START_DATE,
   U.EXPIRATION_DATE,
   U.CAN_VIEW_FLAG,
   U.CAN_CREATE_FLAG,
   U.CAN_DELETE_FLAG,
   U.CAN_UPDATE_FLAG,
   U.CAN_CREATE_DIST_RULE_FLAG,
   U.CHL_APPROVER_FLAG,
   U.CHL_REQUIRED_FLAG,
   U.CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access u, jtf_rs_groups_vl g
Where u.user_or_group_id = g.group_id
And   u.user_or_group_type = G_GROUP_ARC_TYPE
And   access_to_table_code = G_CHAN_ARC_TYPE
And   u.access_to_table_record_id = p_channel_id;
--
CURSOR Get_UserAccessPerChannel_csr IS
Select
   R.LAST_NAME || ', ' || R.FIRST_NAME NAME,
   U.USER_OR_GROUP_ID,
   U.USER_OR_GROUP_TYPE,
   U.ACCESS_TO_TABLE_RECORD_ID,
   U.ACCESS_TO_TABLE_CODE,
   U.ACCESS_ID,
   U.OBJECT_VERSION_NUMBER,
   U.EFFECTIVE_START_DATE,
   U.EXPIRATION_DATE,
   U.CAN_VIEW_FLAG,
   U.CAN_CREATE_FLAG,
   U.CAN_DELETE_FLAG,
   U.CAN_UPDATE_FLAG,
   U.CAN_CREATE_DIST_RULE_FLAG,
   U.CHL_APPROVER_FLAG,
   U.CHL_REQUIRED_FLAG,
   U.CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access u, amv_rs_all_res_extns_vl r
Where u.user_or_group_id = r.resource_id
And   u.user_or_group_type = G_USER_ARC_TYPE
And   access_to_table_code = G_CHAN_ARC_TYPE
And   u.access_to_table_record_id = p_channel_id;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    x_name_varray := AMV_CHAR_VARRAY_TYPE();
    x_access_obj_varray   := AMV_ACCESS_OBJ_VARRAY();
    l_count := 0;
    IF (p_user_or_group_type = G_GROUP_ARC_TYPE) THEN
        FOR  cur IN Get_GroupAccessPerChannel_csr LOOP
            l_count := l_count + 1;
            x_name_varray.extend;
            x_name_varray(l_count) := cur.NAME;

            x_access_obj_varray.extend;
            x_access_obj_varray(l_count).ACCESS_ID := cur.ACCESS_ID;
            x_access_obj_varray(l_count).OBJECT_VERSION_NUMBER := cur.OBJECT_VERSION_NUMBER;
            x_access_obj_varray(l_count).ACCESS_TO_TABLE_CODE := cur.ACCESS_TO_TABLE_CODE;
            x_access_obj_varray(l_count).ACCESS_TO_TABLE_RECORD_ID := cur.ACCESS_TO_TABLE_RECORD_ID;
            x_access_obj_varray(l_count).USER_OR_GROUP_ID := cur.USER_OR_GROUP_ID;
            x_access_obj_varray(l_count).USER_OR_GROUP_TYPE := cur.USER_OR_GROUP_TYPE;
            x_access_obj_varray(l_count).EFFECTIVE_START_DATE := cur.EFFECTIVE_START_DATE;
            x_access_obj_varray(l_count).EXPIRATION_DATE := cur.EXPIRATION_DATE;
            x_access_obj_varray(l_count).CAN_VIEW_FLAG := cur.CAN_VIEW_FLAG;
            x_access_obj_varray(l_count).CAN_CREATE_FLAG := cur.CAN_CREATE_FLAG;
            x_access_obj_varray(l_count).CAN_DELETE_FLAG := cur.CAN_DELETE_FLAG;
            x_access_obj_varray(l_count).CAN_UPDATE_FLAG := cur.CAN_UPDATE_FLAG;
            x_access_obj_varray(l_count).CAN_CREATE_DIST_RULE_FLAG := cur.CAN_CREATE_DIST_RULE_FLAG;
            x_access_obj_varray(l_count).CHL_APPROVER_FLAG := cur.CHL_APPROVER_FLAG;
            x_access_obj_varray(l_count).CHL_REQUIRED_FLAG := cur.CHL_REQUIRED_FLAG;
            x_access_obj_varray(l_count).CHL_REQUIRED_NEED_NOTIF_FLAG := cur.CHL_REQUIRED_NEED_NOTIF_FLAG;

/*
            x_access_obj_varray(l_count) := AMV_ACCESS_OBJ_TYPE(
              cur.ACCESS_ID,
              cur.OBJECT_VERSION_NUMBER,
              cur.ACCESS_TO_TABLE_CODE,
              cur.ACCESS_TO_TABLE_RECORD_ID,
              cur.USER_OR_GROUP_ID,
              cur.USER_OR_GROUP_TYPE,
              cur.EFFECTIVE_START_DATE,
              cur.EXPIRATION_DATE,
              cur.CAN_VIEW_FLAG,
              cur.CAN_CREATE_FLAG,
              cur.CAN_DELETE_FLAG,
              cur.CAN_UPDATE_FLAG,
              cur.CAN_CREATE_DIST_RULE_FLAG,
              cur.CHL_APPROVER_FLAG,
              cur.CHL_REQUIRED_FLAG,
              cur.CHL_REQUIRED_NEED_NOTIF_FLAG
              );
*/
        END LOOP;
    ELSIF ( p_user_or_group_type = G_USER_ARC_TYPE) THEN
        FOR  cur IN Get_UserAccessPerChannel_csr LOOP
            l_count := l_count + 1;
            x_name_varray.extend;
            x_name_varray(l_count) := cur.NAME;

            x_access_obj_varray.extend;
            x_access_obj_varray(l_count).ACCESS_ID := cur.ACCESS_ID;
            x_access_obj_varray(l_count).OBJECT_VERSION_NUMBER := cur.OBJECT_VERSION_NUMBER;
            x_access_obj_varray(l_count).ACCESS_TO_TABLE_CODE := cur.ACCESS_TO_TABLE_CODE;
            x_access_obj_varray(l_count).ACCESS_TO_TABLE_RECORD_ID := cur.ACCESS_TO_TABLE_RECORD_ID;
            x_access_obj_varray(l_count).USER_OR_GROUP_ID := cur.USER_OR_GROUP_ID;
            x_access_obj_varray(l_count).USER_OR_GROUP_TYPE := cur.USER_OR_GROUP_TYPE;
            x_access_obj_varray(l_count).EFFECTIVE_START_DATE := cur.EFFECTIVE_START_DATE;
            x_access_obj_varray(l_count).EXPIRATION_DATE := cur.EXPIRATION_DATE;
            x_access_obj_varray(l_count).CAN_VIEW_FLAG := cur.CAN_VIEW_FLAG;
            x_access_obj_varray(l_count).CAN_CREATE_FLAG := cur.CAN_CREATE_FLAG;
            x_access_obj_varray(l_count).CAN_DELETE_FLAG := cur.CAN_DELETE_FLAG;
            x_access_obj_varray(l_count).CAN_UPDATE_FLAG := cur.CAN_UPDATE_FLAG;
            x_access_obj_varray(l_count).CAN_CREATE_DIST_RULE_FLAG := cur.CAN_CREATE_DIST_RULE_FLAG;
            x_access_obj_varray(l_count).CHL_APPROVER_FLAG := cur.CHL_APPROVER_FLAG;
            x_access_obj_varray(l_count).CHL_REQUIRED_FLAG := cur.CHL_REQUIRED_FLAG;
            x_access_obj_varray(l_count).CHL_REQUIRED_NEED_NOTIF_FLAG := cur.CHL_REQUIRED_NEED_NOTIF_FLAG;
/*
            x_access_obj_varray(l_count) := AMV_ACCESS_OBJ_TYPE(
              cur.ACCESS_ID,
              cur.OBJECT_VERSION_NUMBER,
              cur.ACCESS_TO_TABLE_CODE,
              cur.ACCESS_TO_TABLE_RECORD_ID,
              cur.USER_OR_GROUP_ID,
              cur.USER_OR_GROUP_TYPE,
              cur.EFFECTIVE_START_DATE,
              cur.EXPIRATION_DATE,
              cur.CAN_VIEW_FLAG,
              cur.CAN_CREATE_FLAG,
              cur.CAN_DELETE_FLAG,
              cur.CAN_UPDATE_FLAG,
              cur.CAN_CREATE_DIST_RULE_FLAG,
              cur.CHL_APPROVER_FLAG,
              cur.CHL_REQUIRED_FLAG,
              cur.CHL_REQUIRED_NEED_NOTIF_FLAG
              );
*/
        END LOOP;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_AccessPerChannel;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Get_BusinessObjectAccess
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_or_group_id     IN  NUMBER,
    p_user_or_group_type   IN  VARCHAR2,
    p_business_object_id   IN  NUMBER,
    p_business_object_type IN  VARCHAR2,
    x_access_obj           OUT NOCOPY AMV_ACCESS_OBJ_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_BusinessObjectAccess';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
CURSOR Get_Access_csr IS
Select
   ACCESS_ID,
   OBJECT_VERSION_NUMBER,
   EFFECTIVE_START_DATE,
   EXPIRATION_DATE,
   CAN_VIEW_FLAG,
   CAN_CREATE_FLAG,
   CAN_DELETE_FLAG,
   CAN_UPDATE_FLAG,
   CAN_CREATE_DIST_RULE_FLAG,
   CHL_APPROVER_FLAG,
   CHL_REQUIRED_FLAG,
   CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access
Where user_or_group_id = p_user_or_group_id
And   user_or_group_type = p_user_or_group_type
And   access_to_table_record_id = p_business_object_id
And   access_to_table_code = p_business_object_type;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_access_obj.ACCESS_ID := FND_API.G_MISS_NUM;
    x_access_obj.OBJECT_VERSION_NUMBER := -1;
    x_access_obj.ACCESS_TO_TABLE_CODE := p_business_object_type;
    x_access_obj.ACCESS_TO_TABLE_RECORD_ID := p_business_object_id;
    x_access_obj.USER_OR_GROUP_ID := p_user_or_group_id;
    x_access_obj.USER_OR_GROUP_TYPE := p_user_or_group_type;
    x_access_obj.EFFECTIVE_START_DATE := null;
    x_access_obj.EXPIRATION_DATE := null;
    x_access_obj.CAN_VIEW_FLAG := FND_API.G_FALSE;
    x_access_obj.CAN_CREATE_FLAG := FND_API.G_FALSE;
    x_access_obj.CAN_DELETE_FLAG := FND_API.G_FALSE;
    x_access_obj.CAN_UPDATE_FLAG := FND_API.G_FALSE;
    x_access_obj.CAN_CREATE_DIST_RULE_FLAG := FND_API.G_FALSE;
    x_access_obj.CHL_APPROVER_FLAG := FND_API.G_FALSE;
    x_access_obj.CHL_REQUIRED_FLAG := FND_API.G_FALSE;
    x_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := FND_API.G_FALSE;

/*
    x_access_obj := AMV_ACCESS_OBJ_TYPE
                    (
                       FND_API.G_MISS_NUM,
                       -1,
                       p_business_object_type,
                       p_business_object_id,
                       p_user_or_group_id,
                       p_user_or_group_type,
                       null,
                       null,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE
                    );
*/
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    OPEN  Get_Access_csr;
    FETCH Get_Access_csr INTO
          x_access_obj.ACCESS_ID,
          x_access_obj.OBJECT_VERSION_NUMBER,
          x_access_obj.EFFECTIVE_START_DATE,
          x_access_obj.EXPIRATION_DATE,
          x_access_obj.CAN_VIEW_FLAG,
          x_access_obj.CAN_CREATE_FLAG,
          x_access_obj.CAN_DELETE_FLAG,
          x_access_obj.CAN_UPDATE_FLAG,
          x_access_obj.CAN_CREATE_DIST_RULE_FLAG,
          x_access_obj.CHL_APPROVER_FLAG,
          x_access_obj.CHL_REQUIRED_FLAG,
          x_access_obj.CHL_REQUIRED_NEED_NOTIF_FLAG;
    CLOSE Get_Access_csr;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_BusinessObjectAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_BusinessObjectAccess
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag   IN  VARCHAR2 := FND_API.G_TRUE,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_or_group_id     IN  NUMBER,
    p_user_or_group_type   IN  VARCHAR2,
    p_business_object_id   IN  NUMBER,
    p_business_object_type IN  VARCHAR2,
    x_access_flag_obj      OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_BusinessObjectAccess';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER;
l_current_login_id     NUMBER;
l_current_resource_id  NUMBER;
l_current_user_status  VARCHAR2(30);
--
l_start_date           DATE;
l_end_date             DATE;
--
CURSOR Get_ChannelEffDate_csr(p_id IN NUMBER) IS
Select
   effective_start_date,
   expiration_date
From  amv_c_channels_b
Where channel_id = p_id;
--
CURSOR Get_ItemEffDate_csr(p_id IN NUMBER) IS
Select
   actual_avail_from_date effective_start_date,
   actual_avail_to_date   expiration_date
From  ams_deliverables_all_b
Where deliverable_id = p_id;
--
CURSOR Get_Access_csr IS
Select
   CAN_VIEW_FLAG,
   CAN_CREATE_FLAG,
   CAN_DELETE_FLAG,
   CAN_UPDATE_FLAG,
   CAN_CREATE_DIST_RULE_FLAG,
   CHL_APPROVER_FLAG,
   CHL_REQUIRED_FLAG,
   CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access
Where user_or_group_id = p_user_or_group_id
And   user_or_group_type = p_user_or_group_type
And   access_to_table_record_id = p_business_object_id
And   access_to_table_code = p_business_object_type;
--
CURSOR Get_ResourceAccess_csr IS
Select A.CAN_VIEW_FLAG,
   	  A.CAN_CREATE_FLAG,
   	  A.CAN_DELETE_FLAG,
   	  A.CAN_UPDATE_FLAG,
   	  A.CAN_CREATE_DIST_RULE_FLAG,
   	  A.CHL_APPROVER_FLAG,
   	  A.CHL_REQUIRED_FLAG,
   	  A.CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access a
,     jtf_rs_resource_extns r
Where a.user_or_group_id = p_user_or_group_id
And   a.user_or_group_type = G_USER_ARC_TYPE
And   a.access_to_table_record_id = p_business_object_id
And   a.access_to_table_code = p_business_object_type
And   nvl(a.effective_start_date, sysdate-1) < sysdate
And   nvl(a.expiration_date, sysdate+1) > sysdate
And   r.resource_id = a.user_or_group_id
--And   r.active_flag = 'Y'
;
--
CURSOR Get_GroupAccess_csr IS
Select
   A.CAN_VIEW_FLAG,
   A.CAN_CREATE_FLAG,
   A.CAN_DELETE_FLAG,
   A.CAN_UPDATE_FLAG,
   A.CAN_CREATE_DIST_RULE_FLAG,
   A.CHL_APPROVER_FLAG,
   A.CHL_REQUIRED_FLAG,
   A.CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access a,  jtf_rs_groups_vl g
Where a.user_or_group_id = p_user_or_group_id
And   a.user_or_group_type = G_GROUP_ARC_TYPE
And   a.access_to_table_record_id = p_business_object_id
And   a.access_to_table_code = p_business_object_type
And   nvl(a.effective_start_date, sysdate-1) < sysdate
And   nvl(a.expiration_date, sysdate+1) > sysdate
And   g.group_id = a.user_or_group_id
And   nvl(g.start_date_active, sysdate-1) < sysdate
And   nvl(g.end_date_active, sysdate+1) > sysdate;
--
CURSOR Get_AllGroupAccess_csr IS
Select
   A.CAN_VIEW_FLAG,
   A.CAN_CREATE_FLAG,
   A.CAN_DELETE_FLAG,
   A.CAN_UPDATE_FLAG,
   A.CAN_CREATE_DIST_RULE_FLAG,
   A.CHL_APPROVER_FLAG,
   A.CHL_REQUIRED_FLAG,
   A.CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access a, jtf_rs_group_members m
Where a.access_to_table_record_id = p_business_object_id
And   a.access_to_table_code = p_business_object_type
And   a.user_or_group_type = G_GROUP_ARC_TYPE
And   a.user_or_group_id = m.group_id
And   m.resource_id = p_user_or_group_id;
--
CURSOR Get_AllGroupAccess2_csr IS
Select
   A.CAN_VIEW_FLAG,
   A.CAN_CREATE_FLAG,
   A.CAN_DELETE_FLAG,
   A.CAN_UPDATE_FLAG,
   A.CAN_CREATE_DIST_RULE_FLAG,
   A.CHL_APPROVER_FLAG,
   A.CHL_REQUIRED_FLAG,
   A.CHL_REQUIRED_NEED_NOTIF_FLAG
From  amv_u_access a, jtf_rs_group_members m, jtf_rs_groups_vl g
Where a.access_to_table_record_id = p_business_object_id
And   a.access_to_table_code =p_business_object_type
And   nvl(a.effective_start_date, sysdate-1) < sysdate
And   nvl(a.expiration_date, sysdate+1) > sysdate
And   a.user_or_group_type = G_GROUP_ARC_TYPE
And   a.user_or_group_id = m.group_id
And   m.resource_id = p_user_or_group_id
--And   nvl(m.start_date_active, sysdate-1) < sysdate
--And   nvl(m.end_date_active, sysdate+1) > sysdate
And   g.group_id = m.group_id
And   nvl(g.start_date_active, sysdate-1) < sysdate
And   nvl(g.end_date_active, sysdate+1) > sysdate;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_access_flag_obj.CAN_VIEW_FLAG := FND_API.G_FALSE;
    x_access_flag_obj.CAN_CREATE_FLAG := FND_API.G_FALSE;
    x_access_flag_obj.CAN_DELETE_FLAG := FND_API.G_FALSE;
    x_access_flag_obj.CAN_UPDATE_FLAG := FND_API.G_FALSE;
    x_access_flag_obj.CAN_CREATE_DIST_RULE_FLAG := FND_API.G_FALSE;
    x_access_flag_obj.CHL_APPROVER_FLAG := FND_API.G_FALSE;
    x_access_flag_obj.CHL_REQUIRED_FLAG := FND_API.G_FALSE;
    x_access_flag_obj.CHL_REQUIRED_NEED_NOTIF_FLAG := FND_API.G_FALSE;

/*
    x_access_flag_obj := AMV_ACCESS_FLAG_OBJ_TYPE
                         (
                            FND_API.G_FALSE,
                            FND_API.G_FALSE,
                            FND_API.G_FALSE,
                            FND_API.G_FALSE,
                            FND_API.G_FALSE,
                            FND_API.G_FALSE,
                            FND_API.G_FALSE,
                            FND_API.G_FALSE
                         );
*/
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_resource_id => l_current_resource_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Check the effective date for the business object:
    -- Application, channel, category, and item
    IF (p_check_effective_date = FND_API.G_TRUE) THEN
       IF (p_business_object_type = G_ITEM_ARC_TYPE) THEN
          l_start_date := sysdate+1;
          l_end_date := sysdate-1;
          OPEN  Get_ItemEffDate_csr(p_business_object_id);
          FETCH Get_ItemEffDate_csr INTO l_start_date, l_end_date;
          CLOSE Get_ItemEffDate_csr;
          IF (l_start_date > sysdate OR l_end_date < sysdate) THEN
          --Standard call to get message count and if count=1, get the message
              FND_MSG_PUB.Count_And_Get (
                  p_encoded => FND_API.G_FALSE,
                  p_count => x_msg_count,
                  p_data  => x_msg_data
              );
              return;
          END IF;
       ELSIF (p_business_object_type = G_CHAN_ARC_TYPE) THEN
          l_start_date := sysdate+1;
          l_end_date := sysdate-1;
          OPEN  Get_ChannelEffDate_csr(p_business_object_id);
          FETCH Get_ChannelEffDate_csr INTO l_start_date, l_end_date;
          CLOSE Get_ChannelEffDate_csr;
          IF (l_start_date > sysdate OR l_end_date < sysdate) THEN
          --Standard call to get message count and if count=1, get the message
              FND_MSG_PUB.Count_And_Get (
                  p_encoded => FND_API.G_FALSE,
                  p_count => x_msg_count,
                  p_data  => x_msg_data
              );
              return;
          END IF;
       ELSIF (p_business_object_type = G_CATE_ARC_TYPE) THEN
          null; -- There are no effective date in category
       ELSIF (p_business_object_type = G_APPL_ARC_TYPE) THEN
          null; -- There are no effective date in application
       END IF;
    END IF; --IF (p_check_effective_date = FND_API.G_TRUE)
    --
    IF (p_check_effective_date = FND_API.G_TRUE) THEN
       IF (p_user_or_group_type = G_GROUP_ARC_TYPE) THEN
          OPEN  Get_GroupAccess_csr;
          FETCH Get_GroupAccess_csr INTO
                x_access_flag_obj.CAN_VIEW_FLAG,
                x_access_flag_obj.CAN_CREATE_FLAG,
                x_access_flag_obj.CAN_DELETE_FLAG,
                x_access_flag_obj.CAN_UPDATE_FLAG,
                x_access_flag_obj.CAN_CREATE_DIST_RULE_FLAG,
                x_access_flag_obj.CHL_APPROVER_FLAG,
                x_access_flag_obj.CHL_REQUIRED_FLAG,
                x_access_flag_obj.CHL_REQUIRED_NEED_NOTIF_FLAG;
          CLOSE Get_GroupAccess_csr;
       ELSIF (p_user_or_group_type = G_USER_ARC_TYPE) THEN
          OPEN  Get_ResourceAccess_csr;
          FETCH Get_ResourceAccess_csr INTO
                x_access_flag_obj.CAN_VIEW_FLAG,
                x_access_flag_obj.CAN_CREATE_FLAG,
                x_access_flag_obj.CAN_DELETE_FLAG,
                x_access_flag_obj.CAN_UPDATE_FLAG,
                x_access_flag_obj.CAN_CREATE_DIST_RULE_FLAG,
                x_access_flag_obj.CHL_APPROVER_FLAG,
                x_access_flag_obj.CHL_REQUIRED_FLAG,
                x_access_flag_obj.CHL_REQUIRED_NEED_NOTIF_FLAG;
          CLOSE Get_ResourceAccess_csr;
          IF (p_include_group_flag = FND_API.G_TRUE) THEN
             FOR csr1 IN Get_AllGroupAccess2_csr LOOP
                IF (csr1.CAN_VIEW_FLAG = FND_API.G_TRUE) THEN
                    x_access_flag_obj.CAN_VIEW_FLAG := FND_API.G_TRUE;
                END IF;
                IF (csr1.CAN_CREATE_FLAG = FND_API.G_TRUE) THEN
                    x_access_flag_obj.CAN_CREATE_FLAG := FND_API.G_TRUE;
                END IF;
                IF (csr1.CAN_DELETE_FLAG = FND_API.G_TRUE) THEN
                    x_access_flag_obj.CAN_DELETE_FLAG := FND_API.G_TRUE;
                END IF;
                IF (csr1.CAN_UPDATE_FLAG = FND_API.G_TRUE) THEN
                    x_access_flag_obj.CAN_UPDATE_FLAG := FND_API.G_TRUE;
                END IF;
                IF (csr1.CAN_CREATE_DIST_RULE_FLAG = FND_API.G_TRUE) THEN
                    x_access_flag_obj.CAN_CREATE_DIST_RULE_FLAG :=
                       FND_API.G_TRUE;
                END IF;
                IF (csr1.CHL_APPROVER_FLAG = FND_API.G_TRUE) THEN
                    x_access_flag_obj.CHL_APPROVER_FLAG := FND_API.G_TRUE;
                END IF;
                IF (csr1.CHL_REQUIRED_FLAG = FND_API.G_TRUE) THEN
                    x_access_flag_obj.CHL_REQUIRED_FLAG := FND_API.G_TRUE;
                END IF;
                IF (csr1.CHL_REQUIRED_NEED_NOTIF_FLAG = FND_API.G_TRUE) THEN
                    x_access_flag_obj.CHL_REQUIRED_NEED_NOTIF_FLAG :=
                       FND_API.G_TRUE;
                END IF;
             END LOOP;
          END IF; --IF (p_include_group_flag = FND_API.G_TRUE)
       END IF; --ELSIF (p_user_or_group_type = G_USER_ARC_TYPE)
    ELSE
       OPEN  Get_Access_csr;
       FETCH Get_Access_csr INTO
             x_access_flag_obj.CAN_VIEW_FLAG,
             x_access_flag_obj.CAN_CREATE_FLAG,
             x_access_flag_obj.CAN_DELETE_FLAG,
             x_access_flag_obj.CAN_UPDATE_FLAG,
             x_access_flag_obj.CAN_CREATE_DIST_RULE_FLAG,
             x_access_flag_obj.CHL_APPROVER_FLAG,
             x_access_flag_obj.CHL_REQUIRED_FLAG,
             x_access_flag_obj.CHL_REQUIRED_NEED_NOTIF_FLAG;
       CLOSE Get_Access_csr;
       --
       IF (p_user_or_group_type = G_USER_ARC_TYPE AND
          p_include_group_flag  = FND_API.G_TRUE) THEN
          FOR csr1 IN Get_AllGroupAccess_csr LOOP
             IF (csr1.CAN_VIEW_FLAG = FND_API.G_TRUE) THEN
                 x_access_flag_obj.CAN_VIEW_FLAG := FND_API.G_TRUE;
             END IF;
             IF (csr1.CAN_CREATE_FLAG = FND_API.G_TRUE) THEN
                 x_access_flag_obj.CAN_CREATE_FLAG := FND_API.G_TRUE;
             END IF;
             IF (csr1.CAN_DELETE_FLAG = FND_API.G_TRUE) THEN
                 x_access_flag_obj.CAN_DELETE_FLAG := FND_API.G_TRUE;
             END IF;
             IF (csr1.CAN_UPDATE_FLAG = FND_API.G_TRUE) THEN
                 x_access_flag_obj.CAN_UPDATE_FLAG := FND_API.G_TRUE;
             END IF;
             IF (csr1.CAN_CREATE_DIST_RULE_FLAG = FND_API.G_TRUE) THEN
                 x_access_flag_obj.CAN_CREATE_DIST_RULE_FLAG := FND_API.G_TRUE;
             END IF;
             IF (csr1.CHL_APPROVER_FLAG = FND_API.G_TRUE) THEN
                 x_access_flag_obj.CHL_APPROVER_FLAG := FND_API.G_TRUE;
             END IF;
             IF (csr1.CHL_REQUIRED_FLAG = FND_API.G_TRUE) THEN
                 x_access_flag_obj.CHL_REQUIRED_FLAG := FND_API.G_TRUE;
             END IF;
             IF (csr1.CHL_REQUIRED_NEED_NOTIF_FLAG = FND_API.G_TRUE) THEN
                 x_access_flag_obj.CHL_REQUIRED_NEED_NOTIF_FLAG :=
                    FND_API.G_TRUE;
             END IF;
          END LOOP;
       END IF;
    END IF; --IF (p_check_effective_date = FND_API.G_TRUE)
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_BusinessObjectAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_ResourceApplAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_application_id      IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
BEGIN
    Get_BusinessObjectAccess
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_include_group_flag  => p_include_group_flag,
        p_user_or_group_id    => p_resource_id,
        p_user_or_group_type  => G_USER_ARC_TYPE,
        p_business_object_id  => p_application_id,
        p_business_object_type => G_APPL_ARC_TYPE,
        x_access_flag_obj     => x_access_flag_obj
    );

END Get_ResourceApplAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_ResourceChanAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_channel_id          IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
BEGIN
    Get_BusinessObjectAccess
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_include_group_flag  => p_include_group_flag,
        p_user_or_group_id    => p_resource_id,
        p_user_or_group_type  => G_USER_ARC_TYPE,
        p_business_object_id  => p_channel_id,
        p_business_object_type => G_CHAN_ARC_TYPE,
        x_access_flag_obj     => x_access_flag_obj
    );
END Get_ResourceChanAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_ResourceCateAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_category_id         IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
BEGIN
    Get_BusinessObjectAccess
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_include_group_flag  => p_include_group_flag,
        p_user_or_group_id    => p_resource_id,
        p_user_or_group_type  => G_USER_ARC_TYPE,
        p_business_object_id  => p_category_id,
        p_business_object_type => G_CATE_ARC_TYPE,
        x_access_flag_obj     => x_access_flag_obj
    );
END Get_ResourceCateAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_ResourceItemAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_item_id             IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
BEGIN
    Get_BusinessObjectAccess
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_include_group_flag  => p_include_group_flag,
        p_user_or_group_id    => p_resource_id,
        p_user_or_group_type  => G_USER_ARC_TYPE,
        p_business_object_id  => p_item_id,
        p_business_object_type => G_ITEM_ARC_TYPE,
        x_access_flag_obj     => x_access_flag_obj
    );
END Get_ResourceItemAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_GroupApplAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_application_id      IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
BEGIN
    Get_BusinessObjectAccess
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_include_group_flag  => FND_API.G_FALSE,
        p_user_or_group_id    => p_group_id,
        p_user_or_group_type  => G_GROUP_ARC_TYPE,
        p_business_object_id  => p_application_id,
        p_business_object_type => G_APPL_ARC_TYPE,
        x_access_flag_obj     => x_access_flag_obj
    );
END Get_GroupApplAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_GroupChanAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_channel_id          IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
BEGIN
    Get_BusinessObjectAccess
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_include_group_flag  => FND_API.G_FALSE,
        p_user_or_group_id    => p_group_id,
        p_user_or_group_type  => G_GROUP_ARC_TYPE,
        p_business_object_id  => p_channel_id,
        p_business_object_type => G_CHAN_ARC_TYPE,
        x_access_flag_obj     => x_access_flag_obj
    );
END Get_GroupChanAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_GroupCateAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_category_id         IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
BEGIN
    Get_BusinessObjectAccess
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_include_group_flag  => FND_API.G_FALSE,
        p_user_or_group_id    => p_group_id,
        p_user_or_group_type  => G_GROUP_ARC_TYPE,
        p_business_object_id  => p_category_id,
        p_business_object_type => G_CATE_ARC_TYPE,
        x_access_flag_obj     => x_access_flag_obj
    );
END Get_GroupCateAccess;
--------------------------------------------------------------------------------
PROCEDURE Get_ResourceItemAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_item_id             IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY AMV_ACCESS_FLAG_OBJ_TYPE
) AS
BEGIN
    Get_BusinessObjectAccess
    (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_check_login_user    => p_check_login_user,
        p_include_group_flag  => FND_API.G_FALSE,
        p_user_or_group_id    => p_group_id,
        p_user_or_group_type  => G_GROUP_ARC_TYPE,
        p_business_object_id  => p_item_id,
        p_business_object_type => G_ITEM_ARC_TYPE,
        x_access_flag_obj     => x_access_flag_obj
    );
END Get_ResourceItemAccess;
--------------------------------------------------------------------------------
END amv_user_pvt;

/
