--------------------------------------------------------
--  DDL for Package Body OZF_REASON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_REASON_PVT" as
/* $Header: ozfvreab.pls 120.2 2005/07/29 06:26:26 appldev ship $ */
-- Start of Comments
-- Package name     : OZF_Reason_PVT
-- Purpose          :
-- History          :
--                    28-OCT-2002  UPOLURI   Add one more column: ORDER_TYPE_ID  NUMBER
--                    28-SEP-2003  ANUJGUPT  Add one more column: PARTNER_ACCESS_FLAG  VARCHAR2(1)
-- History          : 22-Jun-2005  KDHULIPA  Add one more column: INVOICING_REASON_CODE  VARCHAR2(30)
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Reason_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvreab.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_reason_Rec     IN      reason_Rec_Type  := G_MISS_reason_REC,
    X_REASON_CODE_ID              OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_reason';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_object_version_number     NUMBER := 1;
l_org_id     NUMBER := FND_API.G_MISS_NUM;
l_REASON_CODE_ID    NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Reason_PVT;

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
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_USER_PROFILE_MISSING');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF OZF_DEBUG_HIGH_ON THEN
             OZF_UTILITY_PVT.debug_message('Private API: Validate_reason');
          END IF;

          -- Invoke validation procedures
          Validate_reason(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            P_reason_Rec  =>  P_reason_Rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Pass org_id from UI
      l_org_id := p_reason_rec.ORG_ID;


      -- Invoke table handler(OZF_reason_codes_All_PKG.Insert_Row)
      OZF_reason_codes_All_PKG.Insert_Row(
          px_REASON_CODE_ID  => l_REASON_CODE_ID,
          px_OBJECT_VERSION_NUMBER  => l_object_version_number,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REASON_CODE  => p_reason_rec.REASON_CODE,
          p_START_DATE_ACTIVE  => p_reason_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE  => p_reason_rec.END_DATE_ACTIVE,
          p_ATTRIBUTE_CATEGORY  => p_reason_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_reason_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_reason_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_reason_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_reason_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_reason_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_reason_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_reason_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_reason_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_reason_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_reason_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_reason_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_reason_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_reason_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_reason_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_reason_rec.ATTRIBUTE15,
          p_NAME         => p_reason_rec.NAME,
          p_DESCRIPTION  => p_reason_rec.DESCRIPTION,
          px_ORG_ID      => l_org_id,
          p_REASON_TYPE  => p_reason_rec.REASON_TYPE,
          p_ADJUSTMENT_REASON_CODE  => p_reason_rec.ADJUSTMENT_REASON_CODE,
	  p_INVOICING_REASON_CODE  => p_reason_rec.INVOICING_REASON_CODE,
          px_ORDER_TYPE_ID     => p_reason_rec.ORDER_TYPE_ID,
          p_PARTNER_ACCESS_FLAG     => p_reason_rec.PARTNER_ACCESS_FLAG
	  );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- End of API body
      --
      x_reason_code_id := l_reason_code_id;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO CREATE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Create_reason;


PROCEDURE Update_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_reason_Rec     IN    reason_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER
    )

 IS

Cursor C_Get_reason(l_REASON_CODE_ID Number) IS
    SELECT REASON_CODE_ID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REASON_CODE,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
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
           NAME,
           DESCRIPTION,
           ORG_ID,
           REASON_TYPE,
           ADJUSTMENT_REASON_CODE,
	   INVOICING_REASON_CODE,
           ORDER_TYPE_ID,
	   PARTNER_ACCESS_FLAG
    FROM  ozf_reason_codes_ALL_VL
    WHERE REASON_CODE_ID = l_REASON_CODE_ID;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_reason';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_REASON_CODE_ID    NUMBER;
