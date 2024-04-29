--------------------------------------------------------
--  DDL for Package Body AST_GRP_CAMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_GRP_CAMP_PUB" as
/* $Header: astpgcab.pls 115.3 2002/02/05 18:04:02 pkm ship      $ */
-- Start of Comments
-- Package name     : ast_grp_camp_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ast_grp_camp_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'astpgcab.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public grp_camp record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private grp_camprecord is returned for the private
-- API call.
--
-- Conversions:
--
-- Notes
--
-- 1. IDs take precedence over values. If both are present for a field, ID is used,
--    the value based parameter is ignored and a warning message is created.
-- 2. This is automatically generated procedure, it converts public record type to
--    private record type for all attributes.
--    Developer must manually add conversion logic to the attributes.
--
-- End of Comments
PROCEDURE Convert_grp_camp_Values_To_Ids(
         P_grp_camp_Rec        IN   ast_grp_camp_PUB.grp_camp_Rec_Type,
         x_pvt_grp_camp_rec    OUT   ast_grp_camp_PVT.grp_camp_Rec_Type
)
IS
-- Hint: Declare cursor and local variables
-- Example: CURSOR C_Get_Lookup_Code(X_Lookup_Type VARCHAR2, X_Meaning VARCHAR2) IS
--          SELECT lookup_code
--          FROM   as_lookups
--          WHERE  lookup_type = X_Lookup_Type and nls_upper(meaning) = nls_upper(X_Meaning);
l_any_errors       BOOLEAN   := FALSE;
BEGIN
  -- Hint: Add logic to process value-id verification for grp_camp record.
  --       Value based parameters should be converted to their equivalent ids.
  --       Each value should resolve into one and only one id.
  --       If this condition is not satisfied, API must report an error and assign l_any_errors to TRUE.
  -- Example: Process Lead Source/Lead Source Code
  -- If(p_opp_rec.lead_source_code is NOT NULL and p_opp_rec.lead_source_code <> FND_API.G_MISS_CHAR)
  -- THEN
  --     p_pvt_opp_rec.lead_source_code := p_opp_rec.lead_source_code;
  --     IF(p_opp_rec.lead_source is NOT NULL and p_opp_rec.lead_source <> FND_API.G_MISS_CHAR)
  --     THEN
  --         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  --         THEN
  --             FND_MESSAGE.Set_Name('AS','API_ATTRIBUTE_IGNORED');
  --             FND_MESSAGE.Set_Token('COLUMN','LEAD_SOURCE',FALSE);
  --             FND_MSG_PUB.Add;
  --         END IF;
  --     END IF;
  -- ELSIF(p_opp_rec.lead_source is NOT NULL and p_opp_rec.lead_source <> FND_API.G_MISS_CHAR)
  -- THEN
  --     OPEN C_Get_Lookup_Code('LEAD_SOURCE', p_opp_rec.lead_source);
  --     FETCH C_Get_Lookup_Code INTO l_val;
  --     CLOSE C_Get_Lookup_Code;
  --     p_pvt_opp_rec.lead_source_code := l_val;
  --     IF(l_val IS NULL)
  --     THEN
  --         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
  --         THEN
  --             FND_MESSAGE.Set_Name('AS','API_ATTRIBUTE_CONVERSION_ERROR'
  --             FND_MESSAGE.Set_Token('COLUMN','LEAD_SOURCE', FALSE
  --             FND_MESSAGE.Set_Token('VALUE', p_opp_rec.lead_source, FALSE
  --             FND_MSG_PUB.Add;
  --         END IF;
  --         l_any_errors := TRUE;
  --     END IF;
  -- ELSE
  --     p_pvt_opp_rec.lead_source_code := NULL;
  -- END IF;


  -- Now copy the rest of the columns to the private record
  -- Hint: We provide copy all columns to the private record.
  --       Developer should delete those fields which are used by Value-Id conversion above
    -- Hint: Developer should remove some of the following statements because of inconsistent column name between table and view.
/*
    x_pvt_grp_camp_rec.GROUP_CAMPAIGN_ID := P_grp_camp_Rec.GROUP_CAMPAIGN_ID;
    x_pvt_grp_camp_rec.GROUP_ID := P_grp_camp_Rec.GROUP_ID;
    x_pvt_grp_camp_rec.CAMPAIGN_ID := P_grp_camp_Rec.CAMPAIGN_ID;
    x_pvt_grp_camp_rec.START_DATE := P_grp_camp_Rec.START_DATE;
    x_pvt_grp_camp_rec.END_DATE := P_grp_camp_Rec.END_DATE;
    x_pvt_grp_camp_rec.ENABLED_FLAG := P_grp_camp_Rec.ENABLED_FLAG;
    x_pvt_grp_camp_rec.LAST_UPDATE_DATE := P_grp_camp_Rec.LAST_UPDATE_DATE;
    x_pvt_grp_camp_rec.LAST_UPDATED_BY := P_grp_camp_Rec.LAST_UPDATED_BY;
    x_pvt_grp_camp_rec.LAST_UPDATE_LOGIN := P_grp_camp_Rec.LAST_UPDATE_LOGIN;
    x_pvt_grp_camp_rec.CREATED_BY := P_grp_camp_Rec.CREATED_BY;
    x_pvt_grp_camp_rec.CREATION_DATE := P_grp_camp_Rec.CREATION_DATE;
*/

  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END Convert_grp_camp_Values_To_Ids;
PROCEDURE Create_grp_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_grp_camp_Rec     IN    grp_camp_Rec_Type  := G_MISS_grp_camp_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_GROUP_CAMPAIGN_ID     OUT  NUMBER,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_grp_camp';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_grp_camp_rec    ast_grp_camp_PVT.grp_camp_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_grp_camp_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'AS: Public API: Convert_grp_camp_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_grp_camp_Values_To_Ids (
            p_grp_camp_rec       =>  p_grp_camp_rec,
            x_pvt_grp_camp_rec   =>  l_pvt_grp_camp_rec
      );

    -- Calling Private package: Create_grp_camp
    -- Hint: Primary key needs to be returned
      ast_grp_camp_PVT.Create_grp_camp(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_grp_camp_Rec  =>  l_pvt_grp_camp_Rec ,
    -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
      X_GROUP_CAMPAIGN_ID     => x_GROUP_CAMPAIGN_ID,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: ' || l_api_name || 'end');


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
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_grp_camp;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_grp_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_grp_camp_Rec     IN    grp_camp_Rec_Type,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_grp_camp';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_grp_camp_rec  ast_grp_camp_PVT.grp_camp_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_grp_camp_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'AS: Public API: Convert_grp_camp_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_grp_camp_Values_To_Ids (
            p_grp_camp_rec       =>  p_grp_camp_rec,
            x_pvt_grp_camp_rec   =>  l_pvt_grp_camp_rec
      );

    ast_grp_camp_PVT.Update_grp_camp(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     => p_identity_salesforce_id,
    P_grp_camp_Rec  =>  l_pvt_grp_camp_Rec ,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: ' || l_api_name || 'end');


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
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_grp_camp;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_grp_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_grp_camp_Rec     IN grp_camp_Rec_Type,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_grp_camp';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_grp_camp_rec  ast_grp_camp_PVT.grp_camp_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_grp_camp_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'AS: Public API: Convert_grp_camp_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_grp_camp_Values_To_Ids (
            p_grp_camp_rec       =>  p_grp_camp_rec,
            x_pvt_grp_camp_rec   =>  l_pvt_grp_camp_rec
      );

    ast_grp_camp_PVT.Delete_grp_camp(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id      => p_identity_salesforce_id,
    P_grp_camp_Rec  => l_pvt_grp_camp_Rec,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: ' || l_api_name || 'end');


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
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_grp_camp;


PROCEDURE Get_grp_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_grp_camp_Rec     IN    ast_grp_camp_PUB.grp_camp_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   ast_grp_camp_PUB.grp_camp_sort_rec_type,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,
    X_grp_camp_Tbl  OUT  ast_grp_camp_PUB.grp_camp_Tbl_Type,
    x_returned_rec_count         OUT  NUMBER,
    x_next_rec_ptr               OUT  NUMBER,
    x_tot_rec_count              OUT  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_grp_camp';
l_api_version_number      CONSTANT NUMBER   := 2.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_grp_camp_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: - Calling PVT.Get_grp_camp');
    ast_grp_camp_PVT.Get_grp_camp(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_id     => p_identity_salesforce_id,
    P_grp_camp_Rec  =>  P_grp_camp_Rec,
    p_rec_requested              => p_rec_requested,
    p_start_rec_prt              => p_start_rec_prt,
    p_return_tot_count           => p_return_tot_count,
  -- Hint: user defined record type
    p_order_by_rec               => p_order_by_rec,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data,
    X_grp_camp_Tbl  => X_grp_camp_Tbl,
    x_returned_rec_count         => x_returned_rec_count,
    x_next_rec_ptr               => x_next_rec_ptr,
    x_tot_rec_count              => x_tot_rec_count
    -- other optional parameters
    -- x_tot_rec_amount             => x_tot_rec_amount
    );



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ast', 'Public API: ' || l_api_name || 'end');


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
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Get_grp_camp;


End ast_grp_camp_PUB;

/
