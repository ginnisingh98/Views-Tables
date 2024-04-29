--------------------------------------------------------
--  DDL for Package Body AS_LEAD_ROUTING_WF_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LEAD_ROUTING_WF_CUHK" AS
/* $Header: asxcldob.pls 115.7 2003/01/22 03:12:05 solin ship $ */

-- Start of Comments
-- Package Name     : AS_LEAD_ROUTING_WF_CUHK
-- Purpose          : This file is customizable for Oracle customers to
--                    add logic to get owner of the lead.
-- NOTE             :
-- History          :
--       12/06/2001   SOLIN   Created
--                    This is sample package body. This file should be
--                    provided by Oracle's customer.
--       12/08/2001   SOLIN, bug 2137318.
--                    Customize for Oracle internal.
--       11/19/2002   SOLIN, Bug 2629604.
--                    The resource from territory API will have higher
--                    precedence to be lead owner
--       12/23/2002   SOLIN  Bug 2724757
--                    Incorrect lead owner due to extra resources
--                    by build_lead_sales_team and rebuild_lead_sales_team.
-- End of Comments

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_LEAD_ROUTING_WF_CUHK';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxcldob.pls';

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE ROUTINES
 |
 *-------------------------------------------------------------------------*/

-- Start of Comments
--
--   API name   : Get_Owner_Pre
--   Parameters :
--   IN         :
--       p_api_version_number:
--       p_init_msg_list     :
--       p_validation_level  :
--       p_commit            :
--                             The above four parameters are standard input.
--       p_resource_id_tbl   :
--       p_group_id_tbl      :
--       p_person_id_tbl     :
--                             The above three parameters store the available
--                             resources for this customized package to decide
--                             owner of the sales lead. Their datatype is
--                             TABLE of NUMBERs.
--       p_resource_flag_tbl :
--                             This parameter specify the source of the
--                             resource.
--                             'D': This is default resource, comes from the
--                                  profile AS_DEFAULT_RESOURCE_ID, "OS:
--                                  Default Resource ID used for Sales Lead
--                                  Assignment"
--                             'L': This is login user.
--                             'T': This resource comes from territory
--                                  definition.
--       p_sales_lead_rec    :
--                             This is the whole definition of the sales lead.
--                             This record is provided to help Oracle customer
--                             decide sales lead owner.
--   OUT        :
--       x_resource_id       :
--       x_group_id          :
--       x_person_id         :
--                             The above three parameters store the result
--                             of this user hook. It will be set as sales
--                             lead owner. If x_resource_id is NULL, owner
--                             will be decided based upon Oracle's logic.
--       x_return_status     :
--       x_msg_count         :
--       x_msg_data          :
--                             The above three parameters are standard output.
--
PROCEDURE Get_Owner_Pre(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_resource_id_tbl       IN  AS_LEAD_ROUTING_WF.NUMBER_TABLE,
    p_group_id_tbl          IN  AS_LEAD_ROUTING_WF.NUMBER_TABLE,
    p_person_id_tbl         IN  AS_LEAD_ROUTING_WF.NUMBER_TABLE,
    p_resource_flag_tbl     IN  AS_LEAD_ROUTING_WF.FLAG_TABLE,
    p_sales_lead_rec        IN  AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type,
    x_resource_id           OUT NOCOPY NUMBER,
    x_group_id              OUT NOCOPY NUMBER,
    x_person_id             OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
    )
 IS
    CURSOR c_get_terr_resource1(c_sales_lead_id NUMBER, c_party_id NUMBER,
                                c_party_site_id NUMBER, c_lead VARCHAR2,
                                c_account VARCHAR2) IS
      SELECT acc.salesforce_id, acc.sales_group_id
      FROM as_accesses_all acc, as_territory_accesses terracc,
           jtf_terr_rsc_all terrrsc
      WHERE acc.sales_lead_id = c_sales_lead_id
      AND acc.created_by_tap_flag = 'Y'
      AND acc.access_id = terracc.access_id
      AND terracc.territory_id = terrrsc.terr_id
      AND terrrsc.resource_id = acc.salesforce_id
      AND terrrsc.role = 'TELESALES_AGENT'
      ORDER BY acc.access_id;

    CURSOR c_get_terr_resource2(c_sales_lead_id NUMBER, c_party_id NUMBER,
                                c_party_site_id NUMBER, c_lead VARCHAR2,
                                c_account VARCHAR2) IS
      SELECT acc.salesforce_id, acc.sales_group_id
      FROM as_accesses_all acc
      WHERE acc.sales_lead_id = c_sales_lead_id
      AND acc.created_by_tap_flag = 'Y'
      ORDER BY acc.access_id;

    -- A resource may not be in any group. Besides, jtf_rs_group_members
    -- may not have person_id for all resources. Therefore, get person_id
    -- is this cursor.
    CURSOR c_get_person_id(c_resource_id NUMBER) IS
      SELECT res.source_id
      FROM jtf_rs_resource_extns res
      WHERE res.resource_id = c_resource_id;

    CURSOR C_Get_Lead_Info(C_Sales_Lead_Id NUMBER) IS
      SELECT SL.CUSTOMER_ID, SL.ADDRESS_ID
      FROM AS_SALES_LEADS SL
      WHERE SL.SALES_LEAD_ID = C_Sales_Lead_Id;

    l_api_name                  CONSTANT VARCHAR2(30)
                                := 'Get_Owner_Pre';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_resource_id               NUMBER := NULL;
    l_group_id                  NUMBER;
    l_person_id                 NUMBER;
    l_customer_id               NUMBER;
    l_address_id                NUMBER;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_OWNER_PRE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT:' || l_api_name || ' Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- For Oracle internal use, p_resource_id_tbl, p_person_id_tbl,
      -- p_group_id_tbl, p_resource_flag_tbl are all NULL. p_sales_lead_rec
      -- has sales_lead_id populated only, other columns are all g_miss.

      OPEN C_Get_Lead_Info(p_sales_lead_rec.sales_lead_id);
      FETCH C_Get_Lead_Info INTO l_customer_id, l_address_id;
      CLOSE C_Get_Lead_Info;

      -- Get the first resource with TELESALES_AGENT role
      OPEN c_get_terr_resource1(p_sales_lead_rec.sales_lead_id,
                                l_customer_id, l_address_id, 'LEAD',
                                'ACCOUNT');
      FETCH c_get_terr_resource1 INTO l_resource_id, l_group_id;
      CLOSE c_get_terr_resource1;

      IF l_resource_id IS NULL
      THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'There''s no Telesales Agent');
          OPEN c_get_terr_resource2(p_sales_lead_rec.sales_lead_id,
                                    l_customer_id, l_address_id, 'LEAD',
                                    'ACCOUNT');
          FETCH c_get_terr_resource2 INTO l_resource_id, l_group_id;
          CLOSE c_get_terr_resource2;
      END IF;

      IF l_resource_id IS NOT NULL
      THEN
          OPEN c_get_person_id(l_resource_id);
          FETCH c_get_person_id INTO l_person_id;
          CLOSE c_get_person_id;

          x_resource_id := l_resource_id;
          x_group_id := l_group_id;
          x_person_id := l_person_id;
      ELSE
          -- There's no resource found, return NULL.
          -- Sales lead assignment API will pick owner from profile,
          -- or current user.
          x_resource_id := NULL;
      END IF;

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Get_Owner_Pre;


END AS_LEAD_ROUTING_WF_CUHK;


/