l_ref_reason_rec  OZF_reason_PVT.reason_Rec_Type;
l_reason_rec  OZF_reason_PVT.reason_Rec_Type;
l_tar_reason_rec  OZF_reason_PVT.reason_Rec_Type := P_reason_Rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Reason_PVT;

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
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      Open C_Get_reason( l_tar_reason_rec.REASON_CODE_ID);
          Fetch C_Get_reason into
               l_ref_reason_rec.REASON_CODE_ID,
               l_ref_reason_rec.OBJECT_VERSION_NUMBER,
               l_ref_reason_rec.LAST_UPDATE_DATE,
               l_ref_reason_rec.LAST_UPDATED_BY,
               l_ref_reason_rec.CREATION_DATE,
               l_ref_reason_rec.CREATED_BY,
               l_ref_reason_rec.LAST_UPDATE_LOGIN,
               l_ref_reason_rec.REASON_CODE,
               l_ref_reason_rec.START_DATE_ACTIVE,
               l_ref_reason_rec.END_DATE_ACTIVE,
               l_ref_reason_rec.ATTRIBUTE_CATEGORY,
               l_ref_reason_rec.ATTRIBUTE1,
               l_ref_reason_rec.ATTRIBUTE2,
               l_ref_reason_rec.ATTRIBUTE3,
               l_ref_reason_rec.ATTRIBUTE4,
               l_ref_reason_rec.ATTRIBUTE5,
               l_ref_reason_rec.ATTRIBUTE6,
               l_ref_reason_rec.ATTRIBUTE7,
               l_ref_reason_rec.ATTRIBUTE8,
               l_ref_reason_rec.ATTRIBUTE9,
               l_ref_reason_rec.ATTRIBUTE10,
               l_ref_reason_rec.ATTRIBUTE11,
               l_ref_reason_rec.ATTRIBUTE12,
               l_ref_reason_rec.ATTRIBUTE13,
               l_ref_reason_rec.ATTRIBUTE14,
               l_ref_reason_rec.ATTRIBUTE15,
               l_ref_reason_rec.NAME,
               l_ref_reason_rec.DESCRIPTION,
               l_ref_reason_rec.ORG_ID,
               l_ref_reason_rec.REASON_TYPE,
               l_ref_reason_rec.ADJUSTMENT_REASON_CODE,
	       l_ref_reason_rec.INVOICING_REASON_CODE,
               l_ref_reason_rec.ORDER_TYPE_ID,
	       l_ref_reason_rec.PARTNER_ACCESS_FLAG;

          If ( C_Get_reason%NOTFOUND) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
               FND_MESSAGE.Set_Name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               FND_MSG_PUB.Add;
             END IF;
             raise FND_API.G_EXC_ERROR;
          END IF;
          -- Debug Message
          IF OZF_DEBUG_HIGH_ON THEN
             OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
          END IF;
      Close     C_Get_reason;


      If (l_tar_reason_rec.object_version_number is NULL or
          l_tar_reason_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_API_NO_OBJ_VER_NUM');
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_reason_rec.object_version_number <> l_ref_reason_rec.object_version_number) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

     Complete_reason_Rec(
         P_reason_rec        => P_reason_rec,
         x_complete_rec      => l_reason_rec,
	 x_return_status  => x_return_status
     );
    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: Before Validate');
      END IF;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF OZF_DEBUG_HIGH_ON THEN
             OZF_UTILITY_PVT.debug_message('Private API: Validate_reason');
          END IF;

          -- Invoke validation procedures
          Validate_reason(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            P_reason_Rec  =>  l_reason_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: After Validate');
      END IF;



      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API:Calling update table handler');
      END IF;

      l_object_version_number := l_reason_rec.OBJECT_VERSION_NUMBER + 1;

      -- Invoke table handler(OZF_reason_codes_All_PKG.Update_Row)
      OZF_reason_codes_All_PKG.Update_Row(
          p_REASON_CODE_ID  => l_reason_rec.REASON_CODE_ID,
          p_OBJECT_VERSION_NUMBER  => l_object_version_number,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REASON_CODE  => l_reason_rec.REASON_CODE,
          p_START_DATE_ACTIVE  => l_reason_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE  => l_reason_rec.END_DATE_ACTIVE,
          p_ATTRIBUTE_CATEGORY  => l_reason_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_reason_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_reason_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_reason_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_reason_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_reason_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_reason_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_reason_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_reason_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_reason_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_reason_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_reason_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_reason_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_reason_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_reason_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_reason_rec.ATTRIBUTE15,
          p_NAME  => l_reason_rec.NAME,
          p_DESCRIPTION  => l_reason_rec.DESCRIPTION,
          p_ORG_ID  => l_reason_rec.ORG_ID,
          p_REASON_TYPE  => l_reason_rec.REASON_TYPE,
          p_ADJUSTMENT_REASON_CODE  => l_reason_rec.ADJUSTMENT_REASON_CODE,
	  p_INVOICING_REASON_CODE  => l_reason_rec.INVOICING_REASON_CODE,
          p_ORDER_TYPE_ID  => l_reason_rec.ORDER_TYPE_ID,
          p_PARTNER_ACCESS_FLAG  => l_reason_rec.PARTNER_ACCESS_FLAG
	  );
      --
      -- End of API body.
      --
      x_object_version_number := l_object_version_number;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO UPDATE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Update_reason;


PROCEDURE Delete_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_REASON_CODE_ID  IN  NUMBER,
    P_Object_Version_Number      IN   NUMBER
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_reason';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_reason_code_id		NUMBER;

CURSOR exist_reason_csr(p_id in number) IS
select reason_code_id
from   ozf_claims_all
where  reason_code_id = p_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Reason_PVT;

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
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      OPEN exist_reason_csr(p_reason_code_id);
	    FETCH exist_reason_csr INTO l_reason_code_id;
	 CLOSE exist_reason_csr;

	 IF l_reason_code_id IS NOT NULL THEN
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_REASON_ID_USED');
		   FND_MSG_PUB.add;
	    END IF;
	    RAISE FND_API.g_exc_error;
	 END IF;

      -- Invoke table handler(OZF_reason_codes_All_PKG.Delete_Row)
      OZF_reason_codes_All_PKG.Delete_Row(
          p_REASON_CODE_ID  => p_REASON_CODE_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO DELETE_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Delete_reason;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_actions
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number    IN  NUMBER   Required
--       p_init_msg_list         IN  VARCHAR2 Optional  Default=FND_API_G_FALSE
--       p_commit                IN  VARCHAR2 Optional  Default=FND_API.G_FALSE
--       p_validation_level      IN  NUMBER   Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_action_Tbl            IN  action_Tbl_Type
--
--   OUT:
--       x_return_status         OUT VARCHAR2
--       x_msg_count             OUT NUMBER
--       x_msg_data              OUT VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it
--         includes standard IN/OUT parameters and basic operation,
--         developer must manually add parameters and business
--         logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_actions(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_action_Tbl                 IN  action_Tbl_Type
)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_actions';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number   NUMBER;
--
l_reason_type_id           NUMBER;
l_task_template_group_id   NUMBER;
l_active_flag              VARCHAR2(1);
l_default_flag             VARCHAR2(1);
P_action_Rec               action_Rec_Type;
p_validation_mode          VARCHAR2(1);
l_reason_type_count        NUMBER;

CURSOR C2 IS SELECT OZF_REASONS_S.nextval FROM sys.dual;

CURSOR C_REASON_TYPE_COUNT(l_reason_type_id NUMBER)
IS    SELECT COUNT(REASON_TYPE_ID)
      FROM OZF_REASONS
      WHERE REASON_TYPE_ID = l_reason_type_id;


CURSOR db_rec_csr (p_id number) IS
 SELECT object_version_number
 ,      task_template_group_id
 ,      active_flag
 ,      default_flag
 FROM   ozf_reasons
 WHERE  reason_type_id = p_id;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Actions_PVT;

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
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      FOR i in p_action_tbl.first..p_action_tbl.last
      LOOP
        l_reason_type_id := p_action_tbl(i).reason_type_id;
        l_default_flag := p_action_tbl(i).default_flag;
        l_task_template_group_id := p_action_tbl(i).task_template_group_id;

        IF (l_default_flag IS NULL) THEN
         l_default_flag := FND_API.G_FALSE;
        END IF;
        -- CREATE mode
	IF l_reason_type_id = -1
   AND  l_task_template_group_id <> -1
   THEN
      --Check for the uniqueness of action.
      P_action_Rec := p_action_tbl(i);
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Check_unique_Action(
                 P_action_Rec        => P_action_Rec,
                 p_validation_mode   => JTF_PLSQL_API.g_create,
                 x_return_status     => X_Return_Status
              );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
      --end of unique check.

	  l_object_version_number := 1;
     l_active_flag := FND_API.G_TRUE;

      --check for unique reason type id.
      LOOP
	  -- get reason_type_id
          OPEN C2;
            FETCH C2 INTO l_reason_type_id;
          CLOSE C2;

          OPEN C_REASON_TYPE_COUNT(l_reason_type_id);
          FETCH C_REASON_TYPE_COUNT INTO l_reason_type_count;
          CLOSE C_REASON_TYPE_COUNT;
          EXIT WHEN l_reason_type_count = 0;
      END LOOP;

          BEGIN
            INSERT INTO ozf_reasons (
              REASON_TYPE_ID,
              OBJECT_VERSION_NUMBER,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
              REASON_CODE_ID,
	      TASK_TEMPLATE_GROUP_ID,
	      ACTIVE_FLAG,
         DEFAULT_FLAG
            ) VALUES (
	      l_reason_type_id,
	      l_object_version_number,
	      SYSDATE,
	      FND_GLOBAL.USER_ID,
	      SYSDATE,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.CONC_LOGIN_ID,
              p_action_tbl(i).reason_code_id,
              l_task_template_group_id,
              l_active_flag,
              l_default_flag
            );
	  EXCEPTION
             WHEN OTHERS THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                 FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ACTION_INSERT_ERROR');
                 FND_MSG_PUB.Add;
               END IF;
               raise FND_API.G_EXC_ERROR;
	  END;
        -- UPDATE mode
	ELSE
	  -- fetch db record
	  OPEN db_rec_csr(l_reason_type_id);
            FETCH db_rec_csr INTO l_object_version_number,
                                  l_task_template_group_id,
                                  l_active_flag,
                                  l_default_flag;
          CLOSE db_rec_csr;

          -- Check Whether record has been changed by someone else
          If (l_object_version_number <> p_action_tbl(i).object_version_number)
          Then
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
              FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
          END IF;

	  l_object_version_number := p_action_tbl(i).object_version_number + 1;

          -- update if there are changes
	  IF l_task_template_group_id <> p_action_tbl(i).task_template_group_id
             OR l_active_flag <> p_action_tbl(i).active_flag
             OR l_default_flag <> p_action_tbl(i).default_flag
	  THEN
            BEGIN
              UPDATE ozf_reasons
	           SET OBJECT_VERSION_NUMBER = l_object_version_number
              ,   LAST_UPDATE_DATE      = SYSDATE
              ,   LAST_UPDATED_BY       = FND_GLOBAL.USER_ID
              ,   LAST_UPDATE_LOGIN     = FND_GLOBAL.CONC_LOGIN_ID
              ,   REASON_CODE_ID        = p_action_tbl(i).reason_code_id
              ,   TASK_TEMPLATE_GROUP_ID= p_action_tbl(i).task_template_group_id
	           ,   ACTIVE_FLAG           = p_action_tbl(i).active_flag
              ,   default_flag        = p_action_tbl(i).default_flag
	      WHERE  reason_type_id = l_reason_type_id;
	    EXCEPTION
              WHEN OTHERS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                  FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ACTION_UPDATE_ERROR');
                  FND_MSG_PUB.Add;
                END IF;
                raise FND_API.G_EXC_ERROR;
	    END;
	  END IF; -- end update

	END IF; -- end create and update modes
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
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_Actions_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_Actions_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO UPDATE_Actions_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Update_Actions;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Action
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number    IN  NUMBER   Required
--       p_init_msg_list         IN  VARCHAR2 Optional  Default=FND_API_G_FALSE
--       p_commit                IN  VARCHAR2 Optional  Default=FND_API.G_FALSE
--       p_validation_level      IN  NUMBER   Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_reason_type_id        IN  NUMBER
--       p_object_version_number IN  NUMBER
--
--   OUT:
--       x_return_status         OUT VARCHAR2
--       x_msg_count             OUT NUMBER
--       x_msg_data              OUT VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it
--         includes standard IN/OUT parameters and basic operation,
--         developer must manually add parameters and business
--         logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_action(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_reason_type_id             IN  NUMBER,
    p_object_version_number       IN  NUMBER
)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_action';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Action_PVT;

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
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(OZF_reason_codes_All_PKG.Delete_Row)
      DELETE FROM ozf_reasons
      WHERE  reason_type_id = p_reason_type_id
      AND    object_version_number = p_object_version_number;

      If (SQL%NOTFOUND) then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
            FND_MSG_PUB.ADD;
         END IF;
         raise FND_API.G_EXC_ERROR;
      End If;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_Action_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_Action_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO DELETE_Action_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Delete_action;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_unique_Action
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       P_action_Rec            IN  action_Rec_Type   Required
--       p_validation_mode       IN  VARCHAR2 Optional  Default=JTF_PLSQL_API.g_create
--
--   OUT:
--       x_return_status         OUT VARCHAR2
--
--   Version : Current version 1.0
--   Description : Checks the uniqueness of the action record for a reason.
--
--   End of Comments
--
PROCEDURE Check_unique_Action(
    P_action_Rec       IN    action_Rec_Type,
    p_validation_mode  IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status    OUT NOCOPY   VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Inside Check_unique_Action - p_validation_mode' || p_validation_mode);

      OZF_UTILITY_PVT.debug_message('P_action_Rec.TASK_TEMPLATE_GROUP_ID :'|| P_action_Rec.TASK_TEMPLATE_GROUP_ID);
   END IF;

   IF( p_validation_mode = JTF_PLSQL_API.g_create )
   THEN
      l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_REASONS',
         ' TASK_TEMPLATE_GROUP_ID  ='||' '||P_action_Rec.TASK_TEMPLATE_GROUP_ID ||''||
         ' AND REASON_CODE_ID      = '||' '|| P_action_Rec.REASON_CODE_ID
	 );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_DUPLICATE_ACTION');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_unique_Action;
--End of Check_unique_Action

PROCEDURE Check_reason_Items (
     P_reason_Rec     IN    reason_Rec_Type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

      --
      -- Check Items API calls
      NULL;
      --

END Check_reason_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_reason_Rec
--
-- PURPOSE
--    For Update_reason, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_claim_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------

PROCEDURE Complete_reason_Rec (
    P_reason_Rec     IN    reason_Rec_Type,
    x_complete_rec        OUT NOCOPY    reason_Rec_Type,
    x_return_status    OUT NOCOPY  varchar2
    )
IS

CURSOR c_reason (cv_reason_id NUMBER) IS
SELECT * FROM ozf_reason_codes_all_b
WHERE reason_code_id = cv_reason_id;

l_reason_rec    c_reason%ROWTYPE;
BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

 x_complete_rec  := P_reason_Rec;

OPEN c_reason(P_reason_Rec.reason_code_id);
  FETCH c_reason INTO l_reason_rec;
     IF c_reason%NOTFOUND THEN
        CLOSE c_reason;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('OZF','OZF_API_RECORD_NOT_FOUND');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
     END IF;
  CLOSE c_reason;

  IF P_reason_Rec.reason_code_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.reason_code_id       := NULL;
  END IF;
  IF P_reason_Rec.reason_code_id          IS NULL THEN
     x_complete_rec.reason_code_id       := l_reason_rec.reason_code_id;
  END IF;

  IF P_reason_Rec.last_update_login         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.last_update_login       := NULL;
  END IF;
  IF P_reason_Rec.last_update_login          IS NULL THEN
     x_complete_rec.last_update_login       := l_reason_rec.last_update_login;
  END IF;

  IF P_reason_Rec.reason_type         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.reason_type       := NULL;
  END IF;
  IF P_reason_Rec.reason_type          IS NULL THEN
     x_complete_rec.reason_type       := l_reason_rec.reason_type;
  END IF;


  IF P_reason_Rec.reason_code         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.reason_code       := NULL;
  END IF;
  IF P_reason_Rec.reason_code          IS NULL THEN
     x_complete_rec.reason_code       := l_reason_rec.reason_code;
  END IF;

  IF P_reason_Rec.start_date_active         = FND_API.G_MISS_DATE THEN
     x_complete_rec.start_date_active       := NULL;
  END IF;
  IF P_reason_Rec.start_date_active          IS NULL THEN
     x_complete_rec.start_date_active       := l_reason_rec.start_date_active;
  END IF;

  IF P_reason_Rec.end_date_active         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.end_date_active       := NULL;
  END IF;
  IF P_reason_Rec.end_date_active          IS NULL THEN
     x_complete_rec.end_date_active       := l_reason_rec.end_date_active;
  END IF;

  IF P_reason_Rec.attribute_category         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute_category       := NULL;
  END IF;
  IF P_reason_Rec.attribute_category          IS NULL THEN
     x_complete_rec.attribute_category       := l_reason_rec.attribute_category;
  END IF;

  IF P_reason_Rec.attribute1         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute1       := NULL;
  END IF;
  IF P_reason_Rec.attribute1          IS NULL THEN
     x_complete_rec.attribute1       := l_reason_rec.attribute1;
  END IF;

  IF P_reason_Rec.attribute2         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute2       := NULL;
  END IF;
  IF P_reason_Rec.attribute2          IS NULL THEN
     x_complete_rec.attribute2       := l_reason_rec.attribute2;
  END IF;
  IF P_reason_Rec.attribute3         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute3       := NULL;
  END IF;
  IF P_reason_Rec.attribute3          IS NULL THEN
     x_complete_rec.attribute3       := l_reason_rec.attribute3;
  END IF;
  IF P_reason_Rec.attribute4         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute4       := NULL;
  END IF;
  IF P_reason_Rec.attribute4          IS NULL THEN
     x_complete_rec.attribute4       := l_reason_rec.attribute4;
  END IF;
  IF P_reason_Rec.attribute5         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute5       := NULL;
  END IF;
  IF P_reason_Rec.attribute5          IS NULL THEN
     x_complete_rec.attribute5       := l_reason_rec.attribute5;
  END IF;
  IF P_reason_Rec.attribute6         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute6       := NULL;
  END IF;
  IF P_reason_Rec.attribute6          IS NULL THEN
     x_complete_rec.attribute6       := l_reason_rec.attribute6;
  END IF;
  IF P_reason_Rec.attribute7         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute7       := NULL;
  END IF;
  IF P_reason_Rec.attribute7          IS NULL THEN
     x_complete_rec.attribute7       := l_reason_rec.attribute7;
  END IF;
  IF P_reason_Rec.attribute8         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute8       := NULL;
  END IF;
  IF P_reason_Rec.attribute8          IS NULL THEN
     x_complete_rec.attribute8       := l_reason_rec.attribute8;
  END IF;
  IF P_reason_Rec.attribute9         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute9       := NULL;
  END IF;
  IF P_reason_Rec.attribute9          IS NULL THEN
     x_complete_rec.attribute9       := l_reason_rec.attribute9;
  END IF;
  IF P_reason_Rec.attribute10         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute10       := NULL;
  END IF;
  IF P_reason_Rec.attribute10          IS NULL THEN
     x_complete_rec.attribute10       := l_reason_rec.attribute10;
  END IF;
  IF P_reason_Rec.attribute11         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute11       := NULL;
  END IF;
  IF P_reason_Rec.attribute11          IS NULL THEN
     x_complete_rec.attribute11       := l_reason_rec.attribute11;
  END IF;
  IF P_reason_Rec.attribute12         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute12       := NULL;
  END IF;
  IF P_reason_Rec.attribute12          IS NULL THEN
     x_complete_rec.attribute12       := l_reason_rec.attribute12;
  END IF;
  IF P_reason_Rec.attribute13         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute13       := NULL;
  END IF;
  IF P_reason_Rec.attribute13          IS NULL THEN
     x_complete_rec.attribute13       := l_reason_rec.attribute13;
  END IF;
  IF P_reason_Rec.attribute14         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute14       := NULL;
  END IF;
  IF P_reason_Rec.attribute14          IS NULL THEN
     x_complete_rec.attribute14       := l_reason_rec.attribute14;
  END IF;
  IF P_reason_Rec.attribute15         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute15       := NULL;
  END IF;
  IF P_reason_Rec.attribute15          IS NULL THEN
     x_complete_rec.attribute15       := l_reason_rec.attribute15;
  END IF;

  IF P_reason_Rec.org_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.org_id       := NULL;
  END IF;
  IF P_reason_Rec.org_id          IS NULL THEN
     x_complete_rec.org_id       := l_reason_rec.org_id;
  END IF;

  IF P_reason_Rec.adjustment_reason_code         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.adjustment_reason_code       := NULL;
  END IF;
  IF P_reason_Rec.adjustment_reason_code          IS NULL THEN
     x_complete_rec.adjustment_reason_code       := l_reason_rec.adjustment_reason_code;
  END IF;

  IF P_reason_Rec.invoicing_reason_code         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.invoicing_reason_code       := NULL;
  END IF;
  IF P_reason_Rec.invoicing_reason_code          IS NULL THEN
     x_complete_rec.invoicing_reason_code       := l_reason_rec.invoicing_reason_code;
  END IF;


  IF P_reason_Rec.order_type_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.order_type_id       := NULL;
  END IF;
  IF P_reason_Rec.order_type_id          IS NULL THEN
     x_complete_rec.order_type_id       := l_reason_rec.order_type_id;
  END IF;

  IF P_reason_Rec.partner_access_flag        = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.partner_access_flag       := NULL;
  END IF;
  IF P_reason_Rec.partner_access_flag          IS NULL THEN
     x_complete_rec.partner_access_flag       := l_reason_rec.partner_access_flag;
  END IF;


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_REASON_COMPLETE_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;


END Complete_reason_Rec;

PROCEDURE Validate_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_reason_Rec     IN    reason_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Validate_reason';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_reason_rec  OZF_reason_PVT.reason_Rec_Type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Reason_;

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
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_reason_Items(
                 p_reason_rec        => p_reason_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      l_reason_Rec := P_reason_Rec;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_reason_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
          P_reason_Rec     =>    l_reason_Rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO VALIDATE_Reason_;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO VALIDATE_Reason_;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_Reason_;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Validate_reason;


PROCEDURE Validate_reason_rec(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_reason_Rec     IN    reason_Rec_Type
    )
IS
  l_reason_name	  VARCHAR2(80);
  l_start_date		  DATE;
  l_end_date		  DATE;
  l_dummy           NUMBER;

   CURSOR  c_order_trx_type(cv_id NUMBER)
   IS
      SELECT 1
      FROM oe_transaction_types_vl
      WHERE transaction_type_id = cv_id;

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

      l_reason_name := P_reason_Rec.NAME;
      l_start_date  := P_reason_Rec.START_DATE_ACTIVE;
      l_end_date    := P_reason_Rec.END_DATE_ACTIVE;

      -- Check for null reason name.
      IF( (l_reason_name IS NULL)
      OR (l_reason_name = FND_API.G_MISS_CHAR) )
      THEN
         FND_MESSAGE.Set_Name('OZF', 'OZF_REASON_NULL_NAME');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Check for null start date
      IF( (l_start_date IS NULL)
      OR (l_start_date = FND_API.G_MISS_DATE) )
      THEN
         FND_MESSAGE.Set_Name('OZF', 'OZF_REASON_NULL_STDATE');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- End date validation.
      IF( (l_end_date IS NOT NULL)
      AND (l_end_date <> FND_API.G_MISS_DATE) )
      THEN
         IF( l_start_date > l_end_date )
         THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_REASON_STDATE_GT_ENDDATE');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

      --Check the validity of OM Transaction type
      IF P_reason_Rec.order_type_id IS NOT NULL THEN
         OPEN c_order_trx_type(P_reason_Rec.order_type_id);
         FETCH c_order_trx_type INTO l_dummy;
         CLOSE c_order_trx_type;

         IF l_dummy <> 1 THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INVALID_OM_TRX_TYPE');
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
      END IF;

      -- Debug Message
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('API_INVALID_RECORD');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_reason_Rec;

End OZF_Reason_PVT;

/
