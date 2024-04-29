--------------------------------------------------------
--  DDL for Package Body AST_SEARCH_RESULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_SEARCH_RESULT_PVT" AS
/* $Header: astlsgnb.pls 115.4 2002/02/06 11:20:24 pkm ship      $ */

-- Start of Comments - astlsgnb.pls
-- Package name     : AST_SEARCH_RESULT_PVT
-- Purpose          : Create_search_result saves the results of mass selection
--                    Get_search_result out put the results
-- History          : 8/11/2000 Julian Wang Created
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AST_SEARCH_RESULT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'astlsgnb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- FUNCTION to return initialized variables to forms

FUNCTION get_search_result_rec RETURN AST_SEARCH_RESULT_PVT.SEARCH_RESULT_REC_TYPE IS
l_variable ast_search_result_pvt.search_result_rec_type
   := ast_search_result_pvt.g_miss_search_result_rec;
BEGIN
      return (l_variable);
END;

-- Hint: Primary key needs to be returned.

PROCEDURE Create_search_result(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_search_result_Rec          IN   search_result_Rec_Type  := G_MISS_search_result_REC,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    )

 IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Create_search_result';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_return_status_full      VARCHAR2(1);
  l_search_result_Rec       search_result_Rec_Type  := p_search_result_Rec;

  l_count                   number;
  x                         number;
  BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_search_result_PVT;

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
      x := 0;
      IF GLB_SEARCH_RESULT_TBL.COUNT = 0 THEN
         x := x + 1;
      ELSE
      	 x := glb_search_result_tbl.count + 1;
      END IF;

      glb_search_result_tbl(x).created_by := P_search_result_Rec.created_by;
      glb_search_result_tbl(x).creation_date := P_search_result_Rec.creation_date;
      glb_search_result_tbl(x).last_updated_by := P_search_result_Rec.last_updated_by;
      glb_search_result_tbl(x).last_update_date := P_search_result_Rec.last_update_date;
      glb_search_result_tbl(x).last_update_login := P_search_result_Rec.last_update_login;
      glb_search_result_tbl(x).primary_id := P_search_result_Rec.primary_id;
      glb_search_result_tbl(x).secondary_id := P_search_result_Rec.secondary_id;

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
End Create_search_result;

PROCEDURE GET_SEARCH_RESULT(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER
                               := FND_API.G_VALID_LEVEL_FULL,
    p_count                    IN   NUMBER,
    x_Search_Result_Rec        OUT   SEARCH_RESULT_REC_TYPE,
    X_Return_Status            OUT  VARCHAR2,
    X_Msg_Count                OUT  NUMBER,
    X_Msg_Data                 OUT  VARCHAR2
    )
 IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Get_search_result';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_return_status_full      VARCHAR2(1);
  l_search_result_Rec       search_result_Rec_Type;

  l_count                   number;
  x                         number;
  BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Get_search_result_PVT;

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

      x_search_result_Rec.created_by := glb_search_result_tbl(p_count).created_by;
      x_search_result_Rec.creation_date := glb_search_result_tbl(p_count).creation_date;
      x_search_result_Rec.last_updated_by := glb_search_result_tbl(p_count).last_updated_by;
      x_search_result_Rec.last_update_date := glb_search_result_tbl(p_count).last_update_date;
      x_search_result_Rec.last_update_login := glb_search_result_tbl(p_count).last_update_login;
      x_search_result_Rec.primary_id := glb_search_result_tbl(p_count).primary_id;
      x_search_result_Rec.secondary_id := glb_search_result_tbl(p_count).secondary_id;

      glb_search_result_tbl.delete(p_count);

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
End Get_search_result;

PROCEDURE DELETE_SEARCH_RESULT(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER
                               := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status            OUT  VARCHAR2,
    X_Msg_Count                OUT  NUMBER,
    X_Msg_Data                 OUT  VARCHAR2
    )
 IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Get_search_result';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_return_status_full      VARCHAR2(1);

  l_count                   number;
  x                         number;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Get_search_result_PVT;

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
      IF GLB_SEARCH_RESULT_TBL.COUNT > 0 THEN

      FOR i IN 1 .. GLB_SEARCH_RESULT_TBL.COUNT LOOP
          glb_search_result_tbl.delete(i);
      END LOOP;

      END IF;
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
END;

PROCEDURE add_party_id(
  p_api_version         IN NUMBER := 1.0,
  p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT VARCHAR2,
  x_msg_count           OUT NUMBER,
  x_msg_data            OUT VARCHAR2,
  p_search_type         IN VARCHAR2,
  p_party_id_tbl        IN party_id_tbl,
  x_glb_count           OUT NUMBER
)
AS

  l_api_name            CONSTANT VARCHAR2(30) := 'Add_Party_Id';
  l_api_version         CONSTANT NUMBER := 1.0;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(32767);

   g_count  INTEGER;
   l_count  INTEGER;
   x        INTEGER;
   y        INTEGER;   -- For testing

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT     AST_Add_Party_Id;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
/*
  l_count := p_party_id_tbl.COUNT;
  g_count := glb_party_id_tbl.COUNT + p_party_id_tbl.COUNT;

  IF glb_party_id_tbl.COUNT = 0 THEN
     x := 0;
     FOR i IN 1..l_count LOOP
         x := x + 1;
         glb_party_id_tbl(x)      := p_party_id_tbl(i);
     END LOOP;
  ELSE
     x := glb_party_id_tbl.COUNT;
     FOR i IN 1..l_count LOOP
         x := x + 1;
         glb_party_id_tbl(x)      := p_party_id_tbl(i);
     END LOOP;
  END IF;

  x_glb_count := g_count;

  -- End of API body
*/
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

END;

PROCEDURE get_party_id(
  p_api_version          IN NUMBER := 1.0,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT VARCHAR2,
  x_msg_count            OUT NUMBER,
  x_msg_data             OUT VARCHAR2,
  p_search_type          IN VARCHAR2,
  x_party_id_tbl         OUT party_id_tbl,
  x_glb_count            OUT NUMBER
) AS
  l_api_name             CONSTANT VARCHAR2(30) := 'Get_Party_Id';
  l_api_version          CONSTANT NUMBER := 1.0;
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(32767);

  x                      INTEGER;
  y                      INTEGER;   -- For testing
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT     AST_Get_Party_Id;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  x := 0;
  FOR i IN 1..glb_party_id_tbl.COUNT LOOP
    x := x + 1;
    x_party_id_tbl(x) := glb_party_id_tbl(i);
  END LOOP;

  FOR i IN 1..glb_party_id_tbl.COUNT LOOP
    glb_party_id_tbl.DELETE(i);
  END LOOP;

  x_glb_count := x;
  -- End of API body

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
END;

End AST_SEARCH_RESULT_PVT;

/
