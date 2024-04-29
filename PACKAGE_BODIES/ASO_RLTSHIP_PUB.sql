--------------------------------------------------------
--  DDL for Package Body ASO_RLTSHIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_RLTSHIP_PUB" as
/* $Header: asoprltb.pls 120.1 2005/06/29 12:37:44 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_RLTSHIP_PUB
-- Purpose          :
--   This package contains specification for pl/sql records and tables and the
--   Public API of Order Capture.
--
G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_RLTSHIP_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoprltb.pls';



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Line_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Line_Rltship_Tbl IN   Line_Rltship_Tbl_Type
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Line_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Line_Rltship_Rec      IN   ASO_QUOTE_PUB.Line_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_line_rltship_REC,
    X_line_relationship_id       OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'CREATE_LINE_RELATIONSHIP';
BEGIN
     -- Standard Start of API savepoint
      SAVEPOINT CREATE_LINE_RELATIONSHIP_PUB;

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
      --AS_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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


    ASO_LINE_RLTSHIP_PVT.Create_line_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_LINE_RLTSHIP_Rec         => P_LINE_RLTSHIP_Rec ,
    X_LINE_RELATIONSHIP_ID     => X_LINE_RELATIONSHIP_ID ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


End Create_line_relationship;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Line_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Line_Rltship_Tbl IN   Line_Rltship_Tbl_Type
--   Version : Current version 2.0
--   End of Comments

PROCEDURE Update_Line_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
 P_Line_Rltship_Rec      IN   ASO_QUOTE_PUB.Line_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_line_rltship_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'UPDATE_LINE_RELATIONSHIP';
BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT UPDATE_LINE_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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


    ASO_LINE_RLTSHIP_PVT.Update_line_rltship(
    P_Api_Version_Number  => 1.0,
    P_Init_Msg_List       => FND_API.G_FALSE,
    P_LINE_RLTSHIP_Rec    => P_LINE_RLTSHIP_Rec,
    X_Return_Status       => X_Return_Status   ,
    X_Msg_Count           => X_Msg_Count,
    X_Msg_Data            =>  X_Msg_Data
    );


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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


End Update_line_relationship;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Line_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Line_Rltship_Tbl IN   Line_Rltship_Tbl_Type
--   End of Comments
--

PROCEDURE Delete_Line_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_control_rec                IN  ASO_QUOTE_PUB.control_rec_type    := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Line_Rltship_Rec      IN   ASO_QUOTE_PUB.Line_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_line_rltship_rec,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'DELETE_LINE_RELATIONSHIP';
BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT DELETE_LINE_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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

    ASO_LINE_RLTSHIP_PVT.Delete_line_rltship(
    P_Api_Version_Number  => 1.0,
    P_Init_Msg_List       => FND_API.G_FALSE,
    p_control_rec         => p_control_rec,
    P_LINE_RLTSHIP_Rec    => P_LINE_RLTSHIP_Rec,
    X_Return_Status       => X_Return_Status   ,
    X_Msg_Count           => X_Msg_Count,
    X_Msg_Data            =>  X_Msg_Data
    );



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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


End Delete_line_relationship;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Header_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Header_Relationship_Rec IN   Header_Relationship_Rec_Type
--

PROCEDURE Create_Header_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Header_Rltship_Rec         IN   ASO_QUOTE_PUB.Header_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_header_rltship_REC,
    X_Header_rltship_id          OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'CREATE_HEADER_RELATIONSHIP';
BEGIN
null;

     -- Standard Start of API savepoint
      SAVEPOINT CREATE_HEADER_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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



    ASO_HEADER_RLTSHIP_PVT.Create_header_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_HEADER_RLTSHIP_Rec         => P_HEADER_RLTSHIP_Rec ,
    X_HEADER_RELATIONSHIP_ID        => X_HEADER_RLTSHIP_ID ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                   ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_header_relationship;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Header_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--   End of Comments
--
PROCEDURE Update_Header_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Header_Rltship_Rec      IN   ASO_QUOTE_PUB.Header_Rltship_Rec_Type := ASO_QUOTE_PUB.
G_MISS_header_rltship_REC,
    X_header_relationship_id       OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status                OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                    OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'UPDATE_HEADER_RELATIONSHIP';
BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT UPDATE_HEADER_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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



    ASO_HEADER_RLTSHIP_PVT.Update_header_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_HEADER_RLTSHIP_Rec         => P_HEADER_RLTSHIP_Rec ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );


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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                   ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                   ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                   ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


End Update_header_relationship;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Header_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Header_Relationship_Rec IN   Header_Relationship_Rec_Type
--   End of Comments
--
PROCEDURE Delete_Header_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Header_Rltship_Rec      IN   ASO_QUOTE_PUB.Header_Rltship_Rec_Type := ASO_QUOTE_PUB.
G_MISS_header_rltship_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'DELETE_HEADER_RELATIONSHIP';

BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT DELETE_HEADER_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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




   ASO_HEADER_RLTSHIP_PVT.Delete_header_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_HEADER_RLTSHIP_id         => P_HEADER_RLTSHIP_Rec.header_relationship_id ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Delete_header_relationship;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Party_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   End of Comments
--
PROCEDURE Create_Party_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Party_Rltship_Rec      IN   ASO_QUOTE_PUB.Party_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_party_rltship_REC,
    X_party_relationship_id      OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'CREATE_PARTY_RELATIONSHIP';
BEGIN

      SAVEPOINT CREATE_PARTY_RELATIONSHIP_PUB;

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,p_api_version_number,l_api_name,G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      --
      -- API body
      --

      -- Validate Environment
      IF FND_GLOBAL.User_Id IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;



     ASO_PARTY_RLTSHIP_PVT.Create_party_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_PARTY_RLTSHIP_Rec         => P_PARTY_RLTSHIP_Rec ,
    X_PARTY_RELATIONSHIP_ID        => X_PARTY_RELATIONSHIP_ID ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Create_party_relationship;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Party_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Party_Relationship_Rec IN   Party_Relationship_Rec_Type
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Update_Party_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Party_Rltship_Rec      IN   ASO_QUOTE_PUB.Party_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_party_rltship_REC,
    X_party_relationship_id       OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'UPDATE_PARTY_RELATIONSHIP';
BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PARTY_RELATIONSHIP_PUB;

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number,l_api_name,G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
      --
      -- API body
      --

      -- Validate Environment
      IF FND_GLOBAL.User_Id IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

         ASO_PARTY_RLTSHIP_PVT.Update_party_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_PARTY_RLTSHIP_Rec         => P_PARTY_RLTSHIP_Rec ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
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
      --AS_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End update_party_relationship;




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Party_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Party_Relationship_Rec IN   Party_Relationship_Rec_Type
--
PROCEDURE Delete_Party_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Party_Rltship_Rec      IN   ASO_QUOTE_PUB.Party_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_party_rltship_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'DELETE_PARTY_RELATIONSHIP';
BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT DELETE_PARTY_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
      --
      -- API body
      --

      -- Validate Environment
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

 ASO_PARTY_RLTSHIP_PVT.Delete_party_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_PARTY_RLTSHIP_Rec         => P_PARTY_RLTSHIP_Rec ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


End Delete_party_relationship;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Object_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Object_Relationship_Rec IN   Object_Relationship_Rec_Type
--   Version : Current version 2.0
--   End of Comments

PROCEDURE Create_Object_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RELATED_OBJ_Rec     IN    ASO_quote_PUB.RELATED_OBJ_Rec_Type  := ASO_quote_PUB.G_MISS_RELATED_OBJ_REC,
    X_related_object_id          OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'CREATE_OBJECT_RELATIONSHIP';
BEGIN


     -- Standard Start of API savepoint
      SAVEPOINT CREATE_OBJECT_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
      -- API body


      -- Validate Environment
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
	 ASO_RELATED_OBJ_PVT.Create_related_obj(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_commit		       => P_commit,
    p_validation_level         => p_validation_level,
    P_RELATED_OBJ_Rec          => P_RELATED_OBJ_Rec ,
    X_RELATED_OBJECT_ID        => X_RELATED_OBJECT_ID ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );



      -- End of API body

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
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Create_object_relationship;




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Object_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Object_Relationship_Rec IN   Object_Relationship_Rec_Type
--   Version : Current version 2.0

--
--   End of Comments
--
PROCEDURE Update_Object_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RELATED_OBJ_Rec     IN    ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'UPDATE_OBJECT_RELATIONSHIP';
BEGIN


     -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OBJECT_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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



   ASO_RELATED_OBJ_PVT.Update_related_obj(
    P_Api_Version_Number      => 1.0,
    P_Init_Msg_List           => FND_API.G_FALSE ,
    P_commit		      => P_commit,
    p_validation_level       => p_validation_level,
    P_RELATED_OBJ_Rec         =>   P_RELATED_OBJ_Rec,
    X_Return_Status           => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );


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
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Update_object_relationship;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  DELETE_OBJECT_RELATIONSHIP
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Object_Relationship_Rec IN   Object_Relationship_Rec_Type
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE DELETE_OBJECT_RELATIONSHIP(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RELATED_OBJ_Rec     IN ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'DELETE_OBJECT_RELATIONSHIP';
BEGIN

     -- Standard Start of API savepoint
      SAVEPOINT DELETE_OBJECT_RELATIONSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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



        ASO_RELATED_OBJ_PVT.Delete_related_obj(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    P_commit                   => P_commit,
    p_validation_level         => p_validation_level,
    P_RELATED_OBJ_Rec          => P_RELATED_OBJ_Rec ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

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
         p_data           =>   x_msg_data);

EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

End DELETE_OBJECT_RELATIONSHIP;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Price_Adj_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Price_Adj_Rltship_Rec   IN   Price_Adj_Rltship_Rec_Type
--   Version : Current version 2.0
--   End of Comments
--
PROCEDURE Create_Price_Adj_Rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Price_Adj_Rltship_Rec      IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_REC,
    X_adj_relationship_id       OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )

IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'CREATE_Price_Adj_RELATIONSHIP';
BEGIN
     -- Standard Start of API savepoint
      SAVEPOINT CREATE_PRICE_ADJ_RLTSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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


    ASO_PRICE_ADJ_RLTSHIP_PVT.Create_price_adj_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    p_commit                   => p_commit,
    P_PRICE_ADJ_RLTSHIP_Rec    => P_PRICE_ADJ_RLTSHIP_Rec ,
    X_ADJ_RELATIONSHIP_ID      => X_ADJ_RELATIONSHIP_ID ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


END;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Price_Adj_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--
    PROCEDURE Update_Price_Adj_Rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Price_Adj_Rltship_Rec      IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_REC,
    X_adj_relationship_id        OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'UPDATE_Price_Adj_RELATIONSHIP';
BEGIN
     -- Standard Start of API savepoint
      SAVEPOINT UPdate_PRICE_ADJ_RLTSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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


    ASO_PRICE_ADJ_RLTSHIP_PVT.Update_price_adj_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    p_commit                   => p_commit,
    P_PRICE_ADJ_RLTSHIP_Rec    => P_PRICE_ADJ_RLTSHIP_Rec ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Price_Adj__Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NUL
--       P_Price_Adj_Rltship_Rec   IN   Price_Adj_Rltship_Rec_Type
--   End of Comments
--
PROCEDURE Delete_Price_Adj_Rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Price_Adj_Rltship_Rec      IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )

IS
l_api_version_number NUMBER := 1.0;
l_api_name   VARCHAR2(240)  := 'DELETE_Price_Adj_RELATIONSHIP';
BEGIN
     -- Standard Start of API savepoint
      SAVEPOINT DELETE_PRICE_ADJ_RLTSHIP_PUB;

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
      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
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


    ASO_PRICE_ADJ_RLTSHIP_PVT.Delete_price_adj_rltship(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => FND_API.G_FALSE ,
    p_commit                   => p_commit,
    P_PRICE_ADJ_RLTSHIP_Rec    => P_PRICE_ADJ_RLTSHIP_Rec ,
    X_Return_Status            => X_Return_Status ,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

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
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END;



END ASO_RLTSHIP_PUB;

/
