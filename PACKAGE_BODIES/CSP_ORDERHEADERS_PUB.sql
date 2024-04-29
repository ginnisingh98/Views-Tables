--------------------------------------------------------
--  DDL for Package Body CSP_ORDERHEADERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_ORDERHEADERS_PUB" AS
/* $Header: cspptmhb.pls 115.7 2003/05/02 17:31:37 phegde ship $ */
-- Start of Comments
-- Package name     : CSP_ORDERHEADERS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_ORDERHEADERS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspptmhb.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public ORDERHEADERS record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private ORDERHEADERSrecord is returned for the private
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
PROCEDURE Convert_MOH_Values_To_Ids(
         P_MOH_Rec        IN   CSP_orderheaders_PUB.MOH_Rec_Type,
         x_pvt_MOH_rec    OUT NOCOPY   CSP_orderheaders_PVT.MOH_Rec_Type
)
IS
-- Hint: Declare cursor and local variables
-- Example: CURSOR C_Get_Lookup_Code(X_Lookup_Type VARCHAR2, X_Meaning VARCHAR2) IS
--          SELECT lookup_code
--          FROM   as_lookups
--          WHERE  lookup_type = X_Lookup_Type and nls_upper(meaning) = nls_upper(X_Meaning);
l_any_errors       BOOLEAN   := FALSE;
BEGIN
  -- Hint: Add logic to process value-id verification for ORDERHEADERS record.
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

    x_pvt_MOH_rec.HEADER_ID := P_MOH_Rec.HEADER_ID;
    x_pvt_MOH_rec.CREATED_BY := P_MOH_Rec.CREATED_BY;
    x_pvt_MOH_rec.CREATION_DATE := P_MOH_Rec.CREATION_DATE;
    x_pvt_MOH_rec.LAST_UPDATED_BY := P_MOH_Rec.LAST_UPDATED_BY;
    x_pvt_MOH_rec.LAST_UPDATE_DATE := P_MOH_Rec.LAST_UPDATE_DATE;
    x_pvt_MOH_rec.LAST_UPDATE_LOGIN := P_MOH_Rec.LAST_UPDATE_LOGIN;
    x_pvt_MOH_rec.CARRIER := P_MOH_Rec.CARRIER;
    x_pvt_MOH_rec.SHIPMENT_METHOD := P_MOH_Rec.SHIPMENT_METHOD;
    x_pvt_MOH_rec.AUTORECEIPT_FLAG := P_MOH_Rec.AUTORECEIPT_FLAG;
    x_pvt_MOH_rec.ATTRIBUTE_CATEGORY := P_MOH_Rec.ATTRIBUTE_CATEGORY;
    X_PVT_MOH_REC.LOCATION_ID   := P_MOH_REC.LOCATION_ID;

    -- The following lines are removed because they are declared in the CSP_ORDERHEADERS_PUB.P_MOH_Rec record.
    /*
    x_pvt_MOH_rec.ATTRIBUTE1 := P_MOH_Rec.ATTRIBUTE1;
    x_pvt_MOH_rec.ATTRIBUTE2 := P_MOH_Rec.ATTRIBUTE2;
    x_pvt_MOH_rec.ATTRIBUTE3 := P_MOH_Rec.ATTRIBUTE3;
    x_pvt_MOH_rec.ATTRIBUTE4 := P_MOH_Rec.ATTRIBUTE4;
    x_pvt_MOH_rec.ATTRIBUTE5 := P_MOH_Rec.ATTRIBUTE5;
    x_pvt_MOH_rec.ATTRIBUTE6 := P_MOH_Rec.ATTRIBUTE6;
    x_pvt_MOH_rec.ATTRIBUTE7 := P_MOH_Rec.ATTRIBUTE7;
    x_pvt_MOH_rec.ATTRIBUTE8 := P_MOH_Rec.ATTRIBUTE8;
    x_pvt_MOH_rec.ATTRIBUTE9 := P_MOH_Rec.ATTRIBUTE9;
    x_pvt_MOH_rec.ATTRIBUTE10 := P_MOH_Rec.ATTRIBUTE10;
    x_pvt_MOH_rec.ATTRIBUTE11 := P_MOH_Rec.ATTRIBUTE11;
    x_pvt_MOH_rec.ATTRIBUTE12 := P_MOH_Rec.ATTRIBUTE12;
    x_pvt_MOH_rec.ATTRIBUTE13 := P_MOH_Rec.ATTRIBUTE13;
    x_pvt_MOH_rec.ATTRIBUTE14 := P_MOH_Rec.ATTRIBUTE14;
    x_pvt_MOH_rec.ATTRIBUTE15 := P_MOH_Rec.ATTRIBUTE15;

    x_pvt_MOH_rec.ADDRESS1 := P_MOH_Rec.ADDRESS1;
    x_pvt_MOH_rec.ADDRESS2 := P_MOH_Rec.ADDRESS2;
    x_pvt_MOH_rec.ADDRESS3 := P_MOH_Rec.ADDRESS3;
    x_pvt_MOH_rec.ADDRESS4 := P_MOH_Rec.ADDRESS4;
    x_pvt_MOH_rec.CITY := P_MOH_Rec.CITY;
    x_pvt_MOH_rec.POSTAL_CODE := P_MOH_Rec.POSTAL_CODE;
    x_pvt_MOH_rec.STATE := P_MOH_Rec.STATE;
    x_pvt_MOH_rec.PROVINCE := P_MOH_Rec.PROVINCE;
    x_pvt_MOH_rec.COUNTRY := P_MOH_Rec.COUNTRY; */


  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END Convert_MOH_Values_To_Ids;
