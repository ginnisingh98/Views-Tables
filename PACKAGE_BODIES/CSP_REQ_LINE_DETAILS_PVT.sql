--------------------------------------------------------
--  DDL for Package Body CSP_REQ_LINE_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQ_LINE_DETAILS_PVT" as
/* $Header: cspvrldb.pls 120.0 2005/05/24 18:11:55 appldev noship $ */
-- Start of Comments
-- Package name     : CSP_Req_Line_details_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_Req_Line_Details_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvrldb.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_req_line_Details(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Req_Line_Details_Tbl       IN   Req_Line_Details_Tbl_Type  := G_MISS_Req_Line_Details_Tbl,
    x_Req_Line_Details_tbl       OUT NOCOPY Req_Line_Details_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_req_line_details';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);

l_req_line_Details_Rec      Req_Line_Details_Rec_Type;
l_req_line_details_id       NUMBER;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Req_Line_Details_PUB;

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
    -- JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Invoke table handler(CSP_REQUIREMENT_LINES_PKG.Insert_Row)
      FOR I IN 1..P_Req_Line_Details_Tbl.COUNT LOOP

        l_req_line_details_rec := P_Req_Line_Details_Tbl(I);

        CSP_req_line_details_PKG.Insert_Row(
          px_REQ_LINE_DETAIL_ID  => l_req_line_details_rec.req_line_detail_id,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUIREMENT_LINE_ID  => l_Req_Line_details_rec.REQUIREMENT_LINE_ID,
          p_SOURCE_TYPE  => l_Req_Line_details_rec.SOURCE_TYPE,
          p_SOURCE_ID  => l_Req_Line_details_rec.source_id
          );

      -- Hint: Primary key should be returned.
         x_REQ_Line_Details_Tbl(I) := l_req_line_details_rec;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;
      --
      -- End of API body
      --

      -- Standard check for p_commit
   /*   IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
*/

      -- Debug Message
     -- JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
    /*  FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      ); */

      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN OTHERS THEN
          Rollback to CREATE_Req_line_details_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Create_req_line_details;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_req_line_details(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Req_Line_Details_Tbl       IN   Req_Line_Details_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_req_line_details';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_Req_Line_Details_rec    CSP_req_line_Details_PVT.Req_Line_Details_Rec_Type;
--l_tar_Requirement_Line_rec  CSP_requirement_lines_PVT.Requirement_Line_Rec_Type := P_Requirement_Line_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Req_Line_Details_PUB;

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
     --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Invoke table handler(CSP_REQUIREMENT_LINES_PKG.Update_Row)
      FOR I IN 1..P_Req_Line_Details_Tbl.COUNT LOOP
        l_req_line_details_rec := p_req_line_details_tbl(I);

        CSP_REQ_LINE_DETAILS_PKG.Update_Row(
          px_REQ_LINE_DETAIL_ID  => l_req_line_details_rec.REQ_LINE_DETAIL_ID,
          p_REQUIREMENT_LINE_ID  => l_req_line_details_rec.REQUIREMENT_LINE_ID,
          p_CREATED_BY     => FND_API.G_MISS_NUM,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_SOURCE_TYPE  => l_req_line_details_rec.SOURCE_TYPE,
          p_SOURCE_ID  => l_req_line_details_rec.SOURCE_ID
          );

      END LOOP;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN OTHERS THEN
          Rollback to UPDATE_Req_Line_Details_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Update_req_line_details;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_req_line_details(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_req_line_details_tbl       IN   Req_Line_Details_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
 l_api_name                CONSTANT VARCHAR2(30) := 'Delete_req_line_details';
 l_api_version_number      CONSTANT NUMBER   := 1.0;
 l_req_line_details_rec    Req_Line_Details_Rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Req_Line_Details_PUB;

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
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');

      -- Invoke table handler(CSP_REQUIREMENT_LINES_PKG.Delete_Row)
      FOR I IN 1..P_Req_Line_Details_Tbl.COUNT LOOP
        l_req_line_details_rec := p_req_Line_Details_Tbl(I);

        CSP_REQ_LINE_DETAILS_PKG.Delete_Row(
          px_REQ_LINE_DETAIL_ID  => l_req_line_details_rec.REQ_LINE_DETAIL_ID);

      END LOOP;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN OTHERS THEN
          Rollback to DELETE_Req_Line_Details_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Delete_req_line_details;

End CSP_Req_Line_Details_PVT;


/
