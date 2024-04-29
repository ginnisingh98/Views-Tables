--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_HEADERS_PVT" as
/* $Header: cspvrqhb.pls 120.0.12010000.3 2012/02/13 07:30:37 htank ship $ */
-- Start of Comments
-- Package name     : CSP_Requirement_headers_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_Requirement_headers_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvrqhb.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REQUIREMENT_HEADER_Rec     IN    REQUIREMENT_HEADER_Rec_Type  := G_MISS_REQUIREMENT_HEADER_REC,
    X_REQUIREMENT_HEADER_ID      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
 l_api_name                CONSTANT VARCHAR2(30) := 'Create_requirement_headers';
 l_api_version_number      CONSTANT NUMBER   := 1.0;
 l_return_status_full        VARCHAR2(1);
 l_access_flag               VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Requirement_headers_PUB;

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

      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
  /*    IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/

/*      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          JTF_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             --,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             --,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
   */
      -- Debug message
      --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_requirement_headers');

      -- Invoke validation procedures
  /*    Validate_requirement_headers(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => JTF_UTILITY_PVT.G_CREATE,
          P_REQUIREMENT_HEADER_Rec  =>  P_REQUIREMENT_HEADER_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
      -- Debug Message
      --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');

      x_requirement_header_id := p_requirement_header_rec.requirement_header_id;

      -- Invoke table handler(CSP_REQUIREMENT_HEADERS_PKG.Insert_Row)
      CSP_REQUIREMENT_HEADERS_PKG.Insert_Row(
          px_REQUIREMENT_HEADER_ID  => x_REQUIREMENT_HEADER_ID,
          p_CREATED_BY  => nvl(FND_GLOBAL.USER_ID, 1),
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => nvl(FND_GLOBAL.USER_ID, 1),
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => nvl(FND_GLOBAL.CONC_LOGIN_ID, -1),
          p_OPEN_REQUIREMENT  => p_REQUIREMENT_HEADER_rec.OPEN_REQUIREMENT,
          p_SHIP_TO_LOCATION_ID  => p_REQUIREMENT_HEADER_rec.SHIP_TO_LOCATION_ID,
          p_TASK_ID  => p_REQUIREMENT_HEADER_rec.TASK_ID,
          p_TASK_ASSIGNMENT_ID  => p_REQUIREMENT_HEADER_rec.TASK_ASSIGNMENT_ID,
          p_SHIPPING_METHOD_CODE  => p_REQUIREMENT_HEADER_rec.SHIPPING_METHOD_CODE,
          p_NEED_BY_DATE  => p_REQUIREMENT_HEADER_rec.NEED_BY_DATE,
          p_DESTINATION_ORGANIZATION_ID  => p_REQUIREMENT_HEADER_rec.DESTINATION_ORGANIZATION_ID,
          p_PARTS_DEFINED  => p_REQUIREMENT_HEADER_rec.PARTS_DEFINED,
          p_ATTRIBUTE_CATEGORY  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE15,
          p_ORDER_TYPE_ID => p_REQUIREMENT_HEADER_rec.ORDER_TYPE_ID,
          p_ADDRESS_TYPE => p_REQUIREMENT_HEADER_rec.ADDRESS_TYPE,
          p_RESOURCE_ID => p_REQUIREMENT_HEADER_rec.RESOURCE_ID,
          p_RESOURCE_TYPE => p_REQUIREMENT_HEADER_rec.RESOURCE_TYPE,
          p_TIMEZONE_ID => p_REQUIREMENT_HEADER_rec.TIMEZONE_ID,
          p_SHIP_TO_CONTACT_ID => p_REQUIREMENT_HEADER_rec.SHIP_TO_CONTACT_ID,
          p_DESTINATION_SUBINVENTORY => p_REQUIREMENT_HEADER_rec.DESTINATION_SUBINVENTORY
        );

      -- Hint: Primary key should be returned.
      -- x_REQUIREMENT_HEADER_ID := px_REQUIREMENT_HEADER_ID;

  /*       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
    */
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
          Rollback to CREATE_Requirement_headers_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Create_requirement_headers;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REQUIREMENT_HEADER_Rec     IN    REQUIREMENT_HEADER_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_requirement_headers(REQUIREMENT_HEADER_ID Number) IS
    Select rowid,
           REQUIREMENT_HEADER_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OPEN_REQUIREMENT,
           SHIP_TO_LOCATION_ID,
           TASK_ID,
           TASK_ASSIGNMENT_ID,
           SHIPPING_METHOD_CODE,
           NEED_BY_DATE,
           DESTINATION_ORGANIZATION_ID,
           SHIP_TO_CONTACT_ID,
           PARTS_DEFINED,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15
    From  CSP_REQUIREMENT_HEADERS
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_requirement_headers';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_ref_REQUIREMENT_HEADER_rec  CSP_requirement_headers_PVT.REQUIREMENT_HEADER_Rec_Type;
l_tar_REQUIREMENT_HEADER_rec  CSP_requirement_headers_PVT.REQUIREMENT_HEADER_Rec_Type := P_REQUIREMENT_HEADER_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Requirement_headers_PUB;

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

      --
      -- Api body
      --

 /*     IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          JTF_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;
 */
      -- Debug Message
      -- JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');

