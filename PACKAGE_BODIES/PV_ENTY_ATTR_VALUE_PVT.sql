--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALUE_PVT" AS
 /* $Header: pvxveavb.pls 120.3 2005/11/07 11:51:29 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Enty_Attr_Value_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


 G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_Enty_Attr_Value_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxveavb.pls';

 G_USER_ID         NUMBER := NVL(FND_GLOBAL.USER_ID,-1);
 G_LOGIN_ID        NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID,-1);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Attr_Value(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_val_rec          IN   enty_attr_val_rec_type  := g_miss_enty_attr_val_rec
    ,x_enty_attr_val_id           OUT NOCOPY  NUMBER
     )


 IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Attr_Value';
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_return_status_full                 VARCHAR2(1);
   l_object_version_number              NUMBER       := 1;
   l_org_id                             NUMBER       := FND_API.G_MISS_NUM;
   l_enty_attr_val_id                   NUMBER;
   l_dummy       	                NUMBER;
   l_enty_attr_val_rec         enty_attr_val_rec_type  := p_enty_attr_val_rec;

   CURSOR c_id IS
      SELECT PV_ENTY_ATTR_VALUES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_ENTY_ATTR_VALUES
      WHERE ENTY_ATTR_VAL_ID = l_id;

       CURSOR c_get_enty_attr_value(cv_attribute_id NUMBER,cv_entity_id NUMBER, cv_entity VARCHAR2) IS
		SELECT *
		FROM  PV_ENTY_ATTR_VALUES
		WHERE attribute_id = cv_attribute_id and
		      entity_id    = cv_entity_id and
		      entity       = cv_entity and
		      latest_flag  = 'Y';

  CURSOR c_get_attr_details(cv_attribute_id NUMBER) IS
		SELECT attribute_type,display_style,DECIMAL_POINTS,name
		FROM  PV_ATTRIBUTES_VL
		WHERE attribute_id = cv_attribute_id
		      ;
  l_already_exists  VARCHAR2(1) := 'N';
  l_attribute_type  VARCHAR2(30);
  l_display_style   VARCHAR2(30);
  l_meaning 	    VARCHAR2(80);


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Attr_Value_PVT;

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
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	  END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_enty_attr_val_rec.ENTY_ATTR_VAL_ID IS NULL OR
      p_enty_attr_val_rec.ENTY_ATTR_VAL_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_ENTY_ATTR_VAL_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_ENTY_ATTR_VAL_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
    ELSE
       l_ENTY_ATTR_VAL_ID := p_enty_attr_val_rec.ENTY_ATTR_VAL_ID;
    END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before Validate_attr_value' );

           -- Populate the default required items
           l_enty_attr_val_rec.enty_attr_val_id      := l_enty_attr_val_id;
           l_enty_attr_val_rec.last_update_date      := SYSDATE;
           l_enty_attr_val_rec.last_updated_by       := G_USER_ID;
           l_enty_attr_val_rec.creation_date         := SYSDATE;
           l_enty_attr_val_rec.created_by            := G_USER_ID;
           l_enty_attr_val_rec.last_update_login     := G_LOGIN_ID;
           l_enty_attr_val_rec.object_version_number := l_object_version_number;

	--Now validating entity attribute value
	--We would not validate for entity ENRQ.
	 if ( p_enty_attr_val_rec.entity <> 'ENRQ')
	 then
		   -- Debug message
	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
           PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Validate_attr_value');
	   END IF;

          -- Invoke validation procedures
            Validate_attr_value(
             p_api_version_number     => 1.0
            ,p_init_msg_list          => FND_API.G_FALSE
            ,p_validation_level       => p_validation_level
            ,p_validation_mode        => JTF_PLSQL_API.g_create
            ,p_enty_attr_val_rec      => l_enty_attr_val_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
            );

	end if;
--DBMS_OUTPUT.PUT_LINE('x_return_status = '||x_return_status );

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Validate_attr_value' );

      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Validate' );

for x in c_get_attr_details(cv_attribute_id => p_enty_attr_val_rec.attribute_id )
  loop
	l_attribute_type := x.attribute_type;
	l_display_style := x.display_style;

  end loop;

  for x in c_get_enty_attr_value(cv_attribute_id => p_enty_attr_val_rec.attribute_id,
				cv_entity_id    => p_enty_attr_val_rec.entity_id,
				cv_entity	=> p_enty_attr_val_rec.entity
				)
  loop

	l_already_exists := 'Y';

  end loop;

  PVX_Utility_PVT.debug_message(l_full_name ||': l_already_exists ' || l_already_exists);

  if(l_already_exists = 'Y'
   and not (l_attribute_type = 'DROPDOWN'
	    and l_DISPLAY_STYLE in ('EXTERNAL_LOV','MULTI','CHECK','PERCENTAGE')
       )
   ) then
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		  Fnd_Message.set_name('PV', 'PV_ENTY_ATTR_VAL_MULTI_ERROR');


		  FOR x IN (select meaning from pv_lookups
			    where lookup_type = 'PV_ATTRIBUTE_TYPE'
			    and lookup_code = l_attribute_type
			   ) LOOP
			l_meaning := x.meaning;
		  END LOOP;
		  Fnd_Message.set_token('ATTR_TYPE',l_meaning);

		  FOR x IN (select meaning from pv_lookups
			    where lookup_type = 'PV_ATTR_DISPLAY_STYLE'
			    and lookup_code = l_display_style
			   ) LOOP
			l_meaning := x.meaning;
		  END LOOP;
		  Fnd_Message.set_token('ATTR_STYLE',l_meaning);


		  Fnd_Msg_Pub.ADD;
	  END IF;
	  RAISE Fnd_Api.G_EXC_ERROR;


  end if;


       -- Debug Message
       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling create table handler');

      -- Invoke table handler(PV_ENTY_ATTR_VALUES_PKG.Insert_Row)
      PV_ENTY_ATTR_VALUES_PKG.Insert_Row(
           px_enty_attr_val_id       => l_enty_attr_val_rec.enty_attr_val_id
          ,p_last_update_date        => l_enty_attr_val_rec.last_update_date
          ,p_last_updated_by         => l_enty_attr_val_rec.last_updated_by
          ,p_creation_date           => l_enty_attr_val_rec.creation_date
          ,p_created_by              => l_enty_attr_val_rec.created_by
          ,p_last_update_login       => l_enty_attr_val_rec.last_update_login
          ,px_object_version_number  => l_object_version_number
          ,p_entity                  => l_enty_attr_val_rec.entity
          ,p_attribute_id            => l_enty_attr_val_rec.attribute_id
          ,p_party_id                => l_enty_attr_val_rec.party_id
          ,p_attr_value              => l_enty_attr_val_rec.attr_value
          ,p_score                   => l_enty_attr_val_rec.score
          ,p_enabled_flag            => l_enty_attr_val_rec.enabled_flag
          ,p_entity_id               => l_enty_attr_val_rec.entity_id
          -- p_security_group_id     => p_enty_attr_val_rec.security_group_id
	  ,p_version		     => l_enty_attr_val_rec.version
	  ,p_latest_flag		     => l_enty_attr_val_rec.latest_flag
	  ,p_attr_value_extn	     => l_enty_attr_val_rec.attr_value_extn
	  ,p_validation_id	     => l_enty_attr_val_rec.validation_id
          );


--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After' );

          x_enty_attr_val_id := l_enty_attr_val_id;

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
     ROLLBACK TO Create_Attr_Value_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Attr_Value_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Attr_Value_PVT;
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
End Create_Attr_Value;


PROCEDURE Update_Attr_Value(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_val_rec          IN   enty_attr_val_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER
    )
 IS

CURSOR c_get_enty_attr_value(cv_enty_attr_val_id NUMBER) IS
    SELECT *
    FROM  PV_ENTY_ATTR_VALUES
    WHERE enty_attr_val_id = cv_enty_attr_val_id;

l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Attr_Value';
l_full_name                CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number       CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number    NUMBER;
l_enty_attr_val_id         NUMBER;
l_ref_enty_attr_val_rec    c_get_Enty_Attr_Value%ROWTYPE ;
l_tar_enty_attr_val_rec    PV_Enty_Attr_Value_PVT.enty_attr_val_rec_type := p_enty_attr_val_rec;
l_rowid                    ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Attr_Value_PVT;

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
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Open Cursor to Select');
      END IF;

      OPEN c_get_Enty_Attr_Value( l_tar_enty_attr_val_rec.enty_attr_val_id);

      FETCH c_get_Enty_Attr_Value INTO l_ref_enty_attr_val_rec  ;

       If ( c_get_Enty_Attr_Value%NOTFOUND) THEN
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
			   FND_MESSAGE.set_token('MODE','Update');
			   FND_MESSAGE.set_token('ENTITY','Enty_Attr_Value');
			   FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_enty_attr_val_rec.enty_attr_val_id));
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

       -- Debug Message
	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
         PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Close Cursor');
	   END IF;
       CLOSE     c_get_Enty_Attr_Value;


      If (l_tar_enty_attr_val_rec.object_version_number is NULL or
          l_tar_enty_attr_val_rec.object_version_number = FND_API.G_MISS_NUM ) Then
		   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
			   FND_MESSAGE.set_token('COLUMN','Last_Update_Date');
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
       End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_enty_attr_val_rec.object_version_number <> l_ref_enty_attr_val_rec.object_version_number) Then
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
			   FND_MESSAGE.set_token('VALUE','Enty_Attr_Value');
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
       End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
             --Now validating entity attribute value
	     --We would not validate for entity ENRQ.
		 if(p_enty_attr_val_rec.entity <> 'ENRQ')
		 then
			-- Debug message
                   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Validate_attr_value');
		   END IF;

		  -- Invoke validation procedures
		   Validate_attr_value(
		     p_api_version_number   => 1.0
		    ,p_init_msg_list        => FND_API.G_FALSE
		    ,p_validation_level     => p_validation_level
		    ,p_validation_mode      => JTF_PLSQL_API.g_update
		    ,p_enty_attr_val_rec    => p_enty_attr_val_rec
		    ,x_return_status        => x_return_status
		    ,x_msg_count            => x_msg_count
		    ,x_msg_data             => x_msg_data
		    );

		END IF;
	END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update table handler');
	   END IF;

      -- Invoke table handler(PV_ENTY_ATTR_VALUES_PKG.Update_Row)
      PV_ENTY_ATTR_VALUES_PKG.Update_Row(
           p_enty_attr_val_id       => p_enty_attr_val_rec.enty_attr_val_id
          ,p_last_update_date       => SYSDATE
          ,p_last_updated_by        => G_USER_ID
          -- p_creation_date          => SYSDATE
          -- p_created_by             => G_USER_ID
          ,p_last_update_login      => G_LOGIN_ID
          ,p_object_version_number  => p_enty_attr_val_rec.object_version_number
          ,p_entity                 => p_enty_attr_val_rec.entity
          ,p_attribute_id           => p_enty_attr_val_rec.attribute_id
          ,p_party_id               => p_enty_attr_val_rec.party_id
          ,p_attr_value             => p_enty_attr_val_rec.attr_value
          ,p_score                  => p_enty_attr_val_rec.score
          ,p_enabled_flag           => p_enty_attr_val_rec.enabled_flag
          ,p_entity_id              => p_enty_attr_val_rec.entity_id
          -- p_security_group_id    => p_enty_attr_val_rec.security_group_id
		  ,p_version		        => p_enty_attr_val_rec.version
		  ,p_latest_flag		    => p_enty_attr_val_rec.latest_flag
		  ,p_attr_value_extn	    => p_enty_attr_val_rec.attr_value_extn
		  ,p_validation_id	        => p_enty_attr_val_rec.validation_id
          );

          x_object_version_number := p_enty_attr_val_rec.object_version_number + 1;
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
     ROLLBACK TO Update_Attr_Value_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Attr_Value_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count => x_msg_count
           ,p_data  => x_msg_data
           );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Attr_Value_PVT;
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
End Update_Attr_Value;


PROCEDURE Delete_Attr_Value(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_val_id           IN  NUMBER
    ,p_object_version_number      IN   NUMBER
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Attr_Value';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Attr_Value_PVT;

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
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling delete table handler');
       END IF;
      -- Invoke table handler(PV_ENTY_ATTR_VALUES_PKG.Delete_Row)
      PV_ENTY_ATTR_VALUES_PKG.Delete_Row(
          p_ENTY_ATTR_VAL_ID  => p_ENTY_ATTR_VAL_ID);
      --
      -- End of API body
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
           p_count    => x_msg_count
          ,p_data     => x_msg_data
          );
EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Attr_Value_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Attr_Value_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Attr_Value_PVT;
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
End Delete_Attr_Value;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Attr_Value(
     p_api_version_number       IN   NUMBER
    ,p_init_msg_list            IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status            OUT NOCOPY  VARCHAR2
    ,x_msg_count                OUT NOCOPY  NUMBER
    ,x_msg_data                 OUT NOCOPY  VARCHAR2

    ,p_enty_attr_val_id         IN   NUMBER
    ,p_object_version           IN   NUMBER
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Attr_Value';
l_api_version_number        CONSTANT NUMBER       := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_ENTY_ATTR_VAL_ID          NUMBER;

CURSOR c_Enty_Attr_Value IS
   SELECT ENTY_ATTR_VAL_ID
   FROM PV_ENTY_ATTR_VALUES
   WHERE ENTY_ATTR_VAL_ID = p_ENTY_ATTR_VAL_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
  PVX_Utility_PVT.debug_message(l_full_name||': start');
  END IF;
  OPEN c_Enty_Attr_Value;

  FETCH c_Enty_Attr_Value INTO l_ENTY_ATTR_VAL_ID;

  IF (c_Enty_Attr_Value%NOTFOUND) THEN
    CLOSE c_Enty_Attr_Value;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Enty_Attr_Value;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
     p_encoded => FND_API.g_false
    ,p_count   => x_msg_count
    ,p_data    => x_msg_data
    );
  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
  PVX_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Lock_Attr_Value_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Lock_Attr_Value_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Lock_Attr_Value_PVT;
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
End Lock_Attr_Value;


PROCEDURE check_uk_items(
     p_enty_attr_val_rec  IN   enty_attr_val_rec_type
    ,p_validation_mode    IN   VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status      OUT NOCOPY  VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN

--DBMS_OUTPUT.PUT_LINE ('entering check_uk_items');

      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
          l_valid_flag := PVX_Utility_PVT.check_uniqueness(
            'PV_ENTY_ATTR_VALUES'
           ,'ENTY_ATTR_VAL_ID = ''' || p_enty_attr_val_rec.ENTY_ATTR_VAL_ID ||''''
           );
      ELSE
         l_valid_flag := PVX_Utility_PVT.check_uniqueness(
           'PV_ENTY_ATTR_VALUES'
          ,'ENTY_ATTR_VAL_ID = ''' || p_enty_attr_val_rec.ENTY_ATTR_VAL_ID ||
           ''' AND ENTY_ATTR_VAL_ID <> ' || p_enty_attr_val_rec.ENTY_ATTR_VAL_ID
          );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
			  FND_MESSAGE.set_token('ID',to_char(p_enty_attr_val_rec.ENTY_ATTR_VAL_ID) );
			  FND_MESSAGE.set_token('ENTITY','Enty_Attr_Value');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;

--DBMS_OUTPUT.PUT_LINE ('leaving check_uk_items');

END check_uk_items;

PROCEDURE check_req_items(
     p_enty_attr_val_rec IN  enty_attr_val_rec_type
    ,p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status	   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
--DBMS_OUTPUT.PUT_LINE('check_req_items::p_validation_mode = '||p_validation_mode);
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

--DBMS_OUTPUT.PUT_LINE('Before calling enty_attr_val_id');
--DBMS_OUTPUT.PUT_LINE('p_enty_attr_val_rec.enty_attr_val_id = '||
--                    TO_CHAR(p_enty_attr_val_rec.enty_attr_val_id));


      IF p_enty_attr_val_rec.enty_attr_val_id = FND_API.g_miss_num
         OR p_enty_attr_val_rec.enty_attr_val_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','enty_attr_val_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;

--DBMS_OUTPUT.PUT_LINE('p_enty_attr_val_rec.LAST_UPDATE_DATE = '||
--                    TO_CHAR(p_enty_attr_val_rec.last_update_date));

      IF p_enty_attr_val_rec.last_update_date = FND_API.g_miss_date
         OR p_enty_attr_val_rec.last_update_date IS NULL THEN

--DBMS_OUTPUT.PUT_LINE('p_enty_attr_val_rec.LAST_UPDATE_DATE = '||
--                    TO_CHAR(p_enty_attr_val_rec.last_update_date));
		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_update_date');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

--DBMS_OUTPUT.PUT_LINE('p_enty_attr_val_rec.last_updated_by = '||
--                    TO_CHAR(p_enty_attr_val_rec.last_updated_by));

      IF p_enty_attr_val_rec.last_updated_by = FND_API.g_miss_num
         OR p_enty_attr_val_rec.last_updated_by IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_updated_by');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.creation_date = FND_API.g_miss_date
         OR p_enty_attr_val_rec.creation_date IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','creation_date');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.created_by = FND_API.g_miss_num
         OR p_enty_attr_val_rec.created_by IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','created_by');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.last_update_login = FND_API.g_miss_num
         OR p_enty_attr_val_rec.last_update_login IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_update_login');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.object_version_number = FND_API.g_miss_num
         OR p_enty_attr_val_rec.object_version_number IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','object_version_number');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.entity = FND_API.g_miss_char
         OR p_enty_attr_val_rec.entity IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','entity');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.attribute_id = FND_API.g_miss_num
         OR p_enty_attr_val_rec.attribute_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','attribute_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.enabled_flag = FND_API.g_miss_char
         OR p_enty_attr_val_rec.enabled_flag IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','enabled_flag');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.entity_id = FND_API.g_miss_num
      OR p_enty_attr_val_rec.entity_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','entity_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

ELSE

      IF p_enty_attr_val_rec.enty_attr_val_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','enty_attr_val_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.last_update_date IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_update_date');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.last_updated_by IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_updated_by');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.creation_date IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','creation_date');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.created_by IS NULL THEN

		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','created_by');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.last_update_login IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_update_login');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.object_version_number IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','object_version_number');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.entity IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','entity');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.attribute_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','attribute_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.enabled_flag IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','enabled_flag');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


      IF p_enty_attr_val_rec.entity_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','entity_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

END check_req_items;

PROCEDURE check_FK_items(
     p_enty_attr_val_rec  IN  enty_attr_val_rec_type
    ,x_return_status      OUT NOCOPY VARCHAR2
    )
IS

CURSOR c_check_attr_exists(cv_attribute_id NUMBER) IS
		SELECT 1
		FROM  PV_ATTRIBUTES_b
		WHERE attribute_id = cv_attribute_id
		      ;
CURSOR c_check_entattr_exists(cv_attribute_id NUMBER, cv_entity VARCHAR2) IS
		SELECT 1
		FROM  PV_ENTITY_ATTRS
		WHERE attribute_id = cv_attribute_id and entity = cv_entity
		      ;

l_exists	BOOLEAN := false;
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Attr_Value';
 l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      PVX_Utility_PVT.debug_message('Attribute Id:'|| p_enty_attr_val_rec.attribute_id||': - entity:' || p_enty_attr_val_rec.entity );
   END IF;

  for x in c_check_attr_exists(cv_attribute_id => p_enty_attr_val_rec.attribute_id )
  loop
	l_exists := true;
  end loop;

  if(l_exists = false) then
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		FND_MESSAGE.set_name('PV', 'PV_ATTRIBUTE_NOT_EXISTS');
		FND_MESSAGE.set_token('ATTRIBUTE_ID',p_enty_attr_val_rec.attribute_id);
		FND_MSG_PUB.add;
	END IF;
        x_return_status := FND_API.g_ret_sts_error;
	return;
  end if;

  l_exists	 := false;

  for x in c_check_entattr_exists(cv_attribute_id => p_enty_attr_val_rec.attribute_id, cv_entity => p_enty_attr_val_rec.entity )
  loop
	l_exists := true;
  end loop;

  if(l_exists = false) then
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		FND_MESSAGE.set_name('PV', 'PV_ATTR_ENTITY_NOT_EXISTS');
		FND_MESSAGE.set_token('ATTRIBUTE_ID',p_enty_attr_val_rec.attribute_id);
		FND_MESSAGE.set_token('ENTITY',p_enty_attr_val_rec.entity);
		FND_MSG_PUB.add;
	END IF;
	x_return_status := FND_API.g_ret_sts_error;
	return;
  end if;


END check_FK_items;

PROCEDURE check_Lookup_items(
     p_enty_attr_val_rec  IN  enty_attr_val_rec_type
    ,x_return_status      OUT NOCOPY VARCHAR2
    )
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Lookup_items;

PROCEDURE Check_attr_value_Items (
     p_enty_attr_val_rec       IN    enty_attr_val_rec_type
    ,p_validation_mode         IN    VARCHAR2
    ,x_return_status           OUT NOCOPY   VARCHAR2
    )
IS
 l_api_name    CONSTANT VARCHAR2(30) := 'Check_attr_value_Items';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   -- Check Items Uniqueness API calls

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_uk_items' );

   check_uk_items(
       p_enty_attr_val_rec  => p_enty_attr_val_rec
      ,p_validation_mode    => p_validation_mode
      ,x_return_status      => x_return_status
      );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_req_items' );

   check_req_items(
       p_enty_attr_val_rec   => p_enty_attr_val_rec
      ,p_validation_mode     => p_validation_mode
      ,x_return_status       => x_return_status
      );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_FK_items' );

   check_FK_items(
       p_enty_attr_val_rec => p_enty_attr_val_rec
      ,x_return_status       => x_return_status
      );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_Lookup_items' );

   check_Lookup_items(
       p_enty_attr_val_rec => p_enty_attr_val_rec
      ,x_return_status       => x_return_status
      );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_attr_value_Items;

PROCEDURE Complete_enty_attr_val_rec (
    p_enty_attr_val_rec IN  enty_attr_val_rec_type
   ,x_complete_rec        OUT NOCOPY enty_attr_val_rec_type
   )
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_enty_attr_values
      WHERE enty_attr_val_id = p_enty_attr_val_rec.enty_attr_val_id;
   l_pv_enty_attr_val_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_enty_attr_val_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_pv_enty_attr_val_rec;
   CLOSE c_complete;

   -- enty_attr_val_id
   IF p_enty_attr_val_rec.enty_attr_val_id = FND_API.g_miss_num THEN
      x_complete_rec.enty_attr_val_id := l_pv_enty_attr_val_rec.enty_attr_val_id;
   END IF;

   -- last_update_date
   IF p_enty_attr_val_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_pv_enty_attr_val_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_enty_attr_val_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_pv_enty_attr_val_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_enty_attr_val_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_pv_enty_attr_val_rec.creation_date;
   END IF;

   -- created_by
   IF p_enty_attr_val_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_pv_enty_attr_val_rec.created_by;
   END IF;

   -- last_update_login
   IF p_enty_attr_val_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_pv_enty_attr_val_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_enty_attr_val_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_pv_enty_attr_val_rec.object_version_number;
   END IF;

   -- entity
   IF p_enty_attr_val_rec.entity = FND_API.g_miss_char THEN
      x_complete_rec.entity := l_pv_enty_attr_val_rec.entity;
   END IF;

   -- attribute_id
   IF p_enty_attr_val_rec.attribute_id = FND_API.g_miss_num THEN
      x_complete_rec.attribute_id := l_pv_enty_attr_val_rec.attribute_id;
   END IF;

   -- party_id
   IF p_enty_attr_val_rec.party_id = FND_API.g_miss_num THEN
      x_complete_rec.party_id := l_pv_enty_attr_val_rec.party_id;
   END IF;

   -- attr_value
   IF p_enty_attr_val_rec.attr_value = FND_API.g_miss_char THEN
      x_complete_rec.attr_value := l_pv_enty_attr_val_rec.attr_value;
   END IF;

   -- score
   IF p_enty_attr_val_rec.score = FND_API.g_miss_char THEN
      x_complete_rec.score := l_pv_enty_attr_val_rec.score;
   END IF;

   -- enabled_flag
   IF p_enty_attr_val_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_pv_enty_attr_val_rec.enabled_flag;
   END IF;

   -- entity_id
   IF p_enty_attr_val_rec.entity_id = FND_API.g_miss_num THEN
      x_complete_rec.entity_id := l_pv_enty_attr_val_rec.entity_id;
   END IF;


   -- version
   IF p_enty_attr_val_rec.version = FND_API.g_miss_num THEN
      x_complete_rec.version := l_pv_enty_attr_val_rec.version;
   END IF;

 -- latest_flag
   IF p_enty_attr_val_rec.latest_flag = FND_API.g_miss_char THEN
      x_complete_rec.latest_flag := l_pv_enty_attr_val_rec.latest_flag;
   END IF;

    -- attr_value_extn
   IF p_enty_attr_val_rec.attr_value_extn = FND_API.g_miss_char THEN
      x_complete_rec.attr_value_extn := l_pv_enty_attr_val_rec.attr_value_extn;
   END IF;

    -- version
   IF p_enty_attr_val_rec.validation_id = FND_API.g_miss_num THEN
      x_complete_rec.validation_id := l_pv_enty_attr_val_rec.validation_id;
   END IF;


   -- security_group_id
   -- IF p_enty_attr_val_rec.security_group_id = FND_API.g_miss_num THEN
   --    x_complete_rec.security_group_id := l_pv_enty_attr_val_rec.security_group_id;
   -- END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_enty_attr_val_rec;

PROCEDURE Validate_attr_value(
     p_api_version_number   IN   NUMBER
    ,p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE
    ,p_validation_level     IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode      IN   VARCHAR2 := JTF_PLSQL_API.G_UPDATE
    ,p_enty_attr_val_rec    IN   enty_attr_val_rec_type
    ,x_return_status        OUT NOCOPY  VARCHAR2
    ,x_msg_count            OUT NOCOPY  NUMBER
    ,x_msg_data             OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_attr_value';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number     NUMBER;
l_pv_enty_attr_val_rec      enty_attr_val_rec_type;

 BEGIN

 --DBMS_OUTPUT.PUT_LINE ('Enter Validate Procedure with mode= '||p_validation_mode);

      -- Standard Start of API savepoint
      SAVEPOINT Validate_attr_value;

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
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before Check_attr_value_Items' );

              Check_attr_value_Items(
                  p_enty_attr_val_rec => p_enty_attr_val_rec
                 ,p_validation_mode   => p_validation_mode
                 ,x_return_status     => x_return_status
              );

--DBMS_OUTPUT.PUT_LINE('After Check_attr_value_Items::x_return_status = '||x_return_status);
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Check_attr_value_Items' );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_enty_attr_val_rec(
          p_enty_attr_val_rec    => p_enty_attr_val_rec
         ,x_complete_rec         => l_pv_enty_attr_val_rec
         );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_attr_val_rec(
            p_api_version_number     => 1.0
           ,p_init_msg_list          => FND_API.G_FALSE
           ,x_return_status          => x_return_status
           ,x_msg_count              => x_msg_count
           ,x_msg_data               => x_msg_data
           ,p_enty_attr_val_rec      => l_pv_enty_attr_val_rec
           ,p_validation_mode        => p_validation_mode
           );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

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
     ROLLBACK TO Validate_attr_value;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_attr_value;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_attr_value;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );
End Validate_attr_value;


PROCEDURE Validate_attr_val_rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_enty_attr_val_rec          IN   enty_attr_val_rec_type
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
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
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: Validate_dm_model_rec');
       END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
         p_count          =>   x_msg_count
        ,p_data           =>   x_msg_data
        );
END Validate_attr_val_rec;

END PV_Enty_Attr_Value_PVT;

/
