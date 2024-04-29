--------------------------------------------------------
--  DDL for Package Body ASO_PROJ_COMM_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PROJ_COMM_INT" as
/* $Header: asoipqcb.pls 120.1 2005/06/29 12:34:43 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PROJ_COMM_INT
-- Purpose         :
-- History         :
-- NOTE       :
-- End of Comments

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'ASO_PROJ_COMM_INT';

PROCEDURE Calculate_Proj_Commission (
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Resource_Id                IN    NUMBER       := FND_API.G_MISS_NUM,
    X_Last_Update_Date           OUT NOCOPY /* file.sql.39 change */   DATE,
    X_Object_Version_Number      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS

   l_api_name              CONSTANT VARCHAR2 ( 30 ) := 'Calculate_Proj_Commission';
   l_api_version_number    CONSTANT NUMBER := 1.0;

BEGIN

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard Start of API savepoint
      SAVEPOINT CALCULATE_PROJ_COMMISSION_INT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           1.0,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      ASO_PROJ_COMM_PVT.Calculate_Proj_Commission (
        P_Init_Msg_List              =>     FND_API.G_FALSE,
        P_Commit                     =>     FND_API.G_FALSE,
        P_Qte_Header_Rec             =>     p_qte_header_rec,
        P_Resource_Id                =>     p_resource_id,
        X_Object_Version_Number      =>     x_object_version_number,
        X_Last_Update_Date           =>     x_last_update_date,
        X_Return_Status              =>     x_return_status,
        X_Msg_Count                  =>     x_msg_count,
        X_Msg_Data                   =>     x_msg_data
      );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After ASO_PROJ_COMM_PVT.Calculate_Proj_Commission: '||x_return_status,1,'Y');
END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );


END Calculate_Proj_Commission;


END ASO_PROJ_COMM_INT;

/
