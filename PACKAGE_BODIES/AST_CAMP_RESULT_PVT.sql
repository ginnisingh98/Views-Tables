--------------------------------------------------------
--  DDL for Package Body AST_CAMP_RESULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_CAMP_RESULT_PVT" as
/* $Header: astvrclb.pls 115.7 2002/02/06 11:44:16 pkm ship   $ */

-- Start of Comments
-- Package name     : AST_camp_result_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AST_camp_result_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'astvrclb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- FUNCTION to return initialized variables to forms

FUNCTION get_camp_result_rec RETURN ast_camp_result_pvt.camp_result_rec_type IS
  l_variable ast_camp_result_pvt.camp_result_rec_type := ast_camp_result_pvt.g_miss_camp_result_rec;
BEGIN
      return (l_variable);
END;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_camp_result(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_camp_result_Rec            IN   camp_result_Rec_Type  := G_MISS_camp_result_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    )

 IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Create_camp_result';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_return_status_full      VARCHAR2(1);
  l_camp_result_Rec         camp_result_Rec_Type  := p_camp_result_Rec;

  CURSOR cur_source IS
  SELECT source_code_id, source_code, arc_source_code_for, source_code_for_id
  FROM ams_source_codes
  WHERE arc_source_code_for = 'CAMP'
  AND source_code = l_camp_result_Rec.source_code
  AND source_code_for_id = l_camp_result_Rec.object_id;

 BEGIN


      -- Standard Start of API savepoint
      SAVEPOINT CREATE_camp_result_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      OPEN cur_source;
      FETCH cur_source INTO l_camp_result_Rec.source_code_id, l_camp_result_Rec.source_code,
                            l_camp_result_Rec.object_type, l_camp_result_Rec.object_id;
      CLOSE cur_source;

      l_camp_result_Rec.object_version_number := 1.0;

      INSERT INTO jtf_ih_campaigns_results
         (result_id
         ,object_id
         ,object_version_number
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,object_type
         ,source_code_id
         ,source_code)
      VALUES
         (l_camp_result_Rec.result_id
         ,l_camp_result_Rec.object_id
         ,l_camp_result_Rec.object_version_number
         ,l_camp_result_Rec.created_by
         ,l_camp_result_Rec.creation_date
         ,l_camp_result_Rec.last_updated_by
         ,l_camp_result_Rec.last_update_date
         ,l_camp_result_Rec.last_update_login
         ,l_camp_result_Rec.object_type
         ,l_camp_result_Rec.source_code_id
         ,l_camp_result_Rec.source_code
         );

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_camp_result;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_camp_result(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_camp_result_Rec            IN   camp_result_Rec_Type,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    )

IS
 l_api_name                CONSTANT VARCHAR2(30) := 'Delete_camp_result';
 l_api_version_number      CONSTANT NUMBER   := 1.0;
 l_camp_result_Rec        camp_result_Rec_Type := p_camp_result_Rec;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_camp_result_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      DELETE FROM jtf_ih_campaigns_results
      WHERE result_id = l_camp_result_Rec.result_id
      AND source_code = l_camp_result_Rec.source_code
      AND object_id = l_camp_result_Rec.object_id;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'end');



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_camp_result;

End AST_camp_result_PVT;

/