/*
      Open C_Get_requirement_headers( l_tar_REQUIREMENT_HEADER_rec.REQUIREMENT_HEADER_ID);

      Fetch C_Get_requirement_headers into
               l_rowid,
               l_ref_REQUIREMENT_HEADER_rec.REQUIREMENT_HEADER_ID,
               l_ref_REQUIREMENT_HEADER_rec.CREATED_BY,
               l_ref_REQUIREMENT_HEADER_rec.CREATION_DATE,
               l_ref_REQUIREMENT_HEADER_rec.LAST_UPDATED_BY,
               l_ref_REQUIREMENT_HEADER_rec.LAST_UPDATE_DATE,
               l_ref_REQUIREMENT_HEADER_rec.LAST_UPDATE_LOGIN,
               l_ref_REQUIREMENT_HEADER_rec.OPEN_REQUIREMENT,
               l_ref_REQUIREMENT_HEADER_rec.SHIP_TO_LOCATION_ID,
               l_ref_REQUIREMENT_HEADER_rec.TASK_ID,
               l_ref_REQUIREMENT_HEADER_rec.TASK_ASSIGNMENT_ID,
               l_ref_REQUIREMENT_HEADER_rec.SHIPPING_METHOD_CODE,
               l_ref_REQUIREMENT_HEADER_rec.NEED_BY_DATE,
               l_ref_REQUIREMENT_HEADER_rec.DESTINATION_ORGANIZATION_ID,
               l_ref_REQUIREMENT_HEADER_rec.SHIP_TO_CONTACT_ID,
               l_ref_REQUIREMENT_HEADER_rec.PARTS_DEFINED,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE_CATEGORY,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE1,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE2,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE3,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE4,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE5,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE6,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE7,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE8,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE9,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE10,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE11,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE12,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE13,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE14,
               l_ref_REQUIREMENT_HEADER_rec.ATTRIBUTE15,

       If ( C_Get_requirement_headers%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'requirement_headers', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_requirement_headers;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       Close     C_Get_requirement_headers;
*/


  /*    If (l_tar_REQUIREMENT_HEADER_rec.last_update_date is NULL or
          l_tar_REQUIREMENT_HEADER_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_REQUIREMENT_HEADER_rec.last_update_date <> l_ref_REQUIREMENT_HEADER_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'requirement_headers', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_requirement_headers');

      -- Invoke validation procedures
      Validate_requirement_headers(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => JTF_UTILITY_PVT.G_UPDATE,
          P_REQUIREMENT_HEADER_Rec  =>  P_REQUIREMENT_HEADER_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    */

       -- Debug Message
      -- JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(CSP_REQUIREMENT_HEADERS_PKG.Update_Row)
      CSP_REQUIREMENT_HEADERS_PKG.Update_Row(
          p_REQUIREMENT_HEADER_ID  => p_REQUIREMENT_HEADER_rec.REQUIREMENT_HEADER_ID,
          p_CREATED_BY     => FND_API.G_MISS_NUM,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_OPEN_REQUIREMENT  => p_REQUIREMENT_HEADER_rec.OPEN_REQUIREMENT,
          p_SHIP_TO_LOCATION_ID  => p_REQUIREMENT_HEADER_rec.SHIP_TO_LOCATION_ID,
          p_TASK_ID  => p_REQUIREMENT_HEADER_rec.TASK_ID,
          p_TASK_ASSIGNMENT_ID  => p_REQUIREMENT_HEADER_rec.TASK_ASSIGNMENT_ID,
          p_SHIPPING_METHOD_CODE  => p_REQUIREMENT_HEADER_rec.SHIPPING_METHOD_CODE,
          p_NEED_BY_DATE  => p_REQUIREMENT_HEADER_rec.NEED_BY_DATE,
          p_DESTINATION_ORGANIZATION_ID  => p_REQUIREMENT_HEADER_rec.DESTINATION_ORGANIZATION_ID,
          p_PARTS_DEFINED  => p_REQUIREMENT_HEADER_rec.PARTS_DEFINED,
          p_ATTRIBUTE_CATEGORY  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_REQUIREMENT_HEADER_rec.ATTRIBUTE15,
          p_ORDER_TYPE_ID => p_REQUIREMENT_HEADER_rec.ORDER_TYPE_ID,
          p_ADDRESS_TYPE  => p_REQUIREMENT_HEADER_rec.ADDRESS_TYPE,
          p_RESOURCE_ID => p_REQUIREMENT_HEADER_rec.RESOURCE_ID,
          p_RESOURCE_TYPE => p_REQUIREMENT_HEADER_rec.RESOURCE_TYPE,
          p_TIMEZONE_ID => p_REQUIREMENT_HEADER_rec.TIMEZONE_ID,
          P_SHIP_TO_CONTACT_ID => p_REQUIREMENT_HEADER_rec.SHIP_TO_CONTACT_ID,
          p_DESTINATION_SUBINVENTORY => p_REQUIREMENT_HEADER_rec.DESTINATION_SUBINVENTORY
          );
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
          Rollback to UPDATE_Requirement_headers_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Update_requirement_headers;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REQUIREMENT_HEADER_Rec     IN REQUIREMENT_HEADER_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_requirement_headers';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Requirement_headers_PUB;

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

      --
      -- Api body
      --

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      -- JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');

      -- Invoke table handler(CSP_REQUIREMENT_HEADERS_PKG.Delete_Row)
      CSP_REQUIREMENT_HEADERS_PKG.Delete_Row(
          p_REQUIREMENT_HEADER_ID  => p_REQUIREMENT_HEADER_rec.REQUIREMENT_HEADER_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      -- JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
          Rollback to DELETE_Requirement_headers_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Delete_requirement_headers;

/*
-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_REQUIREMENT_HEADER_Rec   IN  CSP_Requirement_headers_PVT.REQUIREMENT_HEADER_Rec_Type,
    p_cur_get_REQUIREMENT_HEADER   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Begins');

      -- define all columns for CSP_REQUIREMENT_HEADERS view
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 1, P_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 2, P_REQUIREMENT_HEADER_Rec.OPEN_REQUIREMENT, 240);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 3, P_REQUIREMENT_HEADER_Rec.SHIP_TO_LOCATION_ID);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 4, P_REQUIREMENT_HEADER_Rec.TASK_ID);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 5, P_REQUIREMENT_HEADER_Rec.TASK_ASSIGNMENT_ID);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 6, P_REQUIREMENT_HEADER_Rec.SHIPPING_METHOD_CODE, 30);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 7, P_REQUIREMENT_HEADER_Rec.NEED_BY_DATE);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 8, P_REQUIREMENT_HEADER_Rec.DESTINATION_ORGANIZATION_ID);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 9, P_REQUIREMENT_HEADER_Rec.PARTS_DEFINED, 30);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 10, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 11, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 12, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 13, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 14, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 15, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 16, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 17, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 18, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 19, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 20, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 21, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 22, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 23, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 24, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_REQUIREMENT_HEADER, 25, P_REQUIREMENT_HEADER_Rec.ATTRIBUTE15, 150);

      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_REQUIREMENT_HEADER   IN   NUMBER,
    X_REQUIREMENT_HEADER_Rec   OUT NOCOPY  CSP_Requirement_headers_PUB.REQUIREMENT_HEADER_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Begins');

      -- get all column values for CSP_REQUIREMENT_HEADERS table
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 1, X_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 2, X_REQUIREMENT_HEADER_Rec.OPEN_REQUIREMENT);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 3, X_REQUIREMENT_HEADER_Rec.SHIP_TO_LOCATION_ID);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 4, X_REQUIREMENT_HEADER_Rec.TASK_ID);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 5, X_REQUIREMENT_HEADER_Rec.TASK_ASSIGNMENT_ID);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 6, X_REQUIREMENT_HEADER_Rec.SHIPPING_METHOD_CODE);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 7, X_REQUIREMENT_HEADER_Rec.NEED_BY_DATE);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 8, X_REQUIREMENT_HEADER_Rec.DESTINATION_ORGANIZATION_ID);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 9, X_REQUIREMENT_HEADER_Rec.PARTS_DEFINED);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 10, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 11, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 12, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 13, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 14, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 15, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 16, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 17, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 18, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 19, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 20, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 21, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 22, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 23, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 24, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_REQUIREMENT_HEADER, 25, X_REQUIREMENT_HEADER_Rec.ATTRIBUTE15);

      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Ends');
END Get_Column_Values;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_REQUIREMENT_HEADER_Rec   IN   CSP_Requirement_headers_PUB.REQUIREMENT_HEADER_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_REQUIREMENT_HEADER   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID IS NOT NULL) AND (P_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_REQUIREMENT_HEADER, ':p_REQUIREMENT_HEADER_ID', P_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID);
      END IF;

      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Ends');
END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Begins');

      x_select_cl := 'Select ' ||
                'CSP_REQUIREMENT_HEADERS.REQUIREMENT_HEADER_ID,' ||
                'CSP_REQUIREMENT_HEADERS.CREATED_BY,' ||
                'CSP_REQUIREMENT_HEADERS.CREATION_DATE,' ||
                'CSP_REQUIREMENT_HEADERS.LAST_UPDATED_BY,' ||
                'CSP_REQUIREMENT_HEADERS.LAST_UPDATE_DATE,' ||
                'CSP_REQUIREMENT_HEADERS.LAST_UPDATE_LOGIN,' ||
                'CSP_REQUIREMENT_HEADERS.OPEN_REQUIREMENT,' ||
                'CSP_REQUIREMENT_HEADERS.SHIP_TO_LOCATION_ID,' ||
                'CSP_REQUIREMENT_HEADERS.TASK_ID,' ||
                'CSP_REQUIREMENT_HEADERS.TASK_ASSIGNMENT_ID,' ||
                'CSP_REQUIREMENT_HEADERS.SHIPPING_METHOD_CODE,' ||
                'CSP_REQUIREMENT_HEADERS.NEED_BY_DATE,' ||
                'CSP_REQUIREMENT_HEADERS.DESTINATION_ORGANIZATION_ID,' ||
                'CSP_REQUIREMENT_HEADERS.PARTS_DEFINED,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE_CATEGORY,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE1,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE2,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE3,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE4,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE5,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE6,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE7,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE8,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE9,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE10,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE11,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE12,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE13,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE14,' ||
                'CSP_REQUIREMENT_HEADERS.ATTRIBUTE15,' ||
                'from CSP_REQUIREMENT_HEADERS';
      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_REQUIREMENT_HEADER_Where(
    P_REQUIREMENT_HEADER_Rec     IN   CSP_Requirement_headers_PUB.REQUIREMENT_HEADER_Rec_Type,
    x_REQUIREMENT_HEADER_where   OUT NOCOPY   VARCHAR2
)
IS
-- cursors to check if wildcard values '%' and '_' have been passed
-- as item values
CURSOR c_chk_str1(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '%', 1, 1)
    FROM DUAL;
CURSOR c_chk_str2(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '_', 1, 1)
    FROM DUAL;

-- return values from cursors
str_csr1   NUMBER;
str_csr2   NUMBER;
l_operator VARCHAR2(10);
BEGIN
      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Begins');

      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID IS NOT NULL) AND (P_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_REQUIREMENT_HEADER_where IS NULL) THEN
              x_REQUIREMENT_HEADER_where := 'Where';
          ELSE
              x_REQUIREMENT_HEADER_where := x_REQUIREMENT_HEADER_where || ' AND ';
          END IF;
          x_REQUIREMENT_HEADER_where := x_REQUIREMENT_HEADER_where || 'P_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID = :p_REQUIREMENT_HEADER_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_REQUIREMENT_HEADER_Rec.CREATION_DATE IS NOT NULL) AND (P_REQUIREMENT_HEADER_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_REQUIREMENT_HEADER_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_REQUIREMENT_HEADER_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_REQUIREMENT_HEADER_where IS NULL) THEN
              x_REQUIREMENT_HEADER_where := 'Where ';
          ELSE
              x_REQUIREMENT_HEADER_where := x_REQUIREMENT_HEADER_where || ' AND ';
          END IF;
          x_REQUIREMENT_HEADER_where := x_REQUIREMENT_HEADER_where || 'P_REQUIREMENT_HEADER_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_REQUIREMENT_HEADER_Rec.OPEN_REQUIREMENT IS NOT NULL) AND (P_REQUIREMENT_HEADER_Rec.OPEN_REQUIREMENT <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_REQUIREMENT_HEADER_Rec.OPEN_REQUIREMENT);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_REQUIREMENT_HEADER_Rec.OPEN_REQUIREMENT);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_REQUIREMENT_HEADER_where IS NULL) THEN
              x_REQUIREMENT_HEADER_where := 'Where ';
          ELSE
              x_REQUIREMENT_HEADER_where := x_REQUIREMENT_HEADER_where || ' AND ';
          END IF;
          x_REQUIREMENT_HEADER_where := x_REQUIREMENT_HEADER_where || 'P_REQUIREMENT_HEADER_Rec.OPEN_REQUIREMENT ' || l_operator || ' :p_OPEN_REQUIREMENT';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Ends');

END Gen_REQUIREMENT_HEADER_Where;

-- Item-level validation procedures
PROCEDURE Validate_REQUIREMENT_HEADER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUIREMENT_HEADER_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_REQUIREMENT_HEADER_ID is NULL)
      THEN
          JTF_UTILITY_PVT.Debug_Message('ERROR', 'Private requirement_headers API: -Violate NOT NULL constraint(REQUIREMENT_HEADER_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIREMENT_HEADER_ID is not NULL and p_REQUIREMENT_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIREMENT_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUIREMENT_HEADER_ID;


PROCEDURE Validate_OPEN_REQUIREMENT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OPEN_REQUIREMENT                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OPEN_REQUIREMENT is not NULL and p_OPEN_REQUIREMENT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OPEN_REQUIREMENT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OPEN_REQUIREMENT;


PROCEDURE Validate_SHIP_TO_LOCATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIP_TO_LOCATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIP_TO_LOCATION_ID is not NULL and p_SHIP_TO_LOCATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIP_TO_LOCATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIP_TO_LOCATION_ID;


PROCEDURE Validate_TASK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_ID is not NULL and p_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TASK_ID;


PROCEDURE Validate_TASK_ASSIGNMENT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_ASSIGNMENT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_ASSIGNMENT_ID is not NULL and p_TASK_ASSIGNMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_ASSIGNMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TASK_ASSIGNMENT_ID;


PROCEDURE Validate_SHIPPING_METHOD_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIPPING_METHOD_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPPING_METHOD_CODE is not NULL and p_SHIPPING_METHOD_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPPING_METHOD_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIPPING_METHOD_CODE;


PROCEDURE Validate_NEED_BY_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_NEED_BY_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEED_BY_DATE is not NULL and p_NEED_BY_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_NEED_BY_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_NEED_BY_DATE;


PROCEDURE Validate_DEST_ORGANIZATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DESTINATION_ORGANIZATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DESTINATION_ORGANIZATION_ID is not NULL and p_DESTINATION_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DESTINATION_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEST_ORGANIZATION_ID;


PROCEDURE Validate_PARTS_DEFINED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTS_DEFINED                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARTS_DEFINED is not NULL and p_PARTS_DEFINED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARTS_DEFINED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARTS_DEFINED;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_RQMT_HEADER_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUIREMENT_HEADER_Rec     IN    REQUIREMENT_HEADER_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RQMT_HEADER_Rec;

PROCEDURE Validate_requirement_headers(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUIREMENT_HEADER_Rec     IN    REQUIREMENT_HEADER_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_requirement_headers';
 BEGIN

      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_REQUIREMENT_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUIREMENT_HEADER_ID   => P_REQUIREMENT_HEADER_Rec.REQUIREMENT_HEADER_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OPEN_REQUIREMENT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OPEN_REQUIREMENT   => P_REQUIREMENT_HEADER_Rec.OPEN_REQUIREMENT,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIP_TO_LOCATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIP_TO_LOCATION_ID   => P_REQUIREMENT_HEADER_Rec.SHIP_TO_LOCATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TASK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_ID   => P_REQUIREMENT_HEADER_Rec.TASK_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TASK_ASSIGNMENT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_ASSIGNMENT_ID   => P_REQUIREMENT_HEADER_Rec.TASK_ASSIGNMENT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIPPING_METHOD_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIPPING_METHOD_CODE   => P_REQUIREMENT_HEADER_Rec.SHIPPING_METHOD_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_NEED_BY_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_NEED_BY_DATE   => P_REQUIREMENT_HEADER_Rec.NEED_BY_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DEST_ORGANIZATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DESTINATION_ORGANIZATION_ID   => P_REQUIREMENT_HEADER_Rec.DESTINATION_ORGANIZATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARTS_DEFINED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARTS_DEFINED   => P_REQUIREMENT_HEADER_Rec.PARTS_DEFINED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      IF (p_validation_level >= JTF_UTILITY_PVT.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_RQMT_HEADER_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_REQUIREMENT_HEADER_Rec     =>    P_REQUIREMENT_HEADER_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF (p_validation_level >= JTF_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= JTF_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');

END Validate_requirement_headers; */

End CSP_Requirement_headers_PVT;

/
