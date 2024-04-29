--------------------------------------------------------
--  DDL for Package Body ASO_LINE_RLTSHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_LINE_RLTSHIP_PVT" as
/* $Header: asovlinb.pls 120.1 2005/06/29 12:42:06 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_LINE_RLTSHIP_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_LINE_RLTSHIP_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovlinb.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_line_rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_LINE_RLTSHIP_Rec     IN    ASO_quote_PUB.LINE_RLTSHIP_Rec_Type  := ASO_QUOTE_PUB.G_MISS_LINE_RLTSHIP_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_LINE_RELATIONSHIP_ID     OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_line_rltship';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_LINE_RLTSHIP_PVT;

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
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_line_rltship_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_LINE_RLTSHIP_Rec      =>  P_LINE_RLTSHIP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
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

/*
      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => NULL
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
--Commented by Bmishra on 01/23/2002 Bug # 2193415
/*
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          -- --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_line_rltship');

          -- Invoke validation procedures
          Validate_line_rltship(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => ASO_UTILITY_PVT.G_CREATE,
              P_LINE_RLTSHIP_Rec  =>  P_LINE_RLTSHIP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
-- End of commenting by Bmishra 01/23/2002 Bug # 2193415

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      -- --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');

      -- Invoke table handler(ASO_LINE_RELATIONSHIPS_PKG.Insert_Row)
        ASO_LINE_RELATIONSHIPS_PKG.Insert_Row(
          px_LINE_RELATIONSHIP_ID  => x_LINE_RELATIONSHIP_ID,
          p_CREATION_DATE          => SYSDATE,
          p_CREATED_BY             => G_USER_ID,
          p_LAST_UPDATED_BY         => G_USER_ID,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATE_LOGIN       => G_LOGIN_ID,
          p_REQUEST_ID              => p_LINE_RLTSHIP_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_LINE_RLTSHIP_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_LINE_RLTSHIP_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE => p_LINE_RLTSHIP_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_LINE_ID    => p_LINE_RLTSHIP_rec.QUOTE_LINE_ID,
          p_RELATED_QUOTE_LINE_ID  => p_LINE_RLTSHIP_rec.RELATED_QUOTE_LINE_ID,
   --     p_RELATIONAL_TYPE_CODE  => p_LINE_RLTSHIP_rec.RELATIONAL_TYPE_CODE,
          p_RECIPROCAL_FLAG   => p_LINE_RLTSHIP_rec.RECIPROCAL_FLAG,
          p_RELATIONSHIP_TYPE_CODE => p_LINE_RLTSHIP_rec.RELATIONSHIP_TYPE_CODE,
	     p_OBJECT_VERSION_NUMBER => p_LINE_RLTSHIP_rec.OBJECT_VERSION_NUMBER
		);
      -- Hint: Primary key should be returned.
      -- x_LINE_RELATIONSHIP_ID := px_LINE_RELATIONSHIP_ID;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
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
      -- ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_line_rltship_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_LINE_RLTSHIP_Rec      =>  P_LINE_RLTSHIP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
                  WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Create_line_rltship;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_line_rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
--    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_LINE_RLTSHIP_Rec     IN    ASO_quote_PUB.LINE_RLTSHIP_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )

 IS

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
Cursor C_Get_line_rltship(LINE_RELATIONSHIP_ID Number) IS
    Select --rowid,
           LINE_RELATIONSHIP_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           QUOTE_LINE_ID,
           RELATED_QUOTE_LINE_ID,
           RELATIONSHIP_TYPE_CODE,
           RECIPROCAL_FLAG
           -- RELATIONSHIP_TYPE_CODE
    From  ASO_LINE_RELATIONSHIPS
    where LINE_RELATIONSHIP_ID = P_LINE_RLTSHIP_Rec.LINE_RELATIONSHIP_ID;
    -- Hint: Developer need to provide Where clause
    -- For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_line_rltship';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
--l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_LINE_RLTSHIP_rec  ASO_QUOTE_PUB.LINE_RLTSHIP_Rec_Type;
l_tar_LINE_RLTSHIP_rec  ASO_QUOTE_PUB.LINE_RLTSHIP_Rec_Type := P_LINE_RLTSHIP_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_LINE_RLTSHIP_PVT;

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
      -- ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_line_rltship_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_LINE_RLTSHIP_Rec      =>  P_LINE_RLTSHIP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;

*/
      Open C_Get_line_rltship( l_tar_LINE_RLTSHIP_rec.LINE_RELATIONSHIP_ID);

      Fetch C_Get_line_rltship into
             --  l_rowid,
               l_ref_LINE_RLTSHIP_rec.LINE_RELATIONSHIP_ID,
               l_ref_LINE_RLTSHIP_rec.CREATION_DATE,
               l_ref_LINE_RLTSHIP_rec.CREATED_BY,
               l_ref_LINE_RLTSHIP_rec.LAST_UPDATED_BY,
               l_ref_LINE_RLTSHIP_rec.LAST_UPDATE_DATE,
               l_ref_LINE_RLTSHIP_rec.LAST_UPDATE_LOGIN,
               l_ref_LINE_RLTSHIP_rec.REQUEST_ID,
               l_ref_LINE_RLTSHIP_rec.PROGRAM_APPLICATION_ID,
               l_ref_LINE_RLTSHIP_rec.PROGRAM_ID,
               l_ref_LINE_RLTSHIP_rec.PROGRAM_UPDATE_DATE,
               l_ref_LINE_RLTSHIP_rec.QUOTE_LINE_ID,
               l_ref_LINE_RLTSHIP_rec.RELATED_QUOTE_LINE_ID,
         --      l_ref_LINE_RLTSHIP_rec.RELATIONAL_TYPE_CODE,
                l_ref_LINE_RLTSHIP_rec.RELATIONSHIP_TYPE_CODE,
               l_ref_LINE_RLTSHIP_rec.RECIPROCAL_FLAG;


       If ( C_Get_line_rltship%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('ASO', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'line_rltship', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       -- ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       Close     C_Get_line_rltship;



      If (l_tar_LINE_RLTSHIP_rec.last_update_date is NULL or
          l_tar_LINE_RLTSHIP_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_LINE_RLTSHIP_rec.last_update_date <> l_ref_LINE_RLTSHIP_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('ASO', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'line_rltship', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          -- ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_line_rltship');

          -- Invoke validation procedures
          Validate_line_rltship(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => ASO_UTILITY_PVT.G_UPDATE,
              P_LINE_RLTSHIP_Rec  =>  P_LINE_RLTSHIP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      -- ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(ASO_LINE_RELATIONSHIPS_PKG.Update_Row)
      ASO_LINE_RELATIONSHIPS_PKG.Update_Row(
          p_LINE_RELATIONSHIP_ID  => p_LINE_RLTSHIP_rec.LINE_RELATIONSHIP_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => p_LINE_RLTSHIP_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_LINE_RLTSHIP_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_LINE_RLTSHIP_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_LINE_RLTSHIP_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_LINE_ID  => p_LINE_RLTSHIP_rec.QUOTE_LINE_ID,
          p_RELATED_QUOTE_LINE_ID  => p_LINE_RLTSHIP_rec.RELATED_QUOTE_LINE_ID,
   --       p_RELATIONAL_TYPE_CODE  => p_LINE_RLTSHIP_rec.RELATIONAL_TYPE_CODE,
          p_RECIPROCAL_FLAG  => p_LINE_RLTSHIP_rec.RECIPROCAL_FLAG,
          p_RELATIONSHIP_TYPE_CODE  => p_LINE_RLTSHIP_rec.RELATIONSHIP_TYPE_CODE,
		p_OBJECT_VERSION_NUMBER => p_LINE_RLTSHIP_rec.OBJECT_VERSION_NUMBER);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      -- ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_line_rltship_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_LINE_RLTSHIP_Rec      =>  P_LINE_RLTSHIP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_line_rltship;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.



-- this procedure does the following:
-- if only the relationship_line_id is passed the relationship line is deleted and the delete is cascaded to the quote lines if necessary
-- if only line id is given then all relationship lines with the quote_line_id or related_quote_line_id equal to the line id are deleted.
-- if line id, related line id are passed and reciprocal flag is set to 'N'and the reciprocal flag is 'Y'
-- in the database then the relationship line is deleted and a new line is created with
-- related_quote_line_id = line_id and quote_line_id = related line id and reciprocal flag = 'N'




PROCEDURE Delete_line_rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_control_rec                IN  ASO_QUOTE_PUB.control_rec_type 	:= ASO_QUOTE_PUB.G_MISS_Control_Rec,
--    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_LINE_RLTSHIP_Rec     IN ASO_quote_PUB.LINE_RLTSHIP_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )

 IS

CURSOR C1(line_id NUMBER) IS
select line_relationship_id, quote_line_id, related_quote_line_id, relationship_type_code, reciprocal_flag
from aso_line_relationships
where quote_line_id = line_id;


CURSOR C2(line_id NUMBER) IS
select line_relationship_id
from aso_line_relationships
where related_quote_line_id = line_id;

CURSOR C3(line_id NUMBER, related_line_id NUMBER) IS
select line_relationship_id, quote_line_id, related_quote_line_id, relationship_type_code, reciprocal_flag
from aso_line_relationships
where quote_line_id = line_id
and related_quote_line_id = related_line_id;



l_api_name                CONSTANT VARCHAR2(30) := 'Delete_line_rltship';
l_api_version_number      CONSTANT NUMBER   := 1.0;
--identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

l_line_rltship_rec      ASO_quote_PUB.Line_Rltship_Rec_Type;
l_relationship_id       NUMBER;
l_qte_line_rec          ASO_QUOTE_PUB.qte_line_Rec_Type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_LINE_RLTSHIP_PVT;

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
      -- ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_line_rltship_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_LINE_RLTSHIP_Rec      =>  P_LINE_RLTSHIP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;


      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
 -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');
*/


IF (p_LINE_RLTSHIP_rec.quote_line_id <> FND_API.G_MISS_NUM  and
    p_LINE_RLTSHIP_rec.related_quote_line_id <> FND_API.G_MISS_NUM) THEN

   FOR i in C3(p_LINE_RLTSHIP_rec.quote_line_id, p_LINE_RLTSHIP_rec.related_quote_line_id) LOOP
   IF p_LINE_RLTSHIP_rec.reciprocal_flag = FND_API.G_MISS_CHAR OR
      p_LINE_RLTSHIP_rec.reciprocal_flag = FND_API.G_TRUE  OR
      p_LINE_RLTSHIP_rec.reciprocal_flag = i.reciprocal_flag THEN

      ASO_LINE_RELATIONSHIPS_PKG.Delete_Row(
          p_LINE_RELATIONSHIP_ID  => i.LINE_RELATIONSHIP_ID);

          IF  (i.RELATIONSHIP_TYPE_CODE = 'SERVICE'
             or i.RELATIONSHIP_TYPE_CODE = 'CONFIG') then
             null;


    l_qte_line_rec.quote_line_id := i.related_quote_line_id;

    ASO_quote_lines_PVT.Delete_Quote_Line(
    P_Api_Version_Number  => 1.0,
    P_qte_line_Rec        => l_qte_line_rec,
    p_control_rec         => p_control_rec,
    P_Update_Header_Flag  =>FND_API.G_FALSE,
    X_Return_Status       => x_return_status,
    X_Msg_Count           => x_msg_count,
    X_Msg_Data            => x_msg_data
    );
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


          END IF;
   ELSE

      ASO_LINE_RELATIONSHIPS_PKG.Delete_Row(
          p_LINE_RELATIONSHIP_ID  => i.LINE_RELATIONSHIP_ID);

  l_line_rltship_rec.quote_line_id := i.related_quote_line_id;
  l_line_rltship_rec.related_quote_line_id := i.quote_line_id;
--  l_line_rltship_rec.relational_type_code := i.relationship_type_code;
  l_line_rltship_rec.reciprocal_flag  := FND_API.G_FALSE;

 Create_line_rltship(
    P_Api_Version_Number       => 1.0,
    P_LINE_RLTSHIP_Rec         => l_line_rltship_rec,
    X_LINE_RELATIONSHIP_ID    => l_relationship_id,
    X_Return_Status           => x_return_status ,
    X_Msg_Count               => x_msg_count,
    X_Msg_Data                => x_msg_data
    );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;
  END LOOP;

ELSIF (p_LINE_RLTSHIP_rec.quote_line_id <> FND_API.G_MISS_NUM) THEN

      FOR i in C1(p_LINE_RLTSHIP_rec.quote_line_id) LOOP

         ASO_LINE_RELATIONSHIPS_PKG.Delete_Row(
          p_LINE_RELATIONSHIP_ID  => i.LINE_RELATIONSHIP_ID);

          IF  (i.RELATIONSHIP_TYPE_CODE = 'SERVICE'
             or i.RELATIONSHIP_TYPE_CODE = 'CONFIG') then
                 l_qte_line_rec.quote_line_id := i.related_quote_line_id;

    ASO_quote_lines_PVT.Delete_Quote_Line(
    P_Api_Version_Number  => 1.0,
    P_qte_line_Rec        => l_qte_line_rec,
    p_control_rec         => p_control_rec,
    P_Update_Header_Flag  =>FND_API.G_FALSE,
    X_Return_Status       => x_return_status,
    X_Msg_Count           => x_msg_count,
    X_Msg_Data            => x_msg_data
    );
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
         END IF;
   END LOOP;

   FOR i in C2(p_LINE_RLTSHIP_rec.quote_line_id) LOOP
          ASO_LINE_RELATIONSHIPS_PKG.Delete_Row(
          p_LINE_RELATIONSHIP_ID  => i.LINE_RELATIONSHIP_ID);
   END LOOP;


ELSIF (p_LINE_RLTSHIP_rec.line_relationship_id <> FND_API.G_MISS_NUM) THEN
       ASO_LINE_RELATIONSHIPS_PKG.Delete_Row(
          p_LINE_RELATIONSHIP_ID  => p_LINE_RLTSHIP_rec.LINE_RELATIONSHIP_ID);

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
 --     ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_line_rltship_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_LINE_RLTSHIP_Rec      =>  P_LINE_RLTSHIP_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Delete_line_rltship;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_LINE_RLTSHIP_Rec   IN  ASO_QUOTE_PUB.LINE_RLTSHIP_Rec_Type,
    p_cur_get_LINE_RLTSHIP   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Begins');
/*
      -- define all columns for ASO_QUOTE_LINES_V view
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 1, P_LINE_RLTSHIP_Rec.QUOTE_LINE_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 2, P_LINE_RLTSHIP_Rec.QUOTE_HEADER_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 3, P_LINE_RLTSHIP_Rec.REQUEST_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 4, P_LINE_RLTSHIP_Rec.PROGRAM_APPLICATION_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 5, P_LINE_RLTSHIP_Rec.PROGRAM_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 6, P_LINE_RLTSHIP_Rec.PROGRAM_UPDATE_DATE);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 7, P_LINE_RLTSHIP_Rec.ORG_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 8, P_LINE_RLTSHIP_Rec.LINE_CATEGORY_CODE, 30);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 9, P_LINE_RLTSHIP_Rec.ITEM_TYPE_CODE, 30);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 10, P_LINE_RLTSHIP_Rec.LINE_NUMBER);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 11, P_LINE_RLTSHIP_Rec.START_DATE_ACTIVE);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 12, P_LINE_RLTSHIP_Rec.END_DATE_ACTIVE);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 13, P_LINE_RLTSHIP_Rec.ORDER_LINE_TYPE_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 14, P_LINE_RLTSHIP_Rec.ORGANIZATION_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 15, P_LINE_RLTSHIP_Rec.INVENTORY_ITEM_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 16, P_LINE_RLTSHIP_Rec.QUANTITY);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 17, P_LINE_RLTSHIP_Rec.UOM_CODE, 3);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 18, P_LINE_RLTSHIP_Rec.MARKETING_SOURCE_CODE_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 19, P_LINE_RLTSHIP_Rec.PRICE_LIST_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 20, P_LINE_RLTSHIP_Rec.PRICE_LIST_NAME, 240);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 21, P_LINE_RLTSHIP_Rec.PRICE_LIST_LINE_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 22, P_LINE_RLTSHIP_Rec.CURRENCY_CODE, 15);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 23, P_LINE_RLTSHIP_Rec.LINE_LIST_PRICE);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 24, P_LINE_RLTSHIP_Rec.LINE_ADJUSTED_AMOUNT);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 25, P_LINE_RLTSHIP_Rec.LINE_ADJUSTED_PERCENT);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 26, P_LINE_RLTSHIP_Rec.LINE_QUOTE_PRICE);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 27, P_LINE_RLTSHIP_Rec.RELATED_ITEM_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 28, P_LINE_RLTSHIP_Rec.ITEM_RELATIONSHIP_TYPE, 15);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 29, P_LINE_RLTSHIP_Rec.ACCOUNTING_RULE_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 30, P_LINE_RLTSHIP_Rec.INVOICING_RULE_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 31, P_LINE_RLTSHIP_Rec.SPLIT_SHIPMENT_FLAG, 1);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 32, P_LINE_RLTSHIP_Rec.BACKORDER_FLAG, 1);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 33, P_LINE_RLTSHIP_Rec.QUOTE_LINE_DETAIL_ID);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 34, P_LINE_RLTSHIP_Rec.SERVICE_COTERMINATE_FLAG, 240);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 35, P_LINE_RLTSHIP_Rec.SERVICE_DURATION);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 36, P_LINE_RLTSHIP_Rec.SERVICE_UNIT_SELLING_PERCENT);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 37, P_LINE_RLTSHIP_Rec.SERVICE_UNIT_LIST_PERCENT);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 38, P_LINE_RLTSHIP_Rec.SERVICE_NUMBER);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 39, P_LINE_RLTSHIP_Rec.UNIT_PERCENT_BASE_PRICE);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 40, P_LINE_RLTSHIP_Rec.SERVICE_PERIOD, 240);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 41, P_LINE_RLTSHIP_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 42, P_LINE_RLTSHIP_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 43, P_LINE_RLTSHIP_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 44, P_LINE_RLTSHIP_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 45, P_LINE_RLTSHIP_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 46, P_LINE_RLTSHIP_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 47, P_LINE_RLTSHIP_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 48, P_LINE_RLTSHIP_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 49, P_LINE_RLTSHIP_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 50, P_LINE_RLTSHIP_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 51, P_LINE_RLTSHIP_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 52, P_LINE_RLTSHIP_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 53, P_LINE_RLTSHIP_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 54, P_LINE_RLTSHIP_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 55, P_LINE_RLTSHIP_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_LINE_RLTSHIP, 56, P_LINE_RLTSHIP_Rec.ATTRIBUTE15, 150);

      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Ends');
*/
null;
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_LINE_RLTSHIP   IN   NUMBER,
    X_LINE_RLTSHIP_Rec   OUT NOCOPY /* file.sql.39 change */    ASO_quote_PUB.LINE_RLTSHIP_Rec_Type
)
IS
BEGIN
null;
END Get_Column_Values;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_LINE_RLTSHIP_Rec   IN   ASO_quote_PUB.LINE_RLTSHIP_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_LINE_RLTSHIP   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_LINE_RLTSHIP_Rec.LINE_RELATIONSHIP_ID IS NOT NULL) AND (P_LINE_RLTSHIP_Rec.LINE_RELATIONSHIP_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_LINE_RLTSHIP, ':p_LINE_RELATIONSHIP_ID', P_LINE_RLTSHIP_Rec.LINE_RELATIONSHIP_ID);
      END IF;

      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Ends');
END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS
BEGIN
null;
END Gen_Select;

PROCEDURE Gen_LINE_RLTSHIP_Where(
    P_LINE_RLTSHIP_Rec     IN   ASO_quote_PUB.LINE_RLTSHIP_Rec_Type,
    x_LINE_RLTSHIP_where   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS
-- cursors to check if wildcard values '%' and '_' have been passed
-- as item values
-- return values from cursors
str_csr1   NUMBER;
str_csr2   NUMBER;
l_operator VARCHAR2(10);
BEGIN
      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Begins');

      -- There are three example for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_LINE_RLTSHIP_Rec.LINE_RELATIONSHIP_ID IS NOT NULL) AND (P_LINE_RLTSHIP_Rec.LINE_RELATIONSHIP_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_LINE_RLTSHIP_where IS NULL) THEN
              x_LINE_RLTSHIP_where := 'Where';
          ELSE
              x_LINE_RLTSHIP_where := x_LINE_RLTSHIP_where || ' AND ';
          END IF;
          x_LINE_RLTSHIP_where := x_LINE_RLTSHIP_where || 'P_LINE_RLTSHIP_Rec.LINE_RELATIONSHIP_ID = :p_LINE_RELATIONSHIP_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_LINE_RLTSHIP_Rec.CREATION_DATE IS NOT NULL) AND (P_LINE_RLTSHIP_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard

          str_csr1 := INSTR(P_LINE_RLTSHIP_Rec.CREATION_DATE, '%', 1, 1);

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard

          str_csr2 := INSTR(P_LINE_RLTSHIP_Rec.CREATION_DATE, '_', 1, 1);

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_LINE_RLTSHIP_where IS NULL) THEN
              x_LINE_RLTSHIP_where := 'Where ';
          ELSE
              x_LINE_RLTSHIP_where := x_LINE_RLTSHIP_where || ' AND ';
          END IF;
          x_LINE_RLTSHIP_where := x_LINE_RLTSHIP_where || 'P_LINE_RLTSHIP_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_LINE_RLTSHIP_Rec.RELATIONSHIP_TYPE_CODE IS NOT NULL) AND (P_LINE_RLTSHIP_Rec.RELATIONSHIP_TYPE_CODE <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          /*
		OPEN c_chk_str1(P_LINE_RLTSHIP_Rec.RELATIONSHIP_TYPE_CODE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;
		*/

		str_csr1 := INSTR(P_LINE_RLTSHIP_Rec.RELATIONSHIP_TYPE_CODE, '%', 1, 1);

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          /*
		OPEN c_chk_str2(P_LINE_RLTSHIP_Rec.RELATIONSHIP_TYPE_CODE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;
		*/

		str_csr2 := INSTR(P_LINE_RLTSHIP_Rec.RELATIONSHIP_TYPE_CODE, '%', 1, 1);

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_LINE_RLTSHIP_where IS NULL) THEN
              x_LINE_RLTSHIP_where := 'Where ';
          ELSE
              x_LINE_RLTSHIP_where := x_LINE_RLTSHIP_where || ' AND ';
          END IF;
          x_LINE_RLTSHIP_where := x_LINE_RLTSHIP_where || 'P_LINE_RLTSHIP_Rec.RELATIONAL_TYPE_CODE ' || l_operator || ' :p_RELATIONAL_TYPE_CODE';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Ends');

END Gen_LINE_RLTSHIP_Where;

-- Item-level validation procedures
PROCEDURE Validate_LINE_RELATIONSHIP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LINE_RELATIONSHIP_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_LINE_RELATIONSHIP_ID is NULL)
      THEN
          --ASO_UTILITY_PVT.Print('ERROR', 'Private line_rltship API: -Violate NOT NULL constraint(LINE_RELATIONSHIP_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LINE_RELATIONSHIP_ID is not NULL and p_LINE_RELATIONSHIP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LINE_RELATIONSHIP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;

            IF  p_LINE_RELATIONSHIP_ID is not NULL AND p_LINE_RELATIONSHIP_ID <> FND_API.G_MISS_NUM THEN

              select count(*) into l_count
              from aso_line_relationships
              where line_relationship_id = p_LINE_RELATIONSHIP_ID;

              IF l_count < 1 THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
            END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LINE_RELATIONSHIP_ID;


PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID is not NULL and p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUEST_ID;


PROCEDURE Validate_PROG_APPL_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROGRAM_APPLICATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_APPLICATION_ID is not NULL and p_PROGRAM_APPLICATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_APPLICATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROG_APPL_ID;


PROCEDURE Validate_PROGRAM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROGRAM_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_ID is not NULL and p_PROGRAM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROGRAM_ID;


PROCEDURE Validate_PROGRAM_UPDATE_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROGRAM_UPDATE_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_UPDATE_DATE is not NULL and p_PROGRAM_UPDATE_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_UPDATE_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROGRAM_UPDATE_DATE;


PROCEDURE Validate_QUOTE_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUOTE_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_QUOTE_LINE_ID is NULL)
      THEN
          --ASO_UTILITY_PVT.Print('ERROR', 'Private line_rltship API: -Violate NOT NULL constraint(QUOTE_LINE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

           IF p_QUOTE_LINE_ID is not NULL AND p_QUOTE_LINE_ID <> FND_API.G_MISS_NUM THEN
               select count(*) into l_count
               from aso_quote_lines_all
               where quote_line_id = p_QUOTE_LINE_ID;

               if l_count < 1 then
                  x_return_status := FND_API.G_RET_STS_ERROR;
               end if;
           END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUOTE_LINE_ID;


PROCEDURE Validate_RELATED_QUOTE_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATED_QUOTE_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_RELATED_QUOTE_LINE_ID is NULL)
      THEN
          --ASO_UTILITY_PVT.Print('ERROR', 'Private line_rltship API: -Violate NOT NULL constraint(RELATED_QUOTE_LINE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


              IF p_RELATED_QUOTE_LINE_ID is not NULL AND p_RELATED_QUOTE_LINE_ID <> FND_API.G_MISS_NUM THEN
               select count(*) into l_count
               from aso_quote_lines_all
               where quote_line_id = p_RELATED_QUOTE_LINE_ID;

               if l_count < 1 then
                  x_return_status := FND_API.G_RET_STS_ERROR;
               end if;
           END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RELATED_QUOTE_LINE_ID;


PROCEDURE Validate_RELATIONAL_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATIONAL_TYPE_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RELATIONAL_TYPE_CODE is not NULL and p_RELATIONAL_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RELATIONAL_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

         IF  p_RELATIONAL_TYPE_CODE is not NULL AND  p_RELATIONAL_TYPE_CODE <> FND_API.G_MISS_NUM THEN
            select count(*) into l_count
          from aso_lookups
          where lookup_type = 'ASO_LINE_RELATIONSHIP_TYPE'
          and lookup_code = p_RELATIONAL_TYPE_CODE;

          if l_count < 1 then
          x_return_status := FND_API.G_RET_STS_ERROR;
          end if;
        END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RELATIONAL_TYPE_CODE;


PROCEDURE Validate_RECIPROCAL_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RECIPROCAL_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RECIPROCAL_FLAG is not NULL and p_RECIPROCAL_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RECIPROCAL_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      IF(p_validation_mode is not NULL AND  p_RECIPROCAL_FLAG <> FND_API.G_MISS_CHAR)THEN
             IF (p_RECIPROCAL_FLAG <> FND_API.G_TRUE and p_RECIPROCAL_FLAG <> FND_API.G_FALSE) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RECIPROCAL_FLAG;


PROCEDURE Validate_RLTSHIP_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATIONSHIP_TYPE_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */       ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RELATIONSHIP_TYPE_CODE is not NULL and p_RELATIONSHIP_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RELATIONSHIP_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RLTSHIP_TYPE_CODE;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = ASO_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_LINE_RLTSHIP_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LINE_RLTSHIP_Rec     IN    ASO_quote_PUB.LINE_RLTSHIP_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
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
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LINE_RLTSHIP_Rec;

PROCEDURE Validate_line_rltship(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_LINE_RLTSHIP_Rec     IN    ASO_quote_PUB.LINE_RLTSHIP_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_line_rltship';
 BEGIN

      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_LINE_RELATIONSHIP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LINE_RELATIONSHIP_ID   => P_LINE_RLTSHIP_Rec.LINE_RELATIONSHIP_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUEST_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUEST_ID   => P_LINE_RLTSHIP_Rec.REQUEST_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROG_APPL_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROGRAM_APPLICATION_ID   => P_LINE_RLTSHIP_Rec.PROGRAM_APPLICATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROGRAM_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROGRAM_ID   => P_LINE_RLTSHIP_Rec.PROGRAM_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROGRAM_UPDATE_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROGRAM_UPDATE_DATE   => P_LINE_RLTSHIP_Rec.PROGRAM_UPDATE_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QUOTE_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUOTE_LINE_ID   => P_LINE_RLTSHIP_Rec.QUOTE_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RELATED_QUOTE_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RELATED_QUOTE_LINE_ID   => P_LINE_RLTSHIP_Rec.RELATED_QUOTE_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RECIPROCAL_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RECIPROCAL_FLAG   => P_LINE_RLTSHIP_Rec.RECIPROCAL_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RLTSHIP_TYPE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RELATIONSHIP_TYPE_CODE   => P_LINE_RLTSHIP_Rec.RELATIONSHIP_TYPE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_LINE_RLTSHIP_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_LINE_RLTSHIP_Rec     =>    P_LINE_RLTSHIP_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');

END Validate_line_rltship;

End ASO_LINE_RLTSHIP_PVT;

/
