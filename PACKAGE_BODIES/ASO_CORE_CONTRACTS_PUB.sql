--------------------------------------------------------
--  DDL for Package Body ASO_CORE_CONTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CORE_CONTRACTS_PUB" AS
/* $Header: asopokcb.pls 120.1 2005/06/29 12:36:59 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_core_contracts_PUB
-- Purpose          :
-- History          :
--    10-08-2002 hyang - new contracts integration.
-- NOTE             :
-- End of Comments

  g_pkg_name           CONSTANT VARCHAR2 (30) := 'ASO_core_contracts_PUB';
  g_file_name          CONSTANT VARCHAR2 (12) := 'asopokcb.pls';
  g_login_id                    NUMBER := fnd_global.conc_login_id;

  PROCEDURE create_contract (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_quote_id                  IN       NUMBER,
    p_terms_agreed_flag         IN       VARCHAR2 := fnd_api.g_false,
    p_rel_type                  IN       VARCHAR2 := fnd_api.g_miss_char,
    p_interaction_subject       IN       VARCHAR2 := fnd_api.g_miss_char,
    p_interaction_body          IN       VARCHAR2 := fnd_api.g_miss_char,
    p_party_id                  IN       NUMBER   := fnd_api.g_miss_num,
    p_resource_id               IN       NUMBER   := fnd_api.g_miss_num,
    p_template_id               IN       NUMBER   := fnd_api.g_miss_num,
    p_template_major_version    IN       NUMBER   := fnd_api.g_miss_num,
    x_contract_id               OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_contract_number           OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('create_contract PUB - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END create_contract;

  PROCEDURE update_contract (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_quote_id                  IN       NUMBER,
    p_contract_id               IN       NUMBER   := fnd_api.g_miss_num,
    p_interaction_subject       IN       VARCHAR2 := fnd_api.g_miss_char,
    p_interaction_body          IN       VARCHAR2 := fnd_api.g_miss_char,
    p_party_id                  IN       NUMBER   := fnd_api.g_miss_num,
    p_resource_id               IN       NUMBER   := fnd_api.g_miss_num,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('update_contract PUB - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END update_contract;

  PROCEDURE notify_contract_change (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_quote_id                  IN       NUMBER,
    p_notification_type         IN       VARCHAR2,
    p_customer_comments         IN       VARCHAR2 := fnd_api.g_miss_char,
    p_salesrep_email_id         IN       VARCHAR2 := fnd_api.g_miss_char,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('notify_contract_change PUB - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END notify_contract_change;

-- vtariker
PROCEDURE Check_Customer_Accounts(
    p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
    p_qte_header_id     IN            NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
IS

l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'Check_Customer_Accounts';

BEGIN

-- Standard Start of API savepoint
SAVEPOINT Check_Customer_Accounts_PUB;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
END IF;

-- initialize G_Debug_Flag
ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts PUB - Begin', 1, 'Y');
END IF;

    -- check for missing customer accounts in the quote
    aso_core_contracts_int.check_customer_accounts (
      p_init_msg_list              => p_init_msg_list,
      p_qte_header_id              => p_qte_header_id,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Create_Contract: After Check_Customer_Accounts: x_return_status: '|| x_return_status,
        1,
        'Y'
      );
    END IF;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Check_Customer_Accounts PUB : End ', 1, 'N');
END IF;

   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Check_Customer_Accounts;
-- vtariker

END aso_core_contracts_pub;

/
