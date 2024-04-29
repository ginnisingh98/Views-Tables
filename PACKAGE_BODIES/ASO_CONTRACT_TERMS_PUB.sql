--------------------------------------------------------
--  DDL for Package Body ASO_CONTRACT_TERMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CONTRACT_TERMS_PUB" AS
/* $Header: asopktcb.pls 120.1 2005/06/29 12:36:53 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_Contract_Terms_PUB
-- Purpose          :
-- History          :
--    10-29-2002 hyang - created
-- NOTE             :
-- End of Comments

  g_pkg_name           CONSTANT VARCHAR2 (30) := 'ASO_Contract_Terms_PUB';
  g_file_name          CONSTANT VARCHAR2 (12) := 'asopktcb.pls';

  PROCEDURE Get_Article_Variable_Values (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_sys_var_value_tbl         IN OUT NOCOPY /* file.sql.39 change */    OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(45) := 'Get_Article_Variable_Values';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Get_Article_Variable_PUB;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize G_Debug_Flag
    ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Get_Article_Variable_Values PUB - Begin', 1, 'Y');
    END IF;

    -- check for missing customer accounts in the quote
    ASO_Contract_Terms_Int.Get_Article_Variable_Values (
      p_api_version                 => 1.0,
      p_init_msg_list               => p_init_msg_list,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data,
      p_doc_id                      => p_doc_id,
      p_sys_var_value_tbl           => p_sys_var_value_tbl
    );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Get_Article_Variable_Values: After Get_Article_Variable_Values: x_return_status: '|| x_return_status,
        1,
        'Y'
      );
    END IF;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Get_Article_Variable_Values PUB : End ', 1, 'N');
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count          =>   x_msg_count,
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

  END Get_Article_Variable_Values;

  PROCEDURE Get_Line_Variable_Values (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_variables_tbl             IN        OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
    x_line_var_value_tbl        OUT NOCOPY /* file.sql.39 change */       OKC_TERMS_UTIL_GRP.item_dtl_tbl
  ) IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(45) := 'Get_Line_Variable_Values';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Get_Line_Variable_Values_PUB;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize G_Debug_Flag
    ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Get_Line_Variable_Values PUB - Begin', 1, 'Y');
    END IF;

    -- check for missing customer accounts in the quote
    ASO_Contract_Terms_Int.Get_Line_Variable_Values (
      p_api_version                 => 1.0,
      p_init_msg_list               => p_init_msg_list,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data,
      p_doc_id                      => p_doc_id,
      p_variables_tbl               => p_variables_tbl,
      x_line_var_value_tbl          => x_line_var_value_tbl
    );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Get_Line_Variable_Values: After Get_Line_Variable_Values: x_return_status: '|| x_return_status,
        1,
        'Y'
      );
    END IF;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Get_Line_Variable_Values PUB : End ', 1, 'N');
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count          =>   x_msg_count,
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

  END Get_Line_Variable_Values;

  FUNCTION OK_To_Commit (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_doc_type                  IN        VARCHAR2 := 'QUOTE',
    p_validation_string         IN        VARCHAR2
  ) RETURN VARCHAR2 IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(45) := 'OK_To_Commit';
    l_return      VARCHAR2 (1)    := FND_API.G_TRUE;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT OK_To_Commit_PUB;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize G_Debug_Flag
    ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('OK_To_Commit PUB - Begin', 1, 'Y');
    END IF;

    -- check for missing customer accounts in the quote
    l_return := ASO_Contract_Terms_Int.OK_To_Commit (
      p_api_version                 => 1.0,
      p_init_msg_list               => p_init_msg_list,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data,
      p_doc_id                      => p_doc_id,
      p_doc_type                    => p_doc_type,
      p_validation_string           => p_validation_string
    );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'OK_To_Commit: After OK_To_Commit: x_return_status: '|| x_return_status,
        1,
        'Y'
      );
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('OK_To_Commit PUB : End ', 1, 'N');
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
    );

  RETURN l_return;
  END OK_To_Commit;


END ASO_Contract_Terms_PUB;

/
