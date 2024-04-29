--------------------------------------------------------
--  DDL for Package Body CSP_RS_CUST_RELATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_RS_CUST_RELATION_PUB" as
/* $Header: cspprcrb.pls 115.6 2003/05/02 17:26:07 phegde noship $ */
-- Start of Comments
-- Package name     : CSP_RS_CUST_RELATION_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_RS_CUST_RELATION_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspprcrb.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public RS_CUST_RELATION record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private RS_CUST_RELATIONrecord is returned for the private
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
PROCEDURE Convert_RCR_Values_To_Ids(
         P_RCR_Rec        IN   CSP_rs_cust_relation_PUB.RCR_Rec_Type,
         x_pvt_RCR_rec    OUT NOCOPY   CSP_rs_cust_relation_PVT.RCR_Rec_Type
)
IS
-- Hint: Declare cursor and local variables
-- Example: CURSOR C_Get_Lookup_Code(X_Lookup_Type VARCHAR2, X_Meaning VARCHAR2) IS
--          SELECT lookup_code
--          FROM   as_lookups
--          WHERE  lookup_type = X_Lookup_Type and nls_upper(meaning) = nls_upper(X_Meaning);
l_any_errors       BOOLEAN   := FALSE;
BEGIN
  -- Hint: Add logic to process value-id verification for RS_CUST_RELATION record.
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
    x_pvt_RCR_rec.RS_CUST_RELATION_ID := P_RCR_Rec.RS_CUST_RELATION_ID;
    x_pvt_RCR_rec.RESOURCE_TYPE := P_RCR_Rec.RESOURCE_TYPE;
    x_pvt_RCR_rec.RESOURCE_ID := P_RCR_Rec.RESOURCE_ID;
    x_pvt_RCR_rec.CUSTOMER_ID := P_RCR_Rec.CUSTOMER_ID;
    x_pvt_RCR_rec.CREATED_BY := P_RCR_Rec.CREATED_BY;
    x_pvt_RCR_rec.CREATION_DATE := P_RCR_Rec.CREATION_DATE;
    x_pvt_RCR_rec.LAST_UPDATED_BY := P_RCR_Rec.LAST_UPDATED_BY;
    x_pvt_RCR_rec.LAST_UPDATE_DATE := P_RCR_Rec.LAST_UPDATE_DATE;
    x_pvt_RCR_rec.LAST_UPDATE_LOGIN := P_RCR_Rec.LAST_UPDATE_LOGIN;
    x_pvt_RCR_rec.ATTRIBUTE_CATEGORY := P_RCR_Rec.ATTRIBUTE_CATEGORY;
    x_pvt_RCR_rec.ATTRIBUTE1 := P_RCR_Rec.ATTRIBUTE1;
    x_pvt_RCR_rec.ATTRIBUTE2 := P_RCR_Rec.ATTRIBUTE2;
    x_pvt_RCR_rec.ATTRIBUTE3 := P_RCR_Rec.ATTRIBUTE3;
    x_pvt_RCR_rec.ATTRIBUTE4 := P_RCR_Rec.ATTRIBUTE4;
    x_pvt_RCR_rec.ATTRIBUTE5 := P_RCR_Rec.ATTRIBUTE5;
    x_pvt_RCR_rec.ATTRIBUTE6 := P_RCR_Rec.ATTRIBUTE6;
    x_pvt_RCR_rec.ATTRIBUTE7 := P_RCR_Rec.ATTRIBUTE7;
    x_pvt_RCR_rec.ATTRIBUTE8 := P_RCR_Rec.ATTRIBUTE8;
    x_pvt_RCR_rec.ATTRIBUTE9 := P_RCR_Rec.ATTRIBUTE9;
    x_pvt_RCR_rec.ATTRIBUTE10 := P_RCR_Rec.ATTRIBUTE10;
    x_pvt_RCR_rec.ATTRIBUTE11 := P_RCR_Rec.ATTRIBUTE11;
    x_pvt_RCR_rec.ATTRIBUTE12 := P_RCR_Rec.ATTRIBUTE12;
    x_pvt_RCR_rec.ATTRIBUTE13 := P_RCR_Rec.ATTRIBUTE13;
    x_pvt_RCR_rec.ATTRIBUTE14 := P_RCR_Rec.ATTRIBUTE14;
    x_pvt_RCR_rec.ATTRIBUTE15 := P_RCR_Rec.ATTRIBUTE15;
