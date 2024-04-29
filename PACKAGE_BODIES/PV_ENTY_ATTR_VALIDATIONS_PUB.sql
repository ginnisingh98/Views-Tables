--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALIDATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALIDATIONS_PUB" AS
 /* $Header: pvxvvldb.pls 115.1 2002/12/10 19:29:45 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ENTY_ATTR_VALIDATIONS_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


 G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_ENTY_ATTR_VALIDATIONS_PUB';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvvldb.pls';

 G_USER_ID         NUMBER := NVL(FND_GLOBAL.USER_ID,-1);
 G_LOGIN_ID        NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID,-1);


PROCEDURE Update_Attr_Validations(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_validation_rec   IN   PV_ENTY_ATTR_VALIDATIONS_PVT.enty_attr_validation_rec_type  := PV_ENTY_ATTR_VALIDATIONS_PVT.g_miss_enty_attr_vldtn_rec
	,p_attribute_Id				  IN NUMBER
	,p_entity_Id				  IN NUMBER
	,p_entity                     IN VARCHAR2

    )
 IS

CURSOR c_get_enty_attr_value(cv_entity_id NUMBER, cv_attribute_id NUMBER, cv_entity VARCHAR2 ) IS
    SELECT *
    FROM  PV_ENTY_ATTR_VALUES
    WHERE entity_id = cv_entity_id and
	      attribute_id = cv_attribute_id and
		  entity = cv_entity and
		  latest_flag = 'Y'
		  ;

l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Attr_Validations';
l_full_name                CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number       CONSTANT NUMBER   := 1.0;

l_ref_enty_attr_val_rec    c_get_Enty_Attr_Value%ROWTYPE ;
l_tar_enty_attr_val_rec    PV_Enty_Attr_Value_PVT.enty_attr_val_rec_type ;

l_object_version_number    NUMBER;
l_enty_attr_validation_id  NUMBER;

l_count                    NUMBER :=0;


 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Attr_Validations_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
              l_api_version_number
             ,p_api_version_number
             ,l_api_name
             ,G_PKG_NAME
             )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - start');
	  END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     --first call validations API, get valiodation id and update entity_attr_values API with that validation_id
	 IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - calling PV_ENTY_ATTR_VALIDATIONS_PVT.Create_Enty_Attr_Validation');
	 END IF;
	  PV_ENTY_ATTR_VALIDATIONS_PVT.Create_Enty_Attr_Validation(
		 p_api_version_number         => p_api_version_number
		,p_init_msg_list              => p_init_msg_list
		,p_commit                     => p_commit
		,p_validation_level           => p_validation_level

		,x_return_status              => x_return_status
		,x_msg_count                  => x_msg_count
		,x_msg_data                   => x_msg_data

		,p_enty_attr_validation_rec   => p_enty_attr_validation_rec
		,x_enty_attr_validation_id    => l_enty_attr_validation_id
      );

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;




      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Open Cursor to Select');
      END IF;

	  OPEN c_get_Enty_Attr_Value(	cv_entity_id =>p_entity_id ,
									cv_attribute_id => p_attribute_id,
									cv_entity => p_entity
								);
	  LOOP

			FETCH c_get_Enty_Attr_Value INTO l_ref_enty_attr_val_rec  ;

			EXIT WHEN c_get_Enty_Attr_Value%NOTFOUND;




			l_tar_enty_attr_val_rec.validation_id := l_enty_attr_validation_id;

			l_tar_enty_attr_val_rec.enty_attr_val_id               := l_ref_enty_attr_val_rec.enty_attr_val_id ;
			l_tar_enty_attr_val_rec.last_update_date               := SYSDATE;
			l_tar_enty_attr_val_rec.last_updated_by                := G_USER_ID;
			l_tar_enty_attr_val_rec.creation_date                  := l_ref_enty_attr_val_rec.creation_date;
			l_tar_enty_attr_val_rec.created_by                     := l_ref_enty_attr_val_rec.created_by ;
			l_tar_enty_attr_val_rec.last_update_login              := l_ref_enty_attr_val_rec.last_update_login;
			l_tar_enty_attr_val_rec.object_version_number          := l_ref_enty_attr_val_rec.object_version_number;
			l_tar_enty_attr_val_rec.entity                         := l_ref_enty_attr_val_rec.entity;
			l_tar_enty_attr_val_rec.attribute_id                   := l_ref_enty_attr_val_rec.attribute_id;
			l_tar_enty_attr_val_rec.party_id                       := l_ref_enty_attr_val_rec.party_id ;
			l_tar_enty_attr_val_rec.attr_value                     := l_ref_enty_attr_val_rec.attr_value;
			l_tar_enty_attr_val_rec.score                          := l_ref_enty_attr_val_rec.score;
			l_tar_enty_attr_val_rec.enabled_flag                   := l_ref_enty_attr_val_rec.enabled_flag ;
			l_tar_enty_attr_val_rec.entity_id                      := l_ref_enty_attr_val_rec.entity_id;
			l_tar_enty_attr_val_rec.version						   := l_ref_enty_attr_val_rec.version;
			l_tar_enty_attr_val_rec.latest_flag					   := l_ref_enty_attr_val_rec.latest_flag	;
			l_tar_enty_attr_val_rec.attr_value_extn				   := l_ref_enty_attr_val_rec.attr_value_extn;

			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - calling PV_Enty_Attr_Value_PVT.Update_Attr_Value');
			END IF;
			PV_Enty_Attr_Value_PVT.Update_Attr_Value(
				 p_api_version_number         => p_api_version_number
				,p_init_msg_list              => p_init_msg_list
				,p_commit                     => p_commit
				,p_validation_level           => p_validation_level

				,x_return_status              => x_return_status
				,x_msg_count                  => x_msg_count
				,x_msg_data                   => x_msg_data

				,p_enty_attr_val_rec		  => l_tar_enty_attr_val_rec
				,x_object_version_number	  => l_object_version_number
			);

			IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
			  RAISE FND_API.G_EXC_ERROR;
			 END IF;

			l_count := l_count +1;
		END LOOP;
		   -- Debug Message
		 IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
         PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - Close Cursor');
		 END IF;
       CLOSE     c_get_Enty_Attr_Value;


	  if(l_count = 0) then
		   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
			   FND_MESSAGE.set_token('MODE','Update');
			   FND_MESSAGE.set_token('ENTITY','Enty_Attr_Value');
			   FND_MESSAGE.set_token('ID','Entity:' || p_entity || ' entity id:' || p_entity_id || ' attribute id:' || p_attribute_id);
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
	  end if;



      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	  PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	  END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
          p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
         );
EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Attr_Validations_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Attr_Validations_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count => x_msg_count
           ,p_data  => x_msg_data
           );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Attr_Validations_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count => x_msg_count
           ,p_data  => x_msg_data
           );
End Update_Attr_Validations;




END PV_ENTY_ATTR_VALIDATIONS_PUB;

/
