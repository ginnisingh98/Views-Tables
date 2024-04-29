--------------------------------------------------------
--  DDL for Package Body JTF_UM_ROLE_VERIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_ROLE_VERIFICATION" as
/* $Header: JTFUMRVB.pls 115.3 2002/11/21 22:58:10 kching ship $ */
-- Start of Comments
-- Package name     : JTF_UM_ROLE_VERIFICATION
-- Purpose          : verify if given role exists in UM and updating principal_id.
-- History          :


-- package level variables
G_PKG_NAME CONSTANT VARCHAR2(30):= 'JTF_UM_ROLE_VERIFICATION';

/**
 * Procedure   :  UPDATE_AUTH_PRINCIPAL_ID
 * Type        :  Private
 * Pre_reqs    :
 * Description : Updates the existing UM records with the old_auth_principal_id to
 *                     the new_auth_principal_id
 * Parameters
 * input parameters : old_auth_principal_id number
 *                            new_auth_principal_id number
 * Other Comments :
 */
  procedure UPDATE_AUTH_PRINCIPAL_ID(old_auth_principal_id  in number,
                                     new_auth_principal_id in number  ) IS
  BEGIN
    update jtf_um_subscriptions_b
    set AUTH_DELEGATION_ROLE_ID = new_auth_principal_id
    where AUTH_DELEGATION_ROLE_ID = old_auth_principal_id;
  END;

/**
 * Procedure   :  IS_AUTH_PRINCIPAL_REFERRED
 * Type        :  Private
 * Pre_reqs    :
 * Description : Looks for existence of input auth_principal_id or auth_principal_name in
 *                    UM tables and if so, returns "E" in x_return_status with appropriate message that the
 *                    role cannot be deleted. If the principal does not exist anywhere in the usertype/enrollments,
 *                    returns "S" in the parameter x_return_status
 * Parameters
 * input parameters :  auth_principal_name varchar2
 * output parameters : x_return_status varchar2
 * Errors      :  If the principal exists in UM, sends appropriate message back as part of
 *                error stack
 * Other Comments :
 */
  procedure IS_AUTH_PRINCIPAL_REFERRED(
                 auth_principal_name      in  varchar2,
              --   x_if_referred_flag       out NOCOPY varchar2,
                 x_return_status          out NOCOPY varchar2,
                 x_msg_count              out NOCOPY number,
                 x_msg_data               out NOCOPY varchar2
                 ) IS
  l_api_name            VARCHAR2(50) := 'IS_AUTH_PRINCIPAL_REFERRED';
  l_count               NUMBER        := 0;
  l_usertype_key       VARCHAR2(30);
  l_enrollment_key     VARCHAR2(30);

  BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize the flag to value 'N' which means that the principal
    -- passed in is not referred by any of UM columns
    -- x_if_referred_flag := 'N';

    -- Standard Start of API savepoint
    SAVEPOINT IS_AUTH_PRINCIPAL_REFERRED;

    -- Initialize message list -- if p_init_msg_list is set to TRUE.
    FND_MSG_PUB.initialize;

    -- Validate required fields for not null values
    if (auth_principal_name is null) then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTA_UM_REQUIRED_FIELD');
            --FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME, FALSE);
            FND_MESSAGE.Set_Token('API_NAME', 'IS_AUTH_PRINCIPAL_REFERRED', FALSE);
            FND_MESSAGE.Set_Token('FIELD', 'auth_principal_name', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     end if;

    -- business logic starts

    -- verify to see if the auth_principal_name passed as input is assigned to any usertype
    select count(*) into l_count
    from jtf_um_usertype_role a, jtf_um_usertypes_b b
    where a.principal_name = auth_principal_name
    and a.usertype_id = b.usertype_id
    and a.effective_end_date is null
    and b.effective_end_date is null;

    IF( l_count <> 0 ) THEN
      -- set the flag that this principal_name is being referred
      -- x_if_referred_flag := 'Y';

      -- need to find usertype where the role is used
      select usertype_key into l_usertype_key
      from jtf_um_usertypes_b a, jtf_um_usertype_role b
      where b.principal_name = auth_principal_name
      and a.usertype_id = b.usertype_id
      and a.effective_end_date is null
      and b.effective_end_date is null
      and rownum = 1;

      -- throw exception for the usertype found
      FND_MESSAGE.Set_Name('JTF', 'JTA_UM_USERTYPE_ROLE');
      FND_MESSAGE.Set_Token('PRINCIPAL_NAME', auth_principal_name , FALSE);
      FND_MESSAGE.Set_Token('USERTYPE_NAME', l_usertype_key , FALSE);

      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- verify to see if the auth_principal_name passed as input is assigned to any enrollment
    select count(*) into l_count
    from jtf_um_subscription_role a, jtf_um_subscriptions_b b
    where a.principal_name = auth_principal_name
    and a.subscription_id = b.subscription_id
    and a.effective_end_date is null
    and b.effective_end_date is null;


    IF( l_count <> 0 ) THEN
      -- set the flag that this principal_name is being referred
      -- x_if_referred_flag := 'Y';

      -- need to find usertype where the role is used
      select subscription_key into l_enrollment_key
      from jtf_um_subscriptions_b a, jtf_um_subscription_role b
      where b.principal_name = auth_principal_name
      and a.subscription_id = b.subscription_id
      and a.effective_end_date is null
      and b.effective_end_date is null
      and rownum = 1;

      -- throw exception for the enrollment found
      FND_MESSAGE.Set_Name('JTF', 'JTA_UM_ENROLLMENT_ROLE');
      FND_MESSAGE.Set_Token('PRINCIPAL_NAME', auth_principal_name , FALSE);
      FND_MESSAGE.Set_Token('ENROLLMENT_NAME', l_enrollment_key , FALSE);

      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- verify to see if the auth_principal_name passed as input is assigned to any enrollment as delegation role
    select count(*) into l_count
    from jtf_auth_principals_b a, jtf_um_subscriptions_b b
    where a.principal_name = auth_principal_name
    and a.JTF_AUTH_PRINCIPAL_ID = b.AUTH_DELEGATION_ROLE_ID
    and b.effective_end_date is null;


    IF( l_count <> 0 ) THEN

      -- need to find enrollment where the role is used
      select subscription_key into l_enrollment_key
      from jtf_um_subscriptions_b a, jtf_auth_principals_b b
      where b.principal_name = auth_principal_name
      and b.JTF_AUTH_PRINCIPAL_ID = a.AUTH_DELEGATION_ROLE_ID
      and a.effective_end_date is null
      and rownum = 1;

      -- throw exception for the enrollment found
      FND_MESSAGE.Set_Name('JTF', 'JTA_UM_ENROLLMENT_ROLE');
      FND_MESSAGE.Set_Token('PRINCIPAL_NAME', auth_principal_name , FALSE);
      FND_MESSAGE.Set_Token('ENROLLMENT_NAME', l_enrollment_key , FALSE);

      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --

    -- business logic ends

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data  => x_msg_data);

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN OTHERS THEN
          JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  END;

END;

/
