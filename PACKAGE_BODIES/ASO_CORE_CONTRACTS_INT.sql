--------------------------------------------------------
--  DDL for Package Body ASO_CORE_CONTRACTS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CORE_CONTRACTS_INT" AS
/* $Header: asoiokcb.pls 120.1 2005/06/29 12:34:10 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_core_contracts_INT
-- Purpose          :
-- History          :
--    12-03-2002 hyang - bug 2692785, checking running concurrent pricing request.
--    12-12-2002 hyang - bug 2706400, add who column in all update statements
--    10-08-2002 hyang - new contracts integration.
-- NOTE             :
-- End of Comments

  g_pkg_name           CONSTANT VARCHAR2 (30) := 'ASO_core_contracts_INT';
  g_file_name          CONSTANT VARCHAR2 (12) := 'asoiokcb.pls';
  g_login_id                    NUMBER        := fnd_global.conc_login_id;
  g_user_id                     NUMBER        := fnd_global.user_id;


  PROCEDURE quote_is_renewal (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    p_quote_id                  IN       NUMBER,
    x_true_false                OUT NOCOPY /* file.sql.39 change */        VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('quote_is_renewal - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END quote_is_renewal;

  PROCEDURE quote_contract_renewal (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    p_quote_id                  IN       NUMBER,
    x_contract_id               OUT NOCOPY /* file.sql.39 change */        NUMBER
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('quote_contract_renewal - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END quote_contract_renewal;

  PROCEDURE contract_renewal (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    p_contract_id               IN       NUMBER,
    p_start_date                IN       DATE,
    p_end_date                  IN       DATE,
    x_contract_id               OUT NOCOPY /* file.sql.39 change */        NUMBER
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('contract_renewal - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END contract_renewal;

  PROCEDURE quote_contract_is_ordered (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    p_quote_id                  IN       NUMBER,
    x_true_false                OUT NOCOPY /* file.sql.39 change */        VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('quote_contract_is_ordered - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END quote_contract_is_ordered;

  PROCEDURE create_contract (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    p_quote_id                  IN       NUMBER,
    p_template_id               IN       NUMBER,
    x_contract_id               OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_contract_number           OUT NOCOPY /* file.sql.39 change */        VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('create_contract - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END create_contract;


  PROCEDURE create_contract (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_quote_id                  IN       NUMBER,
    p_terms_agreed_flag         IN       VARCHAR2 := fnd_api.g_false,
    p_rel_type                  IN       VARCHAR2,
    p_interaction_subject       IN       VARCHAR2 := fnd_api.g_miss_char,
    p_interaction_body          IN       VARCHAR2 := fnd_api.g_miss_char,
    p_party_id                  IN       NUMBER   := fnd_api.g_miss_num,
    p_resource_id               IN       NUMBER   := fnd_api.g_miss_num,
    p_template_id               IN       NUMBER   := fnd_api.g_miss_num,
    p_template_major_version    IN       NUMBER   := fnd_api.g_miss_num,
    x_contract_id               OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_contract_number           OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('create_contract - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END create_contract;


-- this procedure is used to update a contract from a quote.

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
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('update_contract - Obsolete', 1, 'Y');
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
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2
  ) IS
  BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('notify_contract_change - Obsolete', 1, 'Y');
    END IF;

    NULL;

  END notify_contract_change;


-- vtariker
PROCEDURE Check_Customer_Accounts(
    p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
    p_qte_header_id     IN            NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  )
IS

/******* Stubbing out

**************/
l_api_name              CONSTANT VARCHAR2 ( 50 ) := 'Check_Customer_Accounts';
BEGIN

-- Standard Start of API savepoint
SAVEPOINT Check_Customer_Accounts_INT;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_CORE_CONTRACTS_INT.Check_Customer_Accounts - Begin', 1, 'Y');
END IF;

/************** Replacing with call to moved api ********************/

    ASO_CHECK_TCA_PVT.Check_Customer_Accounts (
      p_init_msg_list              => fnd_api.g_false,
      p_qte_header_id              => p_qte_header_id,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_CORE_CONTRACTS_INT.Check_Customer_Accounts: End ', 1, 'N');
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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Check_Customer_Accounts;
-- vtariker


END aso_core_contracts_int;

/
