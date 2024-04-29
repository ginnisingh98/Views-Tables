--------------------------------------------------------
--  DDL for Package Body AMS_REL_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_REL_ITEM_PVT" as
/* $Header: amsvritb.pls 115.11 2002/11/14 00:56:47 abhola ship $ */
-- Start of Comments
-- Package name     : AMS_REL_ITEM_PVT
-- Purpose          :
-- History          :
-- 08-FEB-2001   abhola    created
-- 17-MAY-2002   abhola    removed references to g_user_id
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_REL_ITEM_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvritb.pls';



AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_REL_ITEM_Rec (
	P_REL_ITEM_Rec     IN    REL_ITEM_Rec_Type,
	x_complete_rec     OUT  NOCOPY   REL_ITEM_Rec_Type
   );


-- Hint: Primary key needs to be returned.
PROCEDURE Create_rel_item(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,

    P_REL_ITEM_Rec     IN      REL_ITEM_Rec_Type  := G_MISS_REL_ITEM_REC
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_rel_item';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_object_version_number     NUMBER := 1;
l_org_id     NUMBER := FND_API.G_MISS_NUM;
l_owner_id                NUMBER;
l_return_status_cue      VARCHAR2(1);

Cursor Check_item  IS
    Select rowid,
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           RELATED_ITEM_ID,
           RELATIONSHIP_TYPE_ID,
           RECIPROCAL_FLAG,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE
    From  MTL_RELATED_ITEMS
    WHERE inventory_item_id = P_REL_ITEM_Rec.inventory_item_id
	 AND organization_id   = P_REL_ITEM_Rec.organization_id
	 AND related_item_id   = P_REL_ITEM_Rec.related_item_id
	 AND relationship_type_id = P_REL_ITEM_Rec.relationship_type_id;

  check_item_row Check_item%ROWTYPE;

  Cursor Get_owner_id IS
    SELECT item_owner_id
    FROM ams_item_attributes
    WHERE inventory_item_id = P_REL_ITEM_Rec.inventory_item_id
    AND organization_id = P_REL_ITEM_rec.organization_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_REL_ITEM_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
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
              FND_MESSAGE.Set_Name('AMS', 'USER_PROFILE_MISSING');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


	 -- *******************************************************************
	 -- Check for Duplicate Items
	 -- ******************************************************************

	 OPEN  Check_item;
	 FETCH Check_item INTO Check_item_row;

	 if (Check_item%FOUND) then
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
		 FND_MESSAGE.Set_Name('AMS', 'AMS_PROD_DUP_REL');
		 FND_MSG_PUB.ADD;
        END IF;
	   CLOSE Check_item;
	   RAISE FND_API.G_EXC_ERROR ;
      end if;

	 CLOSE Check_item;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_rel_item');
          END IF;

          -- Invoke validation procedures
          Validate_rel_item(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            P_REL_ITEM_Rec  =>  P_REL_ITEM_Rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

	  -- ******************************************************************
      -- Item Cannot be realted to it self.
      -- ******************************************************************
      IF (p_REL_ITEM_rec.INVENTORY_ITEM_ID = p_REL_ITEM_rec.RELATED_ITEM_ID)
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_INVALID_ITM_REL');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- *******************************************************************
      -- Invoke table handler(AMS_RELATED_ITEMS_PKG.Insert_Row)
      -- ******************************************************************

      AMS_RELATED_ITEMS_PKG.Insert_Row(
          p_INVENTORY_ITEM_ID  => p_REL_ITEM_rec.INVENTORY_ITEM_ID,
          p_ORGANIZATION_ID  => p_REL_ITEM_rec.ORGANIZATION_ID,
          p_RELATED_ITEM_ID  => p_REL_ITEM_rec.RELATED_ITEM_ID,
          p_RELATIONSHIP_TYPE_ID  => p_REL_ITEM_rec.RELATIONSHIP_TYPE_ID,
          p_RECIPROCAL_FLAG  => p_REL_ITEM_rec.RECIPROCAL_FLAG,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => p_REL_ITEM_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_REL_ITEM_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_REL_ITEM_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_REL_ITEM_rec.PROGRAM_UPDATE_DATE);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
	  END IF;

      /** commneted by abhola 05/17/01
	  ELSE
	  OPEN get_owner_id;
            FETCH get_owner_id INTO l_owner_id;
          CLOSE get_owner_id;

      -- ************************************************************************
      -- call for cue cards.
      -- ************************************************************************

            AMS_ObjectAttribute_PVT.modify_object_attribute(
              p_api_version        => l_api_version_number,
              p_init_msg_list      => FND_API.g_false,
              p_commit             => FND_API.g_false,
              p_validation_level   => FND_API.g_valid_level_full,

              x_return_status      => l_return_status_cue,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data,

              p_object_type        => 'PROD',
              p_object_id          => l_owner_id ,
              p_attr               => 'RPRD',
              p_attr_defined_flag  => 'Y'
           );

      END IF;
	 **/





      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_REL_ITEM_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_REL_ITEM_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO CREATE_REL_ITEM_PVT;
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
End Create_rel_item;


PROCEDURE Update_rel_item(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,

    P_REL_ITEM_Rec     IN    REL_ITEM_Rec_Type
    )

 IS

Cursor C_Get_rel_item  IS
    Select rowid,
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           RELATED_ITEM_ID,
           RELATIONSHIP_TYPE_ID,
           RECIPROCAL_FLAG,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE
    From  MTL_RELATED_ITEMS
    WHERE inventory_item_id = P_REL_ITEM_Rec.inventory_item_id
	 AND organization_id   = P_REL_ITEM_Rec.organization_id
	 AND related_item_id   = P_REL_ITEM_Rec.related_item_id
	 AND relationship_type_id = P_REL_ITEM_Rec.relationship_type_id;


l_api_name                CONSTANT VARCHAR2(30) := 'Update_rel_item';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_RELATED_ITEM_ID    NUMBER;
l_ref_REL_ITEM_rec  AMS_rel_item_PVT.REL_ITEM_Rec_Type;
l_tar_REL_ITEM_rec  AMS_rel_item_PVT.REL_ITEM_Rec_Type := P_REL_ITEM_Rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_REL_ITEM_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;


      Open C_Get_rel_item;

      Fetch C_Get_rel_item into
               l_rowid,
               l_ref_REL_ITEM_rec.INVENTORY_ITEM_ID,
               l_ref_REL_ITEM_rec.ORGANIZATION_ID,
               l_ref_REL_ITEM_rec.RELATED_ITEM_ID,
               l_ref_REL_ITEM_rec.RELATIONSHIP_TYPE_ID,
               l_ref_REL_ITEM_rec.RECIPROCAL_FLAG,
               l_ref_REL_ITEM_rec.LAST_UPDATE_DATE,
               l_ref_REL_ITEM_rec.LAST_UPDATED_BY,
               l_ref_REL_ITEM_rec.CREATION_DATE,
               l_ref_REL_ITEM_rec.CREATED_BY,
               l_ref_REL_ITEM_rec.LAST_UPDATE_LOGIN,
               l_ref_REL_ITEM_rec.REQUEST_ID,
               l_ref_REL_ITEM_rec.PROGRAM_APPLICATION_ID,
               l_ref_REL_ITEM_rec.PROGRAM_ID,
               l_ref_REL_ITEM_rec.PROGRAM_UPDATE_DATE;

       If ( C_Get_rel_item%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'rel_item', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       Close     C_Get_rel_item;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_rel_item');
          END IF;

          -- Invoke validation procedures
          Validate_rel_item(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            P_REL_ITEM_Rec  =>  P_REL_ITEM_Rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message

      -- Invoke table handler(AMS_RELATED_ITEMS_PKG.Update_Row)
      AMS_RELATED_ITEMS_PKG.Update_Row(
          p_INVENTORY_ITEM_ID  => p_REL_ITEM_rec.INVENTORY_ITEM_ID,
          p_ORGANIZATION_ID  => p_REL_ITEM_rec.ORGANIZATION_ID,
          p_RELATED_ITEM_ID  => p_REL_ITEM_rec.RELATED_ITEM_ID,
          p_RELATIONSHIP_TYPE_ID  => p_REL_ITEM_rec.RELATIONSHIP_TYPE_ID,
          p_RECIPROCAL_FLAG  => p_REL_ITEM_rec.RECIPROCAL_FLAG,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => p_REL_ITEM_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_REL_ITEM_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_REL_ITEM_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_REL_ITEM_rec.PROGRAM_UPDATE_DATE);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_REL_ITEM_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_REL_ITEM_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO UPDATE_REL_ITEM_PVT;
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
End Update_rel_item;


PROCEDURE Delete_rel_item(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    P_REL_ITEM_Rec     IN    REL_ITEM_Rec_Type
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_rel_item';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_dummy number :=0;
l_return_status VARCHAR2(1) ;
l_item_owner_id NUMBER;

Cursor check_item is
   SELECT 1
   FROM mtl_related_items
   WHERE organization_id = P_REL_ITEM_Rec.organization_id
   AND inventory_item_id = p_REL_ITEM_Rec.inventory_item_id;
   --AND related_item_id   = P_REL_ITEM_Rec.related_item_id
   --AND relationship_type_id = P_REL_ITEM_Rec.relationship_type_id;



Cursor Get_owner_id IS
    SELECT item_owner_id
    FROM ams_item_attributes
    WHERE inventory_item_id = P_REL_ITEM_Rec.inventory_item_id
    AND organization_id = P_REL_ITEM_rec.organization_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_REL_ITEM_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_RELATED_ITEMS_PKG.Delete_Row

      AMS_RELATED_ITEMS_PKG.Delete_Row(
          p_INVENTORY_ITEM_ID  => p_REL_ITEM_rec.INVENTORY_ITEM_ID,
          p_ORGANIZATION_ID  => p_REL_ITEM_rec.ORGANIZATION_ID,
          p_RELATED_ITEM_ID  => p_REL_ITEM_rec.RELATED_ITEM_ID,
          p_RELATIONSHIP_TYPE_ID  => p_REL_ITEM_rec.RELATIONSHIP_TYPE_ID,
          p_RECIPROCAL_FLAG  => p_REL_ITEM_rec.RECIPROCAL_FLAG,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => p_REL_ITEM_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_REL_ITEM_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_REL_ITEM_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_REL_ITEM_rec.PROGRAM_UPDATE_DATE);

	/** commented CUE CARD code on 5/17/01 by ABHOLA
      -- ************************************************************
      --    Call for cue card
      -- ************************************************************
      OPEN check_item;
        FETCH check_item INTO l_dummy;
      CLOSE check_item;

      OPEN get_owner_id;
       FETCH get_owner_id INTO l_item_owner_id;
      CLOSE get_owner_id;

      IF l_dummy =1 THEN

         AMS_ObjectAttribute_PVT.modify_object_attribute(
              p_api_version        => l_api_version_number,
              p_init_msg_list      => FND_API.g_false,
              p_commit             => FND_API.g_false,
              p_validation_level   => FND_API.g_valid_level_full,

              x_return_status      => l_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data,

              p_object_type        => 'PROD',
              p_object_id          => l_item_owner_id ,
              p_attr               => 'RPRD',
              p_attr_defined_flag  => 'Y'
           );

      ELSE

         AMS_ObjectAttribute_PVT.modify_object_attribute(
              p_api_version        => l_api_version_number,
              p_init_msg_list      => FND_API.g_false,
              p_commit             => FND_API.g_false,
              p_validation_level   => FND_API.g_valid_level_full,

              x_return_status      => l_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data,

              p_object_type        => 'PROD',
              p_object_id          => l_item_owner_id ,
              p_attr               => 'RPRD',
              p_attr_defined_flag  => 'N'
           );

       END IF;

	   *************  end of commented code ****************************/

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_REL_ITEM_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_REL_ITEM_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO DELETE_REL_ITEM_PVT;
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
End Delete_rel_item;


PROCEDURE Check_REL_ITEM_Items (
     P_REL_ITEM_Rec     IN    REL_ITEM_Rec_Type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT  NOCOPY  VARCHAR2
    )
IS
BEGIN

      --
      -- Check Items API calls
      NULL;
      --

END Check_REL_ITEM_Items;

PROCEDURE Complete_REL_ITEM_Rec (
    P_REL_ITEM_Rec     IN    REL_ITEM_Rec_Type,
     x_complete_rec        OUT  NOCOPY   REL_ITEM_Rec_Type
    )
IS


 CURSOR c_rel_item_rec IS
   SELECT *
     FROM mtl_related_items
    WHERE inventory_item_id = P_REL_ITEM_Rec.inventory_item_id
	AND organization_id   = P_REL_ITEM_Rec.organization_id
	AND related_item_id   = P_REL_ITEM_Rec.related_item_id
	AND relationship_type_id = P_REL_ITEM_Rec.relationship_type_id;

    l_rel_item_rec  c_rel_item_rec%ROWTYPE;

BEGIN

	x_complete_rec := P_REL_ITEM_Rec;

   OPEN c_rel_item_rec;
   FETCH c_rel_item_rec INTO l_rel_item_rec;
	IF c_rel_item_rec%NOTFOUND THEN
	  CLOSE c_rel_item_rec;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		  FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
		 FND_MSG_PUB.add;
       END IF;
	  RAISE FND_API.g_exc_error;
	END IF;
   CLOSE c_rel_item_rec;

   IF P_REL_ITEM_Rec.inventory_item_id = FND_API.g_miss_num THEN
	    x_complete_rec.inventory_item_id := l_rel_item_rec.inventory_item_id;
   END IF;

   IF P_REL_ITEM_Rec.organization_id = FND_API.g_miss_num THEN
	    x_complete_rec.organization_id := l_rel_item_rec.organization_id;
   END IF;


   IF P_REL_ITEM_Rec.related_item_id = FND_API.g_miss_num THEN
	    x_complete_rec.related_item_id := l_rel_item_rec.related_item_id;
   END IF;


   IF P_REL_ITEM_Rec.relationship_type_id = FND_API.g_miss_num THEN
	    x_complete_rec.relationship_type_id := l_rel_item_rec.relationship_type_id;
   END IF;


   IF P_REL_ITEM_Rec.reciprocal_flag = FND_API.g_miss_char THEN
	    x_complete_rec.reciprocal_flag := l_rel_item_rec.reciprocal_flag;
   END IF;


   IF P_REL_ITEM_Rec.request_id = FND_API.g_miss_num THEN
	    x_complete_rec.request_id := l_rel_item_rec.request_id;
   END IF;


   IF P_REL_ITEM_Rec.program_application_id = FND_API.g_miss_num THEN
	    x_complete_rec.program_application_id := l_rel_item_rec.program_application_id;
   END IF;


   IF P_REL_ITEM_Rec.program_id = FND_API.g_miss_num THEN
	    x_complete_rec.program_id := l_rel_item_rec.program_id;
   END IF;


   IF P_REL_ITEM_Rec.program_update_date = FND_API.g_miss_date THEN
	    x_complete_rec.program_update_date := l_rel_item_rec.program_update_date;
   END IF;

END Complete_REL_ITEM_Rec;

PROCEDURE Validate_rel_item(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_REL_ITEM_Rec     IN    REL_ITEM_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Validate_rel_item';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_REL_ITEM_rec  AMS_rel_item_PVT.REL_ITEM_Rec_Type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_REL_ITEM_;

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
              Check_REL_ITEM_Items(
                 p_REL_ITEM_rec        => p_REL_ITEM_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_REL_ITEM_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
          P_REL_ITEM_Rec     =>    l_REL_ITEM_Rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO VALIDATE_REL_ITEM_;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO VALIDATE_REL_ITEM_;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_REL_ITEM_;
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
End Validate_rel_item;


PROCEDURE Validate_REL_ITEM_rec(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    P_REL_ITEM_Rec     IN    REL_ITEM_Rec_Type
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


      -- Debug Message
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_UTILITY_PVT.debug_message('API_INVALID_RECORD'); END IF;



      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_REL_ITEM_Rec;

End AMS_REL_ITEM_PVT;

/