PROCEDURE Create_orderheaders(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_MOH_Rec     IN    MOH_Rec_Type  := G_MISS_MOH_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_HEADER_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_orderheaders';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_MOH_rec    CSP_ORDERHEADERS_PVT.MOH_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ORDERHEADERS_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'AS: Public API: Convert_MOH_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_MOH_Values_To_Ids (
            p_MOH_rec       =>  p_MOH_rec,
            x_pvt_MOH_rec   =>  l_pvt_MOH_rec
      );

    -- Calling Private package: Create_ORDERHEADERS
    -- Hint: Primary key needs to be returned
      CSP_orderheaders_PVT.Create_orderheaders(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_MOH_Rec  =>  l_pvt_MOH_Rec ,
    -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
      X_HEADER_ID     => x_HEADER_ID,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


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
End Create_orderheaders;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_orderheaders(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_MOH_Rec     IN    MOH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_orderheaders';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_MOH_rec  CSP_ORDERHEADERS_PVT.MOH_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_ORDERHEADERS_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'AS: Public API: Convert_MOH_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_MOH_Values_To_Ids (
            p_MOH_rec       =>  p_MOH_rec,
            x_pvt_MOH_rec   =>  l_pvt_MOH_rec
      );

    CSP_orderheaders_PVT.Update_orderheaders(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     => p_identity_salesforce_id,
    P_MOH_Rec  =>  l_pvt_MOH_Rec ,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


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
End Update_orderheaders;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_orderheaders(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_MOH_Rec     IN MOH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_orderheaders';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_MOH_rec  CSP_ORDERHEADERS_PVT.MOH_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_ORDERHEADERS_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'AS: Public API: Convert_MOH_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_MOH_Values_To_Ids (
            p_MOH_rec       =>  p_MOH_rec,
            x_pvt_MOH_rec   =>  l_pvt_MOH_rec
      );

    CSP_orderheaders_PVT.Delete_orderheaders(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id      => p_identity_salesforce_id,
    P_MOH_Rec  => l_pvt_MOH_Rec,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


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
End Delete_orderheaders;


PROCEDURE Get_orderheaders(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_MOH_Rec     IN    CSP_orderheaders_PUB.MOH_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   CSP_orderheaders_PUB.MOH_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_MOH_Tbl  OUT NOCOPY  CSP_orderheaders_PUB.MOH_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_orderheaders';
l_api_version_number      CONSTANT NUMBER   := 2.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_ORDERHEADERS_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Debug Message
    JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: - Calling PVT.Get_ORDERHEADERS');
/*
    CSP_orderheaders_PVT.Get_orderheaders(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_id     => p_identity_salesforce_id,
    P_MOH_Rec  =>  P_MOH_Rec,
    p_rec_requested              => p_rec_requested,
    p_start_rec_prt              => p_start_rec_prt,
    p_return_tot_count           => p_return_tot_count,
    p_order_by_rec               => p_order_by_rec,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data,
    X_MOH_Tbl  => X_MOH_Tbl,
    x_returned_rec_count         => x_returned_rec_count,
    x_next_rec_ptr               => x_next_rec_ptr,
    x_tot_rec_count              => x_tot_rec_count
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


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
End Get_orderheaders;


End CSP_ORDERHEADERS_PUB;

/
