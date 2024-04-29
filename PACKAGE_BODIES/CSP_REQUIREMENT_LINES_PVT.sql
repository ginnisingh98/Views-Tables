--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_LINES_PVT" as
/* $Header: cspvrqlb.pls 120.0.12010000.2 2010/03/17 17:10:32 htank ship $ */
-- Start of Comments
-- Package name     : CSP_Requirement_Lines_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_Requirement_Lines_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvrqlb.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_requirement_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Requirement_Line_Tbl       IN   Requirement_Line_Tbl_Type  := G_MISS_Requirement_Line_Tbl,
    x_Requirement_Line_tbl       OUT NOCOPY Requirement_Line_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_requirement_lines';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);

l_requirement_line_Rec      Requirement_Line_Rec_Type;
l_requirement_line_id       NUMBER;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Requirement_Lines_PUB;

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
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
/*      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => NULL
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
      --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');

      -- Invoke table handler(CSP_REQUIREMENT_LINES_PKG.Insert_Row)
      FOR I IN 1..P_Requirement_Line_Tbl.COUNT LOOP

        l_requirement_line_rec := P_Requirement_Line_Tbl(I);

        CSP_REQUIREMENT_LINES_PKG.Insert_Row(
          px_REQUIREMENT_LINE_ID  => l_requirement_line_rec.requirement_line_id,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUIREMENT_HEADER_ID  => l_Requirement_Line_rec.REQUIREMENT_HEADER_ID,
          p_INVENTORY_ITEM_ID  => l_Requirement_Line_rec.INVENTORY_ITEM_ID,
          p_UOM_CODE  => l_Requirement_Line_rec.UOM_CODE,
          p_REQUIRED_QUANTITY  => l_Requirement_Line_rec.REQUIRED_QUANTITY,
          p_SHIP_COMPLETE_FLAG  => l_Requirement_Line_rec.SHIP_COMPLETE_FLAG,
          p_LIKELIHOOD  => l_Requirement_Line_rec.LIKELIHOOD,
          p_REVISION  => l_Requirement_Line_rec.REVISION,
          p_SOURCE_ORGANIZATION_ID  => l_Requirement_Line_rec.SOURCE_ORGANIZATION_ID,
          p_SOURCE_SUBINVENTORY  => l_Requirement_Line_rec.SOURCE_SUBINVENTORY,
          p_ORDERED_QUANTITY  => l_Requirement_Line_rec.ORDERED_QUANTITY,
          p_ORDER_LINE_ID  => l_Requirement_Line_rec.ORDER_LINE_ID,
          p_RESERVATION_ID  => l_Requirement_Line_rec.RESERVATION_ID,
          p_ORDER_BY_DATE  => l_Requirement_Line_rec.ORDER_BY_DATE,
          p_ATTRIBUTE_CATEGORY  => l_Requirement_Line_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_Requirement_Line_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_Requirement_Line_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_Requirement_Line_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_Requirement_Line_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_Requirement_Line_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_Requirement_Line_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_Requirement_Line_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_Requirement_Line_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_Requirement_Line_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_Requirement_Line_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_Requirement_Line_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_Requirement_Line_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_Requirement_Line_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_Requirement_Line_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_Requirement_Line_rec.ATTRIBUTE15,
          p_ARRIVAL_DATE => l_Requirement_line_rec.ARRIVAL_DATE,
          p_ITEM_SCRATCHPAD => l_requirement_line_rec.item_scratchpad,
          p_SHIPPING_METHOD_CODE => l_requirement_line_rec.shipping_method_code,
          p_LOCAL_RESERVATION_ID => l_requirement_line_rec.LOCAL_RESERVATION_ID,
          p_SOURCED_FROM => l_requirement_line_rec.SOURCED_FROM
          );

      -- Hint: Primary key should be returned.
         x_REQUIREMENT_Line_Tbl(I) := l_requirement_line_rec;

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
          Rollback to CREATE_Requirement_lines_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Create_requirement_lines;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_requirement_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Requirement_Line_Tbl       IN   Requirement_Line_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_requirement_lines(REQUIREMENT_LINE_ID Number) IS
    Select rowid,
           REQUIREMENT_LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUIREMENT_HEADER_ID,
           INVENTORY_ITEM_ID,
           UOM_CODE,
           REQUIRED_QUANTITY,
           SHIP_COMPLETE_FLAG,
           LIKELIHOOD,
           REVISION,
           SOURCE_ORGANIZATION_ID,
           SOURCE_SUBINVENTORY,
           ORDERED_QUANTITY,
           ORDER_LINE_ID,
           RESERVATION_ID,
           ORDER_BY_DATE,
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
           ATTRIBUTE15,
    From  CSP_REQUIREMENT_LINES
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_requirement_lines';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_Requirement_Line_rec    CSP_requirement_lines_PVT.Requirement_Line_Rec_Type;
--l_tar_Requirement_Line_rec  CSP_requirement_lines_PVT.Requirement_Line_Rec_Type := P_Requirement_Line_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Requirement_Lines_PUB;

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

     -- Debug Message
     -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');

/*
      Open C_Get_requirement_lines( l_tar_Requirement_Lines_rec.REQUIREMENT_LINE_ID);

      Fetch C_Get_requirement_lines into
               l_rowid,
               l_ref_Requirement_Lines_rec.REQUIREMENT_LINE_ID,
               l_ref_Requirement_Lines_rec.CREATED_BY,
               l_ref_Requirement_Lines_rec.CREATION_DATE,
               l_ref_Requirement_Lines_rec.LAST_UPDATED_BY,
               l_ref_Requirement_Lines_rec.LAST_UPDATE_DATE,
               l_ref_Requirement_Lines_rec.LAST_UPDATE_LOGIN,
               l_ref_Requirement_Lines_rec.REQUIREMENT_HEADER_ID,
               l_ref_Requirement_Lines_rec.INVENTORY_ITEM_ID,
               l_ref_Requirement_Lines_rec.UOM_CODE,
               l_ref_Requirement_Lines_rec.REQUIRED_QUANTITY,
               l_ref_Requirement_Lines_rec.SHIP_COMPLETE_FLAG,
               l_ref_Requirement_Lines_rec.LIKELIHOOD,
               l_ref_Requirement_Lines_rec.REVISION,
               l_ref_Requirement_Lines_rec.SOURCE_ORGANIZATION_ID,
               l_ref_Requirement_Lines_rec.SOURCE_SUBINVENTORY,
               l_ref_Requirement_Lines_rec.ORDERED_QUANTITY,
               l_ref_Requirement_Lines_rec.ORDER_LINE_ID,
               l_ref_Requirement_Lines_rec.RESERVATION_ID,
               l_ref_Requirement_Lines_rec.ORDER_BY_DATE,
               l_ref_Requirement_Lines_rec.ATTRIBUTE_CATEGORY,
               l_ref_Requirement_Lines_rec.ATTRIBUTE1,
               l_ref_Requirement_Lines_rec.ATTRIBUTE2,
               l_ref_Requirement_Lines_rec.ATTRIBUTE3,
               l_ref_Requirement_Lines_rec.ATTRIBUTE4,
               l_ref_Requirement_Lines_rec.ATTRIBUTE5,
               l_ref_Requirement_Lines_rec.ATTRIBUTE6,
               l_ref_Requirement_Lines_rec.ATTRIBUTE7,
               l_ref_Requirement_Lines_rec.ATTRIBUTE8,
               l_ref_Requirement_Lines_rec.ATTRIBUTE9,
               l_ref_Requirement_Lines_rec.ATTRIBUTE10,
               l_ref_Requirement_Lines_rec.ATTRIBUTE11,
               l_ref_Requirement_Lines_rec.ATTRIBUTE12,
               l_ref_Requirement_Lines_rec.ATTRIBUTE13,
               l_ref_Requirement_Lines_rec.ATTRIBUTE14,
               l_ref_Requirement_Lines_rec.ATTRIBUTE15,

       If ( C_Get_requirement_lines%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'requirement_lines', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_requirement_lines;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       Close     C_Get_requirement_lines;



      If (l_tar_Requirement_Lines_rec.last_update_date is NULL or
          l_tar_Requirement_Lines_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_Requirement_Lines_rec.last_update_date <> l_ref_Requirement_Lines_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'requirement_lines', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_requirement_lines');

      -- Invoke validation procedures
      Validate_requirement_lines(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          p_requirement_line_rec  =>  p_requirement_line_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
--        AS_ACCESS_PUB.Has_???Access(
--            p_api_version_number     => 2.0
--           ,p_init_msg_list          => p_init_msg_list
--           ,p_validation_level       => p_validation_level
--           ,p_profile_tbl            => p_profile_tbl
--           ,p_admin_flag             => p_admin_flag
--           ,p_admin_group_id         => p_admin_group_id
--           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
--           ,p_customer_id            =>
--           ,p_check_access_flag      => 'Y'
--           ,p_identity_salesforce_id => p_identity_salesforce_id
--           ,p_partner_cont_party_id  => NULL
--           ,x_return_status          => x_return_status
--           ,x_msg_count              => x_msg_count
--           ,x_msg_data               => x_msg_data
--           ,x_access_flag            => l_access_flag);

--          IF l_access_flag <> 'Y' THEN
--              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
--                  'API_NO_UPDATE_PRIVILEGE');
--          END IF;


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
      -- Hint: Add corresponding Master-Detail business logic here if necessary.
*/
      -- Debug Message
     --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(CSP_REQUIREMENT_LINES_PKG.Update_Row)
      FOR I IN 1..P_Requirement_Line_Tbl.COUNT LOOP
        l_requirement_line_rec := p_requirement_line_tbl(I);

        CSP_REQUIREMENT_LINES_PKG.Update_Row(
          p_REQUIREMENT_LINE_ID  => l_requirement_line_rec.REQUIREMENT_LINE_ID,
          p_CREATED_BY     => FND_API.G_MISS_NUM,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUIREMENT_HEADER_ID  => l_requirement_line_rec.REQUIREMENT_HEADER_ID,
          p_INVENTORY_ITEM_ID  => l_requirement_line_rec.INVENTORY_ITEM_ID,
          p_UOM_CODE  => l_requirement_line_rec.UOM_CODE,
          p_REQUIRED_QUANTITY  => l_requirement_line_rec.REQUIRED_QUANTITY,
          p_SHIP_COMPLETE_FLAG  => l_requirement_line_rec.SHIP_COMPLETE_FLAG,
          p_LIKELIHOOD  => l_requirement_line_rec.LIKELIHOOD,
          p_REVISION  => l_requirement_line_rec.REVISION,
          p_SOURCE_ORGANIZATION_ID  => l_requirement_line_rec.SOURCE_ORGANIZATION_ID,
          p_SOURCE_SUBINVENTORY  => l_requirement_line_rec.SOURCE_SUBINVENTORY,
          p_ORDERED_QUANTITY  => l_requirement_line_rec.ORDERED_QUANTITY,
          p_ORDER_LINE_ID  => l_requirement_line_rec.ORDER_LINE_ID,
          p_RESERVATION_ID  => l_requirement_line_rec.RESERVATION_ID,
          p_ORDER_BY_DATE  => l_requirement_line_rec.ORDER_BY_DATE,
          p_ATTRIBUTE_CATEGORY  => l_requirement_line_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_requirement_line_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_requirement_line_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_requirement_line_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_requirement_line_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_requirement_line_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_requirement_line_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_requirement_line_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_requirement_line_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_requirement_line_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_requirement_line_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_requirement_line_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_requirement_line_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_requirement_line_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_requirement_line_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_requirement_line_rec.ATTRIBUTE15,
          p_ARRIVAL_DATE => l_requirement_line_rec.arrival_date,
          p_ITEM_SCRATCHPAD => l_requirement_line_rec.item_scratchpad,
          p_SHIPPING_METHOD_CODE => l_requirement_line_rec.shipping_method_code,
          p_LOCAL_RESERVATION_ID => l_requirement_line_rec.LOCAL_RESERVATION_ID,
          p_SOURCED_FROM => l_requirement_line_rec.SOURCED_FROM
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


      -- Debug Message
      --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
    /*  FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
*/
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
          Rollback to UPDATE_Requirement_Lines_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Update_requirement_lines;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_requirement_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_requirement_line_tbl       IN   Requirement_Line_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
 l_api_name                CONSTANT VARCHAR2(30) := 'Delete_requirement_lines';
 l_api_version_number      CONSTANT NUMBER   := 1.0;
 l_requirement_line_rec    Requirement_Line_Rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Requirement_Lines_PUB;

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
      -- Debug Message
      --JTF_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');

      -- Invoke table handler(CSP_REQUIREMENT_LINES_PKG.Delete_Row)
      FOR I IN 1..P_Requirement_Line_Tbl.COUNT LOOP
        l_requirement_line_rec := p_requirement_Line_Tbl(I);

        CSP_REQUIREMENT_LINES_PKG.Delete_Row(
          p_REQUIREMENT_LINE_ID  => l_requirement_line_rec.REQUIREMENT_LINE_ID);

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
          Rollback to DELETE_Requirement_Lines_PUB;
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
          FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
          x_return_status := FND_API.G_RET_STS_ERROR;
End Delete_requirement_lines;

/*
-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    l_requirement_line_rec   IN  CSP_Requirement_Lines_PUB.Requirement_Lines_Rec_Type,
    p_cur_get_Requirement_Lines   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Begins');

      -- define all columns for CSP_REQUIREMENT_LINES view
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 1, p_requirement_line_rec.REQUIREMENT_LINE_ID);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 2, p_requirement_line_rec.REQUIREMENT_HEADER_ID);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 3, p_requirement_line_rec.INVENTORY_ITEM_ID);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 4, p_requirement_line_rec.UOM_CODE, 3);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 5, p_requirement_line_rec.REQUIRED_QUANTITY);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 6, p_requirement_line_rec.SHIP_COMPLETE_FLAG, 3);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 7, p_requirement_line_rec.LIKELIHOOD);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 8, p_requirement_line_rec.REVISION, 3);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 9, p_requirement_line_rec.SOURCE_ORGANIZATION_ID);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 10, p_requirement_line_rec.SOURCE_SUBINVENTORY, 10);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 11, p_requirement_line_rec.ORDERED_QUANTITY);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 12, p_requirement_line_rec.ORDER_LINE_ID);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 13, p_requirement_line_rec.RESERVATION_ID);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 14, p_requirement_line_rec.ORDER_BY_DATE);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 15, p_requirement_line_rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 16, p_requirement_line_rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 17, p_requirement_line_rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 18, p_requirement_line_rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 19, p_requirement_line_rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 20, p_requirement_line_rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 21, p_requirement_line_rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 22, p_requirement_line_rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 23, p_requirement_line_rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 24, p_requirement_line_rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 25, p_requirement_line_rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 26, p_requirement_line_rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 27, p_requirement_line_rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 28, p_requirement_line_rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 29, p_requirement_line_rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_Requirement_Lines, 30, p_requirement_line_rec.ATTRIBUTE15, 150);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_Requirement_Lines   IN   NUMBER,
    X_Requirement_Lines_Rec   OUT NOCOPY  CSP_Requirement_Lines_PUB.Requirement_Lines_Rec_Type
)
IS
BEGIN
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Begins');

      -- get all column values for CSP_REQUIREMENT_LINES table
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 1, X_Requirement_Lines_Rec.REQUIREMENT_LINE_ID);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 2, X_Requirement_Lines_Rec.REQUIREMENT_HEADER_ID);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 3, X_Requirement_Lines_Rec.INVENTORY_ITEM_ID);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 4, X_Requirement_Lines_Rec.UOM_CODE);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 5, X_Requirement_Lines_Rec.REQUIRED_QUANTITY);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 6, X_Requirement_Lines_Rec.SHIP_COMPLETE_FLAG);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 7, X_Requirement_Lines_Rec.LIKELIHOOD);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 8, X_Requirement_Lines_Rec.REVISION);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 9, X_Requirement_Lines_Rec.SOURCE_ORGANIZATION_ID);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 10, X_Requirement_Lines_Rec.SOURCE_SUBINVENTORY);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 11, X_Requirement_Lines_Rec.ORDERED_QUANTITY);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 12, X_Requirement_Lines_Rec.ORDER_LINE_ID);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 13, X_Requirement_Lines_Rec.RESERVATION_ID);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 14, X_Requirement_Lines_Rec.ORDER_BY_DATE);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 15, X_Requirement_Lines_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 16, X_Requirement_Lines_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 17, X_Requirement_Lines_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 18, X_Requirement_Lines_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 19, X_Requirement_Lines_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 20, X_Requirement_Lines_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 21, X_Requirement_Lines_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 22, X_Requirement_Lines_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 23, X_Requirement_Lines_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 24, X_Requirement_Lines_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 25, X_Requirement_Lines_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 26, X_Requirement_Lines_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 27, X_Requirement_Lines_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 28, X_Requirement_Lines_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 29, X_Requirement_Lines_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_Requirement_Lines, 30, X_Requirement_Lines_Rec.ATTRIBUTE15);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_Requirement_Lines_order_cl(
    p_order_by_rec   IN   CSP_Requirement_Lines_PUB.Requirement_Lines_sort_rec_type,
    x_order_by_cl    OUT NOCOPY  VARCHAR2,
    x_return_status  OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2
)
IS
l_order_by_cl        VARCHAR2(1000)   := NULL;
l_util_order_by_tbl  AS_UTILITY_PVT.Util_order_by_tbl_type;
BEGIN
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Order by Begins');

      -- Hint: Developer should add more statements according to CSP_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Invoke AS_UTILITY_PVT.Translate_OrderBy');

      AS_UTILITY_PVT.Translate_OrderBy(
          p_api_version_number   =>   1.0
         ,p_init_msg_list        =>   FND_API.G_FALSE
         ,p_validation_level     =>   FND_API.G_VALID_LEVEL_FULL
         ,p_order_by_tbl         =>   l_util_order_by_tbl
         ,x_order_by_clause      =>   l_order_by_cl
         ,x_return_status        =>   x_return_status
         ,x_msg_count            =>   x_msg_count
         ,x_msg_data             =>   x_msg_data);

      IF(l_order_by_cl IS NOT NULL) THEN
          x_order_by_cl := 'order by' || l_order_by_cl;
      ELSE
          x_order_by_cl := NULL;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Order by Ends');
END Gen_Requirement_Lines_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    p_requirement_line_rec   IN   CSP_Requirement_Lines_PUB.Requirement_Lines_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_Requirement_Lines   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (p_requirement_line_rec.REQUIREMENT_LINE_ID IS NOT NULL) AND (p_requirement_line_rec.REQUIREMENT_LINE_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_Requirement_Lines, ':p_REQUIREMENT_LINE_ID', p_requirement_line_rec.REQUIREMENT_LINE_ID);
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Ends');
END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Begins');

      x_select_cl := 'Select ' ||
                'CSP_REQUIREMENT_LINES.REQUIREMENT_LINE_ID,' ||
                'CSP_REQUIREMENT_LINES.CREATED_BY,' ||
                'CSP_REQUIREMENT_LINES.CREATION_DATE,' ||
                'CSP_REQUIREMENT_LINES.LAST_UPDATED_BY,' ||
                'CSP_REQUIREMENT_LINES.LAST_UPDATE_DATE,' ||
                'CSP_REQUIREMENT_LINES.LAST_UPDATE_LOGIN,' ||
                'CSP_REQUIREMENT_LINES.REQUIREMENT_HEADER_ID,' ||
                'CSP_REQUIREMENT_LINES.INVENTORY_ITEM_ID,' ||
                'CSP_REQUIREMENT_LINES.UOM_CODE,' ||
                'CSP_REQUIREMENT_LINES.REQUIRED_QUANTITY,' ||
                'CSP_REQUIREMENT_LINES.SHIP_COMPLETE_FLAG,' ||
                'CSP_REQUIREMENT_LINES.LIKELIHOOD,' ||
                'CSP_REQUIREMENT_LINES.REVISION,' ||
                'CSP_REQUIREMENT_LINES.SOURCE_ORGANIZATION_ID,' ||
                'CSP_REQUIREMENT_LINES.SOURCE_SUBINVENTORY,' ||
                'CSP_REQUIREMENT_LINES.ORDERED_QUANTITY,' ||
                'CSP_REQUIREMENT_LINES.ORDER_LINE_ID,' ||
                'CSP_REQUIREMENT_LINES.RESERVATION_ID,' ||
                'CSP_REQUIREMENT_LINES.ORDER_BY_DATE,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE_CATEGORY,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE1,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE2,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE3,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE4,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE5,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE6,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE7,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE8,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE9,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE10,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE11,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE12,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE13,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE14,' ||
                'CSP_REQUIREMENT_LINES.ATTRIBUTE15,' ||
                'from CSP_REQUIREMENT_LINES';
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_Requirement_Lines_Where(
    p_requirement_line_rec     IN   CSP_Requirement_Lines_PUB.Requirement_Lines_Rec_Type,
    x_Requirement_Lines_where   OUT NOCOPY   VARCHAR2
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Begins');

      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (p_requirement_line_rec.REQUIREMENT_LINE_ID IS NOT NULL) AND (p_requirement_line_rec.REQUIREMENT_LINE_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_Requirement_Lines_where IS NULL) THEN
              x_Requirement_Lines_where := 'Where';
          ELSE
              x_Requirement_Lines_where := x_Requirement_Lines_where || ' AND ';
          END IF;
          x_Requirement_Lines_where := x_Requirement_Lines_where || 'p_requirement_line_rec.REQUIREMENT_LINE_ID = :p_REQUIREMENT_LINE_ID';
      END IF;

      -- example for DATE datatype
      IF( (p_requirement_line_rec.CREATION_DATE IS NOT NULL) AND (p_requirement_line_rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(p_requirement_line_rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(p_requirement_line_rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_Requirement_Lines_where IS NULL) THEN
              x_Requirement_Lines_where := 'Where ';
          ELSE
              x_Requirement_Lines_where := x_Requirement_Lines_where || ' AND ';
          END IF;
          x_Requirement_Lines_where := x_Requirement_Lines_where || 'p_requirement_line_rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (p_requirement_line_rec.UOM_CODE IS NOT NULL) AND (p_requirement_line_rec.UOM_CODE <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(p_requirement_line_rec.UOM_CODE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(p_requirement_line_rec.UOM_CODE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_Requirement_Lines_where IS NULL) THEN
              x_Requirement_Lines_where := 'Where ';
          ELSE
              x_Requirement_Lines_where := x_Requirement_Lines_where || ' AND ';
          END IF;
          x_Requirement_Lines_where := x_Requirement_Lines_where || 'p_requirement_line_rec.UOM_CODE ' || l_operator || ' :p_UOM_CODE';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Ends');

END Gen_Requirement_Lines_Where;

-- Item-level validation procedures
PROCEDURE Validate_REQUIREMENT_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUIREMENT_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
      IF(p_REQUIREMENT_LINE_ID is NULL)
      THEN
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private requirement_lines API: -Violate NOT NULL constraint(REQUIREMENT_LINE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIREMENT_LINE_ID is not NULL and p_REQUIREMENT_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIREMENT_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUIREMENT_LINE_ID;


PROCEDURE Validate_REQUIREMENT_HEADER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUIREMENT_HEADER_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private requirement_lines API: -Violate NOT NULL constraint(REQUIREMENT_HEADER_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIREMENT_HEADER_ID is not NULL and p_REQUIREMENT_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
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


PROCEDURE Validate_INVENTORY_ITEM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INVENTORY_ITEM_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
      IF(p_INVENTORY_ITEM_ID is NULL)
      THEN
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private requirement_lines API: -Violate NOT NULL constraint(INVENTORY_ITEM_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_INVENTORY_ITEM_ID is not NULL and p_INVENTORY_ITEM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_INVENTORY_ITEM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INVENTORY_ITEM_ID;


PROCEDURE Validate_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_UOM_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
      IF(p_UOM_CODE is NULL)
      THEN
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private requirement_lines API: -Violate NOT NULL constraint(UOM_CODE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_UOM_CODE is not NULL and p_UOM_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_UOM_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_UOM_CODE;


PROCEDURE Validate_REQUIRED_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUIRED_QUANTITY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
      IF(p_REQUIRED_QUANTITY is NULL)
      THEN
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private requirement_lines API: -Violate NOT NULL constraint(REQUIRED_QUANTITY)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIRED_QUANTITY is not NULL and p_REQUIRED_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUIRED_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUIRED_QUANTITY;


PROCEDURE Validate_SHIP_COMPLETE_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIP_COMPLETE_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIP_COMPLETE_FLAG is not NULL and p_SHIP_COMPLETE_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIP_COMPLETE_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIP_COMPLETE_FLAG;


PROCEDURE Validate_LIKELIHOOD (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LIKELIHOOD                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LIKELIHOOD is not NULL and p_LIKELIHOOD <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LIKELIHOOD <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LIKELIHOOD;


PROCEDURE Validate_REVISION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REVISION                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REVISION is not NULL and p_REVISION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REVISION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REVISION;


PROCEDURE Validate_SOURCE_ORGANIZATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_ORGANIZATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_ORGANIZATION_ID is not NULL and p_SOURCE_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SOURCE_ORGANIZATION_ID;


PROCEDURE Validate_SOURCE_SUBINVENTORY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_SUBINVENTORY                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_SUBINVENTORY is not NULL and p_SOURCE_SUBINVENTORY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SOURCE_SUBINVENTORY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SOURCE_SUBINVENTORY;


PROCEDURE Validate_ORDERED_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORDERED_QUANTITY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORDERED_QUANTITY is not NULL and p_ORDERED_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORDERED_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORDERED_QUANTITY;


PROCEDURE Validate_ORDER_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORDER_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORDER_LINE_ID is not NULL and p_ORDER_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORDER_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORDER_LINE_ID;


PROCEDURE Validate_RESERVATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESERVATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESERVATION_ID is not NULL and p_RESERVATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESERVATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RESERVATION_ID;


PROCEDURE Validate_ORDER_BY_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORDER_BY_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORDER_BY_DATE is not NULL and p_ORDER_BY_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORDER_BY_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORDER_BY_DATE;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_Requirement_Lines_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    p_requirement_line_rec     IN    Requirement_Lines_Rec_Type,
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Requirement_Lines_Rec;

PROCEDURE Validate_requirement_lines(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    p_requirement_line_rec     IN    Requirement_Lines_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_requirement_lines';
 BEGIN

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_REQUIREMENT_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUIREMENT_LINE_ID   => p_requirement_line_rec.REQUIREMENT_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUIREMENT_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUIREMENT_HEADER_ID   => p_requirement_line_rec.REQUIREMENT_HEADER_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_INVENTORY_ITEM_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_INVENTORY_ITEM_ID   => p_requirement_line_rec.INVENTORY_ITEM_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_UOM_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_UOM_CODE   => p_requirement_line_rec.UOM_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUIRED_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUIRED_QUANTITY   => p_requirement_line_rec.REQUIRED_QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIP_COMPLETE_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIP_COMPLETE_FLAG   => p_requirement_line_rec.SHIP_COMPLETE_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LIKELIHOOD(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LIKELIHOOD   => p_requirement_line_rec.LIKELIHOOD,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REVISION(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REVISION   => p_requirement_line_rec.REVISION,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SOURCE_ORGANIZATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SOURCE_ORGANIZATION_ID   => p_requirement_line_rec.SOURCE_ORGANIZATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SOURCE_SUBINVENTORY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SOURCE_SUBINVENTORY   => p_requirement_line_rec.SOURCE_SUBINVENTORY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORDERED_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ORDERED_QUANTITY   => p_requirement_line_rec.ORDERED_QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORDER_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ORDER_LINE_ID   => p_requirement_line_rec.ORDER_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RESERVATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RESERVATION_ID   => p_requirement_line_rec.RESERVATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORDER_BY_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ORDER_BY_DATE   => p_requirement_line_rec.ORDER_BY_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      IF (p_validation_level >= AS_UTILITY_PVT.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_Requirement_Lines_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          p_requirement_line_rec     =>    p_requirement_line_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');

END Validate_requirement_lines;

*/

End CSP_Requirement_Lines_PVT;

/
