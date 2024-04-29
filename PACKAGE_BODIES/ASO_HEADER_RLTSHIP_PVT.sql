--------------------------------------------------------
--  DDL for Package Body ASO_HEADER_RLTSHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_HEADER_RLTSHIP_PVT" as
/* $Header: asovhedb.pls 120.1 2005/06/29 12:41:41 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_HEADER_RLTSHIP_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_HEADER_RLTSHIP_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovhedb.pls';
PROCEDURE Create_header_rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_HEADER_RLTSHIP_Rec     IN    ASO_QUOTE_PUB.HEADER_RLTSHIP_Rec_Type  := ASO_QUOTE_PUB.G_MISS_HEADER_RLTSHIP_REC,
    X_HEADER_RELATIONSHIP_ID     OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_header_rltship';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
--l_identity_sales_member_rec ASO_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_HEADER_RLTSHIP_PVT;

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



      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_header_rltship(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => ASO_UTILITY_PVT.G_CREATE,
              P_HEADER_RLTSHIP_Rec  =>  P_HEADER_RLTSHIP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);

      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(ASO_HEADER_RELATIONSHIPS_PKG.Insert_Row)
      ASO_HEADER_RELATIONSHIPS_PKG.Insert_Row(
          px_HEADER_RELATIONSHIP_ID  => x_HEADER_RELATIONSHIP_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => p_HEADER_RLTSHIP_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_HEADER_RLTSHIP_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_HEADER_RLTSHIP_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_HEADER_RLTSHIP_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID  => p_HEADER_RLTSHIP_rec.QUOTE_HEADER_ID,
          p_RELATED_HEADER_ID  => p_HEADER_RLTSHIP_rec.RELATED_HEADER_ID,
          p_RELATIONSHIP_TYPE_CODE  => p_HEADER_RLTSHIP_rec.RELATIONAL_TYPE_CODE,
          p_RECIPROCAL_FLAG  => p_HEADER_RLTSHIP_rec.RECIPROCAL_FLAG,
		p_OBJECT_VERSION_NUMBER => p_HEADER_RLTSHIP_rec.OBJECT_VERSION_NUMBER
		);

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


      -- Standard call to get message count and if count is 1, get message info.
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

End Create_header_rltship;

PROCEDURE Update_header_rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_HEADER_RLTSHIP_Rec     IN    ASO_quote_PUB.HEADER_RLTSHIP_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS

G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
Cursor C_Get_header_rltship(P_HEADER_RELATIONSHIP_ID Number) IS
    Select --rowid,
           HEADER_RELATIONSHIP_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           QUOTE_HEADER_ID,
           RELATED_HEADER_ID,
           RELATIONSHIP_TYPE_CODE,
           RECIPROCAL_FLAG
    From  ASO_HEADER_RELATIONSHIPS
    where HEADER_RELATIONSHIP_ID = P_HEADER_RELATIONSHIP_ID;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_header_rltship';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
--l_identity_sales_member_rec   ASO_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_HEADER_RLTSHIP_rec  ASO_quote_PUB.HEADER_RLTSHIP_Rec_Type;
l_tar_HEADER_RLTSHIP_rec  ASO_quote_PUB.HEADER_RLTSHIP_Rec_Type := P_HEADER_RLTSHIP_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_HEADER_RLTSHIP_PVT;

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



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      Open C_Get_header_rltship( l_tar_HEADER_RLTSHIP_rec.HEADER_RELATIONSHIP_ID);

      Fetch C_Get_header_rltship into
              -- l_rowid,
               l_ref_HEADER_RLTSHIP_rec.HEADER_RELATIONSHIP_ID,
               l_ref_HEADER_RLTSHIP_rec.CREATION_DATE,
               l_ref_HEADER_RLTSHIP_rec.CREATED_BY,
               l_ref_HEADER_RLTSHIP_rec.LAST_UPDATE_DATE,
               l_ref_HEADER_RLTSHIP_rec.LAST_UPDATED_BY,
               l_ref_HEADER_RLTSHIP_rec.LAST_UPDATE_LOGIN,
               l_ref_HEADER_RLTSHIP_rec.REQUEST_ID,
               l_ref_HEADER_RLTSHIP_rec.PROGRAM_APPLICATION_ID,
               l_ref_HEADER_RLTSHIP_rec.PROGRAM_ID,
               l_ref_HEADER_RLTSHIP_rec.PROGRAM_UPDATE_DATE,
               l_ref_HEADER_RLTSHIP_rec.QUOTE_HEADER_ID,
               l_ref_HEADER_RLTSHIP_rec.RELATED_HEADER_ID,
               l_ref_HEADER_RLTSHIP_rec.RELATIONAL_TYPE_CODE,
               l_ref_HEADER_RLTSHIP_rec.RECIPROCAL_FLAG;

       If ( C_Get_header_rltship%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('ASO', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'header_rltship', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       Close     C_Get_header_rltship;

      If (l_tar_HEADER_RLTSHIP_rec.last_update_date is NULL or
          l_tar_HEADER_RLTSHIP_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_HEADER_RLTSHIP_rec.last_update_date <> l_ref_HEADER_RLTSHIP_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('ASO', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'header_rltship', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Invoke table handler(ASO_HEADER_RELATIONSHIPS_PKG.Update_Row)
      ASO_HEADER_RELATIONSHIPS_PKG.Update_Row(
          p_HEADER_RELATIONSHIP_ID  => p_HEADER_RLTSHIP_rec.HEADER_RELATIONSHIP_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => p_HEADER_RLTSHIP_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_HEADER_RLTSHIP_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_HEADER_RLTSHIP_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_HEADER_RLTSHIP_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID  => p_HEADER_RLTSHIP_rec.QUOTE_HEADER_ID,
          p_RELATED_HEADER_ID  => p_HEADER_RLTSHIP_rec.RELATED_HEADER_ID,
          p_RELATIONSHIP_TYPE_CODE  => p_HEADER_RLTSHIP_rec.RELATIONAL_TYPE_CODE,
          p_RECIPROCAL_FLAG  => p_HEADER_RLTSHIP_rec.RECIPROCAL_FLAG,
		P_OBJECT_VERSION_NUMBER => p_HEADER_RLTSHIP_rec.OBJECT_VERSION_NUMBER
		);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
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
End Update_header_rltship;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_header_rltship
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_HEADER_RLTSHIP_Rec     IN HEADER_RLTSHIP_Rec_Type  Required
--
--   OUT NOCOPY /* file.sql.39 change */  :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */    VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */    NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */    VARCHAR2
PROCEDURE Delete_header_rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_HEADER_RLTSHIP_id     IN  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_header_rltship';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_HEADER_RLTSHIP_PVT;

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Invoke table handler(ASO_HEADER_RELATIONSHIPS_PKG.Delete_Row)
      ASO_HEADER_RELATIONSHIPS_PKG.Delete_Row(
          p_HEADER_RELATIONSHIP_ID  => p_HEADER_RLTSHIP_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
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
End Delete_header_rltship;

PROCEDURE Delete_header_rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_HEADER_id                    IN  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
CURSOR related_headers(p_header_id NUMBER) IS
 SELECT header_relationship_id FROM
 ASO_HEADER_RELATIONSHIPS
 WHERE QUOTE_HEADER_ID = p_header_id
 OR RELATED_HEADER_ID = p_header_id;


l_api_name                CONSTANT VARCHAR2(30) := 'Delete_header_rltship';
l_api_version_number      CONSTANT NUMBER   := 1.0;
BEGIN
  -- Standard Start of API savepoint
      SAVEPOINT DELETE_HEADER_RLTSHIP_PVT;

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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
       FOR i in related_headers(p_header_id) LOOP
         Delete_header_rltship(
            P_Api_Version_Number     => 1.0,
            p_validation_level        => p_validation_level,
            P_HEADER_RLTSHIP_id    => i.header_relationship_id,
    	    X_Return_Status       => x_return_status,
    	    X_Msg_Count           => x_msg_count,
    	    X_Msg_Data            => x_msg_data
    ) ;
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

     -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


    -- Standard call to get message count and if count is 1, get message info.
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
End Delete_header_rltship;


PROCEDURE Validate_HEADER_RLTSHIP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_HEADER_RELATIONSHIP_ID                IN   NUMBER,
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

      -- validate NOT NULL column
      IF(p_HEADER_RELATIONSHIP_ID is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_HEADER_RLTSHIP_ID;

PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUEST_ID;

    PROCEDURE Validate_PROGRAM_APPL_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROGRAM_APPLICATION_ID                IN   NUMBER,
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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROGRAM_APPL_ID;

PROCEDURE Validate_PROGRAM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROGRAM_ID                IN   NUMBER,
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


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROGRAM_UPDATE_DATE;

PROCEDURE Validate_QUOTE_HEADER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUOTE_HEADER_ID                IN   NUMBER,
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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUOTE_HEADER_ID;

PROCEDURE Validate_RELATED_HEADER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATED_HEADER_ID                IN   NUMBER,
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
        FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );



END Validate_RELATED_HEADER_ID;

PROCEDURE Validate_RLTSHIP_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATIONSHIP_TYPE_CODE                IN   VARCHAR2,
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
      IF(p_RELATIONSHIP_TYPE_CODE is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF((p_validation_mode = ASO_UTILITY_PVT.G_CREATE) OR (p_validation_mode = ASO_UTILITY_PVT.G_UPDATE and p_RELATIONSHIP_TYPE_CODE <> FND_API.G_MISS_CHAR))
      THEN
          -- Hint: Validate data
          -- IF p_RELATIONSHIP_TYPE_CODE is not NULL and p_RELATIONSHIP_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;


          select count(*) into l_count
          from aso_lookups
          where lookup_type = 'ASO_HEADER_RELATIONSHIP_TYPE'
          and lookup_code = p_RELATIONSHIP_TYPE_CODE;

          if l_count < 1 then
          x_return_status := FND_API.G_RET_STS_ERROR;
          end if;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RLTSHIP_TYPE_CODE;

PROCEDURE Validate_RECIPROCAL_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RECIPROCAL_FLAG                IN   VARCHAR2,
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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RECIPROCAL_FLAG;

PROCEDURE Validate_HEADER_RLTSHIP_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_HEADER_RLTSHIP_Rec     IN   ASO_QUOTE_PUB.HEADER_RLTSHIP_Rec_Type,
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


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_HEADER_RLTSHIP_Rec;

PROCEDURE Validate_header_rltship(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_HEADER_RLTSHIP_Rec         IN   ASO_quote_PUB.HEADER_RLTSHIP_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_header_rltship';
 BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

          Validate_QUOTE_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUOTE_HEADER_ID   => P_HEADER_RLTSHIP_Rec.QUOTE_HEADER_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RELATED_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RELATED_HEADER_ID   => P_HEADER_RLTSHIP_Rec.RELATED_HEADER_ID,
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
              p_RELATIONSHIP_TYPE_CODE   => P_HEADER_RLTSHIP_Rec.RELATIONAL_TYPE_CODE,
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
              p_RECIPROCAL_FLAG   => P_HEADER_RLTSHIP_Rec.RECIPROCAL_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */   parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

END Validate_header_rltship;

End ASO_HEADER_RLTSHIP_PVT;

/