*/

  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END Convert_RCR_Values_To_Ids;


PROCEDURE Create_rs_cust_relation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RCR_Rec     IN    RCR_Rec_Type  := G_MISS_RCR_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_RS_CUST_RELATION_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_rs_cust_relation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_RCR_rec    CSP_RS_CUST_RELATION_PVT.RCR_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_RS_CUST_RELATION_PUB;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS: Public API: Convert_RCR_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_RCR_Values_To_Ids (
            p_RCR_rec       =>  p_RCR_rec,
            x_pvt_RCR_rec   =>  l_pvt_RCR_rec
      );

    -- Calling Private package: Create_RS_CUST_RELATION
    -- Hint: Primary key needs to be returned
      CSP_rs_cust_relation_PVT.Create_rs_cust_relation(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_RCR_Rec  =>  l_pvt_RCR_Rec ,
    -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
      X_RS_CUST_RELATION_ID     => x_RS_CUST_RELATION_ID,
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_rs_cust_relation;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_rs_cust_relation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_RCR_Rec     IN    RCR_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_rs_cust_relation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_RCR_rec  CSP_RS_CUST_RELATION_PVT.RCR_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_RS_CUST_RELATION_PUB;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS: Public API: Convert_RCR_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_RCR_Values_To_Ids (
            p_RCR_rec       =>  p_RCR_rec,
            x_pvt_RCR_rec   =>  l_pvt_RCR_rec
      );

    CSP_rs_cust_relation_PVT.Update_rs_cust_relation(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     => p_identity_salesforce_id,
    P_RCR_Rec  =>  l_pvt_RCR_Rec ,
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_rs_cust_relation;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_rs_cust_relation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_RCR_Rec     IN RCR_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_rs_cust_relation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_RCR_rec  CSP_RS_CUST_RELATION_PVT.RCR_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_RS_CUST_RELATION_PUB;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS: Public API: Convert_RCR_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_RCR_Values_To_Ids (
            p_RCR_rec       =>  p_RCR_rec,
            x_pvt_RCR_rec   =>  l_pvt_RCR_rec
      );

    CSP_rs_cust_relation_PVT.Delete_rs_cust_relation(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id      => p_identity_salesforce_id,
    P_RCR_Rec  => l_pvt_RCR_Rec,
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_rs_cust_relation;


PROCEDURE Get_rs_cust_relation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_RCR_Rec     IN    CSP_rs_cust_relation_PUB.RCR_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   CSP_rs_cust_relation_PUB.RCR_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_RCR_Tbl  OUT NOCOPY  CSP_rs_cust_relation_PUB.RCR_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_rs_cust_relation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_RS_CUST_RELATION_PUB;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Public API: - Calling PVT.Get_RS_CUST_RELATION');
/*
    CSP_rs_cust_relation_PVT.Get_rs_cust_relation(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_id     => p_identity_salesforce_id,
    P_RCR_Rec  =>  P_RCR_Rec,
    p_rec_requested              => p_rec_requested,
    p_start_rec_prt              => p_start_rec_prt,
    p_return_tot_count           => p_return_tot_count,
  -- Hint: user defined record type
    p_order_by_rec               => p_order_by_rec,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data,
    X_RCR_Tbl  => X_RCR_Tbl,
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
*/
      --
      -- End of API body
      --

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Get_rs_cust_relation;


End CSP_RS_CUST_RELATION_PUB;

/
